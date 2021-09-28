----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[560401] = {	id = 560401, pos = { x = -36.35271, y = 8.196625, z = -23.0067 }, randomPos = 0, randomRadius = 0, monsters = { 90705,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[560402] = {	id = 560402, pos = { x = -32.09862, y = 8.196625, z = -16.55786 }, randomPos = 0, randomRadius = 0, monsters = { 90702,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[560403] = {	id = 560403, pos = { x = -27.90791, y = 8.245381, z = -23.6307 }, randomPos = 0, randomRadius = 0, monsters = { 90702,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[560404] = {	id = 560404, pos = { x = -32.17801, y = 8.196625, z = -22.73757 }, randomPos = 0, randomRadius = 0, monsters = { 90704,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[560405] = {	id = 560405, pos = { x = -32.15501, y = 8.196625, z = -26.35176 }, randomPos = 0, randomRadius = 0, monsters = { 90704,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[560501] = {	id = 560501, pos = { x = 1.605928, y = 12.39662, z = 44.53877 }, randomPos = 0, randomRadius = 0, monsters = { 90706,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[560502] = {	id = 560502, pos = { x = 6.572171, y = 12.39663, z = 44.27097 }, randomPos = 0, randomRadius = 0, monsters = { 90703,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[560503] = {	id = 560503, pos = { x = -3.1889, y = 12.39662, z = 44.06645 }, randomPos = 0, randomRadius = 0, monsters = { 90703,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[560504] = {	id = 560504, pos = { x = 1.36912, y = 12.39663, z = 43.03881 }, randomPos = 0, randomRadius = 0, monsters = { 90704,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[560505] = {	id = 560505, pos = { x = 1.674869, y = 12.46087, z = 51.49051 }, randomPos = 0, randomRadius = 0, monsters = { 90704,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
