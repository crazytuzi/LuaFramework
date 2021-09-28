----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[29201] = {	id = 29201, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 29201, 29202, 29203, 29204, 29205, 29206,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
