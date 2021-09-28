----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[230401] = {	id = 230401, pos = { x = 61.22942, y = 2.2057, z = 56.20582 }, randomPos = 0, randomRadius = 0, monsters = { 90124,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230402] = {	id = 230402, pos = { x = 62.63606, y = 2.2057, z = 54.85609 }, randomPos = 0, randomRadius = 0, monsters = { 90123,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230403] = {	id = 230403, pos = { x = 63.00908, y = 2.2057, z = 54.01681 }, randomPos = 0, randomRadius = 0, monsters = { 90123,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230404] = {	id = 230404, pos = { x = 64.38331, y = 2.2057, z = 53.99612 }, randomPos = 0, randomRadius = 0, monsters = { 90123,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230405] = {	id = 230405, pos = { x = 65.33891, y = 2.2057, z = 53.98641 }, randomPos = 0, randomRadius = 0, monsters = { 90123,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230406] = {	id = 230406, pos = { x = 64.55191, y = 2.2057, z = 52.02425 }, randomPos = 0, randomRadius = 0, monsters = { 90120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230407] = {	id = 230407, pos = { x = 67.38499, y = 2.2057, z = 52.17138 }, randomPos = 0, randomRadius = 0, monsters = { 90120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230408] = {	id = 230408, pos = { x = 69.51419, y = 2.2057, z = 52.079 }, randomPos = 0, randomRadius = 0, monsters = { 90120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230409] = {	id = 230409, pos = { x = 67.32111, y = 2.2057, z = 50.77981 }, randomPos = 0, randomRadius = 0, monsters = { 90120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230501] = {	id = 230501, pos = { x = 60.19578, y = 2.405701, z = 93.94703 }, randomPos = 0, randomRadius = 0, monsters = { 90125,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230502] = {	id = 230502, pos = { x = 62.57855, y = 2.405701, z = 96.16991 }, randomPos = 0, randomRadius = 0, monsters = { 90120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230503] = {	id = 230503, pos = { x = 64.17163, y = 2.413354, z = 98.45377 }, randomPos = 0, randomRadius = 0, monsters = { 90120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230504] = {	id = 230504, pos = { x = 65.16959, y = 2.457856, z = 99.55841 }, randomPos = 0, randomRadius = 0, monsters = { 90120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230505] = {	id = 230505, pos = { x = 65.48439, y = 2.458339, z = 102.9816 }, randomPos = 0, randomRadius = 0, monsters = { 90120,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230506] = {	id = 230506, pos = { x = 67.82163, y = 2.553959, z = 100.7771 }, randomPos = 0, randomRadius = 0, monsters = { 90121,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230507] = {	id = 230507, pos = { x = 66.98824, y = 2.490468, z = 97.26765 }, randomPos = 0, randomRadius = 0, monsters = { 90121,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230508] = {	id = 230508, pos = { x = 63.95196, y = 2.405701, z = 95.74585 }, randomPos = 0, randomRadius = 0, monsters = { 90121,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[230509] = {	id = 230509, pos = { x = 64.46697, y = 2.405701, z = 94.30563 }, randomPos = 0, randomRadius = 0, monsters = { 90121,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
