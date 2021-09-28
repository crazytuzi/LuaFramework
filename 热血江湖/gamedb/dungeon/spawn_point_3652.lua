----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[730401] = {	id = 730401, pos = { x = -15.61593, y = 22.0, z = -9.546333 }, randomPos = 0, randomRadius = 0, monsters = { 94112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730402] = {	id = 730402, pos = { x = -17.85482, y = 22.0, z = -11.31035 }, randomPos = 0, randomRadius = 0, monsters = { 94112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730403] = {	id = 730403, pos = { x = -15.31711, y = 22.0, z = -11.99032 }, randomPos = 0, randomRadius = 0, monsters = { 94111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730404] = {	id = 730404, pos = { x = -12.18399, y = 21.0, z = -23.66063 }, randomPos = 0, randomRadius = 0, monsters = { 94111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730405] = {	id = 730405, pos = { x = -10.30362, y = 21.0, z = -25.78712 }, randomPos = 0, randomRadius = 0, monsters = { 94114,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730406] = {	id = 730406, pos = { x = -8.267367, y = 21.08573, z = -23.59477 }, randomPos = 0, randomRadius = 0, monsters = { 94113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730407] = {	id = 730407, pos = { x = -13.63704, y = 21.0, z = -25.52406 }, randomPos = 0, randomRadius = 0, monsters = { 94113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730501] = {	id = 730501, pos = { x = 40.48812, y = 18.6, z = -43.79456 }, randomPos = 0, randomRadius = 0, monsters = { 94113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730502] = {	id = 730502, pos = { x = 42.96907, y = 18.6, z = -46.22741 }, randomPos = 0, randomRadius = 0, monsters = { 94113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730503] = {	id = 730503, pos = { x = 43.31703, y = 18.6, z = -48.60823 }, randomPos = 0, randomRadius = 0, monsters = { 94112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730504] = {	id = 730504, pos = { x = 42.88914, y = 18.6, z = -51.59927 }, randomPos = 0, randomRadius = 0, monsters = { 94112,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730505] = {	id = 730505, pos = { x = 34.46337, y = 18.0, z = -44.84575 }, randomPos = 0, randomRadius = 0, monsters = { 94111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730506] = {	id = 730506, pos = { x = 33.80901, y = 18.0, z = -53.0925 }, randomPos = 0, randomRadius = 0, monsters = { 94111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730507] = {	id = 730507, pos = { x = 41.14218, y = 18.6, z = -55.07241 }, randomPos = 0, randomRadius = 0, monsters = { 94114,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730508] = {	id = 730508, pos = { x = 39.83378, y = 18.39583, z = -58.98926 }, randomPos = 0, randomRadius = 0, monsters = { 94113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730509] = {	id = 730509, pos = { x = 42.46175, y = 18.6, z = -52.93398 }, randomPos = 0, randomRadius = 0, monsters = { 94113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[730510] = {	id = 730510, pos = { x = 33.21326, y = 18.0, z = -48.59628 }, randomPos = 0, randomRadius = 0, monsters = { 94115,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
