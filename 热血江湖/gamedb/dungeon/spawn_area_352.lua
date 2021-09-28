----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[35201] = {	id = 35201, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 35201, 35202, 35203, 35204, 35205, 35206,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
