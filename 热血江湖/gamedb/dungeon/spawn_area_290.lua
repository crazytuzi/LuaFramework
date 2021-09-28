----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[29001] = {	id = 29001, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 29001, 29002, 29003, 29004, 29005, 29006, 29007, 29008, 29009, 29010,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
