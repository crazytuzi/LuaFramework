----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[37201] = {	id = 37201, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 37201, 37202, 37203, 37204, 37205, 37206,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
