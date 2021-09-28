----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001791] = {
		[1] = {events = {{triTime = 875, hitEffID = 30786, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001761] = {
		[1] = {events = {{triTime = 600, hitEffID = 30783, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001762] = {
		[1] = {events = {{triTime = 650, hitEffID = 30783, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001771] = {
		[1] = {events = {{triTime = 350, hitEffID = 30784, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001772] = {
		[1] = {events = {{triTime = 500, hitEffID = 30784, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1025, hitEffID = 30784, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001781] = {
		[1] = {events = {{triTime = 1250, hitEffID = 30785, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001782] = {
		[1] = {events = {{triTime = 1250, hitEffID = 30785, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001792] = {
		[1] = {events = {{triTime = 850, hitEffID = 30786, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
