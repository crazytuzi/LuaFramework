----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[63300] = {	id = 63300, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63301, 63302, 63303, 63304,  } , spawndeny = 0 },
	[63310] = {	id = 63310, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63311, 63312,  } , spawndeny = 0 },
	[63320] = {	id = 63320, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63321, 63322, 63323, 63324,  } , spawndeny = 0 },
	[63330] = {	id = 63330, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63331, 63332,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
