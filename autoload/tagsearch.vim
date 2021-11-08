" vim-tagsearch.vim - Search for tags across files.
" Maintainer: Chris Davison <https://chrisdavison.github.io>
" Version: 2021-08-03

function! s:make_list(fn, pattern)
    let tags=join(map(split(a:pattern, ' '), {_, val -> '@' . val}), ' ')
    return { 'filename': fnamemodify(a:fn, ':p'), 'text': l:tags,
           \ 'lnum': 1, 'col': 0,
           \ }
endfunction

function! tagsearch#untagged()
    let files=systemlist('tagsearch -u')
    let filedict=map(l:files, {_, val -> <sid>make_list(val, 'untagged')})
    call setloclist(0, l:filedict)
endfunction

function! tagsearch#untagged_fzf()
    call fzf#run({'source': 'tagsearch -u', 'sink': 'e', 'down': '30%'})
endfunction

function! tagsearch#list(tags)
    let files=systemlist('tagsearch ' . a:tags)
    let filedict=map(l:files, {_, val -> <sid>make_list(val, a:tags)})
    call setloclist(0, l:filedict)
endfunction

function! tagsearch#list_fzf(tags)
    call fzf#run({'source': 'tagsearch ' . a:tags, 'sink': 'e', 'down': '30%'})
endfunction

function! tagsearch#knowledge_projects(_arglead, _cmdline, _cursorpos)
    let curdir=getcwd()
    exec "cd " . expand("~/src/github.com/ChrisDavison/knowledge")
    return systemlist('tagsearch project --not archive')
    exec "cd " . l:curdir
endfunction
