if exists('g:loaded_translate_plugin')
  finish
endif
let g:loaded_translate_plugin = 1

" This is public api and will refactor using autoload later 
" -> prefix with translate#
let s:default_options   = get(g:, 'translate#default_options', '-no-ansi -no-auto -no-warn -brief')
let s:default_languages = get(g:, 'translate#default_languages', {})

let s:base_cmd = 'trans ' . s:default_options

function! s:translate(source_target) abort
  if !s:check_executable() | return | endif

  let l:backup = @a
  silent! %yank a

  let l:translation = s:run_translate(a:source_target, @a)
  call s:new_trans_buf(l:translation)

  let @a = l:backup
endfunction

function! s:translate_visual(source_target) range
  if !s:check_executable() | return | endif

  let l:backup = @a
  silent! normal! gv"ay

  let l:translation = s:run_translate(a:source_target, @a)
  call s:new_trans_buf(l:translation)

  let @a = l:backup
endfunction

function! s:translate_replace(source_target) range
  if !s:check_executable() | return | endif

  let l:backup = @a
  silent! normal! gv"ay

  let @a = s:run_translate(a:source_target, @a)

  silent! normal! gv"ap

  let @a = l:backup
endfunction

function! s:run_translate(source_target, text) abort
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

function! s:translate_clear() abort
  if exists('s:trans_buf') && bufexists(s:trans_buf)
    sil! exe 'bd! ' . s:trans_buf
    unlet s:trans_buf
  endif
endfunction

function! s:new_trans_buf(text) abort
  let l:winnr = winnr()
  call s:translate_clear()
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


" Commands {{{
command! -nargs=* Translate call s:translate(<q-args>)
command! -nargs=* -range TranslateVisual call s:translate_visual(<q-args>)
command! -nargs=* -range TranslateReplace call s:translate_replace(<q-args>)
command! TranslateClear call s:translate_clear()
" }}}
