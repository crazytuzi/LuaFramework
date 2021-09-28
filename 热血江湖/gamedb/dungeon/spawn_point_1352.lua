----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[270401] = {	id = 270401, pos = { x = -54.05585, y = 5.156708, z = -3.410098 }, randomPos = 0, randomRadius = 0, monsters = { 90201,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[270402] = {	id = 270402, pos = { x = -63.7996, y = 5.151559, z = -6.456062 }, randomPos = 0, randomRadius = 0, monsters = { 90201,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[270403] = {	id = 270403, pos = { x = -64.07149, y = 5.219983, z = 1.314138 }, randomPos = 0, randomRadius = 0, monsters = { 90204,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[270404] = {	id = 270404, pos = { x = -56.10951, y = 5.184703, z = -2.756578 }, randomPos = 0, randomRadius = 0, monsters = { 90204,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[270405] = {	id = 270405, pos = { x = -58.35508, y = 5.203387, z = -3.257944 }, randomPos = 0, randomRadius = 0, monsters = { 90205,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[270501] = {	id = 270501, pos = { x = -33.37839, y = 4.293883, z = 57.98705 }, randomPos = 0, randomRadius = 0, monsters = { 90206,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[270502] = {	id = 270502, pos = { x = -33.66359, y = 4.18022, z = 62.66501 }, randomPos = 0, randomRadius = 0, monsters = { 90206,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[270503] = {	id = 270503, pos = { x = -33.25501, y = 4.29074, z = 66.24055 }, randomPos = 0, randomRadius = 0, monsters = { 90206,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[270504] = {	id = 270504, pos = { x = -33.25501, y = 4.29074, z = 66.24055 }, randomPos = 0, randomRadius = 0, monsters = { 90206,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[270505] = {	id = 270505, pos = { x = -34.62984, y = 4.243796, z = 58.60001 }, randomPos = 0, randomRadius = 0, monsters = { 90207,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[270506] = {	id = 270506, pos = { x = -34.27934, y = 4.265041, z = 65.80179 }, randomPos = 0, randomRadius = 0, monsters = { 90207,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[270507] = {	id = 270507, pos = { x = -28.35126, y = 3.714686, z = 65.54005 }, randomPos = 0, randomRadius = 0, monsters = { 90207,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 200.0, z = 0.0 } },
	[270508] = {	id = 270508, pos = { x = -28.19628, y = 3.753635, z = 59.0773 }, randomPos = 0, randomRadius = 0, monsters = { 90207,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 2, faceDir = { x = 0.0, y = 200.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
