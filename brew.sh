#!/usr/bin/env bash

sudo chown -R `whoami` /usr/local

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

# Install GNU core utilities (those that come with OS X are outdated)
brew install coreutils
echo "Don’t forget to add $(brew --prefix coreutils)/libexec/gnubin to \$PATH."

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils
# Install Bash 4
brew install bash

# Install wget with IRI support
brew install wget --enable-iri

# Install more recent versions of some OS X tools
brew tap homebrew/dupes
brew install homebrew/dupes/grep

# Install other useful binaries
brew install wget
brew install ack
brew install git
brew install imagemagick
brew install lynx
#brew install node
brew install pigz
brew install rename
brew install tree
brew install maven

# Install zsh and switch to zsh
brew install zsh
chsh -s /bin/zsh

# Install nosql db riak
brew install riak

# Install redis
brew install redis

# Install mac terminal mail client
brew install mutt
brew install w3m
brew install urlview

# Install native apps
brew tap phinze/homebrew-cask
brew install brew-cask

function installcask() {
    brew cask install "${@}" 2> /dev/null
}

#installcask evernote
installcask google-chrome
installcask google-chrome-canary
installcask iterm2
installcask vlc
installcask u-torrent
#installcask qq
installcask skitch
installcask the-unarchiver
installcask dropbox

# Remove outdated versions from the cellar
brew cleanup
