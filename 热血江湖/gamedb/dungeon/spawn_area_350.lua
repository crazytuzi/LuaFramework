----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[35001] = {	id = 35001, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 35001, 35002, 35003, 35004, 35005, 35006, 35007, 35008, 35009, 35010,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
