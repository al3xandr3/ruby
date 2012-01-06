
collection of my ruby util scripts.

bootstraps with:

	# filename: profile.sh
	# my utils
	export RUBYLIB=/my/proj/ruby:$RUBYLIB
	# 3rd party libs
	libs=$(find /dmg/ruby -type d | grep 'lib$')
	for d in $libs; do 
	 export RUBYLIB=$d:$RUBYLIB 
	done
