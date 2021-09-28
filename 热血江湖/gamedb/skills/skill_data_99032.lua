----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99032] = {
		[1] = {cool = 5000, events = {{triTime = 750, hitEffID = 30089, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0043, arg2 = 103.0, }, }, },spArgs1 = '200.43', spArgs2 = '103', spArgs3 = '50', },
	},

};
function get_db_table()
	return level;
end
