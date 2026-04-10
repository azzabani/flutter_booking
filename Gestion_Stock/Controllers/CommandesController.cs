using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Gestion_Stock.Data;
using Gestion_Stock.Models;
using Gestion_Stock.Services;

namespace Gestion_Stock.Controllers
{
    [Authorize]
    public class CommandesController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IAlertService _alertService;
        private readonly IMouvementService _mouvementService;
        private readonly ILogService _logService;

        public CommandesController(ApplicationDbContext context, IAlertService alertService,
            IMouvementService mouvementService, ILogService logService)
        {
            _context = context;
            _alertService = alertService;
            _mouvementService = mouvementService;
            _logService = logService;
        }

        public async Task<IActionResult> Index(string? statut, int? fournisseurId, DateTime? dateDebut, DateTime? dateFin)
        {
            var query = _context.CommandesAchat
                .Include(c => c.Employe)
                .Include(c => c.Fournisseur)
                .Include(c => c.LignesCommande)
                .AsQueryable();

            if (!string.IsNullOrEmpty(statut)) query = query.Where(c => c.Statut == statut);
            if (fournisseurId.HasValue) query = query.Where(c => c.FournisseurId == fournisseurId);
            if (dateDebut.HasValue) query = query.Where(c => c.DateCommande >= dateDebut);
            if (dateFin.HasValue) query = query.Where(c => c.DateCommande <= dateFin.Value.AddDays(1));

            ViewBag.Fournisseurs = new SelectList(await _context.Fournisseurs.OrderBy(f => f.Nom).ToListAsync(), "Id", "Nom", fournisseurId);
            ViewBag.FiltreStatut = statut;
            ViewBag.FiltreFournisseurId = fournisseurId;
            ViewBag.FiltreDateDebut = dateDebut?.ToString("yyyy-MM-dd");
            ViewBag.FiltreDateFin = dateFin?.ToString("yyyy-MM-dd");

            return View(await query.OrderByDescending(c => c.DateCommande).ToListAsync());
        }

        public async Task<IActionResult> Details(int? id)
        {
            if (id == null) return NotFound();
            var commande = await _context.CommandesAchat
                .Include(c => c.Employe).Include(c => c.Fournisseur)
                .Include(c => c.Livraison).ThenInclude(l => l!.Commercial)
                .Include(c => c.LignesCommande).ThenInclude(lc => lc.Produit)
                .FirstOrDefaultAsync(m => m.Id == id);
            if (commande == null) return NotFound();
            return View(commande);
        }

        [Authorize(Roles = "Admin,ChefCuisine")]
        public IActionResult Create()
        {
            ViewBag.EmployeId = new SelectList(_context.Employes, "Id", "NomComplet");
            ViewBag.FournisseurId = new SelectList(_context.Fournisseurs.OrderBy(f => f.Nom), "Id", "Nom");
            ViewBag.LivraisonId = new SelectList(_context.Livraisons, "Id", "Statut");
            return View();
        }

        [HttpPost, ValidateAntiForgeryToken, Authorize(Roles = "Admin,ChefCuisine")]
        public async Task<IActionResult> Create([Bind("DateCommande,FraisLivraison,TauxTVA,Statut,Notes,EmployeId,LivraisonId,FournisseurId")] CommandeAchat commande)
        {
            if (ModelState.IsValid)
            {
                commande.SousTotal = 0; commande.MontantTVA = 0; commande.TotalTTC = 0;
                commande.TotalFacture = commande.FraisLivraison;
                _context.Add(commande);
                await _context.SaveChangesAsync();
                await _logService.LogAsync("Création commande", "CommandeAchat", commande.Id);
                TempData["SuccessMessage"] = "Commande créée! Ajoutez maintenant les produits.";
                return RedirectToAction(nameof(AddProduct), new { id = commande.Id });
            }
            ViewBag.EmployeId = new SelectList(_context.Employes, "Id", "NomComplet", commande.EmployeId);
            ViewBag.FournisseurId = new SelectList(_context.Fournisseurs.OrderBy(f => f.Nom), "Id", "Nom", commande.FournisseurId);
            ViewBag.LivraisonId = new SelectList(_context.Livraisons, "Id", "Statut", commande.LivraisonId);
            return View(commande);
        }

        public async Task<IActionResult> AddProduct(int? id)
        {
            if (id == null) return NotFound();
            var commande = await _context.CommandesAchat
                .Include(c => c.Fournisseur)
                .Include(c => c.LignesCommande).ThenInclude(lc => lc.Produit)
                .FirstOrDefaultAsync(c => c.Id == id);
            if (commande == null) return NotFound();

            ViewBag.Produits = new SelectList(await _context.Produits.OrderBy(p => p.Nom).ToListAsync(), "Id", "Nom");
            return View(commande);
        }

        [HttpPost, ValidateAntiForgeryToken]
        public async Task<IActionResult> AddProduct(int commandeId, int produitId, int quantite, decimal prixUnitaire)
        {
            var commande = await _context.CommandesAchat.Include(c => c.LignesCommande).FirstOrDefaultAsync(c => c.Id == commandeId);
            var produit = await _context.Produits.FindAsync(produitId);
            if (commande == null || produit == null) return NotFound();

            _context.LignesCommande.Add(new LigneCommande
            {
                CommandeAchatId = commandeId,
                ProduitId = produitId,
                Quantite = quantite,
                PrixUnitaire = prixUnitaire > 0 ? prixUnitaire : produit.PrixUnitaire
            });
            await _context.SaveChangesAsync();
            await _context.Entry(commande).Collection(c => c.LignesCommande).LoadAsync();
            RecalculerTotaux(commande);
            await _context.SaveChangesAsync();

            TempData["SuccessMessage"] = "Produit ajouté!";
            return RedirectToAction(nameof(AddProduct), new { id = commandeId });
        }

        [HttpPost, ValidateAntiForgeryToken]
        public async Task<IActionResult> RemoveProduct(int ligneId, int commandeId)
        {
            var ligne = await _context.LignesCommande.FindAsync(ligneId);
            var commande = await _context.CommandesAchat.Include(c => c.LignesCommande).FirstOrDefaultAsync(c => c.Id == commandeId);
            if (ligne == null || commande == null) return NotFound();
            _context.LignesCommande.Remove(ligne);
            await _context.SaveChangesAsync();
            await _context.Entry(commande).Collection(c => c.LignesCommande).LoadAsync();
            RecalculerTotaux(commande);
            await _context.SaveChangesAsync();
            TempData["SuccessMessage"] = "Produit retiré!";
            return RedirectToAction(nameof(AddProduct), new { id = commandeId });
        }

        [Authorize(Roles = "Admin,ChefCuisine")]
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null) return NotFound();
            var commande = await _context.CommandesAchat.Include(c => c.LignesCommande).FirstOrDefaultAsync(c => c.Id == id);
            if (commande == null) return NotFound();
            ViewBag.EmployeId = new SelectList(_context.Employes, "Id", "NomComplet", commande.EmployeId);
            ViewBag.FournisseurId = new SelectList(_context.Fournisseurs.OrderBy(f => f.Nom), "Id", "Nom", commande.FournisseurId);
            ViewBag.LivraisonId = new SelectList(_context.Livraisons, "Id", "Statut", commande.LivraisonId);
            return View(commande);
        }

        [HttpPost, ValidateAntiForgeryToken, Authorize(Roles = "Admin,ChefCuisine")]
        public async Task<IActionResult> Edit(int id, [Bind("Id,DateCommande,FraisLivraison,TauxTVA,Statut,Notes,EmployeId,LivraisonId,FournisseurId")] CommandeAchat commande)
        {
            if (id != commande.Id) return NotFound();
            if (ModelState.IsValid)
            {
                var existing = await _context.CommandesAchat
                    .Include(c => c.LignesCommande).ThenInclude(lc => lc.Produit)
                    .FirstOrDefaultAsync(c => c.Id == id);
                if (existing == null) return NotFound();

                var ancienStatut = existing.Statut;
                existing.DateCommande = commande.DateCommande;
                existing.FraisLivraison = commande.FraisLivraison;
                existing.TauxTVA = commande.TauxTVA;
                existing.Statut = commande.Statut;
                existing.Notes = commande.Notes;
                existing.EmployeId = commande.EmployeId;
                existing.LivraisonId = commande.LivraisonId;
                existing.FournisseurId = commande.FournisseurId;
                RecalculerTotaux(existing);

                if (commande.Statut == "Livrée" && ancienStatut != "Livrée")
                    await _mouvementService.GenererMouvementsLivraison(id, false);
                else if (commande.Statut == "Partielle" && ancienStatut != "Partielle")
                    await _mouvementService.GenererMouvementsLivraison(id, true);

                await _context.SaveChangesAsync();
                await _logService.LogAsync($"Commande #{id} → {commande.Statut}", "CommandeAchat", id);
                TempData["SuccessMessage"] = "Commande modifiée!";
                return RedirectToAction(nameof(Index));
            }
            ViewBag.EmployeId = new SelectList(_context.Employes, "Id", "NomComplet", commande.EmployeId);
            ViewBag.FournisseurId = new SelectList(_context.Fournisseurs.OrderBy(f => f.Nom), "Id", "Nom", commande.FournisseurId);
            ViewBag.LivraisonId = new SelectList(_context.Livraisons, "Id", "Statut", commande.LivraisonId);
            return View(commande);
        }

        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null) return NotFound();
            var commande = await _context.CommandesAchat
                .Include(c => c.Employe).Include(c => c.Fournisseur)
                .FirstOrDefaultAsync(m => m.Id == id);
            if (commande == null) return NotFound();
            return View(commande);
        }

        [HttpPost, ActionName("Delete"), ValidateAntiForgeryToken, Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var commande = await _context.CommandesAchat.FindAsync(id);
            if (commande != null) { _context.CommandesAchat.Remove(commande); await _context.SaveChangesAsync(); }
            TempData["SuccessMessage"] = "Commande supprimée!";
            return RedirectToAction(nameof(Index));
        }

        private void RecalculerTotaux(CommandeAchat commande)
        {
            commande.SousTotal = commande.LignesCommande.Sum(l => l.Quantite * l.PrixUnitaire);
            commande.MontantTVA = Math.Round(commande.SousTotal * commande.TauxTVA / 100, 3);
            commande.TotalTTC = commande.SousTotal + commande.MontantTVA;
            commande.TotalFacture = commande.TotalTTC + commande.FraisLivraison;
        }

        private bool CommandeExists(int id) => _context.CommandesAchat.Any(e => e.Id == id);
    }
}
