#!/bin/zsh

for link_file ($PWD/*.symlink); do
    FILENAME=${link_file##*/}
    ln -s -i -v $link_file $HOME/.${FILENAME%.*}
done

cp -r -f $PWD/gnzh.zsh-theme $HOME/.oh-my-zsh/themes/
cd $HOME && source $HOME/.zshrc
./.osx

echo "-- Install coreutils"
wget http://ftp.gnu.org/gnu/coreutils/coreutils-8.21.tar.xz
tar xvJf coreutils-8.21.tar.xz
cd coreutils-8.21
wget http://zwicke.org/web/advcopy/advcpmv-0.5-8.21.patch
patch -p1 -i advcpmv-0.5-8.21.patch$ ./configure$ make
sudo cp src/cp /bin/cp
sudo cp src/mv /bin/mv

echo "-- Re-configure mac os environment successfully --"
