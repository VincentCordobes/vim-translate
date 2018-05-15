if exists('g:loaded_translate_plugin')
  finish
endif
let g:loaded_translate_plugin = 1

augroup translate
  autocmd!
  autocmd bufenter * if (winnr("$") == 1 && exists("s:trans_buf")) | q! |  endif
augroup END

function! s:vtranslate(source_target) abort
  if !s:check_executable() | return | endif

  let l:backup = @a
  silent! normal! gv"ay

  let l:cmd = s:translate_shell_cmd() . a:source_target . ' ' . shellescape(@a)
  let l:translation = systemlist(l:cmd)
  let @a = join(l:translation, "\n")
  silent! normal! gv"ap

  let @a = l:backup
endfunction

function! s:translate(source_target) abort
  if !s:check_executable() | return | endif

  call s:translate_clear()

  silent! %y
  botright 8new Translation
  set buftype=nofile
  let s:trans_buf = bufnr('%')
  silent! put!

  exe '%!' . s:translate_shell_cmd() . a:source_target 
  execute('resize ' . line('$'))
  wincmd p
endfunction

function! s:translate_clear() abort
  if exists('s:trans_buf') && bufexists(s:trans_buf)
    sil! exe 'bd! ' . s:trans_buf
  endif
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

function! s:translate_shell_cmd()
  return 'trans -no-ansi -no-auto -no-warn -brief '
endfunction

command! -nargs=? Translate call s:translate(<q-args>)
command! -nargs=? -range VTranslate call s:vtranslate(<q-args>)
command! TranslateClear call s:translate_clear()

