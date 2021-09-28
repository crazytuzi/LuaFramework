----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[18016] = {	pos = { x = -106.8683, y = 5.183387, z = -69.66728 }, mapid = 8888},
	[18014] = {	pos = { x = -56.0061, y = 17.81494, z = 94.11829 }, mapid = 8888},
	[18015] = {	pos = { x = -66.896, y = 10.18339, z = -83.44202 }, mapid = 8888},
	[18001] = {	pos = { x = -59.86765, y = 17.76959, z = 95.43091 }, mapid = 8888},
	[18018] = {	pos = { x = -9.999819, y = 16.18339, z = 99.53949 }, mapid = 8888},
	[18020] = {	pos = { x = -77.00102, y = 17.58339, z = 81.82337 }, mapid = 8888},
	[18022] = {	pos = { x = 179.8541, y = 26.18894, z = 83.17757 }, mapid = 10},
	[18023] = {	pos = { x = 29.91885, y = 2.183387, z = -64.3631 }, mapid = 8888},
	[18024] = {	pos = { x = 37.57312, y = 2.183387, z = -83.09081 }, mapid = 8888},
	[18025] = {	pos = { x = -90.92169, y = 17.58339, z = 93.50673 }, mapid = 8888},

};
function get_db_table()
	return map;
end
