----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[6201] = {	id = 6201, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 620101, 620102, 620103, 620104, 620105, 620106, 620107, 620108,  } , spawndeny = 0 },
	[6202] = {	id = 6202, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 620201, 620202, 620203, 620204, 620205, 620206, 620207, 620208,  } , spawndeny = 0 },
	[6203] = {	id = 6203, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 620301, 620302, 620303, 620304, 620305, 620306, 620307, 620308,  } , spawndeny = 0 },
	[6204] = {	id = 6204, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6001,  }, EndClose = {  }, spawnPoints = { 620401, 620402, 620403, 620404, 620405, 620406, 620407, 620408,  } , spawndeny = 0 },
	[6205] = {	id = 6205, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 620501, 620502, 620503, 620504, 620505, 620506, 620507, 620508, 620509,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
