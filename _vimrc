call plug#begin()
Plug 'vimwiki/vimwiki', { 'branch': 'dev' }
Plug 'mhinz/vim-startify'
call plug#end()

let maplocalleader = "\\"

let g:vimwiki_list = [
  \{
  \'path': '~/Desktop/wiki/JayFreemandev.github.io/_wiki',
  \'ext': '.md',
  \'diary_rel_path': '.',
  \},
  \]

let g:vimwiki_conceallevel = 0
command! WikiIndex :VimwikiIndex
nmap <LocalLeader>ww <Plug>VimwikiIndex
nmap <LocalLeader>wi <Plug>VimwikiDiaryIndex
nmap <LocalLeader>w<LocalLeader>w <Plug>VimwikiMakeDiaryNote
nmap <LocalLeader>wt :VimwikiTable<CR>

" F4 키를 누르면 커서가 놓인 단어를 위키에서 검색한다.
nnoremap <F4> :execute "VWS /" . expand("<cword>") . "/" <Bar> :lopen<CR>

" Shift F4 키를 누르면 현재 문서를 링크한 모든 문서를 검색한다
nnoremap <S-F4> :execute "VWB" <Bar> :lopen<CR>

" :today 날짜 출력 "
command! Date r!date "+\%Y-\%m-\%d \%H:\%M:\%S"


let g:vimwiki_global_ext = 0


function! LastModified()
    if g:md_modify_disabled
        return
    endif
    if &modified
        echo 'markdown updated time modified'
        let save_cursor = getpos(".")
        let n = min([10, line("$")])
        keepjumps exe '1,' . n . 's#^\(.\{,10}updated\s*: \).*#\1' .
            \ strftime('%Y-%m-%d %H:%M:%S +0900') . '#e'
        call histdel('search', -1)
        call setpos('.', save_cursor)
    endif
endfun

autocmd BufWritePost *.md call LastModified()

function! NewTemplate()

    let l:wiki_directory = v:false

    for wiki in g:vimwiki_list
        echom 'Current File Directory: ' . expand('%:p:h')
        if expand('%:p:h') =~ expand(wiki.path)
        let l:wiki_directory = v:true
            break
        endif
    endfor

    
    if !l:wiki_directory
        return
    endif

    if line("$") > 1
        return
    endif

    let l:template = []
    call add(l:template, '---')
    call add(l:template, 'layout  : wiki')
    call add(l:template, 'title   : ')
    call add(l:template, 'summary : ')
    call add(l:template, 'date    : ' . strftime('%Y-%m-%d %H:%M:%S +0900'))
    call add(l:template, 'updated : ' . strftime('%Y-%m-%d %H:%M:%S +0900'))
    call add(l:template, 'tag     : ')
    call add(l:template, 'toc     : true')
    call add(l:template, 'public  : true')
    call add(l:template, 'parent  : ')
    call add(l:template, 'latex   : false')
    call add(l:template, 'resource: ' . substitute(system("uuidgen"), '\n', '', ''))
    call add(l:template, '---')
    call add(l:template, '* TOC')
    call add(l:template, '{:toc}')
    call add(l:template, '')
    call add(l:template, '# ')
    call setline(1, l:template)
    execute 'normal! G'
    execute 'normal! $'

    echom 'new wiki page has created'
endfunction

autocmd BufRead,BufNewFile *.md call NewTemplate()

function! UpdateBookProgress()
    let l:cmd = "cd ~ && ~/book.sh " . expand('%:p')
    call system(l:cmd)
    edit
endfunction
autocmd BufWritePre *.md call UpdateBookProgress()

let g:md_modify_disabled = 0