FriendManagePanel = FriendManagePanel or class("FriendManagePanel",WindowPanel)
local FriendManagePanel = FriendManagePanel
local tableInsert = table.insert

function FriendManagePanel:ctor()
	self.abName = "mail"
	self.assetName = "FriendManagePanel"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.panel_type = 3								--窗体样式  1 1280*720  2 850*545
	self.show_sidebar = false		--是否显示侧边栏
	self.table_index = nil
	self.model = FriendModel:GetInstance()

	self.item_list = {}
end

function FriendManagePanel:dctor()
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
	end
	if self.event_id then
		self.model:RemoveListener(self.event_id)
		self.event_id = nil
	end
end

function FriendManagePanel:Open( )
	FriendManagePanel.super.Open(self)
end

function FriendManagePanel:LoadCallBack()
	self.nodes = {
		"friend_num","ScrollView/Viewport/Content","changebtn","threedays","sevendays",
	}
	self:GetChildren(self.nodes)
	self.friend_num = GetText(self.friend_num)
	self.threedays = GetToggle(self.threedays)
	self.sevendays = GetToggle(self.sevendays)

	self:SetTileTextImage("mail_image", "friend_manage_img_title")
	self:AddEvent()
	self:SetPanelSize(650, 450)
end

function FriendManagePanel:AddEvent()

	local function call_back()
		self:UpdateView()
	end
	self.event_id = self.model:AddListener(FriendEvent.DeleteFriends, call_back)
	
	local function call_back(target,x,y)
		local roles = self.model:GetManageRoles()
		local role_ids = {}
		for role_id, _ in pairs(roles) do
			tableInsert(role_ids, role_id)
		end
		if #role_ids > 0 then
			local function ok_fun()
				FriendController:GetInstance():RequestDeleteFriend(role_ids)
			end
			Dialog.ShowTwo(ConfigLanguage.Mail.TipsTitle, ConfigLanguage.Mail.DeleteFriendTips, nil, ok_fun)
		else
			Notify.ShowText("You didn't select friends")
		end
	end
	AddClickEvent(self.changebtn.gameObject,call_back)

	local function call_back()
		self:FilterSelect()
	end
	AddValueChange(self.threedays.gameObject, call_back)

	local function call_back()
		self:FilterSelect()
	end
	AddValueChange(self.sevendays.gameObject, call_back)
end

function FriendManagePanel:OpenCallBack()
	self:UpdateView()
end

function FriendManagePanel:UpdateView( )
    local frinds = self.model:GetFriendList()
	local num, total_num = self.model:GetOnlineNum(frinds)
	self.friend_num.text = string.format(ConfigLanguage.Common.TwoNum, num, total_num)
	local i = 1
	for _, friend in pairs(frinds) do
		local item = self.item_list[i] or FriendManageItem(self.Content)
		item:SetData(friend)
		self.item_list[i] = item
		i = i + 1
	end
	if #self.item_list > i-1 then
		for j = #self.item_list, i, -1 do
			self.item_list[j]:destroy()
			self.item_list[j] = nil
		end
	end
end

function FriendManagePanel:CloseCallBack(  )
	self.model.manage_roles = {}
end

function FriendManagePanel:FilterSelect()
	local days = 0
	if self.threedays.isOn then
		days = 3
	elseif self.sevendays.isOn then
		days = 7
	end

	self.model:Brocast(FriendEvent.FilterDays, days)
end
