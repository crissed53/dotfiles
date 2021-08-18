""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Custom RTP
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" this will make you use VIM_CONFIG_PATH environment variable as well
if !empty($VIM_CONFIG_PATH)
  set rtp+=$VIM_CONFIG_PATH/.vim
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Profiling
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Run the following commands in order to check what's making your vim slow.
" :profile start profile.log
" :profile func *
" :profile file *
"" At this point do slow actions
" :profile pause

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim-plug Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" :PlugList, :PlugInstall, :PlugClean, :PlugSearch
set nocompatible
filetype off

call plug#begin()

Plug 'VundleVim/Vundle.vim'
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'sheerun/vim-polyglot'

" rainbow brackets
Plug 'luochen1990/rainbow'
Plug 'dense-analysis/ale'  " asynchronous linter - vim8 required - use either syntastic or ale not both

Plug 'romainl/Apprentice'  " apprentice

call plug#end()
filetype plugin on
filetype indent on
syntax enable

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Basic Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au BufNewFile,BufRead *.py
    \ set expandtab       |" replace tabs with spaces
    \ set autoindent      |" copy indent when starting a new line
    \ set tabstop=4
    \ set softtabstop=4
    \ set shiftwidth=4

set mouse=a  " enable mouse in all modes
set smartcase
set hlsearch  " highlight search (:noh<cr> to disable)
set incsearch  " immediately highlight seraches

" advanced
set autowrite  " auto write when going off to other files
set autoread  " auto read in when modified outside
set nobackup
set noswapfile  " no .swp files!

" misc
set history=700  " remember up to n histories
set timeoutlen=500  " timeout length on mappings and key codes
" marks remembered for last 100 files, 3000 line limit to yank,
" registers with more than 100kB text are skipped
set viminfo='100,<30000,s100

" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" locality and security
set exrc  " if found, use local .vimrc
set secure  " restrict some commands in non-default .vimrc

set nopaste  " default is nopaste
set pastetoggle=<F10>  " map paste toggle key
" this is set because 'paste' disables all mappings

" if ag is available, use it over :grep
" use :copen, :cn, :cp, :cclose, :cr<num> to navigate / open quickfix
" also find :cdo, :argdo, :bufdo for executions across files
" NOTE: navigation using :cn or :cp will not work
" if ag-backed grep is applied on a single file '%' (current file),
" because ag will not show the file name.
" use :vimgrep or simply search using '/'
if executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor\ --column
  set grepformat=%f:%l:%c%m
endif

" collect open buffers
function! BuffersList()
  let all = range(0, bufnr('$'))
  let res = []
  for b in all
    if buflisted(b)
      call add(res, bufname(b))
    endif
  endfor
  return res
endfunction

" [!] prevents vimgrep from moving cursor to the first matching result
function! GrepBuffers(expression)
  exec 'vimgrep!/'.a:expression.'/ '.join(BuffersList())
endfunction

" bind K to grep word under cursor for all open buffers
nnoremap K :call GrepBuffers("<C-R><C-W>")<CR>

" Delete trailing white space on save!!!
fun! CleanExtraSpaces()
  let save_cursor = getpos(".")
  let old_query = getreg('/')
  silent! %s/\s\+$//e
  call setpos('.', save_cursor)
  call setreg('/', old_query)
endfun

if has("autocmd")
  autocmd BufWritePre *.c,*.cc,*.js,*.py,*.sh,*.json,*.cpp,*.go,*.h,*.hpp,*.hs,.vimrc,.zshrc,*.java,*.scala :call CleanExtraSpaces()
endif

" colorscheme - very sensitive stuff :(
set background=dark
" try term=screen-256color if this doesn't work for you
" set term=xterm-256color
silent! colorscheme apprentice
" silent! set termguicolors  " should be uncommented if colorscheme doesn't work properly
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" map Ctrl-c to behave the same as <ESC> (<C-c> will not trigger InsertLeave event)
" <Esc> is pressed twice since it will wait for 'timeoutlen' millisecs
" in case there is a mapping with <Esc>.
inoremap <C-c> <Esc><Esc>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" better whitespace option
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
highlight ExtraWhitespace ctermbg=0xFF0000

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ale settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" only run the lint during text change in normal mode
let g:ale_lint_on_text_changed = 'normal'
" instead of running the linter always in insert mode,
" only run the linter when leaving the insert - InsertLeave event
let g:ale_lint_on_insert_leave = 1
" 0.5s delay to linter to run after text change
let g:ale_lint_delay = 300
" Enable completion
let g:ale_completion_enabled = 1

" specific linters
" python: pip install pylint flake8
let g:ale_linters = {
      \ 'python': ['pylint', 'flake8'],
      \}

" Autoformatting.
" python: pip install yapf
let g:ale_fixers = {
      \ 'python': ['yapf'],
      \}

" Apply autoformatting on save.
let g:ale_fix_on_save = 1

