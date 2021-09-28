----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[29601] = {	id = 29601, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 29601, 29602, 29603, 29604,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
