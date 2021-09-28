----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[80201] = {	id = 80201, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80201, 80202, 80203, 80204, 80205, 80206, 80207, 80208,  } , spawndeny = 3000 },
	[80221] = {	id = 80221, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80221, 80222,  } , spawndeny = 3000 },
	[80241] = {	id = 80241, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80241, 80242, 80243, 80244, 80245, 80246,  } , spawndeny = 3000 },
	[80261] = {	id = 80261, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80261, 80262, 80263, 80264, 80265, 80266,  } , spawndeny = 3000 },
	[80281] = {	id = 80281, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80281, 80282, 80283, 80284, 80285, 80286, 80287, 80288,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
