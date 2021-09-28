----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[21201] = {	id = 21201, pos = { x = -40.85682, y = 5.123886, z = -41.39412 }, randomPos = 1, randomRadius = 600, monsters = { 89122,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21202] = {	id = 21202, pos = { x = -42.27787, y = 0.2000002, z = -94.03571 }, randomPos = 1, randomRadius = 600, monsters = { 89123,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21203] = {	id = 21203, pos = { x = 3.471752, y = 5.0, z = -62.20977 }, randomPos = 0, randomRadius = 0, monsters = { 89124,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21204] = {	id = 21204, pos = { x = -87.38947, y = 7.0, z = 2.351742 }, randomPos = 0, randomRadius = 0, monsters = { 89125,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21301] = {	id = 21301, pos = { x = 82.07528, y = 3.075851, z = -69.56886 }, randomPos = 1, randomRadius = 600, monsters = { 89131,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21302] = {	id = 21302, pos = { x = 28.95895, y = 3.075851, z = -96.06113 }, randomPos = 1, randomRadius = 400, monsters = { 89132,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21303] = {	id = 21303, pos = { x = -81.81829, y = 6.875852, z = -62.11798 }, randomPos = 0, randomRadius = 0, monsters = { 89133,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21304] = {	id = 21304, pos = { x = -85.61968, y = 15.67917, z = 28.25744 }, randomPos = 1, randomRadius = 600, monsters = { 89134,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21305] = {	id = 21305, pos = { x = 70.08688, y = 9.398273, z = 55.70187 }, randomPos = 1, randomRadius = 400, monsters = { 89135,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[21306] = {	id = 21306, pos = { x = 47.62566, y = 9.447509, z = 97.01409 }, randomPos = 0, randomRadius = 0, monsters = { 89136,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
