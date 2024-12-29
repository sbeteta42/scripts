<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Récupérer les données du formulaire
    $username = escapeshellarg($_POST['username']);
    $currentPassword = escapeshellarg($_POST['current_password']);
    $newPassword = escapeshellarg($_POST['new_password']);

    // Chemin vers le script PowerShell
    $scriptPath = "C:\\Scripts\\Modify-ADPassword.ps1";

    // Commande PowerShell
    $command = "powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -username $username -currentPassword $currentPassword -newPassword $newPassword";

    // Exécuter le script PowerShell
    $output = [];
    $returnCode = 0;
    exec($command, $output, $returnCode);

    // Afficher le résultat
    if ($returnCode === 0) {
        echo "<p>Résultat : " . implode("<br>", $output) . "</p>";
    } else {
        echo "<p>Une erreur s'est produite lors de la modification du mot de passe.</p>";
    }
}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Modifier le mot de passe Active Directory</title>
</head>
<body>
    <h1>Modifier le mot de passe Active Directory</h1>
    <form method="POST" action="">
        <label for="username">Nom d'utilisateur :</label>
        <input type="text" id="username" name="username" required><br><br>

        <label for="current_password">Mot de passe actuel :</label>
        <input type="password" id="current_password" name="current_password" required><br><br>

        <label for="new_password">Nouveau mot de passe :</label>
        <input type="password" id="new_password" name="new_password" required><br><br>

        <button type="submit">Modifier le mot de passe</button>
    </form>
</body>
</html>
