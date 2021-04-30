LmodMessage( 'DEBUG: ' .. myModuleFullName() .. ', mode ' .. mode() )

local famexp_module = os.getenv( 'FAMEXP_MODULE' ) or 'NOT SET'
local famexp_push   = os.getenv( 'FAMEXP_PUSH' )   or 'NOT SET'
local module_path   = os.getenv( 'MODULEPATH' )    or 'NOT SET'
LmodMessage( 'DEBUG: ' .. myModuleFullName() .. ', at the start:\n  * FAMEXP_MODULE = ' .. famexp_module .. '\n  * FAMEXP_PUSH = ' .. famexp_push .. '\n  * MODULEPATH = ' .. module_path )

family( 'famexp' )

local mroot = os.getenv( 'LMOD_MODULE_ROOT' )

setenv( 'FAMEXP_MODULE', 'a' )

pushenv( 'FAMEXP_PUSH', 'a')

prepend_path( 'MODULEPATH', pathJoin( mroot,  'famexp_a' ) )

famexp_module = os.getenv( 'FAMEXP_MODULE' ) or 'NOT SET'
famexp_push   = os.getenv( 'FAMEXP_PUSH' )   or 'NOT SET'
module_path   = os.getenv( 'MODULEPATH' )    or 'NOT SET'
LmodMessage( 'DEBUG: ' .. myModuleFullName() .. ', at the start:\n  * FAMEXP_MODULE = ' .. famexp_module .. '\n  * FAMEXP_PUSH = ' .. famexp_push .. '\n  * MODULEPATH = ' .. module_path .. '\n' )
