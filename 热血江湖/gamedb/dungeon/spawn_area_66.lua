----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[6601] = {	id = 6601, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6501,  }, EndClose = {  }, spawnPoints = { 660101, 660102, 660103, 660104, 660105, 660106,  } , spawndeny = 0 },
	[6602] = {	id = 6602, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6502,  }, EndClose = {  }, spawnPoints = { 660201, 660202, 660203, 660204, 660205, 660206, 660207, 660208, 660209,  } , spawndeny = 0 },
	[6603] = {	id = 6603, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 660301, 660302, 660303, 660304, 660305, 660306,  } , spawndeny = 0 },
	[6604] = {	id = 6604, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 660307,  } , spawndeny = 0 },
	[6605] = {	id = 6605, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 660308,  } , spawndeny = 0 },
	[6606] = {	id = 6606, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6503,  }, EndClose = {  }, spawnPoints = { 660309,  } , spawndeny = 0 },
	[6607] = {	id = 6607, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 660401, 660402, 660403, 660404, 660405, 660406, 660407, 660408, 660409, 660410,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
