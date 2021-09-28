-- 队伍数据管理
ZDModel = BaseClass(LuaModel)
function ZDModel:__init()
	self:Reset()
end

function ZDModel:Reset()
	self.openType = 0 -- 0 队伍大厅 1 我的队伍
	self.teamList = {} -- 大厅列表
	self.mineTeam = {}
	-- 大厅
	self.autoMath = false -- 自动匹配队伍
	-- 我的队伍信息
	self.teamId=0 -- 队伍唯一编号
	self.activityId=0 -- 活动编号
	self.minLevel=1 -- 最低等级
	self.state=0 -- 0：正常 1：满员
	self.members={} -- 队员列表

	self.isFollow = false -- 是否跟随
	self.autoAgree = true -- 自动同意
	self.teamMath = 1 -- 队伍匹配成员 1匹配 0不匹配

	-- 申请加入列表
	self.applyList = {}
	self.hasReq = false -- 是否有人申请加入
	self.isHanhuaCDing = {false, false, false, false}
	self.hanhuaCD = {}
end

-- 大厅
	function ZDModel:ClearTeamList()
		for k,v in pairs(self.teamList) do
			v:Destroy()
		end
		self.hasReq = false
		self.teamList = {}
	end
	function ZDModel:UpdateTeamList(list)
		-- local vo = nil
		self.teamList={}
		SerialiseProtobufList( list, function ( item )
			-- vo = self.teamList[item.teamId]
			-- if vo then
			-- 	vo:Update(item)
			-- else
			-- 	vo = ZDVo.New(item)
			-- 	self.teamList[item.teamId] = vo
			-- end
			if item and self:IsTeamMate( item.playerId ) then return end
			local vo = ZDVo.New(item)
			table.insert(self.teamList, vo)
		end)
		if #self.teamList ~= 0 then
			SortTableByKey( self.teamList, "createTime", false )
		end
		self:Fire(ZDConst.HALL_CHANGE)
	end

	-- 自动匹配队伍
	function ZDModel:AutoMathTeam( v, id )
		if self.autoMath == v then return end
		self.autoMath = v
		if v then
			ZDCtrl:GetInstance():C_PlayerAutoMatch(id)
			RenderMgr.AddInterval(function ()
				ZDCtrl:GetInstance():C_PlayerAutoMatch(id)
			end, 
				"autoMath_team_key", 2, 30,
				function ()
					self.autoMath = false
					self:Fire(ZDConst.FINISH_MATCH_TEAM)
					UIMgr.Win_FloatTip("很遗憾，未找到可匹配的队伍!")
				end)
		else
			self:Fire(ZDConst.FINISH_MATCH_TEAM)
			RenderMgr.Realse("autoMath_team_key")
		end
	end
	-- 设置匹配活动编号
	function ZDModel:SetActivityId(id)
		self.activityId = id or 0
	end
	function ZDModel:GetActivityId()
		return self.activityId or 0
	end
	

-- 我的队伍
	function ZDModel:SynTeam(msg)
		self.teamId = msg.teamId or 0
		if msg.activityId then
			self.activityId = msg.activityId
		end
		self.minLevel = msg.minLevel or 0
		self.state = msg.state or 0
		self.members = {}
		SerialiseProtobufList( msg.listTeamPlayers, function ( item )
			self.members[item.playerId] = ZDMemberVo.New(item)
		end)
		self:Fire(ZDConst.MINE_CHANGE)
		GlobalDispatcher:Fire(EventName.TEAM_CHANGED)
		if self.teamId ~= 0 then
			self:Fire(ZDConst.FINISH_MATCH_TEAM)
			self.autoMath = false
			RenderMgr.Realse("autoMath_team_key")
		end
		if self.teamId == 0 or self:IsLeader() then
			self:SetFollow(false)
		end
		GlobalDispatcher:Fire(EventName.TeamListChange, self.teamId)
	end
	-- 获取某个成员或全部成员
	function ZDModel:GetMember( playerId )
		if not playerId then return self.members or {} end
		return self.members[playerId]
	end
	-- 是否为同队
	function ZDModel:IsTeamMate( playerId )
		return playerId ~= nil and self.members[playerId] ~= nil
	end
	function ZDModel:UpdateMember( playerId, hp, maxHp )
		if not playerId then return end
		local mem = self:GetMember( playerId )
		if not mem then return end
		mem.hp = hp or mem.hp
		mem.maxHp = maxHp or mem.maxHp
		GlobalDispatcher:Fire(EventName.MEMBER_HP_CHANGED, playerId)
	end
	-- 重置清空队伍
	function ZDModel:ClearMine()
		self.autoMath = false
		RenderMgr.Realse("autoMath_team_key")
		self.teamId=0
		self.activityId=0
		self.minLevel=1
		self.state=0
		self.teamMath = 1
		self.members={}
		self.autoAgree = true
		self:Fire(ZDConst.MINE_CHANGE)
		GlobalDispatcher:Fire(EventName.TEAM_CHANGED)
		self:SetFollow(false)
		self.hasReq = false
	end
	-- 是否玩家为队长
	function ZDModel:IsLeader()
		local id = LoginModel:GetInstance():GetLoginRole().playerId
		for mId,v in pairs(self.members) do
			if id == mId then
				return v.captain
			end
		end
		return false
	end
	-- 获取得队长id
	function ZDModel:GetLeaderId()
		local id = LoginModel:GetInstance():GetLoginRole().playerId
		for mId,v in pairs(self.members) do
			if v.captain then
				if mId ~= id then
					return v.playerId
				else
					return 0
				end
			end
		end
		return 0
	end
	-- 设置有申请加入状态
	function ZDModel:SetHasReq( bool )
		self.hasReq = bool == true
		if bool then
			GlobalDispatcher:Fire(EventName.NOTICE_REQ_INTEAM)
		end
	end
	-- 自动同意
	function ZDModel:SetAutoAgree( bool )
		if self.autoAgree ~= bool then
			self.autoAgree = bool
		end
		ZDCtrl:GetInstance():C_AutoAgreeApply()
	end
	-- 跟随
	function ZDModel:SetFollow(bool)
		if self.isFollow == bool then return end
		self.isFollow = bool
		if bool then
			ZDCtrl:GetInstance():C_GetCaptainPostion()
			RenderMgr.AddInterval(function () 
				ZDCtrl:GetInstance():C_GetCaptainPostion()
			end, 
			"auto_follow_key", 6)
		else
			RenderMgr.Realse("auto_follow_key")
		end
		ZDCtrl:GetInstance():C_Follow()
		self:Fire(ZDConst.FOLLOW)
		self.posFollow = nil
	end

	function ZDModel:IsFollowing()
		return self.isFollow
	end

--申请加入队伍列表
	function ZDModel:UpdateTeamApplyList( list )
		self.applyList = {}
		SerialiseProtobufList(list, function ( item )
			local vo = InviteVo.New(item)
			table.insert(self.applyList, item)
		end)
		self:Fire(ZDConst.APPLYLIST_CHANGE)
	end

function ZDModel:GetInstance()
	if ZDModel.inst == nil then
		ZDModel.inst = ZDModel.New()
	end
	return ZDModel.inst
end

function ZDModel:__delete()
	self.autoMath = false
	RenderMgr.Realse("autoMath_team_key")
	RenderMgr.Realse("auto_follow_key")
	for i = 1, #self.isHanhuaCDing do
		RenderMgr.Realse("hanhuaCD" .. i)
	end
	ZDModel.inst = nil
end

function ZDModel:GetTeamId()
	return self.teamId or 0
end

--未在主城的成员信息
function ZDModel:GetNotInMainMapMember()
	local tab = {}
	for k, v in pairs(self.members) do
		if v.mapId and v.mapId ~= 1001 then
			table.insert(tab, v)
		end
	end
	return tab
end

--获得"xxx,xxx不在主城"的tip string
function ZDModel:GetNameTipStr(memTab)
	local nameStr = ""
	local len = #memTab
	for i = 1, len do
		local name = memTab[i].playerName or ""
		nameStr = nameStr .. name
		if i ~= len then
			nameStr = nameStr .. ","
		end
	end
	nameStr = StringFormat("{0}不在主城,无法开启副本", nameStr)
	return nameStr
end
--开始一键喊话cd
function ZDModel:StartHanhuaCD(index)
	if not self.isHanhuaCDing[index] then
		self.isHanhuaCDing[index] = true
		local cfg = GetCfgData("constant"):Get(31)
		if cfg then
			self.hanhuaCD[index] = cfg.value or 10
		end
		RenderMgr.Add(function() self:UpdateHanhuaCD(index) end, "hanhuaCD" .. index)
	end
end

function ZDModel:UpdateHanhuaCD(index)
	if not self.hanhuaCD[index] then return end
	self.hanhuaCD[index] = self.hanhuaCD[index] - Time.deltaTime
	if self.hanhuaCD[index] <= 0 then
		self.isHanhuaCDing[index] = false
		RenderMgr.Realse("hanhuaCD" .. index)
	end
end

function ZDModel:IsHanhuaCDing(index)
	index = index or 1
	return self.isHanhuaCDing[index]
end

function ZDModel:GetMemNum()
	local num = 0
	if self:GetTeamId() ~= 0 and self.members then
		for _, v in pairs(self.members) do
			num = num + 1
		end
	end
	return num
end

function ZDModel:FollowLeader(msg)
	local scene = SceneController:GetInstance():GetScene()
	if scene then
		local role = scene:GetMainPlayer()
		if not self:IsLeader() and role then
			self:StopBeforeFollow()
			self.posFollow = Vector3.New(msg.position.x*0.01, msg.position.y*0.01, msg.position.z*0.01)
			role:SetWorldNavigation(msg.mapId, self.posFollow)
		end
	end
end

function ZDModel:StopBeforeFollow()
	GlobalDispatcher:DispatchEvent(EventName.AutoFightEnd)
	SceneController:GetInstance():GetScene():StopAutoFight(false)
	GlobalDispatcher:DispatchEvent(EventName.Player_AutoRunEnd)
	--GlobalDispatcher:DispatchEvent(EventName.Player_StopWorldNavigation)
	GlobalDispatcher:DispatchEvent(EventName.StopReturnMainCity) -- 停止回城动作
	GlobalDispatcher:DispatchEvent(EventName.StopCollect)
end
--是否到达队长身边
function ZDModel:IsFollowEnd(mainPlayer)
	if self.posFollow and mainPlayer then
		return MapUtil.IsNearByV3( self.posFollow, mainPlayer:GetPosition(), 2 )
	end
end

function ZDModel:StopFollowIfReach(mainPlayer)
	if self:IsFollowEnd(mainPlayer) then
		self:SetFollow(false)-- 取消跟随队长
	end
end

function ZDModel:SetSelectActivityId(id)
	self.selectActivityId = id
end

function ZDModel:GetSelectActivityId()
	return self.selectActivityId or 0
end

function ZDModel:GetPosFollow()
	return self.posFollow
end