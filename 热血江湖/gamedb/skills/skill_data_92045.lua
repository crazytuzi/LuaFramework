----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[92045] = {
		[1] = {cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.0336, arg2 = 1153.0, }, status = {{odds = 2500, buffID = 1285, }, }, }, },skillpower = 50, spArgs1 = '203.36', spArgs2 = '1153', spArgs3 = '25', },
		[2] = {needCoin = 5000, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.0708, arg2 = 1255.0, }, status = {{odds = 3000, buffID = 1285, }, }, }, },skillpower = 100, spArgs1 = '207.08', spArgs2 = '1255', spArgs3 = '30', },
		[3] = {needCoin = 10000, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.108, arg2 = 1361.0, }, status = {{odds = 3500, buffID = 1285, }, }, }, },skillpower = 150, spArgs1 = '210.8', spArgs2 = '1361', spArgs3 = '35', },
		[4] = {needCoin = 15000, needItemID = 67277, needItemNum = 5, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.1452, arg2 = 1470.0, }, status = {{odds = 4000, buffID = 1285, }, }, }, },skillpower = 200, spArgs1 = '214.52', spArgs2 = '1470', spArgs3 = '40', },
		[5] = {needCoin = 20000, needItemID = 67277, needItemNum = 5, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.1824, arg2 = 1582.0, }, status = {{odds = 4499, buffID = 1285, }, }, }, },skillpower = 250, spArgs1 = '218.24', spArgs2 = '1582', spArgs3 = '45', },
		[6] = {needCoin = 30000, needItemID = 67277, needItemNum = 5, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.2196, arg2 = 1697.0, }, status = {{odds = 4999, buffID = 1285, }, }, }, },skillpower = 300, spArgs1 = '221.96', spArgs2 = '1697', spArgs3 = '50', },
		[7] = {needCoin = 40000, needItemID = 67277, needItemNum = 10, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.2568, arg2 = 1816.0, }, status = {{odds = 5499, buffID = 1285, }, }, }, },skillpower = 350, spArgs1 = '225.68', spArgs2 = '1816', spArgs3 = '55', },
		[8] = {needCoin = 50000, needItemID = 67277, needItemNum = 10, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.294, arg2 = 1938.0, }, status = {{odds = 5999, buffID = 1285, }, }, }, },skillpower = 400, spArgs1 = '229.4', spArgs2 = '1938', spArgs3 = '60', },
		[9] = {needCoin = 60000, needItemID = 67277, needItemNum = 10, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.3312, arg2 = 2064.0, }, status = {{odds = 6499, buffID = 1285, }, }, }, },skillpower = 450, spArgs1 = '233.12', spArgs2 = '2064', spArgs3 = '65', },
		[10] = {needCoin = 70000, needItemID = 67277, needItemNum = 15, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.3684, arg2 = 2193.0, }, status = {{odds = 6999, buffID = 1285, }, }, }, },skillpower = 500, spArgs1 = '236.84', spArgs2 = '2193', spArgs3 = '70', },
		[11] = {needCoin = 80000, needItemID = 67277, needItemNum = 15, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.4056, arg2 = 2325.0, }, status = {{odds = 7499, buffID = 1285, }, }, }, },skillpower = 550, spArgs1 = '240.56', spArgs2 = '2325', spArgs3 = '75', },
		[12] = {needCoin = 90000, needItemID = 67277, needItemNum = 15, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.4428, arg2 = 2461.0, }, status = {{odds = 7999, buffID = 1285, }, }, }, },skillpower = 600, spArgs1 = '244.28', spArgs2 = '2461', spArgs3 = '80', },
		[13] = {needCoin = 100000, needItemID = 67277, needItemNum = 20, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.48, arg2 = 2600.0, }, status = {{odds = 8499, buffID = 1285, }, }, }, },skillpower = 650, spArgs1 = '248', spArgs2 = '2600', spArgs3 = '85', },
		[14] = {needCoin = 110000, needItemID = 67277, needItemNum = 20, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.5172, arg2 = 2742.0, }, status = {{odds = 8999, buffID = 1285, }, }, }, },skillpower = 700, spArgs1 = '251.72', spArgs2 = '2742', spArgs3 = '90', },
		[15] = {needCoin = 120000, needItemID = 67277, needItemNum = 20, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.5544, arg2 = 2887.0, }, status = {{odds = 9499, buffID = 1285, }, }, }, },skillpower = 750, spArgs1 = '255.44', spArgs2 = '2887', spArgs3 = '95', },
		[16] = {needCoin = 130000, needItemID = 67277, needItemNum = 25, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.5916, arg2 = 3036.0, }, status = {{odds = 9999, buffID = 1285, }, }, }, },skillpower = 800, spArgs1 = '259.16', spArgs2 = '3036', spArgs3 = '100', },
		[17] = {needCoin = 140000, needItemID = 67277, needItemNum = 25, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.6288, arg2 = 3189.0, }, status = {{odds = 10000, buffID = 1285, }, }, }, },skillpower = 850, spArgs1 = '262.88', spArgs2 = '3189', spArgs3 = '100', },
		[18] = {needCoin = 150000, needItemID = 67277, needItemNum = 25, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.666, arg2 = 3344.0, }, status = {{odds = 10000, buffID = 1285, }, }, }, },skillpower = 900, spArgs1 = '266.6', spArgs2 = '3344', spArgs3 = '100', },
		[19] = {needCoin = 160000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.7032, arg2 = 3503.0, }, status = {{odds = 10000, buffID = 1285, }, }, }, },skillpower = 950, spArgs1 = '270.32', spArgs2 = '3503', spArgs3 = '100', },
		[20] = {needCoin = 170000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.7404, arg2 = 3666.0, }, status = {{odds = 10000, buffID = 1285, }, }, }, },skillpower = 1000, spArgs1 = '274.04', spArgs2 = '3666', spArgs3 = '100', },
		[21] = {needCoin = 180000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.7776, arg2 = 3832.0, }, status = {{odds = 10000, buffID = 1285, }, }, }, },skillpower = 1050, spArgs1 = '277.76', spArgs2 = '3832', spArgs3 = '100', },
		[22] = {needCoin = 190000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.8148, arg2 = 4001.0, }, status = {{odds = 10000, buffID = 1285, }, }, }, },skillpower = 1100, spArgs1 = '281.48', spArgs2 = '4001', spArgs3 = '100', },
		[23] = {needCoin = 200000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.852, arg2 = 4173.0, }, status = {{odds = 10000, buffID = 1285, }, }, }, },skillpower = 1150, spArgs1 = '285.2', spArgs2 = '4173', spArgs3 = '100', },
		[24] = {needCoin = 210000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.8892, arg2 = 4349.0, }, status = {{odds = 10000, buffID = 1285, }, }, }, },skillpower = 1200, spArgs1 = '288.92', spArgs2 = '4349', spArgs3 = '100', },
		[25] = {needCoin = 220000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.909, arg2 = 4528.0, }, status = {{odds = 10000, buffID = 1285, }, }, }, },skillpower = 1250, spArgs1 = '290.9', spArgs2 = '4528', spArgs3 = '100', },
		[26] = {needCoin = 230000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.9202, arg2 = 4710.0, }, status = {{odds = 10000, buffID = 1285, }, }, }, },skillpower = 1300, spArgs1 = '292.02', spArgs2 = '4710', spArgs3 = '100', },
		[27] = {needCoin = 240000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.9314, arg2 = 4896.0, }, status = {{odds = 10000, buffID = 1285, }, }, }, },skillpower = 1350, spArgs1 = '293.14', spArgs2 = '4896', spArgs3 = '100', },
		[28] = {needCoin = 250000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.9425, arg2 = 5085.0, }, status = {{odds = 10000, buffID = 1285, }, }, }, },skillpower = 1400, spArgs1 = '294.25', spArgs2 = '5085', spArgs3 = '100', },
		[29] = {needCoin = 260000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.9537, arg2 = 5278.0, }, status = {{odds = 10000, buffID = 1285, }, }, }, },skillpower = 1450, spArgs1 = '295.37', spArgs2 = '5278', spArgs3 = '100', },
		[30] = {needCoin = 270000, needItemID = 67277, needItemNum = 30, cool = 40000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.9648, arg2 = 5474.0, }, status = {{odds = 10000, buffID = 1285, }, }, }, },skillpower = 1500, spArgs1 = '296.48', spArgs2 = '5474', spArgs3 = '100', },
	},

};
function get_db_table()
	return level;
end
