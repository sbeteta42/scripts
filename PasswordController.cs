using Microsoft.AspNetCore.Mvc;

namespace ChangePasswordApp.Controllers
{
    public class PasswordController : Controller
    {
        // Action qui affiche le formulaire pour changer le mot de passe
        [HttpGet]
        public IActionResult ChangePassword()
        {
            return View();
        }

        // Action qui traite le formulaire après soumission
        [HttpPost]
        public IActionResult ChangePassword(string username, string newPassword)
        {
            // Logique pour traiter le changement de mot de passe
            ViewBag.Message = $"Le mot de passe pour l'utilisateur {username} a été modifié avec succès.";
            return View();
        }
    }
}
