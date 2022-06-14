
local attCollectionClass  = include("attCollection")

local playerDataClass = class("playerDataClass")

local ATT_MP  = "ATT_MP"
local ATT_MP_MAX  = "ATT_MP_MAX"
local ATT_INTELLIGENCE  = "ATT_INTELLIGENCE"
local ATT_FORCE  = "ATT_FORCE"
local ATT_LEVEL  = "ATT_LEVEL"
local ATT_NAME  = "ATT_NAME"

local ATT_GOLD  = "ATT_GOLD"
local ATT_WOOD  = "ATT_WOOD"
local ATT_GEM  = "ATT_GEM"
local ATT_VITALITY  = "ATT_VITALITY"
local ATT_FOOD = "ATT_FOOD"

local ATT_VIP_LEVEL  = "ATT_VIP_LEVEL"

local ATT_CAST_MP_RATE  = "ATT_CAST_MP_RATE"

local ATT_EXP  = "ATT_EXP"
local ATT_ADVENTURE_PROGRESS_NORMAL = "ATT_ADVENTURE_PROGRESS_NORMAL"
local ATT_ADVENTURE_PROGRESS_ELITE = "ATT_ADVENTURE_PROGRESS_ELITE"

local ATTR_CHAPTER_REWARD_NORMAL = "ATTR_CHAPTER_REWARD_NORMAL"
local ATTR_CHAPTER_REWARD_ELITE = "ATTR_CHAPTER_REWARD_ELITE"

local ATT_HONOR  = "ATT_HONOR"
local ATT_CONQUEST  = "ATT_CONQUEST"
local ATT_MYTHS  = "ATT_MYTHS"
 
function playerDataClass:ctor()
	self.att = attCollectionClass.new()	
	-- player attr
	self.playerAttr = {};
	self.playerAttrString = {};
	self.timeAttr = {}
		-- counter数据
	self.counter = {};
	self.counterArray = {};
    self.counterActivity = {};


	self:setMp(1)		
	self:setMpMax(1)	
	self:setIntelligence(0)	
 
	self:setGold(0)	
	self:setGem(0)	
	self:setWood(0)	
	self:setVitality(0)	
	self:setVipLevel(0)
	self:setFood(0)
	self:setHonor(0)
	self:setConquest(0)
 
		
	self:setCasterMPRate(100)		
	self:setExp(0)		
	self:setIcon(0)
	self:setMyths(0)
	-- 时间属性
	self.timeAttr = {};
	
	-- 新增属性
	self.extraAttr = {};
	
	-- 城堡名字
	self.castleName = "";
	
	self:setAdventureNormalProcess(1)
	self:setAdventureEliteProcess(1)
	self.stageInfo = nil
	
	self.login = false;
end 	

function playerDataClass:getCreateRoleTime()
	return self:getTimeAttr(enum.PLAYER_ATTR64.PLAYER_ATTR64_CREATE_ROLE);
end

function playerDataClass:moneyIsEnough(s_type,num)
	 
	if(s_type == enum.MONEY_TYPE.MONEY_TYPE_GOLD)then
		return self:getGold() >= num
	elseif(s_type == enum.MONEY_TYPE.MONEY_TYPE_LUMBER)then
		return self:getWood() >= num
	elseif(s_type == enum.MONEY_TYPE.MONEY_TYPE_DIAMOND)then
		return self:getGem() >= num
	elseif(s_type == enum.MONEY_TYPE.MONEY_TYPE_VIGOR)then
		return self:getVitality() >= num
	end
end

function playerDataClass:getCastleName()
	return self.castleName;
end

function playerDataClass:setCastleName(castleName)
	self.castleName = castleName;
end

function playerDataClass:setPlayerAttr(attrEnum, value)
	
	local oldvalue = self.playerAttr[attrEnum];
	
	self.playerAttr[attrEnum] = value;
	
	self:onPlayerAttrChange(attrEnum, oldvalue, value);
	
end

function playerDataClass:onPlayerAttrChange(attrEnum, oldvalue, newvalue)
	
	if attrEnum == enum.PLAYER_ATTR.PLAYER_ATTR_ADVENTURE_PROGRESS_NORMAL then
		shipData.updateActiveShip();
	end
	
end

function playerDataClass:setPlayerStringAttr(attrEnum, value)
	self.playerAttrString[attrEnum] = value;
end
function playerDataClass:getPlayerStringAttr(attrEnum)
	return  self.playerAttrString[attrEnum]
end
function playerDataClass:setPlayerId(value)
    self.playerId = value;
end
function playerDataClass:getPlayerId()
    return self.playerId;
end

 
--enum.PLAYER_ATTR_STRING.PLAYER_ATTR_STRING_ACCOUNT = 0;-- 账号名
--enum.PLAYER_ATTR_STRING.PLAYER_ATTR_STRING_NAME = 1;-- 玩家名
 
function playerDataClass:getPlayerAttr(attrEnum)
	return self.playerAttr[attrEnum];
end

function playerDataClass:checkLevelup()
	
	if self.levelupFlag then
		--体力已经更新过了
		eventManager.dispatchEvent( {name = global_event.HEROLEVELUP_SHOW, vigorIsBefore = false });
		self.levelupFlag = nil;
	end
	
end

function playerDataClass:onPlayerAttrChanged(attrEnum, oldValue, newValue)
	
	if attrEnum == enum.PLAYER_ATTR.PLAYER_ATTR_LEVEL then
		
		self.preLevel = oldValue		
		if(newValue ~= -1 and self.preLevel ~= newValue and self.preLevel ~= nil )then
			--eventManager.dispatchEvent( {name = global_event.HEROLEVELUP_SHOW })
			
			--print("--------------------------global_event.HEROLEVELUP_SHOW--------------------level change ");
			
			--layoutManager.delay({name = global_event.HEROLEVELUP_SHOW },{"sweep","instancejiesuanView","BattleView"}) --"instanceinfor"
			
			-- 推图和战斗的时候要延迟出现 升级
			if game.state == game.GAME_STATE_BATTLE or 
					game.state == game.GAME_STATE_INSTANCE then
				self.levelupFlag = true;
			else
				-- 体力在后发
				eventManager.dispatchEvent( {name = global_event.HEROLEVELUP_SHOW, vigorIsBefore = true })
			end
			
			eventManager.dispatchEvent({name = global_event.TASK_UPDATE_LIST});
		end	

	elseif attrEnum == enum.PLAYER_ATTR.PLAYER_ATTR_INTELLIGENCE then

	elseif attrEnum == enum.PLAYER_ATTR.PLAYER_ATTR_DRAW_TIMES then
	
	elseif attrEnum == enum.PLAYER_ATTR.PLAYER_ATTR_GLOBAL_MAIL_ID then
	
	elseif attrEnum == enum.PLAYER_ATTR.PLAYER_ATTR_RMB then
	
	elseif attrEnum == enum.PLAYER_ATTR.PLAYER_ATTR_EXP then
		
		-- 系统提示
		if oldValue and newValue then
		
			local change = newValue - oldValue;
			if change > 0 then
				local text = "^FFFF00获得^BE4BF9经验 ^00FF00+"..change;
				eventManager.dispatchEvent({name =  global_event.WARNINGHINT_SHOW,tip =  text ,RESGET = true})
			end
			eventManager.dispatchEvent({name = global_event.EXPBUYBACK_UPDATE});
		
		end
	elseif attrEnum == enum.PLAYER_ATTR.PLAYER_ATTR_LOST_EXP then
	
		eventManager.dispatchEvent({name = global_event.EXPBUYBACK_UPDATE});
		 	
	elseif attrEnum == enum.PLAYER_ATTR.PLAYER_ATTR_ADVENTURE_PROGRESS_NORMAL then
			eventManager.dispatchEvent({name = global_event.GUIDE_ON_ENTER_ADVENTURE_PROGRESS_NORMAL,arg1 = newValue});
	elseif attrEnum == enum.PLAYER_ATTR.PLAYER_ATTR_ADVENTURE_PROGRESS_ELITE then
			eventManager.dispatchEvent({name = global_event.GUIDE_ON_ENTER_ADVENTURE_PROGRESS_ELITE});
	elseif attrEnum == enum.PLAYER_ATTR.PLAYER_ATTR_CHAPTER_REWARD_NORMAL then
			
	elseif attrEnum == enum.PLAYER_ATTR.PLAYER_ATTR_CHAPTER_REWARD_ELITE then

	elseif attrEnum == enum.PLAYER_ATTR.PLAYER_ATTR_VIP then

	elseif attrEnum == enum.PLAYER_ATTR.PLAYER_ATTR_LEVEL_REWARD then
		eventManager.dispatchEvent({name = global_event.TASK_UPDATE_LIST});
		eventManager.dispatchEvent({name = global_event.MAIN_UI_DAILY_REWARD_STATE});
	elseif attrEnum == enum.PLAYER_ATTR.PLAYER_ATTR_LOGIN_REWARD then
		eventManager.dispatchEvent({name = global_event.TASK_UPDATE_LIST});
		eventManager.dispatchEvent({name = global_event.MAIN_UI_DAILY_REWARD_STATE});
	end
end

function playerDataClass:getLastOpenShopTime()
	return self:getTimeAttr(enum.PLAYER_ATTR64.PLAYER_ATTR64_LAST_OPEN_SHOP_GUI_TIME);
end

function playerDataClass:getTimeAttr(attrEnum)
	return self.timeAttr[attrEnum];	
end 	

function playerDataClass:setTimeAttr(attrEnum, time)
	self.timeAttr[attrEnum] = time;
	if(enum.PLAYER_ATTR64.PLAYER_ATTR64_PVP_OFFLINE_COOLDOWN == attrEnum)then
		eventManager.dispatchEvent({name = global_event.PVP_UPDATE})
	end

end

function playerDataClass:getExtraAttr(attrEnum)
	
	return self.extraAttr[attrEnum];
	
end

function playerDataClass:setExtraAttr(attrEnum, value)
	
	self.extraAttr[attrEnum] = value;
	
end

function playerDataClass:getMp()
	return self.att:getAttr(ATT_MP)		
end 	

function playerDataClass:setMp(mp)
	
	self.oldMp = self:getMp();
	
	self.att:setAttr(ATT_MP,mp)			
end

function playerDataClass:getOldMp()
	return self.oldMp;
end

function playerDataClass:getMpMax()
	return self.att:getAttr(ATT_MP_MAX)		
end 	

function playerDataClass:setMpMax(mp)
	 self.att:setAttr(ATT_MP_MAX,mp)		
end

-- 从player表获取
function playerDataClass:setIntelligence(intelligence)
	 --self.att:setAttr(ATT_INTELLIGENCE,intelligence)		
end 	

function playerDataClass:getIntelligence()
	 --return self.att:getAttr(ATT_INTELLIGENCE)		
	 --return self:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_INTELLIGENCE);
	local config = self:getPlayerConfig();
	if config then
		return config.intelligence;
	end
	
	return 0;
end

function playerDataClass:getPlayerConfig(level)
	level = level or self:getLevel();
	if(level < 0)then
		level = 0
	elseif(level > #dataConfig.configs.playerConfig)then
		level = #dataConfig.configs.playerConfig
	end
	return dataConfig.configs.playerConfig[level];
end

function playerDataClass:setForce(force)
	 self.att:setAttr(ATT_FORCE,force)		
end 	

function playerDataClass:getForce()
	 return self.att:getAttr(ATT_FORCE)		
end

function playerDataClass:setLevel(level)
	--self.att:setAttr(ATT_LEVEL,level)		
	
	self:setPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_LEVEL,level)	
end 	

function playerDataClass:getLevel()
	 --return self.att:getAttr(ATT_LEVEL)			
	return self:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_LEVEL);
end
 
function playerDataClass:setName(name)
	--self.att:setAttr(ATT_NAME,name)	
	self:setPlayerStringAttr(enum.PLAYER_ATTR_STRING.PLAYER_ATTR_STRING_NAME,name)
	
end
 
function playerDataClass:setIcon(icon)
	self:setPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_ICON,icon)
end
 

function playerDataClass:getName()
	--return self.att:getAttr(ATT_NAME)		
	return self:getPlayerStringAttr(enum.PLAYER_ATTR_STRING.PLAYER_ATTR_STRING_NAME);
end 	

function playerDataClass:getHeadIconImage()
	return global.getHeadIcon(self:getHeadIcon());
end

function playerDataClass:getHeadIcon()
	return self:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_ICON );
end 	

function playerDataClass:setGold(gold)
	self.att:setAttr(ATT_GOLD,gold)			
end
function playerDataClass:getGold()
	return self.att:getAttr(ATT_GOLD)		
end 	

function playerDataClass:setWood(wood)
	self.att:setAttr(ATT_WOOD,wood)			
end
function playerDataClass:getWood()
	return self.att:getAttr(ATT_WOOD)		
end 	


function playerDataClass:setHonor(h)
	self.att:setAttr(ATT_HONOR,h)			
end
function playerDataClass:getHonor()
	return self.att:getAttr(ATT_HONOR)		
end 
function playerDataClass:setConquest(h)
	self.att:setAttr(ATT_CONQUEST,h)			
end
function playerDataClass:getConquest()
	return self.att:getAttr(ATT_CONQUEST)		
end 
 
function playerDataClass:setGem(gem)
	self.att:setAttr(ATT_GEM,gem)			
end
function playerDataClass:getGem()
	return self.att:getAttr(ATT_GEM)		
end 

function playerDataClass:setVitality(v)
	self.att:setAttr(ATT_VITALITY,v)			
end

function playerDataClass:getVitality()
	
	if self.att:getAttr(ATT_VITALITY) >= self:getVigorMax() then
		return self.att:getAttr(ATT_VITALITY);
	else
		local lastRefreshTime = self:getTimeAttr(enum.PLAYER_ATTR64.PLAYER_ATTR64_VIGOR_TIME);
		local gatherTime = dataManager.getServerTime() - lastRefreshTime;
		
		local getTimeInterval = dataConfig.configs.ConfigConfig[0].vigorRegenerationInterval;
		local gatherCount = math.floor(gatherTime/getTimeInterval);

		local vigor =  self.att:getAttr(ATT_VITALITY) + gatherCount;
		if vigor > self:getVigorMax() then
			vigor = self:getVigorMax();
		end
		
		return vigor;
	end
	
end 

-- 获得下次体力回复需要的时间
function playerDataClass:getNextFreeVigorTime()
	
	if self:getVitality() >= self:getVigorMax() then
		return 0;
	end
	
	local lastRefreshTime = self:getTimeAttr(enum.PLAYER_ATTR64.PLAYER_ATTR64_VIGOR_TIME);
	local gatherTime = dataManager.getServerTime() - lastRefreshTime;
	
	if gatherTime < 0 then
		gatherTime = 0;
	end
	
	local getTimeInterval = dataConfig.configs.ConfigConfig[0].vigorRegenerationInterval;
	--print("gatherTime "..gatherTime.." getTimeInterval "..getTimeInterval.."  math.fmod(gatherTime, getTimeInterval) "..math.fmod(gatherTime, getTimeInterval));
	gatherTime = getTimeInterval - math.fmod(gatherTime, getTimeInterval);

	return gatherTime;
end

-- 下次免费抽卡时间
function playerDataClass:getNextFreeCardRemainTime()
	local nextFreeTime = self:getTimeAttr(enum.PLAYER_ATTR64.PLAYER_ATTR64_NEXT_FREE_DRAW_TIME);
	local waitTime = nextFreeTime - dataManager.getServerTime();
	
	return waitTime;	
end

function playerDataClass:getFullVigorTime()
	
	if self:getVitality() >= self:getVigorMax() then
		return 0;
	else
		local lack = self:getVigorMax() - self:getVitality();
		
		if lack < 0 then
			lack = 0;
		end
		
		local getTimeInterval = dataConfig.configs.ConfigConfig[0].vigorRegenerationInterval;
		
		return self:getNextFreeVigorTime() + getTimeInterval * (lack-1);
	end
	
end

function playerDataClass:getVigorMax()
	return dataConfig.configs.vipConfig[self:getVipLevel()].maxVigor;
end

function playerDataClass:setFood(v)
	self.att:setAttr(ATT_FOOD,v)			
end

function playerDataClass:getFood()
	return self.att:getAttr(ATT_FOOD)		
end

function playerDataClass:setVipLevel(level)
	self.att:setAttr(ATT_VIP_LEVEL,level)			
end

function playerDataClass:getVipLevel()
	--return self.att:getAttr(ATT_VIP_LEVEL)	
	return self:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_VIP);	
end 

function playerDataClass:getVipConfig()
	return dataConfig.configs.vipConfig[self:getVipLevel()];
end


function playerDataClass:getVipMax()
	local size = table.nums(dataConfig.configs.vipConfig)
	return 	dataConfig.configs.vipConfig[size -1].id
end


function playerDataClass:getRMB()
 
	return self:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_RMB);	
end 
 

function playerDataClass:getNextVipNeedInfo()
	 
	local cur = self:getVipLevel()
	local max = self:getVipMax()
	local process = 0
	if(cur == max)then
		return 0,max,1
	end
	local rmb = self:getRMB()
	local nextrmbNum = dataConfig.configs.vipConfig[cur + 1].rmb
	return nextrmbNum - rmb,cur + 1,rmb/nextrmbNum
end


function playerDataClass:getVipMoneyInfo()
	 
	--[[local cur = self:getVipLevel()
	local max = self:getVipMax()
	local rmb = self:getRMB()
	local nvip = cur + 1 
	if(nvip >= max)then
		nvip =   max
	end
	local nextrmbNum = dataConfig.configs.vipConfig[nvip].rmb
 	local currmbNum = dataConfig.configs.vipConfig[cur].rmb
 
	return   rmb - currmbNum ,nextrmbNum
	]]--
	local cur = self:getVipLevel()
	local max = self:getVipMax()
	local rmb = self:getRMB()
	local nvip = cur + 1 
	if(nvip >= max)then
		nvip =   max
	end
	local nextrmbNum = dataConfig.configs.vipConfig[nvip].rmb
	local currmbNum = dataConfig.configs.vipConfig[cur].rmb
	return  rmb,nextrmbNum,currmbNum
end

function playerDataClass:getNeedMoneyWithVipLevel(level)
	 
	local cur = level
	local max = self:getVipMax()
	local rmb = self:getRMB()
	if(cur >= max)then
		cur =   max
	end
	local currmbNum = dataConfig.configs.vipConfig[cur].rmb
	return  currmbNum - rmb
end



function playerDataClass:setCasterMPRate(rate)
	rate = rate *0.01
	self.att:setAttr(ATT_CAST_MP_RATE,rate)			
end

function playerDataClass:setMyths(myths)
	self.att:setAttr(ATT_MYTHS,myths)			
end

function playerDataClass:getMyths()
	return self.att:getAttr(ATT_MYTHS)			
end


function playerDataClass:getMythsIcon()
	 	 local ths = self:getMyths()
 		 return global.getMythsIcon(ths)
end

function playerDataClass:getCasterMPRate()
	return self.att:getAttr(ATT_CAST_MP_RATE)		
end 

function playerDataClass:getPreLevel()
	return self.preLevel
end

function playerDataClass:getLevelConfig()
	 	return dataConfig.configs.playerConfig[self:getLevel()]
end
function playerDataClass:getNexLevel()
	local level = self:getLevel()
	if(level >= #dataConfig.configs.heroConfig)then
		return nil
	end
	return level + 1
end
function playerDataClass:setExp(exp)
	self.att:setAttr(ATT_EXP,exp)			
end

function playerDataClass:getExp()
	--return self.att:getAttr(ATT_EXP)
	return self:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_EXP);
end 

function playerDataClass:getLevelupExp()
	if dataConfig.configs.playerConfig[self:getLevel()] then
		return dataConfig.configs.playerConfig[self:getLevel()].exp;
	else
		return 1;
	end
end

function playerDataClass:setAdventureNormalProcess(p)
	self.att:setAttr(ATT_ADVENTURE_PROGRESS_NORMAL,p)			
end

function playerDataClass:getAdventureNormalProcess()
	--return self.att:getAttr(ATT_ADVENTURE_PROGRESS_NORMAL)		
	return self:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_ADVENTURE_PROGRESS_NORMAL);	
end

function playerDataClass:getCurrentNormalStage()
	local id = self:getAdventureNormalProcess();
	if id == 0 then
		id = 1;
	end
	
	return id;
end

function playerDataClass:getCurrentEliteStage()
	local id = self:getAdventureEliteProcess();
	if id == 0 then
		id = 1;
	end
	
	return id;
end

function playerDataClass:setAdventureEliteProcess(p)
	self.att:setAttr(ATT_ADVENTURE_PROGRESS_ELITE,p)			
end
 
function playerDataClass:getAdventureAandB(id)

	local ppp = 0;
	local c = 0;
	
	id = id;
	
	for k,v in ipairs(dataConfig.configs.ChapterConfig) do
		
		c = v.adventureID;
		
		if id-1 <=c then 
			local A = k;
			local B = math.floor((id - ppp)/2);
			
			print("B  "..B.." id "..id.." ppp "..ppp);
			return A, B;
		end
		
		ppp= c;
	end
		
end

function playerDataClass:getAdventureEliteText()

end

function playerDataClass:getAdventureEliteProcess()
	--return self.att:getAttr(ATT_ADVENTURE_PROGRESS_ELITE)			
	return self:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_ADVENTURE_PROGRESS_ELITE);	
end

-----章节领奖进度
function playerDataClass:setChapterNormalAwardProcess(p)
	self.att:setAttr(ATTR_CHAPTER_REWARD_NORMAL,p)			
end
 

function playerDataClass:getChapterNormalAwardProcess(id)
	return self:getCounterArrayData(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_CHAPTER_NORMAL, id);
end

function playerDataClass:setChapterEliteAwardProcess(p)
	self.att:setAttr(ATTR_CHAPTER_REWARD_ELITE,p)			
end
 

function playerDataClass:getChapterEliteAwardProcess(id)
	--return self.att:getAttr(ATTR_CHAPTER_REWARD_ELITE)
	--return self:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_CHAPTER_REWARD_ELITE);				
	return self:getCounterArrayData(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_CHAPTER_ELITE, id);	
end
 

function playerDataClass:release()
	self.att = nil
end

-- 得到counter的数据
function playerDataClass:getCounterData(counterEnum)
	return self.counter[counterEnum+1];
end

-- 得到counterarray的数据
 
function playerDataClass:getCounterArrayData(counterArrayEnum, id)
	
	self.counterArray[counterArrayEnum+1] = self.counterArray[counterArrayEnum+1] or {};
	self.counterArray[counterArrayEnum+1]["counterArray"] = self.counterArray[counterArrayEnum+1]["counterArray"] or {};
	self.counterArray[counterArrayEnum+1]["counterArray"][id] = self.counterArray[counterArrayEnum+1]["counterArray"][id] or 0;
	
	return self.counterArray[counterArrayEnum+1]["counterArray"][id];	
end
function playerDataClass:getCounterArrayDataAll(counterArrayEnum)

	self.counterArray[counterArrayEnum+1] = self.counterArray[counterArrayEnum+1] or {};
	self.counterArray[counterArrayEnum+1]["counterArray"] = self.counterArray[counterArrayEnum+1]["counterArray"] or {};
	
	return self.counterArray[counterArrayEnum+1]["counterArray"];	
end

-- 设置counter的常规计数
function playerDataClass:setCounterData(counterEnum, value)
	self.counter[counterEnum+1] = value;	
	if(enum.COUNTER_TYPE.COUNTER_TYPE_PVP_OFFLINE_BATTLE == counterEnum)then
		eventManager.dispatchEvent({name = global_event.PVP_UPDATE})
	elseif enum.COUNTER_TYPE.COUNTER_TYPE_CHALLENGE_SPEED_ROUND == counterEnum or
				enum.COUNTER_TYPE.COUNTER_TYPE_CHALLENGE_SPEED_FAIL == counterEnum or
				enum.COUNTER_TYPE.COUNTER_TYPE_CHALLENGE_SPEED_STAGE == counterEnum then
		eventManager.dispatchEvent({name = global_event.ACTIVITYSPEED_UPDATE});
	elseif enum.COUNTER_TYPE.COUNTER_TYPE_CHALLENGE_DAMAGE_TIMES == counterEnum then	
		 eventManager.dispatchEvent({name = global_event.ACTIVITYDAMAGE_UPDATE})
 
	end
end

-- 设置counter的活动计数
function playerDataClass:setCounterActivity(counterEnum, value)
    self.counterActivity[counterEnum+1] = value;
end

-- 活动计数的枚举就是id
function playerDataClass:getCounterActivity(counterEnum)
	return self.counterActivity[counterEnum];
end

-- index是服务器的数组下标从0开始, 保存的时候都加了1，就是保存成id了
-- get接口是直接传id,也就是index+1
-- 设置counterarray的数据
function playerDataClass:setCounterArrayData(counterArrayEnum, index, value)

	self.counterArray[counterArrayEnum+1] = self.counterArray[counterArrayEnum+1] or {};
	self.counterArray[counterArrayEnum+1]["counterArray"] = self.counterArray[counterArrayEnum+1]["counterArray"] or {};
	self.counterArray[counterArrayEnum+1]["counterArray"][index+1] = self.counterArray[counterArrayEnum+1]["counterArray"][index+1] or 0;
		
	self.counterArray[counterArrayEnum+1]["counterArray"][index+1] = value;
	
	if enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_GUIDE == counterArrayEnum then		
		Guide.onServerData(self:getCounterArrayDataAll(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_GUIDE))
	end
end


-- 得到当前已经购买资源的次数
function playerDataClass:getBuyResourceTimes(resType, copyType, copyID)
	
	if resType == enum.BUY_RESOURCE_TYPE.GOLD then
		return self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_GOLD_PURCHASE);
	elseif resType == enum.BUY_RESOURCE_TYPE.WOOD then
		return self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_LUMBER_PURCHASE);
	elseif resType == enum.BUY_RESOURCE_TYPE.VIGOR then
		return self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_VIGOR_PURCHASE);
	elseif resType == enum.BUY_RESOURCE_TYPE.RESET_COPY then
		if copyType == enum.ADVENTURE.ADVENTURE_NORMAL then
			return self:getCounterArrayData(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_STAGE_RESET,copyID);
		elseif copyType == enum.ADVENTURE.ADVENTURE_ELITE then
			return self:getCounterArrayData(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_ELITE_RESET,copyID);
		end
	end

end

-- 得到当前可购买资源的次数
function playerDataClass:getCanBuyResourceTimes(resType, copyType, copyID)
	
	local maxTimes = self:getMaxBuyResourceTimes(resType);
	
	if maxTimes >= 0 then
		return maxTimes - self:getBuyResourceTimes(resType, copyType, copyID);
	else
		return -1;
	end
end

-- 得到当前购买资源的次数的上限
function playerDataClass:getMaxBuyResourceTimes(resType)

	local vipInfo = dataConfig.configs.vipConfig[self:getVipLevel()];
	if vipInfo then
		if resType == enum.BUY_RESOURCE_TYPE.GOLD then
			return vipInfo.buyGoldTimes;
		elseif resType == enum.BUY_RESOURCE_TYPE.WOOD then
			return vipInfo.buyLumberTimes;
		elseif resType == enum.BUY_RESOURCE_TYPE.VIGOR then
			return vipInfo.buyVigorTimes;
		elseif resType == enum.BUY_RESOURCE_TYPE.RESET_COPY then
			return vipInfo.resetTimes;
		end
	end
	
	return -1;
end

function playerDataClass:isDiamondEnough(resType, copyType, copyID)
	local cost = self:getBuyResourceNeedDiamond(resType, copyType, copyID);
	return self:getGem() >= cost;
end

-- 得到当前购买某个资源需要的钻石
function playerDataClass:getBuyResourceNeedDiamond(resType, copyType, copyID)
	local buyTimes = self:getBuyResourceTimes(resType, copyType, copyID);
	local priceInfo = dataConfig.configs.priceConfig[buyTimes+1];
	--dump(priceInfo);
	local nowBuyPriceInfo = -1;
	--print("buyTimes "..buyTimes);
	if priceInfo then
		nowBuyPriceInfo = priceInfo;
	else
		if buyTimes+1 > #dataConfig.configs.priceConfig then
			nowBuyPriceInfo =  dataConfig.configs.priceConfig[#dataConfig.configs.priceConfig];
		else
			return -1;
		end
	end
	
	if resType == enum.BUY_RESOURCE_TYPE.GOLD then
		return nowBuyPriceInfo.gold;
	elseif resType == enum.BUY_RESOURCE_TYPE.WOOD then
		return nowBuyPriceInfo.lumber;
	elseif resType == enum.BUY_RESOURCE_TYPE.VIGOR then
		return nowBuyPriceInfo.vigor;
	elseif resType == enum.BUY_RESOURCE_TYPE.RESET_COPY then
		return nowBuyPriceInfo.resetStage;
	end
	
	return -1;
end

-- 可以购买的资源数量
function playerDataClass:getCanBuyResourceNumber(resType)
	
	local configInfo = dataConfig.configs.ConfigConfig[0];
	
	if resType == enum.BUY_RESOURCE_TYPE.GOLD then
		local output = dataManager.goldMineData:getConfig().output;
		return output * configInfo.diamondToGold;
	elseif resType == enum.BUY_RESOURCE_TYPE.WOOD then
		local output = dataManager.lumberMillData:getConfig().diamondToLumber;
		return output;
	elseif resType == enum.BUY_RESOURCE_TYPE.VIGOR then
		return configInfo.diamondToVigor;
	elseif resType == enum.BUY_RESOURCE_TYPE.RESET_COPY then
		return -1;
	end
	
	return -1;
end

-- 获得免费体力
function playerDataClass:isCanGetFreeVigor()
	local h, m, s = dataManager.getLocalTime();
	local nowTime = h*3600 + m*60 + s;
		
	local id = -1;
	for k,v in pairs(dataConfig.configs.vigorRewardConfig) do
		local bhour, bminute = stringToTime(v.beginTime);
		local ehour, eminute = stringToTime(v.endTime);
				
		local beginTime = bhour*3600 + bminute*60;
		local endTime = ehour*3600 + eminute*60;
		
		local time24 = 24 * 3600;
		if beginTime < endTime then
			-- 当天
			if nowTime >= beginTime and nowTime < endTime then
				id = k;
				break;
			end
		else
			-- 跨天了
			if (nowTime>= beginTime and nowTime <= time24) or (nowTime>= time24 and nowTime <= endTime) then
				id = k;
				break;
			end
		end
	end

	--服务器硬编码了。。
	if (id == 1 and self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_FREE_VIGOR_NOON)==0) or 
			(id == 2 and self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_FREE_VIGOR_EVENING)==0) then
		return true, id;
	else
		return false, id;
	end
end


function playerDataClass:GetNextFreeVigorTime()
	local h, m, s  = dataManager.getLocalTime();
	local nowTime = h*3600 + m*60 + s;
	
--[[	
21:01~23:59  次日12:00~14:00可领取体力
00:00~11:59  今日12:00~14:00可领取体力
12:00~14:00  快来领取体力吧！
14:01~17:59  今日18:00~21:00可领取体力
18:00~21:00  快来领取体力吧！
]]--		
 
	local zeroTime = 0
	local id = -1;
	local t = {} 
	for k,v in pairs(dataConfig.configs.vigorRewardConfig) do
		local bhour, bminute = stringToTime(v.beginTime);
		local ehour, eminute = stringToTime(v.endTime);
		local beginTime = bhour*3600 + bminute*60;
		local endTime = ehour*3600 + eminute*60;
		if(beginTime > endTime)then
			endTime =  24*3600 + endTime
		end
		table.insert(t, { b = beginTime,e = endTime,v = v})
	end
	
	local text = ""
	if( nowTime > t[2].e and nowTime < t[1].b )then
		text = "次日"..t[1].v.beginTime.."~"..t[1].v.endTime.."可领取体力"
	elseif( nowTime >= zeroTime and nowTime < t[1].b )then
		text = "今日"..t[1].v.beginTime.."~"..t[1].v.endTime.."可领取体力"
	elseif( nowTime >= t[1].b and nowTime <= t[1].e )then
	
		
		if (self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_FREE_VIGOR_NOON)==0) then
			text = "快来领取体力吧"
		else
			text =  "今日"..t[2].v.beginTime.."~"..t[2].v.endTime.."可领取体力"
		end
	elseif( nowTime >= t[1].e and nowTime <= t[2].b )then
		
		text =  "今日"..t[2].v.beginTime.."~"..t[2].v.endTime.."可领取体力"
	
	elseif( nowTime >= t[2].b and nowTime <= t[2].e )then
		if (self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_FREE_VIGOR_EVENING)==0) then
			text = "快来领取体力吧"
		else
			text =   t[1].v.beginTime.."~"..t[1].v.endTime.."可领取体力"
		end
	end
	return text

end

function playerDataClass:getFreeVigor()
	
	local can, id = self:isCanGetFreeVigor();
	if can then
		sendSystemReward(enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_DAILY_VIGOR, id);
	else
		local timeText = "";
		for k,v in pairs(dataConfig.configs.vigorRewardConfig) do
			timeText = timeText..v.beginTime.."～"..v.endTime.."   ";
		end
		
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
				textInfo = "免费体力领取时间为:\n"..timeText });
	end
end


-- 每日任务相关接口
-- 根据id获得任务是否已经领取奖励
function playerDataClass:hasDailyTaskAwarded(taskID)
	return self:getCounterArrayData(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_EVENT_STATUS, taskID) > 0;
end

function playerDataClass:getDailyTaskCurrentProgress(taskID)
	
	local taskConfig = self:getDailyTaskConfig(taskID);
	if taskConfig == nil then
		return 0;
	end
	
	local finishType = taskConfig.finishType;
	
	local currentProgress = 0;
	if finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_ADVENTURE then
		currentProgress = self:getAdventureTimes();
	elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_NORMAL then
		currentProgress = self:getAdventureNormalTimes();
	elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_ELITE then
		currentProgress = self:getAdventureEliteTimes();
	elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_PVP_ONLINE then
		currentProgress =  dataManager.pvpData:getOnlineWinNum() + dataManager.pvpData:getOnlineLoseNum() 
	elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_PVP_OFFLINE then
		currentProgress = dataManager.pvpData:getOfflineTimes()
						
	elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_PURCHASE_GOLD then
		currentProgress = self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_GOLD_PURCHASE);
	elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_PURCHASE_LUMBER then
		currentProgress = self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_LUMBER_PURCHASE);
	elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_MEDITATION then
		currentProgress = self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_DAILY_MEDITATE_TIMES);
	elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_MONTH_RIGHT then
		-- 这里判断是否有权限领
		currentProgress = self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_MONTH_RIGHT_DAYS);
	elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_SWIEEP_TICKET then
		-- 扫荡卷肯定可以领，不需要完成
	elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_CHALLENGE_STAGE then
		currentProgress = self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_CHALLENGE_STAGE_TIMES);
	elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_CHALLENGE_DAMAGE then
		currentProgress = self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_CHALLENGE_DAMAGE_TIMES);
	elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_CHALLENGE_SPEED then
		currentProgress = self:getSpeedChanllegeTimes();
		
  elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_FRIENDS_PLAY then
    
    currentProgress = self:getFriendContestTimes();
    print("DAILY_TASK_TYPE_FRIENDS_PLAY  "..currentProgress)
    
  elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_PLUNDER then
  
	  currentProgress = self:getTotalPlunderTimes();
  
  elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_CHALLENGE_CRUSADE then
  	
  	currentProgress = self:getCrusadeTimes();
  	
  	print("crusade currentProgress "..currentProgress)
  elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_GIFTS_VIGOR then
  
		currentProgress = self:getGiftVigorTimes();
		print("DAILY_TASK_TYPE_GIFTS_VIGOR  "..currentProgress)
  end
	
	return currentProgress;
end

-- 是否任务已经完成
function playerDataClass:hasDailyTaskFinished(taskID)
	local taskConfig = self:getDailyTaskConfig(taskID);
	if taskConfig == nil then
		return false;
	end
	
	--根据不同的类型判断完成
	local finishType = taskConfig.finishType;
	local finishParam = taskConfig.finishParam;
	
	local currentProgress = self:getDailyTaskCurrentProgress(taskID);

	if finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_MONTH_RIGHT then
		-- 这里判断是否有权限领
		return currentProgress > 0 ;
	elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_SWIEEP_TICKET then
		-- 扫荡卷肯定可以领，不需要完成
		return true;
	else
		return currentProgress >= finishParam;
	end
	
end

-- 获得每日任务的表格数据
function playerDataClass:getDailyTaskConfig(taskID)
	return dataConfig.configs.dailyTaskConfig[taskID];
end

-- 获得副本次数相关
function playerDataClass:getAdventureTimes()
	return self:getAdventureNormalTimes() + self:getAdventureEliteTimes();
end

function playerDataClass:getAdventureNormalTimes()
	local normalTimes = 0;
	local normalCounterArray = self:getCounterArrayDataAll(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_STAGE_TIMES);
	for k,v in pairs(normalCounterArray) do
		normalTimes = normalTimes + v;
		--print("getAdventureNormalTimes "..v.." k "..k);
	end
	
	return normalTimes;
end

function playerDataClass:getAdventureEliteTimes()
	local eliteTimes = 0;
	local eliteCounterArray = self:getCounterArrayDataAll(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_ELITE_TIMES);
	for k,v in pairs(eliteCounterArray) do
		eliteTimes = eliteTimes + v;
	end
	
	return eliteTimes;
end

function playerDataClass:checkDailyTaskVIPBlock(id)
	
	if GLOBAL_CONFIG_BLOCK_VIP and (id == 8 or id == 9) then
		return true;
	else
		return false;
	end
end

function playerDataClass:getDailyTaskCanAwardedList()
	local awardedList = {};
	--key 是 tastid， value是draworder
	for k,v in pairs(dataConfig.configs.dailyTaskConfig) do
		local drawOrder = v.drawOrder;
		local hasFinished = self:hasDailyTaskFinished(k);
		local hasAwarded = self:hasDailyTaskAwarded(k);
		if hasAwarded == false and hasFinished == true and v.level <= self:getLevel() then
			local tableItem = {
				['taskID'] = k;
				['drawOrder'] = drawOrder;
			};
			
			if not self:checkDailyTaskVIPBlock(k) then
				table.insert(awardedList, tableItem);
			end
		end
	end
	
	function awardComp(item1, item2)
		return item1.drawOrder < item2.drawOrder;
	end
	
	table.sort(awardedList, awardComp);
	
	return awardedList;
end

-- levellimit
function playerDataClass:getDailyTaskLevelLimitAwardedList()
	local levellimitList = {};
	--key 是 tastid， value是draworder
	for k,v in pairs(dataConfig.configs.dailyTaskConfig) do
		local drawOrder = v.drawOrder;
		local hasFinished = self:hasDailyTaskFinished(k);
		local hasAwarded = self:hasDailyTaskAwarded(k);
		if v.level > self:getLevel() then
			local tableItem = {
				['taskID'] = k;
				['drawOrder'] = drawOrder;
			};
			
			if not self:checkDailyTaskVIPBlock(k) then
				table.insert(levellimitList, tableItem);
			end
		end
	end
	
	function awardComp(item1, item2)
		return item1.drawOrder < item2.drawOrder;
	end
	
	table.sort(levellimitList, awardComp);
	
	return levellimitList;
end

function playerDataClass:isHaveCanGainedDailyTaskReward()
	return #self:getDailyTaskCanAwardedList() > 0;
end

function playerDataClass:isHaveCanGainedLevelReward()
	for k,v in ipairs(self:getLevelRewardList()) do
		if self:hasLevelRewardFinished(v) then
			return true;
		end
	end
	
	return false;
end

function playerDataClass:isCanGetLoginReward()
	for k,v in ipairs(self:getLoginRewardList()) do
		if self:hasLoginRewardFinished(v) then
			return true;
		end
	end
	
	return false;
end

function playerDataClass:isHaveCanGainedReward()
	return self:getLevel() >= dataConfig.configs.ConfigConfig[0].dailyButtonLevelLimit and (self:isHaveCanGainedDailyTaskReward() or
					self:isHaveCanGainedLevelReward() or
					self:isCanGetFreeVigor() or
					self:isCanGetLoginReward());
end

function playerDataClass:getDailyTaskUnfinishedList()
	local unfinishedList = {};
	--key 是 tastid， value是draworder
	for k,v in pairs(dataConfig.configs.dailyTaskConfig) do
		local drawOrder = v.drawOrder;
		local hasFinished = self:hasDailyTaskFinished(k);
		local hasAwarded = self:hasDailyTaskAwarded(k);
		if hasAwarded == false and hasFinished == false and v.level <= self:getLevel() then
			local tableItem = {
				['taskID'] = k;
				['drawOrder'] = drawOrder;
			};
			
			if not self:checkDailyTaskVIPBlock(k) then
				table.insert(unfinishedList, tableItem);
			end

		end
	end
	
	function awardComp(item1, item2)
		return item1.drawOrder < item2.drawOrder;
	end
	
	table.sort(unfinishedList, awardComp);
	
	return unfinishedList;
end

-- 表格数据中奖励的数据结构，统一的获得接口
function playerDataClass:getRewardInfo(rewardType, rewardID, rewardCount)
	local rewardInfo = {
		['id'] = rewardID,
		['count'] = rewardCount,
		['icon'] = "",
		['star'] = 1,
		['showstar'] = 0,
		['maskicon'] = nil;
		['isDebris'] = false;
		['backImage'] = nil;
		['selectImage'] = nil;
		['qualityImage'] = nil;
		['userdata'] = rewardID;
		['type'] = rewardType;
	};
	
	if rewardType == enum.REWARD_TYPE.REWARD_TYPE_ITEM then
		local itemConfigInfo = itemManager.getConfig(rewardID);
		if itemConfigInfo then
			rewardInfo.icon = itemConfigInfo.icon;
			rewardInfo.star = itemConfigInfo.star;
			rewardInfo.showstar = 0;
			if itemConfigInfo.type == enum.ITEM_TYPE.ITEM_TYPE_DEBRIS then
				rewardInfo.maskicon = "itemmask.png";
			end
		end
	elseif rewardType == enum.REWARD_TYPE.REWARD_TYPE_MONEY then
		rewardInfo.icon = enum.MONEY_ICON_STRING[rewardID];
	elseif rewardType == enum.REWARD_TYPE.REWARD_TYPE_CARD_EXP then
		--print("rewardID "..rewardID);
		--dump(cardData.getCardInstance(rewardID))
		--dump(cardData.getCardInstance(rewardID):getConfig())
		local configData = cardData.getConfigByTypeAndExp(rewardID, rewardCount);
		if configData then
			rewardInfo.icon = configData.icon;
			rewardInfo.star = cardData.getStarByExp(rewardCount);
			
			if table.find(dataConfig.configs.ConfigConfig[0].startLevelTable, rewardCount) then
				rewardInfo.count = 1;
				rewardInfo.showstar = rewardInfo.star;
			else
				rewardInfo.showstar = 0;
				rewardInfo.maskicon = "corpsmask.png";
			end
		end
	elseif rewardType == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
		if dataConfig.configs.magicConfig[rewardID] then
			rewardInfo.icon = dataConfig.configs.magicConfig[rewardID].icon;
			rewardInfo.star = dataManager.kingMagic:getStarByExp(rewardCount);
			rewardInfo.userdata = dataManager.kingMagic:mergeIDLevel(rewardInfo.id, rewardInfo.star);
			
			if table.find(dataConfig.configs.ConfigConfig[0].magicLevelExp, rewardCount) then
				rewardInfo.count = 1;
				rewardInfo.showstar = rewardInfo.star;
			else
				rewardInfo.maskicon = "corpsmask.png";
				rewardInfo.showstar = 0;
			end
						
		end
		
	elseif rewardType == enum.REWARD_TYPE.REWARD_TYPE_PRIMAL then
		
		local itemInfo = dataManager.idolBuildData:getPrimalItemInfo(rewardID);
		
		if itemInfo then
			rewardInfo.icon = itemInfo.icon;
			rewardInfo.star = itemInfo.star;
			rewardInfo.showstar = 0;
		end
		
	end
	
	rewardInfo.isDebris = rewardInfo.maskicon ~= nil;
	
	rewardInfo.backImage = itemManager.getBackImage(rewardInfo.isDebris);
	rewardInfo.selectImage = itemManager.getSelectImage(rewardInfo.isDebris);
	rewardInfo.qualityImage = itemManager.getImageWithStar(rewardInfo.star, rewardInfo.isDebris);
	
	return rewardInfo;
	
end

-- 等级奖励
function playerDataClass:hasLevelRewardFinished(levelRewardID)
	local currentLevelReward = self:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_LEVEL_REWARD);
	
	local config = self:getLevelRewardConfig(levelRewardID);
	if config then
		return self:getLevel() >= config.level and (levelRewardID == (currentLevelReward+1));
	end
	
	return false;
end

-- 是否已经领取
function playerDataClass:hasLevelRewardGained(levelRewardID)
	local currentLevelReward = self:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_LEVEL_REWARD);
	--记录的是当前领到哪个
	return levelRewardID <= currentLevelReward;
end

-- 获取等级奖励表格信息
function playerDataClass:getLevelRewardConfig(levelRewardID)
	return dataConfig.configs.levelRewardConfig[levelRewardID];
end

-- 获取等级奖励的id list
function playerDataClass:getLevelRewardList()
	local rewardList = {};
	
	for k,v in pairs(dataConfig.configs.levelRewardConfig) do
		table.insert(rewardList, v.id);
	end
	
	table.sort(rewardList);
	
	return rewardList;
end

-- 获取连续登录奖励的id list
function playerDataClass:getLoginRewardList()
	local rewardList = {};
	
	for k,v in pairs(dataConfig.configs.loginRewardConfig) do
		table.insert(rewardList, v.id);
	end
	
	table.sort(rewardList);
	
	return rewardList;
end

-- 获取登录奖励表格信息
function playerDataClass:getLoginRewardConfig(loginRewardID)
	return dataConfig.configs.loginRewardConfig[loginRewardID];
end

-- 是否已经领取(决定ui上显示不显示)
function playerDataClass:hasLoginRewardGained(loginRewardID)
	local currentLoginRewardDays = self:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_LOGIN_REWARD);
	
	local rewardList = self:getLoginRewardList();
	local maxConfig = self:getLoginRewardConfig(rewardList[#rewardList]);
	local config = self:getLoginRewardConfig(loginRewardID);
	
	local nowOnlineDays = self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_ONLINE_DAYS);
	
	print("nowOnlineDays "..nowOnlineDays);
	print("currentLoginRewardDays "..currentLoginRewardDays);
	print("loginRewardID "..loginRewardID);
	print("maxConfig.id "..maxConfig.id);
	
	if loginRewardID == maxConfig.id then
		-- 只在15天都领完 最后一个的每日奖励才出现
		if currentLoginRewardDays < (maxConfig.id - 1) then
			return true;
		else
			return currentLoginRewardDays == nowOnlineDays;
		end
		
	else
		return currentLoginRewardDays >= config.id;
	end

end

-- 是否可以领取（决定领取按钮是否可以点击）
function playerDataClass:hasLoginRewardFinished(loginRewardID)
	local currentLoginRewardDays = self:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_LOGIN_REWARD);
	
	local rewardList = self:getLoginRewardList();
	local maxConfig = self:getLoginRewardConfig(rewardList[#rewardList]);
	local config = self:getLoginRewardConfig(loginRewardID);
	
	local nowOnlineDays = self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_ONLINE_DAYS);
	
	if loginRewardID == maxConfig.id then
		-- 只在15天都领完 最后一个的每日奖励才出现
		-- 出现了就肯定是可以领的，不能领就看不见
		return currentLoginRewardDays >= (maxConfig.id - 1) and currentLoginRewardDays < nowOnlineDays;
	else
		return nowOnlineDays >= config.id and (currentLoginRewardDays + 1) == config.id;
	end
	
end

-- 是否可以领取首冲
function playerDataClass:hasFinishedFirstCharge()
	return self:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_RMB) > 0;
end

-- 是否已经领取首冲
function playerDataClass:hasGainedFirstCharge()
	return self:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_FIRST_RECHARGE_REWARD) ~= 0;
end

-- 是否第一次登录
function playerDataClass:isFirstLogin()
	local resetTimeStr = dataConfig.configs.ConfigConfig[0].playerRefleshTime;
	local hour, minute = stringToTime(resetTimeStr);
	local sererTime = dataManager.getServerTime();
	local sererTimeTable = os.date("*t", sererTime);
	print("today is year:"..sererTimeTable.year.." month "..sererTimeTable.month.." day "..sererTimeTable.day);
	
	local resetTime = os.time({year = sererTimeTable.year, month = sererTimeTable.month, day = sererTimeTable.day, hour = hour, min = minute});
	print("resetTime "..resetTime);
	
	return self:getTimeAttr(enum.PLAYER_ATTR64.PLAYER_ATTR64_LOGIN) >= resetTime and
				self:getTimeAttr(enum.PLAYER_ATTR64.PLAYER_ATTR64_LOGOUT) < resetTime;
end

-- 极限挑战当前的第几关 0 开始
function playerDataClass:getSpeedChallengeStage()
	return self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_CHALLENGE_SPEED_STAGE);
end

-- 极限挑战第几关的stageID
function playerDataClass:getSpeedChallegeStageID(stageIndex)
	if dataConfig.configs.ConfigConfig[0] and dataConfig.configs.ConfigConfig[0].challengeSpeedStageID then
		return dataConfig.configs.ConfigConfig[0].challengeSpeedStageID[stageIndex+1];
	end
	
	return nil;
end

-- 极限挑战第几关的stageInfo
function playerDataClass:getSpeedChallegeStageInfo(stageIndex)
	return dataConfig.configs.stageConfig[self:getSpeedChallegeStageID(stageIndex)];
end

-- 极限挑战当前战斗回合数
function playerDataClass:getSpeedChallegeRound()
	return self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_CHALLENGE_SPEED_ROUND);
end

-- 极限挑战当前失败次数
function playerDataClass:getSpeedChallegeFailedCount()
	return self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_CHALLENGE_SPEED_FAIL);
end

-- 极速挑战挑战次数
function playerDataClass:getSpeedChanllegeTimes()
	return self:getSpeedChallegeFailedCount() + self:getSpeedChallengeStage();
end

-- 切磋次数
function playerDataClass:getFriendContestTimes()
    return self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_FRIEND_CONTEST_TIMES);
end

-- 掠夺/复仇次数
function playerDataClass:getTotalPlunderTimes()
    return self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_TOTAL_PLUNDER_TIMES);
end

-- 远征挑战次数
function playerDataClass:getCrusadeTimes()
    return dataManager.crusadeActivityData:getCurrentStageIndex()-1;
end

-- 赠送体力
function playerDataClass:getGiftVigorTimes()
    return self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_FRIEND_VIGOR_GIFT_TIMES);
end

-- 极限挑战最大失败次数
function playerDataClass:getSpeedChallegeMaxFailedCount()
	return self:getVipConfig().challengeSpeedFailLimit;
end

-- 当前是否通关了
function playerDataClass:isSpeedChallegeSuccess()
	return self:getSpeedChallengeStage() == #dataConfig.configs.ConfigConfig[0].challengeSpeedStageID;
end

-- 是否可以开战
function playerDataClass:isSpeedChallegeCanStart()
	-- 根据时间判断
	local beginTime = dataConfig.configs.ConfigConfig[0].playerRefleshTime;
	local endTime = dataConfig.configs.ConfigConfig[0].challengeSpeedCloseTime;
	return isTimeValid(beginTime, endTime);
end

-- 根据回合数获得奖励的档次
function playerDataClass:getSpeedChallegeReward()
	local round = self:getSpeedChallegeRound();
	for k,v in ipairs(dataConfig.configs.challengeSpeedConfig) do
		if round <= v.bracket then 
			return v.rewardType, v.rewardID, v.rewardCount;
		end
	end
	
	local lastone = dataConfig.configs.challengeSpeedConfig[#dataConfig.configs.challengeSpeedConfig];
	
	return lastone.rewardType, lastone.rewardID, lastone.rewardCount;
end

function playerDataClass:isSpeedChallegeStageCanStart(stageIndex)
	return ( self:getSpeedChallengeStage() == stageIndex and 
						self:getSpeedChallegeFailedCount() < self:getSpeedChallegeMaxFailedCount());
end

function playerDataClass:isLevelEnoughToSpeedChallege()
	return self:getLevel() >= self:getSpeedLevelLimit();
end

function playerDataClass:getSpeedLevelLimit()
	return dataConfig.configs.ConfigConfig[0].challengeSpeedLevelLimit;
end

-- 副本挑战相关
function playerDataClass:getChallegeStageTimesLeft()
	local lefttimes =  self:getVipConfig().challengeStageTimes - self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_CHALLENGE_STAGE_TIMES);
	if lefttimes < 0 then
		lefttimes = 0;
	end
	
	return lefttimes;
end

-- 下次挑战的剩余时间
function playerDataClass:getNextChallegeStageTime()
	local nextTime = self:getTimeAttr(enum.PLAYER_ATTR64.PLAYER_ATTR64_STAGE_CHALLENGE_COOLDOWN) - dataManager.getServerTime();
	--print("self:getTimeAttr(enum.PLAYER_ATTR64.PLAYER_ATTR64_STAGE_CHALLENGE_COOLDOWN)"..self:getTimeAttr(enum.PLAYER_ATTR64.PLAYER_ATTR64_STAGE_CHALLENGE_COOLDOWN));
	if nextTime < 0 then
		nextTime = 0;
	end
	return nextTime;
end

-- 根据索引获得某个副本的信息 index 从1开始, battleType 是类型普通，精英，地狱
function playerDataClass:getChallegeStageInfo(battleType, stageIndex)
	local stageid = nil;
	
	--print("getChallegeStageInfo battleType "..battleType.." stageIndex "..stageIndex)
	
	if battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL then
	
		stageid = dataConfig.configs.challengeStageConfig[stageIndex].normal;
		
	elseif battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE then
		
		stageid = dataConfig.configs.challengeStageConfig[stageIndex].elite;
		
	elseif battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL then
		
		stageid = dataConfig.configs.challengeStageConfig[stageIndex].hall;
		
	end
	
	if stageid then
		return dataConfig.configs.stageConfig[stageid];
	else
		return nil;
	end
end

-- 获取等级是否满足
function playerDataClass:isChallegeStageLevelEnough(battleType, stageIndex)
	local levelLimit = dataConfig.configs.challengeStageConfig[stageIndex].levelLimit;
	if levelLimit then
		return self:getLevel() >= levelLimit;
	else
		return false;
	end
end

-- 获取等级限制
function playerDataClass:getChallegeStageLevelLimit(battleType, stageIndex)
	local levelLimit = dataConfig.configs.challengeStageConfig[stageIndex].levelLimit;
	return levelLimit;
end

-- 获取副本关数
function playerDataClass:getChallegeStageCount(battleType)

	return #dataConfig.configs.challengeStageConfig;
	
end

-- 获得当前副本挑战进度
function playerDataClass:getChallengeStageProgress(battleType)
	return self:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_CHALLENGE_STAGE_PROCESS);
end

-- 是否可打
function playerDataClass:isChallengeStageCanStart(battleType, stageIndex)
	return self:getChallengeStageProgress(battleType) >= (stageIndex-1) and self:isChallegeStageLevelEnough(battleType, stageIndex);
end

-- 设置当前打的副本挑战的stageid
function playerDataClass:setChallegeStageIndex(stageIndex)
	self.challegeStageIndex = stageIndex;
end

function playerDataClass:getChallegeStageIndex()
	return self.challegeStageIndex;
end

-- 活动有没完成的
function playerDataClass:isHaveActivitys()
	local speed = self:isSpeedChallegeCanStart() and (self:getSpeedChallegeFailedCount() < self:getSpeedChallegeMaxFailedCount());
	local copy = (self:getChallegeStageTimesLeft() > 0) and self:getNextChallegeStageTime() == 0;
	local damage = dataManager.hurtRankData:isBattleNumEnough() and dataManager.hurtRankData:isOpenTime();
	
	return speed or copy or damage;
end

function playerDataClass:parseTextSetArr(...)
	
	for k,v in ipairs{...} do
		self.parseTextArr[k] = v;
	end
	
	return "";
end

function playerDataClass:parseTextGetArr(k)
	return self.parseTextArr[k];
end

function playerDataClass:parseText(text, magicID, level, intelligence)
	
	local MAGIC_LEVEL = "魔法等级";
	local KING_INTELLIGENCE = "国王智力";
	local SET_FUNC_NAME = "设置浮点数组";
	local GET_FUNC_NAME = "获取浮点元素";
	self.parseTextArr = {};
	
	dataManager.kingMagic:setTipsMagicID(magicID);
	dataManager.kingMagic:setTipsMagicLevel(level);
	dataManager.kingMagic:setTipsMagicIntelligence(intelligence);
	
	local splitTexts = string.split(text, "$$");
	local result = "";
	
	for i, v in ipairs(splitTexts) do
		
		local convert = "";
		convert = string.gsub(v, MAGIC_LEVEL, "level");
		convert = string.gsub(convert, KING_INTELLIGENCE, "intelligence");
		convert = string.gsub(convert, SET_FUNC_NAME, "dataManager.playerData:parseTextSetArr");
		convert = string.gsub(convert, GET_FUNC_NAME, "dataManager.playerData:parseTextGetArr");
		
		--print(convert);
		if convert ~= v then
			-- 计算值
			convert = 
			"local level = dataManager.kingMagic:getTipsMagicLevel();\
			local intelligence = dataManager.kingMagic:getTipsMagicIntelligence();\
				return "..convert;
			
			--print("tips magicID "..magicID);					 
			--print(convert);
			local value = loadstring(convert);
			--print(value());
			local ret = value();
			if type(ret) == "number" then
				ret = math.ceil(ret);
			end
			result = result..ret;
		else
			result = result..v;
		end
		
	end
	
	return result;
end

function playerDataClass:drawOneCard()
	
	local drawType = enum.DRAW_CARD_TYPE.DRAW_CARD_TYPE_INVALID;
	
	local nextFreeTime = self:getTimeAttr(enum.PLAYER_ATTR64.PLAYER_ATTR64_NEXT_FREE_DRAW_TIME);
	local waitTime = nextFreeTime - dataManager.getServerTime();
	
	if waitTime > 0 then
		-- 时间还没到
		drawType = enum.DRAW_CARD_TYPE.DRAW_CARD_TYPE_ONCE;
	else
		-- 可以免费抽
		drawType = enum.DRAW_CARD_TYPE.DRAW_CARD_TYPE_FREE;
	end
	
		
	local diamond = self:getGem();
	
	if drawType ~= enum.DRAW_CARD_TYPE.DRAW_CARD_TYPE_FREE and diamond < cardData.oneCost then
		-- 钱不够
			eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.LACK_OF_DIMOND, data = -1, 
				text = "当前钻石不足，是否充值？" });			
	else
		sendDrawCard(drawType);
		global.setFlag("sendDrawCard", true);
	end
	
end

function playerDataClass:drawTenCard()

	local diamond = self:getGem();
	if diamond < cardData.tenCost then
		-- 钱不够
			eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.LACK_OF_DIMOND, data = -1, 
				text = "当前钻石不足，是否充值？" });			
	else
		sendDrawCard(enum.DRAW_CARD_TYPE.DRAW_CARD_TYPE_TENTIMES);
		global.setFlag("sendDrawCard", true);
		
		eventManager.dispatchEvent({name = global_event.CORPSGET2_UPDATE_BUTTON, state = false});
	end	
end

function playerDataClass:getNextDrawCardLuckyTimes()
	
	local drawTimes = self:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_DRAW_TIMES);
	local cardAwardsNode = dataConfig.configs.ConfigConfig[0].cardAwardsNode;
	local times = math.fmod(drawTimes+1, cardAwardsNode);
	
	local remainTimes = cardAwardsNode - times;
	
	if remainTimes == cardAwardsNode then
		return 0;
	else
		return remainTimes;		
	end

end

function playerDataClass:setNextDrawCardLuckyTimes(times)
	self.nextLuckyCardTimes = times;
end

-- 战斗开始前备份一下金币，木头和钻石
-- 战斗结束后需要计算增长
function playerDataClass:backupMoney()
	self.backupMoneys = self.backupMoneys or {};
	
	self.backupMoneys[enum.MONEY_TYPE.MONEY_TYPE_GOLD] = self:getGold();
	self.backupMoneys[enum.MONEY_TYPE.MONEY_TYPE_LUMBER] = self:getWood();
	self.backupMoneys[enum.MONEY_TYPE.MONEY_TYPE_DIAMOND] = self:getGem();
	
end

-- 战斗结束后需要计算增长
function playerDataClass:checkMoneyAward()
										
end

-- 检查vip对应几级开启购买经验
function playerDataClass:getBuyExpVipLevel()
	
	local count = table.nums(dataConfig.configs.vipConfig);
	
	for i=0, count-1 do
		
		local config = dataConfig.configs.vipConfig[i];
		
		if config.buyLostExpTimes > 0 then
			return i;
		end
		
	end
	
	return -1;
end

-- 检查vip对应几级开启重置副本
function playerDataClass:getResetTimesVipLevel()
	
	local count = table.nums(dataConfig.configs.vipConfig);
	
	for i=0, count-1 do
		
		local config = dataConfig.configs.vipConfig[i];
		
		if config.resetTimes > 0 then
			return i;
		end
		
	end
	
	return -1;
end

return playerDataClass
