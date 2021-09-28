----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[37601] = {	id = 37601, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 37601, 37602, 37603, 37604,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
