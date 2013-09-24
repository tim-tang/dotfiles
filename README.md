Mac OSX /Linux => Vim&Dot Files
--
## Install Home Brew

    $ ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"

## Git-free install

    $ curl -L https://github.com/tim-tang/dotfiles/tarball/master |tar -xzv

## Create dot file link

    $ ./install.sh

> Above command will create symbol links under $Home/ and copy .vim folder into $Home/

## When setting up a new Mac, you may want to install some common Homebrew formulae (after installing Homebrew, of course):

    $ ./brew.sh

    $ git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

## Add alias that easy to pull and push

    $ pull-dotfiles
    $ push-dotfile

Install Homebrew formulae
