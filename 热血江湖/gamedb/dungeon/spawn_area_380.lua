----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[38001] = {	id = 38001, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 38001, 38002, 38003, 38004, 38005, 38006, 38007, 38008, 38009, 38010,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
