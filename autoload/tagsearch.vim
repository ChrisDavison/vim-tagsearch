" vim-tagsearch.vim - Search for tags across files.
" Maintainer: Chris Davison <https://chrisdavison.github.io>
" Version: 2021-08-03

function! s:fzf(source, sink) abort
    call fzf#run(fzf#wrap({
                \ 'source': a:source, 
                \ 'sink': a:sink, 
                \ 'window': {'width': 1.0, 'height': 0.3, 'relative': v:false, 'yoffset': 0.0},
                \ 'preview': ['right:50%:hidden', 'ctrl-/'],
                \ }))
endfunction

function! s:make_list(fn, pattern) abort
    let tags=join(map(split(a:pattern, ' '), {_, val -> '@' . val}), ' ')
    return { 'filename': fnamemodify(a:fn, ':p'), 'text': l:tags,
           \ 'lnum': 1, 'col': 0,
           \ }
endfunction

function! tagsearch#untagged() abort
    let files=systemlist('tagsearch -u')
    let filedict=map(l:files, {_, val -> <sid>make_list(val, 'untagged')})
    call setqflist(l:filedict)
    if len(l:filedict)
        copen
        cfirst
    endif

endfunction

function! s:just_return(arg) abort
    return a:arg
endfunction

function! tagsearch#long() abort
    call fzf#run(fzf#wrap({
                \ 'source': 'tagsearch --long', 
                \ 'sink*': function('tagsearch#list_or'), 
                \ 'options': '-m'}))
endfunction


function! tagsearch#untagged_fzf() abort
    call <sid>fzf('tagsearch -u', 'e')
endfunction

function! tagsearch#list_or(tags) abort
    call tagsearch#list(a:tags, 1)
endfunction

function! tagsearch#list(tags, or) abort
    let or=''
    if a:or == 1
        let or=' -o '
    endif
    let tags = a:tags
    if type(a:tags) == 3
        let tags = join(l:tags, ' ')
    endif
    let files=systemlist('tagsearch ' . l:or . l:tags)
    let filedict=map(l:files, {_, val -> <sid>make_list(val, l:tags)})
    call setqflist(l:filedict)
    if len(l:filedict)
        copen
        cfirst
    endif
endfunction

function! tagsearch#list_fzf(tags, or) abort
    let or=''
    if a:or == 1
        let or=' -o '
    endif
    call <sid>fzf('tagsearch ' . l:or . a:tags, 'e')
endfunction

function! tagsearch#knowledge_projects(arglead, _cmdline, _cursorpos) abort
    let curdir=getcwd()
    exec "cd " . expand(g:knowledge_dir)
    let matching=filter(systemlist('tagsearch project --not archive'), 'v:val =~ "' . trim(a:arglead) . '"')
    echom l:matching
    return l:matching
    exec "cd " . l:curdir
endfunction

function! tagsearch#knowledge_projects_fzf() abort
    let curdir=getcwd()
    exec "cd " . expand(g:knowledge_dir)
    call fzf#run(fzf#wrap({
                \ 'source': 'tagsearch project --not archive',
                \ 'sink': 'edit',
                \ }))
    exec "cd " . l:curdir
endfunction
