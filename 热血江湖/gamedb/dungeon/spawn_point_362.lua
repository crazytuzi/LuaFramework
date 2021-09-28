----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[72401] = {	id = 72401, pos = { x = -63.61148, y = 3.528582, z = 43.19972 }, randomPos = 1, randomRadius = 500, monsters = { 61313,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72402] = {	id = 72402, pos = { x = -59.72425, y = 3.506287, z = 44.42885 }, randomPos = 1, randomRadius = 500, monsters = { 61314,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72403] = {	id = 72403, pos = { x = -75.08159, y = 3.506287, z = 50.71727 }, randomPos = 1, randomRadius = 500, monsters = { 61315,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72404] = {	id = 72404, pos = { x = -87.61556, y = 5.506287, z = 19.43461 }, randomPos = 1, randomRadius = 500, monsters = { 61313,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72405] = {	id = 72405, pos = { x = -88.4495, y = 5.506287, z = 20.68154 }, randomPos = 1, randomRadius = 500, monsters = { 61314,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72406] = {	id = 72406, pos = { x = -87.95016, y = 5.506287, z = 19.78795 }, randomPos = 1, randomRadius = 500, monsters = { 61315,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72407] = {	id = 72407, pos = { x = -83.8495, y = 5.506287, z = -17.95497 }, randomPos = 1, randomRadius = 500, monsters = { 61313,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72408] = {	id = 72408, pos = { x = -84.1678, y = 5.506287, z = -17.68835 }, randomPos = 1, randomRadius = 500, monsters = { 61314,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72409] = {	id = 72409, pos = { x = -84.15033, y = 5.506287, z = -18.28393 }, randomPos = 1, randomRadius = 500, monsters = { 61315,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72410] = {	id = 72410, pos = { x = -28.66339, y = 3.593954, z = -18.51784 }, randomPos = 1, randomRadius = 500, monsters = { 61313,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72411] = {	id = 72411, pos = { x = -33.24719, y = 3.542739, z = -30.20642 }, randomPos = 1, randomRadius = 500, monsters = { 61314,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72412] = {	id = 72412, pos = { x = -23.87026, y = 3.806353, z = -35.77225 }, randomPos = 1, randomRadius = 500, monsters = { 61315,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72413] = {	id = 72413, pos = { x = -8.406165, y = 3.506287, z = -76.11761 }, randomPos = 1, randomRadius = 500, monsters = { 61313,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72414] = {	id = 72414, pos = { x = -13.55728, y = 3.506287, z = -75.06763 }, randomPos = 1, randomRadius = 500, monsters = { 61314,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72415] = {	id = 72415, pos = { x = -5.529804, y = 3.506287, z = -77.3781 }, randomPos = 1, randomRadius = 500, monsters = { 61315,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72416] = {	id = 72416, pos = { x = -50.53162, y = 3.506287, z = -79.55728 }, randomPos = 1, randomRadius = 500, monsters = { 61313,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72417] = {	id = 72417, pos = { x = -55.75636, y = 3.506287, z = -79.44218 }, randomPos = 1, randomRadius = 500, monsters = { 61314,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72418] = {	id = 72418, pos = { x = -48.47137, y = 3.506287, z = -83.86414 }, randomPos = 1, randomRadius = 500, monsters = { 61315,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72419] = {	id = 72419, pos = { x = -59.90346, y = 1.306274, z = -127.8284 }, randomPos = 1, randomRadius = 500, monsters = { 61313,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72420] = {	id = 72420, pos = { x = -56.94579, y = 1.306274, z = -133.0912 }, randomPos = 1, randomRadius = 500, monsters = { 61314,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72421] = {	id = 72421, pos = { x = -64.31557, y = 1.306274, z = -132.9505 }, randomPos = 1, randomRadius = 500, monsters = { 61315,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72422] = {	id = 72422, pos = { x = -99.4846, y = 3.627938, z = -79.95505 }, randomPos = 1, randomRadius = 500, monsters = { 61313,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72423] = {	id = 72423, pos = { x = -109.1416, y = 3.491834, z = -80.30615 }, randomPos = 1, randomRadius = 500, monsters = { 61314,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72424] = {	id = 72424, pos = { x = -114.837, y = 3.426113, z = -79.94102 }, randomPos = 1, randomRadius = 500, monsters = { 61315,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72425] = {	id = 72425, pos = { x = -27.78175, y = 7.506287, z = 78.67441 }, randomPos = 1, randomRadius = 500, monsters = { 61313,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72426] = {	id = 72426, pos = { x = -37.58595, y = 7.453172, z = 76.07867 }, randomPos = 1, randomRadius = 500, monsters = { 61314,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72427] = {	id = 72427, pos = { x = -15.59799, y = 7.306274, z = 71.05965 }, randomPos = 1, randomRadius = 500, monsters = { 61315,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72428] = {	id = 72428, pos = { x = -85.27414, y = 3.506287, z = 74.04955 }, randomPos = 1, randomRadius = 500, monsters = { 61313,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72429] = {	id = 72429, pos = { x = -96.2115, y = 3.506287, z = 83.88007 }, randomPos = 1, randomRadius = 500, monsters = { 61314,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72430] = {	id = 72430, pos = { x = -99.3332, y = 3.506287, z = 72.65366 }, randomPos = 1, randomRadius = 500, monsters = { 61315,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72501] = {	id = 72501, pos = { x = -63.61148, y = 3.528582, z = 43.19972 }, randomPos = 1, randomRadius = 500, monsters = { 61316,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72502] = {	id = 72502, pos = { x = -59.72425, y = 3.506287, z = 44.42885 }, randomPos = 1, randomRadius = 500, monsters = { 61317,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72503] = {	id = 72503, pos = { x = -75.08159, y = 3.506287, z = 50.71727 }, randomPos = 1, randomRadius = 500, monsters = { 61318,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72504] = {	id = 72504, pos = { x = -87.61556, y = 5.506287, z = 19.43461 }, randomPos = 1, randomRadius = 500, monsters = { 61316,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72505] = {	id = 72505, pos = { x = -88.4495, y = 5.506287, z = 20.68154 }, randomPos = 1, randomRadius = 500, monsters = { 61317,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72506] = {	id = 72506, pos = { x = -87.95016, y = 5.506287, z = 19.78795 }, randomPos = 1, randomRadius = 500, monsters = { 61318,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72507] = {	id = 72507, pos = { x = -83.8495, y = 5.506287, z = -17.95497 }, randomPos = 1, randomRadius = 500, monsters = { 61316,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72508] = {	id = 72508, pos = { x = -84.1678, y = 5.506287, z = -17.68835 }, randomPos = 1, randomRadius = 500, monsters = { 61317,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72509] = {	id = 72509, pos = { x = -84.15033, y = 5.506287, z = -18.28393 }, randomPos = 1, randomRadius = 500, monsters = { 61318,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72510] = {	id = 72510, pos = { x = -28.66339, y = 3.593954, z = -18.51784 }, randomPos = 1, randomRadius = 500, monsters = { 61316,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72511] = {	id = 72511, pos = { x = -33.24719, y = 3.542739, z = -30.20642 }, randomPos = 1, randomRadius = 500, monsters = { 61317,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72512] = {	id = 72512, pos = { x = -23.87026, y = 3.806353, z = -35.77225 }, randomPos = 1, randomRadius = 500, monsters = { 61318,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72513] = {	id = 72513, pos = { x = -8.406165, y = 3.506287, z = -76.11761 }, randomPos = 1, randomRadius = 500, monsters = { 61316,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72514] = {	id = 72514, pos = { x = -13.55728, y = 3.506287, z = -75.06763 }, randomPos = 1, randomRadius = 500, monsters = { 61317,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72515] = {	id = 72515, pos = { x = -5.529804, y = 3.506287, z = -77.3781 }, randomPos = 1, randomRadius = 500, monsters = { 61318,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72516] = {	id = 72516, pos = { x = -50.53162, y = 3.506287, z = -79.55728 }, randomPos = 1, randomRadius = 500, monsters = { 61316,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72517] = {	id = 72517, pos = { x = -55.75636, y = 3.506287, z = -79.44218 }, randomPos = 1, randomRadius = 500, monsters = { 61317,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72518] = {	id = 72518, pos = { x = -48.47137, y = 3.506287, z = -83.86414 }, randomPos = 1, randomRadius = 500, monsters = { 61318,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72519] = {	id = 72519, pos = { x = -59.90346, y = 1.306274, z = -127.8284 }, randomPos = 1, randomRadius = 500, monsters = { 61316,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72520] = {	id = 72520, pos = { x = -56.94579, y = 1.306274, z = -133.0912 }, randomPos = 1, randomRadius = 500, monsters = { 61317,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72521] = {	id = 72521, pos = { x = -64.31557, y = 1.306274, z = -132.9505 }, randomPos = 1, randomRadius = 500, monsters = { 61318,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72522] = {	id = 72522, pos = { x = -99.4846, y = 3.627938, z = -79.95505 }, randomPos = 1, randomRadius = 500, monsters = { 61316,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72523] = {	id = 72523, pos = { x = -109.1416, y = 3.491834, z = -80.30615 }, randomPos = 1, randomRadius = 500, monsters = { 61317,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72524] = {	id = 72524, pos = { x = -114.837, y = 3.426113, z = -79.94102 }, randomPos = 1, randomRadius = 500, monsters = { 61318,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72525] = {	id = 72525, pos = { x = -27.78175, y = 7.506287, z = 78.67441 }, randomPos = 1, randomRadius = 500, monsters = { 61316,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72526] = {	id = 72526, pos = { x = -37.58595, y = 7.453172, z = 76.07867 }, randomPos = 1, randomRadius = 500, monsters = { 61317,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72527] = {	id = 72527, pos = { x = -15.59799, y = 7.306274, z = 71.05965 }, randomPos = 1, randomRadius = 500, monsters = { 61318,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72528] = {	id = 72528, pos = { x = -85.27414, y = 3.506287, z = 74.04955 }, randomPos = 1, randomRadius = 500, monsters = { 61316,  }, spawnType = 3, spawnDTime = 2000, spawnTimes = -1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72529] = {	id = 72529, pos = { x = -96.2115, y = 3.506287, z = 83.88007 }, randomPos = 1, randomRadius = 500, monsters = { 61317,  }, spawnType = 3, spawnDTime = 30000, spawnTimes = -1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[72530] = {	id = 72530, pos = { x = -99.3332, y = 3.506287, z = 72.65366 }, randomPos = 1, randomRadius = 500, monsters = { 61318,  }, spawnType = 3, spawnDTime = 120000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
