using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Gestion_Stock.Data;
using Gestion_Stock.Models;

namespace Gestion_Stock.Controllers
{
    /// <summary>
    /// Contrôleur pour la gestion des commerciaux
    /// </summary>
    public class CommerciauxController : Controller
    {
        private readonly ApplicationDbContext _context;

        public CommerciauxController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Commerciaux
        public async Task<IActionResult> Index()
        {
            return View(await _context.Commerciaux.ToListAsync());
        }

        // GET: Commerciaux/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var commercial = await _context.Commerciaux
                .Include(c => c.Livraisons)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (commercial == null)
            {
                return NotFound();
            }

            return View(commercial);
        }

        // GET: Commerciaux/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: Commerciaux/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("Id,Nom,Region,Commission")] Commercial commercial)
        {
            if (ModelState.IsValid)
            {
                _context.Add(commercial);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Commercial créé avec succès!";
                return RedirectToAction(nameof(Index));
            }
            return View(commercial);
        }

        // GET: Commerciaux/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var commercial = await _context.Commerciaux.FindAsync(id);
            if (commercial == null)
            {
                return NotFound();
            }
            return View(commercial);
        }

        // POST: Commerciaux/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("Id,Nom,Region,Commission")] Commercial commercial)
        {
            if (id != commercial.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(commercial);
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Commercial modifié avec succès!";
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!CommercialExists(commercial.Id))
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
            return View(commercial);
        }

        // GET: Commerciaux/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var commercial = await _context.Commerciaux
                .FirstOrDefaultAsync(m => m.Id == id);

            if (commercial == null)
            {
                return NotFound();
            }

            return View(commercial);
        }

        // POST: Commerciaux/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var commercial = await _context.Commerciaux.FindAsync(id);
            if (commercial != null)
            {
                _context.Commerciaux.Remove(commercial);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Commercial supprimé avec succès!";
            }

            return RedirectToAction(nameof(Index));
        }

        private bool CommercialExists(int id)
        {
            return _context.Commerciaux.Any(e => e.Id == id);
        }
    }
}
