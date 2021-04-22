--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林数据管理

local QBaseModel = import("...models.QBaseModel")
local QSilverMine = class("QSilverMine", QBaseModel)
local QStaticDatabase = import("...controllers.QStaticDatabase")

QSilverMine.NEW_DAY = "QSILVERMINE_NEW_DAY"
QSilverMine.MY_INFO_UPDATE = "QSILVERMINE_MY_INFO_UPDATE"
QSilverMine.CAVE_LIST_UPDATE = "QSILVERMINE_CAVE_LIST_UPDATE"
QSilverMine.CAVE_UPDATE = "QSILVERMINE_CAVE_UPDATE"
QSilverMine.MINE_FINISH_UPDATE = "QSILVERMINE_MINE_FINISH_UPDATE"
QSilverMine.BUY_GOLDPICKAXE = "QSILVERMINE_BUY_GOLDPICKAXE"
QSilverMine.SILVER_ASSIST_UPDATE = "SILVER_ASSIST_UPDATE"
-- QSilverMine.NO_GOLDPICKAXE = "QSILVERMINE_NO_GOLDPICKAXE"

function QSilverMine:ctor()
	QSilverMine.super.ctor(self)
end

function QSilverMine:init()
	self._remoteProexy = cc.EventProxy.new(remote.user)
    self._remoteProexy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, function ()
        self:_checkSilverMineUnlock()
    end)

    self.mineCaves = {}
    self.opportunity = {}
    self._dispatchTBl = {}
    self._helpList = {} -- 协助邀请
    self._allItemIds = {} -- 保存魂兽森林可能产出的item的id
    self._things = {} -- 保存事件的id
    self._lock = false -- 魂兽森林防止频繁操作的统一的锁。
    self._lockByTime = false -- 锁，但是不受response解锁
    self._aniLock = false -- 锁，用于播放动画的时候，自动解锁的时间较长，一般动画播放完解锁
    self._isWaitShowChangeAni = false
    self._isFirstGoldPickaxe = true -- 有没有点过黄金框镐
    self.curCaveType = SILVERMINEWAR_TYPE.SENIOR
    self.miningLv = 0
    self.assistCount = 0
    self.isNeedShowAward = true -- 进入魂兽森林一级或二级的时候，如果有奖励可以领取，自动弹框。每次登入后只有第一次进入的时候弹框
    -- self.isNeedShowGoldPickaxeRedTips = true -- 进入魂兽森林一级或二级的时候，如果有魂兽区显示诱魂草小红点。
    self:_analysisThingConfig()
end

function QSilverMine:disappear()

end

function QSilverMine:loginEnd()
	--xurui: 登录结束后先拉一次魂兽森林信息
	if self:_checkSilverMineUnlock() then
    	self:silvermineGetMyInfoRequest()
    end
end

function QSilverMine:newDayUpdate()
	self.fightCount = QStaticDatabase.sharedDatabase():getConfigurationValue("silvermine_num")
	self:setCaveRegion( SILVERMINEWAR_TYPE.SENIOR, true )
	self:dispatchEvent( { name = QSilverMine.NEW_DAY } )
end

--------------数据储存--------------

-- 设置魂兽区
function QSilverMine:setCaveRegion( caveRegion, isForce ) 
	if not self.caveRegion or isForce or self.caveRegion ~= caveRegion then
		self.caveRegion = caveRegion
		self:_changeCaveRegion()
	end
end

-- 获取魂兽区
function QSilverMine:getCaveRegion()
	return self.caveRegion
end

-- 获取已购买狩猎的次数
function QSilverMine:getBuyFightCount()
	return self.buyFightCount or 0
end

-- 获取已购买诱魂草的次数
function QSilverMine:getMiningPickBuyCount()
	return self.miningPickBuyCount or 0
end

-- 获取战斗次数
function QSilverMine:getFightCount()
	return self.fightCount or QStaticDatabase.sharedDatabase():getConfigurationValue("silvermine_num")
end

-- 获取防守阵容
function QSilverMine:getDefenseArmy()
	return self.defenseArmy or {}
end

-- 获取防守战力
function QSilverMine:getDefenseForce()
	return self.defenseForce or 0
end

-- 获取狩猎等级
function QSilverMine:getMiningLv()
	return self.miningLv or 0
end

-- 获取狩猎经验
function QSilverMine:getMiningExp()
	return self.miningExp or 0
end

-- 获取自己狩猎信息
-- optional int32 mineId = 1;                                                  //魂兽森林ID
-- optional string occupyId = 2;                                               //狩猎事件ID
-- optional int64 startAt = 3;                                                 //狩猎开始时间
-- optional int64 endAt = 4;                                                   //战况结束时间
-- optional string occupyAward = 5;                                            //当前已获得的狩猎奖励
-- optional string miningAward = 6;                                            //当前已获得的狩猎奖励
-- optional int32 extendCount = 7;                                             //已进行过的延长狩猎次数
-- optional string ownerId = 8;                                                //狩猎者ID
-- optional string ownerName = 9;                                              //狩猎者名称
-- optional int32 consortiaBonus = 10;                                         //狩猎宗门加成
-- optional string consortiaId = 11;                                           //宗门ID
-- optional string consortiaName = 12;                                         //宗门名称
-- optional int32 defenseForce = 13;                                           //守魂兽区部队的战斗力
-- optional int32 defenseWinCount = 14;                                        //守魂兽区胜利次数
-- repeated AssistUserInfo assistUserInfo = 15;                                //参加协助的玩家ID
-- optional string oriOccupyId = 16;                                           //原始的occupyID
-- optional int32 inviteAssistCount = 17;                                      //邀请次数
-- optional int64 miningPickEndAt = 18;                                        //诱魂草结束时间
function QSilverMine:getMyOccupy()
	return self.myOccupy or {}
end

-- 是否需要弹出狩猎等级升级界面
function QSilverMine:setIsLevelUp( boo )
	self.isLevelUp = boo
end

function QSilverMine:getIsLevelUp()
	return self.isLevelUp
end

function QSilverMine:setIsRecordRedTip( boo )
	self.isRecordRedTip = boo
	self:dispatchEvent({name = QSilverMine.MY_INFO_UPDATE})
end

function QSilverMine:getIsRecordRedTip()
	return self.isRecordRedTip
end

--战况总时间
function QSilverMine:getTotalOccupySecs()
	return self.totalOccupySecs
end

function QSilverMine:setCurCaveType( int )
	self.curCaveType = int
end

function QSilverMine:getCurCaveType()
	return self.curCaveType
end

function QSilverMine:setShareTime( time )
	self._shareTime = time
end

function QSilverMine:getShareTime()
	return self._shareTime or 0
end

function QSilverMine:setIsShareRedTips( boo )
	self._isShareRedTips = boo
end

function QSilverMine:getIsShareRedTips()
	return self._isShareRedTips
end

function QSilverMine:setIsNeedShowMineId( int )
	self._isNeedShowMineId = int
end

function QSilverMine:getIsNeedShowMineId()
	if self._isNeedShowMineId and self._isNeedShowMineId > 0 then
		if self.myOccupy and table.nums(self.myOccupy) > 0 then
			if self.myOccupy.mineId ~= self._isNeedShowMineId then
				self._isNeedShowMineId = 0
			end
		else
			self._isNeedShowMineId = 0
		end
	end
	
	return self._isNeedShowMineId or 0
end

function QSilverMine:setFinishMineId( mineId )
	self._curFinishMineId = mineId
end

function QSilverMine:getFinishMineId()
	return self._curFinishMineId
end

function QSilverMine:setIsNeedShowAward( boo )
	self.isNeedShowAward = boo
end

function QSilverMine:getIsNeedShowAward()
	return self.isNeedShowAward
end

-- function QSilverMine:setIsNeedShowGoldPickaxeRedTips( boo )
-- 	self.isNeedShowGoldPickaxeRedTips = boo
-- end

-- function QSilverMine:getIsNeedShowGoldPickaxeRedTips()
-- 	return self.isNeedShowGoldPickaxeRedTips
-- end

function QSilverMine:setIsNeedShowChangeAni( boo )
	self._isNeedShowChangeAni = boo
end

function QSilverMine:getIsNeedShowChangeAni()
	return self._isNeedShowChangeAni
end

function QSilverMine:setIsWaitShowChangeAni( boo )
	self._isWaitShowChangeAni = boo
end

function QSilverMine:getIsWaitShowChangeAni()
	return self._isWaitShowChangeAni
end

function QSilverMine:setIsFirstGoldPickaxe( boo )
	self._isFirstGoldPickaxe = boo
end

function QSilverMine:getIsFirstGoldPickaxe()
	return self._isFirstGoldPickaxe
end

--------------调用素材--------------

-- 获取小锤子动画
function QSilverMine:getHammer()
	return {x = -20, y = -60}, "ccb/effects/kuangtong_gxps.ccbi"
end

-- 获取诱魂草动画
function QSilverMine:getGoldPickaxe()
	return {x = -120, y = -10}, "ccb/effects/kuangtong2_gxps.ccbi"
end

-- 获取我的魂兽区的光效动画
function QSilverMine:getGuang()
	return {x = 0, y = 0}, "ccb/effects/Arena_one_guang5.ccbi"
end

-- 获取狩猎特效
function QSilverMine:getWin()
	-- return {x = 0, y = 0}, "ccb/Widget_SilverMine_holdwin.ccbi"
	return {x = 0, y = 0}, "ccb/effects/ChooseHero.ccbi"
	
end

-- 获取结算动画
function QSilverMine:getFinish( index )
	return {x = 0, y = 0}, "ccb/effects/yinkuangzhan_baoshi_"..index..".ccbi"
end

-- 获取普通魂兽区镐转变成诱魂草的动画
function QSilverMine:getChangeEffect()
	return {x = -108, y = 28}, "ccb/effects/fumo_effect_k.ccbi"
end

--------------便民工具--------------

function QSilverMine:addLock()
	if self._scheduler then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end

	self._lock = true
    self._scheduler = scheduler.performWithDelayGlobal(function ()
	        self:removeLock()
	    end, 0.5)
end

function QSilverMine:isLock()
	return self._lock 
end

function QSilverMine:removeLock()
	if self._scheduler then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end
    self._lock = false
end

function QSilverMine:addLockByTime()
	if self._lockByTimescheduler then
        scheduler.unscheduleGlobal(self._lockByTimescheduler)
        self._lockByTimescheduler = nil
    end

	self._lockByTime = true
    self._lockByTimescheduler = scheduler.performWithDelayGlobal(function ()
	        self:removeLockByTime()
	    end, 0.5)
end

function QSilverMine:isLockByTime()
	return self._lockByTime 
end

function QSilverMine:removeLockByTime()
	if self._lockByTimescheduler then
        scheduler.unscheduleGlobal(self._lockByTimescheduler)
        self._lockByTimescheduler = nil
    end
    self._lockByTime = false
end

function QSilverMine:addAniLock()
	if self._aniScheduler then
        scheduler.unscheduleGlobal(self._aniScheduler)
        self._aniScheduler = nil
    end

	self._aniLock = true
    self._aniScheduler = scheduler.performWithDelayGlobal(function ()
	        self:removeAniLock()
	    end, 3)
end

function QSilverMine:isAniLock()
	return self._aniLock 
end

function QSilverMine:removeAniLock()
	if self._aniScheduler then
        scheduler.unscheduleGlobal(self._aniScheduler)
        self._aniScheduler = nil
    end
    self._aniLock = false
end

--魂兽森林小红点
function QSilverMine:checkSilverMineRedTip()
	if self:_checkSilverMineUnlock() then
		-- print("1")
		if self:checkSilverMineAwardRedTip() then return true end
		-- print("2")
		if self:checkSilverMineAttackCountRedTip() then return true end
		-- print("3")
		if self:checkSilverMineShopRedTip() then return true end
		-- print("4")
		if self:checkSilverMineAssistRedTip() then return true end
		-- print("5")
		if not remote.teamManager:checkTeamStormIsFull(remote.teamManager.SILVERMINE_DEFEND_TEAM) then return true end
		-- print("6")
		-- if self:checkSilverMineGoldPickaxeRedTip() then return true end
	end
	-- return false
end

--魂兽森林狩猎奖励小红点
function QSilverMine:checkSilverMineAwardRedTip()
	if self.awardCount and self.awardCount > 0 then
		return true
	end
	return false
end

--魂兽森林狩猎次数小红点（有次数，未狩猎）
function QSilverMine:checkSilverMineAttackCountRedTip()
	if self.myOccupy and table.nums(self.myOccupy) > 0 then
		-- 自己有狩猎
		return false
	elseif (self.fightCount or 0) > 0 then
		-- 自己没狩猎，但有次数
		return true
	end
	return false
end

--魂兽森林商店小红点
function QSilverMine:checkSilverMineShopRedTip()
	return remote.exchangeShop:checkExchangeShopRedTipsById(SHOP_ID.silverShop)
end

--银魂兽区协助小红点
function QSilverMine:checkSilverMineAssistRedTip()
	if self.myOccupy ~= nil then
		local inviteAssistCount = 0
		local assistCount = 0
		if self.myOccupy.inviteAssistCount ~= nil then
			inviteAssistCount = self.myOccupy.inviteAssistCount
		end
		if self.myOccupy.assistUserInfo ~= nil then
			assistCount = #self.myOccupy.assistUserInfo
		end
		return inviteAssistCount > 0 and assistCount < self:getAssistTotalCount()
	end
	return false
end

--魂兽森林诱魂草小红点
function QSilverMine:checkSilverMineGoldPickaxeRedTip()
	if not self:getIsFirstGoldPickaxe() then
		return false
	end
	local myOccupy = self:getMyOccupy()
	local isOvertime = self:updateGoldPickaxeTime(true)
	if myOccupy and table.nums(myOccupy) > 0 and isOvertime then
		return true
	end
	return false
end

-- 根据cave_region 获取魂兽森林的配置
function QSilverMine:getCaveConfigByCaveRegion( caveRegion )
	local tbl = {}
	local caveConfigs = QStaticDatabase.sharedDatabase():getSilvermineCaveConfigs()
	for _, config in pairs(caveConfigs) do
		if config.cave_region == tonumber(caveRegion) then
			table.insert(tbl, config)
		end
	end
	table.sort(tbl, function(a, b) return a.cave_id < b.cave_id end)
	return tbl
end

-- 根据cave_id 获取魂兽森林的配置
function QSilverMine:getCaveConfigByCaveId( caveId )
	local caveConfigs = QStaticDatabase.sharedDatabase():getSilvermineCaveConfigs()
	for _, config in pairs(caveConfigs) do
		if config.cave_id == caveId then
			return config
		end
	end
	return nil
end

-- 根据cave_id和mine_id 获取巢穴的配置
function QSilverMine:getMineConfigByMineId( mineId )
	local mineConfigs = QStaticDatabase.sharedDatabase():getSilvermineMineConfigs()
	if mineConfigs and table.nums(mineConfigs) > 0 then
		for _, config in pairs(mineConfigs) do
			if config.mine_id == mineId then
				return config
			end
		end
	end
	return nil
end

--获取配置的协助邀请次数
function QSilverMine:getInviteCount()
	return QStaticDatabase:sharedDatabase():getConfiguration().yaoqingxiezhu_cishu_1.value or 0
end

--协助的最大人数
function QSilverMine:getAssistTotalCount()
	return 3
end

-- 根据mine_id 获取cave的配置
function QSilverMine:getCaveConfigByMineId( mineId )
	local caveId = tonumber(string.sub(mineId, 1, 4))
	local caveConfig = self:getCaveConfigByCaveId(caveId)
	if caveConfig and table.nums(caveConfig) > 0 then
		local mines = caveConfig.mine_ids
		local isFind = string.find(mines, mineId)
		if isFind then
			return caveConfig
		end
	end

	local caveConfigs = QStaticDatabase.sharedDatabase():getSilvermineCaveConfigs()
	for _, config in pairs(caveConfigs) do
		local mines = config.mine_ids
		local isFind = string.find(mines, mineId)
		if isFind then
			return config
		end
	end

	return nil
end

function QSilverMine:getLevelConfigByLevel( level )
	local levelConfigs = QStaticDatabase.sharedDatabase():getSilvermineLevelConfigs()
	if levelConfigs and table.nums(levelConfigs) > 0 then
		for _, config in pairs(levelConfigs) do
			if config.level == level then
				return config
			end
		end
	end
	return nil
end

function QSilverMine:getCaveInfoByCaveId( caveId )
	if not self.mineCaves or table.nums(self.mineCaves) == 0 then return nil end
	return self.mineCaves[caveId]
end

function QSilverMine:getMineInfoByMineId( mineId )
	local caveId = self:getCaveIdByMineId( mineId )
	local caveInfo = self:getCaveInfoByCaveId( caveId )
	if caveInfo and caveInfo.occupies and  table.nums(caveInfo.occupies) > 0 then
		for _, occupy in pairs(caveInfo.occupies) do
			if occupy.mineId == mineId then
				return occupy
			end
		end
	end
	return nil
end

-- function QSilverMine:getOpportunitysByMineId( mineId )
-- 	if not self.opportunity or table.nums(self.opportunity) == 0 then return nil end
-- 	return self.opportunity[mineId]
-- end

-- function QSilverMine:getOpportunityByMineIdAndOccupyId( mineId, occupyId )
-- 	local tbl = self:getOpportunitysByMineId(mineId)
-- 	if not tbl or table.nums(tbl) == 0 then return nil end
-- 	return tbl[occupyId]
-- end

-- 获取狩猎者的信息（BOSS狩猎没有occupy）
function QSilverMine:getMineOccupyInfoByMineID( mineId )
	for _, caveInfo in pairs(self.mineCaves or {}) do
		for _, occupy in pairs(caveInfo.occupies or {}) do
			if occupy.mineId == mineId then
				return occupy
			end
		end
	end
end

-- 获取狩猎协助的信息
function QSilverMine:setMineAssistInfo()
	self._helpList = {}
	for i, caveInfo in pairs(self.mineCaves or {}) do
		if caveInfo.isInvite then
			table.insert(self._helpList, caveInfo)
		end
	end
end

function QSilverMine:getMineAssistInfo()
	return self._helpList
end

function QSilverMine:getMineAssistNum()
	local assistCount = self.assistCount or 0
	if assistCount <= 0 then
		return 0
	end
	return self.inviteAssistNum or 0
end

function QSilverMine:getMyConsortiaId()
	local myConsortiaId = remote.user.userConsortia.consortiaId
	if not myConsortiaId and self.myOccupy and self.myOccupy.consortiaId then
		myConsortiaId = self.myOccupy.consortiaId
	end
	return myConsortiaId or ""
end

function QSilverMine:getMyUserId()
	return remote.user:getPropForKey("userId")
end

-- 计算狩猎者的类型
function QSilverMine:getLordTypeByMineId( mineId )
	local occupy = self:getMineOccupyInfoByMineID( mineId )
	if occupy and occupy.ownerId then
		if occupy.ownerId == self:getMyUserId() then
			-- 自己的魂兽区
			return LORD_TYPE.SELF
		else
			-- 他人的魂兽区
			if occupy.consortiaId == self:getMyConsortiaId() then
				-- 宗门成员
				return LORD_TYPE.SOCIETY
			else
				-- 其他玩家
				return LORD_TYPE.NORMAL
			end
		end
	else
		-- BOSS的魂兽区
		return LORD_TYPE.BOSS
	end
end

function QSilverMine:getThingConfigById( thingId )
	local thingsConfigs = QStaticDatabase.sharedDatabase():getSilvermineThingsConfigs()
	for _, config in pairs(thingsConfigs) do
		if config.things_id == thingId then
			return config
		end
	end
	return nil
end

function QSilverMine:getActorById( actorId )
	local character = QStaticDatabase.sharedDatabase():getCharacterByID(actorId)
	return character
end

-- 获得守魂兽区NPC的信息
function QSilverMine:getNPCInfoById( dungeon_monster_id )
	local config = QStaticDatabase.sharedDatabase():getMonstersById( dungeon_monster_id )
	if config and table.nums(config) > 0 then
		for _, value in pairs(config) do
			if value.is_boss then
				return self:getActorById(value.npc_id)
			end
		end
	end
	if config and config[1] and config[1].npc_id then
		return self:getActorById(config[1].npc_id)
	end
end

-- mineId转成caveId
function QSilverMine:getCaveIdByMineId( mineId )
	local caveConfig = self:getCaveConfigByMineId( mineId )
	local caveId = caveConfig.cave_id

	return caveId
end

-- 根据不同魂兽区的品质，计算出十分钟产量（包含狩猎等级加成、宗门加成）
-- mineId 魂兽区的id。 （必须参数）
-- myConsortiaId 如果需要预计我狩猎后的产出，这时就需要把我狩猎后可能产生的宗门加成算进去的话，就需要传值。否则不用传值  （可选参数，仅仅做我的预计时使用）
-- level 如果需要计算的产出是别人的魂兽区，这里需要传入别人玩家的狩猎等级。这里没有值，默认以我的狩猎等级计算  （可选参数，计算他人产出时为必须）
-- ownerConsortiaId 如果需要计算的产出是别人的魂兽区，这里需要传入他人的宗门ID，用来计算他人的宗门加成情况。这里没有值，默认以我的宗门id来判断  （可选参数，计算他人产出时为必须）
-- isMe 主要用于获得诱魂草的加成计算。如果查看的BOSS魂兽区或者自己的魂兽区的时候，isMe为true，会根据自己的诱魂草加成来预算。（可选参数，计算BOSS魂兽区时为必须）
function QSilverMine:getOutPutByMineId( mineId, myConsortiaId, level, ownerConsortiaId, isMe )
	local moneyOutputBase, silverMineMoneyOutputBase = self:getBaseOutputByMineId( mineId )
	local moneyOutputLevelup, silverMineMoneyOutputLevelup = self:getLevelBuff( level )
	local occupy = self:getMineOccupyInfoByMineID(mineId)
	local count = 0
	if occupy ~= nil then
		count = #(occupy.assistUserInfo or {})
	end
	local moneyOutputAssistUp, silverMineMoneyOutputAssitUp = self:getAssistBuff(count)
	local moneyOutputSocietyUp, silverMineMoneyOutputSocietyUp = self:getSocietyBuff( mineId, myConsortiaId, ownerConsortiaId )
	local moneyOutputGoldPickaxeup, silverMineMoneyOutputGoldPickaxeup = self:getGoldPickaxeBuff( isMe, mineId )

	local moneyOutput = (moneyOutputBase + moneyOutputSocietyUp) * (1 + moneyOutputLevelup) * (1 + moneyOutputAssistUp) * (1 + moneyOutputGoldPickaxeup)
	local silverMineMoneyOutput = (silverMineMoneyOutputBase + silverMineMoneyOutputSocietyUp) * (1 + silverMineMoneyOutputLevelup) * (1 + silverMineMoneyOutputAssitUp) * (1 + silverMineMoneyOutputGoldPickaxeup) 

	return moneyOutput, silverMineMoneyOutput
end

-- 获取基础十分钟产量
function QSilverMine:getBaseOutputByMineId( mineId )
	local mineConfig = self:getMineConfigByMineId( mineId )
	local moneyOutputBase = mineConfig.money_output
	local silverMineMoneyOutputBase = mineConfig.silverMineMoney_output
	return moneyOutputBase, silverMineMoneyOutputBase
end

-- 返回狩猎等级对产出的加成值
function QSilverMine:getLevelBuff( lv )
	local level = lv or self:getMiningLv()
	local levelConfig = self:getLevelConfigByLevel( level )
	local moneyOutputLevelup = levelConfig.money_output / 100
	local silverMineMoneyOutputLevelup = levelConfig.silvermineMoney_output / 100

	return moneyOutputLevelup, silverMineMoneyOutputLevelup
end

-- 返回协助对产出的加成值
function QSilverMine:getAssistBuff( count )
	local count = count or 0
	local config = QStaticDatabase.sharedDatabase():getConfiguration()
	local moneyOutputLevelup = 0
	local silverMineMoneyOutputLevelup = 0
	if count > 0 and count <= self:getAssistTotalCount() then
		local value = config["xiezhu_jiacheng_"..count].value
		moneyOutputLevelup = value
		silverMineMoneyOutputLevelup = value
	end
	return moneyOutputLevelup, silverMineMoneyOutputLevelup
end

-- 返回诱魂草对产出的加成值
function QSilverMine:getGoldPickaxeBuff( isMe, mineId )
	local moneyOutputGoldPickaxeup = 0
	local silverMineMoneyOutputGoldPickaxeup = 0
	local isOvertime = self:updateGoldPickaxeTime( isMe, mineId )
	if not isOvertime then
		moneyOutputGoldPickaxeup = QStaticDatabase.sharedDatabase():getConfigurationValue("huangjinkuanggao_buff")
		silverMineMoneyOutputGoldPickaxeup = QStaticDatabase.sharedDatabase():getConfigurationValue("huangjinkuanggao_buff")
	end
	return moneyOutputGoldPickaxeup, silverMineMoneyOutputGoldPickaxeup
end

-- 返回宗门对产出的加成值
function QSilverMine:getSocietyBuff( mineId, myConsortiaId, ownerConsortiaId )
	local caveId = self:getCaveIdByMineId( mineId )
	local societyCount = 0
	local isBuff, member, consortiaId = self:getSocietyBuffInfoByCaveId(caveId, myConsortiaId, mineId)
	if isBuff then
		if ownerConsortiaId then
			if consortiaId == ownerConsortiaId then
				societyCount = member
			end
		elseif consortiaId == self:getMyConsortiaId() then
			societyCount = member
		end
	end
	local moneyOutputSocietyUp = QStaticDatabase.sharedDatabase():getConfigurationValue("silvermine_up_money_"..societyCount) or 0
	local silverMineMoneyOutputSocietyUp = QStaticDatabase.sharedDatabase():getConfigurationValue("silvermine_up_silverminemoney_"..societyCount) or 0

	return moneyOutputSocietyUp, silverMineMoneyOutputSocietyUp
end

-- 根据caveId计算这个cave的宗门加成一些信息，如果没有宗门加成，则isBuff为false
-- mineId为玩家点开的魂兽区的id
function QSilverMine:getSocietyBuffInfoByCaveId( caveId, myConsortiaId, mineId )
	-- print("QSilverMine:getSocietyBuffInfoByCaveId() ", caveId, myConsortiaId )
	local societyTbl = {}
	local isBuff = false
	local member = 0
	local consortiaId = ""
	local consortiaName = ""

	local caveConfig = self:getCaveConfigByCaveId( caveId )
	if caveConfig and caveConfig.cave_bonus == 1 then
		local caveInfo = self:getCaveInfoByCaveId( caveId )
		if caveInfo and caveInfo.occupies and table.nums(caveInfo.occupies) > 0 then
			for _, occupy in pairs(caveInfo.occupies) do
				if occupy.consortiaId and occupy.consortiaId ~= "" then
					if not societyTbl[occupy.consortiaId] then
						societyTbl[occupy.consortiaId] = {}
						if myConsortiaId and myConsortiaId ~= "" and myConsortiaId == occupy.consortiaId then
							-- 初始为1，因为如果我狩猎了之后，我算1，用于查看别人的魂兽区时，预先计算我拿下之后的产出
							-- 但是这个要减去2个特殊情况。1，我也占据了其中一个魂兽区了。2，我点的是我宗门的人的魂兽区
							societyTbl[occupy.consortiaId].count = 1
						else
							societyTbl[occupy.consortiaId].count = 0
						end
					end

					societyTbl[occupy.consortiaId].name = occupy.consortiaName
					societyTbl[occupy.consortiaId].count = societyTbl[occupy.consortiaId].count + 1

					if myConsortiaId then
						if occupy.ownerId == self:getMyUserId() then
							-- 1，我也占据了其中一个魂兽区了。
							societyTbl[occupy.consortiaId].count = societyTbl[occupy.consortiaId].count - 1
						end

						if occupy.mineId == mineId and occupy.consortiaId == myConsortiaId then
							-- 2，我点的是我宗门的人的魂兽区
							societyTbl[occupy.consortiaId].count = societyTbl[occupy.consortiaId].count - 1
						end
					end

					if societyTbl[occupy.consortiaId].count >= 3 then
						if myConsortiaId then
							if myConsortiaId == occupy.consortiaId then
								isBuff = true
								member = societyTbl[occupy.consortiaId].count
								consortiaId = occupy.consortiaId
								consortiaName = occupy.consortiaName
							end
						else
							isBuff = true
							member = societyTbl[occupy.consortiaId].count
							consortiaId = occupy.consortiaId
							consortiaName = occupy.consortiaName
						end
					end
				end
			end
		end
	end

	return isBuff, member, consortiaId, consortiaName, societyTbl
end

-- 根据品质等级，转换成中文的品质
function QSilverMine:getMineCNNameByQuality( quality )
    if quality == PLUNDER_TYPE.IRON then
        return "百年魂兽区"
    elseif quality == PLUNDER_TYPE.COPPER then
        return "五百年魂兽区"
    elseif quality == PLUNDER_TYPE.SILVER then
        return "千年魂兽区"
    elseif quality == PLUNDER_TYPE.RICH_SILVER then
        return "五千年魂兽区"
    elseif quality == PLUNDER_TYPE.GOLD then
        return "万年魂兽区"
    elseif quality == PLUNDER_TYPE.RICH_GOLD then
        return "五万年魂兽区"
    elseif quality == PLUNDER_TYPE.DIAMOND then
        return "十万年魂兽区"
    else
        return ""
    end
end

-- 根绝mineId返回狩猎倒计时
function QSilverMine:updateTime( isMe, mineId )
	local startTime = 0
	local endTime = 0
	local isOvertime = false
	local timeStr = ""
	local color = ccc3(255, 63, 0) -- 红色
	if not isMe and mineId then
		local caveId = self:getCaveIdByMineId( mineId )

		local caveInfo = self:getCaveInfoByCaveId( caveId )
		-- QPrintTable(caveInfo)
		for _, mine in pairs(caveInfo.occupies or {}) do
			if mine.mineId == mineId then
				startTime = (mine.startAt or 0) / 1000
				endTime = (mine.endAt or 0) / 1000
			end
		end
	else
		local myOccupy = self:getMyOccupy()
		if myOccupy then 
			startTime = (myOccupy.startAt or 0) / 1000
			endTime = (myOccupy.endAt or 0) / 1000
		end
	end

	if q.serverTime() >= endTime then
		isOvertime = true
	else
		local sec = endTime - q.serverTime()
		if sec >= 30*60 then
			color = ccc3(255, 216, 44)
		else
			color = ccc3(255, 63, 0)
		end
		local h, m, s = self:formatSecTime( sec )
		timeStr = string.format("%02d:%02d:%02d", h, m, s)
	end

	return isOvertime, timeStr, color
end

-- 将秒为单位的数字转换成 00：00：00格式
function QSilverMine:formatSecTime( sec )
	local h = math.floor((sec/3600)%24)
	local m = math.floor((sec/60)%60)
	local s = math.floor(sec%60)

	return h, m, s
end

-- 根绝mineId返回狩猎倒计时
function QSilverMine:updateGoldPickaxeTime( isMe, mineId )
	local endTime = 0
	local isOvertime = false
	local isCanBuy = true
	local timeStr = ""
	local color = ccc3(255, 63, 0) -- 红色
	if not isMe and mineId then
		local caveId = self:getCaveIdByMineId( mineId )
		local caveInfo = self:getCaveInfoByCaveId( caveId )
		-- QPrintTable(caveInfo)
		for _, mine in pairs(caveInfo.occupies or {}) do
			if mine.mineId == mineId then
				endTime = (mine.miningPickEndAt or 0) / 1000
			end
		end
	else
		local myOccupy = self:getMyOccupy()
		if myOccupy and myOccupy.miningPickEndAt then 
			-- print("QSilverMine:updateGoldPickaxeTime (1)", myOccupy.miningPickEndAt)
			endTime = (myOccupy.miningPickEndAt or 0) / 1000
		else
			-- print("QSilverMine:updateGoldPickaxeTime (2)", self.miningPickEndAt)
			endTime = (self.miningPickEndAt or 0) / 1000
		end
	end

	if q.serverTime() >= endTime then
		isOvertime = true
		-- self:dispatchEvent({name = QSilverMine.NO_GOLDPICKAXE})
	else
		local sec = endTime - q.serverTime()
		if sec >= 15*60 then
			color = ccc3(255, 216, 44)
		else
			color = ccc3(255, 63, 0)
		end
		local h, m, s = self:formatSecTime( sec )
		local limit = tonumber(QStaticDatabase.sharedDatabase():getConfigurationValue("huangjinkuanggao_time_limit")) - tonumber(QStaticDatabase.sharedDatabase():getConfigurationValue("huangjinkuanggao_time"))
		if h >= limit then
			isCanBuy = false
		end
		timeStr = string.format("%02d:%02d:%02d", h, m, s)
	end

	return isOvertime, timeStr, color, isCanBuy
end

-- 获取最大的延长狩猎的次数
function QSilverMine:getMaxExtendOccupyCount()
	local index = 1
	while true do
		local obj = QStaticDatabase.sharedDatabase():getConfigurationValue("silvermine_longtime_"..index)
		if not obj then
			break
		end
		index = index + 1
	end

	return index - 1
end

-- awardStr : consortia_money^730; consortia_money; 23^73; 23
function QSilverMine:getItemBoxParaMetet( awardStr )
	local idOrType = ""
	local count = 0
	local itemType = -1

	local s, e = string.find(awardStr, "%^")
    if s then
        local a = string.sub(awardStr, 1, s - 1)
        local b = string.sub(awardStr, e + 1)
        idOrType = a
        count = tonumber(b)
    else
        idOrType = awardStr
        count = 0
    end
    local n = tonumber(idOrType)
    if n then
        -- 数字， item
       	itemType = self:getItemTypeById( idOrType )
   	 	if itemType == ITEM_CONFIG_TYPE.GEMSTONE_PIECE then
            return idOrType, ITEM_TYPE.GEMSTONE_PIECE, count
        elseif itemType == ITEM_CONFIG_TYPE.GEMSTONE then
        	return idOrType, ITEM_TYPE.GEMSTONE, count
        else
        	return idOrType, ITEM_TYPE.ITEM, count
        end
    end
    -- 字母，resource
    return nil, idOrType, count
end

-- 根据item的id返回item的type
function QSilverMine:getItemTypeById( itemId )
	local itemConfig = QStaticDatabase.sharedDatabase():getItemByID( itemId )
	if not itemConfig then
		app.tip:floatTip("没有id["..itemId.."]的配置，请策划检查量表")
		return 1
	end
	return itemConfig.type
end

-- 根据awardStr获取货品的中文名字
function QSilverMine:getGoodsNameByAwardStr( awardStr )
	local id, type, count = self:getItemBoxParaMetet( awardStr )
	if id then
		--item
		local itemConfig = QStaticDatabase.sharedDatabase():getItemByID( id )
		return itemConfig.name
	else
		--recource
		local itemType = remote.items:getItemType( type )
		local wallet = remote.items:getWalletByType( itemType )
		return wallet.nativeName
	end
end

-- 根据物品的品质做降序排列，如果同品质，按照item>resource排序，同品质item按照id降序排序，同品质resource不排序
-- awardStrTbl : { consortia_money^730, consortia_money, 23^73, 23 }
-- awardTbl : { type: item, count: 9999, id: 123 }
function QSilverMine:arrangeByQuality( awardStrTbl, awardTbl )
	local isStrTbl = true
	local tbl = {}
	if awardStrTbl then
		isStrTbl = true
		tbl = awardStrTbl
	else
		isStrTbl = false
		tbl = awardTbl
	end

	if table.nums(tbl) < 2 then return end

	table.sort(tbl, function( a, b ) 
			local id1, type1, id2, type2, item1, item2 = nil, nil, nil, nil, nil, nil
			local color1, color2 = 0, 0

			if isStrTbl then
				id1, type1 = self:getItemBoxParaMetet(a)
				id2, type2 = self:getItemBoxParaMetet(b)
			else
				id1 = a.id
				type1 = a.typeName or a.type
				id2 = b.id
				type2 = b.typeName or b.type
			end
			
			if id1 then
				item1 = QStaticDatabase.sharedDatabase():getItemByID(id1)
				color1 = item1.colour or 0
			else
				local res = QStaticDatabase.sharedDatabase():getResource()
				for _, value in pairs(res) do
					if value.name == type1 then
						color1 = value.colour or 0
					else
						local cnames = string.split(value.cname, ",")
						for _, name in pairs(cnames) do
							if name == type1 then
								color1 = value.colour or 0
							end
						end
					end
				end
			end

			if id2 then
				item2 = QStaticDatabase.sharedDatabase():getItemByID(id2)
				color2 = item2.colour or 0
			else
				local res = QStaticDatabase.sharedDatabase():getResource()
				for _, value in pairs(res) do
					if value.name == type2 then
						color2 = value.colour or 0
					else
						local cnames = string.split(value.cname, ",")
						for _, name in pairs(cnames) do
							if name == type2 then
								color2 = value.colour or 0
							end
						end
					end
				end
			end

			-- print("--------------")
			-- print(id1, id2)
			-- print(item1, item2)
			-- print(type1, type2)
			-- print(color1, color2)

			if color1 > color2 then
				return true
			elseif color1 == color2 then
				-- 同品质
				if not item1 then
					return false
				else
					if not item2 then
						return true
					else
						-- if type1 == ITEM_TYPE.GEMSTONE_PIECE then
						if item1.gemstone_quality then
							-- if type2 ~= ITEM_TYPE.GEMSTONE_PIECE then
							if not item2.gemstone_quality then
								return true
							else
								-- print("=================================")
								-- print(id1, type1, item1.gemstone_quality)
								-- print(id2, type2, item2.gemstone_quality)
								if tonumber(item1.gemstone_quality) > tonumber(item2.gemstone_quality) then
									-- print("true")
									return true 
								else
									-- print("false")
									return false
								end
							end
						else
							-- if type2 == ITEM_TYPE.GEMSTONE_PIECE then
							if item2.gemstone_quality then
								return false
							else
								-- print("---------------------------------")
								-- print(id1, type1)
								-- print(id2, type2)
								if tonumber(id1) > tonumber(id2) then
									-- print("true")
									return true 
								else
									-- print("false")
									return false
								end
							end
						end
					end
				end
			else
				return false
			end
		end)
end

-- 获取当前延长狩猎的费用
function QSilverMine:getExtendOccupyPrice()
	if self.myOccupy and self.myOccupy.extendCount then
		local index = self.myOccupy.extendCount + 1
		local price = QStaticDatabase.sharedDatabase():getConfigurationValue("silvermine_longtime_"..index)
		return price
	end
	return 0
end

function QSilverMine:getAllWalletCount()
	local wallets = QStaticDatabase.sharedDatabase():getResource()
	local tbl = {}
	for _, wallet in pairs(wallets) do
		tbl[wallet.name] = remote.user:getPropForKey(wallet.name)
	end

	return tbl
end

function QSilverMine:getAllItemCountInSilverMine()
	local allItemIds = self._allItemIds
	QPrintTable(allItemIds)
	local tbl = {}
	for _, id in pairs(allItemIds) do
		tbl[id] = remote.items:getItemsNumByID( id )
	end

	return tbl
end

function QSilverMine:getRandomOpportunityId( hasAward )
	local awardPool = {}
	if hasAward then
		awardPool = self._things[1]
	else
		awardPool = self._things[2]
	end
	local n = table.nums(awardPool)
	local index = math.random(n)

	return awardPool[index]
end

function QSilverMine:getOccupyPriceAtPM()
	return QStaticDatabase.sharedDatabase():getConfigurationValue("silvermine_pm_token")
end

function QSilverMine:getOccupyPriceForFriend()
	return 100
end

function QSilverMine:IsInBattle()
	return self._isInBattle
end

function QSilverMine:getOtherPlayerSilverMine()
	return self.otherPlayerSilverMine
end

function QSilverMine:getOtherPlayerOccupy()
	return self.otherPlayerOccupy
end

--------------数据处理--------------

function QSilverMine:responseHandler( response, successFunc, failFunc )
	-- QPrintTable( response )
	if response.api == "SILVERMINE_FINISH_MINE_OCCUPY" then
		table.insert(self._dispatchTBl, QSilverMine.MINE_FINISH_UPDATE)
	end

	if response.silverMineGetMyInfoResponse then
		local data = response.silverMineGetMyInfoResponse.mySilverMine
		self:_updateMySilverMine(data)
		self.awardCount = response.silverMineGetMyInfoResponse.awardCount
		self.myOccupy = response.silverMineGetMyInfoResponse.myOccupy
		self.inviteAssistNum = response.silverMineGetMyInfoResponse.inviteAssistNum

		table.insert(self._dispatchTBl, QSilverMine.MY_INFO_UPDATE)
		table.insert(self._dispatchTBl, QSilverMine.SILVER_ASSIST_UPDATE)
	end

	if response.silverMineInviteAssistResponse then
		if response.silverMineInviteAssistResponse.myOccupy ~= nil then
			self.myOccupy = response.silverMineInviteAssistResponse.myOccupy
		end
		table.insert(self._dispatchTBl, QSilverMine.MY_INFO_UPDATE)
	end

	if response.silverMineGetCaveListResponse then
		local data = response.silverMineGetCaveListResponse.mineCaves
		if data and table.nums(data) > 0 then
			for _, cave in pairs(data) do
				self.mineCaves[cave.caveId] = cave
			end
		end

		table.insert(self._dispatchTBl, QSilverMine.CAVE_LIST_UPDATE)

		self:setMineAssistInfo()
	end

	if response.silverMineGetCaveInfoResponse then
		local data = response.silverMineGetCaveInfoResponse.mineCave
		if data and data.caveId then
			self.mineCaves[data.caveId] = data
		end

		table.insert(self._dispatchTBl, QSilverMine.CAVE_UPDATE)

		self:setMineAssistInfo()
	end

	if response.silverMineBuyFightCountResponse then
		local data = response.silverMineBuyFightCountResponse.mySilverMine
		self:_updateMySilverMine(data)
		table.insert(self._dispatchTBl, QSilverMine.MY_INFO_UPDATE)
	end

	if response.silverMineGetMiningEventListResponse then
	end

	if response.silverMineExtendOccupyTimeResponse then
		self.myOccupy = response.silverMineExtendOccupyTimeResponse.myOccupy
	end

	if response.silverMineFightStartCheckResponse then
	end

	if response.gfStartResponse and response.gfStartResponse.silverMineFightStartResponse then
		self._isInBattle = true
	end

	if response.gfEndResponse and response.gfEndResponse.silverMineFightEndResponse then
		self._isInBattle = false
		local data = response.gfEndResponse.silverMineFightEndResponse.mySilverMine
		if self.miningLv ~= data.miningLv and data.miningLv > 0 then
			self.isLevelUp = true
		end
		self:_updateMySilverMine(data)
		self.myOccupy = response.gfEndResponse.silverMineFightEndResponse.myOccupy

		table.insert(self._dispatchTBl, QSilverMine.MY_INFO_UPDATE)
	end

	if response.silverMineShowOccupyAwardListResponse then
		local data = response.silverMineShowOccupyAwardListResponse.awards
		if data and table.nums(data) > 0 then
			local count = 0
			for _, award in pairs(data) do
				local str = award.miningAward..";"..award.occupyAward
				self:_analysisItem(str)
				if not award.getAward then
					count = count + 1
				end
			end
			self.awardCount = count
		end
		-- QPrintTable( self._allItemIds )
	end

	if response.silverMineGetOccupyAwardResponse then
		local data = response.silverMineGetOccupyAwardResponse.mySilverMine
		if self.miningLv ~= data.miningLv and data.miningLv > 0 then
			self.isLevelUp = true
		end

		self:_updateMySilverMine(data)
		self.awardCount = response.silverMineGetOccupyAwardResponse.awardCount

		table.insert(self._dispatchTBl, QSilverMine.MY_INFO_UPDATE)
	end

	if response.silverMineShowDefenseArmyResponse then

	end

	if response.silverMineFightReportUploadResponse then

	end

	if response.silverMineSetDefenseArmyResponse then
		local data = response.silverMineSetDefenseArmyResponse.mySilverMine
		self:_updateMySilverMine(data)
		-- if data and data.defenseArmy then
		-- 	self.defenseArmy = data.defenseArmy
		-- 	self.totalOccupySecs	= data.totalOccupySecs
		-- 	self:_updateTeam()
		-- end
	end

	if response.silverMineGetMineOccupyInfoResponse then
		-- QPrintTable(response.silverMineGetMineOccupyInfoResponse)
		self.otherPlayerSilverMine = response.silverMineGetMineOccupyInfoResponse.silverMine
		self.otherPlayerOccupy = response.silverMineGetMineOccupyInfoResponse.occupy
		-- QPrintTable(self.otherPlayerSilverMine)
		-- QPrintTable(self.otherPlayerOccupy)
	end

	if response.silverMineBuyMiningPickResponse then
		-- QPrintTable(response.silverMineBuyMiningPickResponse)
		local data = response.silverMineBuyMiningPickResponse.mySilverMine
		self:_updateMySilverMine(data)
		self.myOccupy = response.silverMineBuyMiningPickResponse.myOccupy
		-- table.insert(self._dispatchTBl, QSilverMine.BUY_GOLDPICKAXE)
		table.insert(self._dispatchTBl, QSilverMine.BUY_GOLDPICKAXE)
	end

	if response.api == "SILVERMINE_INVITE_MEMBER" and response.error == "NO_ERROR" then
		app.taskEvent:updateTaskEventProgress(app.taskEvent.SILVERMINE_HELP_EVENT, 1)
    end

    if response.api == "SILVERMINE_ASSIST" and response.error == "NO_ERROR" then
    	app.taskEvent:updateTaskEventProgress(app.taskEvent.SILVERMINE_ASSIST_EVENT, 1)
    end
    
	if self.myOccupy then
    	app.taskEvent:updateTaskEventProgress(app.taskEvent.SILVERMINE_OCCUPY_EVENT, 1)
	end

	self:_calculateForce()

	if successFunc then 
        successFunc(response) 
        self:_dispatchAll()
        remote.silverMine:removeLock()
        return
    end

    if failFunc then 
        failFunc(response)
    end

    self:_dispatchAll()
    remote.silverMine:removeLock()
end

function QSilverMine:pushHandler( data )
    QPrintTable(data)
    if data.eventType == "SILVERMINE_GRABBED" then
    	self.isRecordRedTip = true
    	self:silvermineGetMyInfoRequest(function()
        		if self.myOccupy then
        			-- if self.myOccupy.mineId then
		        	-- 	local caveConfig = self:getCaveConfigByMineId( self.myOccupy.mineId )
		        	-- 	if caveConfig and caveConfig.cave_id then
		        	-- 		self:silvermineGetCaveInfoRequest(caveConfig.cave_id)
		        	-- 	end
		        	-- end
		        	if self.myOccupy.cave_region then
		        		local caveConfig = self:getCaveConfigByMineId( self.myOccupy.mineId )
		        		if caveConfig and caveConfig.cave_region then
		        			self:silvermineGetCaveListRequest(caveConfig.cave_region)
		        		end
		        	end
	        	end	        	
        	end)
	elseif data.eventType == "SILVERMINE_AUTO_OCCUPY" then
        self:silvermineGetMyInfoRequest(function()
        		if self.myOccupy then
        			-- if self.myOccupy.mineId then
		        	-- 	local caveConfig = self:getCaveConfigByMineId( self.myOccupy.mineId )
		        	-- 	if caveConfig and caveConfig.cave_id then
		        	-- 		self:silvermineGetCaveInfoRequest(caveConfig.cave_id)
		        	-- 	end
		        	-- end
		        	if self.myOccupy.cave_region then
		        		local caveConfig = self:getCaveConfigByMineId( self.myOccupy.mineId )
		        		if caveConfig and caveConfig.cave_region then
		        			self:silvermineGetCaveListRequest(caveConfig.cave_region)
		        		end
		        	end
	        	end

        	end)
    end
end

 --[[
 	//银魂兽区本API定义
	SILVERMINE_GET_MY_INFO                      = 7001;                     // 获取玩家的银魂兽区本信息和狩猎信息
    SILVERMINE_GET_CAVE_LIST                    = 7002;                     // 获取魂兽森林列表
    SILVERMINE_GET_CAVE_INFO                    = 7003;                     // 获取魂兽森林信息
    SILVERMINE_BUY_FIGHT_COUNT                  = 7004;                     // 购买抢魂兽区次数
    SILVERMINE_SHOW_OCCUPY_AWARD_LIST           = 7005;                     // 狩猎奖励列表
    SILVERMINE_GET_OCCUPY_AWARD                 = 7006;                     // 领取狩猎奖励
    SILVERMINE_GET_MINING_EVENT_LIST            = 7007;                     // 获取狩猎事件列表
    SILVERMINE_CHECK_FOR_FIGHT_START            = 7008;                     // 抢魂兽区战斗开始前校验
    SILVERMINE_FIGHT_START                      = 7009;                     // 抢魂兽区战斗开始
    SILVERMINE_FIGHT_END                        = 7010;                     // 抢魂兽区战斗结束
    SILVERMINE_EXTEND_OCCUPY_TIME               = 7011;                     // 延长狩猎时间
    SILVERMINE_SET_DEFENSE_ARMY                 = 7012;                     // 设置狩猎防守阵容
    SILVERMINE_SHOW_DEFENSE_ARMY                = 7013;                     // 获取狩猎玩家的防守阵容信息
    SILVERMINE_QUICK_FIND_MINE                  = 7014;                     // 一键找魂兽区
    SILVERMINE_FIGHT_REPORT_UPLOAD              = 7015;                     // 抢魂兽区战报上传
    SILVERMINE_FINISH_MINE_OCCUPY               = 7019;                     // 结束狩猎，结算奖励
    SILVERMINE_GET_MINE_OCCUPY_INFO             = 7021;                     // 获取一个魂兽区的狩猎信息SilverMineGetMineOccupyInfoRequest
    SILVERMINE_BUY_MINING_PICK                  = 7026;                     // 购买黄金魂兽区铲 无参数； 返回：SilverMineBuyMiningPickResponse
]]

-- 获取玩家的银魂兽区本信息和狩猎信息
function QSilverMine:silvermineGetMyInfoRequest(success, fail, status)
    local request = { api = "SILVERMINE_GET_MY_INFO" }
    app:getClient():requestPackageHandler("SILVERMINE_GET_MY_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 获取魂兽森林列表
-- optional int32 mineRegion = 1;                                              //魂兽区
function QSilverMine:silvermineGetCaveListRequest(mineRegion, success, fail, status)
	local silverMineGetCaveListRequest = {mineRegion = mineRegion}
    local request = { api = "SILVERMINE_GET_CAVE_LIST", silverMineGetCaveListRequest = silverMineGetCaveListRequest }
    app:getClient():requestPackageHandler("SILVERMINE_GET_CAVE_LIST", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 获取魂兽森林信息
-- optional int32 caveId = 1;                                                  //魂兽森林ID
function QSilverMine:silvermineGetCaveInfoRequest(caveId, success, fail, status)
	local silverMineGetCaveInfoRequest = {caveId = caveId}
    local request = { api = "SILVERMINE_GET_CAVE_INFO", silverMineGetCaveInfoRequest = silverMineGetCaveInfoRequest }
    app:getClient():requestPackageHandler("SILVERMINE_GET_CAVE_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 购买抢魂兽区次数
function QSilverMine:silvermineBuyFightCountRequest(success, fail, status)
    local request = { api = "SILVERMINE_BUY_FIGHT_COUNT" }
    app:getClient():requestPackageHandler("SILVERMINE_BUY_FIGHT_COUNT", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 狩猎奖励列表
function QSilverMine:silvermineShowOccupyAwardListRequest(success, fail, status)
    local request = { api = "SILVERMINE_SHOW_OCCUPY_AWARD_LIST" }
    app:getClient():requestPackageHandler("SILVERMINE_SHOW_OCCUPY_AWARD_LIST", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 领取狩猎奖励
-- repeated string occupyIds = 1;                                              //狩猎事件ID集合
function QSilverMine:silvermineGetOccupyAwardRequest(occupyIds, success, fail, status)
	local silverMineGetOccupyAwardRequest = {occupyIds = occupyIds}
    local request = { api = "SILVERMINE_GET_OCCUPY_AWARD", silverMineGetOccupyAwardRequest = silverMineGetOccupyAwardRequest }
    app:getClient():requestPackageHandler("SILVERMINE_GET_OCCUPY_AWARD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 获取狩猎事件列表
-- optional int32 mineId = 1;                                                   //魂兽森林ID
-- optional string occupyId = 2;                                                //狩猎事件ID
function QSilverMine:silvermineGetMiningEventListRequest(mineId, occupyId, success, fail, status)
	local silverMineGetMiningEventListRequest = {mineId = mineId, occupyId = occupyId}
    local request = { api = "SILVERMINE_GET_MINING_EVENT_LIST", silverMineGetMiningEventListRequest = silverMineGetMiningEventListRequest }
    app:getClient():requestPackageHandler("SILVERMINE_GET_MINING_EVENT_LIST", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 抢魂兽区战斗开始前校验
-- optional int32 mineId = 1;                                                  //待抢占的魂兽区的ID
function QSilverMine:silvermineCheckForFightStartRequest(mineId, success, fail, status)
	local silverMineFightStartCheckRequest = {mineId = mineId}
	local gfStartCheckRequest = {battleType = BattleTypeEnum.SILVER_MINE,silverMineFightStartCheckRequest = silverMineFightStartCheckRequest}
    local request = { api = "GLOBAL_FIGHT_START_CHECK", gfStartCheckRequest = gfStartCheckRequest }
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START_CHECK", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 抢魂兽区战斗开始
-- optional int32 mineId = 1;                                                  //待抢占的魂兽区的ID
-- optional string mineOwnerId = 2;                                             //魂兽区的占有者,为空表示没人占
-- optional BattleFormation battleFormation = 3;								//战斗阵容
function QSilverMine:silvermineFightStartRequest(mineId, mineOwnerId, battleFormation, success, fail, status)
	local silverMineFightStartRequest = {mineId = mineId, mineOwnerId = mineOwnerId}
	local gfStartRequest = {battleType = BattleTypeEnum.SILVER_MINE, battleFormation = battleFormation, silverMineFightStartRequest = silverMineFightStartRequest}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, function (response)
    	remote.activity:updateLocalDataByType(717, 1)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 抢魂兽区战斗结束
-- optional int32 mineId = 1;                                                  //待抢占的魂兽区的ID
-- optional string mineOwnerId = 2;                                            //魂兽区的占有者,为空表示没人占
-- optional string fightReportData = 3;                                        //战报内容
-- optional string battleVerify = 4;                                           //战斗校验key
-- optional bool isWin = 5;                                                    //是否胜利
function QSilverMine:silvermineFightEndRequest(mineId, mineOwnerId, fightReportData, battleKey, isWin, isQuick, success, fail, status)
	local battleVerify = q.battleVerifyHandler(battleKey)
	local silverMineFightEndRequest = {mineId = mineId, mineOwnerId = mineOwnerId, battleVerify = battleVerify, isWin = isWin, isQuick = isQuick}
	local gfEndRequest = {battleType = BattleTypeEnum.SILVER_MINE, battleVerify = battleVerify, isQuick = isQuick, isWin = isWin, fightReportData = fightReportData,silverMineFightEndRequest = silverMineFightEndRequest}
    local request = { api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest }
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function (response)
    	-- if response.silverMineFightEndResponse.success then
    	if response.gfEndResponse.isWin then
    		local caveConfig = self:getCaveConfigByMineId( mineId )
    		if caveConfig and caveConfig.cave_bonus and caveConfig.cave_bonus == 1 then
    			self._isShareRedTips = true
    		end
    		self._isNeedShowMineId = tonumber(mineId)
			remote.user:addPropNumForKey("todaySilverMineOccupyCount")
    	end
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 延长狩猎时间
-- optional int32 mineId = 1;                                                  //魂兽区的ID
function QSilverMine:silvermineExtendOccupyTimeRequest(mineId, success, fail, status)
	local silverMineExtendOccupyTimeRequest = {mineId = mineId}
    local request = { api = "SILVERMINE_EXTEND_OCCUPY_TIME", silverMineExtendOccupyTimeRequest = silverMineExtendOccupyTimeRequest }
    app:getClient():requestPackageHandler("SILVERMINE_EXTEND_OCCUPY_TIME", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--设置防御阵容
function QSilverMine:requestSetDefenseHero(team, success)
	local battleFormation = remote.teamManager:encodeBattleFormation(team)
    local silverMineSetDefenseArmyRequest = {}
    local request = {api = "SILVERMINE_SET_DEFENSE_ARMY", silverMineSetDefenseArmyRequest = silverMineSetDefenseArmyRequest, battleFormation = battleFormation}
    app:getClient():requestPackageHandler("SILVERMINE_SET_DEFENSE_ARMY", request, function ( data )
    	self:responseHandler(data, success)
    end)
end

--[[
/**
 * 上传魂兽森林回放
    optional int64   fightReportId           = 1;                        //斗魂场历史记录ID
    optional string  fightReportData              = 2;                        //战报内容
    optional string  fightersData				= 3;						//战斗魂师数据信息
 */
 --]]
function QSilverMine:replayUploadRequest(fightReportId, fightReportData, fightersData, success, fail, status)
    local silverMineFightReportUploadRequest = {fightReportId = fightReportId, fightReportData = fightReportData, fightersData = fightersData}
    local request = {api = "SILVERMINE_FIGHT_REPORT_UPLOAD", silverMineFightReportUploadRequest = silverMineFightReportUploadRequest}
    app:getClient():requestPackageHandler("SILVERMINE_FIGHT_REPORT_UPLOAD", request, success, fail, false)
end

-- 获取狩猎玩家的防守阵容信息
-- optional int32 mineId =1;                                                   //魂兽区ID
function QSilverMine:silvermineShowDefenseArmyRequest(mineId, success, fail, status)
	local silverMineShowDefenseArmyRequest = {mineId = mineId}
    local request = { api = "SILVERMINE_SHOW_DEFENSE_ARMY", silverMineShowDefenseArmyRequest = silverMineShowDefenseArmyRequest }
    app:getClient():requestPackageHandler("SILVERMINE_SHOW_DEFENSE_ARMY", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 一键找魂兽区
function QSilverMine:silvermineQuickFindMineRequest(success, fail, status)
    local request = { api = "SILVERMINE_QUICK_FIND_MINE" }
    app:getClient():requestPackageHandler("SILVERMINE_QUICK_FIND_MINE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 结束狩猎，结算奖励
function QSilverMine:silvermineFinishMineOccupyRequest(success, fail, status)
    local request = { api = "SILVERMINE_FINISH_MINE_OCCUPY" }
    app:getClient():requestPackageHandler("SILVERMINE_FINISH_MINE_OCCUPY", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--[[
/**
 * 自己的20次对战记录
 */
 --]]
function QSilverMine:silverMineAgainstRecordRequest(success, fail, status)
    local request = {api = "SILVERMINE_GET_FIGHT_REPORT_LIST", silverMineGetFightReportListRequest = {ifSelf = true}}
    app:getClient():requestPackageHandler("SILVERMINE_GET_FIGHT_REPORT_LIST", request, success, fail)
end

--[[
/**
 * 魂兽区的20次对战记录
 */
]]
function QSilverMine:silverMineRegionAgainstRecordRequest(mineRegionId, success, fail, status)
    local request = {api = "SILVERMINE_GET_FIGHT_REPORT_LIST", silverMineGetFightReportListRequest = {ifSelf = false, mineRegion = mineRegionId}}
    app:getClient():requestPackageHandler("SILVERMINE_GET_FIGHT_REPORT_LIST", request, success, fail)
end

-- 获取战报（对战记录）出战魂师信息
-- optional int64 fightReportId = 1
function QSilverMine:silverMineFightReportFighterData(fightReportId, success, fail, status)
	local silverMineGetFightReportFighterDataRequest = {fightReportId = fightReportId}
	local request = {api = "SILVERMINE_GET_FIGHT_REPORT_FIGHTER_DATA", silverMineGetFightReportFighterDataRequest = silverMineGetFightReportFighterDataRequest}
	app:getClient():requestPackageHandler("SILVERMINE_GET_FIGHT_REPORT_FIGHTER_DATA", request, success, fail)
end

-- 获取战报（对战记录）内容
-- optional int64 fightReportId = 1
function QSilverMine:silverMineFightReportData(fightReportId, success, fail, status)
	local silverMineGetFightReportDataRequest = {fightReportId = fightReportId}
	local request = {api = "SILVERMINE_GET_FIGHT_REPORT_DATA", silverMineGetFightReportDataRequest = silverMineGetFightReportDataRequest}
	app:getClient():requestPackageHandler("SILVERMINE_GET_FIGHT_REPORT_DATA", request, success, fail)
end

-- 根据userid获取银魂兽区防守阵容
-- optional string fighterUserId
function QSilverMine:silverMineQueryFighterRequest(fighterUserId, success, fail, status)
	local silverMineFightReportQueryFighterRequest = {fighterUserId = fighterUserId}
	local request = {api = "SILVERMINE_FIGHT_REPORT_QUERY_FIGHTER", silverMineFightReportQueryFighterRequest = silverMineFightReportQueryFighterRequest}
	app:getClient():requestPackageHandler("SILVERMINE_FIGHT_REPORT_QUERY_FIGHTER", request, success, fail)
end

-- 获取具体某个魂兽区的详细玩家数据
-- optional int32 mineId = 1;                                                  //魂兽区ID
function QSilverMine:silverMineGetMineOccupyInfoRequest(mineId, success, fail, status)
	local silverMineGetMineOccupyInfoRequest = {mineId = mineId}
	local request = {api = "SILVERMINE_GET_MINE_OCCUPY_INFO", silverMineGetMineOccupyInfoRequest = silverMineGetMineOccupyInfoRequest}
	app:getClient():requestPackageHandler("SILVERMINE_GET_MINE_OCCUPY_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 获取某个魂兽区的邀请信息
function QSilverMine:silverMineToAssistCaveRequest(userId, oriOccupyId, success, fail)
	local silverMineToAssistCaveRequest = {userId = userId, oriOccupyId = oriOccupyId}
	local request = {api = "SILVERMINE_TO_ASSIST_CAVE", silverMineToAssistCaveRequest = silverMineToAssistCaveRequest}
	app:getClient():requestPackageHandler("SILVERMINE_TO_ASSIST_CAVE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--获取协助邀请列表
function QSilverMine:silverMineGetInviteListRequest(success, fail, status)
	local request = {api = "SILVERMINE_GET_INVITE_LIST"}
	app:getClient():requestPackageHandler("SILVERMINE_GET_INVITE_LIST", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--发送协助邀请
function QSilverMine:silverMineInviteAssistRequest(userId, success, fail, status)
	local silverMineInviteAssistRequest = {userId = userId}
	local request = {api = "SILVERMINE_INVITE_MEMBER", silverMineInviteAssistRequest = silverMineInviteAssistRequest}
	app:getClient():requestPackageHandler("SILVERMINE_INVITE_MEMBER", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--发送接受协助
function QSilverMine:silverMineAssistRequest(oriOccupyId, userId, success, fail, status)
	local silverMineAssistRequest = {oriOccupyId = oriOccupyId, userId = userId}
	local request = {api = "SILVERMINE_ASSIST", silverMineAssistRequest = silverMineAssistRequest}
	app:getClient():requestPackageHandler("SILVERMINE_ASSIST", request, function (response)
		if response.silverMineAssistResponse ~= nil and response.silverMineAssistResponse.targetOccupy ~= nil then
			local targetOccupy = response.silverMineAssistResponse.targetOccupy
			local occupies = self.mineCaves[response.silverMineAssistResponse.caveId].occupies
			if occupies ~= nil then
				for index,occupy in ipairs(occupies) do
					if occupy.oriOccupyId == targetOccupy.oriOccupyId then
						occupies[index] = targetOccupy
						break
					end
				end
			end
		end
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 购买黄金魂兽区铲
function QSilverMine:silverMineBuyMiningPick(success, fail, status)
	local request = {api = "SILVERMINE_BUY_MINING_PICK"}
	app:getClient():requestPackageHandler("SILVERMINE_BUY_MINING_PICK", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 一键协助
function QSilverMine:silverMineOneKeyAssist(success, fail, status)
	local request = {api = "SILVERMINE_ONE_KEY_ASSIST"}
	app:getClient():requestPackageHandler("SILVERMINE_ONE_KEY_ASSIST", request, function (response)
		self.inviteAssistNum = 0
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--------------本地工具--------------

function QSilverMine:_checkSilverMineUnlock()
	return app.unlock:getUnlockSilverMine()
end

function QSilverMine:_changeCaveRegion()
	self.mineCaves = {}
    self.opportunity = {}
    self._dispatchTBl = {}
    self._lock = false
	self:silvermineGetCaveListRequest( self.caveRegion )
end

function QSilverMine:_calculateForce()
	if not self.defenseArmy or table.nums(self.defenseArmy) == 0 then 
		self.defenseForce = 0
		return 
	end

    local tbl = {}
    local force = 0
    local index = 1

    if self.defenseArmy.mainHeroIds then
    	tbl = self.defenseArmy.mainHeroIds
    else
    	self.defenseForce = 0 
    	return 
    end

   	for _, id in pairs(tbl) do
		local heroProp = remote.herosUtil:createHeroPropById(id)
		if heroProp then
			force = force + heroProp:getBattleForce(true)
		end
	end

	print("[Kumo] QSilverMine:_calculateForce() 主力防守战力：", force)

	while true do
		tbl = self.defenseArmy["sub"..index.."HeroIds"]
		if tbl then
			for _, id in pairs(tbl) do
				local heroProp = remote.herosUtil:createHeroPropById(id)
				if heroProp then
					force = force + heroProp:getBattleForce(true)
				end
			end
			index = index + 1
		else
			break
		end
    end

	if self.defenseArmy.soulSpiritId then
		local soulForce = remote.soulSpirit:countForceBySpiritIds(self.defenseArmy.soulSpiritId)
		force = force + soulForce
	end
	
	if self.defenseArmy.godArmIdList then
		local soulForce = remote.godarm:countForceByGodarmIds(self.defenseArmy.godArmIdList)
		force = force + soulForce
	end

    self.defenseForce = force
    print("[Kumo] QSilverMine:_calculateForce() 防守战力：", self.defenseForce)
end

function QSilverMine:_dispatchAll()
	if not self._dispatchTBl or table.nums(self._dispatchTBl) == 0 then return end
	local tbl = {}
	for _, name in pairs(self._dispatchTBl) do
		if not tbl[name] then
			self:dispatchEvent({name = name})
			tbl[name] = 0
		end
	end
	self._dispatchTBl = {}
end

function QSilverMine:_updateTeam()
	local defenseArmy = self.defenseArmy
	if defenseArmy then
		local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.SILVERMINE_DEFEND_TEAM)
		teamVO:setTeamDataWithBattleFormation(defenseArmy)
	end
end

function QSilverMine:_analysisItem( str )
	local awardTbl = string.split(str, ";")
	for _, award in pairs(awardTbl) do
		local id, type, count = self:getItemBoxParaMetet( award )
		if id then
			self._allItemIds[id] = id
		end
	end
end

function QSilverMine:_analysisThingConfig()
	local thingConfig = QStaticDatabase.sharedDatabase():getSilvermineThingsConfigs()
	self._things[1] = {} -- 保存有奖励的事件 id
	self._things[2] = {} -- 保存无奖励的事件 id
	for _, thing in pairs(thingConfig) do
		local count = thing.weight
		while count > 0 do
			if thing.group == 1 then
				table.insert(self._things[1], thing.things_id)
			end
			if thing.group == 2 then
				table.insert(self._things[2], thing.things_id)
			end
			count = count - 1
		end
	end
end

function QSilverMine:_updateMySilverMine( data )
	if data and table.nums(data) > 0 then
		self.buyFightCount = data.buyFightCount
		self.fightCount    = data.fightCount
		self.miningLv      = data.miningLv
		self.miningExp     = data.miningExp
		self.totalOccupySecs	= data.totalOccupySecs
		self.assistCount = data.assistCount
		self.miningPickBuyCount = data.miningPickBuyCount
		self.miningPickEndAt = data.miningPickEndAt
		if data.defenseArmy and table.nums(data.defenseArmy) > 0 then
			self.defenseArmy   = data.defenseArmy
			self:_updateTeam()
		end
	end
end

return QSilverMine
