----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[37401] = {	id = 37401, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 37401, 37402, 37403, 37404, 37405, 37406, 37407, 37408, 37409, 37410,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
