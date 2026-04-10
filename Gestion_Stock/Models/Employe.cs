using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Identity;

namespace Gestion_Stock.Models
{
    /// <summary>
    /// Représente un employé du café-restaurant
    /// </summary>
    public class Employe
    {
        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "Le nom complet est requis")]
        [StringLength(200)]
        [Display(Name = "Nom complet")]
        public string NomComplet { get; set; } = string.Empty;

        [Required(ErrorMessage = "L'email est requis")]
        [EmailAddress]
        [StringLength(100)]
        [Display(Name = "Email")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Le rôle est requis")]
        [StringLength(50)]
        [Display(Name = "Rôle")]
        public string Role { get; set; } = "Serveur"; // Admin, ChefCuisine, Serveur

        [StringLength(500)]
        [Display(Name = "Note")]
        public string? Note { get; set; }

        // Lien optionnel vers l'utilisateur Identity
        [StringLength(450)]
        public string? UserId { get; set; }

        // Navigation properties
        public virtual ICollection<CommandeAchat> Commandes { get; set; } = new List<CommandeAchat>();
        public virtual ICollection<LogAction> LogsActions { get; set; } = new List<LogAction>();
    }
}
