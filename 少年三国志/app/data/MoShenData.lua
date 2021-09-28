local MoShenConst = require("app.const.MoShenConst")
local MoShenData = class("MoShenData")
local FunctionLevelConst = require("app.const.FunctionLevelConst")

require("app.cfg.rebel_exploit_reward_info")
require("app.cfg.rebel_special_event_info")

require("app.cfg.rebel_boss_info")
require("app.cfg.rebel_boss_rank_info")
require("app.cfg.rebel_boss_buff_info")
require("app.cfg.rebel_boss_corps_info")
require("app.cfg.rebel_boss_exploit_info")
require("app.cfg.rebel_boss_reward_info")
require("app.cfg.rebel_boss_attack_reward_info")



function MoShenData:ctor()
	-- 功勋值
	self.gongxun = 0
	-- 最大伤害值
	self._maxHarm = 0

	--是否拉取过过功勋数据
	self._hasEnterAward =  false
	self._enterAwardDate = nil

	--[[
		对应S2C_GetExploitAwardType里的mode字段
	]]
	self._awardTypeMode = 0
	self.gongxunAwardList = {}

	self._gongxunRank = 0 --功勋排名
	self._harmRank = 0   --伤害排名
	self._lastGongxunRank = 0 --上一次功勋排名
	self._lastHarmRank = 0 

	self:_initRebelBoss()
end

function MoShenData:getGongXun()
	return self.gongxun or 0
end

function MoShenData:setGongXun(gongxun)
	self.gongxun = gongxun and gongxun or 0 
end

--最大功勋排名
function MoShenData:setGongXunRank(gongxunRank)
	self._gongxunRank = gongxunRank
end
function MoShenData:getGongXunRank()
	return self._gongxunRank
end

--上一次最大功勋排名
function MoShenData:setLastGongXunRank(lastGongxunRank)
	self._lastGongxunRank = lastGongxunRank
end
function MoShenData:getLastGongXunRank()
	return self._lastGongxunRank
end

-- 最大伤害值
function MoShenData:setMaxHarm(nHarm)
	self._maxHarm = nHarm
end
function MoShenData:getMaxHarm()
	return self._maxHarm
end

--最大伤害排名
function MoShenData:setHarmRank(harmRank)
	self._harmRank = harmRank
end
function MoShenData:getHarmRank()
	return self._harmRank
end

--上一次最大伤害排名
function MoShenData:setLastHarmRank(lastHarmRank)
	self._lastHarmRank = lastHarmRank
end
function MoShenData:getLastHarmRank()
	return self._lastHarmRank
end

function MoShenData:setAwardSignList(data)
	self._hasEnterAward = true
	self._awardTypeMode = data.mode
	self._enterAwardDate = G_ServerTime:getDate()
	if data.awards == nil or #data.awards == 0 then
		self.gongxunAwardList = {}
		return
	else
		for i,v in ipairs(data.awards)do
			self.gongxunAwardList[v] = v
		end
	end
end

--[[
	对应S2C_GetExploitAwardType里的mode字段
]]
function MoShenData:getAwardMode()
	return self._awardTypeMode
end

--获得功勋
function MoShenData:addGongXun(gongxun)
	local date = G_ServerTime:getDate()
	if self._enterAwardDate ~= date then
		--功勋每日24点清0
		self.gongxun = 0
	end
	self.gongxun = self.gongxun + gongxun
end

--标记领取的奖励
function MoShenData:setAwardSign(id)
	if self.gongxunAwardList == nil then
		self.gongxunAwardList = {}
	end
	self.gongxunAwardList[id] = id 
end

--检查是否已领取
function MoShenData:checkAwardSign(id)
	return self.gongxunAwardList[id] ~= nil
end

--检查是否已拉取过功勋奖励数据
function  MoShenData:checkEnterAward( ... )
	-- body
	local date = G_ServerTime:getDate()
	if self._enterAwardDate ~= date then
		return false
	end
	return self._hasEnterAward
end

--检查是否有可领取的奖励
function MoShenData:checkAwardSignEnabled()
	for i=1, rebel_exploit_reward_info.getLength() do
	    local v = rebel_exploit_reward_info.indexOf(i)
	    if v.rebel_exploit_type == self._awardTypeMode then 
	    	if v.holiday == 0 or G_Me.specialActivityData:isInActivityTime() then
		        --已达成并且未领取
		        if self.gongxun >= v.exploit and (not self:checkAwardSign(v.id)) then
		        	return true
		        end
	    	end
	    end
	end
	return false
end

-- 检查当前是否在特殊活动期间
function MoShenData:checkEventActive(type)
	-- 如果服务器强制开启活动， 返回true
	if (type == 1 and G_Me.activityData.custom:isZhengtaoActive()) or
	   (type == 3 and G_Me.activityData.custom:isGongxunActive()) then
		return true
	end

	-- 获取从今天0点起的秒数
	local curTime = G_ServerTime:getTime()
	local secFromToday = G_ServerTime:secondsFromToday(curTime)

	-- 检查是否是在事件期间
	local event = rebel_special_event_info.get(type)
	if event then
		if secFromToday >= event.open and secFromToday <= event.end_time then
			return true
		end
	end

	return false
end

----------------------------------------------------------------------------------------
-- 世界Boss
function MoShenData:_initRebelBoss()
	-- 初始化信息
	self._tInitializeInfo = {
		_nTotalHonor = 0,
		_nGroupTotalHonorRank = 0,
		_nMaxHarm = 0,
		_nGroupMaxHarmRank = 0,
		_nLegionRank = 0,
		_nState = 0,                		-- 开始/结束阶段
		_nAttackCount = 0,
		_nRemainPurCount = 0,  -- 剩余可购买挑战次数
		_nGroup = 0,
		_nEndTime = 0,					-- 活动结束时间
		-- 各阵营第一
		_tGroupFirstRankList = {},
		-- Boss info
		_tBoss = {
			_nId = 0,
			_nCurHp = 0,
			_nMaxHp = 0,
			_nLevel = 0,
			_szKillerName = "",
			_nKillerTime = 0,
			_nLastAttackIndex = 0,
			_nProduceTime = 0,			-- Boss出生时间
		},
	}

	-- 2种模式(荣誉、最高伤害)，4个阵营(魏、蜀、吴、群)的排行榜
	self._tRankList = {}
	for i=1, 2 do
		self._tRankList[i] = {}
		for j=1, 4 do
			self._tRankList[i][j] = {}
		end
	end
	-- 玩家自己的排行信息
	self._tMyRankInfo = {}
	-- Boss战报 
	self._tBossReportList = {}
	-- 3种模式的已领取奖励列表
	self._tClaimedAwardList = {}
	for i=1, 3 do
		self._tClaimedAwardList[i] = {}
	end
	-- 军团排行
	self._tLegionRankInfoList = {}
	self._tMyLegionRankInfo = {}
	-- 挑战次数恢复时间戳
	self._nChallengeTimeRecoverTimestamp = 0
end

-- 存储初始化信息，刚进入Boss主界面时拉取
function MoShenData:storeInitializeInfo(data)
	if not self._tInitializeInfo then
		self._tInitializeInfo = {}
	end

	local tInfo = {}
	tInfo._nTotalHonor = data.total_honor
	tInfo._nGroupTotalHonorRank = data.group_thonor_rank
	tInfo._nMaxHarm = data.max_harm
	tInfo._nGroupMaxHarmRank = data.group_mharm_rank
	tInfo._nLegionRank = data.corp_rank
	tInfo._nState = data.state                      -- 开始/结束阶段
	tInfo._nAttackCount = data.att_count
	tInfo._nRemainPurCount = data.remain_pur_count  -- 剩余可购买挑战次数
	tInfo._nGroup = data.group
	tInfo._nEndTime = data.end_time					-- 活动结束时间
	-- 各阵营第一
	tInfo._tGroupFirstRankList = {}
	for i, v in ipairs(data.group_first_ranks) do
		local tRankItem = self:_packRankItem(v)
		local nGroup = tRankItem._nGroup
		tInfo._tGroupFirstRankList[nGroup] = tRankItem
	end
	-- Boss info
	tInfo._tBoss = self:_packRebelBoss(data.rebel_boss)

	self._tInitializeInfo = tInfo

--	dump(self._tInitializeInfo)
end

function MoShenData:getInitializeInfo()
	return self._tInitializeInfo
end

function MoShenData:getBossInfo()
	return self._tInitializeInfo._tBoss
end

-- data为RebelBoss结构数据
function MoShenData:_packRebelBoss(data)
	local tBoss = {}
	tBoss._nId = data.id
	tBoss._nCurHp = data.hp
	tBoss._nMaxHp = data.max_hp
	tBoss._nLevel = data.level
	tBoss._szKillerName = ""
	tBoss._nKillerTime = 0
	if rawget(data, "killer_name") then
		tBoss._szKillerName = data.killer_name
	end
	if rawget(data, "killer_time") then
		tBoss._nKillerTime = data.killer_time --Boss死亡时间戳
	end
	tBoss._nLastAttackIndex = data.last_att_index
	tBoss._nProduceTime = data.produce_time			-- Boss出生时间

	return tBoss
end


-- 选择设置自己的阵营
function MoShenData:storeMyGroup(nGroup)
	self._tInitializeInfo._nGroup = nGroup or 0
end

-- 获取自己的阵营
function MoShenData:getMyGroup()
	return self._tInitializeInfo._nGroup
end


-- 更新boss, data为RebelBoss结构数据
function MoShenData:updateRebelBoss(data)
	local tBoss = self:_packRebelBoss(data)
	self._tInitializeInfo._tBoss = tBoss
end

function MoShenData:getRebelBoss()
	return self._tInitializeInfo._tBoss
end

-- 上次攻击的Boss的索引
function MoShenData:getLastAttackIndex()
	return self._tInitializeInfo._tBoss._nLastAttackIndex
end


function MoShenData:_packRankItem(data)
	-- tRankItem为RebelBossRank结构对象

	local tRankItem = {}
	tRankItem._nId = data.id
	tRankItem._nFightValue = data.fight_value
	tRankItem._nMode = data.mode
	tRankItem._nValue = data.value
	tRankItem._nRank = data.rank
	tRankItem._szName = data.name
	tRankItem._szLegionName = data.corp_name
	tRankItem._nUserId = data.user_id
	tRankItem._nDressId = data.dress_id
	tRankItem._nGroup = data.group

	return tRankItem
end

function MoShenData:_packMyRankInfo(data)
	-- tMyRankInfo为RebelBossSimpleRank结构对象
	local tMyRankInfo = {}
	tMyRankInfo._nRank = data.rank
	tMyRankInfo._nGroup = data.group
	tMyRankInfo._nValue = data.value

	return tMyRankInfo
end

-- 存储排行榜信息
function MoShenData:storeRankList(data)
	local function sortFunc(tRankItem1, tRankItem2)
		return tRankItem1._nRank < tRankItem2._nRank
	end

	local nMode = data.mode
	local nGroup = data.group
	if nMode == MoShenConst.REBEL_BOSS_RANK_MODE.HONOR then
		self._tRankList[nMode][nGroup] = {}
		for i, val in pairs(data.rbh_ranks) do
			local tRankItem = self:_packRankItem(val)
			table.insert(self._tRankList[nMode][nGroup], tRankItem)
		end
		if rawget(data, "rbh_my_rank") then
			local tMyRankInfo = self:_packMyRankInfo(data.rbh_my_rank)
			self._tMyRankInfo = tMyRankInfo
		end
	elseif nMode == MoShenConst.REBEL_BOSS_RANK_MODE.MAX_HARM then
		self._tRankList[nMode][nGroup] = {}
		for i, val in pairs(data.rbmh_ranks) do
			local tRankItem = self:_packRankItem(val)
			table.insert(self._tRankList[nMode][nGroup], tRankItem)
		end
		if rawget(data, "rbmh_my_rank") then
			local tMyRankInfo = self:_packMyRankInfo(data.rbmh_my_rank)
			self._tMyRankInfo = tMyRankInfo
		end
	end

	table.sort(self._tRankList[nMode][nGroup], sortFunc)
end

function MoShenData:getRankList(nMode, nGroup)
	return self._tRankList[nMode][nGroup] or {}
end

-- 获取玩家自己的排行信息
function MoShenData:getMyRankInfo()
	return self._tMyRankInfo
end

-- 购买挑战次数成功，要更新挑战次数
function MoShenData:updateChallengeTime(nChallengeTime)
	self._tInitializeInfo._nAttackCount = nChallengeTime
end

-- 获得挑战次数
function MoShenData:getChallengeTime()
	return self._tInitializeInfo._nAttackCount
end

-- 购买挑战次数成功，要更新剩余挑战次数
function MoShenData:updateRemainPurchaseTime(nRemainPurCount)
	self._tInitializeInfo._nRemainPurCount = nRemainPurCount
end

function MoShenData:getRemainPurchaseTime()
	return self._tInitializeInfo._nRemainPurCount
end

-- 战斗结果
function MoShenData:storeRebelBossBattleResult(data)
	self._tRebelBossBattleResult = data
end

function MoShenData:getRebelBossBattleResult()
	return self._tRebelBossBattleResult
end

-- Boss战报
-- data为BossReport结构数组
function MoShenData:storeBossReport(data)
	local tReportList = {}
	for i, val in ipairs(data.reports) do
		local tReport = self:_packBossReport(val)
		if tReport then
			table.insert(tReportList, #tReportList + 1, tReport)
		end
	end
	local function sortFunc(tReport1, tReport2)
		return tReport1._nTime1 < tReport2._nTime1
	end
	table.sort(tReportList, sortFunc)
	self._tBossReportList = tReportList
end

function MoShenData:getBossReportList()
	return self._tBossReportList
end


-- data为BossReport结构
function MoShenData:_packBossReport(data)
	local tReport = {}
	tReport._nBossId = data.boss_id
	tReport._nLevel  = data.boss_level
	-- 第一次被攻击
	tReport._nTime1 = 0
	tReport._szName1 = ""
	tReport._tAward1 = nil
	if rawget(data, "award1") then
		tReport._nTime1 = data.time1
		tReport._szName1 = data.name1
		tReport._tAward1 = data.award1
	end
	-- 被杀死
	tReport._nTime2 = 0
	tReport._szName2 = ""
	tReport._tAward2 = nil
	if rawget(data, "award2") then
		tReport._nTime2 = data.time2
		tReport._szName2 = data.name2
		tReport._tAward2 = data.award2
	end

	-- 这个Boss一次都没有被攻击过，不显示内容
	if tReport._nTime1 == 0 then
		tReport = nil
	end

	return tReport
end

function MoShenData:getMyTotalHonor()
	return self._tInitializeInfo._nTotalHonor
end

function MoShenData:storeClaimedAwardList(data)
	local nMode = data.mode
	self._tClaimedAwardList[nMode] = data.status
end

-- 获得3种模式奖励的已领取列表,存储的是id
function MoShenData:getClaimedAwardList(nMode)
	return self._tClaimedAwardList[nMode] or {}
end

function MoShenData:storeLegionRankInfoList(data)
	local tLegionRankInfoList = {}
	local tMyLegionRankInfo = {}
	for i, val in ipairs(data.ranks) do
		local tLegionRankInfo = self:_packLegionRankInfo(val)
		table.insert(tLegionRankInfoList, tLegionRankInfo)
	end
	if rawget(data, "my_rank") then
		local tLegionRankInfo = self:_packLegionRankInfo(data.my_rank)
		tMyLegionRankInfo = tLegionRankInfo
	end

	self._tLegionRankInfoList = tLegionRankInfoList
	self._tMyLegionRankInfo = tMyLegionRankInfo
end

function MoShenData:getLegionRankInfoList()
	return self._tLegionRankInfoList or {}
end

function MoShenData:getMyLegionRankInfo()
	return self._tMyLegionRankInfo or {}
end


function MoShenData:_packLegionRankInfo(data)
	local tLegionRankInfo = {}
	tLegionRankInfo._nRank = data.rank
	tLegionRankInfo._szLegionName = data.corp_name
	tLegionRankInfo._nHonor = data.honor
	local tStateList = {}
	tStateList._nActivityState = 1
	tStateList._nClaimState = 0
	tStateList._nConditionState = 0
	if rawget(data, "state") then
		tStateList._nActivityState = data.state.activity_status
		tStateList._nClaimState = data.state.award_status
		tStateList._nConditionState = data.state.condition_status
	end
	tLegionRankInfo._tStateList = tStateList

	return tLegionRankInfo
end

-- 是否有奖励（总荣誉，Boss等级，军团奖励）
function MoShenData:hasRebelBossAward(nType)
	-- 判断等级，功能是否开启
    local unlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.REBEL_BOSS)
    if not unlockFlag then
        return false
    end

	if nType == MoShenConst.REBEL_BOSS_AWARD_MODE.HONOR then
		-- 荣誉达到条件的列表
		local tRoleTmpl = role_info.get(G_Me.userData.level)
		local tReachConditionList = {}
		local nHonor = self._tInitializeInfo._nTotalHonor
		for i=1, rebel_boss_exploit_info.getLength() do
			local tTmpl = rebel_boss_exploit_info.indexOf(i)
			if tTmpl.boss_exploit_type == tRoleTmpl.boss_exploit_type then
				if nHonor >= tTmpl.boss_exploit then
					table.insert(tReachConditionList, tTmpl)
				end 
			end
		end
		-- 已经领取过的列表
		local tClaimedList = self:getClaimedAwardList(MoShenConst.REBEL_BOSS_AWARD_MODE.HONOR)
		return table.nums(tReachConditionList) > table.nums(tClaimedList)

	elseif nType == MoShenConst.REBEL_BOSS_AWARD_MODE.BOSS_LEVEL then
		local tReachConditionList = {}
		local nBossLevel = self._tInitializeInfo._tBoss._nLevel
		if self._tInitializeInfo._tBoss._nCurHp ~= 0 then
			nBossLevel = nBossLevel - 1
		end

		for i=1, rebel_boss_reward_info.getLength() do
			local tTmpl = rebel_boss_reward_info.indexOf(i)
			if nBossLevel >= tTmpl.boss_level then
				table.insert(tReachConditionList, tTmpl)
			end
		end
		-- 已经领取过的列表
		local tClaimedList = self:getClaimedAwardList(MoShenConst.REBEL_BOSS_AWARD_MODE.BOSS_LEVEL)
		return table.nums(tReachConditionList) > table.nums(tClaimedList)

	elseif nType == MoShenConst.REBEL_BOSS_AWARD_MODE.LEGION then
		return false
	end

	return false
end

-- 有没有挑战次数，红点机制
function MoShenData:hasRebelBossChallengeTime()
	-- 判断等级，功能是否开启
    local unlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.REBEL_BOSS)
    if not unlockFlag then
        return false
    end

	-- 判断是否在活动中
	local isOnActivity = (self._tInitializeInfo._nState == 1)
	if not isOnActivity then
		return false
	end
	return self._tInitializeInfo._nAttackCount > 0 
end

-- 只判断活动有没有开启
function MoShenData:isOnActivity()
	return self._tInitializeInfo._nState == 1
end

-- 暴击id
function MoShenData:setCritId(nId)
	self._nCritId = nId
end

function MoShenData:getCritId()
	local nTemp = self._nCritId or 0
	self._nCritId = 0
	return nTemp
end

function MoShenData:clearAllRebelBossData()
	self:_initRebelBoss()
end

function MoShenData:storeRecoverTimestamp(nTimestamp)
	self._nChallengeTimeRecoverTimestamp = nTimestamp or 0
end

function MoShenData:getRecoverTimestamp()
	return self._nChallengeTimeRecoverTimestamp
end

-- 是否从领奖快捷入口进入的
function MoShenData:setEnterFromAwardShortcut(enter)
	self._bEnterFromAwardShortcur = enter or false
end

function MoShenData:getEnterFromAwardShortcut()
	local tTemp = self._bEnterFromAwardShortcur or false
	self._bEnterFromAwardShortcur = false
	return tTemp
end

return MoShenData

