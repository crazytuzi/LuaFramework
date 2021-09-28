----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[35501] = {	id = 35501, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 35501, 35502, 35503, 35504, 35505, 35506,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
