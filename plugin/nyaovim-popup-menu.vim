if get(g:, 'loaded_nyaovim_popup_menu', 0) || !exists('g:nyaovim_version')
    finish
endif
let g:loaded_nyaovim_popup_menu = 1

let g:nyaovim_popup_menu_default_mapping = get(g:, 'nyaovim_popup_menu_default_mapping', 1)

" Clear any commands that we add throughout the script
augroup nyaovim_popup_menu
    autocmd!
augroup END

""
" Open a popup menu, given a list of strings
" It will open up a popup menu displaying the strings on individual lines in
" the popup
"
function! s:open_popup_menu(str_list, line, col) abort
    call rpcnotify(0, 'popup-menu:open', a:line, a:col)

    call rpcnotify(0, 'popup-menu:add', '')

    for l:str_line in a:str_list
      call rpcnotify(0, 'popup-menu:add', l:str_line)
    endfor

    augroup nyaovim_popup_menu
        autocmd!
        autocmd CursorMoved,CursorMovedI * call rpcnotify(0, 'popup-menu:close') | autocmd! nyaovim_popup_menu
    augroup END
endfunction

function! TogglePopupMenu(str_list, line, col)
    call rpcnotify(0, 'popup-menu:toggle', a:str_list, a:line, a:col)
endfunction

function! OpenPopupMenu(str_list, line, col)
    call rpcnotify(0, 'popup-menu:open', a:line, a:col)
endfunction

function! ClosePopupMenu()
    call rpcnotify(0, 'popup-menu:close')
endfunction

function! s:calc_virtline() abort
    if !&l:wrap
        return line('.') - line('w0') + 1
    endif

    let l:width = winwidth(0)
    let l:l = 0
    let l:c = line('w0')
    let l:end = line('.')

    while l:c < l:end
        let l:l += strdisplaywidth(getline(l:c)) / l:width + 1
        let l:c += 1
    endwhile

    return l:l + col('.') / l:width + 1
endfunction

nnoremap <silent><Plug>(nyaovim-popup-menu-open) :<C-u>call <SID>open_popup_menu(["HELLO", "world"], <SID>calc_virtline(), virtcol('.'))<CR>
vnoremap <silent><Plug>(nyaovim-popup-menu-open) y:call <SID>open_popup_menu(["HELLO", "visual", "world"], <SID>calc_virtline(), virtcol('.'))<CR>

if g:nyaovim_popup_menu_default_mapping
    nmap <silent>gtj <Plug>(nyaovim-popup-menu-open)
    vmap <silent>gtj <Plug>(nyaovim-popup-menu-open)
endif

let g:loaded_nyaovim_popup_menu = 1
