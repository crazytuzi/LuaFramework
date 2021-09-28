----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[29501] = {	id = 29501, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 29501, 29502, 29503, 29504, 29505, 29506,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
