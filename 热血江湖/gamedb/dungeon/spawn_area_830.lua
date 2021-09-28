----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[83001] = {	id = 83001, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 83001, 83002, 83003, 83004, 83005, 83006,  } , spawndeny = 5000 },
	[83002] = {	id = 83002, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 83007, 83008, 83009, 83010, 83011, 83012,  } , spawndeny = 3000 },
	[83003] = {	id = 83003, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 83013, 83014,  } , spawndeny = 3000 },
	[83004] = {	id = 83004, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 83015, 83016, 83017, 83018, 83019, 83020,  } , spawndeny = 3000 },
	[83005] = {	id = 83005, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 83021, 83022, 83023, 83024, 83025, 83026,  } , spawndeny = 3000 },
	[83006] = {	id = 83006, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 83027, 83028, 83029, 83030, 83031, 83032,  } , spawndeny = 3000 },
	[83007] = {	id = 83007, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 83033, 83034,  } , spawndeny = 3000 },
	[83008] = {	id = 83008, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 83035, 83036, 83037, 83038, 83039, 83040,  } , spawndeny = 3000 },
	[83009] = {	id = 83009, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 83041, 83042, 83043, 83044, 83045, 83046,  } , spawndeny = 3000 },
	[83010] = {	id = 83010, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 83047, 83048, 83049, 83050, 83051, 83052,  } , spawndeny = 3000 },
	[83011] = {	id = 83011, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 83053, 83054, 83055, 83056,  } , spawndeny = 3000 },
	[83012] = {	id = 83012, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 83057, 83058, 83059, 83060, 83061, 83062,  } , spawndeny = 3000 },
	[83013] = {	id = 83013, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 83063, 83064, 83065, 83066, 83067, 83068,  } , spawndeny = 3000 },
	[83014] = {	id = 83014, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 83069, 83070, 83071, 83072, 83073, 83074,  } , spawndeny = 3000 },
	[83015] = {	id = 83015, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 83075, 83076, 83077, 83078, 83079, 83080,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
