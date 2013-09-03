gem uninstall klipp -x
rbenv rehash
rm klipp-*
gem build klipp.gemspec
gem install klipp-*
rbenv rehash