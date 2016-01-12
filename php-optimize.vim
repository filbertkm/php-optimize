" ============================================================================
" File:         php-optimize.vim
" Description:  vim script to highlight unused php imports
" Maintainer:   aude <aude.wiki at gmail dot com>
" Last Change:  January 7, 2016
" License:      This program is free software. It comes without any warranty,
"               to the extent permitted by applicable law.
" Installation: Install this file as plugin/php-optimize.vim
" Usage:        :UnusedImports will highlight the unused imports
"
" ============================================================================

if exists('g:loaded_unused_imports')
  finish
endif
let g:loaded_unused_imports = '0.1'

if v:version < 700
    echoerr "php-optimize: this plugin requires vim >= 7."
    finish
endif

let s:matches_so_far = []

function! s:highlight_unused_imports(remove)
  highlight unusedimport ctermbg=darkred guibg=darkred

  " save current position to set it back later
  let startLine = line(".")
  let startCol = col(".")

  let linenr = 0
  " where does the class definition start (= where the imports end)
  call cursor(1, 1)
  let classStartLine = search('\/\*\*')

  while linenr < classStartLine
    let line = getline(linenr)
	let lis = matchlist(line, '\v^\s*use\s+(\w+\\)+(\w+);')

    if len(lis) > 0
	  let parts = split(split(line, '\')[-1], ';')
      let className = parts[0]

      call cursor(classStartLine, 1)
      let linefound = search(className, 'nW')

      if linefound == 0
        call add(s:matches_so_far, matchadd('unusedimport', split(line, '\')[-1]))
      endif

      call cursor(startLine, startCol)
    endif

    let linenr += 1
  endwhile

  let linenr = 0
  call cursor(1, 1)

  while linenr < classStartLine
    let line = getline(linenr)
	let lis = matchlist(line, '\v^\s*use\s+(\w+);')

    if len(lis) > 0
	  let className = lis[1]

      call cursor(classStartLine, 1)
      let linefound = search(className, 'nW')

      if linefound == 0
        call add(s:matches_so_far, matchadd('unusedimport', className))
      endif

      call cursor(startLine, startCol)
    endif

    let linenr += 1
  endwhile
  " set cursor back to initial position
  call cursor(startLine, startCol)
endfunction

command! UnusedImports call s:highlight_unused_imports(0)
