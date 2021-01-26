set --local function_name (basename (status filename) .fish)

function $function_name --description 'Subcommands and documentation for a given OCaml binary that uses the Cmdliner library'
    command $argv --help=groff 2>/dev/null \
        | expand_groff_ascii_sequences \
        | sed -n \
            -e '/^.TP 4$/d' \
            -e '/^.SH COMMANDS$/,/^.SH / { N; s%^\\\\\fB\([^,= ]*\)\\\\fR.*\n\(.*\)%\1'(echo -e '\t')'\2%p; }' \
        | string replace --regex '\.( [A-Z\\\\].*|$)' '' \
        | string replace --regex --all '\\\\f.' ''
end
