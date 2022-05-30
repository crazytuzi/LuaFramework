-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-10-08
-- --------------------------------------------------------------------
GuildwarModel = GuildwarModel or BaseClass()

function GuildwarModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function GuildwarModel:config()
	self.challengeCount = 0 		-- 已挑战次数
	self.guildWarResult = GuildwarConst.result.fighting -- 战斗结果
	self.myGuildWarBaseInfo = {}	-- 我方联盟战基础数据(星数、buff等)
	self.enemyGuildWarBaseInfo = {} -- 敌方联盟战基础数据(星数、名称)
	self.guildWarStatus = GuildwarConst.status.close -- 联盟战状态
	self.guildWarStartTime = 0 		-- 联盟战开始时间
	self.guildWarEndTime = 0 		-- 联盟战结束时间
	self.guildWarEnemyFlag = 0 		-- 是否匹配到对手
	self.guildWarTopThreeRank = {}  -- 前三排名

	self.myGuildWarPositionList = {}  -- 我方据点数据
	self.enemyGuildWarPositionList = {} -- 敌方据点数据

	self.award_box_data = {}  		-- 奖励宝箱数据

	self.guildwar_red_list = {} 	-- 红点数据
end

--联盟总战力
function GuildwarModel:setAvgPower(avg_power)
	self.avg_power = avg_power or 0
end

function GuildwarModel:getAvgPower()
	return self.avg_power or 0
end

-- 本地是否有联盟战敌方数据
function GuildwarModel:checkIsHaveEnemyCacheData(  )
	if next(self.enemyGuildWarPositionList) == nil then
		return false
	else
		return true
	end
end

-- 清空敌方联盟数据（断线重连时清空，重连成功后打开公会战则会重新请求数据）
function GuildwarModel:clearEnemyCacheData(  )
	self.enemyGuildWarPositionList = {}
end

-- 设置已挑战次数
function GuildwarModel:setGuildWarChallengeCount( count )
	self.challengeCount = count or 0
	self:updateChallengeCountRedStatus()
end

function GuildwarModel:getGuildWarChallengeCount(  )
	return self.challengeCount
end
-- 更新挑战次数红点
function GuildwarModel:updateChallengeCountRedStatus(  )
	if self.guildWarEnemyFlag == TRUE and self.guildWarStatus == GuildwarConst.status.processing and self.challengeCount < Config.GuildWarData.data_const.challange_time_limit.val then
		self:updateGuildWarRedStatus(GuildConst.red_index.guildwar_count, true)
	else
		self:updateGuildWarRedStatus(GuildConst.red_index.guildwar_count, false)
	end
end

-- 设置联盟战结果
function GuildwarModel:setGuildWarResult( result )
	self.guildWarResult = result
end
function GuildwarModel:getGuildWarResult(  )
	return self.guildWarResult
end

-- 设置我方联盟战基础数据(星数、buff等)
function GuildwarModel:setMyGuildWarBaseInfo( data )
	self.myGuildWarBaseInfo = data or {}
end
function GuildwarModel:getMyGuildWarBaseInfo(  )
	return self.myGuildWarBaseInfo
end

-- 更新我方联盟战基础数据
function GuildwarModel:updateMyGuildWarBaseInfo( data )
	for k,v in pairs(data) do
		self.myGuildWarBaseInfo[k] = v
	end
end

-- 更新敌方联盟战基础数据(目前只是星数)
function GuildwarModel:updateEnemyGuildWarBaseInfo( hp )
	self.enemyGuildWarBaseInfo.hp = hp
end
function GuildwarModel:getEnemyGuildWarBaseInfo(  )
	return self.enemyGuildWarBaseInfo
end

-- 设置敌方联盟战数据
function GuildwarModel:setEnemyGuildWarData( data )
	-- 基础数据
	self.enemyGuildWarBaseInfo.gname = data.gname2 or ""
	self.enemyGuildWarBaseInfo.hp = data.hp2 or 0
	self.enemyGuildWarBaseInfo.g_id = data.g_id or 0
	self.enemyGuildWarBaseInfo.g_sid = data.g_sid or ""

	-- 据点数据
	self.enemyGuildWarPositionList = {}
	for k,pdata in pairs(data.defense or {}) do
		local position_vo = GuildWarPositionVo.New()
		position_vo:updateData(pdata)
		self.enemyGuildWarPositionList[pdata.pos] = position_vo
	end
end
function GuildwarModel:getEnemyGuildWarPositionList(  )
	return self.enemyGuildWarPositionList
end

-- 获取敌方某一据点的当前血量
function GuildwarModel:getEnemyPositionHpByPos( pos )
	local position_vo = self.enemyGuildWarPositionList[pos]
	if position_vo then
		return position_vo.hp
	end
	return 0
end

-- 敌方是否还有存活的据点
function GuildwarModel:checkEnemyIsHaveLivePosition(  )
	local is_have = false
	for k,position_vo in pairs(self.enemyGuildWarPositionList) do
		if position_vo.hp > 0 then
			is_have = true
			break
		end
	end
	return is_have
end

-- 设置联盟战状态数据
function GuildwarModel:setGuildWarStatus( data )
	self.guildWarStatus = data.status or GuildwarConst.status.close
	self.guildWarStartTime = data.start_time or 0
	self.guildWarEndTime = data.end_time or 0
	self.guildWarEnemyFlag = data.flag or 0

	dump(data,"联盟状态-----》》")

	-- 当状态变为未开启时，清掉缓存数据
	if self.guildWarStatus == GuildwarConst.status.close then
		self:config()
	end
	self:checkGuildWarStatusRed()
	self:updateChallengeCountRedStatus()
end

-- 更新联盟战状态的红点
function GuildwarModel:checkGuildWarStatusRed(  )
	if self.guildWarEnemyFlag == TRUE and self.guildWarStatus == GuildwarConst.status.showing then
		if not self._match_red_flag then -- 该红点只显示一次
			self._match_red_flag = true
			self:updateGuildWarRedStatus(GuildConst.red_index.guildwar_match, true)
		end
	elseif self.guildWarEnemyFlag == TRUE and self.guildWarStatus == GuildwarConst.status.processing then
		if not self._start_red_flag then -- 该红点只显示一次
			self._start_red_flag = true
			self:updateGuildWarRedStatus(GuildConst.red_index.guildwar_start, true)
		end
		self:updateGuildWarRedStatus(GuildConst.red_index.guildwar_match, false)
	else
		self:updateGuildWarRedStatus(GuildConst.red_index.guildwar_match, false)
		self:updateGuildWarRedStatus(GuildConst.red_index.guildwar_start, false)
	end
end

function GuildwarModel:getGuildWarStatus(  )
	return self.guildWarStatus
end
function GuildwarModel:getGuildWarSurplusTime(  )
	local cur_time = GameNet:getInstance():getTime()
	return self.guildWarEndTime - cur_time
end
function GuildwarModel:getGuildWarEnemyFlag(  )
	return self.guildWarEnemyFlag
end

-- 设置我方联盟战据点数据
function GuildwarModel:setMyGuildWarPositionData( dataList )
	self.myGuildWarPositionList = {}
	for k,data in pairs(dataList) do
		local position_vo = GuildWarPositionVo.New()
		position_vo:updateData(data)
		self.myGuildWarPositionList[data.pos] = position_vo
	end
end
function GuildwarModel:getMyGuildWarPositionList(  )
	return self.myGuildWarPositionList
end

-- 更新我方据点数据(变量更)
function GuildwarModel:updateMyGuildWarPositionData( dataList )
	dataList = dataList or {}
	for k,data in pairs(dataList) do
		local position_vo = self.myGuildWarPositionList[data.pos]
		if position_vo then
			position_vo:updateData(data)
		end
	end
end

-- 更新敌方据点数据(变量更)
function GuildwarModel:updateEnemyGuildWarPositionData( dataList )
	dataList = dataList or {}
	for k,data in pairs(dataList) do
		local position_vo = self.enemyGuildWarPositionList[data.pos]
		if position_vo then
			position_vo:updateData(data)
		end
	end
end

-- 设置联盟战前三名数据
function GuildwarModel:setGuildWarTopThreeRank( data )
	self.guildWarTopThreeRank = data
end
function GuildwarModel:getGuildWarTopThreeRank(  )
	return self.guildWarTopThreeRank
end

-- 更新联盟战红点
function GuildwarModel:updateGuildWarRedStatus(bid, status, is_just_guildwar)
    local _status = self.guildwar_red_list[bid]
    if _status == status then return end

	self.guildwar_red_list[bid] = status

	if not is_just_guildwar then
		-- 更新场景红点状态
    	MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.guild, {bid = bid, status = status}) 
		-- 更新公会主界面红点
		GlobalEvent:getInstance():Fire(GuildEvent.UpdateGuildRedStatus, bid, status)
	end
	-- 更新公会战主界面红点
	GlobalEvent:getInstance():Fire(GuildwarEvent.UpdateGuildWarRedStatusEvent, bid, status)
end

function GuildwarModel:checkRedIsShowByRedType( redType )
	return self.guildwar_red_list[redType] or false
end

function GuildwarModel:checkGuildGuildWarRedStatus(  )
	for k, v in pairs(self.guildwar_red_list) do
		-- 排除日志红点，日志无需在入口处显示红点
		if v == true and k ~= GuildConst.red_index.guildwar_log then
			return true
		end
	end
	return false
end

-- 设置奖励宝箱数据
function GuildwarModel:setGuildWarBoxData( data )
	local dataList = data.guild_war_box
	local result = data.result
	local status = data.status
	local end_time = data.end_time

	if dataList then
		self.award_box_data = {}
		for k,data in pairs(dataList) do
			data.status = result  -- 在这里赋值宝箱类型（金和铜）
			local box_vo = GuildWarBoxVo.New()
			box_vo:updateData(data)
			table.insert(self.award_box_data, box_vo)
		end
	end

	local cur_time = GameNet:getInstance():getTime()
	-- 是否有权限领取宝箱、是否已到领取截止时间
	if status and status == 1 and end_time and end_time > cur_time then
		self.is_can_get_box = true
	else
		self.is_can_get_box = false
	end
	if self.is_can_get_box and not self:checkIsGetBoxAward() then
		self:updateGuildWarRedStatus(GuildConst.red_index.guildwar_box, true)
	else
		self:updateGuildWarRedStatus(GuildConst.red_index.guildwar_box, false)
	end
end

-- 更新宝箱数据
function GuildwarModel:updateGuildWarBoxData( data )
	if data then
		local box_vo = self:getGuildWarDataByOrder(data.order)
		if box_vo then
			box_vo:updateData(data)
		end
		if self.is_can_get_box and not self:checkIsGetBoxAward() then
			self:updateGuildWarRedStatus(GuildConst.red_index.guildwar_box, true)
		else
			self:updateGuildWarRedStatus(GuildConst.red_index.guildwar_box, false)
		end
	end
end

-- 根据序号获取宝箱数据
function GuildwarModel:getGuildWarDataByOrder( order )
	for k,box_vo in pairs(self.award_box_data) do
		if box_vo.order == order then
			return box_vo
		end
	end
end

-- 获取全部宝箱数据
function GuildwarModel:getGuildWarBoxData(  )
	return self.award_box_data
end

-- 玩家是否领取了宝箱数据
function GuildwarModel:checkIsGetBoxAward(  )
	local is_get = false
	local role_vo = RoleController:getInstance():getRoleVo()
	for k,box_vo in pairs(self.award_box_data) do
		if role_vo and box_vo.rid == role_vo.rid and box_vo.sid == role_vo.srv_id then
			is_get = true
			break
		end
	end
	return is_get
end

function GuildwarModel:__delete()
end