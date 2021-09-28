----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001472] = {
		[1] = {events = {{triTime = 375, hitEffID = 30413, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001441] = {
		[1] = {events = {{triTime = 450, hitEffID = 30417, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001442] = {
		[1] = {events = {{triTime = 625, hitEffID = 30417, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001451] = {
		[1] = {events = {{triTime = 400, hitEffID = 30066, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001452] = {
		[1] = {events = {{triTime = 400, hitEffID = 30066, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001461] = {
		[1] = {events = {{triTime = 450, hitEffID = 30426, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001462] = {
		[1] = {events = {{triTime = 450, hitEffID = 30426, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001471] = {
		[1] = {events = {{triTime = 350, hitEffID = 30413, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
