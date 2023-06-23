
```bash
# This assumes you have a home folder called 'tasa' and that you're using a folder ~/code to keep all your code stuff

# Install ohmyzsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 

# Install brew apps
brew install neovim tmux python virtualenvwrapper

# Install pip apps
pip3 install pynvim black isort flake8

# Install some useful GUI apps
curl -s 'https://api.macapps.link/en/firefox-chrome-github-vscode-docker-postman-iterm' | sh 

# Install dev tools
xcode-select --install 

# Set up an ssh key for this computer on github
ssh-keygen -t ed25519 -C "tasa@enriquetasa.com"
eval "$(ssh-agent -s)"
vi "$(ssh-agent -s)"
"""
Host *.github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
"""
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
pbcopy < ~/.ssh/id_ed25519.pub

# Clone dotfiles repository
git clone git@github.com:enriquetasa/dotfiles.git

# Replace your ~/.zshrc with the one found in the dotfiles repo
cp ~/code/dotfiles/zshrc ~/.zshrc

# Configure git 
cp ~/code/dotfiles/gitconfig ~/.gitconfig

# Configure vim
mkdir ~/.config/nvim
mkdir ~/.config/nvim/plugged
mkdir ~/.config/nvim/autoload
sh -c 'curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
cp ~/code/dotfiles/init.vim ~/.config/nvim/init.vim
nvim -c "PlugInstall"
export EDITOR='nvim'
export VISUAL='nvim'
```
