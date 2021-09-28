----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[37001] = {	id = 37001, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 37001, 37002, 37003, 37004, 37005, 37006, 37007, 37008, 37009, 37010,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
