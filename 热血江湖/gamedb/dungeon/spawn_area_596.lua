----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[59601] = {	id = 59601, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59601,  } , spawndeny = 0 },
	[59602] = {	id = 59602, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59602,  } , spawndeny = 0 },
	[59603] = {	id = 59603, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59603,  } , spawndeny = 0 },
	[59604] = {	id = 59604, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59604,  } , spawndeny = 0 },
	[59605] = {	id = 59605, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59605,  } , spawndeny = 0 },
	[59606] = {	id = 59606, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59606,  } , spawndeny = 0 },
	[59607] = {	id = 59607, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59607,  } , spawndeny = 0 },
	[59608] = {	id = 59608, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59608,  } , spawndeny = 0 },
	[59609] = {	id = 59609, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59609,  } , spawndeny = 0 },
	[59610] = {	id = 59610, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59610,  } , spawndeny = 0 },
	[59611] = {	id = 59611, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59611,  } , spawndeny = 0 },
	[59612] = {	id = 59612, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59612,  } , spawndeny = 0 },
	[59613] = {	id = 59613, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59613,  } , spawndeny = 0 },
	[59651] = {	id = 59651, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59651,  } , spawndeny = 0 },
	[59652] = {	id = 59652, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59652,  } , spawndeny = 0 },
	[59653] = {	id = 59653, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59653,  } , spawndeny = 0 },
	[59654] = {	id = 59654, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59654,  } , spawndeny = 0 },
	[59655] = {	id = 59655, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59655,  } , spawndeny = 0 },
	[59656] = {	id = 59656, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59656,  } , spawndeny = 0 },
	[59657] = {	id = 59657, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59657,  } , spawndeny = 0 },
	[59658] = {	id = 59658, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59658,  } , spawndeny = 0 },
	[59659] = {	id = 59659, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59659,  } , spawndeny = 0 },
	[59660] = {	id = 59660, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59660,  } , spawndeny = 0 },
	[59661] = {	id = 59661, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59661,  } , spawndeny = 0 },
	[59662] = {	id = 59662, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59662,  } , spawndeny = 0 },
	[59663] = {	id = 59663, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 59663,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
