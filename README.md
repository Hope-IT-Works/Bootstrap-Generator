# Bootstrap-Generator

repository for bootstrap project initialization

## About

This PowerShell script initializes a Bootstrap project and can optionally also include Bootstrap Icons.

## Usage

Run the script in PowerShell:

```powershell
./bootstrap-generator.ps1
```

## Parameters

- `-WithBootstrapIcons`: Add this parameter to include Bootstrap Icons.
- `-DirectoryName`: Name for the assets directory. Default is "assets".
- `-DestinationPath`: Directory path where the files will be saved. Default is the current path.

## Workflow

1. The script greets the user and verifies the destination path.
2. It creates the directory if it does not already exist.
3. It fetches the latest Bootstrap release and downloads the assets.
4. The downloaded assets are extracted and the zip file is removed.
5. The assets are moved to the destination directory and the temporary directory is removed.
6. If the WithBootstrapIcons parameter is set, the script repeats steps 3-5 for the Bootstrap Icons.
7. Finally, the script outputs a success message and displays the used versions of Bootstrap and, if applicable, Bootstrap Icons.

## Note

The developement of this script was greatly accelerated by GitHub Copilot.
