----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[38501] = {	id = 38501, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 38501, 38502, 38503, 38504, 38505, 38506,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
