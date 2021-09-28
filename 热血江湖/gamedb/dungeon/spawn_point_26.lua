----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[5201] = {	id = 5201, pos = { x = -11.52283, y = 1.455301, z = -8.290638 }, randomPos = 0, randomRadius = 0, monsters = { 53201,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5202] = {	id = 5202, pos = { x = -9.90184, y = 1.455301, z = -0.8064937 }, randomPos = 0, randomRadius = 0, monsters = { 53202,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5203] = {	id = 5203, pos = { x = -4.785233, y = 1.455301, z = 4.563656 }, randomPos = 0, randomRadius = 0, monsters = { 53203,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5204] = {	id = 5204, pos = { x = 2.526491, y = 1.4553, z = 3.895964 }, randomPos = 0, randomRadius = 0, monsters = { 53204,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5205] = {	id = 5205, pos = { x = -5.17366, y = 1.455301, z = -6.672592 }, randomPos = 0, randomRadius = 0, monsters = { 53205,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5206] = {	id = 5206, pos = { x = -2.055195, y = 1.455301, z = -1.460022 }, randomPos = 0, randomRadius = 0, monsters = { 53206,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5207] = {	id = 5207, pos = { x = 0.0208186, y = 1.411107, z = -6.242029 }, randomPos = 0, randomRadius = 0, monsters = { 53207,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5208] = {	id = 5208, pos = { x = 0.1308975, y = 1.412485, z = -6.339226 }, randomPos = 0, randomRadius = 0, monsters = { 53208,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5301] = {	id = 5301, pos = { x = -11.52283, y = 1.455301, z = -8.290638 }, randomPos = 0, randomRadius = 0, monsters = { 53301,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5302] = {	id = 5302, pos = { x = -9.90184, y = 1.455301, z = -0.8064937 }, randomPos = 0, randomRadius = 0, monsters = { 53302,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5303] = {	id = 5303, pos = { x = -4.785233, y = 1.455301, z = 4.563656 }, randomPos = 0, randomRadius = 0, monsters = { 53303,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5304] = {	id = 5304, pos = { x = 2.526491, y = 1.4553, z = 3.895964 }, randomPos = 0, randomRadius = 0, monsters = { 53304,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5305] = {	id = 5305, pos = { x = -5.17366, y = 1.455301, z = -6.672592 }, randomPos = 0, randomRadius = 0, monsters = { 53305,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5306] = {	id = 5306, pos = { x = -2.055195, y = 1.455301, z = -1.460022 }, randomPos = 0, randomRadius = 0, monsters = { 53306,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5307] = {	id = 5307, pos = { x = 0.0208186, y = 1.411107, z = -6.242029 }, randomPos = 0, randomRadius = 0, monsters = { 53307,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5308] = {	id = 5308, pos = { x = 0.1308975, y = 1.412485, z = -6.339226 }, randomPos = 0, randomRadius = 0, monsters = { 53308,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
