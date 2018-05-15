vim-translate [![Build Status](https://travis-ci.org/VincentCordobes/vim-translate.svg?branch=master)](https://travis-ci.org/VincentCordobes/vim-translate)
=============

🌎 A tiny [translate-shell](https://github.com/soimort/translate-shell) wrapper for Vim.

<p align="center">
<img  width="600" src="https://user-images.githubusercontent.com/7091110/39960996-7012d8fa-562d-11e8-9216-b604d43ad284.gif"></img>
</p>


Installation
------------

Use your favorite plugin manager.

- [vim-plug](https://github.com/junegunn/vim-plug)
  1. Add `Plug 'VincentCordobes/vim-translate'` to .vimrc
  2. Run `:PlugInstall`
  
Make sure you've installed [translate-shell](https://github.com/soimort/translate-shell)

Usage
-----

- `:Translate en:fr`
    - translate **english → french** (see [here](https://github.com/soimort/translate-shell#code-list) for code list) and put translation in a buffer
    
- `:'<,'>TranslateReplace en:fr`
    - translate **english → french** and replace the selection
    
- `:TranslateClear`
    - Quit the translation buffer


License
-------

MIT
