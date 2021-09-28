----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[40002] = {
		[1] = {events = {{triTime = 375, hitEffID = 30143, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.2, }, }, },},
	},

};
function get_db_table()
	return level;
end
