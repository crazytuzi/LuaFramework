----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[300401] = {	id = 300401, pos = { x = -56.44284, y = 5.293882, z = -6.598592 }, randomPos = 0, randomRadius = 0, monsters = { 90231,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[300402] = {	id = 300402, pos = { x = -54.77879, y = 5.213463, z = -1.715906 }, randomPos = 0, randomRadius = 0, monsters = { 90231,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[300403] = {	id = 300403, pos = { x = -55.10776, y = 5.293882, z = -4.50067 }, randomPos = 0, randomRadius = 0, monsters = { 90234,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[300404] = {	id = 300404, pos = { x = -62.06355, y = 5.266116, z = -2.170562 }, randomPos = 0, randomRadius = 0, monsters = { 90234,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[300405] = {	id = 300405, pos = { x = -59.13475, y = 5.293882, z = 1.432631 }, randomPos = 0, randomRadius = 0, monsters = { 90235,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[300501] = {	id = 300501, pos = { x = -32.73973, y = 4.042564, z = 59.57584 }, randomPos = 0, randomRadius = 0, monsters = { 90236,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[300502] = {	id = 300502, pos = { x = -33.11966, y = 4.035832, z = 65.35639 }, randomPos = 0, randomRadius = 0, monsters = { 90236,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[300503] = {	id = 300503, pos = { x = -30.18111, y = 3.99757, z = 64.55595 }, randomPos = 0, randomRadius = 0, monsters = { 90236,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[300504] = {	id = 300504, pos = { x = -29.59335, y = 3.997117, z = 61.4414 }, randomPos = 0, randomRadius = 0, monsters = { 90236,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[300505] = {	id = 300505, pos = { x = -35.49395, y = 4.082347, z = 58.75051 }, randomPos = 0, randomRadius = 0, monsters = { 90237,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[300506] = {	id = 300506, pos = { x = -35.29195, y = 4.067244, z = 64.79329 }, randomPos = 0, randomRadius = 0, monsters = { 90237,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[300507] = {	id = 300507, pos = { x = -27.63236, y = 3.959444, z = 65.68556 }, randomPos = 0, randomRadius = 0, monsters = { 90237,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[300508] = {	id = 300508, pos = { x = -28.7447, y = 3.984859, z = 58.62182 }, randomPos = 0, randomRadius = 0, monsters = { 90237,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
