----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[26001] = {	id = 26001, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 26001, 26002, 26003, 26004, 26005, 26006, 26007, 26008, 26009, 26010,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
