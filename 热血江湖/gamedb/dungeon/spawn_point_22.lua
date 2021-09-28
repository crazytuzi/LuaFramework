----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[4401] = {	id = 4401, pos = { x = 9.389688, y = -11.56405, z = 0.0 }, randomPos = 0, randomRadius = 0, monsters = { 60442,  }, spawnType = 1, spawnDTime = 2900, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4402] = {	id = 4402, pos = { x = -13.91436, y = -11.23211, z = 0.8217726 }, randomPos = 0, randomRadius = 0, monsters = { 60441,  }, spawnType = 1, spawnDTime = 3000, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4403] = {	id = 4403, pos = { x = -2.036355, y = -11.29216, z = -8.995171 }, randomPos = 0, randomRadius = 0, monsters = { 60442,  }, spawnType = 1, spawnDTime = 3100, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4404] = {	id = 4404, pos = { x = 1.697958, y = -11.17975, z = 13.13625 }, randomPos = 0, randomRadius = 0, monsters = { 60441,  }, spawnType = 1, spawnDTime = 3200, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4405] = {	id = 4405, pos = { x = -10.07816, y = -11.15492, z = -6.473653 }, randomPos = 0, randomRadius = 0, monsters = { 60442,  }, spawnType = 1, spawnDTime = 3300, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4406] = {	id = 4406, pos = { x = -12.46036, y = -11.25341, z = 10.37171 }, randomPos = 0, randomRadius = 0, monsters = { 60441,  }, spawnType = 1, spawnDTime = 2900, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4407] = {	id = 4407, pos = { x = 5.950206, y = -11.42301, z = -7.579656 }, randomPos = 0, randomRadius = 0, monsters = { 60442,  }, spawnType = 1, spawnDTime = 3000, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4408] = {	id = 4408, pos = { x = -5.546535, y = -11.38868, z = 5.732229 }, randomPos = 0, randomRadius = 0, monsters = { 60441,  }, spawnType = 1, spawnDTime = 3100, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4409] = {	id = 4409, pos = { x = 0.0, y = -11.63287, z = -1.293612 }, randomPos = 0, randomRadius = 0, monsters = { 60443,  }, spawnType = 1, spawnDTime = 12000, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4411] = {	id = 4411, pos = { x = 9.389688, y = -11.56405, z = 0.0 }, randomPos = 0, randomRadius = 0, monsters = { 60442,  }, spawnType = 1, spawnDTime = 2900, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4412] = {	id = 4412, pos = { x = -13.91436, y = -11.23211, z = 0.8217726 }, randomPos = 0, randomRadius = 0, monsters = { 60441,  }, spawnType = 1, spawnDTime = 3000, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4413] = {	id = 4413, pos = { x = -2.036355, y = -11.29216, z = -8.995171 }, randomPos = 0, randomRadius = 0, monsters = { 60442,  }, spawnType = 1, spawnDTime = 3100, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4414] = {	id = 4414, pos = { x = 1.697958, y = -11.17975, z = 13.13625 }, randomPos = 0, randomRadius = 0, monsters = { 60441,  }, spawnType = 1, spawnDTime = 3200, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4415] = {	id = 4415, pos = { x = -10.07816, y = -11.15492, z = -6.473653 }, randomPos = 0, randomRadius = 0, monsters = { 60442,  }, spawnType = 1, spawnDTime = 3300, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4416] = {	id = 4416, pos = { x = -12.46036, y = -11.25341, z = 10.37171 }, randomPos = 0, randomRadius = 0, monsters = { 60441,  }, spawnType = 1, spawnDTime = 2900, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4417] = {	id = 4417, pos = { x = 5.950206, y = -11.42301, z = -7.579656 }, randomPos = 0, randomRadius = 0, monsters = { 60442,  }, spawnType = 1, spawnDTime = 3000, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4418] = {	id = 4418, pos = { x = -5.546535, y = -11.38868, z = 5.732229 }, randomPos = 0, randomRadius = 0, monsters = { 60441,  }, spawnType = 1, spawnDTime = 3100, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4419] = {	id = 4419, pos = { x = 0.0, y = -11.63287, z = -1.293612 }, randomPos = 0, randomRadius = 0, monsters = { 60443,  }, spawnType = 1, spawnDTime = 12000, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4421] = {	id = 4421, pos = { x = 9.389688, y = -11.56405, z = 0.0 }, randomPos = 0, randomRadius = 0, monsters = { 60442,  }, spawnType = 1, spawnDTime = 2900, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4422] = {	id = 4422, pos = { x = -13.91436, y = -11.23211, z = 0.8217726 }, randomPos = 0, randomRadius = 0, monsters = { 60441,  }, spawnType = 1, spawnDTime = 3000, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4423] = {	id = 4423, pos = { x = -2.036355, y = -11.29216, z = -8.995171 }, randomPos = 0, randomRadius = 0, monsters = { 60442,  }, spawnType = 1, spawnDTime = 3100, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4424] = {	id = 4424, pos = { x = 1.697958, y = -11.17975, z = 13.13625 }, randomPos = 0, randomRadius = 0, monsters = { 60441,  }, spawnType = 1, spawnDTime = 3200, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4425] = {	id = 4425, pos = { x = -10.07816, y = -11.15492, z = -6.473653 }, randomPos = 0, randomRadius = 0, monsters = { 60442,  }, spawnType = 1, spawnDTime = 3300, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4426] = {	id = 4426, pos = { x = -12.46036, y = -11.25341, z = 10.37171 }, randomPos = 0, randomRadius = 0, monsters = { 60441,  }, spawnType = 1, spawnDTime = 2900, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4427] = {	id = 4427, pos = { x = 5.950206, y = -11.42301, z = -7.579656 }, randomPos = 0, randomRadius = 0, monsters = { 60442,  }, spawnType = 1, spawnDTime = 3000, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4428] = {	id = 4428, pos = { x = -5.546535, y = -11.38868, z = 5.732229 }, randomPos = 0, randomRadius = 0, monsters = { 60441,  }, spawnType = 1, spawnDTime = 3100, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4429] = {	id = 4429, pos = { x = 0.0, y = -11.63287, z = -1.293612 }, randomPos = 0, randomRadius = 0, monsters = { 60443,  }, spawnType = 1, spawnDTime = 12000, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4431] = {	id = 4431, pos = { x = 9.389688, y = -11.56405, z = 0.0 }, randomPos = 0, randomRadius = 0, monsters = { 60442,  }, spawnType = 1, spawnDTime = 2900, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4432] = {	id = 4432, pos = { x = -13.91436, y = -11.23211, z = 0.8217726 }, randomPos = 0, randomRadius = 0, monsters = { 60441,  }, spawnType = 1, spawnDTime = 3000, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4433] = {	id = 4433, pos = { x = -2.036355, y = -11.29216, z = -8.995171 }, randomPos = 0, randomRadius = 0, monsters = { 60442,  }, spawnType = 1, spawnDTime = 3100, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4434] = {	id = 4434, pos = { x = 1.697958, y = -11.17975, z = 13.13625 }, randomPos = 0, randomRadius = 0, monsters = { 60441,  }, spawnType = 1, spawnDTime = 3200, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4435] = {	id = 4435, pos = { x = -10.07816, y = -11.15492, z = -6.473653 }, randomPos = 0, randomRadius = 0, monsters = { 60442,  }, spawnType = 1, spawnDTime = 3300, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4436] = {	id = 4436, pos = { x = -12.46036, y = -11.25341, z = 10.37171 }, randomPos = 0, randomRadius = 0, monsters = { 60441,  }, spawnType = 1, spawnDTime = 2900, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4437] = {	id = 4437, pos = { x = 5.950206, y = -11.42301, z = -7.579656 }, randomPos = 0, randomRadius = 0, monsters = { 60442,  }, spawnType = 1, spawnDTime = 3000, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4438] = {	id = 4438, pos = { x = -5.546535, y = -11.38868, z = 5.732229 }, randomPos = 0, randomRadius = 0, monsters = { 60441,  }, spawnType = 1, spawnDTime = 3100, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4439] = {	id = 4439, pos = { x = 0.0, y = -11.63287, z = -1.293612 }, randomPos = 0, randomRadius = 0, monsters = { 60443,  }, spawnType = 1, spawnDTime = 12000, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4501] = {	id = 4501, pos = { x = 9.389688, y = -11.56405, z = 0.0 }, randomPos = 0, randomRadius = 0, monsters = { 60452,  }, spawnType = 1, spawnDTime = 2900, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4502] = {	id = 4502, pos = { x = -13.91436, y = -11.23211, z = 0.8217726 }, randomPos = 0, randomRadius = 0, monsters = { 60451,  }, spawnType = 1, spawnDTime = 3000, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4503] = {	id = 4503, pos = { x = -2.036355, y = -11.29216, z = -8.995171 }, randomPos = 0, randomRadius = 0, monsters = { 60452,  }, spawnType = 1, spawnDTime = 3100, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4504] = {	id = 4504, pos = { x = 1.697958, y = -11.17975, z = 13.13625 }, randomPos = 0, randomRadius = 0, monsters = { 60451,  }, spawnType = 1, spawnDTime = 3200, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4505] = {	id = 4505, pos = { x = -10.07816, y = -11.15492, z = -6.473653 }, randomPos = 0, randomRadius = 0, monsters = { 60452,  }, spawnType = 1, spawnDTime = 3300, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4506] = {	id = 4506, pos = { x = -12.46036, y = -11.25341, z = 10.37171 }, randomPos = 0, randomRadius = 0, monsters = { 60451,  }, spawnType = 1, spawnDTime = 2900, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4507] = {	id = 4507, pos = { x = 5.950206, y = -11.42301, z = -7.579656 }, randomPos = 0, randomRadius = 0, monsters = { 60452,  }, spawnType = 1, spawnDTime = 3000, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4508] = {	id = 4508, pos = { x = -5.546535, y = -11.38868, z = 5.732229 }, randomPos = 0, randomRadius = 0, monsters = { 60451,  }, spawnType = 1, spawnDTime = 3100, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4509] = {	id = 4509, pos = { x = 0.0, y = -11.63287, z = -1.293612 }, randomPos = 0, randomRadius = 0, monsters = { 60453,  }, spawnType = 1, spawnDTime = 12000, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4511] = {	id = 4511, pos = { x = 9.389688, y = -11.56405, z = 0.0 }, randomPos = 0, randomRadius = 0, monsters = { 60452,  }, spawnType = 1, spawnDTime = 2900, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4512] = {	id = 4512, pos = { x = -13.91436, y = -11.23211, z = 0.8217726 }, randomPos = 0, randomRadius = 0, monsters = { 60451,  }, spawnType = 1, spawnDTime = 3000, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4513] = {	id = 4513, pos = { x = -2.036355, y = -11.29216, z = -8.995171 }, randomPos = 0, randomRadius = 0, monsters = { 60452,  }, spawnType = 1, spawnDTime = 3100, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4514] = {	id = 4514, pos = { x = 1.697958, y = -11.17975, z = 13.13625 }, randomPos = 0, randomRadius = 0, monsters = { 60451,  }, spawnType = 1, spawnDTime = 3200, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4515] = {	id = 4515, pos = { x = -10.07816, y = -11.15492, z = -6.473653 }, randomPos = 0, randomRadius = 0, monsters = { 60452,  }, spawnType = 1, spawnDTime = 3300, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4516] = {	id = 4516, pos = { x = -12.46036, y = -11.25341, z = 10.37171 }, randomPos = 0, randomRadius = 0, monsters = { 60451,  }, spawnType = 1, spawnDTime = 2900, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4517] = {	id = 4517, pos = { x = 5.950206, y = -11.42301, z = -7.579656 }, randomPos = 0, randomRadius = 0, monsters = { 60452,  }, spawnType = 1, spawnDTime = 3000, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4518] = {	id = 4518, pos = { x = -5.546535, y = -11.38868, z = 5.732229 }, randomPos = 0, randomRadius = 0, monsters = { 60451,  }, spawnType = 1, spawnDTime = 3100, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4519] = {	id = 4519, pos = { x = 0.0, y = -11.63287, z = -1.293612 }, randomPos = 0, randomRadius = 0, monsters = { 60453,  }, spawnType = 1, spawnDTime = 12000, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4521] = {	id = 4521, pos = { x = 9.389688, y = -11.56405, z = 0.0 }, randomPos = 0, randomRadius = 0, monsters = { 60452,  }, spawnType = 1, spawnDTime = 2900, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4522] = {	id = 4522, pos = { x = -13.91436, y = -11.23211, z = 0.8217726 }, randomPos = 0, randomRadius = 0, monsters = { 60451,  }, spawnType = 1, spawnDTime = 3000, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4523] = {	id = 4523, pos = { x = -2.036355, y = -11.29216, z = -8.995171 }, randomPos = 0, randomRadius = 0, monsters = { 60452,  }, spawnType = 1, spawnDTime = 3100, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4524] = {	id = 4524, pos = { x = 1.697958, y = -11.17975, z = 13.13625 }, randomPos = 0, randomRadius = 0, monsters = { 60451,  }, spawnType = 1, spawnDTime = 3200, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4525] = {	id = 4525, pos = { x = -10.07816, y = -11.15492, z = -6.473653 }, randomPos = 0, randomRadius = 0, monsters = { 60452,  }, spawnType = 1, spawnDTime = 3300, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4526] = {	id = 4526, pos = { x = -12.46036, y = -11.25341, z = 10.37171 }, randomPos = 0, randomRadius = 0, monsters = { 60451,  }, spawnType = 1, spawnDTime = 2900, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4527] = {	id = 4527, pos = { x = 5.950206, y = -11.42301, z = -7.579656 }, randomPos = 0, randomRadius = 0, monsters = { 60452,  }, spawnType = 1, spawnDTime = 3000, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4528] = {	id = 4528, pos = { x = -5.546535, y = -11.38868, z = 5.732229 }, randomPos = 0, randomRadius = 0, monsters = { 60451,  }, spawnType = 1, spawnDTime = 3100, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4529] = {	id = 4529, pos = { x = 0.0, y = -11.63287, z = -1.293612 }, randomPos = 0, randomRadius = 0, monsters = { 60453,  }, spawnType = 1, spawnDTime = 12000, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4531] = {	id = 4531, pos = { x = 9.389688, y = -11.56405, z = 0.0 }, randomPos = 0, randomRadius = 0, monsters = { 60452,  }, spawnType = 1, spawnDTime = 2900, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4532] = {	id = 4532, pos = { x = -13.91436, y = -11.23211, z = 0.8217726 }, randomPos = 0, randomRadius = 0, monsters = { 60451,  }, spawnType = 1, spawnDTime = 3000, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4533] = {	id = 4533, pos = { x = -2.036355, y = -11.29216, z = -8.995171 }, randomPos = 0, randomRadius = 0, monsters = { 60452,  }, spawnType = 1, spawnDTime = 3100, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4534] = {	id = 4534, pos = { x = 1.697958, y = -11.17975, z = 13.13625 }, randomPos = 0, randomRadius = 0, monsters = { 60451,  }, spawnType = 1, spawnDTime = 3200, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4535] = {	id = 4535, pos = { x = -10.07816, y = -11.15492, z = -6.473653 }, randomPos = 0, randomRadius = 0, monsters = { 60452,  }, spawnType = 1, spawnDTime = 3300, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4536] = {	id = 4536, pos = { x = -12.46036, y = -11.25341, z = 10.37171 }, randomPos = 0, randomRadius = 0, monsters = { 60451,  }, spawnType = 1, spawnDTime = 2900, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4537] = {	id = 4537, pos = { x = 5.950206, y = -11.42301, z = -7.579656 }, randomPos = 0, randomRadius = 0, monsters = { 60452,  }, spawnType = 1, spawnDTime = 3000, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4538] = {	id = 4538, pos = { x = -5.546535, y = -11.38868, z = 5.732229 }, randomPos = 0, randomRadius = 0, monsters = { 60451,  }, spawnType = 1, spawnDTime = 3100, spawnTimes = 6, spawnNum = { { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { 2, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[4539] = {	id = 4539, pos = { x = 0.0, y = -11.63287, z = -1.293612 }, randomPos = 0, randomRadius = 0, monsters = { 60453,  }, spawnType = 1, spawnDTime = 12000, spawnTimes = 6, spawnNum = { { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { 1, }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
