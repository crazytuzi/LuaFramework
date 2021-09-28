----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[41501] = {	id = 41501, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41501,  } , spawndeny = 0 },
	[41511] = {	id = 41511, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41511, 41512, 41513, 41514,  } , spawndeny = 0 },
	[41521] = {	id = 41521, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41521, 41522, 41523, 41524,  } , spawndeny = 0 },
	[41531] = {	id = 41531, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41531,  } , spawndeny = 0 },
	[41532] = {	id = 41532, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41532,  } , spawndeny = 0 },
	[41533] = {	id = 41533, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41533,  } , spawndeny = 0 },
	[41534] = {	id = 41534, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41534,  } , spawndeny = 0 },
	[41541] = {	id = 41541, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41541, 41542, 41543, 41544,  } , spawndeny = 0 },
	[41551] = {	id = 41551, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41551,  } , spawndeny = 0 },
	[41561] = {	id = 41561, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41561, 41562, 41563, 41564,  } , spawndeny = 0 },
	[41571] = {	id = 41571, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41571, 41572, 41573, 41574,  } , spawndeny = 0 },
	[41581] = {	id = 41581, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41581,  } , spawndeny = 0 },
	[41582] = {	id = 41582, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41582,  } , spawndeny = 0 },
	[41583] = {	id = 41583, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41583,  } , spawndeny = 0 },
	[41584] = {	id = 41584, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41584,  } , spawndeny = 0 },
	[41591] = {	id = 41591, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41591, 41592, 41593, 41594,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
