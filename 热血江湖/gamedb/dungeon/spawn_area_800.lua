----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[80001] = {	id = 80001, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80001, 80002, 80003, 80004, 80005, 80006,  } , spawndeny = 5000 },
	[80021] = {	id = 80021, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80021, 80022, 80023, 80024, 80025, 80026,  } , spawndeny = 3000 },
	[80041] = {	id = 80041, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80041, 80042, 80043, 80044, 80045, 80046, 80047, 80048,  } , spawndeny = 3000 },
	[80061] = {	id = 80061, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80061, 80062,  } , spawndeny = 3000 },
	[80081] = {	id = 80081, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80081, 80082, 80083, 80084, 80085, 80086,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
