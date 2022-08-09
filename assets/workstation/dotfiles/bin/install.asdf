#! /bin/bash
echo "###############################################"
echo "ASDF"
echo "###############################################"

mkdir -p "$HOME/code/util"
pushd "$HOME/code/util"

rm -fr asdf

git clone https://github.com/asdf-vm/asdf

echo "###############################################"
echo "install languages"
echo "###############################################"

pushd ~/code/util/asdf
  git checkout "$(git describe --abbrev=0 --tags)"
popd
ln -sf "$HOME/code/util/asdf" "$HOME/.asdf"

source ~/.zprofile

pushd "$HOME"

. $HOME/.asdf/asdf.sh

asdf plugin add ruby
asdf plugin add elixir
asdf plugin add nodejs
asdf plugin add rust
asdf plugin add python
bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'

# zlib directories need to be present ahead of time in order for asdf to
# install new versions of ruby
sudo mkdir -p /usr/local/opt/zlib/lib
asdf install ruby latest
asdf install elixir latest
asdf install nodejs latest
asdf install rust latest
asdf install python latest
asdf install python 2.7.13

asdf global ruby latest
asdf global elixir latest
asdf global nodejs latest
asdf global rust latest
asdf global python 2.7.13 latest

popd
