----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[38901] = {	id = 38901, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 38901, 38902,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
