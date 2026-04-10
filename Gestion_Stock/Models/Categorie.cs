using System.ComponentModel.DataAnnotations;

namespace Gestion_Stock.Models
{
    /// <summary>
    /// Représente une catégorie de produits
    /// </summary>
    public class Categorie
    {
        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "Le nom est requis")]
        [StringLength(100, ErrorMessage = "Le nom ne peut pas dépasser 100 caractères")]
        [Display(Name = "Nom de la catégorie")]
        public string Nom { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "La description ne peut pas dépasser 500 caractères")]
        [Display(Name = "Description")]
        public string? Description { get; set; }

        // Navigation property
        public virtual ICollection<Produit> Produits { get; set; } = new List<Produit>();
    }
}
