----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[720201] = {	id = 720201, pos = { x = 19.31351, y = 25.22902, z = 15.29457 }, randomPos = 0, randomRadius = 0, monsters = { 94101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720202] = {	id = 720202, pos = { x = 10.31339, y = 25.34845, z = 16.47988 }, randomPos = 0, randomRadius = 0, monsters = { 94101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720203] = {	id = 720203, pos = { x = 17.63192, y = 25.28132, z = 10.67685 }, randomPos = 0, randomRadius = 0, monsters = { 94102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720204] = {	id = 720204, pos = { x = 24.12315, y = 25.2, z = 13.61496 }, randomPos = 0, randomRadius = 0, monsters = { 94102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720301] = {	id = 720301, pos = { x = -4.507692, y = 21.10747, z = -14.68692 }, randomPos = 0, randomRadius = 0, monsters = { 94102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720302] = {	id = 720302, pos = { x = -6.161278, y = 21.12792, z = -18.69961 }, randomPos = 0, randomRadius = 0, monsters = { 94102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720303] = {	id = 720303, pos = { x = -4.841904, y = 21.10651, z = -19.0129 }, randomPos = 0, randomRadius = 0, monsters = { 94103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720304] = {	id = 720304, pos = { x = -6.901566, y = 21.09863, z = -21.70196 }, randomPos = 0, randomRadius = 0, monsters = { 94103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
