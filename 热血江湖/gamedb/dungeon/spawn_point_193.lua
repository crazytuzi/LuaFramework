----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[38601] = {	id = 38601, pos = { x = 145.5694, y = -6.339142, z = -61.84095 }, randomPos = 1, randomRadius = 200, monsters = { 87807,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38602] = {	id = 38602, pos = { x = 114.8211, y = 0.7273935, z = 47.38323 }, randomPos = 1, randomRadius = 200, monsters = { 87807,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38603] = {	id = 38603, pos = { x = 12.38949, y = 9.86087, z = 51.61377 }, randomPos = 1, randomRadius = 200, monsters = { 87807,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38604] = {	id = 38604, pos = { x = -38.68304, y = 15.44394, z = 112.138 }, randomPos = 1, randomRadius = 200, monsters = { 87807,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38701] = {	id = 38701, pos = { x = -43.633, y = -3.802701, z = -75.90416 }, randomPos = 1, randomRadius = 500, monsters = { 87808,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38702] = {	id = 38702, pos = { x = -27.75502, y = 12.91027, z = 49.01798 }, randomPos = 1, randomRadius = 500, monsters = { 87808,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38703] = {	id = 38703, pos = { x = -16.22035, y = 14.26086, z = 99.19948 }, randomPos = 1, randomRadius = 500, monsters = { 87808,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38704] = {	id = 38704, pos = { x = 96.28883, y = 0.6955482, z = 53.09 }, randomPos = 1, randomRadius = 500, monsters = { 87808,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38705] = {	id = 38705, pos = { x = 137.5451, y = -6.339142, z = -92.42428 }, randomPos = 1, randomRadius = 500, monsters = { 87808,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[38706] = {	id = 38706, pos = { x = 43.75009, y = -8.374153, z = -77.35827 }, randomPos = 1, randomRadius = 500, monsters = { 87808,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
