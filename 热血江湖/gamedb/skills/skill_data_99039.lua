----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99039] = {
		[1] = {events = {{triTime = 775, hitEffID = 30212, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
