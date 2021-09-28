----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[89404] = {	id = 89404, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 89404,  } , spawndeny = 0 },
	[89405] = {	id = 89405, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 89405,  } , spawndeny = 0 },
	[89406] = {	id = 89406, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 89406,  } , spawndeny = 0 },
	[89407] = {	id = 89407, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 89407,  } , spawndeny = 0 },
	[89408] = {	id = 89408, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 89408,  } , spawndeny = 0 },
	[89409] = {	id = 89409, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 89409,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
