----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[38201] = {	id = 38201, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 38201, 38202, 38203, 38204, 38205, 38206,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
