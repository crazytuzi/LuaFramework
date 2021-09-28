----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[39221] = {	id = 39221, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39221,  } , spawndeny = 10000 },
	[39222] = {	id = 39222, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39222,  } , spawndeny = 10000 },
	[39223] = {	id = 39223, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39223,  } , spawndeny = 10000 },
	[39224] = {	id = 39224, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39224,  } , spawndeny = 10000 },
	[39225] = {	id = 39225, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39225,  } , spawndeny = 10000 },
	[39226] = {	id = 39226, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39226,  } , spawndeny = 10000 },
	[39227] = {	id = 39227, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39227,  } , spawndeny = 10000 },

};
function get_db_table()
	return spawn_area;
end
