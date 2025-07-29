" Yank to system clipboard
set clipboard=unnamed
" H and L for beginning/end of line
nmap H ^
nmap L $

" Double
inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O
