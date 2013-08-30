gem uninstall klipp
rbenv rehash
rm klipp-0.0.1.gem
gem build klipp.gemspec
gem install klipp-0.0.1.gem
rbenv rehash