<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Changer le mot de passe Active Directory</title>
</head>
<body>
    <h1>Changer votre mot de passe Active Directory</h1>
    <form method="post" action="">
        <label for="username">Nom d'utilisateur :</label><br>
        <input type="text" id="username" name="username" required><br><br>

        <label for="currentPassword">Mot de passe actuel :</label><br>
        <input type="password" id="currentPassword" name="currentPassword" required><br><br>

        <label for="newPassword">Nouveau mot de passe :</label><br>
        <input type="password" id="newPassword" name="newPassword" required><br><br>

        <label for="confirmPassword">Confirmez le nouveau mot de passe :</label><br>
        <input type="password" id="confirmPassword" name="confirmPassword" required><br><br>

        <button type="submit" name="changePassword">Changer le mot de passe</button>
    </form>

    <?php
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['changePassword'])) {
        // Récupérer les valeurs du formulaire
        $username = $_POST['username'];
        $currentPassword = $_POST['currentPassword'];
        $newPassword = $_POST['newPassword'];
        $confirmPassword = $_POST['confirmPassword'];

        // Vérifier que les deux nouveaux mots de passe correspondent
        if ($newPassword !== $confirmPassword) {
            echo "<p style='color: red;'>Erreur : Les nouveaux mots de passe ne correspondent pas.</p>";
            exit;
        }

        // Créer le script PowerShell à exécuter
        $psScript = <<<PSSCRIPT
        # Importer le module Active Directory
        Import-Module ActiveDirectory

        # Définir les variables
        \$username = "$username"
        \$currentPassword = ConvertTo-SecureString "$currentPassword" -AsPlainText -Force
        \$newPassword = ConvertTo-SecureString "$newPassword" -AsPlainText -Force

        try {
            # Modifier le mot de passe
            Set-ADAccountPassword -Identity \$username `
                                  -OldPassword \$currentPassword `
                                  -NewPassword \$newPassword `
                                  -Confirm:\$false
            Write-Output "Succès : Mot de passe modifié pour l'utilisateur \$username."
        } catch {
            Write-Output "Erreur : \$($_.Exception.Message)"
        }
        PSSCRIPT;

        // Enregistrer le script PowerShell temporairement
        $psScriptFile = tempnam(sys_get_temp_dir(), "psscript") . ".ps1";
        file_put_contents($psScriptFile, $psScript);

        // Exécuter le script PowerShell
        $output = [];
        $returnVar = 0;
        exec("powershell -ExecutionPolicy Bypass -File " . escapeshellarg($psScriptFile), $output, $returnVar);

        // Afficher le résultat
        echo "<h2>Résultat :</h2>";
        echo "<pre>" . implode("\n", $output) . "</pre>";

        // Supprimer le fichier PowerShell temporaire
        unlink($psScriptFile);
    }
    ?>
</body>
</html>
