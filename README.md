# RPackagesOffline

**RPackagesOffline** is a repository providing a collection of R package files for **offline installation**. It allows R users to install packages on systems with no internet access by using pre-downloaded package archives. This is especially useful in secure environments or remote locations where CRAN access is unavailable.

## Repository Purpose

- **Offline R Packages:** Contains R package binaries (e.g., `.zip` for Windows ) stored in the `packages/` folder. These can be installed without an internet connection.
- **Use Cases:** Ideal for installing R packages on servers or computers that are offline or behind firewalls, by transferring these files via USB or internal network share.
- **Dependencies:** The repository aims to include not just the main packages but also their key dependencies. 

## Prerequisites

- **R Installation:** You need R installed on the target offline system. Make sure the R version is compatible with the package files:
  - For **Windows `.zip` packages**, use the corresponding R version (the binary packages are often specific to a major R release, e.g., packages built for R 3.x won’t work on R 4.x, and vice versa).
- **Disk Space:** Sufficient space to store and install the packages.
- **No Internet Required:** All installations from this repository are done offline.

## Getting the Repository

1. **Clone or Download**: If you have internet on a separate machine, clone this repo or download it as a ZIP:
   ```sh
   git clone https://github.com/noyard/RPackagesOffline.git
   ```
   Or use the GitHub web interface to download the repository as a ZIP file and then extract it.
2. Modify file DownloadRPackages.ps1, with the R packages you would like to download.
3. Run .\DownloadRPackages.ps1 from the folder, Script will create a subfolder "Packages" and download the packages and dependant packages. 
4. **Transfer to Offline Machine**: Copy the `packages/` folder and LoadRPackages.ps1 to the offline system via USB, network share, etc.
5. Run .\LoadRPackages.ps1 on the offline system that already has R installed.

## Verifying a Package is loaded into R
example psych R Package - 
require(psych)  # Returns TRUE if loaded successfully


## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details. This means you’re free to use, modify, and distribute the contents of this repo as long as the license terms are respected.

## Author

**Norman Yard** (GitHub: https://github.com/noyard) – creator and maintainer of this repository. Feel free to contact via GitHub for any questions.

---

*Happy R coding, even offline!* 🚀📦

