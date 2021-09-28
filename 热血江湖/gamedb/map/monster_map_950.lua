----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[190001] = {pos = { x = -76.4419556, y = 8.539909, z = 40.9089546 }, mapid = 80001},
	[190002] = {pos = { x = -103.709267, y = 8.539909, z = 40.1916237 }, mapid = 80001},
	[190009] = {pos = { x = -172.544144, y = 23.93991, z = 150.617981 }, mapid = 80001},
	[190001] = {pos = { x = 191.114166, y = 16.73991, z = -84.45013 }, mapid = 80001},
	[190003] = {pos = { x = 163.062256, y = 16.40939, z = 4.22384453 }, mapid = 80001},
	[190006] = {pos = { x = -93.09954, y = 12.3399086, z = -54.4596367 }, mapid = 80001},
	[190004] = {pos = { x = 89.18335, y = 8.040343, z = 202.344391 }, mapid = 80001},
	[190005] = {pos = { x = -129.776917, y = 27.5293732, z = 152.974915 }, mapid = -1},
	[190029] = {pos = { x = -76.4419556, y = 8.539909, z = 40.9089546 }, mapid = 80003},
	[190030] = {pos = { x = -103.709267, y = 8.539909, z = 40.1916237 }, mapid = 80003},
	[190031] = {pos = { x = -80.14921, y = 12.1953983, z = 79.3475647 }, mapid = 80003},
	[190032] = {pos = { x = -10.6428528, y = 12.3955965, z = 7.51626062 }, mapid = 80003},
	[190037] = {pos = { x = -172.544144, y = 23.93991, z = 150.617981 }, mapid = 80003},
	[190033] = {pos = { x = 90.81471, y = 1.56372154, z = -168.455856 }, mapid = 80003},
	[190034] = {pos = { x = 30.3610916, y = 5.33991051, z = -167.010727 }, mapid = 80003},
	[190035] = {pos = { x = -170.060333, y = 12.73991, z = -63.80796 }, mapid = 80003},
	[190036] = {pos = { x = -91.43301, y = 12.3399086, z = -54.5015869 }, mapid = 80004},
	[190038] = {pos = { x = 191.114166, y = 16.73991, z = -84.45013 }, mapid = 80004},
	[190057] = {pos = { x = -76.4419556, y = 8.539909, z = 40.9089546 }, mapid = 80005},
	[190058] = {pos = { x = -103.709267, y = 8.539909, z = 40.1916237 }, mapid = 80005},
	[190059] = {pos = { x = -80.14921, y = 12.1953983, z = 79.3475647 }, mapid = 80005},
	[190060] = {pos = { x = -10.6428528, y = 12.3955965, z = 7.51626062 }, mapid = 80005},
	[190065] = {pos = { x = -172.544144, y = 23.93991, z = 150.617981 }, mapid = 80005},
	[190061] = {pos = { x = 90.81471, y = 1.56372154, z = -168.455856 }, mapid = 80005},
	[190062] = {pos = { x = 30.3610916, y = 5.33991051, z = -167.010727 }, mapid = 80005},
	[190063] = {pos = { x = -170.060333, y = 12.73991, z = -63.80796 }, mapid = 80005},
	[190066] = {pos = { x = 191.114166, y = 16.73991, z = -84.45013 }, mapid = 80006},
	[190086] = {pos = { x = -103.709267, y = 8.539909, z = 40.1916237 }, mapid = 80007},
	[190087] = {pos = { x = -80.14921, y = 12.1953983, z = 79.3475647 }, mapid = 80007},
	[190088] = {pos = { x = -10.6428528, y = 12.3955965, z = 7.51626062 }, mapid = 80007},
	[190085] = {pos = { x = 38.7898636, y = 4.139908, z = 161.503677 }, mapid = 80007},
	[190093] = {pos = { x = -172.544144, y = 23.93991, z = 150.617981 }, mapid = 80007},
	[190089] = {pos = { x = 90.81471, y = 1.56372154, z = -168.455856 }, mapid = 80007},
	[190090] = {pos = { x = 30.3610916, y = 5.33991051, z = -167.010727 }, mapid = 80007},
	[190091] = {pos = { x = -170.060333, y = 12.73991, z = -63.80796 }, mapid = 80007},
	[190092] = {pos = { x = -91.43301, y = 12.3399086, z = -54.5015869 }, mapid = 80008},
	[190094] = {pos = { x = 191.114166, y = 16.73991, z = -84.45013 }, mapid = 80008},
	[190113] = {pos = { x = -76.4419556, y = 8.539909, z = 40.9089546 }, mapid = 80009},
	[190114] = {pos = { x = -103.709267, y = 8.539909, z = 40.1916237 }, mapid = 80009},
	[190115] = {pos = { x = -80.14921, y = 12.1953983, z = 79.3475647 }, mapid = 80009},
	[190116] = {pos = { x = -10.6428528, y = 12.3955965, z = 7.51626062 }, mapid = 80009},
	[190121] = {pos = { x = -172.544144, y = 23.93991, z = 150.617981 }, mapid = 80009},
	[190117] = {pos = { x = 90.81471, y = 1.56372154, z = -168.455856 }, mapid = 80009},
	[190118] = {pos = { x = 30.3610916, y = 5.33991051, z = -167.010727 }, mapid = 80009},
	[190119] = {pos = { x = -170.060333, y = 12.73991, z = -63.80796 }, mapid = 80009},
	[190120] = {pos = { x = -91.43301, y = 12.3399086, z = -54.5015869 }, mapid = 80010},
	[190122] = {pos = { x = 191.114166, y = 16.73991, z = -84.45013 }, mapid = 80010},
	[190008] = {pos = { x = -91.43301, y = 12.3399086, z = -54.5015869 }, mapid = 80002},
	[190010] = {pos = { x = 191.114166, y = 16.73991, z = -84.45013 }, mapid = 80002},
	[190007] = {pos = { x = -170.060333, y = 12.73991, z = -63.80796 }, mapid = 80001},

};
function get_db_table()
	return map;
end
