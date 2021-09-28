----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[5301] = {	id = 5301, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 530101, 530102, 530103, 530104, 530105, 530106, 530107,  } , spawndeny = 0 },
	[5302] = {	id = 5302, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5001,  }, EndClose = {  }, spawnPoints = { 530108, 530109, 530110, 530111, 530112, 530113, 530114,  } , spawndeny = 0 },
	[5303] = {	id = 5303, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 530201, 530202, 530203, 530204, 530205, 530206, 530207, 530208, 530209, 530210,  } , spawndeny = 0 },
	[5304] = {	id = 5304, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5006,  }, EndClose = {  }, spawnPoints = { 530301, 530302, 530303, 530304, 530305, 530306, 530307, 530308, 530309, 530310, 530311, 530312,  } , spawndeny = 0 },
	[5305] = {	id = 5305, range = 2000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 530401, 530402, 530403, 530404, 530405, 530406, 530407, 530408, 530409, 530410, 530411,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
