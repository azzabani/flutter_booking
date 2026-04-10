using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gestion_Stock.Models
{
    /// <summary>
    /// Représente une ligne d'une commande d'achat
    /// </summary>
    public class LigneCommande
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int CommandeAchatId { get; set; }

        [Required]
        public int ProduitId { get; set; }

        [Required(ErrorMessage = "La quantité commandée est requise")]
        [Range(1, int.MaxValue, ErrorMessage = "La quantité doit être supérieure à 0")]
        [Display(Name = "Quantité commandée")]
        public int Quantite { get; set; }

        [Display(Name = "Quantité reçue")]
        [Range(0, int.MaxValue)]
        public int QuantiteRecue { get; set; } = 0; // Pour livraisons partielles

        [Required(ErrorMessage = "Le prix unitaire est requis")]
        [Column(TypeName = "decimal(18,2)")]
        [Display(Name = "Prix unitaire HT")]
        public decimal PrixUnitaire { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        [Display(Name = "Sous-total HT")]
        public decimal SousTotal => Quantite * PrixUnitaire;

        // Navigation properties
        [ForeignKey("CommandeAchatId")]
        public virtual CommandeAchat? CommandeAchat { get; set; }

        [ForeignKey("ProduitId")]
        public virtual Produit? Produit { get; set; }
    }
}
