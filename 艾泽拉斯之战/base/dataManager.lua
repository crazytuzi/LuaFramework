
dataManager = {}

local playerData_Class = include("playerData")
local kingMagic_Class =include("magicData")
local goldMineData_Class = include("goldMineData")
local lumberMillData_Class =include("lumberMillData")
local mainBaseData = include("mainBaseData");
local magicTowerData = include("magicTowerData");
local bagData_Class = include("bagData");
local shopData_Class = include("shopData");
local pvpData_Class = include("pvpData");
local hurtRankData_Class = include("hurtRankData");
local purchaseData_Class = include("purchaseData");
local buddyData_Class = include("buddyData");
 
local mailData_Class = include("mailData")
local instanceZones_Class = include("instanceZonesData") 
local redEnvelopeData_Class = include("redEnvelopeData") 


include("shipData");
include("cardData");
include("chatData");
include("moneyFlyManager");
include("loginData")
include("idolBuildData")
include("miracleData")
include("vipGiftData")
include("guildListData")
include("guildData")
include("guildWarData")
include("transactionData")

BUILD = 
{
	BUILD_INVALID = -1,
	BUILD_MAIN_BASE = 0,
	BUILD_GOLD_MINE = 1,
	BUILD_LUMBER_MILL = 2,
	BUILD_MAGIC_TOWER = 3,
 
};

dataManager.serverBeginTime = 0;

function dataManager.setServerBeginTime(serverBeginTime)
	dataManager.serverBeginTime = serverBeginTime;
end	

-- 这个时间是开服当天0点的时间 九 零 一 起 玩 ww w .9 0 1 7 5. com
function dataManager.getServerBeginTime()
	return dataManager.serverBeginTime;
end

dataManager.serveropenday = 0
function dataManager.setServerOpenDay(serverDays)
	dataManager.serveropenday = serverDays
end	

function dataManager.getServerOpenDay()
	return dataManager.serveropenday 
end	

function dataManager.setServerTime(t, timezone)
	if(type(t) == "userdata")then
		dataManager.serverTime = t:GetUInt()
		print(" dataManager.serverTime "..dataManager.serverTime);
	else
		dataManager.serverTime = t	
	 
	end	
	
	dataManager.timezone = timezone or -8;
	
	dataManager.currentTick = 0;
	dataManager.startTick = true;
	
	dataManager.beginTick = os.time()

	local h, m, s, y, m, d = dataManager.getLocalTime();
	print("h "..h);
	print("m "..m);
	print("s "..s);
    print("y "..y);
    print("m "..m);
    print("d "..d);
	
end
function dataManager.getServerTime() -- s
 
	--local res = dataManager.serverTime + dataManager.currentTick;
	
	local now =  os.time()
	dataManager.serverTime = dataManager.serverTime + (now - dataManager.beginTick)
	dataManager.beginTick  = now;	
	local res = dataManager.serverTime
 
	return res
end

function dataManager.getLocalTime()
	local serverTime = dataManager.getServerTime();
    -- server time add time Zome get GMT
    local tempServerTime = serverTime - dataManager.timezone * 60 * 60;
    -- get Data from GMT is server Data.
	local timeTable = os.date("!*t", tempServerTime);
	
	local hour = timeTable.hour;
	local minute = timeTable.min;
	local second = timeTable.sec;
	
	local year = timeTable.year;
	local month = timeTable.month;
	local day = timeTable.day;
	
	return hour, minute, second, year, month, day;
end

dataManager.setServerTime(os.time())

dataManager.playerData  = playerData_Class.new()

dataManager.battleKing ={}
dataManager.battleKing[enum.FORCE.FORCE_ATTACK] = playerData_Class.new()
dataManager.battleKing[enum.FORCE.FORCE_GUARD] = playerData_Class.new()
  

dataManager.kingMagic  = kingMagic_Class.new()
dataManager.kingMagic:init();
dataManager.bagData = bagData_Class.new()
dataManager.shopData = shopData_Class.new()
dataManager.pvpData = pvpData_Class.new()
dataManager.hurtRankData = hurtRankData_Class.new()

dataManager.mailData  = mailData_Class.new()
dataManager.instanceZonesData  = instanceZones_Class.new()
dataManager.instanceZonesData:init()
dataManager.purchaseData  = purchaseData_Class.new()
dataManager.buddyData  = buddyData_Class.new()
dataManager.chatData  = chatData.new()
dataManager.redEnvelopeData  = redEnvelopeData_Class.new()



dataManager.build = {}
dataManager.goldMineData  = goldMineData_Class.new()
dataManager.lumberMillData  = lumberMillData_Class.new()
dataManager.mainBase = mainBaseData.new();
dataManager.magicTower = magicTowerData.new();

dataManager.build[BUILD.BUILD_MAIN_BASE] = dataManager.mainBase;
dataManager.build[BUILD.BUILD_GOLD_MINE] = dataManager.goldMineData
dataManager.build[BUILD.BUILD_LUMBER_MILL] = dataManager.lumberMillData
dataManager.build[BUILD.BUILD_MAGIC_TOWER] = dataManager.magicTower;

dataManager.moneyFlyManager = moneyFlyManager.new();
dataManager.loginData = loginData.new();
dataManager.loginData:initFromConfig();

dataManager.limitedActivity = limitedActivityData.new();
dataManager.limitedActivity:init();

dataManager.crusadeActivityData = crusadeActivityData.new();
dataManager.crusadeActivityData:init();

dataManager.speedChallegeRankData = speedChallegeRankData.new();
dataManager.speedChallegeRankData:init();

dataManager.buyResPriceData = buyResPriceData.new();
dataManager.buyResPriceData:init();

dataManager.activityInfoData = activityInfoData.new();
dataManager.activityInfoData:init();

dataManager.idolBuildData = idolBuildData.new();
dataManager.idolBuildData:init();

dataManager.miracleData = miracleData.new();
dataManager.miracleData:init();

dataManager.vipGiftData = vipGiftData.new();
dataManager.vipGiftData:init();

dataManager.guildListData = guildListData.new();
dataManager.guildListData:init();

dataManager.guildData = guildData.new();
dataManager.guildData:init();

dataManager.guildWarData = guildWarData.new();
dataManager.guildWarData:init();

dataManager.transactionData = transactionData:new();
dataManager.transactionData:initFromFile();

function dataManager.build.isWorkerFree()
		
	local result =  (dataManager.mainBase:getLevelUpStatus() == enum_LEVELUP_STATUS.LEVELUP_NORMALE and
					dataManager.goldMineData:getLevelUpStatus() == enum_LEVELUP_STATUS.LEVELUP_NORMALE and
					dataManager.lumberMillData:getLevelUpStatus() == enum_LEVELUP_STATUS.LEVELUP_NORMALE and
					dataManager.magicTower:getLevelUpStatus() == enum_LEVELUP_STATUS.LEVELUP_NORMALE)
	
	if result == false then
		-- 强制请求一下状态
		sendAskSyncBuild(BUILD.BUILD_MAIN_BASE);
		sendAskSyncBuild(BUILD.BUILD_GOLD_MINE);
		sendAskSyncBuild(BUILD.BUILD_LUMBER_MILL);
		sendAskSyncBuild(BUILD.BUILD_MAGIC_TOWER);
	end
	
	return result;
end

function dataManager.build.getLevelUpRemainTime(buildType)

	local timeCost = -1;
	local levelUpTime = dataManager.build[buildType]:getLevelUpTime();
	local buildLevel = dataManager.build[buildType]:getLevel();
	
	if buildType == BUILD.BUILD_MAIN_BASE then
		timeCost = dataConfig.configs.MainBaseConfig[buildLevel].timeCost;
	elseif buildType == BUILD.BUILD_GOLD_MINE then
		timeCost = dataConfig.configs.GoldMineConfig[buildLevel].timeCost;
	elseif buildType == BUILD.BUILD_LUMBER_MILL then
		timeCost = dataConfig.configs.lumberMillConfig[buildLevel].timeCost;
	elseif buildType == BUILD.BUILD_MAGIC_TOWER then
		timeCost = dataConfig.configs.MagicTowerConfig[buildLevel].timeCost;
	end
			
	local sysTime = dataManager.getServerTime();
 	local timeRemain = timeCost - (sysTime - levelUpTime)
	if(timeRemain < 0 )then
		timeRemain = 0;
	end
	
	return timeRemain;
end

function dataManager.build.getLevelUpNeedDiamond(buildType)
	local timeRemain = dataManager.build.getLevelUpRemainTime(buildType);
	if timeRemain > 0 then
		local diamondCostLevelUp = dataConfig.configs.ConfigConfig[0].diamondCost_upgradeImmediate;
		
		return math.floor(timeRemain / diamondCostLevelUp) + 1;
	else
		return 0;
	end
end

function dataManager.build.getCurrentLevelUpBuild()
	if dataManager.mainBase:getLevelUpStatus() == enum_LEVELUP_STATUS.LEVELUP_ING then
		return BUILD.BUILD_MAIN_BASE;
	elseif dataManager.goldMineData:getLevelUpStatus() == enum_LEVELUP_STATUS.LEVELUP_ING then
		return BUILD.BUILD_GOLD_MINE;
	elseif dataManager.lumberMillData:getLevelUpStatus() == enum_LEVELUP_STATUS.LEVELUP_ING then
		return BUILD.BUILD_LUMBER_MILL;
	elseif dataManager.magicTower:getLevelUpStatus() == enum_LEVELUP_STATUS.LEVELUP_ING then
		return BUILD.BUILD_MAGIC_TOWER;
	end
	
	return -1;
end

-- 初始化船的数据
shipData.init();

cardData.init();




function dataManager.logic_tick(dt)
	
	if dataManager.startTick then
		--dataManager.currentTick = dataManager.currentTick + dt;
	end
	
	----dataManager.setServerTime(dataManager.getServerTime() + dt)
 
	--dataManager.goldMineData:logic_tick(dt) 
	--dataManager.lumberMillData:logic_tick(dt) 
end	

--dataManager.playerData:setName("奔跑的野驴")
dataManager.playerData:setCastleName("城堡");

--setWindowName(dataManager.playerData:getName())		
function getEquipedMagicData(index)
	local magicPlan = PLAN_CONFIG.getPlan(PLAN_CONFIG.currentPlanType).magic;
	return magicPlan[index];
end

function getEquipedMagicServerData(index)
	
	local magicData = {};
	
	if(battlePlayer.force ==  enum.FORCE.FORCE_ATTACK	)then
		magicData = battlePlayer.attackMagics;
	else
		magicData = battlePlayer.guardMagics;
	end
	
	for k,v in pairs(magicData) do
		if v.position == index then
			return v;
		end
	end
	
	local defalut = {
		id = 0, 
		level = 0, 
	};
	
	return defalut;
end

function setEquipedMagicData(index, id)

	local magicPlan = PLAN_CONFIG.getPlan(PLAN_CONFIG.currentPlanType).magic;
	
	if dataManager.kingMagic:getMagic(id) and index > 0 and index <= 7 then
		magicPlan[index].id = id;
	else
		magicPlan[index].id = 0;
	end
end

function getMagicEquipedIndex(id)
	local magicPlan = PLAN_CONFIG.getPlan(PLAN_CONFIG.currentPlanType).magic;
	
	for k,v in ipairs(magicPlan) do
		if id == v.id then
			return k;
		end
	end
	
	return -1;
end

local team_config =  class("team_config")

function team_config:ctor()
	self.magic = {}
	self.shipPlans ={}
	
	for i=1, 6 do
		self.shipPlans[i] = {};
	end
	
	for i=1, 16 do
		self.magic[i] = {
			['id'] = 0;
		};
	end
	
	self.magic[7] = {
		['id'] = 1;
	};
	
end

PLAN_CONFIG = {}

PLAN_CONFIG.currentPlanType = enum.PLAN_TYPE.PLAN_TYPE_PVE;

-- 改为下面两个分别同步的代码

-- 检查plan是否是空，如果空的就从pve的配置初始化
function PLAN_CONFIG.isShipsPlanEmpty(_type)
	local shipPlan = PLAN_CONFIG.all[_type].shipPlans;
	
	for k,v in pairs(shipPlan) do
		if v.cardID > 0 then
			return false;
		end
	end
	
	return true;
end

-- 复制plan
function PLAN_CONFIG.copyPlan(srcType, destType)

	if PLAN_CONFIG.all[destType] == nil then
		PLAN_CONFIG.all[destType] = team_config.new();
	end
	
	local srcShipPlan = PLAN_CONFIG.all[srcType].shipPlans;
	local destShipPlan = PLAN_CONFIG.all[destType].shipPlans;
	if srcShipPlan and destShipPlan then
		for k,v in pairs(srcShipPlan) do
			destShipPlan[k].cardID = v.cardID;
			destShipPlan[k].x = v.x;
			destShipPlan[k].y = v.y;
		end
	end
	
	local srcMagicPlan = PLAN_CONFIG.all[srcType].magic;
	local destMagicPlan = PLAN_CONFIG.all[destType].magic;
	
	if srcMagicPlan and destMagicPlan then
		for k,v in pairs(srcMagicPlan) do
			destMagicPlan[k].id = v.id;
		end
	end
	
end

function PLAN_CONFIG.setShipsPlan(_type, shipIndex, shipPlan)
	PLAN_CONFIG.all = PLAN_CONFIG.all or {};
	if PLAN_CONFIG.all[_type] == nil then
		PLAN_CONFIG.all[_type] = team_config.new();
	end
	
	local planConfig = PLAN_CONFIG.all[_type];
	if planConfig.shipPlans == nil then
		planConfig.shipPlans = {};
	end
	
	planConfig.shipPlans[shipIndex] = {};
	planConfig.shipPlans[shipIndex].cardID = shipPlan.cardID;
	planConfig.shipPlans[shipIndex].x = shipPlan.position.x;
	planConfig.shipPlans[shipIndex].y = shipPlan.position.y;
	
end

function PLAN_CONFIG.setMagicPlan(_type, shortcutIndex, magicID)
	PLAN_CONFIG.all = PLAN_CONFIG.all or {};
	if PLAN_CONFIG.all[_type] == nil then
		PLAN_CONFIG.all[_type] = team_config.new();
	end
	
	local planConfig = PLAN_CONFIG.all[_type];
	planConfig.magic[shortcutIndex] = {
		['id'] = magicID;
	};
	
	planConfig.magic[7] = {
		['id'] = 1;
	};
	
end

function PLAN_CONFIG.getPlan(_type)
	_type = _type or PLAN_CONFIG.currentPlanType;
	if(	PLAN_CONFIG.all )then
		return PLAN_CONFIG.all[_type]
	end
	return nil
end

-- 因为和服务器下来的数据结构不一样，所以增加一个接口
function PLAN_CONFIG.setShipsPlanFromLocal(_type, shipsPlan)
	_type = _type or PLAN_CONFIG.currentPlanType;
	if(	PLAN_CONFIG.all and PLAN_CONFIG.all[_type])then
		PLAN_CONFIG.all[_type].shipPlans = shipsPlan;
	end
end

-- 设置船的位置，设置船的cardID
function PLAN_CONFIG.setShipPosition( shipIndex, x, y, _type)
	_type = _type or PLAN_CONFIG.currentPlanType;
	if(	PLAN_CONFIG.all and PLAN_CONFIG.all[_type] and PLAN_CONFIG.all[_type].shipPlans[shipIndex])then		
		PLAN_CONFIG.all[_type].shipPlans[shipIndex].x = x;
		PLAN_CONFIG.all[_type].shipPlans[shipIndex].y = y;
	end
end

function PLAN_CONFIG.setShipCardType( shipIndex, cardType, _type)
	_type = _type or PLAN_CONFIG.currentPlanType;
	if(	PLAN_CONFIG.all and PLAN_CONFIG.all[_type] and PLAN_CONFIG.all[_type].shipPlans[shipIndex])then
		PLAN_CONFIG.all[_type].shipPlans[shipIndex].cardID = cardType;
	end
end

-- 获得船的位置，设置船的cardID
function PLAN_CONFIG.getShipPosition(shipIndex, _type)
	_type = _type or PLAN_CONFIG.currentPlanType;
	
	if(	PLAN_CONFIG.all and PLAN_CONFIG.all[_type] and PLAN_CONFIG.all[_type].shipPlans[shipIndex])then
		local x = PLAN_CONFIG.all[_type].shipPlans[shipIndex].x;
		local y = PLAN_CONFIG.all[_type].shipPlans[shipIndex].y;
		return x, y;
	end
	
	return -1, -1;
end

function PLAN_CONFIG.getShipCardType(shipIndex, _type)
	_type = _type or PLAN_CONFIG.currentPlanType;
	if(	PLAN_CONFIG.all and PLAN_CONFIG.all[_type] and PLAN_CONFIG.all[_type].shipPlans[shipIndex])then
		local cardType = PLAN_CONFIG.all[_type].shipPlans[shipIndex].cardID;
		return cardType;
	end
end

function PLAN_CONFIG.getShipIndexByPosition(x, y, _type)
	_type = _type or PLAN_CONFIG.currentPlanType;
	local shipPlan = PLAN_CONFIG.getPlan(_type).shipPlans;
	
	for k, v in ipairs(shipPlan) do
		if v.x == x and v.y == y then
			return k;
		end
	end
	
	return -1;
		
end

-- 找到装载某个卡牌的船
function PLAN_CONFIG.getShipEquipedCard(cardType, _type)
	_type = _type or PLAN_CONFIG.currentPlanType;
	
	local shipPlan = PLAN_CONFIG.getPlan(_type).shipPlans;
	
	for k,v in ipairs(shipPlan) do
		if v.cardID == cardType then
			return k;
		end
	end
	
	return -1;	
end

-- 根据卡牌算军团数
-- add idol effect num
function PLAN_CONFIG.getShipUnitNumber(shipIndex, _type)
	local shipInstance = shipData.getShipInstance(shipIndex);
	if shipInstance then
		local cardType = PLAN_CONFIG.getShipCardType(shipIndex, _type);
		return shipInstance:calcUnitNumByCardType(cardType);
	end
	
	return 0;
end

-- 装载军团,需要判断交换的逻辑
function PLAN_CONFIG.loadCard(shipIndex, cardType, _type)
	
	local shipEquipedCard = PLAN_CONFIG.getShipEquipedCard(cardType, _type);
	
	if shipEquipedCard == shipIndex and PLAN_CONFIG.getShipCardType(shipIndex, _type) > 0 then
		return;
	end
	
	if shipEquipedCard <= 0 then
		-- 不是已经装备的卡，直接放上
		local unitID = cardData.cardlist[cardType].unitID;		
		PLAN_CONFIG.setShipCardType(shipIndex, cardType, _type);

	else
	
		-- 已经装备的卡，并且不是同一条船，交换一下船上的卡
		local equipedCardType = PLAN_CONFIG.getShipCardType(shipEquipedCard, _type);
		local selectCardType = PLAN_CONFIG.getShipCardType(shipIndex, _type);
		
		PLAN_CONFIG.setShipCardType(shipEquipedCard, selectCardType, _type);
		PLAN_CONFIG.setShipCardType(shipIndex, equipedCardType, _type);
		
	end	
end

-- 同步配置
function PLAN_CONFIG.sendPlan(planType)
	
	planType = planType or PLAN_CONFIG.currentPlanType;
	
	-- 同步一下船的配置
	local shipsPlan = PLAN_CONFIG.getPlan(planType);
	
	local serverShipsPlan = {};
	
	for k,v in ipairs(shipsPlan.shipPlans) do
		local temp = nil
	
		temp = {
			['cardID'] = v.cardID,
			['position'] = { x = v.x, y = v.y, },
		}								
		
		table.insert(serverShipsPlan,temp)		
	end 

	local  magicPlans = {}
	magicPlans.shortcuts = {}
	for i = 1,6, 1 do
		local id = 0
		local playerSkill = getEquipedMagicData(i)			
		if playerSkill and  playerSkill.id  then
			id = playerSkill.id
		end
		magicPlans.shortcuts[i] = id
	end
	
	-- 发送配置到服务器
	
	sendPlan(planType, serverShipsPlan, magicPlans);
	
end
