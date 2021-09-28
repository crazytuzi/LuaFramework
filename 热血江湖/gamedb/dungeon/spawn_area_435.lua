----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[43501] = {	id = 43501, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43501, 43502,  } , spawndeny = 0 },
	[43511] = {	id = 43511, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43511, 43512, 43513, 43514,  } , spawndeny = 0 },
	[43521] = {	id = 43521, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43521, 43522, 43523, 43524,  } , spawndeny = 0 },
	[43531] = {	id = 43531, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43531,  } , spawndeny = 0 },
	[43532] = {	id = 43532, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43532,  } , spawndeny = 0 },
	[43533] = {	id = 43533, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43533,  } , spawndeny = 0 },
	[43534] = {	id = 43534, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43534,  } , spawndeny = 0 },
	[43541] = {	id = 43541, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43541, 43542, 43543, 43544,  } , spawndeny = 0 },
	[43551] = {	id = 43551, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43551, 43552,  } , spawndeny = 0 },
	[43561] = {	id = 43561, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43561, 43562, 43563, 43564,  } , spawndeny = 0 },
	[43571] = {	id = 43571, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43571, 43572, 43573, 43574,  } , spawndeny = 0 },
	[43581] = {	id = 43581, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43581,  } , spawndeny = 0 },
	[43582] = {	id = 43582, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43582,  } , spawndeny = 0 },
	[43583] = {	id = 43583, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43583,  } , spawndeny = 0 },
	[43584] = {	id = 43584, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43584,  } , spawndeny = 0 },
	[43591] = {	id = 43591, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43591, 43592, 43593, 43594,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
