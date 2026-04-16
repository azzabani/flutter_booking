using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gestion_Stock.Models
{
    /// <summary>
    /// Représente une commande d'achat de matières premières
    /// </summary>
    public class CommandeAchat
    {
        /// <summary>
        /// Identifiant unique de la commande d'achat
        /// </summary>
        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "La date de commande est requise")]
        [Display(Name = "Date de commande")]
        [DataType(DataType.Date)]
        public DateTime DateCommande { get; set; } = DateTime.Now;

        [Column(TypeName = "decimal(18,2)")]
        [Display(Name = "Sous-total HT")]
        public decimal SousTotal { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        [Display(Name = "TVA (%)")]
        [Range(0, 100)]
        public decimal TauxTVA { get; set; } = 19; // TVA Tunisie 19%

        [Column(TypeName = "decimal(18,2)")]
        [Display(Name = "Montant TVA")]
        public decimal MontantTVA { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        [Display(Name = "Total TTC")]
        public decimal TotalTTC { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        [Display(Name = "Frais de livraison")]
        public decimal FraisLivraison { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        [Display(Name = "Total facture")]
        public decimal TotalFacture { get; set; }

        /// <summary>
        /// Statut actuel de la commande (En attente, Confirmée, Partielle, Livrée, Retour, Annulée)
        /// </summary>
        [Required(ErrorMessage = "Le statut est requis")]
        [StringLength(50)]
        [Display(Name = "Statut")]
        public string Statut { get; set; } = "En attente";
        // Statuts : En attente → Confirmée → Partielle → Livrée / Retour / Annulée

        [StringLength(500)]
        [Display(Name = "Notes")]
        public string? Notes { get; set; }

        public int? EmployeId { get; set; }
        public int? LivraisonId { get; set; }
        public int? FournisseurId { get; set; }

        // Navigation properties
        [ForeignKey("EmployeId")]
        public virtual Employe? Employe { get; set; }

        [ForeignKey("LivraisonId")]
        public virtual Livraison? Livraison { get; set; }

        [ForeignKey("FournisseurId")]
        public virtual Fournisseur? Fournisseur { get; set; }

        public virtual ICollection<LigneCommande> LignesCommande { get; set; } = new List<LigneCommande>();
    }
}
