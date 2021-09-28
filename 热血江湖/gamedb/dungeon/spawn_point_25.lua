----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[5001] = {	id = 5001, pos = { x = -11.52283, y = 1.455301, z = -8.290638 }, randomPos = 0, randomRadius = 0, monsters = { 53001,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5002] = {	id = 5002, pos = { x = -9.90184, y = 1.455301, z = -0.8064937 }, randomPos = 0, randomRadius = 0, monsters = { 53002,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5003] = {	id = 5003, pos = { x = -4.785233, y = 1.455301, z = 4.563656 }, randomPos = 0, randomRadius = 0, monsters = { 53003,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5004] = {	id = 5004, pos = { x = 2.526491, y = 1.4553, z = 3.895964 }, randomPos = 0, randomRadius = 0, monsters = { 53004,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5005] = {	id = 5005, pos = { x = -5.17366, y = 1.455301, z = -6.672592 }, randomPos = 0, randomRadius = 0, monsters = { 53005,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5006] = {	id = 5006, pos = { x = -2.055195, y = 1.455301, z = -1.460022 }, randomPos = 0, randomRadius = 0, monsters = { 53006,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5007] = {	id = 5007, pos = { x = 0.0208186, y = 1.411107, z = -6.242029 }, randomPos = 0, randomRadius = 0, monsters = { 53007,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5008] = {	id = 5008, pos = { x = 0.1308975, y = 1.412485, z = -6.339226 }, randomPos = 0, randomRadius = 0, monsters = { 53008,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5101] = {	id = 5101, pos = { x = -11.52283, y = 1.455301, z = -8.290638 }, randomPos = 0, randomRadius = 0, monsters = { 53101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5102] = {	id = 5102, pos = { x = -9.90184, y = 1.455301, z = -0.8064937 }, randomPos = 0, randomRadius = 0, monsters = { 53102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5103] = {	id = 5103, pos = { x = -4.785233, y = 1.455301, z = 4.563656 }, randomPos = 0, randomRadius = 0, monsters = { 53103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5104] = {	id = 5104, pos = { x = 2.526491, y = 1.4553, z = 3.895964 }, randomPos = 0, randomRadius = 0, monsters = { 53104,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5105] = {	id = 5105, pos = { x = -5.17366, y = 1.455301, z = -6.672592 }, randomPos = 0, randomRadius = 0, monsters = { 53105,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5106] = {	id = 5106, pos = { x = -2.055195, y = 1.455301, z = -1.460022 }, randomPos = 0, randomRadius = 0, monsters = { 53106,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5107] = {	id = 5107, pos = { x = 0.0208186, y = 1.411107, z = -6.242029 }, randomPos = 0, randomRadius = 0, monsters = { 53107,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[5108] = {	id = 5108, pos = { x = 0.1308975, y = 1.412485, z = -6.339226 }, randomPos = 0, randomRadius = 0, monsters = { 53108,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
