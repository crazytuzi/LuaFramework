----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[38801] = {	id = 38801, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 38801, 38802, 38803, 38804, 38805, 38806,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
