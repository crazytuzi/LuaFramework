----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94041] = {
		[1] = {events = {{triTime = 450, hitEffID = 30136, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.5, }, }, },},
	},

};
function get_db_table()
	return level;
end
