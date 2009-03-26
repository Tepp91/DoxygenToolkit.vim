" DoxygenToolkit.vim
" Brief: Usefull tools for Doxygen (comment, author, license).
" Version: 0.2.3
" Date: 03/26/09
" Author: Mathias Lorente
"
" TODO: add automatically (option controlled) in/in out flags to function
"       parameters
" TODO: (Python) Check default paramareters defined as list/dictionnary/tuple
"
" Note: Added @version tag into the DocBlock generated by DoxygenAuthorFunc()
"       (thanks to Dave Walter).
"       The version string can be defines into your .vimrc file with 
"       g:DoxygenToolkit_versionString or it will be asked the first time the
"       function is called (same behavior as @author tag). Example: 
"                 /// \file foo.cpp
"                 /// \brief 
"                 /// \author Dave Walter
"                 /// \version 1.0
"                 /// \date 2009-03-26
"
" Note: Comments are now allowed in function declaration. Example:
"   - C/C++:   void func( int foo, // first param
"                         int bar  /* second param */ );
"
"   - Python:  def func( foo,  # first param
"                        bar ) # second param
"
" Note: Bug correction (many thanks to Alexey Radkov)
"   - C/C++: following function/method are now correctly documented:
"      - operator(),
"      - constructor with initialization parameter(s),
"      - pure virtual method,
"      - const method.
"   - Python:
"      - Single line function are now correctly documented.
"
" Note: The main function has been rewritten (I hope it is cleaner).
"   - There is now support for function pointer as parameter (C/C++).
"   - You can configure the script to get one line documentation (for
"     attribute instance for example, you need to set
"     g:DoxygenToolkit_compactOneLineDoc to "yes").
"
"   - NEW: Support Python scripts:
"      - Function/method are not scanned, so by default they are considered
"        as if they always return something (modify this behavior by defining
"        g:DoxygenToolkit_python_autoFunctionReturn to "no")
"      - self parameter is automatically ignored when scanning function
"        parameters (you can change this behavior by defining
"        g:DoxygenToolkit_python_autoRemoveSelfParam to "no")
"
" Note: Number of lines scanned is now configurable. Default value is still 10
"     lines. (Thanks to Spencer Collyer for this improvement).
"
" Note: Bug correction : function that returns null pointer are correctly
"     documented (Thanks to Ronald WAHL for his report and patch).
"
" Note: Remove header and footer from doxygen documentation
"   - Generated documentation with block header/footer activated (see
"     parameters g:DoxygenToolkit_blockHeader and
"     g:DoxygenToolkit_blockFooter) do not integrate header and footer
"     anymore.
"     Thanks to Justin RANDALL for this.
"     Now comments are as following:
"     /* --- My Header --- */             // --- My Header ---
"     /**                                 /// @brief ...
"      *  @brief ...                or    // --- My Footer ---
"      */
"     /* -- My Footer --- */
"
" Note: Changes to customize cinoptions
"   - New option available for cinoptions : g:DoxygenToolkit_cinoptions
"     (default value is still c1C1)
"     Thanks to Arnaud GODET for this. Now comment can have the following
"     look:
"     /**                      /**
"     *       and not only     *
"     */                       */
" Note: Changes for linux kernel comment style
"   - New option are available for brief tag and parameter tag ! Now there is
"     a pre and a post tag for each of these tag.
"   - You can define 'let g:DoxygenToolkit_briefTag_funcName = "yes"' to add
"     the name of commented function between pre-brief tag and post-brief tag.
"   - With these new features you can get something like:
"     /**
"      * @brief MyFunction -
"      *
"      * @param foo:
"      * @param bar:
"      */
" Note: Changes suggested by Soh Kok Hong:
"   - Fixed indentation in comments
"     ( no more /**               /**
"                 *       but      *
"                 */               */     )
" Note: Changes made by Jason Mills:
"   - Fixed \n bug which resulted in comments being screwed up
"   - Added use of doxygen /// comments.
" Note: Changes made by Mathias Lorente on 05/25/04
"   - Fixed filename bug when including doxygen author comment whereas file
"     has not been open directly on commamd line.
"   - Now /// or /** doxygen comments are correctly integrated (except for
"     license).
" Note: Changes made by Mathias Lorente on 08/02/04
"   - Now include only filename in author comment (no more folder...)
"   - Fixed errors with function with no indentation.
"
"
" Currently five purposes have been defined :
"
" Generates a doxygen license comment.  The tag text is configurable.
"
" Generates a doxygen author skeleton.  The tag text is configurable.
"
" Generates a doxygen comment skeleton for a C, C++ or Python function or class,
" including @brief, @param (for each named argument), and @return.  The tag
" text as well as a comment block header and footer are configurable.
" (Consequently, you can have \brief, etc. if you wish, with little effort.)
" 
" Ignore code fragment placed in a block defined by #ifdef ... #endif (C/C++).  The
" block name must be given to the function.  All of the corresponding blocks
" in all the file will be treated and placed in a new block DOX_SKIP_BLOCK (or
" any other name that you have configured).  Then you have to update
" PREDEFINED value in your doxygen configuration file with correct block name.
" You also have to set ENABLE_PREPROCESSING to YES.
" 
" Generate a doxygen group (begining and ending). The tag text is
" configurable.
"
" Use:
" - Type of comments (C/C++: /// or /** ... */, Python: ## and # ) :
"   In vim, default C++ comments are : /** ... */. But if you prefer to use ///
"   Doxygen comments just add 'let g:DoxygenToolkit_commentType = "C++"'
"   (without quotes) in your .vimrc file
"
" - License :
"   In vim, place the cursor on the line that will follow doxygen license
"   comment.  Then, execute the command :DoxLic.  This will generate license
"   comment and leave the cursor on the line just after.
"
" - Author :
"   In vim, place the cursor on the line that will follow doxygen author
"   comment.  Then, execute the command :DoxAuthor.  This will generate the
"   skeleton and leave the cursor just after @author tag if no variable
"   define it, or just after the skeleton.
"
" - Function / class comment :
"   In vim, place the cursor on the line of the function header (or returned
"   value of the function) or the class.  Then execute the command :Dox.  This
"   will generate the skeleton and leave the cursor after the @brief tag.
"
" - Ignore code fragment :
"   In vim, if you want to ignore all code fragment placed in a block such as :
"     #ifdef DEBUG
"     ...
"     #endif
"   You only have to execute the command :DoxUndoc(DEBUG) !
"   
" - Group :
"   In vim, execute the command :DoxBlock to insert a doxygen block on the
"   following line.
"
" Limitations:
" - Assumes that the function name (and the following opening parenthesis) is
"   at least on the third line after current cursor position.
" - Not able to update a comment block after it's been written.
" - Blocks delimiters (header and footer) are only included for function
"   comment.
" - Assumes that cindent is used.
" - Comments in function parameters (such as void foo(int bar /* ... */, baz))
"   are not yet supported.
"
"
" Example:
" Given:
" int
"   foo(char mychar,
"       int myint,
"       double* myarray,
"       int mask = DEFAULT)
" { //...
" }
"
" Issuing the :Dox command with the cursor on the function declaration would
" generate
" 
" /**
"  * @brief
"  *
"  * @param mychar
"  * @param myint
"  * @param myarray
"  * @param mask
"  *
"  * @return
"  */
"
"
" To customize the output of the script, see the g:DoxygenToolkit_*
" variables in the script's source.  These variables can be set in your
" .vimrc.
"
" For example, my .vimrc contains:
" let g:DoxygenToolkit_briefTag_pre="@Synopsis  "
" let g:DoxygenToolkit_paramTag_pre="@Param "
" let g:DoxygenToolkit_returnTag="@Returns   "
" let g:DoxygenToolkit_blockHeader="--------------------------------------------------------------------------"
" let g:DoxygenToolkit_blockFooter="----------------------------------------------------------------------------"
" let g:DoxygenToolkit_authorName="Mathias Lorente"
" let g:DoxygenToolkit_licenseTag="My own license"   <-- Does not end with
" "\<enter>"


" Verify if already loaded
"if exists("loaded_DoxygenToolkit")
"	echo 'DoxygenToolkit Already Loaded.'
"	finish
"endif
let loaded_DoxygenToolkit = 1
"echo 'Loading DoxygenToolkit...'
let s:licenseTag = "Copyright (C) \<enter>"
let s:licenseTag = s:licenseTag . "This program is free software; you can redistribute it and/or\<enter>"
let s:licenseTag = s:licenseTag . "modify it under the terms of the GNU General Public License\<enter>"
let s:licenseTag = s:licenseTag . "as published by the Free Software Foundation; either version 2\<enter>"
let s:licenseTag = s:licenseTag . "of the License, or (at your option) any later version.\<enter>\<enter>"
let s:licenseTag = s:licenseTag . "This program is distributed in the hope that it will be useful,\<enter>"
let s:licenseTag = s:licenseTag . "but WITHOUT ANY WARRANTY; without even the implied warranty of\<enter>"
let s:licenseTag = s:licenseTag . "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\<enter>"
let s:licenseTag = s:licenseTag . "GNU General Public License for more details.\<enter>\<enter>"
let s:licenseTag = s:licenseTag . "You should have received a copy of the GNU General Public License\<enter>"
let s:licenseTag = s:licenseTag . "along with this program; if not, write to the Free Software\<enter>"
let s:licenseTag = s:licenseTag . "Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.\<enter>"

" Common standard constants
if !exists("g:DoxygenToolkit_briefTag_pre")
	let g:DoxygenToolkit_briefTag_pre = "@brief "
endif
if !exists("g:DoxygenToolkit_briefTag_post")
	let g:DoxygenToolkit_briefTag_post = ""
endif
if !exists("g:DoxygenToolkit_paramTag_pre")
	let g:DoxygenToolkit_paramTag_pre = "@param "
endif
if !exists("g:DoxygenToolkit_paramTag_post")
	let g:DoxygenToolkit_paramTag_post = ""
endif
if !exists("g:DoxygenToolkit_returnTag")
	let g:DoxygenToolkit_returnTag = "@return "
endif
if !exists("g:DoxygenToolkit_blockHeader")
	let g:DoxygenToolkit_blockHeader = ""
endif
if !exists("g:DoxygenToolkit_blockFooter")
	let g:DoxygenToolkit_blockFooter = ""
endif
if !exists("g:DoxygenToolkit_licenseTag")
	let g:DoxygenToolkit_licenseTag = s:licenseTag
endif
if !exists("g:DoxygenToolkit_fileTag")
	let g:DoxygenToolkit_fileTag = "@file "
endif
if !exists("g:DoxygenToolkit_authorTag")
	let g:DoxygenToolkit_authorTag = "@author "
endif
if !exists("g:DoxygenToolkit_dateTag")
	let g:DoxygenToolkit_dateTag = "@date "
endif
if !exists("g:DoxygenToolkit_versionTag")
  let g:DoxygenToolkit_versionTag = "@version "
endif
if !exists("g:DoxygenToolkit_undocTag")
	let g:DoxygenToolkit_undocTag = "DOX_SKIP_BLOCK"
endif
if !exists("g:DoxygenToolkit_blockTag")
	let g:DoxygenToolkit_blockTag = "@name "
endif
if !exists("g:DoxygenToolkit_classTag")
	let g:DoxygenToolkit_classTag = "@class "
endif

if !exists("g:DoxygenToolkit_cinoptions")
    let g:DoxygenToolkit_cinoptions = "c1C1"
endif
if !exists("g:DoxygenToolkit_startCommentTag ")
	let g:DoxygenToolkit_startCommentTag = "/** "
	let g:DoxygenToolkit_startCommentBlock = "/* "
endif
if !exists("g:DoxygenToolkit_interCommentTag ")
	let g:DoxygenToolkit_interCommentTag = "* "
endif
if !exists("g:DoxygenToolkit_interCommentBlock ")
	let g:DoxygenToolkit_interCommentBlock = "* "
endif
if !exists("g:DoxygenToolkit_endCommentTag ")
	let g:DoxygenToolkit_endCommentTag = "*/"
	let g:DoxygenToolkit_endCommentBlock = "*/"
endif
if exists("g:DoxygenToolkit_commentType")
	if ( g:DoxygenToolkit_commentType == "C++" )
		let g:DoxygenToolkit_startCommentTag = "/// "
		let g:DoxygenToolkit_interCommentTag = "/// "
		let g:DoxygenToolkit_endCommentTag = ""
		let g:DoxygenToolkit_startCommentBlock = "// "
		let g:DoxygenToolkit_interCommentBlock = "// "
		let g:DoxygenToolkit_endCommentBlock = ""
  else
    let g:DoxygenToolkit_commentType = "C"
	endif
else
	let g:DoxygenToolkit_commentType = "C"
endif

" Compact documentation
" /**
"  * \brief foo      --->    /** \brief foo */
"  */
if !exists("g:DoxygenToolkit_compactOneLineDoc")
  let g:DoxygenToolkit_compactOneLineDoc = "no"
endif
" /**
"  * \brief foo             /**
"  *                         * \brief foo
"  * \param bar      --->    * \param bar
"  *                         * \return
"  * \return                 */
"  */
if !exists("g:DoxygenToolkit_compactDoc")
  let g:DoxygenToolkit_compactDoc = "no"
endif

" Necessary '\<' and '\>' will be added to each item of the list.
let s:ignoreForReturn = ['template', 'explicit', 'inline', 'static', 'virtual', 'void\([[:blank:]]*\*\)\@!', 'const', 'volatile']
if !exists("g:DoxygenToolkit_ignoreForReturn")
	let g:DoxygenToolkit_ignoreForReturn = s:ignoreForReturn[:]
else
	let g:DoxygenToolkit_ignoreForReturn += s:ignoreForReturn
endif
unlet s:ignoreForReturn

" Maximum number of lines to check for function parameters
if !exists("g:DoxygenToolkit_maxFunctionProtoLines")
	let g:DoxygenToolkit_maxFunctionProtoLines = 10
endif

" Add name of function/class/struct... after pre brief tag if you want
if !exists("g:DoxygenToolkit_briefTag_className")
	let g:DoxygenToolkit_briefTag_className = "no"
endif
if !exists("g:DoxygenToolkit_briefTag_structName")
	let g:DoxygenToolkit_briefTag_structName = "no"
endif
if !exists("g:DoxygenToolkit_briefTag_enumName")
	let g:DoxygenToolkit_briefTag_enumName = "no"
endif
if !exists("g:DoxygenToolkit_briefTag_namespaceName")
	let g:DoxygenToolkit_briefTag_namespaceName = "no"
endif
if !exists("g:DoxygenToolkit_briefTag_funcName")
	let g:DoxygenToolkit_briefTag_funcName = "no"
endif

" Keep empty line (if any) between comment and function/class/...
if !exists("g:DoxygenToolkit_keepEmptyLineAfterComment")
  let g:DoxygenToolkit_keepEmptyLineAfterComment = "no"
endif

" PYTHON specific
"""""""""""""""""
" Remove automatically self parameter from function to avoid its documantation
if !exists("g:DoxygenToolkit_python_autoRemoveSelfParam")
  let g:DoxygenToolkit_python_autoRemoveSelfParam = "yes"
endif
" Consider functions as if they always return something (default: yes)
if !exists("g:DoxygenToolkit_python_autoFunctionReturn")
  let g:DoxygenToolkit_python_autoFunctionReturn = "yes"
endif


""""""""""""""""""""""""""
" Doxygen license comment
""""""""""""""""""""""""""
function! <SID>DoxygenLicenseFunc()
  call s:InitializeParameters()

	" Test authorName variable
	if !exists("g:DoxygenToolkit_authorName")
		let g:DoxygenToolkit_authorName = input("Enter name of the author (generally yours...) : ")
	endif
	mark d
	let l:date = strftime("%Y")
	exec "normal O".s:startCommentBlock.substitute( g:DoxygenToolkit_licenseTag, "\<enter>", "\<enter>".s:interCommentBlock, "g" )
  if( s:endCommentBlock != "" )
    exec "normal o".s:endCommentBlock
  endif
	if( g:DoxygenToolkit_licenseTag == s:licenseTag )
		exec "normal %jA".l:date." - ".g:DoxygenToolkit_authorName
	endif
	exec "normal `d"

	call s:RestoreParameters()
endfunction


""""""""""""""""""""""""""
" Doxygen author comment
""""""""""""""""""""""""""
function! <SID>DoxygenAuthorFunc()
  call s:InitializeParameters()

	" Test authorName variable
	if !exists("g:DoxygenToolkit_authorName")
		let g:DoxygenToolkit_authorName = input("Enter name of the author (generally yours...) : ")
	endif

  " Test versionString variable
  if !exists("g:DoxygenToolkit_versionString")
    let g:DoxygenToolkit_versionString = input("Enter version string : ")
  endif

	" Get file name
	let l:fileName = expand('%:t')

	" Begin to write skeleton
  let l:insertionMode = s:StartDocumentationBlock()
	exec "normal ".l:insertionMode.s:interCommentTag.g:DoxygenToolkit_fileTag.l:fileName
	exec "normal o".s:interCommentTag.g:DoxygenToolkit_briefTag_pre
	mark d
	exec "normal o".s:interCommentTag.g:DoxygenToolkit_authorTag.g:DoxygenToolkit_authorName
  exec "normal o".s:interCommentTag.g:DoxygenToolkit_versionTag.g:DoxygenToolkit_versionString
	let l:date = strftime("%Y-%m-%d")
	exec "normal o".s:interCommentTag.g:DoxygenToolkit_dateTag.l:date
	if ( g:DoxygenToolkit_endCommentTag != "" )
		exec "normal o".s:endCommentTag
	endif

	" Move the cursor to the rigth position
	exec "normal `d"

  call s:RestoreParameters()
	startinsert!
endfunction


""""""""""""""""""""""""""
" Doxygen undocument function
" C/C++ only!
""""""""""""""""""""""""""
function! <SID>DoxygenUndocumentFunc(blockTag)
	let l:search = "#ifdef " . a:blockTag
	" Save cursor position and go to the begining of the file
	mark d
	exec "normal gg"

	while ( search(l:search, 'W') != 0 )
		exec "normal O#ifndef " . g:DoxygenToolkit_undocTag
		exec "normal j^%"
		if ( g:DoxygenToolkit_endCommentTag == "" )
			exec "normal o#endif // " . g:DoxygenToolkit_undocTag 
		else
			exec "normal o#endif /* " . g:DoxygenToolkit_undocTag . " */"
		endif
	endwhile

	exec "normal `d"
endfunction



""""""""""""""""""""""""""
" DoxygenBlockFunc
""""""""""""""""""""""""""
function! <SID>DoxygenBlockFunc()
  call s:InitializeParameters()

  let l:insertionMode = s:StartDocumentationBlock()
	exec "normal ".l:insertionMode.s:interCommentTag.g:DoxygenToolkit_blockTag
	mark d
	exec "normal o".s:interCommentTag."@{ ".s:endCommentTag
	exec "normal o".s:startCommentTag." @} ".s:endCommentTag
	exec "normal `d"

	call s:RestoreParameters()
	startinsert!
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Main comment function for class, attribute, function...
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! <SID>DoxygenCommentFunc()

  " Initialize default templates.
  " Assure compatibility with Python for classes (cf. endDocPattern).
  let l:emptyLinePattern = '^[[:blank:]]*$'
  let l:someNamePattern  = '[_[:alpha:]][_[:alnum:]]*'

  if( s:CheckFileType() == "cpp" )
    let l:someNameWithNamespacePattern  = l:someNamePattern.'\%(::'.l:someNamePattern.'\)*'
    let l:endDocPattern    = ';\|{\|\%([^:]\zs:\ze\%([^:]\|$\)\)'
    let l:commentPattern   = '\%(/*\)\|\%(//\)\'
    let l:templateParameterPattern = "<[^<>]*>"

    let l:classPattern     = '\<class\>[[:blank:]]\+\zs'.l:someNameWithNamespacePattern.'\ze.*\%('.l:endDocPattern.'\)'
    let l:structPattern    = '\<struct\>[[:blank:]]\+\zs'.l:someNameWithNamespacePattern.'\ze.*\%('.l:endDocPattern.'\)'
    let l:enumPattern      = '\<enum\>\%(\%([[:blank:]]\+\zs'.l:someNamePattern.'\ze[[:blank:]]*\)\|\%(\zs\ze[[:blank:]]*\)\)\%('.l:endDocPattern.'\)'
    let l:namespacePattern = '\<namespace\>[[:blank:]]\+\zs'.l:someNamePattern.'\ze[[:blank:]]*\%('.l:endDocPattern.'\)'

    let l:types = { "class": l:classPattern, "struct": l:structPattern, "enum": l:enumPattern, "namespace": l:namespacePattern }
  else
    let l:commentPattern   = '#\|^[[:blank:]]*"""'

    let l:classPattern     = '\<class\>[[:blank:]]\+\zs'.l:someNamePattern.'\ze.*:'
    let l:functionPattern  = '\<def\>[[:blank:]]\+\zs'.l:someNamePattern.'\ze.*:'

    let l:endDocPattern    = '\%(\<class\>\|\<def\>[^:]*\)\@<!$'

    let l:types = { "class": l:classPattern, "function": l:functionPattern }
  endif

  let l:lineBuffer       = getline( line( "." ) )
  let l:count            = 1
  let l:endDocFound      = 0

  let l:doc = { "type": "", "name": "None", "params": [], "returns": "" }

  " Mark current line for future use
  mark d

  " Look for function/method/... to document
  " We look only on the first three lines!
  while( match( l:lineBuffer, l:emptyLinePattern ) != -1 && l:count < 4 )
    exec "normal j"
    let l:lineBuffer = l:lineBuffer.' '.getline( line( "." ) )
    let l:count = l:count + 1
  endwhile
  " Error message when the buffer is still empty.
  if( match( l:lineBuffer, l:emptyLinePattern ) != -1 )
    call s:WarnMsg( "Nothing to document here!" )
    exec "normal `d" 
    return
  endif

  " Remove unwanted lines (ie: jump to the first significant line)
  if( g:DoxygenToolkit_keepEmptyLineAfterComment == "no" )
    " This erase previous mark
    mark d
  endif

  " Look for the end of the function/class/... to document
  " TODO does not work when function/class/... is commented out!
  let l:count = 0
  while( l:endDocFound == 0 && l:count < g:DoxygenToolkit_maxFunctionProtoLines )
    let l:lineBuffer = s:RemoveComments( l:lineBuffer )
    " Valid only for cpp. For Python it must be 'class ...:' or 'def ...:' or
    " '... EOL'.
    if( match( l:lineBuffer, l:endDocPattern ) != -1 )
      let l:endDocFound = 1
      continue
    endif
    exec "normal j"
    let l:lineBuffer = l:lineBuffer.' '.getline( line( "." ))
    let l:count = l:count + 1
  endwhile
  " Error message when the end of the function(/...) has not been found
  if( l:endDocFound == 0 )
    if( match( l:lineBuffer, l:emptyLinePattern ) != -1 )
      " Fall here when only comments have been found.
      call s:WarnMsg( "Nothing to document here!" )
      exec "normal `d" 
      return
    else
      call s:WarnMsg( "Cannot reach end of function/class/... declaration!" )
      exec "normal `d" 
      return
    endif
  endif

  " Trim the buffer
  let l:lineBuffer = substitute( l:lineBuffer, "^[[:blank:]]*\|[[:blank:]]$", "", "g" )

  " Remove any template parameter.
  if( s:CheckFileType() == "cpp" )
    while( match( l:lineBuffer, l:templateParameterPattern ) != -1 )
      let l:lineBuffer = substitute( l:lineBuffer, l:templateParameterPattern, "", "g" )
    endwhile
  endif

  " Look for the type
  for key in keys( l:types )
    "call s:WarnMsg( "[DEBUG] buffer:_".l:lineBuffer."_, test:_".l:types[key] )
    let l:name = matchstr( l:lineBuffer, l:types[key] )
    if( l:name != "" )
      let l:doc.type = key
      let l:doc.name = l:name

      " Python only. Functions are detected differently for C/C++.
      if( key == "function" )
        "call s:WarnMsg( "HERE !!!".l:lineBuffer )
        call s:ParseFunctionParameters( l:lineBuffer, l:doc )
      endif
      break
    endif
  endfor

  if( l:doc.type == "" )
    " Should be a function/method (cpp only) or an attribute.
    " (cpp only) Can also be an unnamed enum/namespace... (or something else ?)
    if( s:CheckFileType() == "cpp" )
      if( match( l:lineBuffer, '(' ) == -1 )
        if( match( l:lineBuffer, '\<enum\>' ) != -1 )
          let l:doc.type = 'enum'
        elseif( match( l:lineBuffer, '\<namespace\>' ) != -1 )
          let l:doc.type = 'namespace'
        else
          " TODO here we get a class attribute of something like that.
          "      We probably just need a \brief statement...
          let l:doc.type = 'attribute'
          " TODO Retrieve the name of the attribute.
          "      Do we really need it? I'm not sure for the moment.
        endif
      else
        let l:doc.type = 'function'
        call s:ParseFunctionParameters( l:lineBuffer, l:doc )
      endif
 
    " This is an attribute for Python
    else
      let l:doc.type = 'attribute'
    endif
  endif

  " Remove the function/class/... name when it is not necessary
  if( ( key == "class" && g:DoxygenToolkit_briefTag_className != "yes" ) || ( key == "struct" && g:DoxygenToolkit_briefTag_structName != "yes" ) || ( key == "enum" && g:DoxygenToolkit_briefTag_enumName != "yes" ) || ( key == "namespace" && g:DoxygenToolkit_briefTag_namespaceName != "yes" ) || ( l:doc.type == "function" && g:DoxygenToolkit_briefTag_funcName != "yes" ) )
    let l:doc.name = "None"

  " Remove namespace from the name of the class/function...
  elseif( s:CheckFileType() == "cpp" )
    let l:doc.name = substitute( l:doc.name, '\%('.l:someNamePattern.'::\)', '', 'g' )
  endif

  " Below, write what we have found
  """""""""""""""""""""""""""""""""

  call s:InitializeParameters()
  if( s:CheckFileType() == "python" && l:doc.type == "function" && g:DoxygenToolkit_python_autoFunctionReturn == "yes" )
    let l:doc.returns = "yes"
  endif

  " Header
	exec "normal `d" 
	if( g:DoxygenToolkit_blockHeader != "" )
		exec "normal O".s:startCommentBlock.g:DoxygenToolkit_blockHeader.s:endCommentBlock
    exec "normal `d" 
	endif
 
  " Brief
  if( g:DoxygenToolkit_compactOneLineDoc =~ "yes" && l:doc.returns != "yes" && len( l:doc.params ) == 0 )
    let s:compactOneLineDoc = "yes"
    exec "normal O".s:startCommentTag.g:DoxygenToolkit_briefTag_pre.g:DoxygenToolkit_briefTag_post
  else
    let s:compactOneLineDoc = "no"
    let l:insertionMode = s:StartDocumentationBlock()
    exec "normal ".l:insertionMode.s:interCommentTag.g:DoxygenToolkit_briefTag_pre.g:DoxygenToolkit_briefTag_post
  endif
  if( l:doc.name != "None" )
    exec "normal A".l:doc.name." "
  endif

  " Mark the line where the cursor will be positionned.
	mark d

  " Arguments/parameters
  if( g:DoxygenToolkit_compactDoc =~ "yes" )
    let s:insertEmptyLine = 0
  else
    let s:insertEmptyLine = 1
  endif
  for param in l:doc.params
    if( s:insertEmptyLine == 1 )
      exec "normal o".s:interCommentTag
      let s:insertEmptyLine = 0
    endif
    exec "normal o".s:interCommentTag.g:DoxygenToolkit_paramTag_pre.g:DoxygenToolkit_paramTag_post.param
  endfor

  " Returned value
  if( l:doc.returns == "yes" )
    if( g:DoxygenToolkit_compactDoc != "yes" )
      exec "normal o".s:interCommentTag
    endif
    exec "normal o".s:interCommentTag.g:DoxygenToolkit_returnTag
  endif

  " End (if any) of documentation block.
	if( s:endCommentTag != "" )
    if( s:compactOneLineDoc =~ "yes" )
      let s:execCommand = "A "
    else
      let s:execCommand = "o"
    endif
		exec "normal ".s:execCommand.s:endCommentTag
	endif

  " Footer
	if ( g:DoxygenToolkit_blockFooter != "" )
		exec "normal o".s:startCommentBlock.g:DoxygenToolkit_blockFooter.s:endCommentBlock
	endif
	exec "normal `d"

  call s:RestoreParameters()
  startinsert!

  " DEBUG purpose only
  "call s:WarnMsg( "Found a ".l:doc.type." named ".l:doc.name." (env: ".s:CheckFileType().")." )
  "if( l:doc.type == "function" )
  "  let l:funcReturn = "returns something."
  "  if( l:doc.returns == "" )
  "    let l:funcReturn = "doesn't return anything."
  "  endif
  "  call s:WarnMsg( " - which ".l:funcReturn )
  "  call s:WarnMsg( " - which has following parameter(s):" )
  "  for param in l:doc.params
  "    call s:WarnMsg( "   - ".param )
  "  endfor
  "endif

endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Write the beginning of the documentation block:
" - C and Python format: insert '/**' and '##' respectively then a linefeed,
" - C++ insert '///' and continue on the same line
"
" This function return the insertion mode which should be used for the next
" call to 'normal'.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:StartDocumentationBlock()
  " For C++ documentation format we do not need first empty line
  if( s:startCommentTag != s:interCommentTag )
    exec "normal O".s:startCommentTag
    let l:insertionMode = "o"
  else
    let l:insertionMode = "O"
  endif
  return l:insertionMode
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remove comments from the given buffer.
" - Remove everything after '//' or '#'.
" - Remove everything between '/*' and '*/' or keep '/*' if '*/' is not present.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:RemoveComments( lineBuffer )
  if( s:CheckFileType() == "cpp" )
    " Remove C++ (//) comment.
    let l:lineBuffer = substitute( a:lineBuffer, '[[:blank:]]*\/\/.*$', '', '')
    " Remove partial C (/* ...) comment: /* foo bar   -->   /*
    " '/*' is preserved until corresponding '*/' is found. Other part of the
    " comment is discarded to prevent the case where it contains characters
    " corresponding to the endDoc string.
    let l:lineBuffer = substitute( l:lineBuffer, '\%(\/\*\zs.*\ze\)\&\%(\%(\/\*.*\*\/\)\@!\)', '', '')
    " Remove C (/* ... */) comment.
    let l:lineBuffer = substitute( l:lineBuffer, '\/\*.\{-}\*\/', '', 'g')
  else
    let l:lineBuffer = substitute( a:lineBuffer, '[[:blank:]]*#.*$', '', '')
  endif
  return l:lineBuffer
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Retrieve file type.
" - Default type is still 'cpp'.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:CheckFileType()
  if( &filetype == "python" )
    let l:fileType       = "python"
  else
    let l:fileType       = "cpp"
  endif
  return l:fileType
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Parse the buffer and set the doc parameter.
" - Functions which return pointer to function are not supported.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:ParseFunctionParameters( lineBuffer, doc )
"  call s:WarnMsg( 'IN__'.a:lineBuffer )
  let l:paramPosition = matchend( a:lineBuffer, 'operator[[:blank:]]*([[:blank:]]*)' )
  if ( l:paramPosition == -1 )
    let l:paramPosition = stridx( a:lineBuffer, '(' )
  else
    let l:paramPosition = stridx( a:lineBuffer, '(', l:paramPosition )
  endif


  " (cpp only) First deal with function name and returned value.
  " Function name has alredy been retrieved for Python and we need to parse
  " all the function definition to know whether a value is returned or not.
  if( s:CheckFileType() == "cpp" )
    let l:functionBuffer = strpart( a:lineBuffer, 0, l:paramPosition )
    for ignored in g:DoxygenToolkit_ignoreForReturn
      let l:functionBuffer = substitute( l:functionBuffer, '\<'.ignored.'\>', '', 'g' )
    endfor
    let l:functionReturnAndName = split( l:functionBuffer, '[[:blank:]*]' )
    if( len( l:functionReturnAndName ) > 1 )
      let a:doc.returns = 'yes'
    endif
    let a:doc.name = l:functionReturnAndName[-1]
  endif

  " Work on parameters.
  let l:parametersBuffer = strpart( a:lineBuffer, l:paramPosition + 1 )
  " Remove trailing closing bracket and everything that follows and trim.
  if( s:CheckFileType() == "cpp" )
    let l:parametersBuffer = substitute( l:parametersBuffer, ')[^)]*\%(;\|{\|\%([^:]:\%([^:]\|$\)\)\).*', '', '' )
  else
    let l:parametersBuffer = substitute( l:parametersBuffer, ')[^)]*:.*', '', '' )
  endif
  let l:parametersBuffer = substitute( l:parametersBuffer, '^[[:blank:]]*\|[[:blank:]]*$', '', '' )

  " Remove default parameter values (if any).
  let l:index = stridx( l:parametersBuffer, '=' )
  let l:startIndex = l:index
  while( l:index != -1 )
    " Look for the next colon...
    let l:colonIndex = stridx( l:parametersBuffer, ',', l:startIndex )
    if( l:colonIndex == -1 )
      let l:colonIndex = strlen( l:parametersBuffer )
    endif
    let l:paramBuffer = strpart( l:parametersBuffer, l:index, l:colonIndex - l:index )
    if( s:CountBrackets( l:paramBuffer ) == 0 )
      " Everything in [l:index, l:colonIndex[ can be removed.
      let l:parametersBuffer = substitute( l:parametersBuffer, l:paramBuffer, '', '' )
      let l:index = stridx( l:parametersBuffer, '=' )
      let l:startIndex = l:index
    else
      " Parameter initialization contains brakets and colons...
      let l:startIndex = l:colonIndex + 1
    endif
  endwhile

  "call s:WarnMsg( "[DEBUG]: ".l:parametersBuffer )
  " Now, work on each parameter.
  let l:params = []
  let l:index = stridx( l:parametersBuffer, ',' )
  while( l:index != -1 )
    let l:paramBuffer = strpart( l:parametersBuffer, 0, l:index )
    if( s:CountBrackets( l:paramBuffer ) == 0 )
      let l:params = add( l:params, s:ParseParameter( l:paramBuffer ) )
      let l:parametersBuffer = strpart( l:parametersBuffer, l:index + 1 )
      let l:index = stridx( l:parametersBuffer, ',' )
    else
      let l:index = stridx( l:parametersBuffer, ',', l:index + 1 )
    endif
  endwhile
  if( strlen( l:parametersBuffer ) != 0 )
    let l:params = add( l:params, s:ParseParameter( l:parametersBuffer ) )
  endif

  if( s:CheckFileType() == "cpp" )
    call filter( l:params, 'v:val !~ "void"' )
  else
    if( g:DoxygenToolkit_python_autoRemoveSelfParam == "yes" )
      call filter( l:params, 'v:val !~ "self"' )
    endif
  endif

  for param in l:params
    call add( a:doc.params, param )
    "call s:WarnMsg( '[DEBUG]:OUT_'.param )
  endfor
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Parse given parameter and return its name.
" It is easy to do unless you use function's pointers...
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:ParseParameter( param )
  let l:paramName = "Unknown"
  let l:firstIndex = stridx( a:param, '(' )

  if( l:firstIndex == -1 )
    let l:paramName =  split( a:param, '[[:blank:]*]' )[-1]
  else
    if( l:firstIndex != 0 )
      let l:startIndex = 0
    else
      let l:startIndex = stridx( a:param, ')' )
      if( l:startIndex == -1 ) " Argggg...
        let l:paramName =  a:param
      else
        let l:startIndex += 1
        while( s:CountBrackets( strpart( a:param, 0, l:startIndex ) ) != 0 )
          let l:startIndex = stridx( a:param, ')', l:startIndex + 1 ) + 1
          if( l:startIndex == -1) " Argggg...
            let l:paramName =  a:param
          endif
        endwhile
      endif
    endif

    if( l:startIndex != -1 )
      let l:startIndex = stridx( a:param, '(', l:startIndex ) + 1
      let l:endIndex = stridx( a:param, ')', l:startIndex + 1 )
      let l:param = strpart( a:param, l:startIndex, l:endIndex - l:startIndex )
      let l:paramName =  substitute( l:param, '^[[:blank:]*]*\|[[:blank:]*]*$', '', '' )
    else
      " Something really wrong has happened.
      let l:paramName =  a:param
    endif
  endif

  return l:paramName
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Define start/end documentation format and backup generic parameters.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:InitializeParameters()
  if( s:CheckFileType() == "cpp" )
    let s:startCommentTag   = g:DoxygenToolkit_startCommentTag
    let s:interCommentTag   = g:DoxygenToolkit_interCommentTag
    let s:endCommentTag     = g:DoxygenToolkit_endCommentTag
    let s:startCommentBlock = g:DoxygenToolkit_startCommentBlock
    let s:interCommentBlock = g:DoxygenToolkit_interCommentBlock
    let s:endCommentBlock   = g:DoxygenToolkit_endCommentBlock
  else
    let s:startCommentTag   = "## "
    let s:interCommentTag   = "# "
    let s:endCommentTag     = ""
    let s:startCommentBlock = "# "
    let s:interCommentBlock = "# "
    let s:endCommentBlock   = ""
  endif

	" Backup standard comment expension and indentation
	let s:commentsBackup = &comments
	let &comments        = ""
	let s:cinoptionsBackup = &cinoptions
	let &cinoptions        = g:DoxygenToolkit_cinoptions
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Restore previously backuped parameters.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:RestoreParameters()
	" Restore standard comment expension and indentation
	let &comments = s:commentsBackup
	let &cinoptions = s:cinoptionsBackup
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Count opened/closed brackets in the given buffer.
" Each opened bracket increase the counter by 1.
" Each closed bracket decrease the counter by 1.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:CountBrackets( buffer )
  let l:count =  len( split( a:buffer, '(', 1 ) )
  let l:count -= len( split( a:buffer, ')', 1 ) )
  return l:count
endfunction


"""""""""""""""""""""""""""""""""""
" Simple warning message function
"""""""""""""""""""""""""""""""""""
function! s:WarnMsg( msg )
  echohl WarningMsg
  echo a:msg
  echohl None
  return
endfunction

""""""""""""""""""""""""""
" Shortcuts...
""""""""""""""""""""""""""
command! -nargs=0 Dox :call <SID>DoxygenCommentFunc()
command! -nargs=0 DoxLic :call <SID>DoxygenLicenseFunc()
command! -nargs=0 DoxAuthor :call <SID>DoxygenAuthorFunc()
command! -nargs=1 DoxUndoc :call <SID>DoxygenUndocumentFunc(<q-args>)
command! -nargs=0 DoxBlock :call <SID>DoxygenBlockFunc()

