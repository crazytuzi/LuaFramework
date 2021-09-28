----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[26601] = {	id = 26601, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 26601, 26602, 26603, 26604,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
