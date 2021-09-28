----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[28201] = {	id = 28201, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 28201, 28202, 28203, 28204, 28205, 28206,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
