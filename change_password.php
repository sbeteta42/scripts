<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Récupére les données du formulaire
    $username = escapeshellarg($_POST['username']);
    $currentPassword = escapeshellarg($_POST['current_password']);
    $newPassword = escapeshellarg($_POST['new_password']);
    $confirnewPassword = escapeshellarg($_POST['confirmnew_password']);


    // Chemin vers le script PowerShell
    $scriptPath = "C:\\Scripts\\Set-ADPassword.ps1";

    // Commande PowerShell
    $command = "powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -username $username -currentPassword $currentPassword -newPassword $newPassword";

    // Exécute le script PowerShell
    $output = [];
    $returnCode = 0;
    exec($command, $output, $returnCode);

    // Traitement du résultat
    $resultMessage = '';
    if ($returnCode === 0) {
        // Analyse des résultats retournés par PowerShell
        $resultMessage = implode("<br>", $output);
        if (strpos($resultMessage, "modifié avec succès") !== false) {
            $success = true;
        } elseif (strpos($resultMessage, "Le mot de passe actuel est incorrect") !== false) {
            $success = false;
            $resultMessage = "Erreur : Le mot de passe actuel est incorrect.";
        } elseif (strpos($resultMessage, "n'existe pas") !== false) {
            $success = false;
            $resultMessage = "Erreur : L'utilisateur spécifié n'existe pas.";
        } else {
            $success = false;
            $resultMessage = "Erreur : Une erreur inconnue s'est produite.";
        }
    } else {
        $success = false;
        $resultMessage = "Erreur : Impossible d'exécuter le script PowerShell.";
    }
}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Modifier votre mot de passe Active Directory</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
    </style>
</head>
<body>
    <h1>Modifier votre mot de passe Active Directory</h1>
    
    <?php if (isset($success)): ?>
        <div class="<?= $success ? 'success' : 'error' ?>">
            <?= htmlspecialchars($resultMessage) ?>
        </div>
        <hr>
    <?php endif; ?>

    <form method="POST" action="">
        <label for="username">Nom d'utilisateur :</label>
        <input type="text" id="username" name="username" required><br><br>

        <label for="current_password">Mot de passe actuel :</label>
        <input type="password" id="current_password" name="current_password" required><br><br>

        <label for="new_password">Nouveau mot de passe :</label>
        <input type="password" id="new_password" name="new_password" required><br><br>

        <label for="confirm_new_password">Confirmer le nouveau mot de passe :</label>
        <input type="password" id="confirmnew_password" name="confirmnew_password" required><br><br>

        <button type="submit">Modifier le mot de passe</button>
    </form>
</body>
</html>
