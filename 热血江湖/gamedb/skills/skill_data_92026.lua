----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[92026] = {
		[1] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 50, spArgs1 = '196.8', spArgs2 = '1116', spArgs3 = '25', },
		[2] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 100, spArgs1 = '200.4', spArgs2 = '1215', spArgs3 = '30', },
		[3] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 150, spArgs1 = '204', spArgs2 = '1317', spArgs3 = '35', },
		[4] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 200, spArgs1 = '207.6', spArgs2 = '1422', spArgs3 = '40', },
		[5] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 250, spArgs1 = '211.2', spArgs2 = '1531', spArgs3 = '45', },
		[6] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 300, spArgs1 = '214.8', spArgs2 = '1643', spArgs3 = '50', },
		[7] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 350, spArgs1 = '218.4', spArgs2 = '1758', spArgs3 = '55', },
		[8] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 400, spArgs1 = '222', spArgs2 = '1876', spArgs3 = '60', },
		[9] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 450, spArgs1 = '225.6', spArgs2 = '1997', spArgs3 = '65', },
		[10] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 500, spArgs1 = '229.2', spArgs2 = '2122', spArgs3 = '70', },
		[11] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 550, spArgs1 = '232.8', spArgs2 = '2250', spArgs3 = '75', },
		[12] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 600, spArgs1 = '236.4', spArgs2 = '2381', spArgs3 = '80', },
		[13] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 650, spArgs1 = '240', spArgs2 = '2516', spArgs3 = '85', },
		[14] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 700, spArgs1 = '243.6', spArgs2 = '2653', spArgs3 = '90', },
		[15] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 750, spArgs1 = '247.2', spArgs2 = '2794', spArgs3 = '95', },
		[16] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 800, spArgs1 = '250.8', spArgs2 = '2939', spArgs3 = '100', },
		[17] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 850, spArgs1 = '254.4', spArgs2 = '3086', spArgs3 = '100', },
		[18] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 900, spArgs1 = '258', spArgs2 = '3237', spArgs3 = '100', },
		[19] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 950, spArgs1 = '261.6', spArgs2 = '3390', spArgs3 = '100', },
		[20] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 1000, spArgs1 = '265.2', spArgs2 = '3548', spArgs3 = '100', },
		[21] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 1050, spArgs1 = '268.8', spArgs2 = '3708', spArgs3 = '100', },
		[22] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 1100, spArgs1 = '272.4', spArgs2 = '3872', spArgs3 = '100', },
		[23] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 1150, spArgs1 = '276', spArgs2 = '4038', spArgs3 = '100', },
		[24] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 1200, spArgs1 = '279.6', spArgs2 = '4209', spArgs3 = '100', },
		[25] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 1250, spArgs1 = '281.52', spArgs2 = '4382', spArgs3 = '100', },
		[26] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 1300, spArgs1 = '282.6', spArgs2 = '4559', spArgs3 = '100', },
		[27] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 1350, spArgs1 = '283.68', spArgs2 = '4738', spArgs3 = '100', },
		[28] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 1400, spArgs1 = '284.76', spArgs2 = '4921', spArgs3 = '100', },
		[29] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 1450, spArgs1 = '285.84', spArgs2 = '5108', spArgs3 = '100', },
		[30] = {events = {{triTime = 100, status = {{buffID = 788, }, {buffID = 787, }, }, }, },skillpower = 1500, spArgs1 = '286.92', spArgs2 = '5297', spArgs3 = '100', },
	},

};
function get_db_table()
	return level;
end
