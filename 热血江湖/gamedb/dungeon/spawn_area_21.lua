----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[2101] = {	id = 2101, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2101,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 210101, 210102,  } , spawndeny = 0 },
	[2102] = {	id = 2102, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2101,  }, EndClose = {  }, spawnPoints = { 210201, 210202, 210203, 210204,  } , spawndeny = 0 },
	[2103] = {	id = 2103, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2102,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 210301, 210302, 210303, 210304,  } , spawndeny = 0 },
	[2104] = {	id = 2104, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2102,  }, EndClose = {  }, spawnPoints = { 210401, 210402, 210403, 210404, 210405,  } , spawndeny = 0 },
	[2105] = {	id = 2105, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 210501, 210502, 210503, 210504, 210505,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
