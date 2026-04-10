using Gestion_Stock.Models;

namespace Gestion_Stock.Services
{
    /// <summary>
    /// Interface pour le service de gestion des alertes
    /// </summary>
    public interface IAlertService
    {
        /// <summary>
        /// Vérifie les niveaux de stock et crée des alertes si nécessaire
        /// </summary>
        Task VerifierStocksEtCreerAlertes();

        /// <summary>
        /// Vérifie un produit spécifique et crée une alerte si nécessaire
        /// </summary>
        Task VerifierProduit(int produitId);

        /// <summary>
        /// Récupère toutes les alertes non lues
        /// </summary>
        Task<List<Alerte>> ObtenirAlertesNonLues();

        /// <summary>
        /// Marque une alerte comme lue
        /// </summary>
        Task MarquerCommeLue(int alerteId);

        /// <summary>
        /// Marque toutes les alertes comme lues
        /// </summary>
        Task MarquerToutesCommeLues();
    }
}
