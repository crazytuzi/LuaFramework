----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[38101] = {	id = 38101, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 38101, 38102, 38103, 38104, 38105, 38106,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
