using Gestion_Stock.Services;
using Microsoft.AspNetCore.Mvc;

namespace Gestion_Stock.Controllers
{
    public class NotificationsController : Controller
    {
        private readonly INotificationService _notificationService;

        public NotificationsController(INotificationService notificationService)
        {
            _notificationService = notificationService;
        }

        public async Task<IActionResult> Index()
        {
            var notifications = await _notificationService.ObtenirNotificationsNonLues();
            return View(notifications);
        }

        [HttpPost]
        public async Task<IActionResult> MarquerLue(int id)
        {
            await _notificationService.MarquerCommeLue(id);
            return RedirectToAction(nameof(Index));
        }

        [HttpPost]
        public async Task<IActionResult> MarquerToutesLues()
        {
            await _notificationService.MarquerToutesCommeLues();
            return RedirectToAction(nameof(Index));
        }

        [HttpPost]
        public async Task<IActionResult> Supprimer(int id)
        {
            await _notificationService.SupprimerNotification(id);
            return RedirectToAction(nameof(Index));
        }

        [HttpGet]
        public async Task<JsonResult> CompterNonLues()
        {
            var count = await _notificationService.CompterNotificationsNonLues();
            return Json(new { count });
        }
    }
}