----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[3901] = {	id = 3901, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3901,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 390101, 390102,  } , spawndeny = 0 },
	[3902] = {	id = 3902, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 3901,  }, EndClose = {  }, spawnPoints = { 390201, 390202, 390203, 390204, 390205,  } , spawndeny = 0 },
	[3903] = {	id = 3903, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3902,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 390301, 390302, 390303, 390304,  } , spawndeny = 0 },
	[3904] = {	id = 3904, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 3902,  }, EndClose = {  }, spawnPoints = { 390401, 390402, 390403, 390404,  } , spawndeny = 0 },
	[3905] = {	id = 3905, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 390501, 390502, 390503, 390504, 390505,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
