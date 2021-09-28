----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[92049] = {
		[1] = {cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.46, arg2 = 1395.0, }, status = {{odds = 2400, buffID = 1654, }, }, }, },skillpower = 50, spArgs1 = '246', spArgs2 = '1395', spArgs3 = '24', },
		[2] = {needCoin = 5000, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.505, arg2 = 1519.0, }, status = {{odds = 2799, buffID = 1654, }, }, }, },skillpower = 100, spArgs1 = '250.5', spArgs2 = '1519', spArgs3 = '28', },
		[3] = {needCoin = 10000, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.55, arg2 = 1646.0, }, status = {{odds = 3200, buffID = 1654, }, }, }, },skillpower = 150, spArgs1 = '255', spArgs2 = '1646', spArgs3 = '32', },
		[4] = {needCoin = 15000, needItemID = 67277, needItemNum = 5, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.595, arg2 = 1778.0, }, status = {{odds = 3600, buffID = 1654, }, }, }, },skillpower = 200, spArgs1 = '259.5', spArgs2 = '1778', spArgs3 = '36', },
		[5] = {needCoin = 20000, needItemID = 67277, needItemNum = 5, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.64, arg2 = 1913.0, }, status = {{odds = 4000, buffID = 1654, }, }, }, },skillpower = 250, spArgs1 = '264', spArgs2 = '1913', spArgs3 = '40', },
		[6] = {needCoin = 30000, needItemID = 67277, needItemNum = 5, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.685, arg2 = 2053.0, }, status = {{odds = 4400, buffID = 1654, }, }, }, },skillpower = 300, spArgs1 = '268.5', spArgs2 = '2053', spArgs3 = '44', },
		[7] = {needCoin = 40000, needItemID = 67277, needItemNum = 10, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.73, arg2 = 2197.0, }, status = {{odds = 4800, buffID = 1654, }, }, }, },skillpower = 350, spArgs1 = '273', spArgs2 = '2197', spArgs3 = '48', },
		[8] = {needCoin = 50000, needItemID = 67277, needItemNum = 10, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.775, arg2 = 2345.0, }, status = {{odds = 5200, buffID = 1654, }, }, }, },skillpower = 400, spArgs1 = '277.5', spArgs2 = '2345', spArgs3 = '52', },
		[9] = {needCoin = 60000, needItemID = 67277, needItemNum = 10, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.82, arg2 = 2497.0, }, status = {{odds = 5600, buffID = 1654, }, }, }, },skillpower = 450, spArgs1 = '282', spArgs2 = '2497', spArgs3 = '56', },
		[10] = {needCoin = 70000, needItemID = 67277, needItemNum = 15, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.865, arg2 = 2653.0, }, status = {{odds = 6000, buffID = 1654, }, }, }, },skillpower = 500, spArgs1 = '286.5', spArgs2 = '2653', spArgs3 = '60', },
		[11] = {needCoin = 80000, needItemID = 67277, needItemNum = 15, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.91, arg2 = 2813.0, }, status = {{odds = 6400, buffID = 1654, }, }, }, },skillpower = 550, spArgs1 = '291', spArgs2 = '2813', spArgs3 = '64', },
		[12] = {needCoin = 90000, needItemID = 67277, needItemNum = 15, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.955, arg2 = 2977.0, }, status = {{odds = 6800, buffID = 1654, }, }, }, },skillpower = 600, spArgs1 = '295.5', spArgs2 = '2977', spArgs3 = '68', },
		[13] = {needCoin = 100000, needItemID = 67277, needItemNum = 20, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 3.0, arg2 = 3145.0, }, status = {{odds = 7200, buffID = 1654, }, }, }, },skillpower = 650, spArgs1 = '300', spArgs2 = '3145', spArgs3 = '72', },
		[14] = {needCoin = 110000, needItemID = 67277, needItemNum = 20, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 3.045, arg2 = 3317.0, }, status = {{odds = 7600, buffID = 1654, }, }, }, },skillpower = 700, spArgs1 = '304.5', spArgs2 = '3317', spArgs3 = '76', },
		[15] = {needCoin = 120000, needItemID = 67277, needItemNum = 20, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 3.09, arg2 = 3493.0, }, status = {{odds = 8000, buffID = 1654, }, }, }, },skillpower = 750, spArgs1 = '309', spArgs2 = '3493', spArgs3 = '80', },
		[16] = {needCoin = 130000, needItemID = 67277, needItemNum = 25, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 3.135, arg2 = 3673.0, }, status = {{odds = 8400, buffID = 1654, }, }, }, },skillpower = 800, spArgs1 = '313.5', spArgs2 = '3673', spArgs3 = '84', },
		[17] = {needCoin = 140000, needItemID = 67277, needItemNum = 25, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 3.18, arg2 = 3857.0, }, status = {{odds = 8800, buffID = 1654, }, }, }, },skillpower = 850, spArgs1 = '318', spArgs2 = '3857', spArgs3 = '88', },
		[18] = {needCoin = 150000, needItemID = 67277, needItemNum = 25, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 3.225, arg2 = 4046.0, }, status = {{odds = 9200, buffID = 1654, }, }, }, },skillpower = 900, spArgs1 = '322.5', spArgs2 = '4046', spArgs3 = '92', },
		[19] = {needCoin = 160000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 3.27, arg2 = 4238.0, }, status = {{odds = 9600, buffID = 1654, }, }, }, },skillpower = 950, spArgs1 = '327', spArgs2 = '4238', spArgs3 = '96', },
		[20] = {needCoin = 170000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 3.315, arg2 = 4435.0, }, status = {{odds = 10000, buffID = 1654, }, }, }, },skillpower = 1000, spArgs1 = '331.5', spArgs2 = '4435', spArgs3 = '100', },
		[21] = {needCoin = 180000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 3.36, arg2 = 4635.0, }, status = {{odds = 10000, buffID = 1654, }, }, }, },skillpower = 1050, spArgs1 = '336', spArgs2 = '4635', spArgs3 = '100', },
		[22] = {needCoin = 190000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 3.405, arg2 = 4840.0, }, status = {{odds = 10000, buffID = 1654, }, }, }, },skillpower = 1100, spArgs1 = '340.5', spArgs2 = '4840', spArgs3 = '100', },
		[23] = {needCoin = 200000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 3.45, arg2 = 5048.0, }, status = {{odds = 10000, buffID = 1654, }, }, }, },skillpower = 1150, spArgs1 = '345', spArgs2 = '5048', spArgs3 = '100', },
		[24] = {needCoin = 210000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 3.495, arg2 = 5261.0, }, status = {{odds = 10000, buffID = 1654, }, }, }, },skillpower = 1200, spArgs1 = '349.5', spArgs2 = '5261', spArgs3 = '100', },
		[25] = {needCoin = 220000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 3.519, arg2 = 5477.0, }, status = {{odds = 10000, buffID = 1654, }, }, }, },skillpower = 1250, spArgs1 = '351.9', spArgs2 = '5477', spArgs3 = '100', },
		[26] = {needCoin = 230000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 3.5325, arg2 = 5698.0, }, status = {{odds = 10000, buffID = 1654, }, }, }, },skillpower = 1300, spArgs1 = '353.25', spArgs2 = '5698', spArgs3 = '100', },
		[27] = {needCoin = 240000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 3.546, arg2 = 5923.0, }, status = {{odds = 10000, buffID = 1654, }, }, }, },skillpower = 1350, spArgs1 = '354.6', spArgs2 = '5923', spArgs3 = '100', },
		[28] = {needCoin = 250000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 3.5595, arg2 = 6152.0, }, status = {{odds = 10000, buffID = 1654, }, }, }, },skillpower = 1400, spArgs1 = '355.95', spArgs2 = '6152', spArgs3 = '100', },
		[29] = {needCoin = 260000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 3.573, arg2 = 6385.0, }, status = {{odds = 10000, buffID = 1654, }, }, }, },skillpower = 1450, spArgs1 = '357.3', spArgs2 = '6385', spArgs3 = '100', },
		[30] = {needCoin = 270000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 3.5864999999999996, arg2 = 6622.0, }, status = {{odds = 10000, buffID = 1654, }, }, }, },skillpower = 1500, spArgs1 = '358.65', spArgs2 = '6622', spArgs3 = '100', },
	},

};
function get_db_table()
	return level;
end
