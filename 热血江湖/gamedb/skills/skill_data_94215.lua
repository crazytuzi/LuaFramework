----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94215] = {
		[1] = {cool = 10000, events = {{triTime = 450, hitEffID = 30792, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 700, hitEffID = 30792, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 1000, hitEffID = 30792, damage = {odds = 10000, arg1 = 0.8, }, }, },},
	},

};
function get_db_table()
	return level;
end
