using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Gestion_Stock.Models;

namespace Gestion_Stock.Data
{
    /// <summary>
    /// Contexte de base de données — café-restaurant, avec Identity
    /// </summary>
    public class ApplicationDbContext : IdentityDbContext<IdentityUser>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options) { }

        // Entités métier
        public DbSet<Produit> Produits { get; set; }
        public DbSet<Categorie> Categories { get; set; }
        public DbSet<Fournisseur> Fournisseurs { get; set; }
        public DbSet<FournisseurProduit> FournisseurProduits { get; set; }
        public DbSet<Employe> Employes { get; set; }
        public DbSet<Commercial> Commerciaux { get; set; }
        public DbSet<Livraison> Livraisons { get; set; }
        public DbSet<CommandeAchat> CommandesAchat { get; set; }
        public DbSet<LigneCommande> LignesCommande { get; set; }
        public DbSet<MouvementStock> MouvementsStock { get; set; }
        public DbSet<Alerte> Alertes { get; set; }
        public DbSet<LogAction> LogsActions { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Produit → Categorie
            modelBuilder.Entity<Produit>()
                .HasOne(p => p.Categorie)
                .WithMany(c => c.Produits)
                .HasForeignKey(p => p.CategorieId)
                .OnDelete(DeleteBehavior.Restrict);

            // FournisseurProduit → Fournisseur
            modelBuilder.Entity<FournisseurProduit>()
                .HasOne(fp => fp.Fournisseur)
                .WithMany(f => f.FournisseurProduits)
                .HasForeignKey(fp => fp.FournisseurId)
                .OnDelete(DeleteBehavior.Cascade);

            // FournisseurProduit → Produit
            modelBuilder.Entity<FournisseurProduit>()
                .HasOne(fp => fp.Produit)
                .WithMany(p => p.FournisseurProduits)
                .HasForeignKey(fp => fp.ProduitId)
                .OnDelete(DeleteBehavior.Cascade);

            // Alerte → Produit
            modelBuilder.Entity<Alerte>()
                .HasOne(a => a.Produit)
                .WithMany(p => p.Alertes)
                .HasForeignKey(a => a.ProduitId)
                .OnDelete(DeleteBehavior.Cascade);

            // MouvementStock → Produit
            modelBuilder.Entity<MouvementStock>()
                .HasOne(m => m.Produit)
                .WithMany(p => p.MouvementsStock)
                .HasForeignKey(m => m.ProduitId)
                .OnDelete(DeleteBehavior.Cascade);

            // MouvementStock → CommandeAchat (optionnel)
            modelBuilder.Entity<MouvementStock>()
                .HasOne(m => m.CommandeAchat)
                .WithMany()
                .HasForeignKey(m => m.CommandeAchatId)
                .OnDelete(DeleteBehavior.SetNull);

            // MouvementStock → Employe (optionnel)
            modelBuilder.Entity<MouvementStock>()
                .HasOne(m => m.Employe)
                .WithMany()
                .HasForeignKey(m => m.EmployeId)
                .OnDelete(DeleteBehavior.SetNull);

            // CommandeAchat → Employe
            modelBuilder.Entity<CommandeAchat>()
                .HasOne(c => c.Employe)
                .WithMany(e => e.Commandes)
                .HasForeignKey(c => c.EmployeId)
                .OnDelete(DeleteBehavior.SetNull);

            // CommandeAchat → Livraison
            modelBuilder.Entity<CommandeAchat>()
                .HasOne(c => c.Livraison)
                .WithMany(l => l.Commandes)
                .HasForeignKey(c => c.LivraisonId)
                .OnDelete(DeleteBehavior.SetNull);

            // CommandeAchat → Fournisseur
            modelBuilder.Entity<CommandeAchat>()
                .HasOne(c => c.Fournisseur)
                .WithMany()
                .HasForeignKey(c => c.FournisseurId)
                .OnDelete(DeleteBehavior.SetNull);

            // LigneCommande → CommandeAchat
            modelBuilder.Entity<LigneCommande>()
                .HasOne(lc => lc.CommandeAchat)
                .WithMany(c => c.LignesCommande)
                .HasForeignKey(lc => lc.CommandeAchatId)
                .OnDelete(DeleteBehavior.Cascade);

            // LigneCommande → Produit
            modelBuilder.Entity<LigneCommande>()
                .HasOne(lc => lc.Produit)
                .WithMany(p => p.LignesCommande)
                .HasForeignKey(lc => lc.ProduitId)
                .OnDelete(DeleteBehavior.Restrict);

            // Livraison → Commercial
            modelBuilder.Entity<Livraison>()
                .HasOne(l => l.Commercial)
                .WithMany(c => c.Livraisons)
                .HasForeignKey(l => l.CommercialId)
                .OnDelete(DeleteBehavior.SetNull);

            // Commercial → Fournisseur (optionnel)
            modelBuilder.Entity<Commercial>()
                .HasOne(c => c.Fournisseur)
                .WithMany(f => f.Commerciaux)
                .HasForeignKey(c => c.FournisseurId)
                .OnDelete(DeleteBehavior.SetNull);

            // LogAction → Employe
            modelBuilder.Entity<LogAction>()
                .HasOne(l => l.Employe)
                .WithMany(e => e.LogsActions)
                .HasForeignKey(l => l.EmployeId)
                .OnDelete(DeleteBehavior.SetNull);

            // Index
            modelBuilder.Entity<Produit>().HasIndex(p => p.Reference);
            modelBuilder.Entity<Alerte>().HasIndex(a => a.DateCreation);
            modelBuilder.Entity<CommandeAchat>().HasIndex(c => c.DateCommande);
            modelBuilder.Entity<MouvementStock>().HasIndex(m => m.DateMouvement);
            modelBuilder.Entity<LogAction>().HasIndex(l => l.DateAction);

            SeedData(modelBuilder);
        }

        private void SeedData(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Categorie>().HasData(
                new Categorie { Id = 1, Nom = "Boissons chaudes", Description = "Café, thé, chocolat, infusions" },
                new Categorie { Id = 2, Nom = "Produits laitiers", Description = "Lait, crème, beurre, fromages" },
                new Categorie { Id = 3, Nom = "Farines & Céréales", Description = "Farine, sucre, sel, riz, pâtes" },
                new Categorie { Id = 4, Nom = "Viandes & Charcuterie", Description = "Poulet, bœuf, jambon, merguez" },
                new Categorie { Id = 5, Nom = "Fruits & Légumes", Description = "Légumes frais, fruits de saison" },
                new Categorie { Id = 6, Nom = "Huiles & Condiments", Description = "Huile d'olive, vinaigre, épices, sauces" },
                new Categorie { Id = 7, Nom = "Boissons froides", Description = "Jus, sodas, eau minérale, sirops" },
                new Categorie { Id = 8, Nom = "Pâtisserie & Desserts", Description = "Œufs, levure, chocolat, vanille" }
            );

            modelBuilder.Entity<Fournisseur>().HasData(
                new Fournisseur { Id = 1, Nom = "Café Premium Tunisie", Email = "commandes@cafepremium.tn", Telephone = "71 234 567", Adresse = "Zone Industrielle, Tunis" },
                new Fournisseur { Id = 2, Nom = "Laiterie du Nord", Email = "ventes@laiterie-nord.tn", Telephone = "72 345 678", Adresse = "Route de Bizerte, Mateur" },
                new Fournisseur { Id = 3, Nom = "Grossiste Alimentaire Ben Ali", Email = "contact@grossiste-benali.tn", Telephone = "73 456 789", Adresse = "Marché de Gros, Sfax" },
                new Fournisseur { Id = 4, Nom = "Boucherie Centrale", Email = "info@boucherie-centrale.tn", Telephone = "74 567 890", Adresse = "Rue du Marché, Sousse" }
            );

            modelBuilder.Entity<Employe>().HasData(
                new Employe { Id = 1, NomComplet = "Ahmed Ben Salah", Email = "ahmed.bensalah@cafe-resto.tn", Role = "Admin", Note = "Responsable des achats et approvisionnement" },
                new Employe { Id = 2, NomComplet = "Fatma Trabelsi", Email = "fatma.trabelsi@cafe-resto.tn", Role = "Admin", Note = "Gestionnaire de stock et inventaire" },
                new Employe { Id = 3, NomComplet = "Mohamed Chaabane", Email = "m.chaabane@cafe-resto.tn", Role = "ChefCuisine", Note = "Chef de cuisine - contrôle qualité" },
                new Employe { Id = 4, NomComplet = "Sarra Mejri", Email = "s.mejri@cafe-resto.tn", Role = "Serveur", Note = "Serveuse" }
            );

            modelBuilder.Entity<Commercial>().HasData(
                new Commercial { Id = 1, Nom = "Karim Mansouri", Region = "Grand Tunis", Commission = 3.5m, FournisseurId = 1 },
                new Commercial { Id = 2, Nom = "Sonia Gharbi", Region = "Sahel", Commission = 4.0m, FournisseurId = 2 }
            );
        }
    }
}
