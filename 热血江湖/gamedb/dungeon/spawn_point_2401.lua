----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[480201] = {	id = 480201, pos = { x = -6.117404, y = 6.359738, z = 8.276796 }, randomPos = 0, randomRadius = 0, monsters = { 90433,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480202] = {	id = 480202, pos = { x = -0.4944591, y = 6.133396, z = -3.868544 }, randomPos = 0, randomRadius = 0, monsters = { 90433,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480203] = {	id = 480203, pos = { x = 0.7441702, y = 6.14389, z = -3.190098 }, randomPos = 0, randomRadius = 0, monsters = { 90433,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480204] = {	id = 480204, pos = { x = 3.99332, y = 6.144376, z = -2.913858 }, randomPos = 0, randomRadius = 0, monsters = { 90433,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480205] = {	id = 480205, pos = { x = 5.347989, y = 6.145614, z = -2.779235 }, randomPos = 0, randomRadius = 0, monsters = { 90433,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480206] = {	id = 480206, pos = { x = 6.919815, y = 6.143645, z = -2.993302 }, randomPos = 0, randomRadius = 0, monsters = { 90432,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480207] = {	id = 480207, pos = { x = 8.924987, y = 6.138572, z = -3.544984 }, randomPos = 0, randomRadius = 0, monsters = { 90432,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480208] = {	id = 480208, pos = { x = 9.77643, y = 6.157355, z = -1.502333 }, randomPos = 0, randomRadius = 0, monsters = { 90432,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480209] = {	id = 480209, pos = { x = 13.7769, y = 6.126305, z = -4.437903 }, randomPos = 0, randomRadius = 0, monsters = { 90432,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480210] = {	id = 480210, pos = { x = 0.0, y = 6.016432, z = 19.62879 }, randomPos = 0, randomRadius = 0, monsters = { 90432,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480301] = {	id = 480301, pos = { x = -9.781466, y = 6.079678, z = 18.30071 }, randomPos = 0, randomRadius = 0, monsters = { 90433,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480302] = {	id = 480302, pos = { x = -9.507328, y = 6.427875, z = 11.59973 }, randomPos = 0, randomRadius = 0, monsters = { 90433,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480303] = {	id = 480303, pos = { x = -8.413284, y = 6.219988, z = 3.744232 }, randomPos = 0, randomRadius = 0, monsters = { 90433,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480304] = {	id = 480304, pos = { x = -6.52361, y = 6.113656, z = 2.182036 }, randomPos = 0, randomRadius = 0, monsters = { 90433,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480305] = {	id = 480305, pos = { x = -9.496993, y = 6.449212, z = 8.838739 }, randomPos = 0, randomRadius = 0, monsters = { 90433,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480306] = {	id = 480306, pos = { x = 13.5259, y = 6.320786, z = 14.31985 }, randomPos = 0, randomRadius = 0, monsters = { 90434,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480307] = {	id = 480307, pos = { x = 14.59788, y = 6.352636, z = 11.51434 }, randomPos = 0, randomRadius = 0, monsters = { 90434,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480308] = {	id = 480308, pos = { x = 14.64462, y = 6.350135, z = 9.599398 }, randomPos = 0, randomRadius = 0, monsters = { 90434,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480309] = {	id = 480309, pos = { x = 15.42652, y = 6.308546, z = 6.384782 }, randomPos = 0, randomRadius = 0, monsters = { 90434,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480310] = {	id = 480310, pos = { x = 11.95575, y = 6.125558, z = 20.55542 }, randomPos = 0, randomRadius = 0, monsters = { 90434,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
