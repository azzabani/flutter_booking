using Gestion_Stock.Models;

namespace Gestion_Stock.Services
{
    public interface IDashboardService
    {
        Task<List<ProduitVenteDto>> ObtenirProduitsLesPlusVendus(int mois, int annee);
        Task<List<ProduitConsommationDto>> ObtenirProduitsLesPlusConsommes(int mois, int annee);
        Task<List<MeilleureOffreDto>> ObtenirMeilleuresOffres();
        Task<List<CommandeAchat>> ObtenirCommandesEnAttente();
        Task<StatistiquesDto> ObtenirStatistiques();
    }

    public class ProduitVenteDto
    {
        public int ProduitId { get; set; }
        public string NomProduit { get; set; } = string.Empty;
        public int QuantiteTotale { get; set; }
        public decimal MontantTotal { get; set; }
    }

    public class ProduitConsommationDto
    {
        public int ProduitId { get; set; }
        public string NomProduit { get; set; } = string.Empty;
        public string Unite { get; set; } = string.Empty;
        public int QuantiteSortie { get; set; }
        public string MotifPrincipal { get; set; } = string.Empty;
    }

    public class MeilleureOffreDto
    {
        public int ProduitId { get; set; }
        public string NomProduit { get; set; } = string.Empty;
        public int FournisseurId { get; set; }
        public string NomFournisseur { get; set; } = string.Empty;
        public decimal PrixAchat { get; set; }
        public int DelaiLivraison { get; set; }
    }

    public class StatistiquesDto
    {
        public int NombreProduits { get; set; }
        public int NombreCategories { get; set; }
        public int NombreFournisseurs { get; set; }
        public int NombreCommandes { get; set; }
        public int NombreAlertesNonLues { get; set; }
        public decimal ValeurTotaleStock { get; set; }
        public int ProduitsEnRupture { get; set; }
        public int ProduitsSurstock { get; set; }
        public int CommandesEnAttente { get; set; }
        public int CommandesEnRetard { get; set; }
    }
}
