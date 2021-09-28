----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[316801] = {	id = 316801, pos = { x = 81.27921, y = 27.46231, z = -54.88493 }, randomPos = 1, randomRadius = 1000, monsters = { 317001,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[316802] = {	id = 316802, pos = { x = 157.1033, y = 27.34424, z = -153.3654 }, randomPos = 1, randomRadius = 1000, monsters = { 317002,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[316803] = {	id = 316803, pos = { x = -6.015606, y = 28.5237, z = -123.069 }, randomPos = 1, randomRadius = 1000, monsters = { 317003,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[316804] = {	id = 316804, pos = { x = -76.95351, y = 33.9796, z = -32.31077 }, randomPos = 1, randomRadius = 1000, monsters = { 317004,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[316805] = {	id = 316805, pos = { x = 5.795868, y = 28.24279, z = -172.8591 }, randomPos = 1, randomRadius = 1000, monsters = { 317005,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[316806] = {	id = 316806, pos = { x = 77.01125, y = 27.27525, z = -133.6458 }, randomPos = 1, randomRadius = 1000, monsters = { 317006,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[316807] = {	id = 316807, pos = { x = 26.93927, y = 28.2695, z = -36.25692 }, randomPos = 1, randomRadius = 1000, monsters = { 317007,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[316808] = {	id = 316808, pos = { x = 95.99387, y = 26.98224, z = 87.56731 }, randomPos = 1, randomRadius = 1000, monsters = { 317008,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[316809] = {	id = 316809, pos = { x = 81.27921, y = 27.46231, z = -54.88493 }, randomPos = 1, randomRadius = 1000, monsters = { 317009,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[316810] = {	id = 316810, pos = { x = 157.1033, y = 27.34424, z = -153.3654 }, randomPos = 1, randomRadius = 1000, monsters = { 317010,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[316811] = {	id = 316811, pos = { x = -6.015606, y = 28.5237, z = -123.069 }, randomPos = 1, randomRadius = 1000, monsters = { 317011,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[316812] = {	id = 316812, pos = { x = -76.95351, y = 33.9796, z = -32.31077 }, randomPos = 1, randomRadius = 1000, monsters = { 317012,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[316813] = {	id = 316813, pos = { x = 5.795868, y = 28.24279, z = -172.8591 }, randomPos = 1, randomRadius = 1000, monsters = { 317013,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[316814] = {	id = 316814, pos = { x = 77.01125, y = 27.27525, z = -133.6458 }, randomPos = 1, randomRadius = 1000, monsters = { 317014,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[316815] = {	id = 316815, pos = { x = 26.93927, y = 28.2695, z = -36.25692 }, randomPos = 1, randomRadius = 1000, monsters = { 317015,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[316816] = {	id = 316816, pos = { x = 95.99387, y = 26.98224, z = 87.56731 }, randomPos = 1, randomRadius = 1000, monsters = { 317016,  }, spawnType = 3, spawnDTime = 500, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
