----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[12601] = {	id = 12601, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111601,  } , spawndeny = 0 },
	[12602] = {	id = 12602, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111602,  } , spawndeny = 0 },
	[12603] = {	id = 12603, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111603, 111604,  } , spawndeny = 0 },
	[12604] = {	id = 12604, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111605,  } , spawndeny = 0 },
	[12611] = {	id = 12611, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111611,  } , spawndeny = 0 },
	[12612] = {	id = 12612, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111612,  } , spawndeny = 0 },
	[12613] = {	id = 12613, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111613, 111614,  } , spawndeny = 0 },
	[12614] = {	id = 12614, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111615,  } , spawndeny = 0 },
	[12621] = {	id = 12621, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111621,  } , spawndeny = 0 },
	[12622] = {	id = 12622, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111622,  } , spawndeny = 0 },
	[12623] = {	id = 12623, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111623, 111624,  } , spawndeny = 0 },
	[12624] = {	id = 12624, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111625,  } , spawndeny = 0 },
	[12631] = {	id = 12631, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111631,  } , spawndeny = 0 },
	[12632] = {	id = 12632, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111632,  } , spawndeny = 0 },
	[12633] = {	id = 12633, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111633, 111634,  } , spawndeny = 0 },
	[12634] = {	id = 12634, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111635,  } , spawndeny = 0 },
	[12641] = {	id = 12641, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111641,  } , spawndeny = 0 },
	[12642] = {	id = 12642, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111642,  } , spawndeny = 0 },
	[12643] = {	id = 12643, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111643, 111644,  } , spawndeny = 0 },
	[12644] = {	id = 12644, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111645,  } , spawndeny = 0 },
	[12651] = {	id = 12651, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111651,  } , spawndeny = 0 },
	[12652] = {	id = 12652, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111652,  } , spawndeny = 0 },
	[12653] = {	id = 12653, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111653, 111654,  } , spawndeny = 0 },
	[12654] = {	id = 12654, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111655,  } , spawndeny = 0 },
	[12661] = {	id = 12661, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111661,  } , spawndeny = 0 },
	[12662] = {	id = 12662, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111662,  } , spawndeny = 0 },
	[12663] = {	id = 12663, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111663, 111664,  } , spawndeny = 0 },
	[12664] = {	id = 12664, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111665,  } , spawndeny = 0 },
	[12671] = {	id = 12671, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111671,  } , spawndeny = 0 },
	[12672] = {	id = 12672, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111672,  } , spawndeny = 0 },
	[12673] = {	id = 12673, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111673, 111674,  } , spawndeny = 0 },
	[12674] = {	id = 12674, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111675,  } , spawndeny = 0 },
	[12681] = {	id = 12681, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111681,  } , spawndeny = 0 },
	[12682] = {	id = 12682, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111682,  } , spawndeny = 0 },
	[12683] = {	id = 12683, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111683, 111684,  } , spawndeny = 0 },
	[12684] = {	id = 12684, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111685,  } , spawndeny = 0 },
	[12691] = {	id = 12691, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111691,  } , spawndeny = 0 },
	[12692] = {	id = 12692, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111692,  } , spawndeny = 0 },
	[12693] = {	id = 12693, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111693, 111694,  } , spawndeny = 0 },
	[12694] = {	id = 12694, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111695,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
