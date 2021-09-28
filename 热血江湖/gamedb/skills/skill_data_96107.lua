----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[96107] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130025, }, {odds = 10000, buffID = 130040, }, }, }, },spArgs1 = '10.0', spArgs2 = '2.0', },
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130026, }, {odds = 10000, buffID = 130041, }, }, }, },spArgs1 = '12.0', spArgs2 = '2.5', },
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130027, }, {odds = 10000, buffID = 130042, }, }, }, },spArgs1 = '15.0', spArgs2 = '3.0', },
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130028, }, {odds = 10000, buffID = 130043, }, }, }, },spArgs1 = '18.0', spArgs2 = '3.5', },
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130029, }, {odds = 10000, buffID = 130044, }, }, }, },spArgs1 = '20.0', spArgs2 = '4.0', },
		[6] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130030, }, {odds = 10000, buffID = 130045, }, }, }, },spArgs1 = '24.0', spArgs2 = '4.5', },
		[7] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130031, }, {odds = 10000, buffID = 130046, }, }, }, },spArgs1 = '28.0', spArgs2 = '5.0', },
		[8] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130032, }, {odds = 10000, buffID = 130047, }, }, }, },spArgs1 = '32.0', spArgs2 = '5.5', },
		[9] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130033, }, {odds = 10000, buffID = 130048, }, }, }, },spArgs1 = '36.0', spArgs2 = '6.0', },
		[10] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130034, }, {odds = 10000, buffID = 130049, }, }, }, },spArgs1 = '40.0', spArgs2 = '6.5', },
		[11] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130035, }, {odds = 10000, buffID = 130050, }, }, }, },spArgs1 = '44.0', spArgs2 = '7.0', },
		[12] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130036, }, {odds = 10000, buffID = 130051, }, }, }, },spArgs1 = '48.0', spArgs2 = '7.5', },
		[13] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130037, }, {odds = 10000, buffID = 130052, }, }, }, },spArgs1 = '52.0', spArgs2 = '8.0', },
		[14] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130038, }, {odds = 10000, buffID = 130053, }, }, }, },spArgs1 = '56.0', spArgs2 = '9.0', },
		[15] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130039, }, {odds = 10000, buffID = 130054, }, }, }, },spArgs1 = '60.0', spArgs2 = '10.0', },
	},

};
function get_db_table()
	return level;
end
