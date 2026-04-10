using Gestion_Stock.Models;
using Gestion_Stock.Services;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;

namespace Gestion_Stock.Controllers
{
    /// <summary>
    /// Contrôleur principal avec tableau de bord
    /// </summary>
    public class HomeController : Controller
    {
        private readonly IDashboardService _dashboardService;
        private readonly IAlertService _alertService;

        public HomeController(IDashboardService dashboardService, IAlertService alertService)
        {
            _dashboardService = dashboardService;
            _alertService = alertService;
        }

        /// <summary>
        /// Page d'accueil avec tableau de bord
        /// </summary>
        public async Task<IActionResult> Index()
        {
            var stats = await _dashboardService.ObtenirStatistiques();
            ViewBag.Statistiques = stats;

            var alertes = await _alertService.ObtenirAlertesNonLues();
            ViewBag.Alertes = alertes;

            // Produits les plus consommés (sorties cuisine) du mois
            var consommations = await _dashboardService.ObtenirProduitsLesPlusConsommes(DateTime.Now.Month, DateTime.Now.Year);
            ViewBag.ProduitsConsommes = consommations;

            // Produits les plus commandés du mois
            var produitsVendus = await _dashboardService.ObtenirProduitsLesPlusVendus(DateTime.Now.Month, DateTime.Now.Year);
            ViewBag.ProduitsVendus = produitsVendus;

            // Meilleures offres fournisseurs
            var meilleuresOffres = await _dashboardService.ObtenirMeilleuresOffres();
            ViewBag.MeilleuresOffres = meilleuresOffres;

            // Commandes en attente / retard
            var commandesEnAttente = await _dashboardService.ObtenirCommandesEnAttente();
            ViewBag.CommandesEnAttente = commandesEnAttente;

            return View();
        }

        /// <summary>
        /// Marquer une alerte comme lue
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> MarquerAlerteLue(int id)
        {
            await _alertService.MarquerCommeLue(id);
            return RedirectToAction(nameof(Index));
        }

        /// <summary>
        /// Marquer toutes les alertes comme lues
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> MarquerToutesAlertesLues()
        {
            await _alertService.MarquerToutesCommeLues();
            return RedirectToAction(nameof(Index));
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
