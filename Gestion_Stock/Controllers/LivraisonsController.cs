using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using Gestion_Stock.Data;
using Gestion_Stock.Models;

namespace Gestion_Stock.Controllers
{
    /// <summary>
    /// Contrôleur pour la gestion des livraisons
    /// </summary>
    public class LivraisonsController : Controller
    {
        private readonly ApplicationDbContext _context;

        public LivraisonsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Livraisons
        public async Task<IActionResult> Index()
        {
            var livraisons = await _context.Livraisons
                .Include(l => l.Commercial)
                .Include(l => l.Commandes)
                .ToListAsync();
            return View(livraisons);
        }

        // GET: Livraisons/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var livraison = await _context.Livraisons
                .Include(l => l.Commercial)
                .Include(l => l.Commandes)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (livraison == null)
            {
                return NotFound();
            }

            return View(livraison);
        }

        // GET: Livraisons/Create
        public IActionResult Create()
        {
            ViewData["CommercialId"] = new SelectList(_context.Commerciaux, "Id", "Nom");
            return View();
        }

        // POST: Livraisons/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("Id,DateLivraison,Statut,NoteAvis,Note,CommercialId")] Livraison livraison)
        {
            if (ModelState.IsValid)
            {
                _context.Add(livraison);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Livraison créée avec succès!";
                return RedirectToAction(nameof(Index));
            }
            ViewData["CommercialId"] = new SelectList(_context.Commerciaux, "Id", "Nom", livraison.CommercialId);
            return View(livraison);
        }

        // GET: Livraisons/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var livraison = await _context.Livraisons.FindAsync(id);
            if (livraison == null)
            {
                return NotFound();
            }
            ViewData["CommercialId"] = new SelectList(_context.Commerciaux, "Id", "Nom", livraison.CommercialId);
            return View(livraison);
        }

        // POST: Livraisons/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("Id,DateLivraison,Statut,NoteAvis,Note,CommercialId")] Livraison livraison)
        {
            if (id != livraison.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(livraison);
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Livraison modifiée avec succès!";
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!LivraisonExists(livraison.Id))
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
            ViewData["CommercialId"] = new SelectList(_context.Commerciaux, "Id", "Nom", livraison.CommercialId);
            return View(livraison);
        }

        // GET: Livraisons/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var livraison = await _context.Livraisons
                .Include(l => l.Commercial)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (livraison == null)
            {
                return NotFound();
            }

            return View(livraison);
        }

        // POST: Livraisons/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var livraison = await _context.Livraisons.FindAsync(id);
            if (livraison != null)
            {
                _context.Livraisons.Remove(livraison);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Livraison supprimée avec succès!";
            }

            return RedirectToAction(nameof(Index));
        }

        // GET: Livraisons/AddNote/5
        public async Task<IActionResult> AddNote(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var livraison = await _context.Livraisons.FindAsync(id);
            if (livraison == null)
            {
                return NotFound();
            }

            return View(livraison);
        }

        // POST: Livraisons/AddNote/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> AddNote(int id, string noteAvis, int? noteChiffre)
        {
            var livraison = await _context.Livraisons.FindAsync(id);
            if (livraison == null) return NotFound();

            livraison.NoteAvis = noteAvis;
            livraison.NoteChiffre = noteChiffre;
            await _context.SaveChangesAsync();
            TempData["SuccessMessage"] = "Évaluation enregistrée avec succès!";

            return RedirectToAction(nameof(Details), new { id = id });
        }

        private bool LivraisonExists(int id)
        {
            return _context.Livraisons.Any(e => e.Id == id);
        }
    }
}
