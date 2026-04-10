using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Gestion_Stock.Migrations
{
    /// <inheritdoc />
    public partial class AddUniteAndCafeData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Unite",
                table: "Produits",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Description", "Nom" },
                values: new object[] { "Café, thé, chocolat, infusions", "Boissons chaudes" });

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Description", "Nom" },
                values: new object[] { "Lait, crème, beurre, fromages", "Produits laitiers" });

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "Description", "Nom" },
                values: new object[] { "Farine, sucre, sel, riz, pâtes", "Farines & Céréales" });

            migrationBuilder.InsertData(
                table: "Categories",
                columns: new[] { "Id", "Description", "Nom" },
                values: new object[,]
                {
                    { 4, "Poulet, bœuf, jambon, merguez", "Viandes & Charcuterie" },
                    { 5, "Légumes frais, fruits de saison", "Fruits & Légumes" },
                    { 6, "Huile d'olive, vinaigre, épices, sauces", "Huiles & Condiments" },
                    { 7, "Jus, sodas, eau minérale, sirops", "Boissons froides" },
                    { 8, "Œufs, levure, chocolat, vanille", "Pâtisserie & Desserts" }
                });

            migrationBuilder.UpdateData(
                table: "Commerciaux",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Commission", "Nom", "Region" },
                values: new object[] { 3.5m, "Karim Mansouri", "Grand Tunis" });

            migrationBuilder.UpdateData(
                table: "Commerciaux",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Commission", "Nom", "Region" },
                values: new object[] { 4.0m, "Sonia Gharbi", "Sahel" });

            migrationBuilder.UpdateData(
                table: "Employes",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Email", "NomComplet", "Note" },
                values: new object[] { "ahmed.bensalah@cafe-resto.tn", "Ahmed Ben Salah", "Responsable des achats et approvisionnement" });

            migrationBuilder.UpdateData(
                table: "Employes",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Email", "NomComplet", "Note" },
                values: new object[] { "fatma.trabelsi@cafe-resto.tn", "Fatma Trabelsi", "Gestionnaire de stock et inventaire" });

            migrationBuilder.InsertData(
                table: "Employes",
                columns: new[] { "Id", "Email", "NomComplet", "Note" },
                values: new object[] { 3, "m.chaabane@cafe-resto.tn", "Mohamed Chaabane", "Chef de cuisine - contrôle qualité" });

            migrationBuilder.UpdateData(
                table: "Fournisseurs",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Adresse", "Email", "Nom", "Telephone" },
                values: new object[] { "Zone Industrielle, Tunis", "commandes@cafepremium.tn", "Café Premium Tunisie", "71 234 567" });

            migrationBuilder.UpdateData(
                table: "Fournisseurs",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Adresse", "Email", "Nom", "Telephone" },
                values: new object[] { "Route de Bizerte, Mateur", "ventes@laiterie-nord.tn", "Laiterie du Nord", "72 345 678" });

            migrationBuilder.InsertData(
                table: "Fournisseurs",
                columns: new[] { "Id", "Adresse", "Email", "Nom", "Telephone" },
                values: new object[,]
                {
                    { 3, "Marché de Gros, Sfax", "contact@grossiste-benali.tn", "Grossiste Alimentaire Ben Ali", "73 456 789" },
                    { 4, "Rue du Marché, Sousse", "info@boucherie-centrale.tn", "Boucherie Centrale", "74 567 890" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Employes",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Fournisseurs",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Fournisseurs",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DropColumn(
                name: "Unite",
                table: "Produits");

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Description", "Nom" },
                values: new object[] { "Produits électroniques", "Électronique" });

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Description", "Nom" },
                values: new object[] { "Produits alimentaires", "Alimentaire" });

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "Description", "Nom" },
                values: new object[] { "Articles vestimentaires", "Vêtements" });

            migrationBuilder.UpdateData(
                table: "Commerciaux",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Commission", "Nom", "Region" },
                values: new object[] { 5.5m, "Pierre Durand", "Nord" });

            migrationBuilder.UpdateData(
                table: "Commerciaux",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Commission", "Nom", "Region" },
                values: new object[] { 6.0m, "Sophie Bernard", "Sud" });

            migrationBuilder.UpdateData(
                table: "Employes",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Email", "NomComplet", "Note" },
                values: new object[] { "jean.dupont@gestionstock.com", "Jean Dupont", "Responsable des achats" });

            migrationBuilder.UpdateData(
                table: "Employes",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Email", "NomComplet", "Note" },
                values: new object[] { "marie.martin@gestionstock.com", "Marie Martin", "Gestionnaire de stock" });

            migrationBuilder.UpdateData(
                table: "Fournisseurs",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Adresse", "Email", "Nom", "Telephone" },
                values: new object[] { "123 Rue Tech", "contact@techsupply.com", "TechSupply", "0123456789" });

            migrationBuilder.UpdateData(
                table: "Fournisseurs",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Adresse", "Email", "Nom", "Telephone" },
                values: new object[] { "456 Avenue Food", "info@fooddistrib.com", "FoodDistrib", "0987654321" });
        }
    }
}
