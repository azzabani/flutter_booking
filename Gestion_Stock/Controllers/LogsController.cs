using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Gestion_Stock.Services;

namespace Gestion_Stock.Controllers
{
    /// <summary>
    /// Module 8 — Journal des actions
    /// </summary>
    [Authorize(Roles = "Admin")]
    public class LogsController : Controller
    {
        private readonly ILogService _logService;

        public LogsController(ILogService logService)
        {
            _logService = logService;
        }

        public async Task<IActionResult> Index(int page = 1)
        {
            var logs = await _logService.ObtenirLogs(page, 50);
            ViewBag.Page = page;
            return View(logs);
        }
    }
}
