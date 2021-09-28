----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[60601] = {	id = 60601, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60601,  } , spawndeny = 0 },
	[60602] = {	id = 60602, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60602,  } , spawndeny = 0 },
	[60603] = {	id = 60603, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60603,  } , spawndeny = 0 },
	[60604] = {	id = 60604, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60604,  } , spawndeny = 0 },
	[60605] = {	id = 60605, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60605,  } , spawndeny = 0 },
	[60606] = {	id = 60606, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60606,  } , spawndeny = 0 },
	[60607] = {	id = 60607, range = 100.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60607,  } , spawndeny = 0 },
	[60608] = {	id = 60608, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60608,  } , spawndeny = 0 },
	[60609] = {	id = 60609, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60609,  } , spawndeny = 0 },
	[60610] = {	id = 60610, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60610,  } , spawndeny = 0 },
	[60611] = {	id = 60611, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60611,  } , spawndeny = 0 },
	[60612] = {	id = 60612, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60612,  } , spawndeny = 0 },
	[60613] = {	id = 60613, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60613,  } , spawndeny = 0 },
	[60614] = {	id = 60614, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60614,  } , spawndeny = 0 },
	[60615] = {	id = 60615, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60615,  } , spawndeny = 0 },
	[60616] = {	id = 60616, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60616,  } , spawndeny = 0 },
	[60617] = {	id = 60617, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60617,  } , spawndeny = 0 },
	[60620] = {	id = 60620, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60620,  } , spawndeny = 0 },
	[60621] = {	id = 60621, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60621,  } , spawndeny = 0 },
	[60622] = {	id = 60622, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60622,  } , spawndeny = 0 },
	[60623] = {	id = 60623, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60623,  } , spawndeny = 0 },
	[60624] = {	id = 60624, range = 0.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60624,  } , spawndeny = 0 },
	[60625] = {	id = 60625, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60625,  } , spawndeny = 0 },
	[60626] = {	id = 60626, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60626,  } , spawndeny = 0 },
	[60627] = {	id = 60627, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60627,  } , spawndeny = 0 },
	[60628] = {	id = 60628, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60628,  } , spawndeny = 0 },
	[60629] = {	id = 60629, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60629,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
