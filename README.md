vim-translate [![Build Status](https://travis-ci.org/VincentCordobes/vim-translate.svg?branch=master)](https://travis-ci.org/VincentCordobes/vim-translate)
=============

🌎 A tiny [translate-shell](https://github.com/soimort/translate-shell) wrapper for Vim.

<p align="center">
<img  width="600" src="https://user-images.githubusercontent.com/7091110/39960996-7012d8fa-562d-11e8-9216-b604d43ad284.gif"></img>
</p>


Installation
------------

Use your favorite plugin manager.
Example with [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'VincentCordobes/vim-translate'
```
  
Make sure you've installed [translate-shell](https://github.com/soimort/translate-shell)

Usage
-----

Translate the whole buffer and put it in a scratch buffer
- `:Translate [options] [source]:[targets]`

Translate a visual selection and put it in a scratch buffer
- `:'<,'>TranslateVisual [options] [source]:[targets]`

Translate and replace a visual selection
- `:'<,'>TranslateReplace [options] [source]:[targets]`

Quit the translation buffer
- `:TranslateClear`

See [here](https://github.com/soimort/translate-shell#usage) to know more about _options_



For convenience, you can create custom key mappings:

```vim
nnoremap <silent> <leader>t :Translate<CR>
vnoremap <silent> <leader>t :TranslateVisual<CR>
```

Configuration
-------------

#### g:translate#default_languages

A dictionary of defaults **source → target**

```vim
let g:translate#default_languages = {
      \ 'fr': 'en',
      \ 'en': 'fr'
      \ }
```


License
-------

MIT
