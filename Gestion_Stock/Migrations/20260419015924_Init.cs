using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Gestion_Stock.Migrations
{
    /// <inheritdoc />
    public partial class Init : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Categories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Nom = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Categories", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Commerciaux",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Nom = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Region = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    Commission = table.Column<decimal>(type: "decimal(5,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Commerciaux", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Employes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    NomComplet = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Note = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Employes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Fournisseurs",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Nom = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Telephone = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    Adresse = table.Column<string>(type: "nvarchar(300)", maxLength: 300, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Fournisseurs", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Produits",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Nom = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Reference = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    PrixUnitaire = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    StockActuel = table.Column<int>(type: "int", nullable: false),
                    SeuilMin = table.Column<int>(type: "int", nullable: false),
                    SeuilMax = table.Column<int>(type: "int", nullable: false),
                    CategorieId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Produits", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Produits_Categories_CategorieId",
                        column: x => x.CategorieId,
                        principalTable: "Categories",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Livraisons",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DateLivraison = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Statut = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    NoteAvis = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    Note = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CommercialId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Livraisons", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Livraisons_Commerciaux_CommercialId",
                        column: x => x.CommercialId,
                        principalTable: "Commerciaux",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "Alertes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TypeAlerte = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Message = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    DateCreation = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EstLue = table.Column<bool>(type: "bit", nullable: false),
                    ProduitId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Alertes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Alertes_Produits_ProduitId",
                        column: x => x.ProduitId,
                        principalTable: "Produits",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "FournisseurProduits",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FournisseurId = table.Column<int>(type: "int", nullable: false),
                    ProduitId = table.Column<int>(type: "int", nullable: false),
                    PrixAchat = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    DelaiLivraisonJours = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FournisseurProduits", x => x.Id);
                    table.ForeignKey(
                        name: "FK_FournisseurProduits_Fournisseurs_FournisseurId",
                        column: x => x.FournisseurId,
                        principalTable: "Fournisseurs",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_FournisseurProduits_Produits_ProduitId",
                        column: x => x.ProduitId,
                        principalTable: "Produits",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "CommandesAchat",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DateCommande = table.Column<DateTime>(type: "datetime2", nullable: false),
                    SousTotal = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    FraisLivraison = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    TotalFacture = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Statut = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    EmployeId = table.Column<int>(type: "int", nullable: true),
                    LivraisonId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CommandesAchat", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CommandesAchat_Employes_EmployeId",
                        column: x => x.EmployeId,
                        principalTable: "Employes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_CommandesAchat_Livraisons_LivraisonId",
                        column: x => x.LivraisonId,
                        principalTable: "Livraisons",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "LignesCommande",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CommandeAchatId = table.Column<int>(type: "int", nullable: false),
                    ProduitId = table.Column<int>(type: "int", nullable: false),
                    Quantite = table.Column<int>(type: "int", nullable: false),
                    PrixUnitaire = table.Column<decimal>(type: "decimal(18,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LignesCommande", x => x.Id);
                    table.ForeignKey(
                        name: "FK_LignesCommande_CommandesAchat_CommandeAchatId",
                        column: x => x.CommandeAchatId,
                        principalTable: "CommandesAchat",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_LignesCommande_Produits_ProduitId",
                        column: x => x.ProduitId,
                        principalTable: "Produits",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "MouvementsStock",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DateMouvement = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Quantite = table.Column<int>(type: "int", nullable: false),
                    TypeMouvement = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Raison = table.Column<string>(type: "nvarchar(300)", maxLength: 300, nullable: true),
                    ProduitId = table.Column<int>(type: "int", nullable: false),
                    CommandeAchatId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MouvementsStock", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MouvementsStock_CommandesAchat_CommandeAchatId",
                        column: x => x.CommandeAchatId,
                        principalTable: "CommandesAchat",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_MouvementsStock_Produits_ProduitId",
                        column: x => x.ProduitId,
                        principalTable: "Produits",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "Categories",
                columns: new[] { "Id", "Description", "Nom" },
                values: new object[,]
                {
                    { 1, "Produits électroniques", "Électronique" },
                    { 2, "Produits alimentaires", "Alimentaire" },
                    { 3, "Articles vestimentaires", "Vêtements" }
                });

            migrationBuilder.InsertData(
                table: "Commerciaux",
                columns: new[] { "Id", "Commission", "Nom", "Region" },
                values: new object[,]
                {
                    { 1, 5.5m, "Pierre Durand", "Nord" },
                    { 2, 6.0m, "Sophie Bernard", "Sud" }
                });

            migrationBuilder.InsertData(
                table: "Employes",
                columns: new[] { "Id", "Email", "NomComplet", "Note" },
                values: new object[,]
                {
                    { 1, "jean.dupont@gestionstock.com", "Jean Dupont", "Responsable des achats" },
                    { 2, "marie.martin@gestionstock.com", "Marie Martin", "Gestionnaire de stock" }
                });

            migrationBuilder.InsertData(
                table: "Fournisseurs",
                columns: new[] { "Id", "Adresse", "Email", "Nom", "Telephone" },
                values: new object[,]
                {
                    { 1, "123 Rue Tech", "contact@techsupply.com", "TechSupply", "0123456789" },
                    { 2, "456 Avenue Food", "info@fooddistrib.com", "FoodDistrib", "0987654321" }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Alertes_DateCreation",
                table: "Alertes",
                column: "DateCreation");

            migrationBuilder.CreateIndex(
                name: "IX_Alertes_ProduitId",
                table: "Alertes",
                column: "ProduitId");

            migrationBuilder.CreateIndex(
                name: "IX_CommandesAchat_DateCommande",
                table: "CommandesAchat",
                column: "DateCommande");

            migrationBuilder.CreateIndex(
                name: "IX_CommandesAchat_EmployeId",
                table: "CommandesAchat",
                column: "EmployeId");

            migrationBuilder.CreateIndex(
                name: "IX_CommandesAchat_LivraisonId",
                table: "CommandesAchat",
                column: "LivraisonId");

            migrationBuilder.CreateIndex(
                name: "IX_FournisseurProduits_FournisseurId",
                table: "FournisseurProduits",
                column: "FournisseurId");

            migrationBuilder.CreateIndex(
                name: "IX_FournisseurProduits_ProduitId",
                table: "FournisseurProduits",
                column: "ProduitId");

            migrationBuilder.CreateIndex(
                name: "IX_LignesCommande_CommandeAchatId",
                table: "LignesCommande",
                column: "CommandeAchatId");

            migrationBuilder.CreateIndex(
                name: "IX_LignesCommande_ProduitId",
                table: "LignesCommande",
                column: "ProduitId");

            migrationBuilder.CreateIndex(
                name: "IX_Livraisons_CommercialId",
                table: "Livraisons",
                column: "CommercialId");

            migrationBuilder.CreateIndex(
                name: "IX_MouvementsStock_CommandeAchatId",
                table: "MouvementsStock",
                column: "CommandeAchatId");

            migrationBuilder.CreateIndex(
                name: "IX_MouvementsStock_DateMouvement",
                table: "MouvementsStock",
                column: "DateMouvement");

            migrationBuilder.CreateIndex(
                name: "IX_MouvementsStock_ProduitId",
                table: "MouvementsStock",
                column: "ProduitId");

            migrationBuilder.CreateIndex(
                name: "IX_Produits_CategorieId",
                table: "Produits",
                column: "CategorieId");

            migrationBuilder.CreateIndex(
                name: "IX_Produits_Reference",
                table: "Produits",
                column: "Reference");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Alertes");

            migrationBuilder.DropTable(
                name: "FournisseurProduits");

            migrationBuilder.DropTable(
                name: "LignesCommande");

            migrationBuilder.DropTable(
                name: "MouvementsStock");

            migrationBuilder.DropTable(
                name: "Fournisseurs");

            migrationBuilder.DropTable(
                name: "CommandesAchat");

            migrationBuilder.DropTable(
                name: "Produits");

            migrationBuilder.DropTable(
                name: "Employes");

            migrationBuilder.DropTable(
                name: "Livraisons");

            migrationBuilder.DropTable(
                name: "Categories");

            migrationBuilder.DropTable(
                name: "Commerciaux");
        }
    }
}
