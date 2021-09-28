----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[11601] = {	id = 11601, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110601,  } , spawndeny = 0 },
	[11602] = {	id = 11602, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110602,  } , spawndeny = 0 },
	[11603] = {	id = 11603, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110603, 110604,  } , spawndeny = 0 },
	[11611] = {	id = 11611, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110611,  } , spawndeny = 0 },
	[11612] = {	id = 11612, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110612,  } , spawndeny = 0 },
	[11613] = {	id = 11613, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110613, 110614,  } , spawndeny = 0 },
	[11621] = {	id = 11621, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110621,  } , spawndeny = 0 },
	[11622] = {	id = 11622, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110622,  } , spawndeny = 0 },
	[11623] = {	id = 11623, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110623, 110624,  } , spawndeny = 0 },
	[11631] = {	id = 11631, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110631,  } , spawndeny = 0 },
	[11632] = {	id = 11632, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110632,  } , spawndeny = 0 },
	[11633] = {	id = 11633, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110633, 110634,  } , spawndeny = 0 },
	[11641] = {	id = 11641, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110641,  } , spawndeny = 0 },
	[11642] = {	id = 11642, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110642,  } , spawndeny = 0 },
	[11643] = {	id = 11643, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110643, 110644,  } , spawndeny = 0 },
	[11651] = {	id = 11651, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110651,  } , spawndeny = 0 },
	[11652] = {	id = 11652, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110652,  } , spawndeny = 0 },
	[11653] = {	id = 11653, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110653, 110654,  } , spawndeny = 0 },
	[11661] = {	id = 11661, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110661,  } , spawndeny = 0 },
	[11662] = {	id = 11662, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110662,  } , spawndeny = 0 },
	[11663] = {	id = 11663, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110663, 110664,  } , spawndeny = 0 },
	[11671] = {	id = 11671, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110671,  } , spawndeny = 0 },
	[11672] = {	id = 11672, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110672,  } , spawndeny = 0 },
	[11673] = {	id = 11673, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110673, 110674,  } , spawndeny = 0 },
	[11681] = {	id = 11681, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110681,  } , spawndeny = 0 },
	[11682] = {	id = 11682, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110682,  } , spawndeny = 0 },
	[11683] = {	id = 11683, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110683, 110684,  } , spawndeny = 0 },
	[11691] = {	id = 11691, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110691,  } , spawndeny = 0 },
	[11692] = {	id = 11692, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110692,  } , spawndeny = 0 },
	[11693] = {	id = 11693, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110693, 110694,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
