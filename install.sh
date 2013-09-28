#!/bin/zsh

for link_file ($PWD/*.symlink); do
    FILENAME=${link_file##*/}
    ln -s -i -v $link_file $HOME/.${FILENAME%.*}
done

cp -r -f $PWD/gnzh.zsh-theme $HOME/.oh-my-zsh/themes/
cd $HOME && source $HOME/.zshrc
./.osx

echo "-- Re-configure mac os environment successfully --"
