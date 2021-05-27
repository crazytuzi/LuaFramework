
PkConfig =
{
subPk = 1,
matchTime = 1,
addHp = 0.2,
yellowName = 100,
redName = 200,
canPkStartLevel = 60,
canPkEndLevel = 60,
pkValue = 50,
nameColorClearTime = 30,
nSceenId = 3,
nEnterRange = {98,72,2,2},
nExitRange = {98,84,2,2},
redNameRelive =
{
	nSceneId = 3,
	x = 92,
	y = 75,
},
redNameWLZBRelive =
{
	nSceneId = 3,
	x = 91,
	y = 73,
},
ybClear =
{
	yb = 10,
	pkValue = 100,
},
coinClear =
{
	ncoin = 1000000,
	pkValue = 100,
},
coinClearRedOneTimes = 10000,
param1 = 40,
param2 = 20000,
pkParam =
{
pkMax = 1000,
pkBase = 20,
otherParam = {
enemyZY = 0,
neutralZY = 0.75,
sameZY = 1,
sameGuild = 1.2,
friend = 1.2,
brother = 1.5,
marry = 1.5,
master = 2,
},
otherPk = {
{ start = 0, theEnd= 59, value = 1},
{ start = 60, theEnd = 99, value = 0.8},
{ start = 100, theEnd = 299, value = 0.6},
{ start = 300, theEnd = 1001, value = 0},
},
},
zhanHunGetParam =
{
killLevel = 60,
killInterval = 1800,
levelStart = 60,
levelBase = {80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,112,114,116,118,120,122,124,126,128,130,132,134,136,138,140,142,144,146,148,150,152,154,156,158,160,162,164,166,168,170,172,174,176,178,180},
otherParam = {
enemyZY = 1,
neutralZY = 1,
sameZY = 0,
},
otherPk = {
{ start = 0, theEnd = 59, value = 1},
{ start = 60, theEnd = 99, value = 1},
{ start = 100, theEnd = 299, value = 1},
{ start = 300, theEnd = 1000, value = 1},
},
levelGap = {
{ start = -500, theEnd = 5, value = 1},
{ start = 6, theEnd = 10, value = 0.5},
{ start = 11, theEnd = 500, value = 0.0},
}
},
zhanHunDropParam =
{
killLevel = 60,
limitZhanHun = 0,
levelStart = 60,
levelBase = {80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,112,114,116,118,120,122,124,126,128,130,132,134,136,138,140,142,144,146,148,150,152,154,156,158,160,162,164,166,168,170,172,174,176,178,180},
otherParam = {
enemyZY = 1,
neutralZY = 1,
sameZY = 0,
},
otherPk = {
{ start = 0, theEnd = 59, value = 1},
{ start = 60, theEnd = 99, value = 1},
{ start = 100, theEnd = 299, value = 1},
{ start = 300, theEnd = 1000, value = 1},
},
levelGap = {
{ start = -500, theEnd = 5, value = 1},
{ start = 6, theEnd = 10, value = 0.5},
{ start = 11, theEnd = 500, value = 0.0},
}
},
pkExpParam =
{
limitDropCount = 10,
levelStart = 60,
dropPercent = {50,50,50,50,50,100,100,100,100,100,100},
levelBase = {1364876,1812076,2296635,2820183,3384383,3990931,4641560,5338033,6082150,6875744,7720682,},
limitNum = 0,
limitGetCount = 10,
killInterval = 1800,
noticeLimitExp = 0,
killerLevel = 60,
levelRate = {0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,},
limitExp = {484512,696005,924929,1171811,1437175,1721543,2025439,2349383,2693898,3059505,3639669,4832202,6124361,7520488,9025021,10642483,12377492,14234754,16219066,18335317,20588484,},
otherParam = {
enemyZY = 1,
neutralZY = 1,
sameZY = 0,
},
otherPk = {
{ start = 0, theEnd = 59, value = 1},
{ start = 60, theEnd = 99, value = 1},
{ start = 100, theEnd = 299, value = 1},
{ start = 300, theEnd = 1000, value = 1},
},
levelGap = {
{ start = -500, theEnd = 10, value = 1.0},
{ start = 11, theEnd = 500, value = 0.0},
}
},
}
ClearRedNameCoinMax = 3000000;