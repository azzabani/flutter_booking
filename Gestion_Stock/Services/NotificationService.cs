using Gestion_Stock.Data;
using Gestion_Stock.Models;
using Microsoft.EntityFrameworkCore;

namespace Gestion_Stock.Services
{
    public class NotificationService : INotificationService
    {
        private readonly ApplicationDbContext _context;

        public NotificationService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<List<Notification>> ObtenirNotificationsNonLues(int? employeId = null)
        {
            var query = _context.Notifications
                .Where(n => !n.EstLue)
                .Include(n => n.Employe);

            if (employeId.HasValue)
            {
                query = query.Where(n => n.EmployeId == employeId || n.EmployeId == null);
            }

            return await query
                .OrderByDescending(n => n.DateCreation)
                .ToListAsync();
        }

        public async Task<Notification> CreerNotification(string titre, string message, string type, int? employeId = null)
        {
            var notification = new Notification
            {
                Titre = titre,
                Message = message,
                Type = type,
                EmployeId = employeId,
                DateCreation = DateTime.Now,
                EstLue = false
            };

            _context.Notifications.Add(notification);
            await _context.SaveChangesAsync();

            return notification;
        }

        public async Task MarquerCommeLue(int notificationId)
        {
            var notification = await _context.Notifications.FindAsync(notificationId);
            if (notification != null)
            {
                notification.EstLue = true;
                await _context.SaveChangesAsync();
            }
        }

        public async Task MarquerToutesCommeLues(int? employeId = null)
        {
            var query = _context.Notifications.Where(n => !n.EstLue);

            if (employeId.HasValue)
            {
                query = query.Where(n => n.EmployeId == employeId || n.EmployeId == null);
            }

            var notifications = await query.ToListAsync();
            foreach (var notification in notifications)
            {
                notification.EstLue = true;
            }

            await _context.SaveChangesAsync();
        }

        public async Task SupprimerNotification(int notificationId)
        {
            var notification = await _context.Notifications.FindAsync(notificationId);
            if (notification != null)
            {
                _context.Notifications.Remove(notification);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<int> CompterNotificationsNonLues(int? employeId = null)
        {
            var query = _context.Notifications.Where(n => !n.EstLue);

            if (employeId.HasValue)
            {
                query = query.Where(n => n.EmployeId == employeId || n.EmployeId == null);
            }

            return await query.CountAsync();
        }
    }
}