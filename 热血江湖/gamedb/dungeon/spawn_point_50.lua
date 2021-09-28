----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[10101] = {	id = 10101, pos = { x = -56.81743, y = 2.954441, z = 28.74183 }, randomPos = 1, randomRadius = 600, monsters = { 50001,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10102] = {	id = 10102, pos = { x = -67.26614, y = 2.954441, z = 19.19622 }, randomPos = 1, randomRadius = 600, monsters = { 50002,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10103] = {	id = 10103, pos = { x = -66.97034, y = 2.954441, z = 3.681648 }, randomPos = 1, randomRadius = 600, monsters = { 50003,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10104] = {	id = 10104, pos = { x = -56.7867, y = 2.954441, z = -6.742241 }, randomPos = 1, randomRadius = 600, monsters = { 50004,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10001] = {	id = 10001, pos = { x = -65.47849, y = 2.954441, z = -2.293961 }, randomPos = 1, randomRadius = 600, monsters = { 90131,  }, spawnType = 3, spawnDTime = 800, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10002] = {	id = 10002, pos = { x = -63.30204, y = 2.954441, z = -1.305308 }, randomPos = 1, randomRadius = 600, monsters = { 90131,  }, spawnType = 3, spawnDTime = 800, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10003] = {	id = 10003, pos = { x = -63.32789, y = 2.954441, z = -6.318638 }, randomPos = 1, randomRadius = 600, monsters = { 90131,  }, spawnType = 3, spawnDTime = 800, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10004] = {	id = 10004, pos = { x = -64.41355, y = 2.954441, z = -2.834438 }, randomPos = 1, randomRadius = 600, monsters = { 90131,  }, spawnType = 3, spawnDTime = 800, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10005] = {	id = 10005, pos = { x = -32.48692, y = 0.3857151, z = 8.982121 }, randomPos = 1, randomRadius = 600, monsters = { 90131,  }, spawnType = 3, spawnDTime = 800, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10006] = {	id = 10006, pos = { x = 16.66072, y = 28.64491, z = 109.9478 }, randomPos = 1, randomRadius = 600, monsters = { 90131,  }, spawnType = 3, spawnDTime = 800, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10007] = {	id = 10007, pos = { x = 20.0662, y = 22.54722, z = 48.17675 }, randomPos = 1, randomRadius = 600, monsters = { 90131,  }, spawnType = 3, spawnDTime = 800, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10008] = {	id = 10008, pos = { x = -44.3692, y = 20.81667, z = 26.19365 }, randomPos = 1, randomRadius = 600, monsters = { 90131,  }, spawnType = 3, spawnDTime = 800, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10009] = {	id = 10009, pos = { x = -43.5149, y = 15.01666, z = -12.78523 }, randomPos = 1, randomRadius = 600, monsters = { 90131,  }, spawnType = 3, spawnDTime = 800, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10010] = {	id = 10010, pos = { x = -34.24603, y = 7.473547, z = -58.57315 }, randomPos = 1, randomRadius = 600, monsters = { 90131,  }, spawnType = 3, spawnDTime = 800, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10011] = {	id = 10011, pos = { x = 36.67226, y = 11.83384, z = -39.76249 }, randomPos = 1, randomRadius = 600, monsters = { 90131,  }, spawnType = 3, spawnDTime = 800, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10012] = {	id = 10012, pos = { x = 71.97201, y = 0.8699169, z = -95.6225 }, randomPos = 1, randomRadius = 600, monsters = { 90131,  }, spawnType = 3, spawnDTime = 800, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10013] = {	id = 10013, pos = { x = 111.3588, y = 19.72623, z = -16.82267 }, randomPos = 1, randomRadius = 600, monsters = { 90131,  }, spawnType = 3, spawnDTime = 800, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10014] = {	id = 10014, pos = { x = -29.73784, y = 7.216659, z = -84.45747 }, randomPos = 1, randomRadius = 600, monsters = { 90131,  }, spawnType = 3, spawnDTime = 800, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10015] = {	id = 10015, pos = { x = 92.64417, y = 18.94524, z = -10.92093 }, randomPos = 1, randomRadius = 600, monsters = { 90131,  }, spawnType = 3, spawnDTime = 800, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10016] = {	id = 10016, pos = { x = 5.218613, y = 5.102379, z = -91.56113 }, randomPos = 1, randomRadius = 600, monsters = { 90131,  }, spawnType = 3, spawnDTime = 800, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10017] = {	id = 10017, pos = { x = 104.1411, y = 19.98226, z = -34.86883 }, randomPos = 1, randomRadius = 600, monsters = { 90131,  }, spawnType = 3, spawnDTime = 800, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[10018] = {	id = 10018, pos = { x = 16.63577, y = 10.61666, z = -22.19458 }, randomPos = 1, randomRadius = 600, monsters = { 90131,  }, spawnType = 3, spawnDTime = 800, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
