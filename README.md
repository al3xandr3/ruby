
collection of my ruby util scripts.

bootstraps with:

	# filename: profile.sh
	# other libs full source
	libs=$(find /dmg/ruby -type d | grep 'lib$')
	for d in $libs; do 
	 export RUBYLIB=$d:$RUBYLIB 
	done
	# my utils
	export RUBYLIB=/my/proj/ruby:$RUBYLIB