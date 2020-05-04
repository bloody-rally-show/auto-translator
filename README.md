# Auto Translator

A tool developed for generating automatic experimental translations for [Bloody Rally Show](https://store.steampowered.com/app/926860/Bloody_Rally_Show/)

## Usage

1. Install Ruby 2.6.6 from https://rubyinstaller.org/downloads/ (if on Windows)
2. Run `gem install bundler`
3. Run `bundle` to install dependencies
4. Place the file you want to translate into this directory
5. Run `bundle exec ruby translate.rb File.txt` to run the translation tooling
6. It will fail due to auth on first run, so read https://googleapis.dev/ruby/google-cloud-translate/latest/file.AUTHENTICATION.html to setup authentification