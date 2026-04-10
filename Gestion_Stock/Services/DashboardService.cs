using Gestion_Stock.Data;
using Gestion_Stock.Models;
using Microsoft.EntityFrameworkCore;

namespace Gestion_Stock.Services
{
    /// <summary>
    /// Service tableau de bord — café-restaurant
    /// </summary>
    public class DashboardService : IDashboardService
    {
        private readonly ApplicationDbContext _context;

        public DashboardService(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Produits les plus consommés (sorties "Utilisation") par mois
        /// </summary>
        public async Task<List<ProduitConsommationDto>> ObtenirProduitsLesPlusConsommes(int mois, int annee)
        {
            var data = await _context.MouvementsStock
                .Include(m => m.Produit)
                .Where(m => m.TypeMouvement == "Sortie"
                         && m.Motif == "Utilisation"
                         && m.DateMouvement.Month == mois
                         && m.DateMouvement.Year == annee)
                .GroupBy(m => new { m.ProduitId, m.Produit!.Nom, m.Produit.Unite })
                .Select(g => new ProduitConsommationDto
                {
                    ProduitId = g.Key.ProduitId,
                    NomProduit = g.Key.Nom,
                    Unite = g.Key.Unite,
                    QuantiteSortie = g.Sum(m => m.Quantite),
                    MotifPrincipal = "Utilisation"
                })
                .OrderByDescending(p => p.QuantiteSortie)
                .Take(10)
                .ToListAsync();

            return data;
        }

        /// <summary>
        /// Produits les plus commandés (lignes commandes livrées) par mois
        /// </summary>
        public async Task<List<ProduitVenteDto>> ObtenirProduitsLesPlusVendus(int mois, int annee)
        {
            var data = await _context.LignesCommande
                .Include(lc => lc.CommandeAchat)
                .Include(lc => lc.Produit)
                .Where(lc => lc.CommandeAchat != null
                          && lc.CommandeAchat.DateCommande.Month == mois
                          && lc.CommandeAchat.DateCommande.Year == annee
                          && lc.CommandeAchat.Statut == "Livrée")
                .GroupBy(lc => new { lc.ProduitId, lc.Produit!.Nom })
                .Select(g => new ProduitVenteDto
                {
                    ProduitId = g.Key.ProduitId,
                    NomProduit = g.Key.Nom,
                    QuantiteTotale = g.Sum(lc => lc.Quantite),
                    MontantTotal = g.Sum(lc => lc.Quantite * lc.PrixUnitaire)
                })
                .OrderByDescending(p => p.QuantiteTotale)
                .Take(10)
                .ToListAsync();

            return data;
        }

        /// <summary>
        /// Fournisseur le moins cher par produit
        /// </summary>
        public async Task<List<MeilleureOffreDto>> ObtenirMeilleuresOffres()
        {
            var all = await _context.FournisseurProduits
                .Include(fp => fp.Produit)
                .Include(fp => fp.Fournisseur)
                .ToListAsync();

            return all
                .GroupBy(fp => fp.ProduitId)
                .Select(g => g.OrderBy(fp => fp.PrixAchat).First())
                .Select(fp => new MeilleureOffreDto
                {
                    ProduitId = fp.ProduitId,
                    NomProduit = fp.Produit!.Nom,
                    FournisseurId = fp.FournisseurId,
                    NomFournisseur = fp.Fournisseur!.Nom,
                    PrixAchat = fp.PrixAchat,
                    DelaiLivraison = fp.DelaiLivraisonJours
                })
                .OrderBy(m => m.NomProduit)
                .ToList();
        }

        /// <summary>
        /// Commandes en attente ou en retard (> 7 jours sans livraison)
        /// </summary>
        public async Task<List<CommandeAchat>> ObtenirCommandesEnAttente()
        {
            return await _context.CommandesAchat
                .Include(c => c.Fournisseur)
                .Include(c => c.Employe)
                .Where(c => c.Statut == "En attente" || c.Statut == "Confirmée")
                .OrderBy(c => c.DateCommande)
                .ToListAsync();
        }

        /// <summary>
        /// Statistiques générales du tableau de bord
        /// </summary>
        public async Task<StatistiquesDto> ObtenirStatistiques()
        {
            var limiteRetard = DateTime.Now.AddDays(-7);

            return new StatistiquesDto
            {
                NombreProduits = await _context.Produits.CountAsync(),
                NombreCategories = await _context.Categories.CountAsync(),
                NombreFournisseurs = await _context.Fournisseurs.CountAsync(),
                NombreCommandes = await _context.CommandesAchat.CountAsync(),
                NombreAlertesNonLues = await _context.Alertes.CountAsync(a => !a.EstLue),
                ValeurTotaleStock = await _context.Produits.SumAsync(p => p.StockActuel * p.PrixUnitaire),
                ProduitsEnRupture = await _context.Produits.CountAsync(p => p.StockActuel <= p.SeuilMin),
                ProduitsSurstock = await _context.Produits.CountAsync(p => p.StockActuel >= p.SeuilMax),
                CommandesEnAttente = await _context.CommandesAchat.CountAsync(c => c.Statut == "En attente"),
                CommandesEnRetard = await _context.CommandesAchat.CountAsync(c =>
                    (c.Statut == "En attente" || c.Statut == "Confirmée") && c.DateCommande < limiteRetard)
            };
        }
    }
}
