----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[43701] = {	id = 43701, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43701, 43702,  } , spawndeny = 0 },
	[43711] = {	id = 43711, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43711, 43712, 43713, 43714,  } , spawndeny = 0 },
	[43721] = {	id = 43721, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43721, 43722, 43723, 43724,  } , spawndeny = 0 },
	[43731] = {	id = 43731, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43731,  } , spawndeny = 0 },
	[43732] = {	id = 43732, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43732,  } , spawndeny = 0 },
	[43733] = {	id = 43733, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43733,  } , spawndeny = 0 },
	[43734] = {	id = 43734, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43734,  } , spawndeny = 0 },
	[43741] = {	id = 43741, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43741, 43742, 43743, 43744,  } , spawndeny = 0 },
	[43751] = {	id = 43751, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43751, 43752,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
