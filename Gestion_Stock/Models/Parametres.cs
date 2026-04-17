using System.ComponentModel.DataAnnotations;

namespace Gestion_Stock.Models
{
    public class Parametres
    {
        public int Id { get; set; }
        
        [Required]
        [StringLength(100)]
        public string Cle { get; set; }
        
        [Required]
        [StringLength(500)]
        public string Valeur { get; set; }
        
        [StringLength(200)]
        public string? Description { get; set; }
        
        [StringLength(50)]
        public string Type { get; set; } = "string"; // string, int, bool, decimal
        
        public bool EstModifiable { get; set; } = true;
        
        public DateTime DateModification { get; set; } = DateTime.Now;
        
        public int? ModifiePar { get; set; }
        public virtual Employe? Employe { get; set; }
    }
}