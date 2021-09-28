----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[3538301] = {	id = 3538301, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538301,  } , spawndeny = 0 },
	[3538302] = {	id = 3538302, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538302,  } , spawndeny = 0 },
	[3538303] = {	id = 3538303, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538303,  } , spawndeny = 0 },
	[3538304] = {	id = 3538304, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538304,  } , spawndeny = 0 },
	[3538305] = {	id = 3538305, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538305, 3538306, 3538307, 3538308,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
