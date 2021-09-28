----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1002333] = {
		[1] = {events = {{triTime = 450, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, }, {triTime = 800, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002341] = {
		[1] = {events = {{triTime = 750, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002342] = {
		[1] = {events = {{triTime = 750, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002351] = {
		[1] = {events = {{triTime = 600, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002352] = {
		[1] = {events = {{triTime = 750, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002353] = {
		[1] = {events = {{triTime = 1250, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, }, },},
	},
	[1002354] = {
		[1] = {events = {{triTime = 1250, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.2, }, }, },},
	},
	[1002355] = {
		[1] = {events = {{triTime = 1250, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002321] = {
		[1] = {events = {{triTime = 1000, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002331] = {
		[1] = {events = {{triTime = 450, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002332] = {
		[1] = {events = {{triTime = 250, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002334] = {
		[1] = {events = {{triTime = 500, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.2, }, }, },},
	},

};
function get_db_table()
	return level;
end
