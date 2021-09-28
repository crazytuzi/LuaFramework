----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99033] = {
		[1] = {cool = 6000, events = {{triTime = 700, hitEffID = 30089, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0415, arg2 = 54.0, }, }, {triTime = 950, hitEffID = 30146, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0415, arg2 = 54.0, }, }, },spArgs1 = '104.15', spArgs2 = '54', },
	},

};
function get_db_table()
	return level;
end
