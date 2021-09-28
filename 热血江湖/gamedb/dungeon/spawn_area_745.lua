----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[74501] = {	id = 74501, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74501, 74502, 74503,  } , spawndeny = 0 },
	[74502] = {	id = 74502, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74504, 74505, 74506,  } , spawndeny = 0 },
	[74503] = {	id = 74503, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74507, 74508, 74509,  } , spawndeny = 0 },
	[74504] = {	id = 74504, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74510, 74511, 74512,  } , spawndeny = 0 },
	[74505] = {	id = 74505, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74513, 74514, 74515,  } , spawndeny = 0 },
	[74506] = {	id = 74506, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74516, 74517, 74518,  } , spawndeny = 0 },
	[74507] = {	id = 74507, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74519, 74520, 74521,  } , spawndeny = 0 },
	[74508] = {	id = 74508, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74522, 74523, 74524,  } , spawndeny = 0 },
	[74509] = {	id = 74509, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74525, 74526, 74527,  } , spawndeny = 0 },
	[74510] = {	id = 74510, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74528, 74529, 74530,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
