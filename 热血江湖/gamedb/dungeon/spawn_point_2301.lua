----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[460201] = {	id = 460201, pos = { x = 0.0, y = 6.11471, z = -1.5356 }, randomPos = 0, randomRadius = 0, monsters = { 90413,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460202] = {	id = 460202, pos = { x = 3.282675, y = 6.124669, z = -5.056988 }, randomPos = 0, randomRadius = 0, monsters = { 90413,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460203] = {	id = 460203, pos = { x = 9.454088, y = 6.151171, z = -2.174829 }, randomPos = 0, randomRadius = 0, monsters = { 90413,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460204] = {	id = 460204, pos = { x = 11.51842, y = 6.391298, z = 1.007135 }, randomPos = 0, randomRadius = 0, monsters = { 90412,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460205] = {	id = 460205, pos = { x = 13.6438, y = 6.353158, z = 1.806459 }, randomPos = 0, randomRadius = 0, monsters = { 90412,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460206] = {	id = 460206, pos = { x = -0.7923012, y = 6.142254, z = -2.919106 }, randomPos = 0, randomRadius = 0, monsters = { 90412,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460301] = {	id = 460301, pos = { x = -11.02583, y = 6.102587, z = 13.97288 }, randomPos = 0, randomRadius = 0, monsters = { 90413,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460302] = {	id = 460302, pos = { x = -4.935541, y = 6.474499, z = 17.32632 }, randomPos = 0, randomRadius = 0, monsters = { 90413,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460303] = {	id = 460303, pos = { x = 3.962447, y = 6.413995, z = 19.50311 }, randomPos = 0, randomRadius = 0, monsters = { 90413,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460304] = {	id = 460304, pos = { x = 8.70293, y = 6.343145, z = 18.90275 }, randomPos = 0, randomRadius = 0, monsters = { 90414,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460305] = {	id = 460305, pos = { x = 8.012592, y = 6.129414, z = -4.540991 }, randomPos = 0, randomRadius = 0, monsters = { 90414,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460306] = {	id = 460306, pos = { x = 14.21833, y = 6.131482, z = -3.715809 }, randomPos = 0, randomRadius = 0, monsters = { 90414,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
