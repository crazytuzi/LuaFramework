----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94034] = {
		[1] = {cool = 10000, events = {{triTime = 780, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
