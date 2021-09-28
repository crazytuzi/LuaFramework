----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[450002] = {	id = 450002, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 450002,  } , spawndeny = 0 },
	[450004] = {	id = 450004, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 450004,  } , spawndeny = 0 },
	[450003] = {	id = 450003, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 450003,  } , spawndeny = 0 },
	[450005] = {	id = 450005, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 450005,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
