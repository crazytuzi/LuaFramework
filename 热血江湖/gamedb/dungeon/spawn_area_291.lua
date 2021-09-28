----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[29101] = {	id = 29101, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 29101, 29102, 29103, 29104, 29105, 29106,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
