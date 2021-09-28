----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[72501] = {	id = 72501, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72501, 72502, 72503,  } , spawndeny = 0 },
	[72502] = {	id = 72502, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72504, 72505, 72506,  } , spawndeny = 0 },
	[72503] = {	id = 72503, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72507, 72508, 72509,  } , spawndeny = 0 },
	[72504] = {	id = 72504, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72510, 72511, 72512,  } , spawndeny = 0 },
	[72505] = {	id = 72505, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72513, 72514, 72515,  } , spawndeny = 0 },
	[72506] = {	id = 72506, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72516, 72517, 72518,  } , spawndeny = 0 },
	[72507] = {	id = 72507, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72519, 72520, 72521,  } , spawndeny = 0 },
	[72508] = {	id = 72508, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72522, 72523, 72524,  } , spawndeny = 0 },
	[72509] = {	id = 72509, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72525, 72526, 72527,  } , spawndeny = 0 },
	[72510] = {	id = 72510, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72528, 72529, 72530,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
