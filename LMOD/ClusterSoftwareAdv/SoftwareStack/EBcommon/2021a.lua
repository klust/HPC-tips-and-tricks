LmodMessage( 'DEBUG: ' .. mode() .. ' ' .. myModuleFullName() .. '(' .. myFileName() .. ')' )

family( 'SoftwareStack' )
add_property( 'lmod', 'sticky' )

local mroot = os.getenv( 'MODULEROOT' )
if mroot == nil then LmodError( 'Failed to load MODULEROOT' ) end

local partition = os.getenv( 'EXAMPLE_PARTITION' )
if partition == nil then LmodError( 'Failed to load EXAMPLE_PARTITION' ) end

whatis( 'Dummy ' .. myModuleFullName() .. ' SoftwareStack module to test hierarchyA.' )

help( [[
Description
===========

Dummy ]] .. myModuleFullName() .. [[ SoftwareStack module to test hierarchyA.
]] )

prepend_path( 'MODULEPATH', pathJoin( mroot, 'SystemPartition', myModuleName(), myModuleVersion() ) )

load( 'partition/' .. partition )

local modulepath = os.getenv( 'MODULEPATH' ):gsub( ':', '\n  * ' )
LmodMessage( 'DEBUG: ' .. mode() .. ' ' .. myModuleFullName() .. ': The MODULEPATH before exiting ' .. myModuleFullName() .. ' is:\n  * ' .. modulepath .. '\n' )
