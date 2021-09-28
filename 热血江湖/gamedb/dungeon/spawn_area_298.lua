----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[29801] = {	id = 29801, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 29801, 29802, 29803, 29804, 29805, 29806,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
