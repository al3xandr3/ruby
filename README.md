collection of my ruby util scripts.

bootstraps with:

	# filename: profile.sh
	export RUBYLIB=~/Dropbox/my/dev/ruby:$RUBYLIB
	
  	# 3rd party libs
	libs=$(find other/ruby -type d | grep 'lib$')
	for d in $libs; do 
	 export RUBYLIB=$d:$RUBYLIB 
	done
