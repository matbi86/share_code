" Show line numbers
set number
" Turn on syntax highlighting
syntax on
" auto indent
set autoindent
set cindent

set ts=4 " Tab 너비
set shiftwidth=4 " 자동 인덴트할 때 너비

" 마지막으로 수정된 곳에 커서를 위치함
au BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\ exe "norm g`\"" |
\ endif

set laststatus=2 " 상태바 표시를 항상한다
set statusline=\ %<%l:%v\ [%P]%=%a\ %h%m%r\ %F\

set incsearch

" Highlight search results
" 검색결과에 하이라이트 표시하기
set hlsearch

" Show matching brackets when text indicator is over them
" 현재 커서가 놓여진 괄호의 짝을 표시하기
set showmatch
" Set utf8 as standard encoding
" utf8을 표준 인코딩으로 사용하기
set encoding=utf-8
set fileencodings=utf-8,cp949
" Set to auto read when a file is changed from the outside
" 현재 사용하고 있는 파일이 외부에서 수정된 경우 자동으로 읽기
set autoread
command! E Explore


