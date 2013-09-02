gem uninstall klipp -x
rbenv rehash
rm klipp-0.0.1.gem
gem build klipp.gemspec
gem install klipp-0.0.1.gem
rbenv rehash