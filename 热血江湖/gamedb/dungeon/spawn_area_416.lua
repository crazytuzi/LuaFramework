----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[41601] = {	id = 41601, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41601,  } , spawndeny = 0 },
	[41611] = {	id = 41611, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41611, 41612, 41613, 41614,  } , spawndeny = 0 },
	[41621] = {	id = 41621, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41621, 41622, 41623, 41624,  } , spawndeny = 0 },
	[41631] = {	id = 41631, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41631,  } , spawndeny = 0 },
	[41632] = {	id = 41632, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41632,  } , spawndeny = 0 },
	[41633] = {	id = 41633, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41633,  } , spawndeny = 0 },
	[41634] = {	id = 41634, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41634,  } , spawndeny = 0 },
	[41641] = {	id = 41641, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41641, 41642, 41643, 41644,  } , spawndeny = 0 },
	[41651] = {	id = 41651, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41651,  } , spawndeny = 0 },
	[41661] = {	id = 41661, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41661, 41662, 41663, 41664,  } , spawndeny = 0 },
	[41671] = {	id = 41671, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41671, 41672, 41673, 41674,  } , spawndeny = 0 },
	[41681] = {	id = 41681, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41681,  } , spawndeny = 0 },
	[41682] = {	id = 41682, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41682,  } , spawndeny = 0 },
	[41683] = {	id = 41683, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41683,  } , spawndeny = 0 },
	[41684] = {	id = 41684, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41684,  } , spawndeny = 0 },
	[41691] = {	id = 41691, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41691, 41692, 41693, 41694,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
