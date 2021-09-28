-- 主动邀请面板
ZDInvitePanel = BaseClass(LuaUI)
function ZDInvitePanel:__init()
	self.ui = UIPackage.CreateObject("Team","ZDInvitePanel")
	self.c1 = self.ui:GetController("c1")
	self.inviteConn = self.ui:GetChild("inviteConn")
	self.btnClose = self.ui:GetChild("btnClose")
	self.lbTab = {}
	for i = 1, 3 do
		self.lbTab[i] = self.ui:GetChild("lb" .. i)
	end

	self.model = ZDModel:GetInstance()
	if SHENHE then
		self.ui:GetChild("radio2").visible = false
	end
	self.items = {}
	self:InitEvent()
	self:AddEvent()
	--if self.c1.selectedIndex == 0  then
		--self:Update()
	--end
	
end
function ZDInvitePanel:InitEvent()
	FriendController:GetInstance():C_FriendList(1)
	self.btnClose.onClick:Add(function ()
		UIMgr.HidePopup()
	end)
	self.c1.onChanged:Add(function ()
		self:Update()
	end)

end

function ZDInvitePanel:AddEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.FriendListRefresh, function()
		self:Update()
	end)
end

function ZDInvitePanel:Update()
	local t = self.c1.selectedIndex
	for k, v in ipairs(self.lbTab) do
		if k == t + 1 then
			v.color = newColorByString("cccccc")
		else
			v.color = newColorByString("000000")
		end
	end
	for i,v in ipairs(self.items) do
		v:RemoveFromParent()
	end
	
	local tmp = {}
	local list = {}
	if t == 0 then
		tmp = FriendModel:GetInstance():GetFriendList()
		for _,v in pairs(tmp) do
			if not self.model:IsTeamMate(v.playerId) then
				local vo = {}
				vo.playerId = v.playerId or 0
				vo.playerName = v.playerName or ""
				vo.level = v.level or 0
				vo.career = v.career or 0
				vo.guildName = v.guildName or ""
				table.insert(list, InviteVo.New(vo))
			end
		end
	elseif t == 1 then
		tmp = FamilyModel:GetInstance():GetMember()
		for k,v in pairs(tmp) do
			if not self.model:IsTeamMate(v.playerId) then
				local vo = {}
				vo.playerId = v.playerId or 0
				vo.playerName = v.playerName or ""
				vo.level = v.level or 0
				vo.career = v.career or 0
				vo.guildName = v.guildName or ""
				table.insert(list, InviteVo.New(vo))
			end
		end                                                      
	elseif t == 2 then -- 附近
		tmp = SceneModel:GetInstance():GetPlayerList()
		for k,v in pairs(tmp) do
			if not self.model:IsTeamMate(v.playerId) then
				local vo = {}
				vo.playerId = v.playerId
				vo.playerName = v.name or ""
				vo.level = v.level or 0
				vo.career = v.career or 0
				vo.guildName = v.guildName or ""
				table.insert(list, InviteVo.New(vo))
			end
		end
	end
	
	local item = nil
	for i,v in pairs(list) do
		item = self.items[i]
		if item then
			item:Update(v)
		else
			item = ZDInviteItem.New(v)
		end
		item:SetXY(0, (i-1)*112)
		item:AddTo(self.inviteConn)
		self.items[i] = item
	end
end

function ZDInvitePanel:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	if self.items then
		for i,v in ipairs(self.items) do
			v:Destroy()
		end
	end
	self.items = nil
end