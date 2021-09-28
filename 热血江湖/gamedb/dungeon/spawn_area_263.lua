----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[26301] = {	id = 26301, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 26301, 26302, 26303, 26304,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
