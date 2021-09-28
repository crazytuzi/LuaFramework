----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[33001] = {	id = 33001, pos = { x = 66.79986, y = 6.165421, z = -95.78157 }, randomPos = 1, randomRadius = 500, monsters = { 87501,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33002] = {	id = 33002, pos = { x = 25.62563, y = 11.16542, z = -97.368 }, randomPos = 1, randomRadius = 500, monsters = { 87501,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33003] = {	id = 33003, pos = { x = -20.15397, y = 13.20028, z = -86.75832 }, randomPos = 1, randomRadius = 500, monsters = { 87501,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33004] = {	id = 33004, pos = { x = -22.98665, y = 13.16542, z = -53.43974 }, randomPos = 1, randomRadius = 500, monsters = { 87501,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33005] = {	id = 33005, pos = { x = -29.67807, y = 15.22212, z = -16.68952 }, randomPos = 1, randomRadius = 500, monsters = { 87501,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33006] = {	id = 33006, pos = { x = -30.76022, y = 22.16542, z = 24.75757 }, randomPos = 1, randomRadius = 500, monsters = { 87501,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33007] = {	id = 33007, pos = { x = -30.18894, y = 29.43149, z = 107.3078 }, randomPos = 1, randomRadius = 500, monsters = { 87501,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33008] = {	id = 33008, pos = { x = 3.998924, y = 32.36542, z = 111.6817 }, randomPos = 1, randomRadius = 500, monsters = { 87501,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33009] = {	id = 33009, pos = { x = 0.5737533, y = 32.36542, z = 128.1476 }, randomPos = 1, randomRadius = 500, monsters = { 87501,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33010] = {	id = 33010, pos = { x = 58.6945, y = 32.36542, z = 112.1905 }, randomPos = 1, randomRadius = 500, monsters = { 87501,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33101] = {	id = 33101, pos = { x = 110.9424, y = 30.16542, z = 110.4442 }, randomPos = 1, randomRadius = 500, monsters = { 87502,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33102] = {	id = 33102, pos = { x = 112.9292, y = 25.16542, z = 42.60841 }, randomPos = 1, randomRadius = 500, monsters = { 87502,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33103] = {	id = 33103, pos = { x = 111.0314, y = 22.32442, z = 4.346741 }, randomPos = 1, randomRadius = 500, monsters = { 87502,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33104] = {	id = 33104, pos = { x = 97.97118, y = 22.41896, z = -43.03109 }, randomPos = 1, randomRadius = 500, monsters = { 87502,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33105] = {	id = 33105, pos = { x = 24.37574, y = 16.16542, z = -33.33265 }, randomPos = 1, randomRadius = 500, monsters = { 87502,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[33106] = {	id = 33106, pos = { x = 23.68215, y = 24.36542, z = 14.11472 }, randomPos = 1, randomRadius = 500, monsters = { 87502,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
