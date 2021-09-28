----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[29401] = {	id = 29401, pos = { x = -69.88878, y = 8.187279, z = 68.64677 }, randomPos = 1, randomRadius = 500, monsters = { 87405,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29402] = {	id = 29402, pos = { x = -56.71631, y = 8.187279, z = 42.58109 }, randomPos = 1, randomRadius = 500, monsters = { 87405,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29403] = {	id = 29403, pos = { x = -64.82858, y = 8.187279, z = -15.41597 }, randomPos = 1, randomRadius = 500, monsters = { 87405,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29404] = {	id = 29404, pos = { x = -104.3968, y = 8.187279, z = -25.66302 }, randomPos = 1, randomRadius = 500, monsters = { 87405,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29405] = {	id = 29405, pos = { x = -48.0836, y = 5.58728, z = -48.60664 }, randomPos = 1, randomRadius = 500, monsters = { 87405,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29406] = {	id = 29406, pos = { x = -59.35216, y = 4.187279, z = -68.54082 }, randomPos = 1, randomRadius = 500, monsters = { 87405,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29407] = {	id = 29407, pos = { x = -17.20559, y = 4.187279, z = -48.18757 }, randomPos = 1, randomRadius = 500, monsters = { 87405,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29408] = {	id = 29408, pos = { x = 3.388649, y = 1.187279, z = -73.73038 }, randomPos = 1, randomRadius = 500, monsters = { 87405,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29409] = {	id = 29409, pos = { x = 29.55106, y = 1.187279, z = -83.94027 }, randomPos = 1, randomRadius = 500, monsters = { 87405,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29410] = {	id = 29410, pos = { x = -14.46663, y = 6.187279, z = -14.97204 }, randomPos = 1, randomRadius = 500, monsters = { 87405,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29501] = {	id = 29501, pos = { x = 15.36827, y = 6.187279, z = 5.374588 }, randomPos = 1, randomRadius = 500, monsters = { 87406,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29502] = {	id = 29502, pos = { x = 23.23954, y = 9.187286, z = 46.3374 }, randomPos = 1, randomRadius = 500, monsters = { 87406,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29503] = {	id = 29503, pos = { x = -20.92041, y = 9.187286, z = 44.6552 }, randomPos = 1, randomRadius = 500, monsters = { 87406,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29504] = {	id = 29504, pos = { x = -23.20883, y = 9.187286, z = 83.27127 }, randomPos = 1, randomRadius = 500, monsters = { 87406,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29505] = {	id = 29505, pos = { x = -24.27016, y = 9.187286, z = 120.5207 }, randomPos = 1, randomRadius = 500, monsters = { 87406,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[29506] = {	id = 29506, pos = { x = -23.50426, y = 9.187286, z = 83.95177 }, randomPos = 1, randomRadius = 500, monsters = { 87406,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
