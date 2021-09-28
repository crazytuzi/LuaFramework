----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[2201] = {	id = 2201, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2101,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 220101, 220102,  } , spawndeny = 0 },
	[2202] = {	id = 2202, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2101,  }, EndClose = {  }, spawnPoints = { 220201, 220202, 220203, 220204,  } , spawndeny = 0 },
	[2203] = {	id = 2203, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2102,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 220301, 220302, 220303, 220304,  } , spawndeny = 0 },
	[2204] = {	id = 2204, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2102,  }, EndClose = {  }, spawnPoints = { 220401, 220402, 220403, 220404, 220405, 220406, 220407,  } , spawndeny = 0 },
	[2205] = {	id = 2205, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 220501, 220502, 220503, 220504, 220505, 220506, 220507,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
