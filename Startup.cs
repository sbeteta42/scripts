app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Password}/{action=ChangePassword}/{id?}");