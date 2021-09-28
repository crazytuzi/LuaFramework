----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[74101] = {	id = 74101, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74101, 74102, 74103,  } , spawndeny = 0 },
	[74102] = {	id = 74102, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74104, 74105, 74106,  } , spawndeny = 0 },
	[74103] = {	id = 74103, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74107, 74108, 74109,  } , spawndeny = 0 },
	[74104] = {	id = 74104, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74110, 74111, 74112,  } , spawndeny = 0 },
	[74105] = {	id = 74105, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74113, 74114, 74115,  } , spawndeny = 0 },
	[74106] = {	id = 74106, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74116, 74117, 74118,  } , spawndeny = 0 },
	[74107] = {	id = 74107, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74119, 74120, 74121,  } , spawndeny = 0 },
	[74108] = {	id = 74108, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74122, 74123, 74124,  } , spawndeny = 0 },
	[74109] = {	id = 74109, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74125, 74126, 74127,  } , spawndeny = 0 },
	[74110] = {	id = 74110, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74128, 74129, 74130,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
