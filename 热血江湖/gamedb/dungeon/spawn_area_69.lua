----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[6901] = {	id = 6901, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 690101, 690102, 690103, 690104,  } , spawndeny = 0 },
	[6902] = {	id = 6902, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6901,  }, EndClose = {  }, spawnPoints = { 690201, 690202, 690203, 690204,  } , spawndeny = 0 },
	[6903] = {	id = 6903, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 690301, 690302, 690303, 690304, 690305,  } , spawndeny = 0 },
	[6904] = {	id = 6904, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6902,  }, EndClose = {  }, spawnPoints = { 690401, 690402, 690403, 690404, 690405, 690406,  } , spawndeny = 0 },
	[6905] = {	id = 6905, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 690501, 690502, 690503, 690504, 690505, 690506,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
