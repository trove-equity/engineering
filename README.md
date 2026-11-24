# Pave Engineering Laptop Pre-Setup

Run this once on a new Mac before setting up Pave's local development environment. The script installs and configures:

- Rosetta 2 (Apple Silicon Macs only)
- Xcode Command Line Tools
- Homebrew
- Git, GitHub CLI (`gh`) and `jq`
- Google Cloud CLI
- Visual Studio Code
- An SSH key for GitHub, plus your Git name and email

## Prerequisites

- A Mac laptop
- A GitHub account that you have signed in to through Okta
- Chrome set as your default browser

## Setup instructions

1. **Clone this repository**

   ```bash
   git clone https://github.com/trove-equity/engineering
   cd engineering
   ```

2. **Run the setup script**

   ```bash
   ./setup.sh
   ```

3. **Follow the prompts**

   - The script asks for your laptop password at the start.
   - Keep an eye on the terminal: the script stops for input several times.
   - It opens your GitHub SSH settings in the browser so you can add the new key and authorize it for SSO. Come back to the terminal afterwards to finish.

   The script is safe to run again. Steps that are already done are skipped.

## Next steps

When the script finishes, set up the local development VM by following the [Getting Started section of the tarmac README](https://github.com/trove-equity/tarmac#monorepo-getting-started-first-time-setup). In short:

```bash
git clone git@github.com:trove-equity/tarmac.git
cd tarmac
./local_dev_config.sh
```

Run `local_dev_config.sh` from your Mac terminal, not inside the VM.

## Troubleshooting

- **Permission errors:** make sure your account can install software on the laptop.
- **Anything else:** ask the Developer Platform team for help.
