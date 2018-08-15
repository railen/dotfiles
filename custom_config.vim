let g:syntastic_c_config_file = '.syntastic_c_config'
autocmd BufWritePre *.c :%s/\s\+$//e
set exrc
set secure
nnoremap <F4> :make<cr>
set cm=blowfish2
let g:vdebug_options = {'ide_key': 'netbeans-xdebug'}
let g:vdebug_options = {'break_on_open': 0}
let g:vdebug_options = {'server': '127.0.0.1'}
let g:syntastic_cpp_compiler_options = '-std=c++11'
let g:clang_complete_macros = 1
let g:DoxygenToolkit_authorName = "Alexandr V. Lebedev"
set encoding=utf-8
set fileencoding=utf-8
nmap <leader>d :Dox<cr>
