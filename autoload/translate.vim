let s:default_options   = get(g:, 'translate#default_options', '-no-ansi -no-auto -no-warn -brief')
let s:default_languages = get(g:, 'translate#default_languages', {})

let s:base_cmd = 'trans ' . s:default_options
let s:is_win = has('win32') || has('win64')

" {{{ Exposed

function! translate#run(source_target) abort
  if !s:check_executable() | return | endif

  let l:regtype = getregtype('a')
  let l:regtext = getreg('a')
  silent! %yank a

  let l:translation = s:translate(a:source_target, @a)
  call translate#open_trans_buf(l:translation)

  call setreg('a', l:regtext, l:regtype)
endfunction

function! translate#visual(source_target) range abort
  if !s:check_executable() | return | endif

  let l:regtype = getregtype('a')
  let l:regtext = getreg('a')
  silent! normal! gv"ay

  let l:translation = s:translate(a:source_target, @a)
  call translate#open_trans_buf(l:translation)

  call setreg('a', l:regtext, l:regtype)
endfunction

function! translate#replace(source_target) range abort
  if !s:check_executable() | return | endif

  let l:regtype = getregtype('a')
  let l:regtext = getreg('a')
  silent! normal! gv"ay

  let @a = s:translate(a:source_target, @a)

  silent! normal! gv"ap

  call setreg('a', l:regtext, l:regtype)
endfunction

function! translate#replace_operator(type) abort
    call translate#operator(a:type, 1)
endfunction

function! translate#operator(type, ...) abort
  if !s:check_executable() | return | endif

  let l:replace = get(a:, 1, 0)
  let l:regtype = getregtype('a')
  let l:regtext = getreg('a')

  if a:type ==# 'char'
    silent! normal! `[v`]"ay
  elseif a:type ==# 'line'
    silent! normal! '[V']"ay
  else
    " Forget about blockwise selection for now
    return
  endif

  let @a = s:translate('', @a)
  if l:replace !=# ''
    silent! normal! gv"ap
  else
    call translate#open_trans_buf(@a)
  endif

  call setreg('a', l:regtext, l:regtype)
endfunction

function! translate#open_trans_buf(text) abort
  let l:winnr = winnr()
  call translate#clear_trans_buf()
  silent! botright 8new Translation
  set buftype=nofile
  set bufhidden=hide
  set noswapfile
  let s:trans_buf = bufnr('%')

  let @a = a:text
  silent! put! a
  execute('resize ' . line('$'))
  silent! normal! gg

  if (l:winnr != winnr())
    wincmd p
  endif
endfunction

function! translate#clear_trans_buf() abort
  if exists('s:trans_buf') && bufexists(s:trans_buf)
    sil! exe 'bd! ' . s:trans_buf
    unlet s:trans_buf
  endif
endfunction

"}}}

"{{{ Helpers

function! s:translate(source_target, text) abort
  echo 'Translating...'
  let l:source_target = s:get_source_target(a:text, a:source_target)

  redraw | echo 'Translating ' . l:source_target . '...'
  let l:cmd = s:base_cmd . ' ' . l:source_target
  let l:result = system(l:cmd, a:text)[:-2]

  redraw | echo ''
  return l:result
endfunction

function! s:get_source_target(text, source_target) abort
  if (a:source_target !=# '') 
    return a:source_target
  endif

  let l:source_lang = system(s:base_cmd .' -id ' . shellescape(a:text))[:-2]
  if (!has_key(s:default_languages, l:source_lang)) 
    return '' 
  endif

  let l:target_lang = s:default_languages[l:source_lang]
  return l:source_lang . ':' . l:target_lang
endfunction

function! s:msg_error(str) abort
  echohl ErrorMsg 
  echo a:str
  echohl None
endfunction

function! s:check_executable() abort
  " translate-shell works on windows via WSL or cygwin
  " Thus we must set vim shell accordingly.
  " However executable() doesn't seem to check to right $PATH 
  " So bypassing that check on windows for now
  if s:is_win
    return 1
  endif

  if !executable('trans')
    call s:msg_error('translate-shell not found. Please install it.')
    return 0
  endif

  return 1
endfunction

function! s:is_trans_buf_open() abort
  return exists('s:trans_buf') && bufnr('%') == s:trans_buf
endfunction

"}}}

augroup translate
  autocmd!
  autocmd bufenter * if (winnr("$") == 1 && s:is_trans_buf_open()) | q! | endif
augroup END
