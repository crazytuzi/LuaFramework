----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[37501] = {	id = 37501, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 37501, 37502, 37503, 37504, 37505, 37506,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
