----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[401001] = {	id = 401001, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351035, 351036, 351037, 351038, 351039,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
