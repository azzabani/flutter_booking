using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Gestion_Stock.Migrations
{
    /// <inheritdoc />
    public partial class FullModules : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "Raison",
                table: "MouvementsStock",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(300)",
                oldMaxLength: 300,
                oldNullable: true);

            migrationBuilder.AddColumn<int>(
                name: "EmployeId",
                table: "MouvementsStock",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Motif",
                table: "MouvementsStock",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "EstPartielle",
                table: "Livraisons",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "NoteChiffre",
                table: "Livraisons",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "QuantiteRecue",
                table: "LignesCommande",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<bool>(
                name: "EstPrefere",
                table: "FournisseurProduits",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "ReferenceFournisseur",
                table: "FournisseurProduits",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Role",
                table: "Employes",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "UserId",
                table: "Employes",
                type: "nvarchar(450)",
                maxLength: 450,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Email",
                table: "Commerciaux",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "FournisseurId",
                table: "Commerciaux",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Telephone",
                table: "Commerciaux",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "FournisseurId",
                table: "CommandesAchat",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "MontantTVA",
                table: "CommandesAchat",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<string>(
                name: "Notes",
                table: "CommandesAchat",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "TauxTVA",
                table: "CommandesAchat",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "TotalTTC",
                table: "CommandesAchat",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.CreateTable(
                name: "AspNetRoles",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    NormalizedName = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    ConcurrencyStamp = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetRoles", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUsers",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    UserName = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    NormalizedUserName = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    Email = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    NormalizedEmail = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    EmailConfirmed = table.Column<bool>(type: "bit", nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SecurityStamp = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ConcurrencyStamp = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PhoneNumber = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PhoneNumberConfirmed = table.Column<bool>(type: "bit", nullable: false),
                    TwoFactorEnabled = table.Column<bool>(type: "bit", nullable: false),
                    LockoutEnd = table.Column<DateTimeOffset>(type: "datetimeoffset", nullable: true),
                    LockoutEnabled = table.Column<bool>(type: "bit", nullable: false),
                    AccessFailedCount = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUsers", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "LogsActions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Action = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Entite = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    EntiteId = table.Column<int>(type: "int", nullable: true),
                    Details = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    DateAction = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EmployeId = table.Column<int>(type: "int", nullable: true),
                    NomUtilisateur = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LogsActions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_LogsActions_Employes_EmployeId",
                        column: x => x.EmployeId,
                        principalTable: "Employes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "AspNetRoleClaims",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RoleId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    ClaimType = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ClaimValue = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetRoleClaims", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AspNetRoleClaims_AspNetRoles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "AspNetRoles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserClaims",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    ClaimType = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ClaimValue = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserClaims", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AspNetUserClaims_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserLogins",
                columns: table => new
                {
                    LoginProvider = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    ProviderKey = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    ProviderDisplayName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserLogins", x => new { x.LoginProvider, x.ProviderKey });
                    table.ForeignKey(
                        name: "FK_AspNetUserLogins_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserRoles",
                columns: table => new
                {
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    RoleId = table.Column<string>(type: "nvarchar(450)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserRoles", x => new { x.UserId, x.RoleId });
                    table.ForeignKey(
                        name: "FK_AspNetUserRoles_AspNetRoles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "AspNetRoles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_AspNetUserRoles_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserTokens",
                columns: table => new
                {
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    LoginProvider = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Value = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserTokens", x => new { x.UserId, x.LoginProvider, x.Name });
                    table.ForeignKey(
                        name: "FK_AspNetUserTokens_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.UpdateData(
                table: "Commerciaux",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Email", "FournisseurId", "Telephone" },
                values: new object[] { null, 1, null });

            migrationBuilder.UpdateData(
                table: "Commerciaux",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Email", "FournisseurId", "Telephone" },
                values: new object[] { null, 2, null });

            migrationBuilder.UpdateData(
                table: "Employes",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Role", "UserId" },
                values: new object[] { "Admin", null });

            migrationBuilder.UpdateData(
                table: "Employes",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Role", "UserId" },
                values: new object[] { "Admin", null });

            migrationBuilder.UpdateData(
                table: "Employes",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "Role", "UserId" },
                values: new object[] { "ChefCuisine", null });

            migrationBuilder.InsertData(
                table: "Employes",
                columns: new[] { "Id", "Email", "NomComplet", "Note", "Role", "UserId" },
                values: new object[] { 4, "s.mejri@cafe-resto.tn", "Sarra Mejri", "Serveuse", "Serveur", null });

            migrationBuilder.CreateIndex(
                name: "IX_MouvementsStock_EmployeId",
                table: "MouvementsStock",
                column: "EmployeId");

            migrationBuilder.CreateIndex(
                name: "IX_Commerciaux_FournisseurId",
                table: "Commerciaux",
                column: "FournisseurId");

            migrationBuilder.CreateIndex(
                name: "IX_CommandesAchat_FournisseurId",
                table: "CommandesAchat",
                column: "FournisseurId");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetRoleClaims_RoleId",
                table: "AspNetRoleClaims",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "RoleNameIndex",
                table: "AspNetRoles",
                column: "NormalizedName",
                unique: true,
                filter: "[NormalizedName] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUserClaims_UserId",
                table: "AspNetUserClaims",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUserLogins_UserId",
                table: "AspNetUserLogins",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUserRoles_RoleId",
                table: "AspNetUserRoles",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "EmailIndex",
                table: "AspNetUsers",
                column: "NormalizedEmail");

            migrationBuilder.CreateIndex(
                name: "UserNameIndex",
                table: "AspNetUsers",
                column: "NormalizedUserName",
                unique: true,
                filter: "[NormalizedUserName] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_LogsActions_DateAction",
                table: "LogsActions",
                column: "DateAction");

            migrationBuilder.CreateIndex(
                name: "IX_LogsActions_EmployeId",
                table: "LogsActions",
                column: "EmployeId");

            migrationBuilder.AddForeignKey(
                name: "FK_CommandesAchat_Fournisseurs_FournisseurId",
                table: "CommandesAchat",
                column: "FournisseurId",
                principalTable: "Fournisseurs",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_Commerciaux_Fournisseurs_FournisseurId",
                table: "Commerciaux",
                column: "FournisseurId",
                principalTable: "Fournisseurs",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_MouvementsStock_Employes_EmployeId",
                table: "MouvementsStock",
                column: "EmployeId",
                principalTable: "Employes",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_CommandesAchat_Fournisseurs_FournisseurId",
                table: "CommandesAchat");

            migrationBuilder.DropForeignKey(
                name: "FK_Commerciaux_Fournisseurs_FournisseurId",
                table: "Commerciaux");

            migrationBuilder.DropForeignKey(
                name: "FK_MouvementsStock_Employes_EmployeId",
                table: "MouvementsStock");

            migrationBuilder.DropTable(
                name: "AspNetRoleClaims");

            migrationBuilder.DropTable(
                name: "AspNetUserClaims");

            migrationBuilder.DropTable(
                name: "AspNetUserLogins");

            migrationBuilder.DropTable(
                name: "AspNetUserRoles");

            migrationBuilder.DropTable(
                name: "AspNetUserTokens");

            migrationBuilder.DropTable(
                name: "LogsActions");

            migrationBuilder.DropTable(
                name: "AspNetRoles");

            migrationBuilder.DropTable(
                name: "AspNetUsers");

            migrationBuilder.DropIndex(
                name: "IX_MouvementsStock_EmployeId",
                table: "MouvementsStock");

            migrationBuilder.DropIndex(
                name: "IX_Commerciaux_FournisseurId",
                table: "Commerciaux");

            migrationBuilder.DropIndex(
                name: "IX_CommandesAchat_FournisseurId",
                table: "CommandesAchat");

            migrationBuilder.DeleteData(
                table: "Employes",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DropColumn(
                name: "EmployeId",
                table: "MouvementsStock");

            migrationBuilder.DropColumn(
                name: "Motif",
                table: "MouvementsStock");

            migrationBuilder.DropColumn(
                name: "EstPartielle",
                table: "Livraisons");

            migrationBuilder.DropColumn(
                name: "NoteChiffre",
                table: "Livraisons");

            migrationBuilder.DropColumn(
                name: "QuantiteRecue",
                table: "LignesCommande");

            migrationBuilder.DropColumn(
                name: "EstPrefere",
                table: "FournisseurProduits");

            migrationBuilder.DropColumn(
                name: "ReferenceFournisseur",
                table: "FournisseurProduits");

            migrationBuilder.DropColumn(
                name: "Role",
                table: "Employes");

            migrationBuilder.DropColumn(
                name: "UserId",
                table: "Employes");

            migrationBuilder.DropColumn(
                name: "Email",
                table: "Commerciaux");

            migrationBuilder.DropColumn(
                name: "FournisseurId",
                table: "Commerciaux");

            migrationBuilder.DropColumn(
                name: "Telephone",
                table: "Commerciaux");

            migrationBuilder.DropColumn(
                name: "FournisseurId",
                table: "CommandesAchat");

            migrationBuilder.DropColumn(
                name: "MontantTVA",
                table: "CommandesAchat");

            migrationBuilder.DropColumn(
                name: "Notes",
                table: "CommandesAchat");

            migrationBuilder.DropColumn(
                name: "TauxTVA",
                table: "CommandesAchat");

            migrationBuilder.DropColumn(
                name: "TotalTTC",
                table: "CommandesAchat");

            migrationBuilder.AlterColumn<string>(
                name: "Raison",
                table: "MouvementsStock",
                type: "nvarchar(300)",
                maxLength: 300,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(500)",
                oldMaxLength: 500,
                oldNullable: true);
        }
    }
}
