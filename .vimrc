set encoding=utf-8
set nocompatible
set noswapfile
set secure
set shell=/bin/sh

set backspace=2   " Make backspace work in Insert mode (see `:help 'backspace'`).
set laststatus=2  " Always show the statusbar.
set ruler         " Show the line & character in the status bar.
set scrolloff=1   " Try to have one line of context when scrolling.
set title         " Set the terminal-emulator tab title.

set ignorecase
set smartcase

syntax off
filetype plugin indent on


" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
	runtime! macros/matchit.vim
endif


" Ignore object & binary files.
set wildignore=*.a,*.aux,*.class,*.dll,*.exe,*.hi,*.o,*.obj,*.pdf,*.pyc,*.toc
set wildmode=longest,list,full
set wildmenu


" I find `,` easier to press than `\`.
let mapleader = ','

" Window movement with less "Emacs pinky".
map <space>w <C-W><C-W>

" #1 best quality-of-life improvement in the entire config.
map ; :

" Make `Y` behave like `D`.
map Y y$

" Yank / Paste / Delete, but with the system clipboard.
map <leader>y "+y
map <leader>p "+p
map <leader>d "+d
map <leader>Y "+Y
map <leader>P "+P
map <leader>D "+D


" Enable the manpage viewer, via `:Man <name>`.
runtime ftplugin/man.vim
let g:ft_man_open_mode = 'vert'


" Write as root.
command! WriteSudo w !sudo tee % >/dev/null


" Show trailing whitespace and spaces before a tab.
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$\| \+\ze\t/


augroup set-filetype
	autocmd!
	autocmd BufRead,BufNewFile *.fish   setlocal filetype=fish
	autocmd BufRead,BufNewFile *.litmus setlocal filetype=litmus
	autocmd BufRead,BufNewFile *.nix    setlocal filetype=nix
	autocmd BufRead,BufNewFile *.scad   setlocal filetype=scad
	autocmd BufRead,BufNewFile *.svg    setlocal filetype=xml
	autocmd BufRead,BufNewFile *.swift  setlocal filetype=swift

	autocmd BufRead,BufNewFile */.ssh/config*     setlocal filetype=sshconfig
	autocmd BufRead,BufNewFile .Brewfile,Brewfile setlocal filetype=ruby
	autocmd BufRead,BufNewFile dune,dune-project,dune-workspace,dune-workspace.* setlocal filetype=dune
augroup end

function s:TabsAreSpaces(width)
	let options = [
		\ 'expandtab',
		\ 'smarttab',
		\ 'shiftwidth='  . a:width,
		\ 'softtabstop=' . a:width,
		\ 'tabstop='     . a:width,
		\ ]
	execute('setlocal ' . join(options, ' '))
endfunction
augroup settings-by-filetype
	autocmd!
	autocmd FileType fish      :call s:TabsAreSpaces(4)
	autocmd FileType gitcommit :call s:TabsAreSpaces(2)
	autocmd FileType html      :call s:TabsAreSpaces(2)
	autocmd FileType nix       :call s:TabsAreSpaces(2)
	autocmd FileType ocaml     :call s:TabsAreSpaces(2)
	autocmd FileType scad      :call s:TabsAreSpaces(4)
	autocmd FileType sh        :call s:TabsAreSpaces(2)

	autocmd FileType text      setlocal breakindent lbr
	autocmd FileType markdown  setlocal breakindent lbr

	autocmd FileType litmus     setlocal commentstring=(*%s*)
	autocmd FileType fish       setlocal commentstring=#\ %s
	autocmd FileType nix        setlocal commentstring=#\ %s
	autocmd FileType scad       setlocal commentstring=//\ %s
	autocmd FileType swift      setlocal commentstring=//\ %s
	autocmd FileType xdefaults  setlocal commentstring=!\ %s
augroup end

augroup sigwinch-resize
	autocmd!
	autocmd VimResized * wincmd =
	autocmd WinNew     * wincmd =
augroup end


" MaybeDetectFiletype attempts to detect filetype of buffers with shebangs.
function s:MaybeDetectFiletype()
	if &filetype
		return
	endif
	if getline(1) =~# '^#!/'
		if getline(1) =~# '^#!/usr/bin/env swift \?'
			setlocal filetype=swift
		else
			filetype detect
		endif
	endif
endfunction
augroup filetype-detect
	autocmd!
	autocmd SafeState * :call s:MaybeDetectFiletype()
augroup end


" MaybeMkdir asks to create the parent directories of new files if needed.
function s:MaybeMkdir(path)
	if isdirectory(a:path)
		return
	endif

	if confirm('Create directory ' . a:path . ' ?', "&Yes\n&No", 2) == 1
		call mkdir(a:path, 'p')
	endif
endfunction
augroup mkdir
	autocmd!
	autocmd BufWritePre * :call s:MaybeMkdir(expand('<afile>:p:h'))
augroup end


" MaybeAutoread is like `:help autoread`, but only for minor changes.
function s:MaybeAutoread(path, reason)
	if a:reason ==# 'mode' || a:reason ==# 'time'
		let v:fcs_choice = 'reload'
	else
		let v:fcs_choice = 'ask'
	endif
endfunction
augroup autoread
	autocmd!
	autocmd FileChangedShell * :call s:MaybeAutoread(expand('<afile>:p'), v:fcs_reason)
augroup end


" LoadTemplate loads a template into the current buffer.
function s:LoadTemplate(path)
	execute('r ' . a:path)
	:0d

	%s/DIRNAME/\=expand('%:p:h:t')/ge
	%s/FILENAME_ALLCAPS/\=toupper(expand('%:t:r'))/ge
	%s/FILENAME/\=expand('%:t:r')/ge

	if search('CURSOR') != 0
		let [line, column] = searchpos('CURSOR')
		call setline(line, substitute(getline(line), 'CURSOR', '', ''))
		call cursor(line, column)
		" TODO: maybe enable this?
		" startinsert!
	endif
endfunction
function s:LoadTemplateByFilename(filename)
	let template_dirs = split(get(environ(), 'VIM_TEMPLATES', ''), ':') + [ '~/.vim/templates' ]
	for dir in template_dirs
		" The expand() is required to expand characters like `~`.
		let fullname = expand(dir . '/' . a:filename)
		let extension = expand(dir . '/' . fnamemodify(a:filename, ':e'))
		if filereadable(fullname)
			call s:LoadTemplate(fullname)
			return
		elseif filereadable(extension)
			call s:LoadTemplate(extension)
			return
		endif
	endfor
endfunction
augroup load-template
	autocmd!
	autocmd BufNewFile * call s:LoadTemplateByFilename(expand('<afile>:p:t'))
augroup end


" FormatCode formats the current buffer with an appropriate formatter.
function s:FormatCode()
	let cursor_state = winsaveview()
	execute('%! format --filetype=' . &filetype . ' --filename=%')
	call winrestview(cursor_state)
endfunction
command! FormatCode :call s:FormatCode()
nnoremap F :FormatCode<CR>


" Delete comment character when joining commented lines.
set formatoptions+=j

" Comment & Uncomment comment/uncomment individual and ranges of lines.
" See `:help commentstring` and `:help comments`.
function s:CommentsFromCommentString()
	let left  = substitute(&commentstring, '^\([^ \t]*\)\s*%s.*$', '\1', '')
	let right = substitute(&commentstring, '^.*%s\s*\(.*\)$', '\1', '')
	return [left, right]
endfunction
function s:Comment()
	let line_number = line('.')
	let line = getline(line_number)
	if line ==# ''
		return
	endif

	let [left, right] = s:CommentsFromCommentString()
	if left !=# ''
		let line = substitute(line, '^\(\s*\)', '\1' . left . ' ', '')
	endif
	if right !=# ''
		let line = substitute(line, '$', '\ ' . right, '')
	endif

	call setline(line_number, line)
endfunction
function s:Uncomment()
	let line_number = line('.')
	let line = getline(line_number)
	if line ==# ''
		return
	endif

	let [left, right] = s:CommentsFromCommentString()
	if left !=# ''
		let line = substitute(line, '^\(\s*\)' . escape(left, '*') . '\ \?', '\1', '')
	endif
	if right !=# ''
		let line = substitute(line, '\ \?' . escape(right, '*') . '$', '', '')
	endif

	call setline(line_number, line)
endfunction
command! Comment   :call s:Comment()
command! Uncomment :call s:Uncomment()
command! -range Comment   <line1>,<line2>call s:Comment()
command! -range Uncomment <line1>,<line2>call s:Uncomment()
map <leader>cc :Comment<CR>
map <leader>cu :Uncomment<CR>
