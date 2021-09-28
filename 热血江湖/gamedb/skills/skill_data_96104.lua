----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[96104] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130003, }, }, }, },spArgs1 = '20.0', },
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130011, }, }, }, },spArgs1 = '25.0', },
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130012, }, }, }, },spArgs1 = '30.0', },
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130013, }, }, }, },spArgs1 = '35.0', },
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130014, }, }, }, },spArgs1 = '40.0', },
		[6] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130015, }, }, }, },spArgs1 = '45.0', },
		[7] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130016, }, }, }, },spArgs1 = '50.0', },
		[8] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130017, }, }, }, },spArgs1 = '55.0', },
		[9] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130018, }, }, }, },spArgs1 = '60.0', },
		[10] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130019, }, }, }, },spArgs1 = '65.0', },
		[11] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130020, }, }, }, },spArgs1 = '70.0', },
		[12] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130021, }, }, }, },spArgs1 = '75.0', },
		[13] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130022, }, }, }, },spArgs1 = '80.0', },
		[14] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130023, }, }, }, },spArgs1 = '90.0', },
		[15] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 130024, }, }, }, },spArgs1 = '100.0', },
	},

};
function get_db_table()
	return level;
end
