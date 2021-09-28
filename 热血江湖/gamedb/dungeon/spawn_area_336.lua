----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[33601] = {	id = 33601, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 33601, 33602, 33603, 33604,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
