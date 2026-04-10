using Gestion_Stock.Models;

namespace Gestion_Stock.Services
{
    public interface IMouvementService
    {
        /// <summary>
        /// Enregistre un mouvement de stock et met à jour le stock du produit
        /// </summary>
        Task<MouvementStock> EnregistrerMouvement(int produitId, int quantite, string typeMouvement,
            string motif, string? raison = null, int? commandeId = null, int? employeId = null);

        /// <summary>
        /// Génère les mouvements d'entrée lors d'une livraison
        /// </summary>
        Task GenererMouvementsLivraison(int commandeId, bool partielle = false);

        /// <summary>
        /// Obtient l'historique des mouvements avec filtres
        /// </summary>
        Task<List<MouvementStock>> ObtenirHistorique(int? produitId = null, string? type = null,
            string? motif = null, DateTime? dateDebut = null, DateTime? dateFin = null);
    }
}
