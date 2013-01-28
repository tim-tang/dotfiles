  set nocompatible

  filetype on
  filetype plugin indent on

" 禁止生成临时文件
  set nobackup
  set noswapfile

" 历史记录数
  set history=50

" 设置编码
  set enc=utf-8

" 设置文件编码
  set fenc=utf-8

" 设置文件编码检测类型及支持格式
  set fencs=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936

" 设置开启语法高亮
  syntax on

" 显示行号
  set number

" 高亮显示匹配的括号
  set showmatch

" 搜索忽略大小写
  set ignorecase

" 查找结果高亮度显示
  set hlsearch
  set incsearch

" tab宽度
  set expandtab
  set tabstop=4
  set tabstop=4
  set cindent shiftwidth=4
  set autoindent shiftwidth=4

" 命令行下按tab键自动完成
  set wildmode=list:full
  set wildmenu

" 带有如下符号的单词不要被换行分割
  set iskeyword+=_,$,@,%,#,-

" 通过使用: commands命令，告诉我们文件的哪一行被改变过
  set report=0

" set vim status line
  set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

" ctrp plugin
  set runtimepath^=~/.vim/bundle/ctrlp.vim
  let g:ctrlp_map = '<c-p>'
  let g:ctrlp_cmd = 'CtrlP'
  let g:ctrlp_working_path_mode = 'ra'

" 可以在buffer的任何地方使用鼠标（类似office中在工作区双击鼠标定位）
  set mouse=a
  set selection=exclusive
  set selectmode=mouse,key
" Strip trailing whitespace
  function! <SID>StripTrailingWhitespaces()
     let _s=@/
     let l = line(".")
     let c = col(".")
     %s/\s\+$//e
     let @/=_s
     call cursor(l, c)
  endfunction
  autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

" 把 F8 映射到 启动NERDTree插件
  map <F8> :NERDTree<CR>

" filter pyc files
  let NERDTreeIgnore = ['\.pyc$']

" config nerdtree window position
  let NERDTreeWinPos="left"

" filter tree files
  let NERDTreeCaseSensitiveSort=1

" beautify nerdtree structure
  let NERDChristmasTree=1

" hijack new trw
  let NERDTreeHijackNetrw=1

" powerline plugin
"  source /Users/timtang/Library/Python/2.7/lib/python/site-packages/powerline/ext/vim/source_plugin.vim
"  python from powerline.ext.vim import source_plugin; source_plugin()

" Setting for vim diff
  if &diff
      colors peaksea
	  set background=dark
  endif

" When you press gv you vimgrep after the selected text
  vnoremap <silent> gv :call VisualSearch('gv')<CR>
  map <leader>g :vimgrep // **/*.<left><left><left><left><left><left><left>

  function! CmdLine(str)
      exe "menu Foo.Bar :" . a:str
      emenu Foo.Bar
      unmenu Foo
  endfunction

  " From an idea by Michael Naumann
   function! VisualSearch(direction) range
      let l:saved_reg = @"
      execute "normal! vgvy"
      let l:pattern = escape(@", '\\/.*$^~[]')
      let l:pattern = substitute(l:pattern, "\n$", "", "")

      if a:direction == 'b'
	   execute "normal ?" . l:pattern . "^M"
       elseif a:direction == 'gv'
	     call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.')
	   elseif a:direction == 'f'
	     execute "normal /" . l:pattern . "^M"
	   endif

      let @/ = l:pattern
      let @" = l:saved_reg
   endfunction
