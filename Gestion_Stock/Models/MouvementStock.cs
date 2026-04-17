using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gestion_Stock.Models
{
    /// <summary>
    /// Représente un mouvement de stock (entrée ou sortie)
    /// </summary>
    public class MouvementStock
    {
        /// <summary>
        /// Identifiant unique du mouvement de stock
        /// </summary>
        [Key]
        public int Id { get; set; }

        [Required]
        [Display(Name = "Date du mouvement")]
        [DataType(DataType.DateTime)]
        public DateTime DateMouvement { get; set; } = DateTime.Now;

        [Required]
        [Display(Name = "Quantité")]
        public int Quantite { get; set; }

        /// <summary>
        /// Type de mouvement : Entrée (Achat, Retour fournisseur) ou Sortie (Utilisation, Perte, Don)
        /// </summary>
        [Required]
        [StringLength(50)]
        [Display(Name = "Type")]
        public string TypeMouvement { get; set; } = string.Empty;
        // Entrée : Achat, Retour fournisseur
        // Sortie : Utilisation, Perte, Don

        [StringLength(50)]
        [Display(Name = "Motif")]
        public string? Motif { get; set; }
        // Achat, Retour fournisseur, Utilisation, Perte, Don, Ajustement

        [StringLength(500)]
        [Display(Name = "Raison / Détails")]
        public string? Raison { get; set; }

        [Required]
        public int ProduitId { get; set; }

        public int? CommandeAchatId { get; set; }
        public int? EmployeId { get; set; }

        // Navigation properties
        [ForeignKey("ProduitId")]
        public virtual Produit? Produit { get; set; }

        [ForeignKey("CommandeAchatId")]
        public virtual CommandeAchat? CommandeAchat { get; set; }

        [ForeignKey("EmployeId")]
        public virtual Employe? Employe { get; set; }
    }
}
