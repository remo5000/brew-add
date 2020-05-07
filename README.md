# Why

https://github.com/Homebrew/brew/issues/3933

https://github.com/Homebrew/brew/issues/3716

```shell
git clone https://github.com/remo5000/brew-add.git
cp brew-add/brew-add.rb /usr/local/bin/
```

# Why not use a shell script??

Knock yourself out:

```zsh
brew() {
  case $1 in
    add)
      shift
      for formula in "$@"
      do
        echo "Adding $formula to Brewfile"
        if ! grep -q "\"$formula\"" ~/Brewfile; then
          echo "brew \"$formula\"" >> ~/Brewfile;
        fi
      done
      echo "Installing..."
      brew bundle install --file ~/Brewfile;
      ;;
    *)
      command brew "$@";;
  esac
}
```
