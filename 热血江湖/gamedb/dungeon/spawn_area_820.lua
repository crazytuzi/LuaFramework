----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[82001] = {	id = 82001, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 82001, 82002,  } , spawndeny = 3000 },
	[82021] = {	id = 82021, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 82021, 82022,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
