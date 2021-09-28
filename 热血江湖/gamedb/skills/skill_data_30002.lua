----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[30002] = {
		[1] = {events = {{triTime = 125, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.6, }, }, },},
	},

};
function get_db_table()
	return level;
end
