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

autocmd! BufRead,BufNewFile *.svg set filetype=xml

let mapleader=','
map <space>w <C-W><C-W>
map ; :
map Y y$


:highlight ExtraWhitespace ctermbg=red guibg=red

" Show trailing whitespace and spaces before a tab:
:match ExtraWhitespace /\s\+$\| \+\ze\t/


function! SetOptionsByFiletype()
	if &filetype ==# 'text'
		setlocal breakindent lbr
	elseif &filetype ==# 'ocaml'
		setlocal tabstop=2 softtabstop=2 expandtab shiftwidth=2 smarttab
	elseif &filetype ==# 'sh'
		setlocal tabstop=2 softtabstop=2 expandtab shiftwidth=2 smarttab
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
function! FormatCode()
	let line_number = line('.')

	if &filetype ==# 'c' || &filetype ==# 'cpp'
		%!clang-format -assume-filename=% -style=file -fallback-style=google
	elseif &filetype ==# 'go'
		%!goimports
	elseif &filetype ==# 'python'
		%!autopep8 -
	elseif &filetype ==# 'rust'
		%!rustfmt --edition 2018 --emit stdout
	elseif &filetype ==# 'xml'
		%!tidy -xml -indent -quiet
	elseif &filetype ==# 'html'
		%!tidy -indent -quiet --tidy-mark no
	endif

	:call cursor(line_number, 1)
endfunction
command! FormatCode :call FormatCode()
nnoremap F :FormatCode<CR>


" Write as root.
command! WriteSudo w !sudo tee % >/dev/null


" Comment & Uncomment comment/uncomment individual and ranges of lines.
let g:comments = {
	\ 'c':          { 'left': '/*', 'right': '*/' },
	\ 'cpp':        { 'left': '//' },
	\ 'gitconfig':  { 'left': '#' },
	\ 'go':         { 'left': '//' },
	\ 'html':       { 'left': '<!--', 'right': '-->' },
	\ 'javascript': { 'left': '//' },
	\ 'make':       { 'left': '#' },
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
	if has_key(g:comments, &filetype)
		let comment = g:comments[&filetype]

		let line = getline(line_number)
		if has_key(comment, 'left')
			let line = substitute(line, '\(\S\)', comment['left'] . '\ \1', '')
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
