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


" Show trailing whitespace and spaces before a tab:
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$\| \+\ze\t/


augroup set-filetype
	autocmd!
	autocmd BufRead,BufNewFile *.fish setlocal filetype=fish
	autocmd BufRead,BufNewFile *.nix  setlocal filetype=nix
	autocmd BufRead,BufNewFile *.svg  setlocal filetype=xml
	autocmd BufRead,BufNewFile dune,dune-project,dune-workspace,dune-workspace.* setlocal filetype=dune
augroup end

augroup settings-by-filetype
	autocmd!
	autocmd FileType fish   setlocal tabstop=2 softtabstop=2 expandtab shiftwidth=2 smarttab
	autocmd FileType nix    setlocal tabstop=2 softtabstop=2 expandtab shiftwidth=2 smarttab
	autocmd FileType ocaml  setlocal tabstop=2 softtabstop=2 expandtab shiftwidth=2 smarttab
	autocmd FileType sh     setlocal tabstop=2 softtabstop=2 expandtab shiftwidth=2 smarttab
	autocmd FileType text   setlocal breakindent lbr
augroup end


" LoadTemplate loads a template from ~/.vim/templates on creating a new file.
" For a file foo.bar:
" - If there is a file ~/.vim/templates/foo.bar, it will load that.
" - If there is a file ~/.vim/templates/bar, it will load that.
" - Otherwise, it does nothing.
function s:LoadTemplate()
	let template_dirs = split(get(environ(), 'VIM_TEMPLATES', ''), ':') + [ '~/.vim/templates' ]

	function ReadTemplate(path)
		execute('r ' . a:path)
		:0d

		if search('HEADER') != 0
			%s/HEADER/\=toupper(expand('%:t:r'))/g
		endif
		if search('CLASSNAME') != 0
			%s/CLASSNAME/\=expand('%:t:r')/g
		endif

		if search('CURSOR') != 0
			let [line, column] = searchpos('CURSOR')
			call setline(line, substitute(getline(line), 'CURSOR', '', ''))
			call cursor(line, column)
			" TODO: maybe enable this?
			" startinsert!
		endif
	endfunction

	for dir in template_dirs
		if filereadable(expand(dir . '/' . expand('%')))
			call ReadTemplate(dir . '/' . expand('%'))
			return
		elseif filereadable(expand(dir . '/' . expand('%:e')))
			call ReadTemplate(dir . '/' . expand('%:e'))
			return
		endif
	endfor
endfunction
autocmd BufNewFile * call s:LoadTemplate()


" FormatCode formats the current buffer with an appropriate formatter.
let s:formatters = {
	\ 'c':      'clang-format -assume-filename=% -style=file -fallback-style=google',
	\ 'cpp':    'clang-format -assume-filename=% -style=file -fallback-style=google',
	\ 'dune':   'dune format',
	\ 'go':     'goimports',
	\ 'html':   'tidy -indent -quiet --tidy-mark no',
	\ 'python': 'autopep8 -',
	\ 'rust':   'rustfmt --edition 2018 --emit stdout',
	\ 'xml':    'tidy -indent -quiet -xml',
	\ }
function s:FormatCode()
	if has_key(s:formatters, &filetype)
		let line_number = line('.')
		execute('%!' . s:formatters[&filetype])
		call cursor(line_number, 1)
	endif
endfunction
command! FormatCode :call s:FormatCode()
nnoremap F :FormatCode<CR>


" Write as root.
command! WriteSudo w !sudo tee % >/dev/null


" Comment & Uncomment comment/uncomment individual and ranges of lines.
let s:comments = {
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
function s:Comment()
	let line_number = line('.')
	let line = getline(line_number)

	if has_key(s:comments, &filetype) && line != ''
		let comment = s:comments[&filetype]

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
function s:Uncomment()
	let line_number = line('.')
	if has_key(s:comments, &filetype)
		let comment = s:comments[&filetype]

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
command! Comment   :call s:Comment()
command! Uncomment :call s:Uncomment()
command! -range Comment   <line1>,<line2>call s:Comment()
command! -range Uncomment <line1>,<line2>call s:Uncomment()
map <leader>cc :Comment<CR>
map <leader>cu :Uncomment<CR>
