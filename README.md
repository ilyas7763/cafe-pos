# Cafe POS

Offline desktop Point of Sale for a café or restaurant. WPF (.NET 8) + SQLite, Windows 10/11.

## Features
- **Point of Sale** – big icon tiles grouped by category. Tap a tile to add it; tap again to increment (red badge on the tile shows the count). +/- buttons in the order panel. Pay by Cash or Card (records the sale).
- **Dashboard** – today's sales / orders / average order, monthly totals with a month picker, daily sales bar chart, best sellers, recent orders.
- **Menu** – add / edit / remove items, choose an emoji **or upload your own picture** as the icon, pick the tile colour, add categories, set currency symbol and tax rate.
- 100 % offline. Data is stored in `%LocalAppData%\CafePOS\cafepos.db` (pictures in `...\CafePOS\icons`). Uninstalling does not delete it. To back up, copy that folder.

## Build the installer (Windows)
Double-click **build.bat**. It installs the .NET 8 SDK and Inno Setup if they are missing (via winget), publishes the app and produces `dist\CafePOS-Setup-1.0.0.exe`.

That one file is all your customers need. Like installing a game, they run it and click Next:
welcome page, licence, install folder, shortcuts (desktop / start with Windows), progress bar, "Launch Cafe POS".
Nothing else is downloaded: the .NET runtime and SQLite are bundled inside the installer, and the database is created on first launch.
Silent install for IT staff: `CafePOS-Setup-1.0.0.exe /VERYSILENT /SUPPRESSMSGBOXES`.
Upgrades: run a newer installer over the old one; it closes the app, replaces the files and keeps all sales data.
Uninstall asks whether to also delete the sales data (default: keep).

No local setup? Push this folder to GitHub: the included workflow (`.github/workflows/build.yml`) builds the installer and attaches it as a downloadable artifact.

Branding: replace `installer\LICENSE.txt` with your own terms and swap the images in `installer\assets` and `src\Assets\app.ico`.

## Run from source
`dotnet run --project src\CafePOS.csproj`

## Layout
```
src/Core        MVVM helpers, currency/tax formatting
src/Models      Product, OrderLine, dashboard rows
src/Data        SQLite schema + seed data (Db.cs), queries (Repo.cs)
src/ViewModels  PosViewModel, DashboardViewModel, MenuViewModel
src/Views       MainWindow + PosView / DashboardView / MenuView (XAML)
installer       Inno Setup script
```
