using Gestion_Stock.Models;

namespace Gestion_Stock.Services
{
    public interface INotificationService
    {
        Task<List<Notification>> ObtenirNotificationsNonLues(int? employeId = null);
        Task<Notification> CreerNotification(string titre, string message, string type, int? employeId = null);
        Task MarquerCommeLue(int notificationId);
        Task MarquerToutesCommeLues(int? employeId = null);
        Task SupprimerNotification(int notificationId);
        Task<int> CompterNotificationsNonLues(int? employeId = null);
    }
}