if exists('g:loaded_translate_plugin')
  finish
endif
let g:loaded_translate_plugin = 1

let s:base_cmd = 'trans -no-ansi -no-auto -no-warn -brief'

function! s:translate(source_target) abort
  if !s:check_executable() | return | endif

  call s:translate_clear()

  silent! %y
  call s:new_trans_buf()
  silent! put!

  exe '%!' . s:base_cmd . ' ' . a:source_target 
  execute('resize ' . line('$'))
  wincmd p
endfunction

function! s:translate_visual(source_target) abort
  if !s:check_executable() | return | endif

  call s:translate_clear()

  let l:backup = @a

  silent! normal! gv"ay
  call s:new_trans_buf()
  silent! normal! "aP

  exe '%!' . s:base_cmd . ' ' . a:source_target 
  execute('resize ' . line('$'))
  wincmd p

  silent! normal! gv
  let @a = l:backup
endfunction

function! s:translate_replace(source_target) abort
  if !s:check_executable() | return | endif

  let l:backup = @a
  silent! normal! gv"ay

  let l:cmd = s:base_cmd . ' ' . a:source_target
  let @a = system(l:cmd, @a)[:-2]
  
  silent! normal! gv"ap

  let @a = l:backup
endfunction

function! s:translate_clear() abort
  if exists('s:trans_buf') && bufexists(s:trans_buf)
    sil! exe 'bd! ' . s:trans_buf
    unlet s:trans_buf
  endif
endfunction

function! s:new_trans_buf() abort
  silent! botright 8new Translation
  set buftype=nofile
  set bufhidden=hide
  set noswapfile
  let s:trans_buf = bufnr('%')
endfunction

function! s:msg_error(str) abort
  echohl ErrorMsg 
  echo a:str
  echohl None
endfunction

function! s:check_executable() abort
  if !executable('trans')
    call s:msg_error('translate-shell not found. Please install it.')
    return 0
  endif

  return 1
endfunction

function! s:is_trans_buf_open() abort
  return exists('s:trans_buf') && bufnr('%') == s:trans_buf
endfunction

augroup translate
  autocmd!
  autocmd bufenter * if (winnr("$") == 1 && s:is_trans_buf_open()) | q! | endif
augroup END

command! -nargs=? Translate call s:translate(<q-args>)
command! -nargs=? -range TranslateVisual call s:translate_visual(<q-args>)
command! -nargs=? -range TranslateReplace call s:translate_replace(<q-args>)
command! TranslateClear call s:translate_clear()
