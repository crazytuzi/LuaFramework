----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[35801] = {	id = 35801, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 35801, 35802, 35803, 35804, 35805, 35806,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
