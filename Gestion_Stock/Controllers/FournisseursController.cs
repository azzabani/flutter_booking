using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Gestion_Stock.Data;
using Gestion_Stock.Models;

namespace Gestion_Stock.Controllers
{
    /// <summary>
    /// Contrôleur pour la gestion des fournisseurs
    /// </summary>
    public class FournisseursController : Controller
    {
        private readonly ApplicationDbContext _context;

        public FournisseursController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Fournisseurs
        public async Task<IActionResult> Index()
        {
            var fournisseurs = await _context.Fournisseurs
                .Include(f => f.FournisseurProduits)
                .ToListAsync();
            return View(fournisseurs);
        }

        // GET: Fournisseurs/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var fournisseur = await _context.Fournisseurs
                .Include(f => f.FournisseurProduits)
                    .ThenInclude(fp => fp.Produit)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (fournisseur == null)
            {
                return NotFound();
            }

            return View(fournisseur);
        }

        // GET: Fournisseurs/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: Fournisseurs/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("Id,Nom,Email,Telephone,Adresse")] Fournisseur fournisseur)
        {
            if (ModelState.IsValid)
            {
                _context.Add(fournisseur);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Fournisseur créé avec succès!";
                return RedirectToAction(nameof(Index));
            }
            return View(fournisseur);
        }

        // GET: Fournisseurs/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var fournisseur = await _context.Fournisseurs.FindAsync(id);
            if (fournisseur == null)
            {
                return NotFound();
            }
            return View(fournisseur);
        }

        // POST: Fournisseurs/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("Id,Nom,Email,Telephone,Adresse")] Fournisseur fournisseur)
        {
            if (id != fournisseur.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(fournisseur);
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Fournisseur modifié avec succès!";
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!FournisseurExists(fournisseur.Id))
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
            return View(fournisseur);
        }

        // GET: Fournisseurs/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var fournisseur = await _context.Fournisseurs
                .FirstOrDefaultAsync(m => m.Id == id);

            if (fournisseur == null)
            {
                return NotFound();
            }

            return View(fournisseur);
        }

        // POST: Fournisseurs/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var fournisseur = await _context.Fournisseurs.FindAsync(id);
            if (fournisseur != null)
            {
                _context.Fournisseurs.Remove(fournisseur);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Fournisseur supprimé avec succès!";
            }

            return RedirectToAction(nameof(Index));
        }

        private bool FournisseurExists(int id)
        {
            return _context.Fournisseurs.Any(e => e.Id == id);
        }
    }
}
