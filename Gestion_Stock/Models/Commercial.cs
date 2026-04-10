using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gestion_Stock.Models
{
    /// <summary>
    /// Représente un commercial attaché à un fournisseur
    /// </summary>
    public class Commercial
    {
        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "Le nom est requis")]
        [StringLength(200)]
        [Display(Name = "Nom")]
        public string Nom { get; set; } = string.Empty;

        [StringLength(100)]
        [Display(Name = "Région")]
        public string? Region { get; set; }

        [Column(TypeName = "decimal(5,2)")]
        [Range(0, 100)]
        [Display(Name = "Commission (%)")]
        public decimal Commission { get; set; }

        [Phone]
        [StringLength(20)]
        [Display(Name = "Téléphone")]
        public string? Telephone { get; set; }

        [EmailAddress]
        [StringLength(100)]
        [Display(Name = "Email")]
        public string? Email { get; set; }

        // Lien vers le fournisseur (optionnel)
        public int? FournisseurId { get; set; }

        [ForeignKey("FournisseurId")]
        public virtual Fournisseur? Fournisseur { get; set; }

        public virtual ICollection<Livraison> Livraisons { get; set; } = new List<Livraison>();
    }
}
