----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[42601] = {	id = 42601, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42601,  } , spawndeny = 0 },
	[42611] = {	id = 42611, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42611, 42612, 42613, 42614,  } , spawndeny = 0 },
	[42621] = {	id = 42621, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42621, 42622, 42623, 42624,  } , spawndeny = 0 },
	[42631] = {	id = 42631, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42631,  } , spawndeny = 0 },
	[42632] = {	id = 42632, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42632,  } , spawndeny = 0 },
	[42633] = {	id = 42633, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42633,  } , spawndeny = 0 },
	[42634] = {	id = 42634, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42634,  } , spawndeny = 0 },
	[42641] = {	id = 42641, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42641, 42642, 42643, 42644,  } , spawndeny = 0 },
	[42651] = {	id = 42651, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42651,  } , spawndeny = 0 },
	[42661] = {	id = 42661, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42661, 42662, 42663, 42664,  } , spawndeny = 0 },
	[42671] = {	id = 42671, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42671, 42672, 42673, 42674,  } , spawndeny = 0 },
	[42681] = {	id = 42681, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42681,  } , spawndeny = 0 },
	[42682] = {	id = 42682, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42682,  } , spawndeny = 0 },
	[42683] = {	id = 42683, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42683,  } , spawndeny = 0 },
	[42684] = {	id = 42684, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42684,  } , spawndeny = 0 },
	[42691] = {	id = 42691, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42691, 42692, 42693, 42694,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
