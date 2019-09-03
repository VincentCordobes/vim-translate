if exists('g:loaded_translate_plugin')
  finish
endif
let g:loaded_translate_plugin = 1

command! -nargs=* Translate call translate#run(<q-args>)
command! -nargs=* -range TranslateVisual call translate#visual(<q-args>)
command! -nargs=* -range TranslateReplace call translate#replace(<q-args>)
command! TranslateOpen call translate#open_trans_buf('')
command! TranslateClear call translate#clear_trans_buf()

nnoremap <silent> <Plug>TranslateText :set operatorfunc=translate#wrap_operator_show<cr>g@
nnoremap <silent> <Plug>TranslateReplaceText :set operatorfunc=translate#wrap_operator_replace<cr>g@
