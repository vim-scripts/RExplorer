"*********************************
"*** Author : Arun Easi        ***
"*** E-mail : arunke@yahoo.com ***
"*********************************
"
"Version 1.05
"
" Change Log:
"===============================================================================
" Version   Description                                             Date
"-------------------------------------------------------------------------------
"   1.00    First submit :)                                         Jan 26, '02
"   1.05    Fixed bug with vim7                                     Nov 16, '06
"===============================================================================

" In case of problems, try running like this:
" vi -u NONE -U NONE -c "se mouse=a nocp|so RExplorer.vim"

let s:state="uninit"
let s:rex_width=23
let s:see_dot=0
let s:wish_files=",,"
let s:ignore_files=",,"

fu! s:Init()
    "3/7/05: escaping [
    let my_name='\[RExplorer]'
    if bufname("%") != my_name
        let cb=bufnr("%")
        silent! wincmd w
        while (bufnr("%") != cb)
            if (bufname("%") == my_name)
                break
            endif
            silent! wincmd w
        endwhile
        if !exists("s:re_vim") || s:re_vim != bufnr("%")
            exe "lefta ".s:rex_width."vsp ".my_name
            let s:re_vim=bufnr("%")
            call s:MapInit()
            call s:HiliteInit()
            if filereadable(s:src_dir."/".s:assoc_file)
                exe "source ".s:src_dir."/".s:assoc_file
            endif
            setlocal noswapfile nobuflisted
        endif
    endif
    let g:ake_timeout=0
    setlocal modifiable shellslash
endf

fu! s:AddLabel(start)
    norm! G
    silent! put =\"[+] \".a:start
    silent! 0/^$/d|$
endf

" So long as the bug (where if you click on any non-explorer buffer, when
" you are in exlorer buffer, the explorer mappings are used) is present we
" need to use this wrapper to call any function
fu! s:BugWrapper(function)
    if bufnr("%") != s:re_vim
        return 0
    endif
    exe "let x=s:".a:function
    return x
endf

fu! s:ReSrcAssocFile()
    echo "Re sourced associations file :)"
    exe "source ".s:src_dir."/".s:assoc_file
endf

" function Just For Mappings (to do misc stuffs, like setting s:vars)
fu! s:JFM(arg)
    " Toggle Seeing Dot files
    if a:arg == "tsd"
        let s:see_dot=!s:see_dot
        if s:see_dot
            echo "You'll see hidden"
        else
            echo "Got rid of hidden"
        endif
    " Wishlist Files
    elseif a:arg == "sf"
        let s:wish_files=",".input("I wud like to see (eg: c,h): ").","
    " Dont-wanna-see Files
    elseif a:arg == "hf"
        let s:ignore_files=",".input("I dont like to see (eg: o,obj): ").","
    elseif a:arg == "ff"
        let wif=matchstr(s:wish_files, '.\zs.*\ze.')
        let igf=matchstr(s:ignore_files, '.\zs.*\ze.')
        echo "[[ show filter: "|echohl MoreMsg|echon wif == "" ? "<null>" : wif|echohl None|echon " ]] [[ hide filter: "|echohl MoreMsg|echon igf == "" ? "<null>" : igf|echohl None|echon " ]]"
    endif
endf

fu! s:HiliteInit()
    syn match  REDir		"^.\{-}+]\zs.*"hs=s+1
    syn match  REODir		"^.\{-}-]\zs.*"hs=s+1
    syn match  REFile		"^.\{-}|-\zs.*"hs=s+1
    hi REDir	    		term=underline  ctermfg=red     guifg=red
    hi REODir	    		term=underline  ctermfg=green   guifg=green
    hi REFile	    		term=underline  ctermfg=3       guifg=yellow
endf

fu! s:Refresh()
    norm! mgg0myHmh`gy2l
    let cur_col=col("'g")
    let cur_scr_col=col("'y")
    let cur_hi_line=getline(line("'h"))
    let cline=getline(line("."))
    norm! 0
    if match(cline, "|-", 0) > 0
        call search("|-", "W")|norm! F|
        call search('\%'.col('.').'c-','b')
    elseif match(cline, "-]") > 0
        call search("-]", "W")
    elseif match(cline, "+]") > 0
        if match(cline, '^\[+]') == 0
            norm! f l
        else
            call search("+]", "W")|norm! F|
            call search('\%'.col('.').'c-','b')
        endif
    else
        norm! $F|
        call search('\%'.col('.').'c-','b')
    endif
    call s:ExpandOrCollapse()
    call s:ExpandOrCollapse()
    norm! mg
    let srch_esc='/\[.'
    let g:abc='^'.escape(cur_hi_line, srch_esc).'$'
    call search('^'.escape(cur_hi_line, srch_esc).'$', "w")
    if search('^'.escape(cline, srch_esc).'$', "W") != 0
        exe "norm! ".cur_scr_col."|zs".cur_col."|"
    else
        norm! `g
    endif
endf

fu! s:MapInit()
    nn <silent> <buffer> ]<CR> :call <SID>BugWrapper("OpenIfFile('loc')")<cr>
    nn <silent> <buffer> <CR> :call <SID>BugWrapper("OpenIfFile('rip')")<cr>
    nn <silent> <buffer> <LeftMouse> <LeftMouse>:call <SID>BugWrapper("ExpandOrCollapse()")<cr>
    "nn <silent> <buffer> <cr> :call <SID>BugWrapper("ExpandOrCollapse()")<cr>
    nn <silent> <buffer> <2-LeftMouse> :call <SID>BugWrapper("OpenIfFile('rip')")<cr>
    nn <silent> <buffer> <RightMouse> <LeftMouse>:call <SID>BugWrapper("OpenIfFile('loc')")<cr>
    nn <silent> <buffer> <F5> :call <SID>BugWrapper("Refresh()")<cr>
    "The following map is to make the "non-shaky" behaviour in gvim
    nn <silent> <buffer> <RightRelease> <Nop>
    vno <buffer> <silent>  <c-c><LeftMouse>:call <SID>BugWrapper("ExpandOrCollapse()")<cr>
    nn <silent> <C-LeftMouse> <LeftMouse>:q<CR>
    nn <buffer> <silent> <Up> <C-Y>
    nn <buffer> <silent> <Down> <C-E>
    nn <buffer> <silent> <Left> zh
    nn <buffer> <silent> <Right> zl
    nn <buffer> <silent> <c-r> :call <SID>BugWrapper("ReSrcAssocFile()")<cr>
    "Other mappings
    nn <silent> <buffer> <Leader>. :call <SID>JFM("tsd")<cr>
    nn <silent> <buffer> <Leader>ff :call <SID>JFM("ff")<cr>
    nn <silent> <buffer> <Leader>sf :call <SID>JFM("sf")<cr>
    nn <silent> <buffer> <Leader>hf :call <SID>JFM("hf")<cr>
    "Just to disable visual mode AMAP
    nn <buffer <buffer> <3-LeftMouse> <Nop>
    nn <buffer <buffer> <4-LeftMouse> <Nop>
    nn <buffer> v <Nop>
    nn <buffer> V <Nop>
endf

"Assumes we are on the first char of file/dir name
"Modifies @", if later needed to restore, add it
fu! s:GetPath()
    norm! mq
    let path=""
    let sep="/"
    let avoid_inf=0
    while (avoid_inf<50)
        norm! y$3h
        let path=@".sep.path
        if (col(".") == 2)
            " case 1: << expanding /, path=// >>
            " case 2: << expanding file, path=//home/aeasi/fvwm2rc/
            let path=substitute(path,'.$','','')
            let path=fnamemodify(path,':s?//?/?')
            break
        endif
        call search("| ","b")
        silent! exe "norm! ?\\%".col(".")."c[+-]\<CR>W"
        call histdel("search", -1)
        let avoid_inf=avoid_inf+1
    endwhile
    norm! `q
    return escape(path, ' \%#~')
endf

fu! s:OpenExtern(path)
    let ext=tolower(fnamemodify(a:path, ":e"))
    exe 'let evar="b:'.ext.'"'
    if !exists(evar)
        let type=substitute(b:rextype, '.*<\([^:]*\):[^>]*[, ]'.ext.'[,>].*', '\1', '')
        exe 'let evar="b:'.type.'"'
    endif
    if exists(evar)
        exe 'let econt='.evar
        let lpath=a:path
        "MS-Windows expects path separator as \
        if b:os == "win32"
            let lpath='"'.fnamemodify(a:path, ':p:gs+/+\\\\+').'"'
        endif
        let cmd=substitute(econt,'%1',lpath,"g")
        call system(cmd)
        echo "viewing ".a:path
        let v:statusmsg="spawned ".cmd
        return 1
    endif
    return 0
endf

" Open policy:
" If asked to open remotely
"    Try opening, if external viewers defined
" Otherwise
"    If explorer is the only window
"       split vertically right and open the file there
"    Otherwise
"       go to the previous window and open the file
"
" Assumptions: `g contains the location where user clicked
"
fu! s:OpenFile(path, where)
    "rip => remote if possible ;)
    if (a:where == "rip")
        if s:OpenExtern(a:path)
            return
        endif
    endif
    silent! wincmd p
    if (bufnr("%") == s:re_vim)
        let w=winwidth(0)-s:rex_width-1
        " This is to re-mark, if your cursor is beyond the width of the
        " explorer window. This is for the non-shaky behaviour
        norm! `g
        if col(".") > s:rex_width
            exe "norm! ".s:rex_width."|mg"
        endif
        exe "rightb ".w."vsp ".a:path
    else
        silent! exe 'e '.a:path
    endif
    wincmd p
endf

" Assumption : cursor is at +/-
" Modifies   : @"
" Marks used: g,h,y
fu! s:ExpandOrCollapse()
    setlocal modifiable
    norm! mgg0myHmh`gy2l
    let ret=0
    let init_mid=line("'h")
    if (@" == "+]")
        norm! r-W
        let path=s:GetPath()
        call s:Expand(path)
        let ret=1
    elseif (@" == "-]")
        silent! exe "norm! r+jly0dV/^\<c-r>\"\ $/e\<cr>"
        call histdel("search", -1)
        let ret=1
    endif
    exe init_mid
    silent! norm! zt`g`yzs`g
    setlocal nomodified nomodifiable
    return ret
endf

" This was a part of ExpandOrCollapse previously. If single clicked on a
" file it would open and on a +/-, it would expand/collapse. The fiddling
" around with line and the massive marks here, is to try as much as possible
" to keep the explorer window un-shaky ;)
"
fu! s:OpenIfFile(where)
    norm! mgg0myHmh`gy2l
    let init_mid=line("'h")
    let ret=0
    if (match(getline(line(".")), "|-", 0) > 0)
        exe "norm! 0f-W"
        let path=s:GetPath()
        call s:OpenFile(path, a:where)
        let ret=1
    else
        norm! 0
        if search('\%'.line('.').'l[+-]]', "W")
            call s:ExpandOrCollapse()
        endif
        let ret=2
    endif
    exe init_mid
    silent! norm! zt`g`yzs`g
    return ret
endf

fu! s:Expand(dir)
    call s:VimGetListing(a:dir)
    exe "norm! yyp$F[R | \<Esc>lD0D0"
    if s:cur_list_len == 0
        norm! p
        return
    endif
    silent! put =s:cur_list.@"
    "norm! For vim 7. vim 7 leaves cursor after pasted chars.
    norm! `[
    let s:cur_list_len=s:cur_list_len-1
    if s:cur_list_len == 0
        let s:cur_list_len="k"
    endif
    silent! exe "norm! 0\<c-v>".s:cur_list_len."jI\<c-r>\"\<Esc>kdd"
endf

fu! s:StrTok(str,ci,sep)
    let cm=match(a:str, a:sep, a:ci)
    let @"=strpart(a:str, a:ci, cm-a:ci)
    return cm
endf

" Add your hooks for misc stuffs here. Like, for windows system, one
" can interpret a call to "My Computer" and return "a:, c:, d:" (how you
" get that is different) etc. Likewise, one can probably keep an
" ftp hook also here.
"
" The o/p of this function prefixes [+] for dirs and |- for files. Necessary
" preceding "| | |" needed to show the levels of dir has to be done by the
" caller". Sample s:cur_list:
" [+] A0
" [+] nvdata
"  |- fw116.zip
" 
" 
fu! s:VimGetListing(dir)
    let cur_dlist=""
    let cur_flist=""
    let curd_sep=""
    let curf_sep=""
    let ci=-1
    let s:cur_list=""
    let s:cur_list_len=-1

    let v:errmsg=""
    silent! exe "cd ".a:dir
    if v:errmsg != ""
        let s:cur_list_len=1
        let s:cur_list="Permission denied for ".a:dir." :(\n"
        return
    endif
    if s:see_dot
        let wildcard='.*\|*'
    else
        let wildcard='*'
    endif
    exe "let cur_alist=glob('".wildcard."')"
    " The foll one is just to take out . and .. files on unix systmes
    let cur_alist=substitute(cur_alist,"^\\.\n\\.\\.\\(\n\\)\\=",'','')
    if cur_alist == ""
        let s:cur_list_len=1
        let s:cur_list="Empty directory :-c\n"
        silent! cd -
        return
    endif
    let cur_alist=cur_alist."\n"
    let a_timer=localtime()
    "3 second timer
    let timeout=3
    while (1)
        if !g:ake_timeout && localtime() > a_timer+timeout
            let s:cur_list_len=2
            let s:cur_list="directory too big :-<\nrun, \"let g:ake_timeout=1\" to see the contents\n"
            silent! cd -
            return
        endif
        let ci=s:StrTok(cur_alist, ci+1, "\n")
        let s:cur_list_len=s:cur_list_len+1
        if !ci || ci == -1
            break
        endif
        if isdirectory(@")
            let cur_dlist=cur_dlist.curd_sep."[+] ".@"
            let curd_sep="\n"
            continue
        endif
        let ext=tolower(escape(fnamemodify(@",":e"), '~'))
        if (ext != "") 
            if ( (match(s:ignore_files, ",".ext.",") >= 0) ||
\                ((s:wish_files != ",,") && (match(s:wish_files, ",".ext.",") < 0)) )
                let s:cur_list_len=s:cur_list_len-1
                continue
            endif
        endif
        if filereadable(@")
            let cur_flist=cur_flist.curf_sep." |- ".@"
            let curf_sep="\n"
        elseif @" != ""
            let cur_flist=cur_flist.curf_sep." |- ".@"
            let curf_sep="\n"
        endif
    endwhile
    let s:cur_list=cur_dlist.curd_sep.cur_flist.curf_sep
    silent! cd -
endf

fu! Explore(start, ...)
    "CHECK: move to the explorer window and do
    " Remove trailing /s
    let dir=substitute(a:start,'\(.*.\)/$','\1','')
    "call s:PreInit()
    if !isdirectory(dir)
        echo "Invalid directory: ".dir
        return
    endif
    call s:Init()
    let s:state="uninit"
    if (s:state == "uninit")
        if !search('^\[[+-]] '.dir.'$', "w")
            call s:AddLabel(dir)
            silent! norm! Gf[
        endif
        if !(a:0 && a:1 == "de")
            norm! ly2l
            if (@" == "+]")
                call s:ExpandOrCollapse()
            endif
        endif
        let s:state = "init"
    elseif (s:state == "init")
        echo "not implemented yet"
    endif
    setlocal nomodified nomodifiable nowrap
endf

"main()
let s:src_dir=expand("<sfile>:p:h")
let s:assoc_file="RECfg.txt"

com! -nargs=* -complete=dir Explore call Explore(<f-args>)
call s:Init()
"------------------------------------------------------------------------------"
" vim:ai:et:sw=4:ts=4:fo=tcroq:com+=b\:\"
