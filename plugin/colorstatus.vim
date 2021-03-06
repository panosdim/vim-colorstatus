" =============================================================================
" Filename: plugin/colorstatus.vim
" Author: Panagiotis Dimopoulos
" License: MIT License
" =============================================================================

" Check if Vim compiled with +statusline
if !has("statusline")
    echoerr 'Vim is not compiled with statusline'
    finish
endif

set ls=2 " Always show status line

" Update status line when ALE is working
if exists('*ale#engine#IsCheckingBuffer')
    augroup colorstatusale
        autocmd!
        autocmd User ALELintPre  call colorstatus#ale()
        autocmd User ALELintPost call colorstatus#ale()

        autocmd User ALEFixPre   call colorstatus#ale()
        autocmd User ALEFixPost  call colorstatus#ale()
    augroup END
endif

" Update status line when GutenTags is working
if exists('*gutentags#statusline')
    augroup MyGutentagsStatusLineRefresher
        autocmd!
        autocmd User GutentagsUpdating call colorstatus#tags()
        autocmd User GutentagsUpdated call colorstatus#tags()
    augroup END
endif

" Check configuration options
let s:vimdevicons = get(g:, 'colorstatus#vimdevicons', 0)
let s:nerdfont = get(g:, 'colorstatus#nerdfont', 0)

" Shows ALE linter status
function! colorstatus#ale() abort
    if exists('*ale#engine#IsCheckingBuffer')
        let &ro = &ro " Use this in order to force status line update

        let l:indicator_warnings = s:nerdfont ? "\uf071" : 'W:'
        let l:indicator_errors = s:nerdfont ? "\uf05e" : 'E:'
        let l:indicator_ok = s:nerdfont ? "\uf00c" : 'OK'
        let l:indicator_checking = s:nerdfont ? "\uf110" : 'Linting...'

        if ale#engine#IsCheckingBuffer(bufnr(''))
            return l:indicator_checking
        endif

        let l:counts = ale#statusline#Count(bufnr(''))

        let l:all_errors = l:counts.error + l:counts.style_error
        let l:all_non_errors = l:counts.total - l:all_errors

        if l:counts.total == 0
            return l:indicator_ok
        elseif l:all_non_errors == 0
            return l:indicator_errors . l:all_errors
        elseif l:all_errors == 0
            return l:indicator_warnings . l:all_non_errors
        else
            return l:indicator_errors . l:all_errors . ' ' . l:indicator_warnings . l:all_non_errors
        endif
    endif
    return ''
endfunction

" Shows and color current mode
function! colorstatus#mode() abort
    let l:mode_map = {
                \ 'n' : 'NORMAL',
                \ 'i' : 'INSERT',
                \ 'R' : 'REPLACE',
                \ 'v' : 'VISUAL',
                \ 'V' : 'V-LINE',
                \ "\<C-v>": 'V-BLOCK',
                \ 'c' : 'COMMAND',
                \ 's' : 'SELECT',
                \ 'S' : 'S-LINE',
                \ "\<C-s>": 'S-BLOCK',
                \ 't': 'TERMINAL',
                \ }

    let l:color_map = {
                \ 'n' : 'hi Mode cterm=bold ctermfg=000 ctermbg=022 gui=bold guifg=#000000 guibg=#005f00',
                \ 'i' : 'hi Mode cterm=bold ctermfg=000 ctermbg=009 gui=bold guifg=#000000 guibg=#ff0000',
                \ 'R' : 'hi Mode cterm=bold ctermfg=000 ctermbg=166 gui=bold guifg=#000000 guibg=#d75f00',
                \ 'v' : 'hi Mode cterm=bold ctermfg=000 ctermbg=027 gui=bold guifg=#000000 guibg=#005fff',
                \ 'V' : 'hi Mode cterm=bold ctermfg=000 ctermbg=033 gui=bold guifg=#000000 guibg=#0087ff',
                \ "\<C-v>": 'hi Mode cterm=bold ctermfg=000 ctermbg=057 gui=bold guifg=#000000 guibg=#5f00ff',
                \ 'c' : 'hi Mode cterm=bold ctermfg=000 ctermbg=011 gui=bold guifg=#000000 guibg=#ffff00',
                \ 's' : 'hi Mode cterm=bold ctermfg=000 ctermbg=020 gui=bold guifg=#000000 guibg=#0000d7',
                \ 'S' : 'hi Mode cterm=bold ctermfg=000 ctermbg=033 gui=bold guifg=#000000 guibg=#0087ff',
                \ "\<C-s>": 'hi Mode cterm=bold ctermfg=000 ctermbg=057 gui=bold guifg=#000000 guibg=#5f00ff',
                \ 't': 'TERMINAL',
                \ }

    exec l:color_map[mode()]
    return l:mode_map[mode()]
endfunction

" Shows git branch
function! colorstatus#fugitive() abort
    if exists('*fugitive#head')
        let branch = fugitive#head()
        return branch !=# '' ? s:nerdfont ? "\ue0a0 " . branch : branch  : ''
    endif
    return ''
endfunction

" Shows filetype and icon
function! colorstatus#filetype() abort
    return winwidth(0) > 70 ? (strlen(&filetype) ? (s:vimdevicons ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : &filetype) : 'no ft') : ''
endfunction

" Shows fileformat and icon
function! colorstatus#fileformat() abort
    return winwidth(0) > 70 ? (s:vimdevicons ? &fileformat . ' ' . WebDevIconsGetFileFormatSymbol() : &fileformat) : ''
endfunction

" Shows readonly
function! colorstatus#readonly()
    return &readonly ? (s:nerdfont ? "\uf023" : 'RO') : ''
endfunction

" Shows if buffer is modified
function! colorstatus#modified()
    return &modified ? (s:nerdfont ? "\uf067" : '+') : ''
endfunction

" Shows LN or glyph icon
function! colorstatus#line()
    return s:nerdfont ? "\ue0a1" : 'LN'
endfunction

" Shows GutenTags status
function! colorstatus#tags() abort
    if exists('*gutentags#statusline')
        let &ro = &ro " Use this in order to force status line update
        return gutentags#statusline()
    endif
    return ''
endfunction

" Highlight sections
hi FilePath     ctermfg=015 ctermbg=088 guifg=#ffffff guibg=#870000
hi GitStatus    ctermfg=015 ctermbg=018 guifg=#ffffff guibg=#000087
hi FileType     ctermfg=000 ctermbg=014 guifg=#000000 guibg=#00ffff
hi Encoding     ctermfg=000 ctermbg=228 guifg=#000000 guibg=#ffff87
hi FileFormat   ctermfg=000 ctermbg=119 guifg=#000000 guibg=#87ff5f
hi Row          ctermfg=015 ctermbg=033 guifg=#ffffff guibg=#0087ff
hi ReadOnly     ctermfg=015 ctermbg=089 guifg=#ffffff guibg=#87005f
hi Status       ctermfg=015 ctermbg=021 guifg=#ffffff guibg=#0000ff
hi Linter       ctermfg=000 ctermbg=036 guifg=#000000 guibg=#00af87
hi GutenTags    ctermfg=000 ctermbg=047 guifg=#000000 guibg=#00ff5f
hi Modified     ctermfg=000 ctermbg=208 guifg=#000000 guibg=#ff8700
hi Reset        ctermfg=015 ctermbg=000 guifg=#ffffff guibg=#000000

" Set status line
let &statusline=""
let &statusline.="%#Mode# %{colorstatus#mode()} "                "Mode
let &statusline.="%#FilePath# %<%F "                             "File+path
let &statusline.="%#GitStatus#%( %{colorstatus#fugitive()} %)"   "Git Branch
let &statusline.="%#Modified#%( %{colorstatus#modified()} %)"    "Modified
let &statusline.="%#ReadOnly#%( %{colorstatus#readonly()} %)"    "Read Only
let &statusline.="%#Reset#%="                                    "Separation point between left and right aligned items
let &statusline.="%#FileType# %{colorstatus#filetype()} "        "FileType
let &statusline.="%#Encoding# %{(&fenc!=''?&fenc:&enc)} "        "Encoding
let &statusline.="%#FileFormat# %{colorstatus#fileformat()} "    "FileFormat (dos/unix..)
let &statusline.="%#Status# %p%% "                               "Percentage of file
let &statusline.="%#Row# %{colorstatus#line()} %3l:%-2v "        "Row/Column
let &statusline.="%#Linter#%( %{colorstatus#ale()} %)"           "Linter Status
let &statusline.="%#GutenTags#%( %{colorstatus#tags()} %)"       "GutenTag Status
