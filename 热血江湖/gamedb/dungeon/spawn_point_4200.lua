----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[840011] = {	id = 840011, pos = { x = -1.200034, y = 6.931233, z = -108.0427 }, randomPos = 1, randomRadius = 600, monsters = { 84001,  }, spawnType = 3, spawnDTime = 800, spawnTimes = -1, spawnNum = { { 9, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[840021] = {	id = 840021, pos = { x = 27.53326, y = 3.114183, z = 67.08454 }, randomPos = 1, randomRadius = 600, monsters = { 84002,  }, spawnType = 3, spawnDTime = 800, spawnTimes = -1, spawnNum = { { 9, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[840031] = {	id = 840031, pos = { x = 46.5052, y = 21.42902, z = 111.1903 }, randomPos = 1, randomRadius = 600, monsters = { 84003,  }, spawnType = 3, spawnDTime = 800, spawnTimes = -1, spawnNum = { { 9, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[840041] = {	id = 840041, pos = { x = 147.8737, y = 7.834466, z = 23.07198 }, randomPos = 1, randomRadius = 600, monsters = { 84004,  }, spawnType = 3, spawnDTime = 800, spawnTimes = -1, spawnNum = { { 9, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[840051] = {	id = 840051, pos = { x = -74.10647, y = 13.38342, z = 31.82576 }, randomPos = 1, randomRadius = 600, monsters = { 84005,  }, spawnType = 3, spawnDTime = 800, spawnTimes = -1, spawnNum = { { 9, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
