----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[60801] = {	id = 60801, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60801,  } , spawndeny = 0 },
	[60802] = {	id = 60802, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60802,  } , spawndeny = 0 },
	[60803] = {	id = 60803, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60803,  } , spawndeny = 0 },
	[60804] = {	id = 60804, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60804,  } , spawndeny = 0 },
	[60805] = {	id = 60805, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60805,  } , spawndeny = 0 },
	[60809] = {	id = 60809, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60809,  } , spawndeny = 0 },
	[60810] = {	id = 60810, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60810,  } , spawndeny = 0 },
	[60811] = {	id = 60811, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60811,  } , spawndeny = 0 },
	[60812] = {	id = 60812, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60812,  } , spawndeny = 0 },
	[60813] = {	id = 60813, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60813,  } , spawndeny = 0 },
	[60814] = {	id = 60814, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60814,  } , spawndeny = 0 },
	[60815] = {	id = 60815, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60815,  } , spawndeny = 0 },
	[60816] = {	id = 60816, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60816,  } , spawndeny = 0 },
	[60817] = {	id = 60817, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60817,  } , spawndeny = 0 },
	[60818] = {	id = 60818, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60818,  } , spawndeny = 0 },
	[60819] = {	id = 60819, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60819,  } , spawndeny = 0 },
	[60820] = {	id = 60820, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60820,  } , spawndeny = 0 },
	[60821] = {	id = 60821, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60821,  } , spawndeny = 0 },
	[60822] = {	id = 60822, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60822,  } , spawndeny = 0 },
	[60823] = {	id = 60823, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60823,  } , spawndeny = 0 },
	[60824] = {	id = 60824, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60824,  } , spawndeny = 0 },
	[60825] = {	id = 60825, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60825,  } , spawndeny = 0 },
	[60827] = {	id = 60827, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60827,  } , spawndeny = 0 },
	[60828] = {	id = 60828, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60828,  } , spawndeny = 0 },
	[60829] = {	id = 60829, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60829,  } , spawndeny = 0 },
	[60830] = {	id = 60830, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60830,  } , spawndeny = 0 },
	[60831] = {	id = 60831, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60831,  } , spawndeny = 0 },
	[60832] = {	id = 60832, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60832,  } , spawndeny = 0 },
	[60833] = {	id = 60833, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60833,  } , spawndeny = 0 },
	[60834] = {	id = 60834, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60834,  } , spawndeny = 0 },
	[60835] = {	id = 60835, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60835,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
