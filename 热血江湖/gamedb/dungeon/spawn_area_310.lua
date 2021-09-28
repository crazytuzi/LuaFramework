----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[31001] = {	id = 31001, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31001, 31002,  } , spawndeny = 0 },
	[31003] = {	id = 31003, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31003, 31004,  } , spawndeny = 0 },
	[31005] = {	id = 31005, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31005, 31006,  } , spawndeny = 0 },
	[31007] = {	id = 31007, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31007, 31008,  } , spawndeny = 0 },
	[31009] = {	id = 31009, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31009, 31010,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
