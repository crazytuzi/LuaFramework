-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-11-01
-- --------------------------------------------------------------------
LadderModel = LadderModel or BaseClass()

function LadderModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function LadderModel:config()
	self.myBaseInfo = {}      -- 个人数据
	self.enemyListData = {}	  -- 挑战对手数据
	self.ladderOpenStatus = 0 -- 天梯是否开启

	self.guildwar_red_list = {} 	-- 红点数据
end

-- 个人数据
function LadderModel:setLadderMyBaseInfo( data )
	self.myBaseInfo = data
end
function LadderModel:getLadderMyBaseInfo(  )
	return self.myBaseInfo
end

-- 获取剩余挑战次数
function LadderModel:getLeftChallengeCount(  )
	if self.myBaseInfo then
		return self.myBaseInfo.can_combat_num or 0
	end
	return 0
end

-- 获取今日购买次数
function LadderModel:getTodayBuyCount(  )
	if self.myBaseInfo then
		return self.myBaseInfo.buy_combat_num or 0
	end
	return 0
end

-- 获取今日剩余购买次数
function LadderModel:getTodayLeftBuyCount(  )
	local role_vo = RoleController:getInstance():getRoleVo()
	local buy_count = self.myBaseInfo.buy_combat_num or 0
	local max_count = 0
	for k,v in pairs(Config.SkyLadderData.data_buy_num) do
		if v.vip <= role_vo.vip_lev then
			max_count = max_count + 1
		end
	end
	local left_count = max_count - buy_count
	if left_count < 0 then left_count = 0 end
	return left_count
end

-- 设置挑战对手数据
function LadderModel:setLadderEnemyListData( data )
	self.enemyListData = data or {}
end
function LadderModel:updateLadderEnemyListData( data )
	data = data or {}
	for k,newData in pairs(data) do
		for _,oldData in pairs(self.enemyListData) do
			if newData.idx == oldData.idx then
				for key,value in pairs(newData) do
					oldData[key] = value
				end
				break
			end
		end
	end
end
function LadderModel:getLadderEnemyListData(  )
	return self.enemyListData
end

function LadderModel:getLadderEnemyDataByIndex( index )
	local enemy_data = {}
	for k,eData in pairs(self.enemyListData) do
		if eData.idx == index then
			enemy_data = eData
			break
		end
	end
	return enemy_data
end

-- 天梯是否开启
function LadderModel:setLadderOpenStatus( status )
	self.ladderOpenStatus = status
end

-- 天梯活动是否开启
function LadderModel:getLadderIsOpen(  )
	return (self.ladderOpenStatus and self.ladderOpenStatus == 1)
end

-- 是否满足天梯功能开启条件 not_tips 不飘字提示
function LadderModel:getLadderOpenStatus( not_tips )
	not_tips = not_tips or false
	local role_vo = RoleController:getInstance():getRoleVo()
	local config = Config.SkyLadderData.data_const.join_min_lev
	if config and config.val <= role_vo.lev then
		return true
	else
		if not not_tips then
			message(config.desc)
		end
		return false, config.desc
	end
end

-- 更新天梯红点
function LadderModel:updateLadderRedStatus(bid, status)
    local _status = self.guildwar_red_list[bid]
    if _status == status then return end

	self.guildwar_red_list[bid] = status

	-- 更新主界面图标红点
	local ladder_status = self:checkLadderRedStatus()
	MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.ladder, {bid = CrossgroundConst.Red_Type.ladder, status = ladder_status})
	-- 更新天梯界面红点
	GlobalEvent:getInstance():Fire(LadderEvent.UpdateLadderRedStatus, bid, status)
end

function LadderModel:checkRedIsShowByRedType( redType )
	return self.guildwar_red_list[redType] or false
end

function LadderModel:checkLadderRedStatus(  )
	for k, v in pairs(self.guildwar_red_list) do
		if v == true then
			return true
		end
	end
	return false
end

function LadderModel:__delete()
end