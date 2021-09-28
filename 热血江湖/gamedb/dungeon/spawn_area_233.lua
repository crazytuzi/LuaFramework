----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[23301] = {	id = 23301, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 23301,  } , spawndeny = 0 },
	[23302] = {	id = 23302, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 23302,  } , spawndeny = 0 },
	[23303] = {	id = 23303, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 23303,  } , spawndeny = 0 },
	[23304] = {	id = 23304, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 23304,  } , spawndeny = 0 },
	[23305] = {	id = 23305, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 23305,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
