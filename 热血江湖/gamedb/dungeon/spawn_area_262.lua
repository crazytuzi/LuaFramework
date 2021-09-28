----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[26201] = {	id = 26201, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 26201, 26202, 26203, 26204, 26205, 26206,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
