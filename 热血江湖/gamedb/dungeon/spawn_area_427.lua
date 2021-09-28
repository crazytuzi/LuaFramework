----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[42701] = {	id = 42701, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42701,  } , spawndeny = 0 },
	[42711] = {	id = 42711, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42711, 42712, 42713, 42714,  } , spawndeny = 0 },
	[42721] = {	id = 42721, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42721, 42722, 42723, 42724,  } , spawndeny = 0 },
	[42731] = {	id = 42731, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42731,  } , spawndeny = 0 },
	[42732] = {	id = 42732, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42732,  } , spawndeny = 0 },
	[42733] = {	id = 42733, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42733,  } , spawndeny = 0 },
	[42734] = {	id = 42734, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42734,  } , spawndeny = 0 },
	[42741] = {	id = 42741, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42741, 42742, 42743, 42744,  } , spawndeny = 0 },
	[42751] = {	id = 42751, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42751,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
