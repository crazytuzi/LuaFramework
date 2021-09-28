----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[28801] = {	id = 28801, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 28801, 28802, 28803, 28804, 28805, 28806,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
