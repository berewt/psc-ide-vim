" Inits ----------------------------------------------------------------------
if !exists("b:loaded_psc_ide_vim")
  let b:loaded_psc_ide_vim = v:true
else
  finish
endif

if !exists("g:loaded_psc_ide_vim")
  let g:loaded_psc_ide_vim = v:false
endif

if !exists('g:psc_ide_suggestions')
  let g:psc_ide_suggestions = {}
endif

" Options -------------------------------------------------------------------
if !exists('g:psc_ide_log_level')
  let g:psc_ide_log_level = 0
endif

if !exists('g:psc_ide_auto_imports')
  let g:psc_ide_auto_imports = 0
endif

if !exists('g:psc_ide_server_port')
  let g:psc_ide_server_port = 4242
endif

if !exists('g:psc_ide_check_output_dir')
  let g:psc_ide_check_output_dir = 1
endif

if !exists('g:psc_ide_notify')
  let g:psc_ide_notify = v:true
endif

if !exists('g:psc_ide_filter_prelude_modules')
  let g:psc_ide_filter_prelude_modules = v:true
endif

if !exists('g:psc_ide_omnicompletion_filter_modules')
  let g:psc_ide_omnicompletion_filter_modules = v:false
endif

if !exists('g:psc_ide_omnicompletion_sort_by')
  " flex / identifier / module
  let g:psc_ide_omnicompletion_sort_by = "flex"
endif

if !exists("g:psc_ide_omnicompletion_prefix_filter")
  " with this option will let purs ide filter by prefix (this disables flex
  " matching) (tip: use i^xu when searching for a command)
  let g:psc_ide_omnicompletion_prefix_filter = v:true
endif

let s:prelude = [
  \ "Control.Applicative",
  \ "Control.Apply",
  \ "Control.Bind",
  \ "Control.Category",
  \ "Control.Monad",
  \ "Control.Semigroupoid",
  \ "Data.Boolean",
  \ "Data.BooleanAlgebra",
  \ "Data.Bounded",
  \ "Data.CommutativeRing",
  \ "Data.Eq",
  \ "Data.EuclideanRing",
  \ "Data.Field",
  \ "Data.Function",
  \ "Data.Functor",
  \ "Data.HeytingAlgebra",
  \ "Data.NaturalTransformation",
  \ "Data.Ord",
  \ "Data.Ordering",
  \ "Data.Ring",
  \ "Data.Semigroup",
  \ "Data.Semiring",
  \ "Data.Show",
  \ "Data.Unit",
  \ "Data.Void",
  \ ]

if !exists('g:psc_ide_filter_submodules')
  " this might hide some modules, e.g. React.DOM.Dynamic will be hidden by
  " React.DOM module, you can adjust g:psc_ide_filter_submodules_do_not_hide
  " variable.
  let g:psc_ide_filter_submodules = v:false
endif

if !exists("g:psc_ide_filter_submodules_do_not_hide")
  let g:psc_ide_filter_submodules_do_not_hide = [ "React.DOM.Dynamic" ]
endif

" Adding iskeyword symbols to improve <cword> expansion- ---------------------
" 124 = |
setl iskeyword+=<,>,$,#,+,-,*,/,%,',&,=,!,:,124,^
setl omnifunc=PSCIDEomni
setl completefunc=PSCIDEcomplete

" Syntastic initialization ---------------------------------------------------
if exists('g:syntastic_extra_filetypes')
  call add(g:syntastic_extra_filetypes, 'purescript')
else
  let g:syntastic_extra_filetypes = ['purescript']
endif

let g:syntastic_purescript_checkers = ['pscide']

" COMMANDS -------------------------------------------------------------------
com! -buffer PSCIDEend call PSCIDEend()
com! -buffer -bang PSCIDEload call PSCIDEload(0, <q-bang>)
com! -buffer -nargs=* PSCIDEimportIdentifier call PSCIDEimportIdentifier(len(<q-args>) ? <q-args> : expand("<cword>"))
com! -buffer -nargs=* PSCIDEgoToDefinition call PSCIDEgoToDefinition(len(<q-args>) ? <q-args> : expand("<cword>"))
com! -buffer PSCIDEaddTypeAnnotation call PSCIDEaddTypeAnnotation(matchstr(getline(line(".")), '^\s*\zs\k\+\ze'))
com! -buffer PSCIDEcwd call PSCIDEcwd()
com! -buffer PSCIDEaddClause call PSCIDEaddClause()
com! -buffer -nargs=1 PSCIDEcaseSplit call PSCIDEcaseSplit(<q-args>)
com! -buffer -nargs=* PSCIDEtype call PSCIDEtype(len(<q-args>) ? <q-args> : expand("<cword>"), v:true)
com! PSCIDElistImports call PSCIDElistImports()
com! -buffer -bang PSCIDEapplySuggestion call PSCIDEapplySuggestion(<q-bang>)
com! -buffer PSCIDEaddImportQualifications call PSCIDEaddImportQualifications()
com! -buffer -nargs=* PSCIDEpursuit call PSCIDEpursuit(len(<q-args>) ? <q-args> : expand("<cword>"))
com! -buffer PSCIDEprojectValidate call PSCIDEprojectValidate()
com! -buffer PSCIDElist call PSCIDElist()
com! -buffer -count=1 PSCIDEerr call PSCIDEerr(<count>)
com! -buffer PSCIDEstart call PSCIDEstart(0)
com! -buffer -nargs=* PSCIDEsearch call PSCIDEsearch(len(<q-args>) ? <q-args> : expand("<cword>"))
com! -buffer -nargs=* -complete=custom,PSCIDEimportModuleCompletion PSCIDEimportModule call PSCIDEimportModule(len(<q-args>) ? <q-args> : expand("<cword>"))

" AUTOSTART ------------------------------------------------------------------
fun! s:autoStart()
  if g:psc_ide_syntastic_mode == 0
    com! PSCIDErebuild call PSCIDErebuild(1, function("PSCIDEerrors"))
    augroup purescript
      au! BufWritePost *.purs call PSCIDErebuild(1, function("PSCIDEerrors"))
      au! BufAdd *.purs call PSCIDErebuild(1, function("PSCIDEerrors"))
    augroup END
  endif

  silent! call PSCIDEstart(0)
  silent! call PSCIDEload(0, "")
endfun

" INTERNALS -------------------------------------------------------------------
" execute only once so we do not redefine functions when they are running
if g:loaded_psc_ide_vim
  call s:autoStart()
  finish
endif
let g:loaded_psc_ide_vim = v:true

" START ----------------------------------------------------------------------
if !exists('s:pscidestarted')
  let s:pscidestarted = 0
endif
if !exists('s:pscideexternal')
  let s:pscideexternal = 0
endif
if !exists('s:projectvalid')
  let s:projectvalid = 0
endif

let s:psc_ide_server = v:null
"Looks for bower.json, assumes that's the root directory, starts
"`purs ide server` in the background
"Returns Nothing
function! PSCIDEstart(silent)
  if s:pscidestarted == 1 
    return
  endif
  let loglevel = a:silent == 1 ? 1 : 0

  let dir = s:findRoot()
  call s:log("PSCIDEstart: cwd " . dir, 3)

  if empty(dir)
    echom "No psc-package.json or bower.json found, couldn't start `purs ide server`"
    return
  endif

  let command = [ 
	\ "purs", "ide", "server",
	\ "-p", g:psc_ide_server_port,
	\ "-d", dir,
	\ "src/**/*.purs",
	\ "bower_components/**/*.purs",
	\ ]

  exe "lcd" dir
  let jobid = async#job#start(
	\ command,
	\ { "on_stderr": { ch, msg -> s:echoWarn(s:toString(msg), v:true) }
	\ , "on_stdout": { ch, msg -> type(msg) == v:t_string ? s:echoLog(msg) : v:null }
	\ , "on_exit": function("s:onServerExit")
	\ }
	\ )
  lcd -

  call s:log("PSCIDEstart: Sleeping for 100ms so server can start up", 1)
  sleep 100m
  let s:pscidestarted = 1
endfunction

let s:onServerExit = v:true
function! s:onServerExit(ch, msg, ev)
  if s:onServerExit
    call s:echoLog(s:toString(a:ev), v:true)
  endif
  let s:pscidestarted = 0
endfunction

if v:version > 704 || (v:version == 704 && has('patch279'))
  function! s:globpath(dir, pattern) abort
    return globpath(a:dir, a:pattern, 1, 1)
  endfunction
else
  function! s:globpath(dir, pattern) abort
    return split(globpath(a:dir, a:pattern, 1), '\n')
  endfunction
endif


" Display choices from a list of dicts for the user to select from with
" alphanumerals as shortcuts
function! s:pickOption(message, options, labelKey)
  let displayOptions = copy(a:options)
  call map(displayOptions, '(v:key > 9 ? nr2char(v:key + 55) : v:key) . " " . v:val[a:labelKey]')
  let choice = confirm(a:message, join(displayOptions, "\n"))
  if choice
    return {'picked': v:true, 'option': a:options[choice - 1]}
  else
    return {'picked': v:false, 'option': v:null}
  endif
endfunction

" Find root folder ----------------------------------------------------
function! s:findRoot()
  let pscPackage = findfile("psc-package.json", fnameescape(expand("%:p:h")).";")
  if !empty(pscPackage)
    return fnamemodify(pscPackage, ":h:p")
  else
    let bower = findfile("bower.json", fnameescape(expand("%:p:h")).";")
    if !empty(bower)
      return fnamemodify(bower, ":h:p")
    else
      return ""
    endif
  endfor
endfunction

" END ------------------------------------------------------------------------
" Tell the `purs ide server` to quit
function! PSCIDEend()
  if s:pscideexternal == 1
    return
  endif
  let jobid = async#job#start(
	\ ["purs", "ide", "client", "-p", g:psc_ide_server_port],
	\ { "on_exit": {job, status, ev -> s:PSCIDEendCallback() }
	\ , "on_stderr": {err -> s:echoLog(string(err), v:true)}
	\ })
  call async#job#send(jobid, json_encode({'command': 'quit'}) . "\n")
endfunction

function! s:PSCIDEendCallback() 
  let s:pscidestarted = 0
  let s:projectvalid = 0
endfunction

function! s:projectProblems()
  let rootdir = s:findRoot()
  let problems = []

  if empty(rootdir)
    call add(problems, "Your project is missing a bower.json or psc-package.json file")
  elseif g:psc_ide_check_output_dir == 1
    let outputcontent = s:globpath(rootdir, "output/*")
    if len(outputcontent) == 0
      call add(problems, "Your project's /output directory is empty.  You should run `pulp build` to compile your project.")
    endif
  endif

  return problems
endfunction

" LOAD -----------------------------------------------------------------------
" Load module of current buffer + its dependencies into `purs ide server`
function! PSCIDEload(logLevel, bang)

  if a:bang == "!"
    return s:callPscIde(
      \ {"command": "reset"},
      \ "failed to reset",
      \ 0,
      \ { resp -> resp["resultType"] == "success" ? PSCIDEload(a:logLevel, "") : "" }
      \ )
  endif

  let input = {'command': 'load'}

  call s:callPscIde(
	\ input,
	\ "Failed to load",
	\ 0,
	\ { resp -> s:PSCIDEloadCallback(a:logLevel, resp)}
	\ )
endfunction

function! s:PSCIDEloadCallback(logLevel, resp)
  if type(a:resp) == v:t_dict
    if a:resp['resultType'] ==# "success"
      call s:log("purs ide: successfully loaded modules: " . string(a:resp["result"]), a:logLevel)
    else
      call s:echoError(get(a:resp, "result", "error"))
    endif
  endif
endfunction

function! s:ExtractModule()
  " Find the module we're currently in. Don't know how to get the length of
  " the current buffer so just looking at the first 20 lines, should be enough
  let module = ''
  let iteration = 0
  while module == '' && iteration < 20
    let iteration += 1
    let line = getline(iteration)
    let matches = matchlist(line, 'module\s\(\S*\)')
    if len(matches) > 0
      let module = matches[1]
    endif
  endwhile

  return module
endfunction

" Import given identifier
function! PSCIDEimportIdentifier(ident)
  call s:importIdentifier(a:ident, "")
endfunction
function! s:importIdentifier(ident, module)

  call s:log('PSCIDEimportIdentifier', 3)
  call s:log('ident: ' . a:ident, 3)

  if (a:ident == "")
    return
  endif

  let file = fnamemodify(bufname(""), ":p")

  let input = { 
        \ 'command': 'import' ,
        \ 'params': {
        \   'file': file, 
	\   'outfile': file,
        \   'importCommand': {
        \     'importCommand': 'addImport',
        \     'identifier': a:ident
        \   } } }

  if a:module != ""
    let input.params.filters = [s:modulesFilter([a:module])]
  endif

  let view = winsaveview()
  let lines = line("$")
  " updated the file
  update

  call s:callPscIde(
	\ input,
	\ "Failed to import identifier " . a:ident, 
	\ 0,
	\ {resp -> s:PSCIDEimportIdentifierCallback(resp, a:ident, view, lines)}
	\ )
endfunction

fun! s:FilterTopFn(module, modules)
  " module :: Array String
  " modules :: Array (Array String)
  let mods = map(copy(g:psc_ide_filter_submodules_do_not_hide), { idx, m -> split(m, '\.') })
  return empty(filter(copy(a:modules), { idx, m -> s:IsSubmodule(a:module, m, a:modules) }))
endfun

fun! s:IsSubmodule(m1, m2, mods)
  " is m1 a submodule of m2
  " m1 :: Array String
  " m2 :: Array String
  if index(a:mods, a:m1) != -1
    return v:false
  endif
  if len(a:m1) > len(a:m2)
    let res = a:m1[0:len(a:m2)-1] == a:m2 ? v:true : v:false
  else
    let res = v:false
  endif
  return res
endfun

fun! s:FilterTop(respResults)
  let modules = map(copy(a:respResults), { idx, r -> split(r.module, '\.') })
  call filter(a:respResults, { idx, r -> s:FilterTopFn(split(r.module, '\.'), modules) })
endfun

fun! s:FilterPrelude(respResults)
  call filter(a:respResults, { idx, r -> index(s:prelude, r.module) == -1 })
endfun

function! s:PSCIDEimportIdentifierCallback(resp, ident, view, lines) 
  call s:log("s:PSCIDEimportIdentifierCallback", 3)
  if a:resp.resultType !=# "success"
    return s:echoError(get(a:resp, "result", "error"))
  endif

  if type(a:resp.result) == v:t_list
    " multiple possibilities
    let respResults = a:resp.result
    if g:psc_ide_filter_prelude_modules && len(filter(copy(respResults), { idx, r -> r.module ==# "Prelude" }))
      " filter prelude modules (hopefully there are no identifires in prelude
      " that clash
      call s:FilterPrelude(respResults)
    endif
    if g:psc_ide_filter_submodules
      call s:FilterTop(respResults)
    endif
    let results = []
    for res in respResults
      if empty(filter(copy(results), { idx, val -> val.module == res.module }))
	call add(results, res)
      endif
    endfor
    if (len(results) == 1)
      let choice = { "option": results[0], "picked": v:true }
    else
      let choice = s:pickOption("Multiple possibilities to import " . a:ident, results, "module")
    endif
    if choice.picked == v:true
      call s:importIdentifier(a:ident, choice.option.module)
    endif
    return
  endif

  let ar = &l:autoread
  let &l:ar = 1
  checktime %
  let &l:ar = ar
  let a:view.lnum = a:view.lnum + line("$") - a:lines
  call winrestview(a:view)
endfunction

function! PSCIDEgoToDefinition(ident)
  let currentModule = s:ExtractModule()
  call s:callPscIde(
	\ {'command': 'type', 'params': {'search': a:ident, 'filters': []}, 'currentModule': currentModule},
	\ 'Failed to get location info for: ' . a:ident,
	\ 0,
	\ { resp -> s:PSCIDEgoToDefinitionCallback(a:ident, resp) }
	\ )
endfunction

function! s:PSCIDEgoToDefinitionCallback(ident, resp)
  call s:log("s:PSCIDEgoToDefinitionCallback", 3)
  let results = []
  for res in a:resp.result
    if empty(filter(copy(results), { idx, val -> 
	  \    type(val.definedAt) == v:t_dict
	  \ && type(res.definedAt) != v:t_dict
	  \ && val.definedAt.name == res.definedAt.name
	  \ && val.definedAt.start[0] == res.definedAt.start[0]
	  \ && val.definedAt.start[1] == res.definedAt.start[1]}))
      call add(results, res)
    endif
  endfor
  if type(a:resp) == v:t_dict && a:resp.resultType ==# "success"
    if len(results) > 1
      let choice = s:pickOption("Multiple possibilities for " . a:ident, results, "module")
    elseif len(results) == 1
      let choice = {"picked": v:true, "option": results[0]}
    else
      let choice = {"picked": v:false, "option": v:null}
    endif
    if choice.picked && type(choice.option.definedAt) == type({})
      call s:goToDefinition(choice.option.definedAt)
    elseif type(choice.option) == v:t_dict
      call s:echoWarn("no location information found for: " . a:ident . " in module " . choice.option.module)
    else
      call s:echoWarn("no location information found for: " . a:ident)
    endif
  else
    call s:echoError(get(a:resp, "result", "error"))
  endif
endfunction

function! s:goToDefinition(definedAt)
  let currentfile = expand("%:p")
  let fname = a:definedAt.name
  let cwd = s:findRoot()
  let fname = fnameescape(findfile(fname, cwd))
  if (currentfile == fname)
    " set ' mark at the current position
    m'
    call cursor(a:definedAt.start[0], a:definedAt.start[1])
  else
    call s:log("PSCIDE s:goToDefinition: fname: " . fname, 3)

    let command = "e +" . a:definedAt.start[0] . " " . fname
    call s:log("PSCIDE s:goToDefinition: command: " . command, 3)
    exe command
    exe "normal " . a:definedAt.start[1] . "|"
  endif
endfunction

function! PSCIDErebuild(async, ...)
  let g:psc_ide_suggestions = {}
  let filename = expand("%:p")
  let input = {'command': 'rebuild', 'params': {'file': filename}}

  if a:0 > 0 && type(a:1) == v:t_func
    let CallBack = a:1
  else
    let CallBack = {resp -> resp}
  endif

  if a:async
    call s:callPscIde(
	  \ input,
	  \ 0,
	  \ 0,
	  \ { msg -> CallBack(s:PSCIDErebuildCallback(filename, msg)) }
	  \ )
  else
    let resp = s:PSCIDErebuildCallback(
	      \ filename,
	      \ s:callPscIdeSync(input, 0, 0),
	      \ )
    return CallBack(resp)
  endif
endfunction

function! s:PSCIDErebuildCallback(filename, resp) 
  if type(a:resp) == v:t_dict && has_key(a:resp, "resultType") 
     \ && has_key (a:resp, "result") && type(a:resp.result) == v:t_list
    if a:resp.resultType == "error"
      let out = ParsePscJsonOutput(a:resp.result, [])
    else
      let out = ParsePscJsonOutput([], a:resp.result)
    endif
    if out.error != ""
      call s:echoError("failed to interpret " . string(a:resp.result))
    endif

    let g:psc_ide_suggestions = out.suggestions
    return out.llist
  else
    call s:echoError("failed to rebuild")
    return []
  endif
endfunction

" Add type annotation
function! PSCIDEaddTypeAnnotation(ident)
  call s:getType(
	\ a:ident,
	\ v:true,
	\ { resp -> s:PSCIDEaddTypeAnnotationCallback(a:ident, resp) }
	\ )
endfunction

function! s:PSCIDEaddTypeAnnotationCallback(ident, resp)
  if type(a:resp) == v:t_dict && a:resp["resultType"] ==# 'success' && !empty(a:resp["result"])
    let result = a:resp["result"]
    let lnr = line(".")
    let indent = matchstr(getline(lnr), '^\s*\ze')
    call append(lnr - 1, indent . s:StripNewlines(result[0]['identifier']) . ' :: ' . s:StripNewlines(result[0]["type"]))
  else
    call s:echoWarn("no type information found for " .a:ident)
  endif
endfunction

" CWD ------------------------------------------------------------------------
" Get current working directory of `pure ide server`
function! PSCIDEcwd()
  call s:callPscIde(
	\ {'command': 'cwd'},
	\ "Failed to get current working directory", 
	\ 0,
	\ function("s:PSCIDEcwdCallback")
	\ )
endfunction

function! s:PSCIDEcwdCallback(resp)
  if type(a:resp) == v:t_dict && a:resp['resultType'] ==# 'success'
    call s:echoLog("current working directory: " . a:resp.result)
  else
    call s:echoError(get(a:resp, "result", "error))
  endif
endfunction

" ADDCLAUSE
" Makes template function implementation from signature
function! PSCIDEaddClause()
  let lnr = line(".")
  let line = getline(lnr)

  let command = {'command': 'addClause', 'params': {'line': line, 'annotations': v:false}}

  call s:callPscIde(
	\ command,
	\ "Failed to add clause",
	\ 0,
	\ { resp -> s:PSCIDEaddClauseCallback(lnr, resp) }
	\ )
endfunction

function! s:PSCIDEaddClauseCallback(lnr, resp)
  if type(a:resp) == v:t_dict && a:resp['resultType'] ==# 'success'
    call s:log('PSCIDEaddClause results: ' . string(a:resp.result), 3)
    call append(a:lnr, a:resp.result)
    normal dd
  else
    call s:echoError(get(a:resp, "result", "error"))
  endif
endfunction

" CASESPLIT
" Hover cursor over variable in function declaration -> pattern match on all
" different cases of the variable
function! PSCIDEcaseSplit(type)
  let winview = winsaveview()
  let lnr = line(".")
  let begin = s:findStart()
  let line = getline(lnr)
  let len = len(matchstr(line[begin:], '^\k*'))
  let word = line[:len]

  call winrestview(winview)

  let command = {
	\ 'command': 'caseSplit',
	\ 'params': { 'line': line, 'begin': begin, 'end': begin + len, 'annotations': v:false, 'type': a:type}
	\ }

  call s:callPscIde(
	\ command,
	\ 'Failed to split case for: ' . word,
	\ 0,
	\ { resp -> s:PSCIDEcaseSplitCallback(lnr, resp) }
	\ )
endfunction

function! s:PSCIDEcaseSplitCallback(lnr, resp)
  if type(a:resp) == v:t_dict && a:resp['resultType'] ==# 'success'
    call append(a:lnr, a:resp.result)
    normal dd
  else
    call s:echoError(get(a:resp, "result", "error"))
  endif
endfunction

" TYPE -----------------------------------------------------------------------
" Get type of word under cursor
function! PSCIDEtype(ident, filterModules)
  call s:getType(
	\ a:ident,
	\ a:filterModules,
	\ { resp -> s:PSCIDEtypeCallback(a:ident, resp.result, a:filterModules) }
	\ )
endfunction

function! s:PSCIDEtypeCallback(ident, result, filterModules)
  if !empty(a:result) && type(a:result) == v:t_list
    for e in a:result
      echom s:formattype(e)
    endfor
  elseif a:filterModules
    call PSCIDEtype(a:ident, v:false)
  else
    echom "PSC-IDE: No type information found for " . a:ident
  endif
endfunction

" LISTIMPORTS -----------------------------------------------------------------------
" List the modules imported by the current module
function! PSCIDElistImports()
  let currentModule = s:ExtractModule()
  call s:log('PSCIDElistImports ' . currentModule, 3)
  let imports =  s:ListImports(currentModule)
  for import in imports
    call s:echoImport(import)
  endfor
  if (len(imports) == 0)
    echom "PSC-IDE: No import information found for " . currentModule
  endif

endfunction

function! s:echoImport(import)
  echohl Identifier
  echon a:import["module"]
  echohl Normal
  if has_key(a:import, "identifiers")
    echon " ("
    let len = len(a:import["identifiers"])
    let idx = 0
    for ident in a:import["identifiers"]
      echohl Identifier
      echon ident 
      echohl Normal
      if (idx < len - 1)
	echon ", "
      else
	echon ")"
      endif
      let idx += 1
    endfor
  endif
  if has_key(a:import, "qualifier")
    echohl Keyword
    echon " as "
    echohl Identifier
    echon a:import["qualifier"]
    echohl Normal
  endif
  echon "\n"
endfunction

function! s:ListImports(module)
  let filename = expand("%:p")
  let resp = s:callPscIdeSync(
	\ {'command': 'list', 'params': {'type': 'import', 'file': filename}},
	\ 'Failed to get imports for: ' . a:module,
	\ 0
	\ )
  call s:log("PSCIDE s:ListImports result: " . string(resp), 3)
  " Only need module names right now, so pluck just those.
  if type(resp) == v:t_dict && resp['resultType'] ==# 'success'
    " psc-ide >=0.11 returns imports on 'imports' property.
    return type(resp.result) == v:t_list ? resp.result : resp.result.imports
  else
    call s:echoError(get(resp, "result", "error"))
  endif
endfunction

function! s:getType(ident, filterModules, cb)
  let currentModule = s:ExtractModule()
  if a:filterModules
    let modules = add(map(s:ListImports(currentModule), {key, val -> val["module"]}), currentModule)
    let filters = [s:modulesFilter(modules)]
  else
    let filters = []
  endif
  call s:log('PSCIDE s:getType currentModule: ' . currentModule, 3)

  call s:callPscIde(
	\ { 'command': 'type'
	\ , 'params':
	\     { 'search': a:ident
	\     , 'filters': filters
	\     , 'currentModule': currentModule
	\     }
	\ },
	\  'Failed to get type info for: ' . a:ident,
	\ 0,
	\ {resp -> a:cb(resp)}
	\ )
endfunction

function! s:formattype(record)
  return s:CleanEnd(s:StripNewlines(a:record['module']) . '.' . s:StripNewlines(a:record['identifier']) . ' ∷ ' . s:StripNewlines(a:record['type']))
endfunction

" APPLYSUGGESTION ------------------------------------------------------
" Apply suggestion in loclist to buffer --------------------------------
function! PSCIDEapplySuggestion(bang)
  if empty(a:bang)
    call PSCIDEapplySuggestionPrime(expand("%:p") . "|" . line("."), v:true, 0)
  else
    let l = 0
    let len = len(keys(g:psc_ide_suggestions))
    while l < len
      " PSCIDEapplySuggestionPrime will change g:psc_ide_suggestions keys on
      " the fly
      let keys = keys(g:psc_ide_suggestions)
      if len(keys) > 0
	let key = keys[0]
	call PSCIDEapplySuggestionPrime(key, v:true, 0)
      else
	break
      endif
    endwhile
  endif
endfunction

function! PSCIDEapplySuggestionPrime(key, cursor, silent)

  call s:log('PSCIDEapplySuggestion: a:key: ' . a:key, 3)

  if (has_key(g:psc_ide_suggestions, a:key))
    let sugg = g:psc_ide_suggestions[a:key]
  else
    if !a:silent
      call s:log('PSCIDEapplySuggestion: No suggestion found', 0)
    endif
    return
  endif

  call s:log('PSCIDEapplySuggestion: Suggestion found: ' . string(sugg), 3)
  let replacement = sugg.replacement
  let range = sugg.replaceRange
  let startLine = range.startLine
  let startColumn = range.startColumn
  let endLine = range.endLine
  let endColumn = range.endColumn
  if startLine == endLine
    let line = getline(startLine)
    let replacement = substitute(replacement, '\_s*$', '\n', '')
    let cursor = getcurpos()
    if startColumn == 1
      let newLines = split(replacement . line[endColumn - 1:], "\n")
    else
      let newLines = split(line[0:startColumn - 2] . replacement . line[endColumn - 1:], "\n")
    endif
    exe startLine . "d _"
    call append(startLine - 1, newLines)
    if a:cursor
      call cursor(cursor[1], startColumn - 1)
    endif
    call remove(g:psc_ide_suggestions, a:key)
    let g:psc_ide_suggestions = s:updateSuggestions(startLine, len(newLines) - 1)
  else
    echom "PSCIDEapplySuggestion: multiline suggestions are not yet supported"
  endif
endfunction

fun! s:updateSuggestions(startLine, newLines)
  let suggestions = {}
  for key in keys(g:psc_ide_suggestions)
    let sug = g:psc_ide_suggestions[key]
    if sug.replaceRange.startLine < a:startLine
      let suggestions[key] = sug
    else
      let keyParts = split(key, "|")
      let keyParts[len(keyParts) - 1] = sug.replaceRange.startLine + a:newLines
      let newKey = join(keyParts, "|")
      let sug.replaceRange.startLine = sug.replaceRange.startLine + a:newLines
      let sug.replaceRange.endLine = sug.replaceRange.endLine + a:newLines
      let suggestions[newKey] = sug
    endif
  endfor
  return suggestions
endfun

" Add all import qualifications
function! PSCIDEaddImportQualifications()
  let foundLines = []
  let filename = expand("%:p")
  let oldCursorPos = getcurpos()

  call cursor(1, 0)
  let found = searchpos("import", "W")
  while found != [0,0]
    let foundLines = insert(foundLines, found[0]) " Insert = unshift -> list is in reverse = what we want because of deleting
    call cursor(found[0], 0)
    let found = searchpos("import", "W")
  endwhile
  call s:log('Adding import qualifications to : ' . string(foundLines), 3)

  for lnr in foundLines
    call PSCIDEapplySuggestionPrime(lnr, filename, 1)
  endfor

  call cursor(oldCursorPos[1], oldCursorPos[2])
endfunction


" PURSUIT --------------------------------------------------------------------
function! PSCIDEpursuit(ident)

  call s:callPscIde(
	\ {'command': 'pursuit', 'params': {'query': a:ident, 'type': "completion"}},
	\ 'Failed to get pursuit info for: ' . a:ident,
	\ 0,
	\ { resp -> s:PSCIDEpursuitCallback(resp) }
	\ )
endfunction

function! s:PSCIDEpursuitCallback(resp)
  if type(a:resp) == v:t_dict && a:resp['resultType'] ==# 'success'
    if len(a:resp["result"]) > 0
      for e in a:resp["result"]
        echom s:formatpursuit(e)
      endfor
    else
      call s:echoError(get(a:resp, "result", "error"))
    endif
  endif
endfunction

function! s:formatpursuit(record)
  return "In " . s:CleanEnd(s:StripNewlines(a:record["package"])) . " " . s:CleanEnd(s:StripNewlines(a:record['module']) . '.' . s:StripNewlines(a:record['ident']) . ' :: ' . s:StripNewlines(a:record['type']))
endfunction

" VALIDATE -------------------------------------------------------------------
function! PSCIDEprojectValidate()
  let problems = s:projectProblems()

  if len(problems) == 0
    let s:projectvalid = 1
    echom "Your project is setup correctly."
  else
    let s:projectvalid = 0
    echom "Your project is not setup correctly. " . join(problems)
  endif
endfunction

" LIST -----------------------------------------------------------------------
function! PSCIDElist()
  let resp = s:callPscIdeSync(
	\ {'command': 'list', 'params': {'type': 'loadedModules'}},
	\ 'Failed to get loaded modules',
	\ 0
	\ )
  call s:PSCIDElistCallback(resp)
endfunction

function! s:PSCIDElistCallback(resp)
  if type(a:resp) == v:t_dict && a:resp['resultType'] ==# 'success'
    if len(a:resp["result"]) > 0
      for m in a:resp["result"]
        echom m
      endfor
    endif
  elseif type(a:resp) == v:t_dict
    call s:echoError(get(a:resp, "result", "error"))
  endif
endfunction

fun! s:findStart()
  let col   = col(".")
  let line  = getline(".")

  " search backwards for start of identifier (iskeyword pattern)
  let start = col
  while start > 0 && (line[start - 2] =~ '\k' || line[start - 2] =~ '\.')
    let start -= 1
  endwhile

  "Looking for the start of the identifier that we want to complete
  return start - 1
endfun

" COMPLETION FUNCTION --------------------------------------------------------
fun! s:completeFn(findstart, base, commandFn)
  if a:findstart 
    return s:findStart()
  else

    if match(a:base, '\.') != -1
      let str_ = split(a:base, '\.')
      let qualifier = join(str_[0:len(str_)-2], ".")
      let ident= str_[len(str_) - 1]
    else
      let ident = a:base
      let qualifier = ""
    endif

    let resp = s:callPscIdeSync(
	  \ a:commandFn(ident, qualifier),
	  \ 'Failed to get completions for: '. a:base,
	  \ 0)

    let entries = get(resp, "result", [])
    "Popuplating the omnicompletion list
    let result = []

    let hasPreview = index(split(&l:completeopt, ','), 'preview') != -1
    " vimL does not have compare function for strings, and uniq must run after
    " sort.
    if g:psc_ide_omnicompletion_sort_by != "flex"
      call uniq(
	    \ sort(entries, { e1, e2 -> 
		  \ g:psc_ide_omnicompletion_sort_by == "module" 
		    \ ? e1.module == e2.module
		    \ : sort([e1.identifier, e2.identifier]) == [e2.identifier, e1.identifier]}),
	    \ { e1, e2 -> !s:compareByDefinedAt(e1, e2) }
	    \ )
    endif

    for entry in entries
      let detail = printf("\t%-25S\t\t%s", entry['module'], entry["type"])
      let e = { 'word': (empty(qualifier) ? "" : qualifier . ".") . entry['identifier']
	    \ , 'menu': hasPreview ? entry["type"] : detail
	    \ , 'info': detail
	    \ , 'dup': 1
	    \ }
      call add(result, e)
    endfor
    return result
  endif
endfun

fun! s:omniCommand(ident, qualifier)
  let currentModule = s:ExtractModule()

  let filters = []
  if g:psc_ide_omnicompletion_prefix_filter
    call add(filters, s:prefixFilter(a:ident))
  endif

  if !empty(a:qualifier)
    let imports = s:ListImports(currentModule)
    let modules = []
    for mod in imports
      if get(mod, "qualifier", "") == a:qualifier || get(mod, "module", "") == a:qualifier
	call add(modules, mod.module)
      endif
    endfor

    if len(modules)
      call add(filters, s:modulesFilter(modules))
    endif
    let matcher = s:flexMatcher(a:ident)
  else
    if g:psc_ide_omnicompletion_filter_modules
      call add(filters, s:modulesFilter(map(s:ListImports(currentModule), { n, m -> m.module })))
    endif
    let matcher = s:flexMatcher(a:ident)
  endif

  return {'command': 'complete'
	 \ , 'params':
	 \   { 'filters': filters
	 \   , 'matcher': matcher
	 \   , 'currentModule': currentModule
	 \   , 'options': { 'groupReexports': v:true }
	 \   }
	 \ }
endfun

fun! s:compareByDefinedAt(e1, e2)
  let d1 = a:e1["definedAt"]
  let d2 = a:e2["definedAt"]
  if d1["name"] != d2["name"]
	\ || d1["start"][0] != d2["start"][0]
	\ || d1["start"][1] != d2["start"][1]
	\ || d1["end"][0] != d2["end"][0]
	\ || d1["end"][1] != d2["end"][1]
    return v:false
  else
    return v:true
  endif
endfun

function! s:prefixFilter(s) 
  return { "filter": "prefix", "params": { "search": a:s } }
endfunction

function! s:flexMatcher(s)
  return { "matcher": "flex", "params": { "search": a:s } }
endfunction

fun! s:modulesFilter(modules)
  return { "filter": "modules", "params": { "modules": a:modules } }
endfun

" SET UP OMNICOMPLETION ------------------------------------------------------
fun! PSCIDEomni(findstart, base)
  if a:findstart
    return s:completeFn(a:findstart, a:base, function("s:omniCommand"))
  else
    let results = s:completeFn(a:findstart, a:base, function("s:omniCommand"))
    if empty(results)
      let results = PSCIDEcomplete(a:findstart, a:base)
    endif
    return results
  endif
endfun

" SET UP USERCOMPLETION ------------------------------------------------------
fun! PSCIDEcomplete(findstart, base)
  return s:completeFn(a:findstart, a:base, { ident, qualifier ->
	\ {'command': 'complete'
	\ , 'params':
	\   { 'matcher': s:flexMatcher(a:base)
	\   , 'options': { 'groupReexports': v:true }
	\   }
	\ }
	\ })
endfun

" SEARCH ---------------------------------------------------------------------
fun! PSCIDEsearch(ident)
  let matcher = s:flexMatcher(a:ident)
  call s:callPscIde(
	\ {'command': 'complete'
	\ , 'params':
	\   { 'matcher': matcher
	\   , 'options': { 'groupReexports': v:true }
	\   }
	\ },
	\ 'Failed to get completions for: '. a:ident,
	\ 0,
	\ { resp -> s:searchFn(resp) }
	\ )
endfun

fun! s:searchFn(resp)
  if get(a:resp, "resultType", "error") !=# "success"
    return s:echoError(get(a:resp, "result", "error"))
  endif
  let llist = []
  for res in get(a:resp, "result", [])
    let llentry = {}
    let bufnr = bufnr(res.definedAt.name)
    if bufnr != -1
      let llentry.bufnr = bufnr
    endif
    let llentry.filename = res.definedAt.name
    let llentry.module = res.module
    let llentry.lnum = res.definedAt.start[0]
    let llentry.col = res.definedAt.start[1]
    let llentry.text = printf("%s %s", res.identifier, res.type)
    call add(llist, llentry)
  endfor
  " echom json_encode(a:resp)
  call setloclist(0, llist)
  call setloclist(0, [], 'a', {'title': 'PureScript Search'})
  lopen
endfun

" PSCIDE HELPER FUNCTION -----------------------------------------------------
" Issues the commands to the server
" Is responsible for keeping track of whether or not we have a running server
" and (re)starting it if not
" Also serializes and deserializes from/to JSON
function! s:callPscIde(input, errorm, isRetry, cb)
  call s:log("callPscIde: start: command: " . json_encode(a:input), 3)

  if s:projectvalid == 0
    call PSCIDEprojectValidate()
  endif

  if s:pscidestarted == 0

    let expectedCWD = fnamemodify(s:findRoot(), ":p:h")
    call s:log("callPscIde: cwd " . expectedCWD, 3)
    let cwdcommand = {'command': 'cwd'}

    call s:log("callPscIde: No server found, looking for external server", 1)
    let jobid = async#job#start(
	  \ ["purs", "ide", "client", "-p", g:psc_ide_server_port],
	  \ { "on_stdout": {ch, msg -> s:PscIdeStartCallback(a:input, a:errorm, a:cb, cwdcommand, msg)}
	  \ , "on_stderr": {ch, err -> s:log("s:callPscIde error: " . string(err), 3)}
	  \ })
    call async#job#send(jobid, json_encode(cwdcommand) . "\n")
    return
  endif

  let enc = json_encode(a:input)
  call s:log("callPscIde: purs ide client: " . enc, 3)
  let jobid = async#job#start(
	\ ["purs", "ide", "client", "-p", g:psc_ide_server_port],
	\ { "on_stdout": {ch, msg -> a:cb(s:PscIdeCallback(a:input, a:errorm, a:isRetry, a:cb, msg))}
	\ , "on_stderr": {ch, err -> s:log("s:callPscIde error: " . string(err), 0)}
	\ })
  call async#job#send(jobid, enc . "\n")
  " call async#job#stop(jobid) " Not needed I think, \n stops job
endfunction

function! s:callPscIdeSync(input, errorm, isRetry)
  call s:log("callPscIdeSync: command: " . json_encode(a:input), 3)

  if s:projectvalid == 0
    call PSCIDEprojectValidate()
  endif

  if s:pscidestarted == 0

    let expectedCWD = fnamemodify(s:findRoot(), ":p:h")
    let cwdcommand = {'command': 'cwd'}

    call s:log("callPscIde: No server found, looking for external server", 1)
    let cwdresp = s:mysystem("purs ide client -p " . g:psc_ide_server_port, json_encode(cwdcommand))
    return s:PscIdeStartCallback(a:input, a:errorm, 0, cwdcommand, cwdresp)
  endif

  call s:log("callPscIde: Trying to reach server again", 1)
  let enc = json_encode(a:input)
  let resp = s:mysystem("purs ide client -p " . g:psc_ide_server_port, enc)
  return s:PscIdeCallback(a:input, a:errorm, a:isRetry, 0, resp)
endfunction

" ADD IMPORTS  --------------------------------------------------------------
fun! PSCIDEimportModule(module)
  let args = filter(split(a:module, ' '), { idx, p -> p != ' ' })
  if len(args) >= 2
    let importCommand =
	  \ { "importCommand": "addQualifiedImport"
	  \ , "module": args[0]
	  \ , "qualifier": args[1]
	  \ }
  else
    let importCommand =
	  \ { "importCommand": "addImplicitImport"
	  \ , "module": args[0]
	  \ }
  endif
  let params =
	\ { "file": expand("%:p")
	\ , "importCommand": importCommand
	\ }

  call s:callPscIde(
	\ { "command": "import" , "params": params }
	\ , "failed to add import",
	\ 0,
	\ function("s:PSCIDEimportModuleCallback")
	\ )
endfun

fun! s:PSCIDEimportModuleCallback(resp)
  if type(a:resp) == v:t_dict && a:resp.resultType ==# "success"
    let view = winsaveview()
    %d_
    call append(0, a:resp.result)
    $d_
    let view.lnum += 1
    let view.topline += 1
    call winrestview(view)
  else
    call s:echoError(get(a:resp, "result", "error"))
  endif
endfun

fun! PSCIDEimportModuleCompletion(ArgLead, CmdLine, CursorPos)
  let resp = s:callPscIdeSync(
	\ {'command': 'list', 'params': {'type': 'loadedModules'}},
	\ 'Failed to get loaded modules',
	\ 0
	\ )
  if type(resp) == v:t_dict && resp.resultType == "success"
    return join(resp.result, "\n")
  else
    return ""
  endif
endfun

" UTILITY FUNCTIONS ----------------------------------------------------------
function! s:PscIdeStartCallback(input, errorm, cb, cwdcommand, cwdresp)
  let expectedCWD = fnamemodify(s:findRoot(), ":p:h")
  try
    let cwdrespDecoded = json_decode(a:cwdresp)
  catch /.*/
    let cwdrespDecoded = {"resultType": "failed", "error": a:cwdresp}
  endtry

  call s:log("s:PscIdeStartCallback: Decoded response of trying to reach external server: " 
	      \ . string(cwdrespDecoded), 1)

  if type(cwdrespDecoded) == type({}) && cwdrespDecoded.resultType ==# 'success'
    call s:log("s:PscIdeStartCallback: Found external server with cwd: " . string(cwdrespDecoded.result), 1)
    call s:log("s:PscIdeStartCallback: Expecting CWD: " . expectedCWD, 1)

    if expectedCWD != cwdrespDecoded.result
      call s:log("s:PscIdeStartCallback: External server on incorrect CWD, closing", 1)
      call PSCIDEend()
      call s:log("s:PscIdeStartCallback: Starting new server", 1)
      call PSCIDEstart(1)
    else
      call s:echoLog("started", v:true)
      let s:pscidestarted = 1
      let s:pscideexternal = 1
    endif
  else
    call s:log("s:PscIdeStartCallback: No external server found, starting new server", 1)
    call PSCIDEstart(1)
  endif
  call s:log("s:PscIdeStartCallback: Trying to reach server again", 1)
  if (type(a:cb) == type(0) && !a:cb)
    let cwdresp = s:mysystem(
	  \ "purs ide client -p" . g:psc_ide_server_port,
	  \ json_encode(a:cwdcommand)
	  \ )
    return s:PscIdeRetryCallback(a:input, a:errorm, 0, expectedCWD, cwdresp)
  endif
  let jobid = async#job#start(
	\ ["purs", "ide", "client", "-p", g:psc_ide_server_port],
	\ { "on_stdout": { ch, resp -> s:PscIdeRetryCallback(a:input, a:errorm, a:cb, expectedCWD, resp) }
	\ , "on_stderr": { ch, err -> s:echoWarn(s:toString(err)) }
	\ })
  call async#job#send(jobid, json_encode(a:cwdcommand) . "\n")
endfunction

function! s:PscIdeRetryCallback(input, errorm, cb, expectedCWD, cwdresp2)
  call s:log("s:PscIdeRetryCallback: Raw response of trying to reach server again: " . string(a:cwdresp2), 1)

  if (type(a:cwdresp2) == type([]))
    let json = a:cwdresp2[0]
  else
    let json = a:cwdresp2
  endif

  try
    let cwdresp2Decoded = json_decode(json)
  catch /.*/
    let cwdresp2Decoded = {"resultType": "failed", "error": a:cwdresp2}
  endtry
  call s:log("s:PscIdeRetryCallback: Decoded response of trying to reach server again: " 
	     \ . string(cwdresp2Decoded), 1)
  call s:log("s:PscIdeRetryCallback: Expecting CWD: " . a:expectedCWD, 1)

  if type(cwdresp2Decoded) == type({}) && cwdresp2Decoded.resultType ==# 'success' 
     \ && cwdresp2Decoded.result == a:expectedCWD
    call s:log("s:PscIdeRetryCallback: Server successfully contacted! Loading current module.", 1)
    call PSCIDEload(1, "")
  else
    call s:log("s:PscIdeRetryCallback: Server still can't be contacted, aborting...", 1)
    return
  endif

  let enc = json_encode(a:input)
  if (type(a:cb) == type(0))
    let resp = s:mysystem(
	  \ "purs ide client -p" . g:psc_ide_server_port,
	  \ enc
	  \ )
    return s:PscIdeCallback(a:input, a:errorm, 1, 0, resp)
  endif

  if (type(a:cb) == type(0) && !a:cb)
    let resp = s:mysystem(
	  \ "purs ide client -p" . g:psc_ide_server_port
	  \ enc
	  \ )
    return s:PscIdeCallback(a:input, a:errorm, 1, 0, resp)
  endif
  call s:log("callPscIde: purs ide client: " . enc, 3)
  let jobid = async#job#start(
	\ ["purs", "ide", "client", "-p", g:psc_ide_server_port],
	\ { "on_stdout": {ch, resp -> a:cb(s:PscIdeCallback(a:input, a:errorm, 1, a:cb, resp))}
	\ , "on_stderr": {ch, err -> s:log("s:PscIdeRetryCallback error: " . err, 3)}
	\ })
  call async#job#send(jobid, enc . "\n")
endfunction

function! s:PscIdeCallback(input, errorm, isRetry, cb, resp)
  call s:log("s:PscIdeCallback: Raw response: " . string(a:resp), 3)

  if (type(a:resp) == type([]))
    let json = a:resp[0]
  else
    let json = a:resp
  endif

  try
    let decoded = json_decode(json)
  catch /.*/
    let s:pscidestarted = 0
    let s:pscideexternal = 0
    let decoded =
	  \ { "resultType": "error"
	  \ , "result": "failed to decode response"
	  \ }

    if a:isRetry
      call s:echoLog("failed to contact server", v:true)
    endif
    if !a:isRetry
      " Seems saving often causes `purs ide server` to crash. Haven't been able
      " to figure out why. It doesn't crash when I run it externally...
      " retrying is then the next best thing
      return s:callPscIde(a:input, a:errorm, 1, a:cb) " Keeping track of retries so we only retry once
    endif
  endtry

  call s:log("s:PscIdeCallback: Input: " . string(a:input), 3)
  call s:log("s:PscIdeCallback: Decoded response: " . string(decoded), 3)

  if (type(decoded) != type({}) || decoded['resultType'] !=# 'success') 
      \ && type(a:errorm) == type("")
    call s:log("s:PscIdeCallback: Error: " . a:errorm, 0)
  endif
  return decoded
endfunction

function! s:StripNewlines(s)
  return substitute(a:s, '\s*\n\s*', ' ', 'g')
endfunction

function! s:CleanEnd(s)
  return substitute(a:s, '\s*\n*\s*$', '', 'g')
endfunction

function! s:log(str, level)
  if g:psc_ide_log_level >= a:level
    echom a:str
  endif
endfunction

" INIT -----------------------------------------------------------------------
function! PSCIDEerrors(llist)
  let qflist = []
  for e in a:llist
    let eparts = split(e, ":")
    let [type, filename, lnum, col, endLnum, endCol] = eparts[0:5]
    let bufnr = bufnr(filename)
    if bufnr != -1
      call add(
	    \ qflist
	    \ , { "bufnr": bufnr
	    \   , "filename": filename
	    \   , "lnum": lnum
	    \   , "col": col
	    \   , "text": join(filter(eparts, {idx -> idx >= 6}), ":")
	    \   , "type": type
	    \   }
	    \ )
    endif
  endfor
  if g:psc_ide_notify
    let errsLen = len(filter(copy(qflist), { n, e -> e["type"] ==# "E" || e["type"] ==# "F" }))
    let wrnLen = len(filter(copy(qflist), { n, e -> e["type"] ==# "W" || e["type"] ==# "V" }))
    if errsLen > 0
      echohl ErrorMsg
      echom "purs: " . errsLen . " " . (errsLen == 1 ? "error" : "errors")
      echohl Normal
    elseif wrnLen > 0
      echohl WarningMsg
      echom "purs: " . wrnLen . " ". (wrnLen == 1 ? "warnings" : "warning")
      echohl Normal
    else
      call s:echoLog("success")
    endif
  endif
  call sort(qflist, { e1, e2 -> e1["lnum"] == e2["lnum"] ? e1["col"] - e2["col"] : e1["lnum"] - e2["lnum"] })
  call setqflist(qflist)
  call setqflist([], 'a', {'title': 'PureScript Errors'})
endfunction

" PSCIDEerr ------------------------------------------------------------------
fun! PSCIDEerr(nr)
  let qf = getqflist()
  if a:nr > 0 && a:nr < len(qf) + 1
    let e = qf[a:nr - 1]
    echo getline(e["lnum"])
    let col = e["col"]
    echon "\n" . repeat(" ", col - 1)
    echohl Error
    echon "^\n\n"
    echohl Normal
    echo e["text"]
  endif
endfun


" Parse Errors & Suggestions -------------------------------------------------
" Returns { error :: String, 
"           llist :: Array (String in errorformat), 
"           suggestions :: StrMap { startLine :: Int,
"                                  startColumn :: Int,
"                                  endLine :: Int,
"                                  endColumn :: Int,
"                                  filename :: String,
"                                  replacement :: String } }
" Key of suggestions = <filename>|<linenr>
function! ParsePscJsonOutput(errors, warnings)
  let out = []
  let suggestions = {}

  for e in a:warnings
    try
      call s:addEntry(out, suggestions, 0, e)
    catch /\m^Vim\%((\a\+)\)\=:E716/
      return {'error': 'ParsePscJsonOutput: unrecognized warning format', 
            \ 'llist': [], 
            \ 'suggestions': []}
    endtry
  endfor
  for e in a:errors
    try
      call s:addEntry(out, suggestions, 1, e)
    catch /\m^Vim\%((\a\+)\)\=:E716/
      return {'error': 'ParsePscJsonOutput: unrecognized error format', 
            \ 'llist': [], 
            \ 'suggestions': []}
    endtry
  endfor

  return {'error': "", 'llist': out, 'suggestions': suggestions}
endfunction

function! s:addEntry(out, suggestions, err, e)
  let hasSuggestion = type(get(a:e, "suggestion", v:null)) == v:t_dict
  let isError = a:err == 1
  let letter = isError ? (hasSuggestion ? 'F' : 'E') : (hasSuggestion ? 'V' : 'W')
  let startL = has_key(a:e, "position") && type(a:e.position) == v:t_dict
	\ ? a:e.position.startLine : 1
  let startC = has_key(a:e, "position") && type(a:e.position) == v:t_dict
	\ ? a:e.position.startColumn : 1
  let endL = has_key(a:e, "position") && type(a:e.position) == v:t_dict
	\ ? a:e.position.endLine : 1
  let endC = has_key(a:e, "position") && type(a:e.position) == v:t_dict
	\ ? a:e.position.endColumn : 1
  let msg = join([letter, 
                \ a:e.filename, 
                \ startL,
                \ startC,
		\ endL,
		\ endC,
                \ a:e.message], ":")

  call add(a:out, msg)

  if hasSuggestion
    call s:addSuggestion(a:suggestions, a:e)
  endif
endfunction

function! s:addSuggestion(suggestions, e)
   let a:suggestions[a:e.filename . "|" . string(a:e.position.startLine)] = a:e.suggestion
endfunction

function! s:mysystem(a, b)
  return system(a:a, a:b . "\n")
endfunction

fun! s:toString(msg)
  if type(a:msg) == v:t_string
    echo a:msg
  elseif type(a:msg) == v:t_list
    return join(map(copy(a:msg), { idx, msg -> s:toString(msg) }), " ")
  elseif type(a:msg) == v:t_dict
    let msg = {}
    for key in a:msg
      msg[key] = s:toString(a:msg[key])
    endfor
    return string(msg)
  else
    return string(a:msg)
  endif
endfun

fun! s:echoError(msg, ...)
  let title = a:0 > 0 && a:1 ? "purs ide server: " : "purs ide: "
  echohl ErrorMsg
  echom title . a:msg
  echohl Normal
endfun

fun! s:echoWarn(msg, ...)
  let title = a:0 > 0 && a:1 ? "purs ide server: " : "purs ide: "
  echohl WarningMsg
  echom title . a:msg
  echohl Normal
endfun

fun! s:echoLog(msg, ...)
  let title = a:0 > 0 && a:1 ? "purs ide server: " : "purs ide: "
  echom title .a:msg
endfun

" AUTOSTART ------------------------------------------------------------------
call s:autoStart()
