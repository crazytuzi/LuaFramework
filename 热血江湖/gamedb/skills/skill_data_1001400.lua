----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001422] = {
		[1] = {events = {{triTime = 600, hitEffID = 30422, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001401] = {
		[1] = {events = {{triTime = 525, hitEffID = 30420, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001402] = {
		[1] = {events = {{triTime = 600, hitEffID = 30420, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001411] = {
		[1] = {events = {{triTime = 525, hitEffID = 30449, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001412] = {
		[1] = {events = {{triTime = 600, hitEffID = 30449, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001421] = {
		[1] = {events = {{triTime = 500, hitEffID = 30422, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001431] = {
		[1] = {events = {{triTime = 475, hitEffID = 30434, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001432] = {
		[1] = {events = {{triTime = 450, hitEffID = 30434, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
