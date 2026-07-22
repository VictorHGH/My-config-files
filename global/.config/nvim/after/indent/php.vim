" Use PHP indentation inside PHP blocks and HTML indentation outside them.
" This fixes plain .php templates where embedded HTML should indent like HTML.

let s:php_indentexpr = &l:indentexpr
let s:php_indentkeys = &l:indentkeys

unlet! b:did_indent
runtime! indent/html.vim
let s:html_indentexpr = &l:indentexpr

let b:did_indent = 1
let &l:indentexpr = 'UserPhpHtmlIndent()'
let &l:indentkeys = s:php_indentkeys . ',<>>,/'

function! UserPhpHtmlIndent() abort
  execute 'let l:php_indent = ' . s:php_indentexpr

  if s:InPhpBlock(v:lnum)
    let l:indent = l:php_indent
  else
    execute 'let l:html_indent = ' . s:html_indentexpr
    let l:indent = s:HtmlBaseIndent(v:lnum, l:php_indent) + s:HtmlRelativeIndent(v:lnum, l:html_indent)
  endif

  return l:indent
endfunction

function! s:HtmlRelativeIndent(lnum, html_indent) abort
  let l:first_html = s:FirstHtmlLine(a:lnum)
  if l:first_html == 0 || l:first_html >= a:lnum
    return a:html_indent
  endif

  return max([a:html_indent - indent(l:first_html), 0])
endfunction

function! s:HtmlBaseIndent(lnum, php_indent) abort
  let l:first_html = s:FirstHtmlLine(a:lnum)

  if l:first_html == 0
    return 0
  endif

  if l:first_html >= a:lnum
    return a:php_indent
  endif

  return indent(l:first_html)
endfunction

function! s:FirstHtmlLine(lnum) abort
  let l:view = winsaveview()
  call cursor(a:lnum, 1)
  let l:php_end = search('?>', 'bnW')
  call winrestview(l:view)

  if l:php_end == 0
    return 0
  endif

  return nextnonblank(l:php_end + 1)
endfunction

function! s:InPhpBlock(lnum) abort
  let l:line = getline(a:lnum)

  if l:line =~# '^\s*<?\%(php\|=\)\=' || l:line =~# '^\s*?>'
    return 1
  endif

  let l:view = winsaveview()
  call cursor(a:lnum, 1)
  let l:php_start = search('<?\%(php\|=\)\=', 'bnW')
  let l:php_end = search('?>', 'bnW')
  call winrestview(l:view)

  return l:php_start > l:php_end
endfunction

let b:undo_indent = 'setlocal indentexpr< indentkeys<'
