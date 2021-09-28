----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001681] = {
		[1] = {events = {{triTime = 450, hitEffID = 30068, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001682] = {
		[1] = {events = {{triTime = 325, hitEffID = 30068, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001691] = {
		[1] = {events = {{triTime = 450, hitEffID = 30068, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001692] = {
		[1] = {events = {{triTime = 425, hitEffID = 30068, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001701] = {
		[1] = {events = {{triTime = 400, hitEffID = 30428, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001702] = {
		[1] = {events = {{triTime = 600, hitEffID = 30428, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001711] = {
		[1] = {events = {{triTime = 400, hitEffID = 30438, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001712] = {
		[1] = {events = {{triTime = 525, hitEffID = 30438, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
