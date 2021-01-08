function fish_title --description 'Set the terminal title'
  # fish_title is called before & after a command is executed or foregrounded.

  # If there are no arguments, the current command is probably fish itself.
  # Otherwise print the full commandline.

  if [ (count $argv) -eq 0 ]
    echo (status current-command) (prompt_pwd)
  else
    echo $argv
  end
end
