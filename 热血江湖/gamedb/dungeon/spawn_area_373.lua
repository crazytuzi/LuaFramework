----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[37301] = {	id = 37301, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 37301, 37302, 37303, 37304,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
