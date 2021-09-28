----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[60101] = {	id = 60101, pos = { x = 18.44737, y = 16.20304, z = 1.117579 }, randomPos = 1, randomRadius = 400, monsters = { 81101,  }, spawnType = 3, spawnDTime = 0, spawnTimes = -1, spawnNum = { { 12, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[60102] = {	id = 60102, pos = { x = 105.6655, y = 20.42833, z = 110.9292 }, randomPos = 1, randomRadius = 300, monsters = { 81102,  }, spawnType = 3, spawnDTime = 0, spawnTimes = -1, spawnNum = { { 10, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[60103] = {	id = 60103, pos = { x = 94.44, y = 16.2, z = 9.8 }, randomPos = 1, randomRadius = 300, monsters = { 81103,  }, spawnType = 3, spawnDTime = 0, spawnTimes = -1, spawnNum = { { 10, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[60104] = {	id = 60104, pos = { x = -42.99, y = 23.0, z = 86.4 }, randomPos = 1, randomRadius = 700, monsters = { 81104,  }, spawnType = 3, spawnDTime = 0, spawnTimes = -1, spawnNum = { { 16, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[60105] = {	id = 60105, pos = { x = -41.45, y = 14.8, z = -62.29 }, randomPos = 1, randomRadius = 500, monsters = { 81105,  }, spawnType = 3, spawnDTime = 0, spawnTimes = -1, spawnNum = { { 16, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[60106] = {	id = 60106, pos = { x = -63.51, y = 12.1, z = -79.0 }, randomPos = 1, randomRadius = 500, monsters = { 81106,  }, spawnType = 3, spawnDTime = 0, spawnTimes = -1, spawnNum = { { 10, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[60107] = {	id = 60107, pos = { x = -73.30924, y = 10.15232, z = -105.1852 }, randomPos = 1, randomRadius = 600, monsters = { 81107,  }, spawnType = 3, spawnDTime = 0, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[60108] = {	id = 60108, pos = { x = -99.25, y = 18.0, z = -13.87 }, randomPos = 1, randomRadius = 600, monsters = { 81108,  }, spawnType = 3, spawnDTime = 0, spawnTimes = -1, spawnNum = { { 10, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[60109] = {	id = 60109, pos = { x = -119.08, y = 19.0, z = -2.4 }, randomPos = 1, randomRadius = 500, monsters = { 81109,  }, spawnType = 3, spawnDTime = 0, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[60110] = {	id = 60110, pos = { x = -137.3749, y = 19.02833, z = -1.232876 }, randomPos = 0, randomRadius = 100, monsters = { 81120,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[60111] = {	id = 60111, pos = { x = 29.23, y = 14.0, z = -41.0 }, randomPos = 0, randomRadius = 100, monsters = { 81121,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[60112] = {	id = 60112, pos = { x = 20.0, y = 14.8, z = -46.98 }, randomPos = 0, randomRadius = 100, monsters = { 81122,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[60113] = {	id = 60113, pos = { x = -69.13346, y = 9.721403, z = -141.1954 }, randomPos = 0, randomRadius = 100, monsters = { 81123,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[60114] = {	id = 60114, pos = { x = 14.0, y = 16.0, z = -2.34 }, randomPos = 1, randomRadius = 400, monsters = { 81101,  }, spawnType = 3, spawnDTime = 0, spawnTimes = -1, spawnNum = { { 12, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
