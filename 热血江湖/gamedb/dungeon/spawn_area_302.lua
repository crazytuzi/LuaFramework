----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[30201] = {	id = 30201, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30201, 30202,  } , spawndeny = 0 },
	[30202] = {	id = 30202, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30203, 30204,  } , spawndeny = 0 },
	[30203] = {	id = 30203, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30205, 30206,  } , spawndeny = 0 },
	[30204] = {	id = 30204, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30207, 30208,  } , spawndeny = 0 },
	[30205] = {	id = 30205, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30209, 30210,  } , spawndeny = 0 },
	[30206] = {	id = 30206, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30211,  } , spawndeny = 0 },
	[30207] = {	id = 30207, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30212,  } , spawndeny = 0 },
	[30208] = {	id = 30208, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30213,  } , spawndeny = 0 },
	[30209] = {	id = 30209, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30214,  } , spawndeny = 0 },
	[30210] = {	id = 30210, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30215,  } , spawndeny = 0 },
	[30211] = {	id = 30211, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30216,  } , spawndeny = 0 },
	[30212] = {	id = 30212, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30217,  } , spawndeny = 0 },
	[30213] = {	id = 30213, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30218,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
