using Gestion_Stock.Data;
using Gestion_Stock.Models;
using Microsoft.EntityFrameworkCore;

namespace Gestion_Stock.Services
{
    /// <summary>
    /// Service de gestion des alertes de stock
    /// </summary>
    public class AlertService : IAlertService
    {
        private readonly ApplicationDbContext _context;

        public AlertService(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Vérifie tous les produits et crée des alertes si nécessaire
        /// </summary>
        public async Task VerifierStocksEtCreerAlertes()
        {
            var produits = await _context.Produits.ToListAsync();

            foreach (var produit in produits)
            {
                await VerifierEtCreerAlerte(produit);
            }

            await _context.SaveChangesAsync();
        }

        /// <summary>
        /// Vérifie un produit spécifique et crée une alerte si nécessaire
        /// </summary>
        public async Task VerifierProduit(int produitId)
        {
            var produit = await _context.Produits.FindAsync(produitId);
            if (produit != null)
            {
                await VerifierEtCreerAlerte(produit);
                await _context.SaveChangesAsync();
            }
        }

        /// <summary>
        /// Vérifie un produit et crée une alerte appropriée
        /// </summary>
        private async Task VerifierEtCreerAlerte(Produit produit)
        {
            // Vérifier si une alerte similaire existe déjà et n'est pas lue
            var alerteExistante = await _context.Alertes
                .Where(a => a.ProduitId == produit.Id && !a.EstLue)
                .OrderByDescending(a => a.DateCreation)
                .FirstOrDefaultAsync();

            // Stock inférieur ou égal au seuil minimum
            if (produit.StockActuel <= produit.SeuilMin)
            {
                // Ne créer une alerte que si aucune alerte de ce type n'existe
                if (alerteExistante == null || alerteExistante.TypeAlerte != "Approvisionnement")
                {
                    var alerte = new Alerte
                    {
                        TypeAlerte = "Approvisionnement",
                        Message = $"Le produit '{produit.Nom}' nécessite un approvisionnement. Stock actuel: {produit.StockActuel}, Seuil minimum: {produit.SeuilMin}",
                        DateCreation = DateTime.Now,
                        EstLue = false,
                        ProduitId = produit.Id
                    };
                    _context.Alertes.Add(alerte);
                }
            }
            // Stock supérieur ou égal au seuil maximum
            else if (produit.StockActuel >= produit.SeuilMax)
            {
                // Ne créer une alerte que si aucune alerte de ce type n'existe
                if (alerteExistante == null || alerteExistante.TypeAlerte != "Surstock")
                {
                    var alerte = new Alerte
                    {
                        TypeAlerte = "Surstock",
                        Message = $"Le produit '{produit.Nom}' est en surstock. Ne plus approvisionner. Stock actuel: {produit.StockActuel}, Seuil maximum: {produit.SeuilMax}",
                        DateCreation = DateTime.Now,
                        EstLue = false,
                        ProduitId = produit.Id
                    };
                    _context.Alertes.Add(alerte);
                }
            }
            else
            {
                // Si le stock est normal, marquer les anciennes alertes comme lues
                if (alerteExistante != null)
                {
                    alerteExistante.EstLue = true;
                }
            }
        }

        /// <summary>
        /// Récupère toutes les alertes non lues
        /// </summary>
        public async Task<List<Alerte>> ObtenirAlertesNonLues()
        {
            return await _context.Alertes
                .Include(a => a.Produit)
                .Where(a => !a.EstLue)
                .OrderByDescending(a => a.DateCreation)
                .ToListAsync();
        }

        /// <summary>
        /// Marque une alerte comme lue
        /// </summary>
        public async Task MarquerCommeLue(int alerteId)
        {
            var alerte = await _context.Alertes.FindAsync(alerteId);
            if (alerte != null)
            {
                alerte.EstLue = true;
                await _context.SaveChangesAsync();
            }
        }

        /// <summary>
        /// Marque toutes les alertes comme lues
        /// </summary>
        public async Task MarquerToutesCommeLues()
        {
            var alertes = await _context.Alertes.Where(a => !a.EstLue).ToListAsync();
            foreach (var alerte in alertes)
            {
                alerte.EstLue = true;
            }
            await _context.SaveChangesAsync();
        }
    }
}
