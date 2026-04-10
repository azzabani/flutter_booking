using Gestion_Stock.Models;

namespace Gestion_Stock.Services
{
    public interface ILogService
    {
        Task LogAsync(string action, string? entite = null, int? entiteId = null, string? details = null);
        Task<List<LogAction>> ObtenirLogs(int page = 1, int pageSize = 50);
    }
}
