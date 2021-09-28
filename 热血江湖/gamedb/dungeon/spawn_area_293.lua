----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[29301] = {	id = 29301, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 29301, 29302, 29303, 29304,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
