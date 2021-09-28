----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[27001] = {	id = 27001, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 27001, 27002, 27003, 27004, 27005, 27006, 27007, 27008, 27009, 27010,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
