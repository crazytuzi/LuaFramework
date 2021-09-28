----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[28601] = {	id = 28601, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 28601, 28602, 28603, 28604,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
