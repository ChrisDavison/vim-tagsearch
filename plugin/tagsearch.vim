" vim-tagsearch.vim - Search for tags across files.
" Maintainer: Chris Davison <https://chrisdavison.github.io>
" Version: 2021-08-03

if exists("g:loaded_vim_tagsearch") || &cp || v:version < 700
    finish
endif
let g:loaded_vim_tagsearch = 1

command! TagsearchUntagged call tagsearch#untagged()
command! TagsearchUntaggedFZF call tagsearch#untagged_fzf()
cnoreabbrev TSU TagsearchUntagged
cnoreabbrev TSUF TagsearchUntaggedF

command! -nargs=+ TagsearchList call tagsearch#list(<q-args>, 0)
command! -nargs=+ TagsearchListFZF call tagsearch#list_fzf(<q-args>, 0)
cnoreabbrev TSL TagsearchList
cnoreabbrev TSLF TagsearchListFZF

command! TagsearchLong call tagsearch#long()
cnoreabbrev TSLO TagsearchLong
