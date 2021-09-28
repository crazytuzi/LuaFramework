----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[510101] = {	id = 510101, pos = { x = -37.49363, y = 11.38163, z = -63.20829 }, randomPos = 0, randomRadius = 0, monsters = { 90611,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510102] = {	id = 510102, pos = { x = -40.40053, y = 11.49542, z = -69.29311 }, randomPos = 0, randomRadius = 0, monsters = { 90611,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510103] = {	id = 510103, pos = { x = -40.86953, y = 11.52282, z = -72.46466 }, randomPos = 0, randomRadius = 0, monsters = { 90612,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510104] = {	id = 510104, pos = { x = -40.80383, y = 11.39569, z = -75.00104 }, randomPos = 0, randomRadius = 0, monsters = { 90612,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510105] = {	id = 510105, pos = { x = -40.34335, y = 11.38163, z = -64.82439 }, randomPos = 0, randomRadius = 0, monsters = { 90613,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510106] = {	id = 510106, pos = { x = 9.383125, y = 11.38163, z = -76.22294 }, randomPos = 0, randomRadius = 0, monsters = { 90613,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510107] = {	id = 510107, pos = { x = 12.02318, y = 11.38163, z = -78.1256 }, randomPos = 0, randomRadius = 0, monsters = { 90613,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510108] = {	id = 510108, pos = { x = 13.32145, y = 11.35116, z = -81.74148 }, randomPos = 0, randomRadius = 0, monsters = { 90613,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510109] = {	id = 510109, pos = { x = 12.08033, y = 11.38162, z = -84.44059 }, randomPos = 0, randomRadius = 0, monsters = { 90613,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510110] = {	id = 510110, pos = { x = 9.990124, y = 11.37707, z = -86.31836 }, randomPos = 0, randomRadius = 0, monsters = { 90613,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
