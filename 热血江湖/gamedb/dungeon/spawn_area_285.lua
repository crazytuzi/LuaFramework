----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[28501] = {	id = 28501, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 28501, 28502, 28503, 28504, 28505, 28506,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
