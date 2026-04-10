using System.ComponentModel.DataAnnotations;

namespace Gestion_Stock.Models
{
    public class Unite
    {
        public int Id { get; set; }
        
        [Required]
        [StringLength(50)]
        public string Nom { get; set; }
        
        [StringLength(10)]
        public string Symbole { get; set; }
        
        public DateTime DateCreation { get; set; } = DateTime.Now;
        
        // Navigation property
        public virtual ICollection<Produit> Produits { get; set; } = new List<Produit>();
    }
}