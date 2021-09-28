----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[5001] = {	id = 5001, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 500101, 500102, 500103, 500104,  } , spawndeny = 0 },
	[5002] = {	id = 5002, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5001,  }, EndClose = {  }, spawnPoints = { 500105, 500106, 500107, 500108,  } , spawndeny = 0 },
	[5003] = {	id = 5003, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 500201, 500202, 500203, 500204,  } , spawndeny = 0 },
	[5004] = {	id = 5004, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5006,  }, EndClose = {  }, spawnPoints = { 500301, 500302, 500303, 500304, 500305, 500306,  } , spawndeny = 0 },
	[5005] = {	id = 5005, range = 2000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 500401, 500402, 500403, 500404, 500405,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
