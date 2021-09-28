----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[402001] = {	id = 402001, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351050, 351051, 351052, 351053,  } , spawndeny = 0 },
	[402002] = {	id = 402002, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351054, 351055, 351056, 351057,  } , spawndeny = 0 },
	[402003] = {	id = 402003, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351058, 351059, 351060, 351061,  } , spawndeny = 0 },
	[402004] = {	id = 402004, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351062, 351063, 351064, 351065,  } , spawndeny = 0 },
	[402005] = {	id = 402005, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351066, 351067, 351068, 351069,  } , spawndeny = 0 },
	[402006] = {	id = 402006, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351070, 351071, 351072, 351073,  } , spawndeny = 0 },
	[402007] = {	id = 402007, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351074, 351075, 351076, 351077,  } , spawndeny = 0 },
	[402008] = {	id = 402008, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351078, 351079, 351080, 351081,  } , spawndeny = 0 },
	[402009] = {	id = 402009, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351082, 351083, 351084, 351085,  } , spawndeny = 0 },
	[402010] = {	id = 402010, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351086, 351087, 351088, 351089,  } , spawndeny = 0 },
	[402011] = {	id = 402011, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351140, 351141, 351142, 351143,  } , spawndeny = 0 },
	[402012] = {	id = 402012, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351144, 351145, 351146, 351147,  } , spawndeny = 0 },
	[402013] = {	id = 402013, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351148, 351149, 351150, 351151,  } , spawndeny = 0 },
	[402014] = {	id = 402014, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351152, 351153, 351154, 351155,  } , spawndeny = 0 },
	[402015] = {	id = 402015, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351156, 351157, 351158, 351159,  } , spawndeny = 0 },
	[402016] = {	id = 402016, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351160, 351161, 351162, 351163,  } , spawndeny = 0 },
	[402017] = {	id = 402017, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351164, 351165, 351166, 351167,  } , spawndeny = 0 },
	[402018] = {	id = 402018, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351168, 351169, 351170, 351171,  } , spawndeny = 0 },
	[402019] = {	id = 402019, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351172, 351173, 351174, 351175,  } , spawndeny = 0 },
	[402020] = {	id = 402020, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351176, 351177, 351178, 351179,  } , spawndeny = 0 },
	[402021] = {	id = 402021, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 120605, 120606, 120607, 120608, 120609, 120610, 120611, 120612, 120613, 120614, 120615, 120616, 120617, 120618, 120619, 120620, 120621, 120622,  } , spawndeny = 1000 },
	[402022] = {	id = 402022, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 120623, 120624, 120625, 120626, 120627, 120628,  } , spawndeny = 1000 },

};
function get_db_table()
	return spawn_area;
end
