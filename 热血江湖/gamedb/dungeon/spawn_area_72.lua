----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[7201] = {	id = 7201, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 720101, 720102, 720103, 720104,  } , spawndeny = 0 },
	[7202] = {	id = 7202, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7201,  }, EndClose = {  }, spawnPoints = { 720201, 720202, 720203, 720204,  } , spawndeny = 0 },
	[7203] = {	id = 7203, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 720301, 720302, 720303, 720304,  } , spawndeny = 0 },
	[7204] = {	id = 7204, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7202,  }, EndClose = {  }, spawnPoints = { 720401, 720402, 720403, 720404,  } , spawndeny = 0 },
	[7205] = {	id = 7205, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 720501, 720502, 720503, 720504, 720505, 720506, 720507,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
