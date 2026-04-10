using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gestion_Stock.Models
{
    /// <summary>
    /// Représente une alerte de stock
    /// </summary>
    public class Alerte
    {
        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "Le type d'alerte est requis")]
        [StringLength(100, ErrorMessage = "Le type ne peut pas dépasser 100 caractères")]
        [Display(Name = "Type d'alerte")]
        public string TypeAlerte { get; set; } = string.Empty;

        [Required(ErrorMessage = "Le message est requis")]
        [StringLength(500, ErrorMessage = "Le message ne peut pas dépasser 500 caractères")]
        [Display(Name = "Message")]
        public string Message { get; set; } = string.Empty;

        [Required(ErrorMessage = "La date de création est requise")]
        [Display(Name = "Date de création")]
        [DataType(DataType.DateTime)]
        public DateTime DateCreation { get; set; } = DateTime.Now;

        [Display(Name = "Est lue")]
        public bool EstLue { get; set; } = false;

        [Required]
        public int ProduitId { get; set; }

        // Navigation properties
        [ForeignKey("ProduitId")]
        public virtual Produit? Produit { get; set; }
    }
}
