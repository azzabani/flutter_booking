using Gestion_Stock.Data;
using Gestion_Stock.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Gestion_Stock.Services
{
    /// <summary>
    /// Service de journalisation des actions utilisateurs
    /// </summary>
    public class LogService : ILogService
    {
        private readonly ApplicationDbContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly UserManager<IdentityUser> _userManager;

        public LogService(ApplicationDbContext context, IHttpContextAccessor httpContextAccessor, UserManager<IdentityUser> userManager)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
            _userManager = userManager;
        }

        public async Task LogAsync(string action, string? entite = null, int? entiteId = null, string? details = null)
        {
            var userName = _httpContextAccessor.HttpContext?.User?.Identity?.Name ?? "Système";

            // Trouver l'employé correspondant
            var employe = await _context.Employes
                .FirstOrDefaultAsync(e => e.Email == userName);

            var log = new LogAction
            {
                Action = action,
                Entite = entite,
                EntiteId = entiteId,
                Details = details,
                DateAction = DateTime.Now,
                NomUtilisateur = userName,
                EmployeId = employe?.Id
            };

            _context.LogsActions.Add(log);
            await _context.SaveChangesAsync();
        }

        public async Task<List<LogAction>> ObtenirLogs(int page = 1, int pageSize = 50)
        {
            return await _context.LogsActions
                .Include(l => l.Employe)
                .OrderByDescending(l => l.DateAction)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();
        }
    }
}
