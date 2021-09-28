----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[38301] = {	id = 38301, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 38301, 38302, 38303, 38304,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
