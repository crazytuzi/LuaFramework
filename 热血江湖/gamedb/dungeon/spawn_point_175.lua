----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[35001] = {	id = 35001, pos = { x = -66.47887, y = 0.2000002, z = -99.37006 }, randomPos = 1, randomRadius = 500, monsters = { 87601,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35002] = {	id = 35002, pos = { x = -38.7005, y = 0.2000001, z = -128.7174 }, randomPos = 1, randomRadius = 500, monsters = { 87601,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35003] = {	id = 35003, pos = { x = -1.896267, y = 0.2000002, z = -114.7555 }, randomPos = 1, randomRadius = 500, monsters = { 87601,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35004] = {	id = 35004, pos = { x = -33.83883, y = 0.2000002, z = -105.397 }, randomPos = 1, randomRadius = 500, monsters = { 87601,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35005] = {	id = 35005, pos = { x = -8.65382, y = 5.0, z = -30.15637 }, randomPos = 1, randomRadius = 500, monsters = { 87601,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35006] = {	id = 35006, pos = { x = -47.33104, y = 5.104568, z = -44.1754 }, randomPos = 1, randomRadius = 500, monsters = { 87601,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35007] = {	id = 35007, pos = { x = -87.17149, y = 7.0, z = 2.615292 }, randomPos = 1, randomRadius = 500, monsters = { 87601,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35008] = {	id = 35008, pos = { x = -54.24651, y = 7.0, z = 33.82076 }, randomPos = 1, randomRadius = 500, monsters = { 87601,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35009] = {	id = 35009, pos = { x = 12.69689, y = 13.94184, z = 38.77549 }, randomPos = 1, randomRadius = 500, monsters = { 87601,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35010] = {	id = 35010, pos = { x = 50.9112, y = 13.08052, z = 20.80769 }, randomPos = 1, randomRadius = 500, monsters = { 87601,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35101] = {	id = 35101, pos = { x = -73.10187, y = 7.0, z = 30.41436 }, randomPos = 1, randomRadius = 500, monsters = { 87602,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35102] = {	id = 35102, pos = { x = 47.90052, y = 13.02554, z = 30.49932 }, randomPos = 1, randomRadius = 500, monsters = { 87602,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35103] = {	id = 35103, pos = { x = -93.92284, y = 7.0, z = 9.554251 }, randomPos = 1, randomRadius = 500, monsters = { 87602,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35104] = {	id = 35104, pos = { x = -35.9593, y = 5.065004, z = -38.68172 }, randomPos = 1, randomRadius = 500, monsters = { 87602,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35105] = {	id = 35105, pos = { x = -110.8945, y = 0.2000002, z = -85.95618 }, randomPos = 1, randomRadius = 500, monsters = { 87602,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35106] = {	id = 35106, pos = { x = -82.33805, y = 0.2000002, z = -123.7884 }, randomPos = 1, randomRadius = 500, monsters = { 87602,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
