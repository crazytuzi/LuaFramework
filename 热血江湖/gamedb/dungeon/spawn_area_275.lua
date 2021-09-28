----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[27501] = {	id = 27501, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 27501, 27502, 27503, 27504, 27505, 27506,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
