using Gestion_Stock.Data;
using Gestion_Stock.Models;
using Microsoft.EntityFrameworkCore;

namespace Gestion_Stock.Services
{
    /// <summary>
    /// Service de gestion des mouvements de stock
    /// </summary>
    public class MouvementService : IMouvementService
    {
        private readonly ApplicationDbContext _context;
        private readonly IAlertService _alertService;

        public MouvementService(ApplicationDbContext context, IAlertService alertService)
        {
            _context = context;
            _alertService = alertService;
        }

        public async Task<MouvementStock> EnregistrerMouvement(int produitId, int quantite,
            string typeMouvement, string motif, string? raison = null,
            int? commandeId = null, int? employeId = null)
        {
            var produit = await _context.Produits.FindAsync(produitId)
                ?? throw new InvalidOperationException($"Produit {produitId} introuvable");

            // Mettre à jour le stock
            if (typeMouvement == "Entrée")
                produit.StockActuel += quantite;
            else if (typeMouvement == "Sortie")
                produit.StockActuel = Math.Max(0, produit.StockActuel - quantite);

            var mouvement = new MouvementStock
            {
                ProduitId = produitId,
                Quantite = quantite,
                TypeMouvement = typeMouvement,
                Motif = motif,
                Raison = raison,
                DateMouvement = DateTime.Now,
                CommandeAchatId = commandeId,
                EmployeId = employeId
            };

            _context.MouvementsStock.Add(mouvement);
            await _context.SaveChangesAsync();

            // Vérifier les alertes après chaque mouvement
            await _alertService.VerifierProduit(produitId);

            return mouvement;
        }

        public async Task GenererMouvementsLivraison(int commandeId, bool partielle = false)
        {
            var commande = await _context.CommandesAchat
                .Include(c => c.LignesCommande)
                    .ThenInclude(lc => lc.Produit)
                .FirstOrDefaultAsync(c => c.Id == commandeId)
                ?? throw new InvalidOperationException($"Commande {commandeId} introuvable");

            foreach (var ligne in commande.LignesCommande)
            {
                // En livraison partielle, utiliser QuantiteRecue ; sinon Quantite
                int qte = partielle ? ligne.QuantiteRecue : ligne.Quantite;
                if (qte <= 0) continue;

                await EnregistrerMouvement(
                    produitId: ligne.ProduitId,
                    quantite: qte,
                    typeMouvement: "Entrée",
                    motif: "Achat",
                    raison: $"Livraison commande #{commandeId}" + (partielle ? " (partielle)" : ""),
                    commandeId: commandeId
                );
            }
        }

        public async Task<List<MouvementStock>> ObtenirHistorique(int? produitId = null,
            string? type = null, string? motif = null,
            DateTime? dateDebut = null, DateTime? dateFin = null)
        {
            var query = _context.MouvementsStock
                .Include(m => m.Produit)
                    .ThenInclude(p => p!.Categorie)
                .Include(m => m.Employe)
                .AsQueryable();

            if (produitId.HasValue)
                query = query.Where(m => m.ProduitId == produitId);
            if (!string.IsNullOrEmpty(type))
                query = query.Where(m => m.TypeMouvement == type);
            if (!string.IsNullOrEmpty(motif))
                query = query.Where(m => m.Motif == motif);
            if (dateDebut.HasValue)
                query = query.Where(m => m.DateMouvement >= dateDebut);
            if (dateFin.HasValue)
                query = query.Where(m => m.DateMouvement <= dateFin.Value.AddDays(1));

            return await query.OrderByDescending(m => m.DateMouvement).ToListAsync();
        }
    }
}
