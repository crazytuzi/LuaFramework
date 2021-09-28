----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[28001] = {	id = 28001, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 28001, 28002, 28003, 28004, 28005, 28006, 28007, 28008, 28009, 28010,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
