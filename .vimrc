"---------------------------------------------------------------------------
" 基本設定
"---------------------------------------------------------------------------
" 保存時に行末の空白を除去する
autocmd BufWritePre * :%s/\s\+$//ge
" 保存時にtabをスペースに変換する
autocmd BufWritePre * :%s/\t/  /ge

" Vim(Mac)
if has('mac')
    set clipboard+=unnamed
" Vim(Ubuntu)
else
    noremap <Space>y "+y
    noremap <Space>p "+p
endif
let g:cssColorVimDoNotMessMyUpdatetime = 1

"---------------------------------------------------------------------------
" インデントの設定 Indent
"---------------------------------------------------------------------------
set autoindent  " 自動インデント
"set paste      " ペースト時にautoindentを無効に(onにするとautocomplpop.vimが動かない)
set smartindent " 新しい行を開始したときに、新しい行のインデントを現在行と同じ量にする。
set cindent     " Cプログラムファイルの自動インデントを始める
" softtabstopはTabキー押し下げ時の挿入される空白の量，0の場合はtabstopと同じ，BSにも影響する
set tabstop=2 shiftwidth=2 softtabstop=0

filetype indent plugin on
autocmd FileType python     setl autoindent
autocmd FileType python     setl smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd FileType html       setl tabstop=2 expandtab shiftwidth=2 softtabstop=2
autocmd FileType hbs        setl tabstop=2 expandtab shiftwidth=2 softtabstop=2
autocmd FileType javascript setl tabstop=2 expandtab shiftwidth=2 softtabstop=2
autocmd FileType coffee     setl tabstop=2 expandtab shiftwidth=2 softtabstop=2
autocmd FileType python     setl tabstop=4 expandtab shiftwidth=4 softtabstop=4
autocmd FileType css        setl tabstop=2 expandtab shiftwidth=2 softtabstop=2
autocmd FileType ruby       setl tabstop=2 expandtab shiftwidth=2 softtabstop=2

"---------------------------------------------------------------------------
" ステータスライン Status Line
"---------------------------------------------------------------------------
" 常にステータスラインを表示
set laststatus=2

"カーソルが何行目の何列目に置かれているかを表示する
set ruler

"---------------------------------------------------------------------------
" 表示 Appearance
"---------------------------------------------------------------------------

" シンタックスハイライト
syntax on
" 括弧の対応をハイライト
set showmatch
" 行番号表示
set number

" カーソル行をハイライト
set cursorline
" カーソル列をハイライト
set cursorcolumn
" カレントウィンドウにのみ罫線を引く
augroup cch
  autocmd! cch
  autocmd WinLeave * set nocursorline
  autocmd WinEnter,BufRead * set cursorline
augroup END

:hi clear CursorLine
:hi CursorLine gui=underline
:highlight CursorLine guibg=#444444 ctermbg=235
:highlight CursorColumn guibg=#444444 ctermbg=235

"---------------------------------------------------------------------------
" エンコーディング関連 Encoding
"---------------------------------------------------------------------------
" 改行文字
set ffs=unix,dos,mac
" エンコーディング
set encoding=utf-8

"---------------------------------------------------------------------------
" プラグインの設定
" quickrun
"---------------------------------------------------------------------------
let g:quickrun_config = {}
let g:quickrun_config._ = {'runner' : 'vimproc'}
let g:quickrun_config['rspec/bundle'] = {
  \ 'type': 'rspec/bundle',
  \ 'command': 'rspec',
  \ 'exec': 'bundle exec %c %s'
  \}
let g:quickrun_config['rspec/normal'] = {
  \ 'type': 'rspec/normal',
  \ 'command': 'rspec',
  \ 'exec': '%c %s'
  \}
function! RSpecQuickrun()
    let b:quickrun_config = {'type' : 'rspec/bundle'}
endfunction
autocmd BufReadPost *_spec.rb call RSpecQuickrun()
let g:quickrun_config = {}
let g:quickrun_config['coffee.mocha'] = {
      \'command': "mocha",
      \'exec': ["%c --require should --growl %s"]
      \}
augroup Mocha
  autocmd!
  autocmd BufWinEnter,BufNewFile *_mocha.coffee,spec_*.coffee,*_test.coffee set filetype=coffee.mocha
augroup END
let g:quickrun_config['markdown'] = {
      \ 'outputter': 'browser'
      \ }
"---------------------------------------------------------------------------
" neocomplcache
"---------------------------------------------------------------------------
let g:neocomplcache_enable_at_startup = 1

"---------------------------------------------------------------------------
" mustache-handlebars
"---------------------------------------------------------------------------
let g:mustache_abbreviations = 1
