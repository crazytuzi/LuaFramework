----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[2901] = {	id = 2901, range = 950.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2701,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 290201, 290202,  } , spawndeny = 0 },
	[2902] = {	id = 2902, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2701,  }, EndClose = {  }, spawnPoints = { 290301, 290302, 290303,  } , spawndeny = 0 },
	[2903] = {	id = 2903, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2702,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 290401, 290402, 290403,  } , spawndeny = 0 },
	[2904] = {	id = 2904, range = 900.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2702,  }, EndClose = {  }, spawnPoints = { 290501, 290502, 290503, 290504, 290505,  } , spawndeny = 0 },
	[2905] = {	id = 2905, range = 350.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 290601, 290602, 290603, 290604, 290605, 290606, 290607, 290608, 290701, 290702,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
