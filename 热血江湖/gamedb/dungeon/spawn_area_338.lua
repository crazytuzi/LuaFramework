----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[33801] = {	id = 33801, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 33801, 33802, 33803, 33804, 33805, 33806,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
