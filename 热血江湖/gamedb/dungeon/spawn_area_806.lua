----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[80601] = {	id = 80601, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80601, 80602, 80603, 80604, 80605, 80606, 80607, 80608,  } , spawndeny = 3000 },
	[80621] = {	id = 80621, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80621, 80622, 80623, 80624,  } , spawndeny = 3000 },
	[80641] = {	id = 80641, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80641, 80642, 80643, 80644, 80645, 80646, 80647, 80648,  } , spawndeny = 3000 },
	[80661] = {	id = 80661, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80661, 80662, 80663, 80664, 80665, 80666, 80667, 80668,  } , spawndeny = 3000 },
	[80681] = {	id = 80681, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80681, 80682, 80683, 80684, 80685, 80686, 80687, 80688,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
