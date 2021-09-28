----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001392] = {
		[1] = {events = {{triTime = 500, hitEffID = 30448, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001381] = {
		[1] = {events = {{triTime = 400, hitEffID = 30459, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001361] = {
		[1] = {events = {{triTime = 325, hitEffID = 30448, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001362] = {
		[1] = {events = {{triTime = 525, hitEffID = 30448, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001371] = {
		[1] = {events = {{triTime = 400, hitEffID = 30425, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001372] = {
		[1] = {events = {{triTime = 425, hitEffID = 30425, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001382] = {
		[1] = {events = {{triTime = 600, hitEffID = 30459, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001391] = {
		[1] = {events = {{triTime = 475, hitEffID = 30448, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
