using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gestion_Stock.Models
{
    /// <summary>
    /// Représente un produit dans le système de gestion de stock
    /// </summary>
    public class Produit
    {
        /// <summary>
        /// Identifiant unique du produit
        /// </summary>
        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "Le nom est requis")]
        [StringLength(200, ErrorMessage = "Le nom ne peut pas dépasser 200 caractères")]
        [Display(Name = "Nom du produit")]
        public string Nom { get; set; } = string.Empty;

        [StringLength(100, ErrorMessage = "La référence ne peut pas dépasser 100 caractères")]
        [Display(Name = "Référence")]
        public string? Reference { get; set; }

        /// <summary>
        /// Prix unitaire du produit en euros
        /// </summary>
        [Required(ErrorMessage = "Le prix unitaire est requis")]
        [Column(TypeName = "decimal(18,2)")]
        [Range(0, double.MaxValue, ErrorMessage = "Le prix doit être positif")]
        [Display(Name = "Prix unitaire")]
        public decimal PrixUnitaire { get; set; }

        [Required(ErrorMessage = "Le stock actuel est requis")]
        [Range(0, int.MaxValue, ErrorMessage = "Le stock doit être positif")]
        [Display(Name = "Stock actuel")]
        public int StockActuel { get; set; }

        [Required(ErrorMessage = "Le seuil minimum est requis")]
        [Range(0, int.MaxValue, ErrorMessage = "Le seuil minimum doit être positif")]
        [Display(Name = "Seuil minimum")]
        public int SeuilMin { get; set; }

        [Required(ErrorMessage = "Le seuil maximum est requis")]
        [Range(0, int.MaxValue, ErrorMessage = "Le seuil maximum doit être positif")]
        [Display(Name = "Seuil maximum")]
        public int SeuilMax { get; set; }

        [StringLength(20)]
        [Display(Name = "Unité de mesure")]
        public string Unite { get; set; } = "unité"; // kg, L, g, cl, sachet, boîte...

        [Required(ErrorMessage = "La catégorie est requise")]
        [Display(Name = "Catégorie")]
        public int CategorieId { get; set; }

        // Navigation properties
        [ForeignKey("CategorieId")]
        public virtual Categorie? Categorie { get; set; }

        public virtual ICollection<FournisseurProduit> FournisseurProduits { get; set; } = new List<FournisseurProduit>();
        public virtual ICollection<Alerte> Alertes { get; set; } = new List<Alerte>();
        public virtual ICollection<MouvementStock> MouvementsStock { get; set; } = new List<MouvementStock>();
        public virtual ICollection<LigneCommande> LignesCommande { get; set; } = new List<LigneCommande>();
    }
}
