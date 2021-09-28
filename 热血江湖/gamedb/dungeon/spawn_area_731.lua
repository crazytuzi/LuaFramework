----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[73101] = {	id = 73101, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73101, 73102, 73103,  } , spawndeny = 0 },
	[73102] = {	id = 73102, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73104, 73105, 73106,  } , spawndeny = 0 },
	[73103] = {	id = 73103, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73107, 73108, 73109,  } , spawndeny = 0 },
	[73104] = {	id = 73104, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73110, 73111, 73112,  } , spawndeny = 0 },
	[73105] = {	id = 73105, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73113, 73114, 73115,  } , spawndeny = 0 },
	[73106] = {	id = 73106, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73116, 73117, 73118,  } , spawndeny = 0 },
	[73107] = {	id = 73107, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73119, 73120, 73121,  } , spawndeny = 0 },
	[73108] = {	id = 73108, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73122, 73123, 73124,  } , spawndeny = 0 },
	[73109] = {	id = 73109, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73125, 73126, 73127,  } , spawndeny = 0 },
	[73110] = {	id = 73110, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73128, 73129, 73130,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
