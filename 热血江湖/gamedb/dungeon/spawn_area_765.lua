----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[76501] = {	id = 76501, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76501, 76502, 76503,  } , spawndeny = 0 },
	[76502] = {	id = 76502, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76504, 76505, 76506,  } , spawndeny = 0 },
	[76503] = {	id = 76503, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76507, 76508, 76509,  } , spawndeny = 0 },
	[76504] = {	id = 76504, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76510, 76511, 76512,  } , spawndeny = 0 },
	[76505] = {	id = 76505, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76513, 76514, 76515,  } , spawndeny = 0 },
	[76506] = {	id = 76506, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76516, 76517, 76518,  } , spawndeny = 0 },
	[76507] = {	id = 76507, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76519, 76520, 76521,  } , spawndeny = 0 },
	[76508] = {	id = 76508, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76522, 76523, 76524,  } , spawndeny = 0 },
	[76509] = {	id = 76509, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76525, 76526, 76527,  } , spawndeny = 0 },
	[76510] = {	id = 76510, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76528, 76529, 76530,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
