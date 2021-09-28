----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[27801] = {	id = 27801, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 27801, 27802, 27803, 27804, 27805, 27806,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
