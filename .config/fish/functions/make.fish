function make --description 'ascend the filesystem, looking for Makefiles'
	set -l previous_dir (pwd)

	while ! [ -f 'Makefile' -o -f 'makefile' -o (pwd) = $HOME -o (pwd) = '/' ]
		cd ..
	end

	pwd
	command make $argv

	cd $previous_dir
end
