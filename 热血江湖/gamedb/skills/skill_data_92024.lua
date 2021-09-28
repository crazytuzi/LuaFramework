----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[92024] = {
		[1] = {cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 1.968, arg2 = 1116.0, }, status = {{odds = 2500, buffID = 786, }, }, }, },skillpower = 50, spArgs1 = '196.8', spArgs2 = '1116', spArgs3 = '25', },
		[2] = {needCoin = 5000, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.004, arg2 = 1215.0, }, status = {{odds = 3000, buffID = 786, }, }, }, },skillpower = 100, spArgs1 = '200.4', spArgs2 = '1215', spArgs3 = '30', },
		[3] = {needCoin = 10000, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.04, arg2 = 1317.0, }, status = {{odds = 3500, buffID = 786, }, }, }, },skillpower = 150, spArgs1 = '204', spArgs2 = '1317', spArgs3 = '35', },
		[4] = {needCoin = 15000, needItemID = 67277, needItemNum = 5, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.076, arg2 = 1422.0, }, status = {{odds = 4000, buffID = 786, }, }, }, },skillpower = 200, spArgs1 = '207.6', spArgs2 = '1422', spArgs3 = '40', },
		[5] = {needCoin = 20000, needItemID = 67277, needItemNum = 5, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.112, arg2 = 1531.0, }, status = {{odds = 4500, buffID = 786, }, }, }, },skillpower = 250, spArgs1 = '211.2', spArgs2 = '1531', spArgs3 = '45', },
		[6] = {needCoin = 30000, needItemID = 67277, needItemNum = 5, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.148, arg2 = 1643.0, }, status = {{odds = 5000, buffID = 786, }, }, }, },skillpower = 300, spArgs1 = '214.8', spArgs2 = '1643', spArgs3 = '50', },
		[7] = {needCoin = 40000, needItemID = 67277, needItemNum = 10, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.184, arg2 = 1758.0, }, status = {{odds = 5500, buffID = 786, }, }, }, },skillpower = 350, spArgs1 = '218.4', spArgs2 = '1758', spArgs3 = '55', },
		[8] = {needCoin = 50000, needItemID = 67277, needItemNum = 10, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.22, arg2 = 1876.0, }, status = {{odds = 6000, buffID = 786, }, }, }, },skillpower = 400, spArgs1 = '222', spArgs2 = '1876', spArgs3 = '60', },
		[9] = {needCoin = 60000, needItemID = 67277, needItemNum = 10, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.256, arg2 = 1997.0, }, status = {{odds = 6500, buffID = 786, }, }, }, },skillpower = 450, spArgs1 = '225.6', spArgs2 = '1997', spArgs3 = '65', },
		[10] = {needCoin = 70000, needItemID = 67277, needItemNum = 15, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.292, arg2 = 2122.0, }, status = {{odds = 7000, buffID = 786, }, }, }, },skillpower = 500, spArgs1 = '229.2', spArgs2 = '2122', spArgs3 = '70', },
		[11] = {needCoin = 80000, needItemID = 67277, needItemNum = 15, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.328, arg2 = 2250.0, }, status = {{odds = 7500, buffID = 786, }, }, }, },skillpower = 550, spArgs1 = '232.8', spArgs2 = '2250', spArgs3 = '75', },
		[12] = {needCoin = 90000, needItemID = 67277, needItemNum = 15, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.364, arg2 = 2381.0, }, status = {{odds = 8000, buffID = 786, }, }, }, },skillpower = 600, spArgs1 = '236.4', spArgs2 = '2381', spArgs3 = '80', },
		[13] = {needCoin = 100000, needItemID = 67277, needItemNum = 20, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.4, arg2 = 2516.0, }, status = {{odds = 8500, buffID = 786, }, }, }, },skillpower = 650, spArgs1 = '240', spArgs2 = '2516', spArgs3 = '85', },
		[14] = {needCoin = 110000, needItemID = 67277, needItemNum = 20, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.436, arg2 = 2653.0, }, status = {{odds = 9000, buffID = 786, }, }, }, },skillpower = 700, spArgs1 = '243.6', spArgs2 = '2653', spArgs3 = '90', },
		[15] = {needCoin = 120000, needItemID = 67277, needItemNum = 20, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.472, arg2 = 2794.0, }, status = {{odds = 9500, buffID = 786, }, }, }, },skillpower = 750, spArgs1 = '247.2', spArgs2 = '2794', spArgs3 = '95', },
		[16] = {needCoin = 130000, needItemID = 67277, needItemNum = 25, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.508, arg2 = 2939.0, }, status = {{odds = 10000, buffID = 786, }, }, }, },skillpower = 800, spArgs1 = '250.8', spArgs2 = '2939', spArgs3 = '100', },
		[17] = {needCoin = 140000, needItemID = 67277, needItemNum = 25, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.544, arg2 = 3086.0, }, status = {{odds = 10000, buffID = 786, }, }, }, },skillpower = 850, spArgs1 = '254.4', spArgs2 = '3086', spArgs3 = '100', },
		[18] = {needCoin = 150000, needItemID = 67277, needItemNum = 25, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.58, arg2 = 3237.0, }, status = {{odds = 10000, buffID = 786, }, }, }, },skillpower = 900, spArgs1 = '258', spArgs2 = '3237', spArgs3 = '100', },
		[19] = {needCoin = 160000, needItemID = 67277, needItemNum = 30, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.616, arg2 = 3390.0, }, status = {{odds = 10000, buffID = 786, }, }, }, },skillpower = 950, spArgs1 = '261.6', spArgs2 = '3390', spArgs3 = '100', },
		[20] = {needCoin = 170000, needItemID = 67277, needItemNum = 30, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.652, arg2 = 3548.0, }, status = {{odds = 10000, buffID = 786, }, }, }, },skillpower = 1000, spArgs1 = '265.2', spArgs2 = '3548', spArgs3 = '100', },
		[21] = {needCoin = 180000, needItemID = 67277, needItemNum = 30, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.688, arg2 = 3708.0, }, status = {{odds = 10000, buffID = 786, }, }, }, },skillpower = 1050, spArgs1 = '268.8', spArgs2 = '3708', spArgs3 = '100', },
		[22] = {needCoin = 190000, needItemID = 67277, needItemNum = 30, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.724, arg2 = 3872.0, }, status = {{odds = 10000, buffID = 786, }, }, }, },skillpower = 1100, spArgs1 = '272.4', spArgs2 = '3872', spArgs3 = '100', },
		[23] = {needCoin = 200000, needItemID = 67277, needItemNum = 30, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.76, arg2 = 4038.0, }, status = {{odds = 10000, buffID = 786, }, }, }, },skillpower = 1150, spArgs1 = '276', spArgs2 = '4038', spArgs3 = '100', },
		[24] = {needCoin = 210000, needItemID = 67277, needItemNum = 30, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.796, arg2 = 4209.0, }, status = {{odds = 10000, buffID = 786, }, }, }, },skillpower = 1200, spArgs1 = '279.6', spArgs2 = '4209', spArgs3 = '100', },
		[25] = {needCoin = 220000, needItemID = 67277, needItemNum = 30, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.8152, arg2 = 4382.0, }, status = {{odds = 10000, buffID = 786, }, }, }, },skillpower = 1250, spArgs1 = '281.52', spArgs2 = '4382', spArgs3 = '100', },
		[26] = {needCoin = 230000, needItemID = 67277, needItemNum = 30, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.826, arg2 = 4559.0, }, status = {{odds = 10000, buffID = 786, }, }, }, },skillpower = 1300, spArgs1 = '282.6', spArgs2 = '4559', spArgs3 = '100', },
		[27] = {needCoin = 240000, needItemID = 67277, needItemNum = 30, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.8368, arg2 = 4738.0, }, status = {{odds = 10000, buffID = 786, }, }, }, },skillpower = 1350, spArgs1 = '283.68', spArgs2 = '4738', spArgs3 = '100', },
		[28] = {needCoin = 250000, needItemID = 67277, needItemNum = 30, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.8476, arg2 = 4921.0, }, status = {{odds = 10000, buffID = 786, }, }, }, },skillpower = 1400, spArgs1 = '284.76', spArgs2 = '4921', spArgs3 = '100', },
		[29] = {needCoin = 260000, needItemID = 67277, needItemNum = 30, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.8584, arg2 = 5108.0, }, status = {{odds = 10000, buffID = 786, }, }, }, },skillpower = 1450, spArgs1 = '285.84', spArgs2 = '5108', spArgs3 = '100', },
		[30] = {needCoin = 270000, needItemID = 67277, needItemNum = 30, cool = 45000, events = {{triTime = 350, damage = {odds = 10000, arg1 = 2.8692, arg2 = 5297.0, }, status = {{odds = 10000, buffID = 786, }, }, }, },skillpower = 1500, spArgs1 = '286.92', spArgs2 = '5297', spArgs3 = '100', },
	},

};
function get_db_table()
	return level;
end
