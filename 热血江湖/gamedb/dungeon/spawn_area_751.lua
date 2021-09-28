----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[75101] = {	id = 75101, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75101, 75102, 75103,  } , spawndeny = 0 },
	[75102] = {	id = 75102, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75104, 75105, 75106,  } , spawndeny = 0 },
	[75103] = {	id = 75103, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75107, 75108, 75109,  } , spawndeny = 0 },
	[75104] = {	id = 75104, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75110, 75111, 75112,  } , spawndeny = 0 },
	[75105] = {	id = 75105, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75113, 75114, 75115,  } , spawndeny = 0 },
	[75106] = {	id = 75106, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75116, 75117, 75118,  } , spawndeny = 0 },
	[75107] = {	id = 75107, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75119, 75120, 75121,  } , spawndeny = 0 },
	[75108] = {	id = 75108, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75122, 75123, 75124,  } , spawndeny = 0 },
	[75109] = {	id = 75109, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75125, 75126, 75127,  } , spawndeny = 0 },
	[75110] = {	id = 75110, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75128, 75129, 75130,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
