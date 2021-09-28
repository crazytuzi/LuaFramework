----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[80301] = {	id = 80301, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80301, 80302,  } , spawndeny = 3000 },
	[80321] = {	id = 80321, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80321, 80322, 80323, 80324, 80325, 80326,  } , spawndeny = 3000 },
	[80341] = {	id = 80341, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80341, 80342, 80343, 80344, 80345, 80346,  } , spawndeny = 3000 },
	[80361] = {	id = 80361, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80361, 80362, 80363, 80364, 80365, 80366, 80367, 80368,  } , spawndeny = 3000 },
	[80381] = {	id = 80381, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80381, 80382, 80383, 80384,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
