----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[43601] = {	id = 43601, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43601, 43602,  } , spawndeny = 0 },
	[43611] = {	id = 43611, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43611, 43612, 43613, 43614,  } , spawndeny = 0 },
	[43621] = {	id = 43621, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43621, 43622, 43623, 43624,  } , spawndeny = 0 },
	[43631] = {	id = 43631, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43631,  } , spawndeny = 0 },
	[43632] = {	id = 43632, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43632,  } , spawndeny = 0 },
	[43633] = {	id = 43633, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43633,  } , spawndeny = 0 },
	[43634] = {	id = 43634, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43634,  } , spawndeny = 0 },
	[43641] = {	id = 43641, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43641, 43642, 43643, 43644,  } , spawndeny = 0 },
	[43651] = {	id = 43651, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43651, 43652,  } , spawndeny = 0 },
	[43661] = {	id = 43661, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43661, 43662, 43663, 43664,  } , spawndeny = 0 },
	[43671] = {	id = 43671, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43671, 43672, 43673, 43674,  } , spawndeny = 0 },
	[43681] = {	id = 43681, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43681,  } , spawndeny = 0 },
	[43682] = {	id = 43682, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43682,  } , spawndeny = 0 },
	[43683] = {	id = 43683, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43683,  } , spawndeny = 0 },
	[43684] = {	id = 43684, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43684,  } , spawndeny = 0 },
	[43691] = {	id = 43691, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43691, 43692, 43693, 43694,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
