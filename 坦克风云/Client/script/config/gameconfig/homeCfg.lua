homeCfg=
{
	--每个地块预设的建筑类型

--指挥中心等级与解锁的地块关系
pIndexArrayByLevel={[1]={1,8,9,10,11,14,15,16,17,18,19,20,101,102,103,104,105,106,107,108,109,52},[2]={21},[3]={2},[4]={22},[5]={3,7},[6]={4,23},[7]={6},[8]={24},[10]={46,25},[11]={5},[12]={26},[13]={12,13},[14]={27},[16]={28},[18]={29},[20]={47,30},[22]={31},[24]={32},[26]={33},[28]={34},[30]={48,35},[32]={36},[34]={37},[36]={38},[38]={39},[40]={49,40},[42]={41},[44]={42},[46]={43},[48]={44},[50]={50},[60]={51},},

	buildingUnlock=
	{

		[1]={bid=1,type=7,pos={1238,915},posv2={1228,961}}, --指挥中心
		[2]={bid=2,type=5,pos={1751,931},},
		[3]={bid=3,type=8,pos={1140,605},},
		[4]={bid=4,type=10,pos={1392,1098},posv2={1403,1086.5}}, --仓库
		[5]={bid=5,type=10,pos={1545,1022},posv2={1555,1012.5}},
		[6]={bid=6,type=9,pos={1891,855},posv2={1895,864.5}}, --装置车间
		[7]={bid=7,type=15,pos={814,785},},
		[8]={bid=8,type=11,pos={1910,1026},posv2={1913.5,1022}}, --异星科技
		[9]={bid=9,type=12,pos={1730,1130},posv2={1722.5,1118}}, --军事学院
		[10]={bid=10,type=13,pos={2315,683},},
		[11]={bid=11,type=6,pos={1660,351},},
		[12]={bid=12,type=6,pos={1842,443},},
		[13]={bid=13,type=14,pos={2019,534},},
		[14]={bid=14,type=16,pos={1481,799},posv2={1473,787.5}}, --作战中心
		[15]={bid=15,type=17,pos={2488.5,758.5},},
		[16]={bid=16,type={1,2,3},pos={215,750},},--左上
		[17]={bid=17,type={1,2,3},pos={314,802},},
		[18]={bid=18,type={1,2,3},pos={204,635},},
		[19]={bid=19,type={1,2,3},pos={307,683},},
		[20]={bid=20,type={1,2,3},pos={410,736},},
		[21]={bid=21,type={1,2,3},pos={379,611},},
		[22]={bid=22,type={1,2,3},pos={481,663},},
		[23]={bid=23,type={1,2,3},pos={559,835},},--右上
		[24]={bid=24,type={1,2,3},pos={655,785},},
		[25]={bid=25,type={1,2,3},pos={732,850},},
		[26]={bid=26,type={1,2,3},pos={282,449},},--左中
		[27]={bid=27,type={1,2,3},pos={385,501},},
		[28]={bid=28,type={1,2,3},pos={489,550},},
		[29]={bid=29,type={1,2,3},pos={383,398},},
		[30]={bid=30,type={1,2,3},pos={484,449},},
		[31]={bid=31,type={1,2,3},pos={583,500},},
		[32]={bid=32,type={1,2,3},pos={463,333},},
		[33]={bid=33,type={1,2,3},pos={567,385},},
		[34]={bid=34,type={1,2,3},pos={845,422},},--右中2
		[35]={bid=35,type={1,2,3},pos={940,370},},
		[36]={bid=36,type={1,2,3},pos={761,645},},--右中1
		[37]={bid=37,type={1,2,3},pos={865,699},},
		[38]={bid=38,type={1,2,3},pos={856,591},},
		[39]={bid=39,type={1,2,3},pos={960,644},},
		[40]={bid=40,type={1,2,3},pos={185,264},},--左下
		[41]={bid=41,type={1,2,3},pos={77,101},},
		[42]={bid=42,type={1,2,3},pos={176,156},},
		[43]={bid=43,type={1,2,3},pos={282,207},},
		[44]={bid=44,type={1,2,3},pos={382,154},},
		[45]={bid=45,type={1,2,3},pos={1244,844},},--无用地块？
		[46]={bid=46,type=4,pos={572,154},},--钛矿--右下
		[47]={bid=47,type=4,pos={671,203},},
		[48]={bid=48,type=4,pos={772,252},},
		[49]={bid=49,type=4,pos={769,155},},
		[50]={bid=50,type=4,pos={867,203},},
		[51]={bid=51,type=4,pos={965,151},},
		[52]={bid=52,type=18,pos={2338,1113.5}}, --飞艇
		[101]={bid=101,type=101,pos={1558,1160},},
		[102]={bid=102,type=102,pos={2060,933},},
		[103]={bid=103,type=103,pos={550,892},},
		[104]={bid=104,type=104,pos= {1100,1120},posv2={1087.5,1145}},--{1275,1190},}, 军徽建筑
		[105]={bid=105,type=105,pos={1250,1200},posv2={1275,1239.5}}, --装甲矩阵
		[106]={bid=106,type=106,pos={283.5,775.5},}, --空中打击
		[107]={bid=107,type=107,pos={770,1020},posv2={789,1044.5}}, --战争塑像
		[108]={bid=108,type=108,pos={550,642},}, --AI部队
		[109]={bid=109,type=109,pos={896,490},}, --战略中心
		
	},

	--新增地板图片位置(上面有军徽和装甲矩阵)
	newFloorPos={1253,1217},
	homeFloorCfg={
		{pos={1253,1217},pic="portModifyFloor.png",zorder=1},
		{pos={1006,1135},pic="portModifyFloor2.png",zorder=2,scale=1.4482},
		{pos={1112,1062},pic="portModifyFloor3.png",scale=1.4482},
		{pos={1085,1035},pic="homeCar.png",scale=1.4482},
		{pos={1200,1050},pic="varia.png",zorder=2,scale=1.4482},
	},
mainModelCfg={--2745,1483
	{m_tree1={2694,1447}},
	{m_tree2={2545,1373}},
	{m_tree3={2333,1273}},
	-- {m_baseBuild1={2251,1192}},
	{m_baseBuild2={1644,679}},
	{m_baseBuild3={502,1255}},
	{m_signpost={90,190}},
	{m_billboard={1811,1015}},
	{m_billboard={1665,943}},
	{m_streetLight={719,1118}},
	{m_streetLight={920,1016}},
	{rightDoor={1944,1128}},
	{rightDoor2={1944,1128}},
	{leftDoor={339,385}},
	-- {unknowBuilding={555,615}},
	-- {unknowBuilding={914,437}},
	{m_buildblock={905,437.5}},
	{m_baseFrame={1134,905}},
	{ironFrame={693,1182}},
	{m_rPillar={613,1245}},
	-- {greenStation={1630,926}},
	{m_buildblock={577,629}},
	{m_airshipblock={2177,1195}},
},
--可以建造和升级的建筑的数量
canBuildNumber=44,

buildingUnDisplay={	
	[1]={1,0},	--建筑 1级可建造  指挥中心
	[2]={0,0},	--建筑 3级可建造  水晶工厂	
	[3]={0,0},	--建筑 5级可建造  科研中心		
	[4]={0,0},	--建筑 6级可建造  第一个仓库	
	[5]={10,0},	--建筑11级可建造  第两个仓库	
	[6]={5,0},	--建筑 7级可建造  装置车间	
	[7]={0,0},	--建筑 5级可建造  军团建筑
	[8]={0,22},	--角色22级可开启  异星科技研究中心
	[9]={0,0},	--角色 0级可开启  军事学院
	[10]={0,22},	--角色22级可开启  异星科技改造车间
	[11]={0,0},	--建筑 1级可建造  第一个坦克工厂	
	[12]={11,0},	--建筑13级可建造  第二个坦克工厂	
	[13]={11,0},	--建筑13级可建造  坦克改装工厂	
	[14]={0,10},	--作战中心 10级	
	[15]={0,0},	--地下车库
	[101]={0,8},	--角色 8级可开启 配件工厂
	[102]={0,24},	--角色 25级可开启 武器研发中心
	[103]={0,24},	--天梯建筑
	[104]={0,29},	--军徽建筑
	[105]={0,3},	--装甲矩阵建筑
	[106]={0,50},	--空中打击建筑
	[107]={0,30},	--战争塑像
	[108]={0,60},	--AI部队
	[109]={0,60},	--战略中心
	[52]={0,70}, --飞艇
},

--每个地块预设的建筑类型
indexForBuildType="7,5,8,10,10,9,15,11,12,13,6,6,14,16,17,1:2:3,1:2:3,1:2:3,1:2:3,1:2:3,1:2:3,1:2:3,1:2:3,1:2:3,1:2:3,4,4,4,4,4,4",


scoutConsume="20,40,92,136,192,252,324,408,504,608,724,850,1000,1150,1320,1510,1710,1930,2160,2420,2690,2980,3280,3610,3960,4330,4720,5130,5570,6020,6510,7020,7550,8100,8700,9300,9900,10600,11300,12000,12800,13600,14400,15200,16100,17000,18000,19000,20000,21000,22100,23300,24400,25600,26900,28100,29500,30800,32200,33700,35300,37000,38800,40600,42500,44500,46600,48800,51100,53500,56000,58600,61300,64200,67200,70300,73600,77000,80600,84400,88300,92400,96700,101200,106000,111000,117000,123000,129000,135000",

--每个地块在地图上的位置 新版
indexForBuildPositionNew="663:1000,1378:1054,596:733,769:1218,1038:1219,1134:1042,235:904,200:517,550:556,1000:789,838:431,1038:532,1239:631,900:871,250:600,415:816,222:718,632:815,523:761,328:663,220:610,116:556,921:858,738:761,632:705,435:608,330:555,223:501,1284:612,1177:555,1063:500,824:398,716:342,1147:237,1040:181,1391:553,1286:501,1176:447,932:342,824:288,1035:804,1254:299,1040:291,934:237,1144:859,428:203,540:258,538:150,646:203,758:148",

tankPosition={
    [10001]={ sid="10001",homex=1594+703.12+80,homey=654-114.77+40},--"轻型坦克",
    [10002]={ sid="10002",homex=1430+703.12,homey=570-114.77},--"中型坦克",
	[10003]={ sid="10003",homex=1266+703.12,homey=486-114.77},--"重型坦克"
	[10004]={ sid="10004",homex=1092+703.12+10,homey=405-114.77-5},--"豹式坦克",
	[10005]={ sid="10005",homex=780+703.12-10,homey=399-114.77+10},--"天启坦克",

	[10011]={ sid="10011",homex=1509+703.12+172+80,homey=535-114.77+87+40},--"轻型#jianjiche#",
	[10012]={ sid="10012",homex=1509+703.12-10,homey=535-114.77-5},--"中型#jianjiche#",
	[10013]={ sid="10013",homex=1337+703.12,homey=448-114.77},--"重型#jianjiche#",
	[10014]={ sid="10014",homex=1170+703.12,homey=364-114.77},--"追猎者#jianjiche#",
	[10015]={ sid="10015",homex=848+703.12-5,homey=360-114.77+3},--"猛虎#jianjiche#",

	[10021]={ sid="10021",homex=1571+703.12+169+80,homey=485-114.77+80+40},--轻型#zixinghuopao#
	[10022]={ sid="10022",homex=1571+703.12+6,homey=485-114.77+3},--中型#zixinghuopao#
	[10023]={ sid="10023",homex=1402+703.12+10,homey=405-114.77+5},--重型#zixinghuopao#
	[10024]={ sid="10024",homex=1252+703.12-15,homey=328-114.77-8},--野蜂#zixinghuopao#
	[10025]={ sid="10025",homex=915+703.12+6,homey=311-114.77-3},--黑豹#zixinghuopao#

	[10031]={ sid="10031",homex=1656+703.12+173+80,homey=455-114.77+77+40},--"轻型#huojianche#",
	[10032]={ sid="10032",homex=1656+703.12,homey=455-114.77},--"中型#huojianche#",
	[10033]={ sid="10033",homex=1483+703.12+6,homey=378-114.77},--"重型#huojianche#",
	[10034]={ sid="10034",homex=1325+703.12+6,homey=293-114.77-5},--"冰雹#huojianche#",
	[10035]={ sid="10035",homex=1013+703.12-10,homey=276-114.77-5},--"尖啸者#huojianche#",

    }
}

-- function homeCfg:initPos()
-- 	local tb = {[14]=3,[3]=14,[8]=9,[9]=8,[106]=107,[107]=106,[108]=103,[103]=108,[104]=105,[105]=104}
-- 	for k,v in pairs(tb) do
-- 		print("["..k.."]={"..self.buildingUnlock[v]["pos"][1]..","..self.buildingUnlock[v]["pos"][2].."},")
-- 	end
-- end

--提审服部分建筑坐标调整配置
buildingApplyUnlock={
	[3]={1481-15,799}, --科研中心
	[8]={1730-10,1130-15}, --异星科技研究中心
	[9]={1910+10,1026+12}, --军事学院
	[14]={1140+10,605+5}, --作战中心
	[103]={550,642}, --天梯建筑
	[104]={1250+14,1200+1}, --军徽建筑
	[105]={1100-15,1120}, --装甲矩阵建筑
	[106]={770-30,1020-10}, --空中打击建筑
	[107]={283.5+30,775.5+10}, --战争塑像
	[108]={550,892}, --AI部队
}

function homeCfg:getBuildingPosById(id)
	if G_isApplyVersion()==true then --提审服某些建筑位置调换一下
		if buildingApplyUnlock[id] then
			return buildingApplyUnlock[id][1],buildingApplyUnlock[id][2]
		end
	end
	local _posX, _posY = self.buildingUnlock[id]["pos"][1], self.buildingUnlock[id]["pos"][2]
    if id >= 16 and id ~= 109 and id ~= 52 then
        _posX = _posX + 10
        _posY = _posY + 15
    end
	if G_getGameUIVer() == 2 then
		if self.buildingUnlock[id]["posv2"] then
			_posX, _posY = self.buildingUnlock[id]["posv2"][1], self.buildingUnlock[id]["posv2"][2]
		end
		if id == 1 then --基地建筑坐标
			local skinId = buildDecorateVoApi:getNowUse()
			if skinId and (skinId == "b11" or skinId == "b12") then
				_posX, _posY = self.buildingUnlock[id]["pos"][1], self.buildingUnlock[id]["pos"][2]
			end
		end
	end
	return _posX, _posY
end

-- 获取奖杯的坐标
function homeCfg:getChampionBuildingPos()
	return 1644,679
end

function homeCfg:getBuildingScale(bid, btype)
   	local scale = 1
    if buildingCfg[btype] then
      	scale = buildingCfg[btype].buildScale or 1
    end
    if G_getGameUIVer() == 2 and self.buildingUnlock[bid] and self.buildingUnlock[bid]["posv2"] then
		scale = 1
    end
    return scale
end
