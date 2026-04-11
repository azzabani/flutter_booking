using System.ComponentModel.DataAnnotations;

namespace Gestion_Stock.Models
{
    public class Notification
    {
        public int Id { get; set; }
        
        [Required]
        [StringLength(200)]
        public string Titre { get; set; }
        
        [Required]
        [StringLength(1000)]
        public string Message { get; set; }
        
        public bool EstLue { get; set; } = false;
        
        public DateTime DateCreation { get; set; } = DateTime.Now;
        
        [StringLength(50)]
        public string Type { get; set; } // Info, Warning, Error, Success
        
        public int? EmployeId { get; set; }
        public virtual Employe? Employe { get; set; }
    }
}