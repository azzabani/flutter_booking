using System.ComponentModel.DataAnnotations;

namespace Gestion_Stock.Models
{
    /// <summary>
    /// Représente un fournisseur
    /// </summary>
    public class Fournisseur
    {
        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "Le nom est requis")]
        [StringLength(200, ErrorMessage = "Le nom ne peut pas dépasser 200 caractères")]
        [Display(Name = "Nom du fournisseur")]
        public string Nom { get; set; } = string.Empty;

        [Required(ErrorMessage = "L'email est requis")]
        [EmailAddress(ErrorMessage = "Format d'email invalide")]
        [StringLength(100, ErrorMessage = "L'email ne peut pas dépasser 100 caractères")]
        [Display(Name = "Email")]
        public string Email { get; set; } = string.Empty;

        [Phone(ErrorMessage = "Format de téléphone invalide")]
        [StringLength(20, ErrorMessage = "Le téléphone ne peut pas dépasser 20 caractères")]
        [Display(Name = "Téléphone")]
        public string? Telephone { get; set; }

        [StringLength(300, ErrorMessage = "L'adresse ne peut pas dépasser 300 caractères")]
        [Display(Name = "Adresse")]
        public string? Adresse { get; set; }

        // Navigation properties
        public virtual ICollection<FournisseurProduit> FournisseurProduits { get; set; } = new List<FournisseurProduit>();
        public virtual ICollection<Commercial> Commerciaux { get; set; } = new List<Commercial>();
    }
}
