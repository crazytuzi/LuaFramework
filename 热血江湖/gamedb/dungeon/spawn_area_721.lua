----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[72101] = {	id = 72101, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72101, 72102, 72103,  } , spawndeny = 0 },
	[72102] = {	id = 72102, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72104, 72105, 72106,  } , spawndeny = 0 },
	[72103] = {	id = 72103, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72107, 72108, 72109,  } , spawndeny = 0 },
	[72104] = {	id = 72104, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72110, 72111, 72112,  } , spawndeny = 0 },
	[72105] = {	id = 72105, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72113, 72114, 72115,  } , spawndeny = 0 },
	[72106] = {	id = 72106, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72116, 72117, 72118,  } , spawndeny = 0 },
	[72107] = {	id = 72107, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72119, 72120, 72121,  } , spawndeny = 0 },
	[72108] = {	id = 72108, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72122, 72123, 72124,  } , spawndeny = 0 },
	[72109] = {	id = 72109, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72125, 72126, 72127,  } , spawndeny = 0 },
	[72110] = {	id = 72110, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72128, 72129, 72130,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
