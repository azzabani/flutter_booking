using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gestion_Stock.Models
{
    /// <summary>
    /// Journal des actions effectuées dans le système
    /// </summary>
    public class LogAction
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(100)]
        [Display(Name = "Action")]
        public string Action { get; set; } = string.Empty; // "Création commande", "Modification stock", etc.

        [StringLength(100)]
        [Display(Name = "Entité")]
        public string? Entite { get; set; } // "CommandeAchat", "MouvementStock", etc.

        public int? EntiteId { get; set; }

        [StringLength(1000)]
        [Display(Name = "Détails")]
        public string? Details { get; set; }

        [Required]
        [Display(Name = "Date")]
        public DateTime DateAction { get; set; } = DateTime.Now;

        public int? EmployeId { get; set; }

        [StringLength(200)]
        [Display(Name = "Utilisateur")]
        public string? NomUtilisateur { get; set; }

        // Navigation
        [ForeignKey("EmployeId")]
        public virtual Employe? Employe { get; set; }
    }
}
