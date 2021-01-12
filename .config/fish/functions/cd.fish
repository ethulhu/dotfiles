function cd --argument-names path
  if [ ! $path ]
    __builtin_cd ~
  else if [ -f $path ]
    __builtin_cd (dirname $path)
  else
    __builtin_cd $path
  end
end
