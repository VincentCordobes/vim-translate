if exists('g:loaded_translate_plugin')
  finish
endif
let g:loaded_translate_plugin = 1

augroup translate
  autocmd!
  autocmd bufenter * if (winnr("$") == 1 && exists("g:trans_buf")) | q! |  endif
augroup END

function! s:translate(source_target) abort
  if !executable('trans')
    call s:msg_error('translate-shell not found. Please install it.')
    return
  endif 

  call s:translate_clear()

  silent! %y
  botright 8new
  let g:trans_buf = bufnr('%')
  silent! put!

  let l:cmd = '%!trans '
        \ . '-no-ansi '
        \ . '-no-auto '
        \ . '-no-warn '
        \ . '-brief '
        \ . a:source_target 
  exe l:cmd
  execute('resize ' . line('$'))
  wincmd p
endfunction

function! s:translate_clear() abort
  if exists('g:trans_buf') && bufexists(g:trans_buf)
    sil! exe 'bd! ' . g:trans_buf
  endif
endfunction

function! s:msg_error(str) abort
  echohl ErrorMsg 
  echo a:str
  echohl None
endfunction

command! -nargs=? Translate call s:translate(<q-args>)
command! TranslateClear call s:translate_clear()
