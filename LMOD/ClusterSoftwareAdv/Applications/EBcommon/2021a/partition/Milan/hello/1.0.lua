LmodMessage( 'DEBUG: ' .. mode() .. ' ' .. myModuleFullName() .. '(' .. myFileName() .. ')' )

local hierarchy = hierarchyA( myModuleFullName(), 2 )
LmodMessage( 'DEBUG: ' .. mode() .. ' ' .. myModuleFullName() .. ': hierarchyA( myModuleFullName(), 2 ) returns hierarchy[1]: ' .. hierarchy[1] .. ', hierarchy[2]: ' .. hierarchy[2] )
LmodMessage( 'DEBUG: ' .. mode() .. ' ' .. myModuleFullName() .. ': Hello from the ' .. hierarchy[2] .. ' Software stack in the ' .. hierarchy[1] .. ' partition.\n' )

whatis( 'Just an empty hello module for the ' .. hierarchy[2] .. ' software stack in the ' .. hierarchy[1] .. ' partition.' )

help( [[
Description
===========
Just an empty hello module for the ]] .. hierarchy[2] .. [[ software stack in
the ]] .. hierarchy[1] .. [[ partition.
]] )

