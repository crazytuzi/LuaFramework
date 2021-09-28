----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001662] = {
		[1] = {events = {{triTime = 525, hitEffID = 30457, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001641] = {
		[1] = {events = {{triTime = 375, hitEffID = 30432, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001651] = {
		[1] = {events = {{triTime = 450, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001652] = {
		[1] = {events = {{triTime = 400, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001661] = {
		[1] = {events = {{triTime = 450, hitEffID = 30457, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001671] = {
		[1] = {events = {{triTime = 475, hitEffID = 30437, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001672] = {
		[1] = {events = {{triTime = 475, hitEffID = 30437, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001642] = {
		[1] = {events = {{triTime = 450, hitEffID = 30432, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
