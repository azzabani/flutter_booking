using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gestion_Stock.Models
{
    /// <summary>
    /// Représente une livraison de matières premières
    /// </summary>
    public class Livraison
    {
        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "La date de livraison est requise")]
        [Display(Name = "Date de livraison")]
        [DataType(DataType.Date)]
        public DateTime DateLivraison { get; set; }

        [Required(ErrorMessage = "Le statut est requis")]
        [StringLength(50)]
        [Display(Name = "Statut")]
        public string Statut { get; set; } = "En attente";
        // En attente, Partielle, Complète, Retour

        [Display(Name = "Note (1-5)")]
        [Range(1, 5)]
        public int? NoteChiffre { get; set; }

        [StringLength(500)]
        [Display(Name = "Avis / Commentaire")]
        public string? NoteAvis { get; set; }

        [StringLength(500)]
        [Display(Name = "Note interne")]
        public string? Note { get; set; }

        [Display(Name = "Livraison partielle ?")]
        public bool EstPartielle { get; set; } = false;

        public int? CommercialId { get; set; }

        // Navigation properties
        [ForeignKey("CommercialId")]
        public virtual Commercial? Commercial { get; set; }

        public virtual ICollection<CommandeAchat> Commandes { get; set; } = new List<CommandeAchat>();
    }
}
