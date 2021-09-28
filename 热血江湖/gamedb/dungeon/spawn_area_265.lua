----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[26501] = {	id = 26501, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 26501, 26502, 26503, 26504, 26505, 26506,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
