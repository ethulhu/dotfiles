function cd --wraps cd --argument-names path
  if [ ! $path ]
    builtin cd ~
  else if [ -f $path ]
    builtin cd (dirname $path)
  else
    builtin cd $path
  end
end
