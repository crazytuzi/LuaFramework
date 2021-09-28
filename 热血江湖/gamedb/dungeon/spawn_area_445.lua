----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[44501] = {	id = 44501, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44501, 44502, 44503, 44504, 44505, 44506,  } , spawndeny = 0 },
	[44511] = {	id = 44511, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44511, 44512, 44513, 44514,  } , spawndeny = 0 },
	[44521] = {	id = 44521, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44521, 44522, 44523, 44524,  } , spawndeny = 0 },
	[44531] = {	id = 44531, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44531,  } , spawndeny = 0 },
	[44532] = {	id = 44532, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44532,  } , spawndeny = 0 },
	[44533] = {	id = 44533, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44533,  } , spawndeny = 0 },
	[44534] = {	id = 44534, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44534,  } , spawndeny = 0 },
	[44541] = {	id = 44541, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44541, 44542, 44543, 44544,  } , spawndeny = 0 },
	[44551] = {	id = 44551, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44551, 44552, 44553, 44554, 44555, 44556,  } , spawndeny = 0 },
	[44561] = {	id = 44561, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44561, 44562, 44563, 44564,  } , spawndeny = 0 },
	[44571] = {	id = 44571, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44571, 44572, 44573, 44574,  } , spawndeny = 0 },
	[44581] = {	id = 44581, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44581,  } , spawndeny = 0 },
	[44582] = {	id = 44582, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44582,  } , spawndeny = 0 },
	[44583] = {	id = 44583, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44583,  } , spawndeny = 0 },
	[44584] = {	id = 44584, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44584,  } , spawndeny = 0 },
	[44591] = {	id = 44591, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44591, 44592, 44593, 44594,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
