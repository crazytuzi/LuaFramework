----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[33501] = {	id = 33501, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 33501, 33502, 33503, 33504, 33505, 33506,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
