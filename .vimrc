set nocompatible
set shell=/bin/sh
set secure
set noswapfile
set viminfo=""
set encoding=utf-8
set backspace=2

syntax off

filetype plugin indent on

" ignore object & binary files.
set wildignore=*.a,*.aux,*.class,*.dll,*.exe,*.hi,*.o,*.obj,*.pdf,*.pyc,*.toc
set wildmode=longest,list,full
set wildmenu


let mapleader=','
map <space>w <C-W><C-W>
map ; :
map Y y$


:highlight ExtraWhitespace ctermbg=red guibg=red

" Show trailing whitespace and spaces before a tab:
:match ExtraWhitespace /\s\+$\| \+\ze\t/


autocmd! BufRead,BufNewFile *.fish setlocal filetype=fish
autocmd! BufRead,BufNewFile *.nix setlocal filetype=nix
autocmd! BufRead,BufNewFile *.svg setlocal filetype=xml
autocmd! BufRead,BufNewFile dune,dune-project,dune-workspace,dune-workspace.* setlocal filetype=dune

let g:options = {
	\ 'fish':  'tabstop=2 softtabstop=2 expandtab shiftwidth=2 smarttab',
	\ 'nix':   'tabstop=2 softtabstop=2 expandtab shiftwidth=2 smarttab',
	\ 'ocaml': 'tabstop=2 softtabstop=2 expandtab shiftwidth=2 smarttab',
	\ 'sh':    'tabstop=2 softtabstop=2 expandtab shiftwidth=2 smarttab',
	\ 'text':  'breakindent lbr',
	\ }
function! SetOptionsByFiletype()
	if has_key(g:options, &filetype)
		execute('setlocal ' . g:options[&filetype])
	endif
endfunction
autocmd! BufRead,BufNewFile * call SetOptionsByFiletype()


" LoadTemplate loads a template from ~/.vim/templates on creating a new file.
" For a file foo.bar:
" - If there is a file ~/.vim/templates/foo.bar, it will load that.
" - If there is a file ~/.vim/templates/bar, it will load that.
" - Otherwise, it does nothing.
function! LoadTemplate()
        if filereadable(expand('~/.vim/templates/' . expand('%')))
                r ~/.vim/templates/%
                :0d
        elseif filereadable(expand('~/.vim/templates/' . expand('%:e')))
                r ~/.vim/templates/%:e
                :0d
		if &filetype ==# 'cs' || &filetype ==# 'java'
                        %s/CLASSNAME/\=expand('%:t:r')/g
		elseif &filetype ==# 'c' || &filetype ==# 'cpp'
                        %s/HEADER/\=toupper(expand('%:t:r'))/g
                endif
        endif
endfunction
autocmd! BufNewFile * call LoadTemplate()


" FormatCode formats the current buffer with an appropriate formatter.
let g:formatters = {
	\ 'c':      'clang-format -assume-filename=% -style=file -fallback-style=google',
	\ 'cpp':    'clang-format -assume-filename=% -style=file -fallback-style=google',
	\ 'dune':   'dune format',
	\ 'go':     'goimports',
	\ 'html':   'tidy -indent -quiet --tidy-mark no',
	\ 'python': 'autopep8 -',
	\ 'rust':   'rustfmt --edition 2018 --emit stdout',
	\ 'xml':    'tidy -indent -quiet -xml',
	\ }
function! FormatCode()
	if has_key(g:formatters, &filetype)
		let line_number = line('.')
		execute('%!' . g:formatters[&filetype])
		call cursor(line_number, 1)
	endif
endfunction
command! FormatCode :call FormatCode()
nnoremap F :FormatCode<CR>


" Write as root.
command! WriteSudo w !sudo tee % >/dev/null


" Comment & Uncomment comment/uncomment individual and ranges of lines.
let g:comments = {
	\ 'c':          { 'left': '/*', 'right': '*/' },
	\ 'cpp':        { 'left': '//' },
	\ 'fish':       { 'left': '#' },
	\ 'gitconfig':  { 'left': '#' },
	\ 'go':         { 'left': '//' },
	\ 'html':       { 'left': '<!--', 'right': '-->' },
	\ 'javascript': { 'left': '//' },
	\ 'make':       { 'left': '#' },
	\ 'nix':        { 'left': '#' },
	\ 'ocaml':      { 'left': '(*', 'right': '*)' },
	\ 'python':     { 'left': '#' },
	\ 'rust':       { 'left': '//' },
	\ 'sh':         { 'left': '#' },
	\ 'tmux':       { 'left': '#' },
	\ 'vim':        { 'left': '"' },
	\ 'xdefaults':  { 'left': '!' },
	\ 'xml':        { 'left': '<!--', 'right': '-->' },
	\ 'yaml':       { 'left': '#' },
	\ }
function! Comment()
	let line_number = line('.')
	let line = getline(line_number)

	if has_key(g:comments, &filetype) && line != ''
		let comment = g:comments[&filetype]

		let line = getline(line_number)
		if has_key(comment, 'left')
			let line = substitute(line, '^\(\s*\)', '\1' . comment['left'] . ' ', '')
		endif
		if has_key(comment, 'right')
			let line = substitute(line, '$', '\ ' . comment['right'], '')
		endif
		call setline(line_number, line)
	endif
endfunction
function! Uncomment()
	let line_number = line('.')
	if has_key(g:comments, &filetype)
		let comment = g:comments[&filetype]

		let line = getline(line_number)
		if has_key(comment, 'left')
			let line = substitute(line, '^\(\s*\)' . escape(comment['left'], '*') . '\ \?', '\1', '')
		endif
		if has_key(comment, 'right')
			let line = substitute(line, '\ \?' . escape(comment['right'], '*') . '$', '', '')
		endif
		call setline(line_number, line)
	endif
endfunction
command! Comment   :call Comment()
command! Uncomment :call Uncomment()
command! -range Comment   <line1>,<line2>call Comment()
command! -range Uncomment <line1>,<line2>call Uncomment()
map <leader>cc :Comment<CR>
map <leader>cu :Uncomment<CR>
