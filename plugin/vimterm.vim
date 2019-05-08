function! s:open_term(command)
	let query = "vert term ".a:command
	execute query
	let g:__term_name = @%
	sleep 100m
    wincmd l
	let b:__term_name = g:__term_name
endfunction

function! s:open_ipython()
	call s:open_term("ipython")
	nnoremap <leader>l :SendLineCpaste<CR>j
	nnoremap <leader>s :SendSelectionCpaste<CR>
	vnoremap <leader>s :SendSelectionCpaste<CR>
	nnoremap <leader>b :SendBlockCpaste<CR>
endfunction

function! s:open_r()
	call s:open_term("R")
	nnoremap <leader>l :SendLine<CR>j
	nnoremap <leader>s :SendSelection<CR>
	vnoremap <leader>s :SendSelection<CR>
	nnoremap <leader>b :SendBlock<CR>
endfunction

function! s:open_bash()
	call s:open_term("bash")
	nnoremap <leader>l :SendLine<CR>j
	nnoremap <leader>s :SendSelection<CR>
	vnoremap <leader>s :SendSelection<CR>
	nnoremap <leader>b :SendBlock<CR>
endfunction

function! s:close_term()
	let b:buffer_no = bufnr(b:__term_name)
	execute 'bdelete! '.b:buffer_no
endfunction

function! s:term_sendlines(lines) range
    call term_sendkeys(b:__term_name, a:lines)
	sleep 100m
endfunction

function! s:get_lineno_for_search(pattern, flags)
    let lineno = searchpos(a:pattern, a:flags)[0]
	return lineno
endfunction

function! s:get_lineno_for_blockstart()
    let lineno = s:get_lineno_for_search("# %%", "bWnc")
	return lineno
endfunction

function! s:get_lineno_for_blockend()
    let lineno = s:get_lineno_for_search("# %%", "Wnc")
	return lineno
endfunction

function! s:get_lines(fline, lline)
    let lines = join(getline(a:fline, a:lline), "\n") . "\r"
	return lines
endfunction

function! s:send_lines() range
	let line = s:get_lines(a:firstline, a:lastline)
	call s:term_sendlines(line)
endfunction

function! s:send_block()
	let line = s:get_lines(s:get_lineno_for_blockstart(), s:get_lineno_for_blockend())
	call s:term_sendlines(line)
endfunction

function! s:send_lines_cpaste() range
	let line = s:get_lines(a:firstline, a:lastline)
	call s:term_sendlines("%cpaste -q\n")
	call s:term_sendlines(line)
	call s:term_sendlines("--\n")
endfunction

function! s:send_block_cpaste()
	let line = s:get_lines(s:get_lineno_for_blockstart(), s:get_lineno_for_blockend())
	call s:term_sendlines("%cpaste -q\n")
	call s:term_sendlines(line)
	call s:term_sendlines("--\n")
endfunction

command! OpenIPython :call s:open_ipython()
command! OpenR :call s:open_r()
command! OpenBash :call s:open_bash()
command! CloseTerm :call s:close_term()
command! SendLine :call s:send_lines()
command! -range SendSelection :<line1>,<line2>call s:send_lines()
command! SendBlock :call s:send_block()
command! SendLineCpaste :call s:send_lines_cpaste()
command! -range SendSelectionCpaste :<line1>,<line2>call s:send_lines_cpaste()
command! SendBlockCpaste :call s:send_block_cpaste()

nnoremap <leader>c :CloseTerm<CR>
nnoremap <leader>p :OpenIPython<CR>
nnoremap <leader>r :OpenR<CR>
nnoremap <leader>t :OpenBash<CR>
