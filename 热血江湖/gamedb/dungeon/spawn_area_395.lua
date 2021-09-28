----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[39521] = {	id = 39521, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39521,  } , spawndeny = 10000 },
	[39522] = {	id = 39522, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39522,  } , spawndeny = 10000 },
	[39523] = {	id = 39523, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39523,  } , spawndeny = 10000 },
	[39524] = {	id = 39524, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39524,  } , spawndeny = 10000 },
	[39525] = {	id = 39525, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39525,  } , spawndeny = 10000 },
	[39526] = {	id = 39526, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39526,  } , spawndeny = 10000 },
	[39527] = {	id = 39527, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39527,  } , spawndeny = 10000 },

};
function get_db_table()
	return spawn_area;
end
