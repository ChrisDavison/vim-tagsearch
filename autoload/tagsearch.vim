" vim-tagsearch.vim - Search for tags across files.
" Maintainer: Chris Davison <https://chrisdavison.github.io>
" Version: 2021-08-03

function! s:fzf(source, sink) abort "{{{
    call fzf#run(fzf#wrap({
                \ 'source': a:source,
                \ 'sink': a:sink,
                \ 'window': {'width': 1.0, 'height': 0.3, 'relative': v:false, 'yoffset': 0.0},
                \ 'preview': ['right:50%:hidden', 'ctrl-/'],
                \ }))
endfunction "}}}

function! s:make_list(fn, pattern) abort "{{{
    let tags=join(map(split(a:pattern, ' '), {_, val -> '@' . val}), ' ')
    return { 'filename': fnamemodify(a:fn, ':p'), 'text': l:tags,
           \ 'lnum': 1, 'col': 0,
           \ }
endfunction "}}}

function! tagsearch#untagged() abort "{{{
    let grepprg_old=&g:grepprg
    let &g:grepprg='tagsearch untagged --vim'
    silent grep
    let &g:grepprg=l:grepprg_old
endfunction "}}}

function! tagsearch#long() abort "{{{
    call fzf#run(fzf#wrap({
                \ 'source': 'tagsearch tags --long --no-tree',
                \ 'sink*': function('tagsearch#list_or'),
                \ 'options': '-m'}))
endfunction "}}}

function! tagsearch#insert_tags_at_point(tags) "{{{
    let tagstr=join(map(a:tags, {_, v -> "@" . v}), " ")
    call setline('.', l:tagstr)
endfunction "}}}

function! s:wordlist_to_tagstr(words) abort "{{{
    return join(map(a:words, { k, v -> '@' . v }), ' ')
endfunction "}}}

function! tagsearch#append_tags_to_first_tagline(tags) abort "{{{
    let curpos=getpos('.')
    call cursor(1, 1)
    let first_tagline=search('^@', 'nc')
    " use dict to avoid duplicating tags
    let tag_dict = {}
    for new_tag in a:tags
        let tag_dict[substitute(new_tag, '@', '', '')] = 1
    endfor

    if l:first_tagline[0] > 0
        let dict_tags = {}
        " replace (first) tagline with updated tagline
        let tags_in_line = split(getline(l:first_tagline[0]), ' ')
        for single_tag in tags_in_line
            let tag_dict[substitute(single_tag, '@', '', '')] = 1
        endfor
        call setline(l:first_tagline[0], s:wordlist_to_tagstr(keys(tag_dict)))
    else
        call cursor(1,1)
        let first_h1=search('^#', 'nc')
        if l:first_h1 > 0
            " append after the first H1
            call append(l:first_h1[0], ["", s:wordlist_to_tagstr(keys(tag_dict)), ""])
        else
            " or just put it right at the top of the file
            call append(0, [s:wordlist_to_tagstr(keys(tag_dict))])
        endif
    endif
    call cursor(l:curpos)
endfunction "}}}

function! tagsearch#insert_tags() abort "{{{
    call fzf#run(fzf#wrap({
                \ 'source': 'tagsearch tags --long --no-tree',
                \ 'sink*': function('tagsearch#insert_tags_at_point'),
                \ 'options': '-m'}))
endfunction "}}}

function! tagsearch#append_tags() abort "{{{
    call fzf#run(fzf#wrap({
            \ 'source': 'tagsearch tags --long --no-tree',
            \ 'sink*': function('tagsearch#append_tags_to_first_tagline'),
            \ 'options': '-m'}))
endfunction "}}}

function! tagsearch#untagged_fzf() abort "{{{
    call <sid>fzf('tagsearch untagged', 'e')
endfunction "}}}

function! tagsearch#list_or(tags) abort "{{{
    call tagsearch#list(a:tags, 1)
endfunction "}}}

function! tagsearch#list(tags, or) abort "{{{
    let or=''
    if a:or == 1
        let or=' -o '
    endif
    let tags = a:tags
    if type(a:tags) == 3
        let tags = join(l:tags, ' ')
    endif

    let grepprg_old=&g:grepprg
    let &g:grepprg='tagsearch files --vim ' . l:or . l:tags
    silent grep
    let &g:grepprg=l:grepprg_old
endfunction "}}}

function! tagsearch#list_fzf(tags, or) abort "{{{
    let or=''
    if a:or == 1
        let or=' -o '
    endif
    call <sid>fzf('tagsearch files ' . l:or . a:tags, 'e')
endfunction "}}}

function! tagsearch#knowledge_projects(arglead, _cmdline, _cursorpos) abort "{{{
    let curdir=getcwd()
    exec "cd " . expand(g:knowledge_dir)
    let matching=filter(systemlist('tagsearch files project --not archive'), 'v:val =~ "' . trim(a:arglead) . '"')
    exec "cd " . l:curdir
    return l:matching
endfunction "}}}

function! tagsearch#knowledge_projects_fzf() abort "{{{
    let curdir=getcwd()
    let g:rooter_manual_only=1
    exec "cd " . expand(g:knowledge_dir)
    let command='tagsearch files project --not archive'
    call fzf#run(fzf#wrap({
                \ 'source': l:command,
                \ 'sink': 'edit',
                \ }))
    let g:rooter_manual_only=0
    return systemlist(l:command)
endfunction "}}}
