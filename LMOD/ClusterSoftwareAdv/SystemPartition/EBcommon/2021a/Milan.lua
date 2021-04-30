LmodMessage( 'DEBUG: ' .. mode() .. ' ' .. myModuleFullName() .. '(' .. myFileName() .. ')' )

family( 'SystemPartition' )
add_property( 'lmod', 'sticky' )

local mroot = os.getenv( 'MODULEROOT' )
local partition = myModuleName()

local hierarchy = hierarchyA( myModuleFullName(), 2 )
LmodMessage( 'DEBUG: ' .. mode() .. ' ' .. myModuleFullName() .. ': hierarchyA( myModuleFullName(), 2 ) returns hierarchy[1]: ' .. hierarchy[1] .. ', hierarchy[2]: ' .. hierarchy[2] )
LmodMessage( 'DEBUG: ' .. mode() .. ' ' .. myModuleFullName() .. ': I am for the ' .. hierarchy[2] .. '/' .. hierarchy[1] .. ' Software stack' )

whatis( 'Dummy partition module to activate the ' .. hierarchy[2] .. '/' .. hierarchy[1] .. ' software stack on the ' .. partition .. ' partition and to test hierarchyA' )

help( [[
Description
===========

This dummy ]] .. myModuleFullName() .. [[ module shows how to activate software
for the ]] .. hierarchy[1] .. [[ software stack on ]] .. partition .. [[ partition and
to demonstrate how the Lmod function hierarchyA can be used to write a
generic module file that will work correctly in all circumstances.
]] )

prepend_path( 'MODULEPATH', pathJoin( mroot, 'Applications', hierarchy[2], hierarchy[1], 'partition', partition ) )

local modulepath = os.getenv( 'MODULEPATH' ):gsub( ':', '\n  * ' )
LmodMessage( 'DEBUG: ' .. mode() .. ' ' .. myModuleFullName() .. ': The MODULEPATH before exiting ' .. myModuleFullName() .. ' is:\n  * ' .. modulepath .. '\n' )
