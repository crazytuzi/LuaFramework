----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[304001] = {pos = { x = -101.384773, y = 17.3685169, z = 109.741043 }, mapid = 94001},
	[304002] = {pos = { x = -149.22, y = 4.11368465, z = -85.03379 }, mapid = 94002},
	[304004] = {pos = { x = 75.4961243, y = 3.927905, z = 87.2176056 }, mapid = 94004},
	[304009] = {pos = { x = -89.01487, y = 11.1872864, z = 101.473572 }, mapid = 94009},
	[304010] = {pos = { x = -29.2726631, y = 9.187286, z = 124.75647 }, mapid = 94010},
	[304013] = {pos = { x = 4.536003, y = 6.18727875, z = -16.1728439 }, mapid = 94013},
	[304014] = {pos = { x = 26.3724747, y = 1.18727875, z = -68.23922 }, mapid = 94014},
	[304015] = {pos = { x = -102.916733, y = 8.187279, z = -14.916317 }, mapid = 94015},
	[304016] = {pos = { x = -57.39499, y = 8.187279, z = 50.6538773 }, mapid = 94016},
	[304018] = {pos = { x = -60.01852, y = -1.46601737, z = -178.907623 }, mapid = 94018},
	[304019] = {pos = { x = -60.31963, y = 0.0820236, z = -118.124847 }, mapid = 94019},
	[304020] = {pos = { x = 38.36272, y = 17.0820236, z = 81.25824 }, mapid = 94020},
	[304021] = {pos = { x = -44.0183334, y = 17.0820236, z = 62.755455 }, mapid = 94021},
	[304022] = {pos = { x = 15.9568892, y = 17.0820236, z = 162.8648 }, mapid = 94022},
	[304024] = {pos = { x = 52.4970627, y = 10.0820236, z = -56.55552 }, mapid = 94024},
	[304025] = {pos = { x = 8.921643, y = 11.2608643, z = 99.64482 }, mapid = 94025},
	[304026] = {pos = { x = 122.907043, y = 0.6628423, z = 58.7301064 }, mapid = 94026},
	[304027] = {pos = { x = 171.037537, y = -6.339142, z = -93.57309 }, mapid = 94027},
	[304028] = {pos = { x = 151.352112, y = 0.6608609, z = 35.2247467 }, mapid = 94028},
	[304030] = {pos = { x = -15.8990812, y = -2.94951344, z = -40.3167458 }, mapid = 94030},
	[304031] = {pos = { x = -19.9585075, y = 12.6608582, z = 23.0378265 }, mapid = 94031},
	[304032] = {pos = { x = 46.04559, y = -7.777195, z = -62.4948235 }, mapid = 94032},
	[304033] = {pos = { x = -116.579582, y = 5.25521564, z = -48.3611145 }, mapid = 94033},
	[304034] = {pos = { x = -91.3236542, y = 15.1046066, z = -147.07724 }, mapid = 94034},
	[304036] = {pos = { x = 106.189758, y = 0.1046066, z = -169.65329 }, mapid = 94036},
	[304037] = {pos = { x = 86.44093, y = 10.3715572, z = -54.47197 }, mapid = 94037},
	[304038] = {pos = { x = 124.89357, y = 30.1046085, z = 98.57005 }, mapid = 94038},
	[304040] = {pos = { x = 27.1074142, y = 10.1620245, z = -7.597122 }, mapid = 94040},
	[304005] = {pos = { x = 11.5344086, y = 3.155068, z = 72.1788 }, mapid = 94005},
	[304006] = {pos = { x = 39.4236946, y = -9.234032, z = -36.7133331 }, mapid = 94006},
	[304007] = {pos = { x = -55.9162064, y = 4.076365, z = -163.682816 }, mapid = 94007},
	[304011] = {pos = { x = 33.68907, y = 9.187286, z = 81.6028442 }, mapid = 94011},
	[304012] = {pos = { x = 67.9577942, y = 7.18727827, z = 61.005928 }, mapid = 94012},
	[304023] = {pos = { x = 55.0579758, y = 12.0820236, z = 23.2015781 }, mapid = 94023},
	[304029] = {pos = { x = -37.69867, y = -3.79388952, z = -113.214134 }, mapid = 94029},
	[304035] = {pos = { x = 10.9876709, y = 5.19361, z = -125.748131 }, mapid = 94035},
	[304039] = {pos = { x = -33.625145, y = 2.23323464, z = 133.538513 }, mapid = 94039},
	[304003] = {pos = { x = 71.27869, y = 3.16384315, z = -135.027924 }, mapid = 94003},
	[304008] = {pos = { x = -99.59375, y = 3.16384315, z = 20.4592152 }, mapid = 94008},
	[304017] = {pos = { x = 112.2015, y = 12.0820236, z = -13.863019 }, mapid = 94017},

};
function get_db_table()
	return map;
end
