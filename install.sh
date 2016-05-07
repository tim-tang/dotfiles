#!/bin/zsh

for link_file ($PWD/*.symlink); do
    FILENAME=${link_file##*/}
    ln -s -i -v $link_file $HOME/.${FILENAME%.*}
done

cp -r -f $PWD/gnzh.zsh-theme $HOME/.oh-my-zsh/themes/
cp -r -f $PWD/git_diff_wrapper.sh $HOME/git_diff_wrapper.sh
cd $HOME && source $HOME/.zshrc
./.osx
echo "-- Re-configure mac os environment successfully --"
