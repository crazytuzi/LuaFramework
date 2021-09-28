----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[63200] = {	id = 63200, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63201, 63202, 63203, 63204,  } , spawndeny = 0 },
	[63210] = {	id = 63210, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63211, 63212,  } , spawndeny = 0 },
	[63220] = {	id = 63220, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63221, 63222, 63223, 63224,  } , spawndeny = 0 },
	[63230] = {	id = 63230, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63231, 63232,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
