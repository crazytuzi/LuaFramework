----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[27301] = {	id = 27301, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 27301, 27302, 27303, 27304,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
