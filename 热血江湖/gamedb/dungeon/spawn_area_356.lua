----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[35601] = {	id = 35601, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 35601, 35602, 35603, 35604,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
