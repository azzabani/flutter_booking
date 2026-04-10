using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Gestion_Stock.Data;
using Gestion_Stock.Models;
using Gestion_Stock.Services;

namespace Gestion_Stock.Controllers
{
    /// <summary>
    /// Module 5 — Mouvements de stock avec filtres
    /// </summary>
    [Authorize]
    public class MouvementsController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IMouvementService _mouvementService;
        private readonly ILogService _logService;

        public MouvementsController(ApplicationDbContext context, IMouvementService mouvementService, ILogService logService)
        {
            _context = context;
            _mouvementService = mouvementService;
            _logService = logService;
        }

        // GET: Mouvements — avec filtres
        public async Task<IActionResult> Index(int? produitId, string? type, string? motif,
            DateTime? dateDebut, DateTime? dateFin)
        {
            var mouvements = await _mouvementService.ObtenirHistorique(produitId, type, motif, dateDebut, dateFin);

            ViewBag.Produits = new SelectList(await _context.Produits.OrderBy(p => p.Nom).ToListAsync(), "Id", "Nom", produitId);
            ViewBag.FiltreType = type;
            ViewBag.FiltreMotif = motif;
            ViewBag.FiltreProduitId = produitId;
            ViewBag.FiltreDateDebut = dateDebut?.ToString("yyyy-MM-dd");
            ViewBag.FiltreDateFin = dateFin?.ToString("yyyy-MM-dd");

            return View(mouvements);
        }

        // GET: Mouvements/Create — saisie manuelle (sortie cuisine, perte, etc.)
        [Authorize(Roles = "Admin,ChefCuisine")]
        public IActionResult Create()
        {
            ViewBag.Produits = new SelectList(_context.Produits.OrderBy(p => p.Nom), "Id", "Nom");
            ViewBag.Employes = new SelectList(_context.Employes, "Id", "NomComplet");
            return View();
        }

        // POST: Mouvements/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "Admin,ChefCuisine")]
        public async Task<IActionResult> Create(int produitId, int quantite, string typeMouvement,
            string motif, string? raison, int? employeId)
        {
            if (quantite <= 0)
            {
                ModelState.AddModelError("", "La quantité doit être supérieure à 0");
                ViewBag.Produits = new SelectList(_context.Produits.OrderBy(p => p.Nom), "Id", "Nom");
                ViewBag.Employes = new SelectList(_context.Employes, "Id", "NomComplet");
                return View();
            }

            await _mouvementService.EnregistrerMouvement(produitId, quantite, typeMouvement, motif, raison, null, employeId);
            await _logService.LogAsync($"Mouvement {typeMouvement} enregistré", "MouvementStock", null,
                $"Produit #{produitId}, Qté: {quantite}, Motif: {motif}");

            TempData["SuccessMessage"] = "Mouvement enregistré avec succès!";
            return RedirectToAction(nameof(Index));
        }

        // GET: Mouvements/ParProduit/5
        public async Task<IActionResult> ParProduit(int id)
        {
            var produit = await _context.Produits
                .Include(p => p.Categorie)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (produit == null) return NotFound();

            var mouvements = await _mouvementService.ObtenirHistorique(produitId: id);
            ViewBag.Produit = produit;
            return View(mouvements);
        }
    }
}
