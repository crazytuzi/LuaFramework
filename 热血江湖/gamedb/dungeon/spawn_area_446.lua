----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[44601] = {	id = 44601, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44601, 44602, 44603, 44604, 44605, 44606,  } , spawndeny = 0 },
	[44611] = {	id = 44611, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44611, 44612, 44613, 44614,  } , spawndeny = 0 },
	[44621] = {	id = 44621, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44621, 44622, 44623, 44624,  } , spawndeny = 0 },
	[44631] = {	id = 44631, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44631,  } , spawndeny = 0 },
	[44632] = {	id = 44632, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44632,  } , spawndeny = 0 },
	[44633] = {	id = 44633, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44633,  } , spawndeny = 0 },
	[44634] = {	id = 44634, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44634,  } , spawndeny = 0 },
	[44641] = {	id = 44641, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44641, 44642, 44643, 44644,  } , spawndeny = 0 },
	[44651] = {	id = 44651, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44651, 44652, 44653, 44654, 44655, 44656,  } , spawndeny = 0 },
	[44661] = {	id = 44661, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44661, 44662, 44663, 44664,  } , spawndeny = 0 },
	[44671] = {	id = 44671, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44671, 44672, 44673, 44674,  } , spawndeny = 0 },
	[44681] = {	id = 44681, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44681,  } , spawndeny = 0 },
	[44682] = {	id = 44682, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44682,  } , spawndeny = 0 },
	[44683] = {	id = 44683, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44683,  } , spawndeny = 0 },
	[44684] = {	id = 44684, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44684,  } , spawndeny = 0 },
	[44691] = {	id = 44691, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44691, 44692, 44693, 44694,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
