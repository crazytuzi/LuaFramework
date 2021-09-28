----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[27201] = {	id = 27201, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 27201, 27202, 27203, 27204, 27205, 27206,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
