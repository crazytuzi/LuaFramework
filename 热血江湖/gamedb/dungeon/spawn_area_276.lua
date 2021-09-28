----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[27601] = {	id = 27601, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 27601, 27602, 27603, 27604,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
