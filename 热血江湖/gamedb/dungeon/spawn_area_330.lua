----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[33001] = {	id = 33001, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 33001, 33002, 33003, 33004, 33005, 33006, 33007, 33008, 33009, 33010,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
