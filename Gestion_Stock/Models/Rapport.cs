using System.ComponentModel.DataAnnotations;

namespace Gestion_Stock.Models
{
    public class Rapport
    {
        public int Id { get; set; }
        
        [Required]
        [StringLength(100)]
        public string Nom { get; set; }
        
        [Required]
        [StringLength(50)]
        public string Type { get; set; } // Stock, Ventes, Achats, Mouvements
        
        public DateTime DateDebut { get; set; }
        public DateTime DateFin { get; set; }
        
        [StringLength(500)]
        public string? Description { get; set; }
        
        public DateTime DateCreation { get; set; } = DateTime.Now;
        
        public int? EmployeId { get; set; }
        public virtual Employe? Employe { get; set; }
        
        [StringLength(200)]
        public string? CheminFichier { get; set; }
        
        public bool EstGenere { get; set; } = false;
    }
}