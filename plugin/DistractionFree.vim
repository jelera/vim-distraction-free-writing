" DistrationFree.vim  -- Toggle distraction free writing mode
"      Maintainer: Jose Elera (https://github.com/jelera)
" Original Author: Lakshan Perera (lakshan AT web2media net)
"             URL: https://github.com/laktek/distraction-free-writing-vim
"     Last Update: Mon 09 Dec 2013 12:35:40 AM CST
"
" TODO: Add support for terminal Vim
"
" Copy this file to .vim/plugin.
"
" In .vimrc, specify the colorschemes and fonts to use
" in fullscreen mode and normal mode.
"
" g:fullscreen_colorscheme - colorscheme to use in fullscreen mode
" g:fullscreen_font font to use in fullscreen mode
" g:normal_colorscheme - colorscheme to use in normal mode
" g:normal_font - font to use in normal mode
" eg: let g:fullscreen_colorscheme = "iawriter"
"
" By default, toggling of full screen mode is bound to F4 key.
" You can change it in .vimrc as follows:
" :map <F4> :call ToggleDistractionFreeWriting()<CR>

"initVariable borrowed from NERDTree

function! s:initVariable(var, value)
	if !exists(a:var)
		exec 'let ' . a:var . ' = ' . "'" . a:value . "'"
		return 1
	endif
	return 0
endfunction

"Initialize variables
call s:initVariable("g:distractionFreeFullscreen", "off")

function! DistractionFreeWriting()

	" If vim-airline and bufferline is installed then toggle it
	if exists('g:airline_theme')
		exec "AirlineToggle"
	endif
	if exists('g:bufferline_echo')
		let g:bufferline_echo = 0
	endif

	function! WordCount()
		let s:old_status = v:statusmsg
		let position = getpos(".")
		exe ":silent normal g\<C-g>"
		let stat = v:statusmsg
		let s:word_count = 0
		if stat != '--No lines in buffer--'
			let s:word_count = str2nr(split(v:statusmsg)[11])
			let v:statusmsg = s:old_status
		end
		call setpos('.', position)
		return s:word_count
	endfunction

	set statusline=%<\ %t\ %m%r%=%-14.(%{WordCount()}\ words\ \ %L\ lines\ \ \ \ %l,%c%)\ \ %p%%

	exec "colorscheme ".g:fullscreen_colorscheme
	" added escape function to allow for multiword font names
	" (AmaruCoder)
	exec "set gfn=".escape(g:fullscreen_font,' ')

	set background=light
	set lines=40 columns=90 " size of the editable area
	set linespace=5         " spacing between lines
	set guioptions-=r       " remove righ scrollbar
	set noruler             " don't show ruler
	set colorcolumn=300     " set the column away from the viewport
	if has("gui_macvim")
		set fuoptions=background:#00f5f6f6 " bakground color
		set fullscreen
	else
		set guioptions-=m   " remove menu
		set guioptions-=T   " remove Toolbar
	endif
	let g:distractionFreeFullscreen = 'on'
	set linebreak  " break the lines on words
endfunction

function! ToggleDistractionFreeWriting()
	if g:distractionFreeFullscreen == 'on'
		exec "set background=".s:prev_background
		exec "set lines=".s:prev_lines
		exec "set columns=".s:prev_columns
		exec "set linespace=".s:prev_linespace
		exec "set laststatus=".s:prev_laststatus
		exec "set colorcolumn=".s:prev_colorcolumn
		exec "set guioptions+=r"

		set noruler!
		if has("gui_macvim")
			exec "set fuoptions=".s:prev_fuoptions
			set fullscreen!
		else
			set guioptions+=m  " add menu
		endif
		let g:distractionFreeFullscreen = 'off'
		set linebreak!

		exec "colorscheme ".g:normal_colorscheme
		" added escape function to allow for multiword font names
		" (AmaruCoder)
		exec "set gfn=".escape(g:normal_font,' ')
	else
		let s:prev_background = &background
		let s:prev_gfn = &gfn
		let s:prev_lines = &lines
		let s:prev_columns = &columns
		let s:prev_linespace = &linespace
		let s:prev_colorcolumn = &colorcolumn
		if has("gui_macvim")
			let s:prev_fuoptions = &fuoptions
		endif
		let s:prev_laststatus = &laststatus
		let s:prev_font = &gfn

		call DistractionFreeWriting()

	endif
endfunction

if !exists('g:fullscreen_colorscheme')
	let g:fullscreen_colorscheme = "iawriter"
endif

if !exists('g:fullscreen_font')
	if has("gui_macvim")
		let g:fullscreen_font = "Cousine:h15"
	else
		let g:fullscreen_font = "Cousine 12"
	endif
endif

if !exists('g:normal_colorscheme')
	if has("gui_macvim")
		let g:normal_colorscheme = "Hybrid"
	else
		let g:normal_colorscheme = g:colors_name
	end
endif

if !exists('g:normal_font')
	if has("gui_macvim")
		let g:normal_font="Meslo\ LG\ \L\ DZ\ for\ Powerline\:h14"
	else
		let g:normal_font=&guifont
	endif
endif

map <Leader>df :call ToggleDistractionFreeWriting()<CR>

" turn-on distraction free writing mode by default for markdown files
" au BufNewFile,BufRead *.{md,mdown,mkd,mkdn,markdown,mdwn} call DistractionFreeWriting()
