LmodMessage( 'DEBUG: ' .. mode() .. ' ' .. myModuleFullName() .. '(' .. myFileName() .. ')' )

family( 'SoftwareStack' )

whatis( 'Dummy ' .. myModuleFullName() .. ' SoftwareStack module to test hierarchyA.' )

help( [[
Description
===========

Dummy ]] .. myModuleFullName() .. [[ SoftwareStack module to test hierarchyA.
]] )

local mroot = os.getenv( 'MODULEROOT' )

prepend_path( 'MODULEPATH', pathJoin( mroot, 'SystemPartition', myModuleName(), myModuleVersion() ) )

local modulepath = os.getenv( 'MODULEPATH' ):gsub( ':', '\n  * ' )
LmodMessage( 'DEBUG: ' .. mode() .. ' ' .. myModuleFullName() .. ': The MODULEPATH before exiting ' .. myModuleFullName() .. ' is:\n  * ' .. modulepath .. '\n' )
