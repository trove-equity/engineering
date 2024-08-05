#!/bin/bash
set -e
source helpers/helpers.sh

# Set the profile file, see helpers/helpers.sh
shell_profile

# Intro message
INTRO_MESSAGE=$(cat <<EOF

Welcome to the local development pre-setup script. This script will install the 
necessary tools before you can run the local dev setup process. You will be prompted
for your laptop password during the installation process.

Please make sure that you have a Github account before proceeding.

If you encounter any issues, please notify the Dev Platform Team.\n
EOF
)

log "${INTRO_MESSAGE}"
read -p "Press enter to continue"

sudo --reset-timestamp
echo
sudo_refresh


# Install Rosetta 2 for Apple Silicon (M1) Macs
if [[ "$(uname -m)" == "arm64" ]] && ! pgrep oahd >/dev/null 2>&1; then
    logN "Installing Rosetta for Mac"
    sudo_askpass softwareupdate --install-rosetta --agree-to-license
    logC "Rosetta installed"
else
    logS "Rosetta already installed"
fi


# Install Xcode Command Line Tools
if ! [ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]; then
    logN "Installing Xcode Command Line Tools"
    xcode-select --install
else
    logS "Xcode Command Line Tools already installed"
fi


# Install Homebrew
if ! [ -f /opt/homebrew/bin/brew ]; then
    logN "Installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval $(/opt/homebrew/bin/brew shellenv)
    logC "Homebrew installed"
else
    logS "Homebrew already installed"
fi


# Add Homebrew to PATH
if ! string_in_file "/opt/homebrew/bin/brew" "${PROFILE}"; then
    BREWPATH=$(cat <<'EOF'
if [ -f /opt/homebrew/bin/brew ]; then
    eval $(/opt/homebrew/bin/brew shellenv)
fi
EOF
)
    echo "${BREWPATH}" >> ${PROFILE}
    logC "Homebrew added to PATH"
else
    logS "Homebrew already in PATH"
fi


# Update Homebrew
logN "Updating Homebrew"
eval $(/opt/homebrew/bin/brew shellenv)
brew update --quiet
logC "Homebrew updated"


# Install Brewfile
logN "Installing Brewfile"
brew bundle --file=./Brewfile
logC "Brewfile installed"

# Install VSCode separately (if required)
if ! [ -d "/Applications/Visual Studio Code.app" ]; then
    brew install --cask 'visual-studio-code'
    logC "VSCode installed via Brew"
else
    logS "VSCode already installed"
fi

# Add gcloud to PATH
if ! string_in_file 'google-cloud-sdk' ${PROFILE} ; then
    GCLOUD_SDK_PATH=$(cat <<'EOF'
if command -v brew &> /dev/null; then
    source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
    source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
fi
EOF
)

    echo -e "\n${GCLOUD_SDK_PATH}" >> ${PROFILE}
    logC "gcloud added to PATH"
else
    logS "gcloud already in PATH"
fi


# Setup SSH key
DEFAULT_RSA_PATH=~/.ssh/id_rsa

logN "Where would you like to save your SSH key? (default: ${DEFAULT_RSA_PATH})"
read -p "Enter path: " RSA_PATH

if [[ -z ${RSA_PATH} ]]; then
    RSA_PATH=${DEFAULT_RSA_PATH}
fi

# Check if key already exists
if [[ -f ${RSA_PATH} ]]; then
    logS "SSH key already exists"
else
    while true; do
        logN "Please enter your Pave email to associate with your SSH key?"
        read -p "Enter email: " EMAIL </dev/tty || {
            EMAIL=""
        }

        if [[ -z ${EMAIL} ]]; then
            logA "Email cannot be empty"
        else
            break
        fi
    done

    logN "Generating SSH key"
    if [[ ! -f ${RSA_PATH} ]]; then
        ssh-keygen -t rsa -b 4096 -C "${EMAIL}" -f ${RSA_PATH}
        logC "SSH key generated"
    else
        logS "SSH key already exists"
    fi

    # Add SSH key to config
    touch ~/.ssh/config
    if ! string_in_file "IdentityFile ${RSA_PATH}" ~/.ssh/config; then
        echo -e "\n\nHost *\n AddKeysToAgent yes\n IdentityFile $RSA_PATH\n\n" >> ~/.ssh/config
        logC "SSH config updated"
    fi

    # Add SSH key to ssh-agent
    logN "Adding SSH key to ssh-agent"
    ssh-add -K $rsa_path
    logC "SSH key added to ssh-agent"
fi


# Configure Git and GitHub
logN "Copying SSH Public Key to clipboard \nUse this key to add to your GitHub account in the next step"
pbcopy < ${RSA_PATH}.pub

logN $(cat <<EOF
Your browser will be opened to a GitHub SSH Keys settings page\n
You’ll need to paste into the 'Key' field, then click the 'Add SSK Key' button\n
Then, click 'Enable SSO' for that key.
EOF
)
read -p "Press enter to continue"

open https://github.com/settings/ssh/new

logN "Configuring Git"
logN "Enter your display name for Git"
read -p "Enter name: " GIT_NAME
git config --global user.name "${GIT_NAME}"

logN "Enter your email address for Git"
read -p "Enter email: " GIT_EMAIL
git config --global user.email "${GIT_EMAIL}"

logC "Git configured"


# Setup Complete
logC $(cat <<EOF
Setup complete! 
You can now proceed with the local development setup process.
EOF
)

SETUP_SUCCESS=1