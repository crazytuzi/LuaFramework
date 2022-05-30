-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-04-30
-- --------------------------------------------------------------------
CrossarenaModel = CrossarenaModel or BaseClass()

function CrossarenaModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function CrossarenaModel:config()
	self.myBaseInfo = {}  -- 个人基础信息
	self.challengeRoleData = {}  -- 挑战角色列表
	self.challengeAwardData = {} -- 挑战次数奖励数据
	self.crossarenaStatus = CrossarenaConst.Open_Status.Close  -- 活动开启状态
	self.honourRoleData = {} -- 赛季荣耀数据

	self.arena_red_list = {} -- 红点数据
end

-- 设置个人基础信息
function CrossarenaModel:setCrossarenaMyBaseInfo( data )
	self.myBaseInfo = data
end

-- 更新刷新按钮的CD时间
function CrossarenaModel:updateRefreshTime( ref_time )
	if self.myBaseInfo and ref_time then
		self.myBaseInfo.ref_time = ref_time
	end
end

function CrossarenaModel:getCrossarenaMyBaseInfo(  )
	return self.myBaseInfo
end

-- 获取我的个人积分
function CrossarenaModel:getMyCrossarenaScore(  )
	if self.myBaseInfo then
		return self.myBaseInfo.score or 0
	end
	return 0
end

function CrossarenaModel:setCrossarenaAutoBattle( is_auto )
	if self.myBaseInfo then
		self.myBaseInfo.is_auto = is_auto
	end
end

-- 是否跳过战斗 0：不跳过 1：跳过
function CrossarenaModel:getCrossarenaAutoBattle(  )
	if self.myBaseInfo then
		return self.myBaseInfo.is_auto or 0
	end
	return 0
end

-- 本赛季挑战次数
function CrossarenaModel:getCrossarenaChallengeNum(  )
	if self.myBaseInfo then
		return self.myBaseInfo.season_combat_num or 0
	end
	return 0
end

-- 是否达到隐藏两队的要求
function CrossarenaModel:checkIsCanHideTwoTeam(  )
	local hide_cfg = Config.ArenaClusterData.data_const["second_hide_rank"]
	if hide_cfg and self.myBaseInfo and self.myBaseInfo.rank and self.myBaseInfo.rank > 0 and self.myBaseInfo.rank <= hide_cfg.val then
		return true
	end
	return false
end

-- 设置挑战角色数据
function CrossarenaModel:setChallengeRoleData( data )
	self.challengeRoleData = data
end

-- 更新挑战角色数据
function CrossarenaModel:updateChallengeRoleData( data )
	for _,newData in pairs(data) do
		for k,oldData in pairs(self.challengeRoleData) do
			if newData.idx == oldData.idx then
				self.challengeRoleData[k] = newData
				GlobalEvent:getInstance():Fire(CrossarenaEvent.Update_Single_Challenge_Role_Event, newData)
				break
			end
		end
	end
end

function CrossarenaModel:getChallengeRoleData( )
	return self.challengeRoleData
end

-- 判断是否有挑战角色数据
function CrossarenaModel:checkIsHaveChallengeData(  )
	if self.challengeRoleData and next(self.challengeRoleData) ~= nil then
		return true
	end
	return false
end

-- 设置挑战次数奖励数据
function CrossarenaModel:setChallengeAwardData( data )
	self.challengeAwardData = data
	self:checkCrossarenaPrompt()
end

--检测是否要显示气泡
function CrossarenaModel:checkCrossarenaPrompt()
	local is_time = ArenapeakchampionController:getInstance():getModel():isBeforeOpenMacthTime()
	if not is_time then return end
	local status = self:getCrossarenaStatus(  )
	if status and status == CrossarenaConst.Open_Status.Open and self.challengeAwardData and self.challengeAwardData.had_combat_num <=0 then
        PromptController:getInstance():getModel():addPromptData({type = PromptTypeConst.Corss_arena_tips})
    else
        PromptController:getInstance():getModel():removePromptDataByTpye(PromptTypeConst.Corss_arena_tips)
    end
end

function CrossarenaModel:getChallengeAwardData(  )
	return self.challengeAwardData
end

-- 根据次数判断奖励领取状态 1不可领取 2可领取 3已领取
function CrossarenaModel:getChallengeAwardStatus( num )
	local award_status = 1
	if self.challengeAwardData.had_combat_num and self.challengeAwardData.had_combat_num >= num then
		award_status = 2
		for k,v in pairs(self.challengeAwardData.num_list or {}) do
			if v.num == num then
				award_status = 3
				break
			end
		end
	end
	return award_status
end

-- 判断是否有奖励数据
function CrossarenaModel:checkIsHaveAwardData(  )
	if self.challengeAwardData and next(self.challengeAwardData) ~= nil then
		return true
	end
	return false
end

-- 设置活动开启状态
function CrossarenaModel:setCrossarenaStatus( status )
	self.crossarenaStatus = status
	if not self._first_login_flag and status == CrossarenaConst.Open_Status.Open then
		self._first_login_flag = true
		self:updateCrossarenaRedStatus(CrossarenaConst.Red_Index.Open, true)
	else
		self:updateCrossarenaRedStatus(CrossarenaConst.Red_Index.Open, false)
	end
end

function CrossarenaModel:getCrossarenaStatus(  )
	return self.crossarenaStatus
end

-- 跨服竞技场活动是否开启
function CrossarenaModel:checkCrossarenaIsOpen( )
	if self.crossarenaStatus == CrossarenaConst.Open_Status.Open then
        return true
    end
    local open_cfg = Config.ArenaClusterData.data_const["close_attention"]
    if open_cfg then
        message(open_cfg.desc)
    end
    return false
end

-- 跨服竞技场功能开启状态
function CrossarenaModel:getCrossarenaIsOpen( not_tips )
	if not Config.ArenaClusterData then return false end
	local role_vo = RoleController:getInstance():getRoleVo()
	local lev_limt_cfg = Config.ArenaClusterData.data_const["lev_limt"]
	if role_vo and role_vo.lev < lev_limt_cfg.val then
		if not not_tips then
			message(lev_limt_cfg.desc)
		end
		return false, lev_limt_cfg.desc
	end
	local world_lv = RoleController:getInstance():getModel():getWorldLev()
	local world_lv_cfg = Config.ArenaClusterData.data_const["world_lev_open"]
	if world_lv < world_lv_cfg.val then
		if not not_tips then
			message(world_lv_cfg.desc)
		end
		return false, world_lv_cfg.desc
	end
	return true
end

-- 根据排名获取对应的奖励数据
function CrossarenaModel:getCrossarenaRankAward( rank )
	for k,cfg in pairs(Config.ArenaClusterData.data_rank_award) do
		if rank <= cfg.max and rank >= cfg.min then
			return cfg.items
		end
	end
end

--设置赛季荣耀数据
function CrossarenaModel:setHonourRoleData( data )
	self.honourRoleData = data

	local red_status = false
	for k,v in pairs(self.honourRoleData) do
		if v.worship_status == 0 then
			red_status = true
			break
		end
	end
	self:updateCrossarenaRedStatus(CrossarenaConst.Red_Index.Like, red_status)
end

function CrossarenaModel:getHonourRoleData(  )
	return self.honourRoleData
end

-- 红点相关
function CrossarenaModel:updateCrossarenaRedStatus( bid, status )
    local _status = self.arena_red_list[bid]
    if _status == status then return end

    self.arena_red_list[bid] = status

    local arena_status = self:checkCrossarenaRedStatus()
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.ladder, {bid = CrossgroundConst.Red_Type.crossArena, status = arena_status})
    GlobalEvent:getInstance():Fire(CrossarenaEvent.Update_Red_Status_Event, bid, status)
end

function CrossarenaModel:checkCrossarenaRedStatus(  )
	local status = false
	for k,v in pairs(self.arena_red_list) do
		if v == true then
			status = true
			break
		end
	end
	return status
end

-- 根据红点类型获取红点状态
function CrossarenaModel:getCrossarenaRedStatus( red_type )
	return self.arena_red_list[red_type] or false
end

function CrossarenaModel:__delete()
end