----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94043] = {
		[1] = {cool = 15000, events = {{triTime = 500, hitEffID = 30136, hitSoundID = 2, damage = {odds = 10000, arg1 = 0.65, }, status = {{odds = 10000, buffID = 1509, }, }, }, {triTime = 1025, hitEffID = 30138, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.65, }, }, },},
	},

};
function get_db_table()
	return level;
end
