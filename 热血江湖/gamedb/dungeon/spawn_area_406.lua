----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[40601] = {	id = 40601, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40601,  } , spawndeny = 0 },
	[40611] = {	id = 40611, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40611, 40612, 40613, 40614,  } , spawndeny = 0 },
	[40621] = {	id = 40621, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40621, 40622, 40623, 40624,  } , spawndeny = 0 },
	[40631] = {	id = 40631, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40631,  } , spawndeny = 0 },
	[40632] = {	id = 40632, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40632,  } , spawndeny = 0 },
	[40633] = {	id = 40633, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40633,  } , spawndeny = 0 },
	[40634] = {	id = 40634, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40634,  } , spawndeny = 0 },
	[40641] = {	id = 40641, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40641, 40642, 40643, 40644,  } , spawndeny = 0 },
	[40651] = {	id = 40651, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40651,  } , spawndeny = 0 },
	[40661] = {	id = 40661, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40661, 40662, 40663, 40664,  } , spawndeny = 0 },
	[40671] = {	id = 40671, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40671, 40672, 40673, 40674,  } , spawndeny = 0 },
	[40681] = {	id = 40681, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40681,  } , spawndeny = 0 },
	[40682] = {	id = 40682, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40682,  } , spawndeny = 0 },
	[40683] = {	id = 40683, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40683,  } , spawndeny = 0 },
	[40684] = {	id = 40684, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40684,  } , spawndeny = 0 },
	[40691] = {	id = 40691, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40691, 40692, 40693, 40694,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
