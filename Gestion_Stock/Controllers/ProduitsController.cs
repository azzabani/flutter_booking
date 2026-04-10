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
    public class ProduitsController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IAlertService _alertService;

        public ProduitsController(ApplicationDbContext context, IAlertService alertService)
        {
            _context = context;
            _alertService = alertService;
        }

        // GET: Produits
        public async Task<IActionResult> Index()
        {
            var produits = await _context.Produits
                .Include(p => p.Categorie)
                .ToListAsync();
            return View(produits);
        }

        // GET: Produits/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var produit = await _context.Produits
                .Include(p => p.Categorie)
                .Include(p => p.FournisseurProduits)
                    .ThenInclude(fp => fp.Fournisseur)
                .Include(p => p.MouvementsStock)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (produit == null)
            {
                return NotFound();
            }

            return View(produit);
        }

        // GET: Produits/Create
        public IActionResult Create()
        {
            ViewData["CategorieId"] = new SelectList(_context.Categories, "Id", "Nom");
            return View();
        }

        // POST: Produits/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("Id,Nom,Reference,PrixUnitaire,StockActuel,SeuilMin,SeuilMax,CategorieId")] Produit produit)
        {
            if (ModelState.IsValid)
            {
                _context.Add(produit);
                await _context.SaveChangesAsync();

                // Vérifier et créer des alertes si nécessaire
                await _alertService.VerifierProduit(produit.Id);

                TempData["SuccessMessage"] = "Produit créé avec succès!";
                return RedirectToAction(nameof(Index));
            }
            ViewData["CategorieId"] = new SelectList(_context.Categories, "Id", "Nom", produit.CategorieId);
            return View(produit);
        }

        // GET: Produits/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var produit = await _context.Produits.FindAsync(id);
            if (produit == null)
            {
                return NotFound();
            }
            ViewData["CategorieId"] = new SelectList(_context.Categories, "Id", "Nom", produit.CategorieId);
            return View(produit);
        }

        // POST: Produits/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("Id,Nom,Reference,PrixUnitaire,StockActuel,SeuilMin,SeuilMax,CategorieId")] Produit produit)
        {
            if (id != produit.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(produit);
                    await _context.SaveChangesAsync();

                    // Vérifier et créer des alertes si nécessaire
                    await _alertService.VerifierProduit(produit.Id);

                    TempData["SuccessMessage"] = "Produit modifié avec succès!";
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!ProduitExists(produit.Id))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
                return RedirectToAction(nameof(Index));
            }
            ViewData["CategorieId"] = new SelectList(_context.Categories, "Id", "Nom", produit.CategorieId);
            return View(produit);
        }

        // GET: Produits/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var produit = await _context.Produits
                .Include(p => p.Categorie)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (produit == null)
            {
                return NotFound();
            }

            return View(produit);
        }

        // POST: Produits/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var produit = await _context.Produits.FindAsync(id);
            if (produit != null)
            {
                _context.Produits.Remove(produit);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Produit supprimé avec succès!";
            }

            return RedirectToAction(nameof(Index));
        }

        private bool ProduitExists(int id)
        {
            return _context.Produits.Any(e => e.Id == id);
        }
    }
}
