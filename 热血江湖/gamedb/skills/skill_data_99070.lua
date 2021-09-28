----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99070] = {
		[1] = {cool = 7000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, }, },},
	},

};
function get_db_table()
	return level;
end
