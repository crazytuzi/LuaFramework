----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[80001] = {
		[1] = {events = {{triTime = 450, hitEffID = 31037, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
