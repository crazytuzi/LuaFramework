TeamInvitePanel = TeamInvitePanel or class("TeamInvitePanel",WindowPanel)
local TeamInvitePanel = TeamInvitePanel
local tableInsert = table.insert

function TeamInvitePanel:ctor()
	self.abName = "team"
	self.assetName = "TeamInvitePanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true

	self.item_list = {}
	self.height = 0
	self.panel_type = 3

	self.model = TeamModel:GetInstance()
end

function TeamInvitePanel:dctor()
end

function TeamInvitePanel:Open( )
	TeamInvitePanel.super.Open(self)
end

function TeamInvitePanel:LoadCallBack()
	self.nodes = {
		"role_scroll/Viewport/Content", "btn_invite", "btn_location", 
		"buttons/btn_guild","buttons/btn_friend","buttons/btn_nearby",
		"buttons/btn_guild/Label1","buttons/btn_friend/Label2","buttons/btn_nearby/Label3",
	}
	self:GetChildren(self.nodes)

	self.Label1 = GetText(self.Label1)
	self.Label2 = GetText(self.Label2)
	self.Label3 = GetText(self.Label3)
	self:AddEvent()
	self:SetPanelSize(642, 487)
	self:SetTileTextImage("team_image", "team_invite_f")
end

function TeamInvitePanel:AddEvent()

	local function call_back(target,x,y)
		local flag = false
		for i=1, #self.item_list do
			local item = self.item_list[i]
			local role_id = item:GetRoleId()
			if role_id ~= "" then
				TeamController:GetInstance():RequestInvite(role_id)
				flag = true
			end
		end
		if not flag then
			Notify.ShowText("Select the character you want to invite")
		end
	end
	AddClickEvent(self.btn_invite.gameObject,call_back)

	local function call_back(target, value)
		if value then
			local data = self:ShowLabel(1)
			self:UpdateList(data)
			SetColor(self.Label1, 121, 140, 185)
			SetColor(self.Label2, 255, 255, 255)
			SetColor(self.Label3, 255, 255, 255)
		end
	end
	AddValueChange(self.btn_guild.gameObject, call_back)

	local function call_back(target, value)
		if value then
			local data = self:ShowLabel(2)
			self:UpdateList(data)
			SetColor(self.Label2, 121, 140, 185)
			SetColor(self.Label1, 255, 255, 255)
			SetColor(self.Label3, 255, 255, 255)
		end
	end
	AddValueChange(self.btn_friend.gameObject, call_back)

	local function call_back(target, value)
		if value then
			local data = self:ShowLabel(3)
			self:UpdateList(data)
			SetColor(self.Label3, 121, 140, 185)
			SetColor(self.Label2, 255, 255, 255)
			SetColor(self.Label1, 255, 255, 255)
		end
	end
	AddValueChange(self.btn_nearby.gameObject, call_back)
end

function TeamInvitePanel:OpenCallBack()
	self:UpdateView()
end

function TeamInvitePanel:UpdateView( )
	local data = self:ShowLabel(1)
	self:UpdateList(data)
end

function TeamInvitePanel:CloseCallBack(  )

end


function TeamInvitePanel:ShowLabel(index)
	local data = {}
	local guild_members = FactionModel:GetInstance():GetMember()
	local main_role_id = RoleInfoModel:GetInstance():GetMainRoleId()
	if index == 1 then
		self.index = 1
		for i=1, #guild_members do
			local member = guild_members[i]
			local id = member.base.id
			if id ~= main_role_id and member.online then
				tableInsert(data, member.base)
			end
		end
		return data 
	end
	local friends = FriendModel:GetInstance():GetFriendList()
	if index == 2 then
		self.index = 2
		for _, friend in pairs(friends) do
			local id = friend.base.id
			if id ~= main_role_id and friend.is_online then
				tableInsert(data, friend.base)
			end
		end
		return data
	end
	local objects = SceneManager:GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_ROLE) or {}
	if index == 3 then
		self.index = 3
		for _, actor in pairs(objects) do
			local role = actor.object_info
			local id = role.uid
			if id ~= main_role_id then
				local item = {}
				item.id = id
				item.name = role.name
				item.power = role.power
				item.level = role.level
				item.gender = role.gender
				item.viplv  = role.viplv
				item.icon = role.icon
				tableInsert(data, item)
			end
		end
		return data
	end
	self.index = 1
	return data
end

function TeamInvitePanel:UpdateList(data)
	for _, item in pairs(self.item_list) do
		item:destroy()
	end
	self.item_list = {}
	for _, item in pairs(data) do
		local roleItem = TeamInviteItem(self.Content)
		roleItem:SetData(item)
		table.insert(self.item_list, roleItem)
	end
end