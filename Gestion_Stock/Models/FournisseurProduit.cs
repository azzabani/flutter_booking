using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gestion_Stock.Models
{
    /// <summary>
    /// Association entre un fournisseur et un produit avec conditions commerciales
    /// </summary>
    public class FournisseurProduit
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int FournisseurId { get; set; }

        [Required]
        public int ProduitId { get; set; }

        [Required(ErrorMessage = "Le prix d'achat est requis")]
        [Column(TypeName = "decimal(18,2)")]
        [Range(0, double.MaxValue)]
        [Display(Name = "Prix d'achat HT")]
        public decimal PrixAchat { get; set; }

        [StringLength(100)]
        [Display(Name = "Référence fournisseur")]
        public string? ReferenceFournisseur { get; set; }

        [Range(0, int.MaxValue)]
        [Display(Name = "Délai de livraison (jours)")]
        public int DelaiLivraisonJours { get; set; }

        [Display(Name = "Fournisseur préféré")]
        public bool EstPrefere { get; set; } = false;

        // Navigation properties
        [ForeignKey("FournisseurId")]
        public virtual Fournisseur? Fournisseur { get; set; }

        [ForeignKey("ProduitId")]
        public virtual Produit? Produit { get; set; }
    }
}
