----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[38601] = {	id = 38601, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 38601, 38602, 38603, 38604,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
