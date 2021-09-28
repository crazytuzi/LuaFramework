----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1002813] = {
		[1] = {events = {{triTime = 100, hitEffID = 30203, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, arg2 = 97500.0, }, status = {{odds = 5000, buffID = 626, }, {odds = 5000, buffID = 627, }, }, }, },},
	},
	[1002801] = {
		[1] = {events = {{triTime = 525, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002809] = {
		[1] = {events = {{triTime = 100, hitEffID = 30203, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, arg2 = 3366.0, }, status = {{odds = 5000, buffID = 626, }, {odds = 5000, buffID = 627, }, }, }, },},
	},
	[1002803] = {
		[1] = {events = {{triTime = 2275, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.2, }, }, {triTime = 2650, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.2, }, }, },},
	},
	[1002810] = {
		[1] = {events = {{triTime = 100, hitEffID = 30203, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, arg2 = 6720.0, }, status = {{odds = 5000, buffID = 626, }, {odds = 5000, buffID = 627, }, }, }, },},
	},
	[1002811] = {
		[1] = {events = {{triTime = 100, hitEffID = 30203, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, arg2 = 20736.0, }, status = {{odds = 5000, buffID = 626, }, {odds = 5000, buffID = 627, }, }, }, },},
	},
	[1002812] = {
		[1] = {events = {{triTime = 100, hitEffID = 30203, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, arg2 = 68009.0, }, status = {{odds = 5000, buffID = 626, }, {odds = 5000, buffID = 627, }, }, }, },},
	},
	[1002805] = {
		[1] = {events = {{triTime = 100, hitEffID = 30203, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, arg2 = 594.0, }, status = {{odds = 5000, buffID = 626, }, {odds = 5000, buffID = 627, }, }, }, },},
	},
	[1002806] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 74002, }, }, }, },},
	},
	[1002808] = {
		[1] = {events = {{triTime = 100, hitEffID = 30203, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, arg2 = 1599.0, }, status = {{odds = 5000, buffID = 626, }, {odds = 5000, buffID = 627, }, }, }, },},
	},
	[1002802] = {
		[1] = {events = {{hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
	},
	[1002804] = {
		[1] = {events = {{triTime = 375, damage = {odds = 10000, arg1 = 1.0, }, }, {damage = {atrType = 1, }, }, },},
	},
	[1002807] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 74003, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
