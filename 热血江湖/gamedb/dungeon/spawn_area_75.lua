----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[7501] = {	id = 7501, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 750101, 750102, 750103, 750104, 750105, 750106,  } , spawndeny = 0 },
	[7502] = {	id = 7502, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7206,  }, EndClose = {  }, spawnPoints = { 750201, 750202, 750203, 750204,  } , spawndeny = 0 },
	[7503] = {	id = 7503, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7207,  }, EndClose = {  }, spawnPoints = { 750301, 750302, 750303, 750304, 750305,  } , spawndeny = 0 },
	[7504] = {	id = 7504, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 750401, 750402, 750403,  } , spawndeny = 0 },
	[7505] = {	id = 7505, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 750501,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
