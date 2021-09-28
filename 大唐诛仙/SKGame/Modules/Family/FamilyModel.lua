FamilyModel = BaseClass(LuaModel)

function FamilyModel:__init( ... )
	self.openType = 0 -- 0 创建界面 1 家族界面
	self.inviteList = {} -- 可邀请成员
	self.inviteVo = nil -- 收到的邀请信息
	self.invitePanelList = {} -- 被邀请列表
	self.tab = {} -- 单个邀请面板
	self.invitePanel = {} -- 邀请面板
	self.inviteTime = 30 -- 邀请倒计时

	self.familyId = 0 -- 家族id
	self.familyName = "" -- 家族名字
	self.familyNotice = "" -- 家族公告
	self.familyPost = "" -- 家族称谓
	self.members = {} -- 家族成员
	self.listFamilyPlayer = {}
	self.familyGo = {} -- 家族成员模型

	self.sortList = {} -- 排序位调整列表
	self.sortIds = {} -- 排序
	
	self.state = 0 -- 家族状态 1 main 0 create

	self.talkCD = false -- 喊话CD中
	self.redTips = false -- 邀请红点状态
	self.modelState = true -- 是否隐藏模型

	self:InitEvent()
end

function FamilyModel:InitEvent()
	self.role = LoginModel:GetInstance():GetLoginRole()
	self:AddListener()
end

function FamilyModel:AddListener()
	-- 切换账号清除家族信息
	self.reloginHandler = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function ()
		self:Clear()
	end)
end

function FamilyModel:GetInstance()
	if FamilyModel.inst == nil then
		FamilyModel.inst = FamilyModel.New()
	end
	return FamilyModel.inst
end	

function FamilyModel:GetFamilyId()
	return self.familyId or 0
end

-- 创建条件
	-- 主角等级是否满足
	function FamilyModel:IsLevelEnough()
		local level = self.role.level
		return level >= GetCfgData("constant"):Get(5).value
	end

	-- 主角金币是否满足
	function FamilyModel:IsGoldEnough()
		local gold = self.role.gold
		return gold >= GetCfgData("constant"):Get(3).value
	end

-- 已创建
	function FamilyModel:SynMembers( msg )
		self.members = {}
		self.sortIds = {}
		self.sortList = {}
		self.listFamilyPlayer = {}
		self.familyId = msg.playerFamilyId or 0
		self.familyName = msg.familyName or ""
		self.familyNotice = msg.familyNotice or ""
		SerialiseProtobufList( msg.listFamilyPlayer, function ( item )
			self.members[item.playerId] = FamilyMemberVo.New(item)
			table.insert(self.listFamilyPlayer, item)
			table.insert(self.sortList, item)
			table.insert(self.sortIds, item.familySortId)
		end)
		SortTableByKey( self.sortList, "familySortId", true )
		table.sort( self.sortIds )
	end

	-- 更新成员列表
	function FamilyModel:UpdateMembers( list )
		SerialiseProtobufList( list, function ( item )
			if item and self:IsFamilyMate( item.playerId ) then return end
			local vo = FamilyMemberVo.New(item)
			-- table.insert(self.members, vo)
			self.members[item.playerId] = vo
		end)

		if #self.members ~= 0 then
			SortTableByKey( self.members, "familySortId", true )
		end
	end

	-- 更新邀请列表
	function FamilyModel:UpdateInviteList( list )
		self.inviteList = {}
		SerialiseProtobufList( list, function ( item )
			if item and self:IsHasFamily( item.playerId ) then return end
			local vo = FamilyInviteVo.New(item)
			table.insert(self.inviteList, vo)
		end)
	end

	-- 存入排序
	function FamilyModel:SetSortMembers( index1, index2 )
		self.sortIds = {}
		local player1 = self.sortList[index1]
		self.sortList[index1] = self.sortList[index2]
		self.sortList[index2] = player1
		for i,v in ipairs(self.sortList) do
			local playerId = v.playerId
			table.insert(self.sortIds, self.members[playerId].familySortId)
			v.familySortId = i
		end

		self:DispatchEvent(FamilyConst.FAMILY_SORT, self.sortList)
	end

	-- 取消排序
	function FamilyModel:ClearSortMembers()
		self.sortList = {}
		self.sortIds = {}

		for i,v in ipairs(self.listFamilyPlayer) do
			v.familySortId = i
		end

		SerialiseProtobufList( self.listFamilyPlayer, function ( item )
			table.insert(self.sortList, item)
			table.insert(self.sortIds, item.familySortId)
		end)

		SortTableByKey( self.sortList, "familySortId", true )
		SortTableByKey( self.listFamilyPlayer, "familySortId", true )
		table.sort( self.sortIds )

		self:DispatchEvent(FamilyConst.FAMILY_SORT, self.listFamilyPlayer)
	end

	-- 存入模型
	function FamilyModel:SetFamilyModel( model )
		table.insert(self.familyGo, model)
	end

	-- 清空所有模型
	function FamilyModel:ClearFamilyModel()
		if self.familyGo then
			for i,v in ipairs(self.familyGo) do
				table.remove(self.familyGo, i)
			end
		end
		self.familyGo = {}
	end

	-- 删除某个模型
	function FamilyModel:RemoveModel( playerId )
		for i,v in ipairs(self.familyGo) do
			if v.playerId == playerId then
				table.remove(self.familyGo, i)
				break
			end
		end
	end

	-- 是否存在模型
	function FamilyModel:IsHaveModel( model )
		for i,v in ipairs(self.familyGo) do
			if v.playerId == model.playerId then
				return true
			end
		end
		return false
	end

	-- 设置模型显示
	function FamilyModel:SetFamilyModelShow( bool )
		self.modelState = bool
		if self.familyGo then
			for i,v in ipairs(self.familyGo) do
				v.model.visible = bool
			end
		end
	end

	function FamilyModel:GetModelState()
		return self.modelState
	end

-- 设置有邀请状态
function FamilyModel:SetRedTips( bool )
	self.redTips = bool == true
	if self.redTips then
		GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.social , state = true})
	end
end

function FamilyModel:GetRedTips()
	return self.redTips == true
end

-- 获取某个成员或全部成员
function FamilyModel:GetMember( playerId )
	if not playerId then return self.members or {} end
	return self.members[playerId]
end

-- 获取某个好友是否有家族
function FamilyModel:IsHasFamily( playerId )
	
end

-- 获取可邀请好友
function FamilyModel:GetInviteFriends()
	local friendList = {}
	-- 可邀请的好友列表
	local inviteFriendList = {}
	
	SerialiseProtobufList( FriendModel:GetInstance():GetFriendList(), function ( v )
		table.insert(friendList, v)
	end )

	local level = GetCfgData("constant"):Get(5).value
	SerialiseProtobufList( friendList, function ( v )
		if toLong(v.exitTime) == 0 and toLong(v.playerFamilyId) == 0 and v.level >= level then
			table.insert( inviteFriendList, v )
		end
	end )

	return inviteFriendList
end

-- 存入邀请面板
function FamilyModel:SaveInvitePanel( playerFamilyId, vo )
	if playerFamilyId and vo then
		self.tab = {
			playerFamilyId = playerFamilyId,
			vo = vo
		}
		table.insert(self.invitePanelList, self.tab)
		self.tab = {}
	end
end

-- 邀请面板处理
function FamilyModel:RemoveInvitePanel( agr, familyId )
	if agr then -- 接受邀请
		if #self.invitePanelList >= 1 then
			for i,v in ipairs(self.invitePanelList) do
				table.remove(self.invitePanelList, i)
			end

			for i,v in ipairs(self.invitePanel) do
				v:Destroy()
			end
		end
		self.invitePanel = {}
		self.invitePanelList = {}
	else
		if self.invitePanelList then
			for i,v in ipairs(self.invitePanelList) do
				if v.playerFamilyId == familyId then
					table.remove(self.invitePanelList, i)
				end
			end
		end
	end
end

-- 清除家族信息
function FamilyModel:Clear()
	self.familyId = 0
	self.familyName = ""
	self.familyNotice = ""
	self.members = {}
	self.listFamilyPlayer = {}
	self.familyGo = {}
	self.sortIds = {}
	self.sortList = {}
	self.state = 0
	self:DispatchEvent(FamilyConst.FAMILY_HEADNAME)
end

function FamilyModel:ResetInviteTime( time )
	if time then
		self.inviteTime = time
	else
		self.inviteTime = 30
	end
end

function FamilyModel:GetInviteTime()
	return self.inviteTime
end

-- 是否为家族成员
function FamilyModel:IsFamilyMate( playerId )
	return playerId ~= nil and self.members[playerId] ~= nil
end

-- 自己是否为族长
function FamilyModel:IsFamilyLeader()
	if self.familyId ~= 0 then
		local id = LoginModel:GetInstance():GetLoginRole().playerId
		return self.members[id].familyPosId == 2
	else
		return false
	end
end

-- 信息面板加入家族
function FamilyModel:JoinFamily( id )
	local msg = ""
	if self.familyId ~= 0 then
		if not self:IsFamilyLeader() then
			msg = GetCfgData("game_exception"):Get(2602).exceptionMsg
			UIMgr.Win_FloatTip(msg)
			return
		elseif self:IsFamilyMate(id) then
			UIMgr.Win_FloatTip("玩家已是家族成员")
			return
		end
		FamilyCtrl:GetInstance():C_InviteJoinFamily( id )
	else
		msg = GetCfgData("game_exception"):Get(2601).exceptionMsg
		UIMgr.Win_FloatTip(msg)
		return
	end
end

-- 一键喊话CD开始
function FamilyModel:StartTalkCD()
	if not self.talkCD then
		self.talkCD = true
		self.time = GetCfgData("constant"):Get(31).value
	end
	RenderMgr.Add(function() self:UpdateTalkCD() end, "talkCD")
end

-- 更新喊话间隔
function FamilyModel:UpdateTalkCD()
	if not self.time then return end
	self.time = self.time - Time.deltaTime
	if self.time <= 0 then
		self.time = 0
		self.talkCD = false
		RenderMgr.Realse("talkCD")
	end
end

-- 喊话是否CD中
function FamilyModel:IsTalkCD()
	return self.talkCD
end

function FamilyModel:__delete()
	FamilyModel.inst = nil
	if self.members then
		for i,v in ipairs(self.members) do
			v:Destroy()
		end
		self.members = nil
	end

	if self.inviteList then
		for i,v in ipairs(self.inviteList) do
			v:Destroy()
		end
		self.inviteList = nil
	end

	if self.listFamilyPlayer then
		for i,v in ipairs(self.listFamilyPlayer) do
			v:Destroy()
		end
		self.listFamilyPlayer = nil
	end

	if self.familyGo then
		for i,v in ipairs(self.familyGo) do
			v:Destroy()
		end
		self.familyGo = nil
	end

	GlobalDispatcher:RemoveEventListener(self.reloginHandler)
end