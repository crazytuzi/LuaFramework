----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[520201] = {	id = 520201, pos = { x = -18.23066, y = 9.381627, z = -52.25546 }, randomPos = 0, randomRadius = 0, monsters = { 90623,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520202] = {	id = 520202, pos = { x = -15.29486, y = 9.412899, z = -53.51306 }, randomPos = 0, randomRadius = 0, monsters = { 90623,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520203] = {	id = 520203, pos = { x = -12.69141, y = 9.528347, z = -53.27982 }, randomPos = 0, randomRadius = 0, monsters = { 90623,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520204] = {	id = 520204, pos = { x = -10.27636, y = 9.63544, z = -53.3251 }, randomPos = 0, randomRadius = 0, monsters = { 90623,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520205] = {	id = 520205, pos = { x = -8.257444, y = 9.724968, z = -52.80709 }, randomPos = 0, randomRadius = 0, monsters = { 90624,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520206] = {	id = 520206, pos = { x = -11.39082, y = 9.58602, z = -53.15977 }, randomPos = 0, randomRadius = 0, monsters = { 90624,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520207] = {	id = 520207, pos = { x = -13.52985, y = 9.491167, z = -53.55852 }, randomPos = 0, randomRadius = 0, monsters = { 90624,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520208] = {	id = 520208, pos = { x = -14.38098, y = 9.453424, z = -54.17809 }, randomPos = 0, randomRadius = 0, monsters = { 90624,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520301] = {	id = 520301, pos = { x = -16.91927, y = 9.305968, z = -44.40629 }, randomPos = 0, randomRadius = 0, monsters = { 90625,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520302] = {	id = 520302, pos = { x = -14.54785, y = 9.344854, z = -44.79349 }, randomPos = 0, randomRadius = 0, monsters = { 90626,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520303] = {	id = 520303, pos = { x = -12.57488, y = 9.381625, z = -45.27909 }, randomPos = 0, randomRadius = 0, monsters = { 90623,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520304] = {	id = 520304, pos = { x = -10.41618, y = 9.406878, z = -45.42837 }, randomPos = 0, randomRadius = 0, monsters = { 90623,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520305] = {	id = 520305, pos = { x = -18.21811, y = 9.34956, z = -46.47691 }, randomPos = 0, randomRadius = 0, monsters = { 90623,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520306] = {	id = 520306, pos = { x = -8.240839, y = 9.578436, z = -46.3392 }, randomPos = 0, randomRadius = 0, monsters = { 90623,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520307] = {	id = 520307, pos = { x = -14.69439, y = 9.390816, z = -47.43774 }, randomPos = 0, randomRadius = 0, monsters = { 90624,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520308] = {	id = 520308, pos = { x = -12.00173, y = 9.487664, z = -47.20365 }, randomPos = 0, randomRadius = 0, monsters = { 90624,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520309] = {	id = 520309, pos = { x = -10.41468, y = 9.42919, z = -47.6466 }, randomPos = 0, randomRadius = 0, monsters = { 90624,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[520310] = {	id = 520310, pos = { x = -13.35367, y = 9.298101, z = -41.75402 }, randomPos = 0, randomRadius = 0, monsters = { 90624,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
