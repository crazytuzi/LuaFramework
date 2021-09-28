----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001251] = {
		[1] = {events = {{triTime = 525, hitEffID = 30447, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001261] = {
		[1] = {events = {{triTime = 550, hitEffID = 30453, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001262] = {
		[1] = {events = {{triTime = 625, hitEffID = 30453, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001271] = {
		[1] = {events = {{triTime = 550, hitEffID = 30454, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001241] = {
		[1] = {events = {{triTime = 475, hitEffID = 30448, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001242] = {
		[1] = {events = {{triTime = 500, hitEffID = 30448, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001272] = {
		[1] = {events = {{triTime = 625, hitEffID = 30454, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001252] = {
		[1] = {events = {{triTime = 550, hitEffID = 30447, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
