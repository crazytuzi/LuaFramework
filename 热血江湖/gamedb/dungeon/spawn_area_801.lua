----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[80101] = {	id = 80101, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80101, 80102, 80103, 80104, 80105, 80106,  } , spawndeny = 3000 },
	[80121] = {	id = 80121, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80121, 80122, 80123, 80124, 80125, 80126, 80127, 80128,  } , spawndeny = 3000 },
	[80141] = {	id = 80141, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80141, 80142,  } , spawndeny = 3000 },
	[80161] = {	id = 80161, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80161, 80162, 80163, 80164, 80165, 80166,  } , spawndeny = 3000 },
	[80181] = {	id = 80181, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80181, 80182, 80183, 80184, 80185, 80186,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
