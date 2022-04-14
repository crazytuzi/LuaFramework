SendGiftPanel = SendGiftPanel or class("SendGiftPanel", WindowPanel)
local SendGiftPanel = SendGiftPanel
local tableInsert = table.insert

function SendGiftPanel:ctor()
	self.abName = "friendGift"
	self.assetName = "SendGiftPanel"
	self.layer = "UI"
	self.title = "title"
    self.panel_type = 7

	self.use_background = true
	self.change_scene_close = true
	self.is_hide_other_panel = true

	self.item_list = {}
	self.model = FriendModel:GetInstance()
end

function SendGiftPanel:dctor()
	if self.event_id then
		self.model:RemoveListener(self.event_id)
		self.event_id = nil
	end

	if self.event_id2 then
		self.model:RemoveListener(self.event_id2)
		self.event_id2 = nil
	end

	if self.event_id3 then
		self.model:RemoveListener(self.event_id3)
		self.event_id3 = nil
	end
end

function SendGiftPanel:Open( )
	WindowPanel.Open(self)
end

function SendGiftPanel:LoadCallBack()
	self.nodes = {
		"rolebg/name_bg/name","charming/charming_value","change_friend","friendly/friendly_value","closebtn",
		"right_content/ScrollView/Viewport/Content","right_content/friendly2/friendly_value2","right_content/flower/flower_value2",
		"right_content/sendbtn","role","friendly/icon","right_content/tipsbtn","rolebg/norole","change_friend/change_text",
		"role/Camera",
	}
	self:GetChildren(self.nodes)
	self.name = GetText(self.name)
	self.charming_value = GetText(self.charming_value)
	self.friendly_value2 = GetText(self.friendly_value2)
	self.flower_value2 = GetText(self.flower_value2)
	self.friendly_value = GetText(self.friendly_value)
	self.change_text = GetText(self.change_text)

	self.render_texture = CreateRenderTexture() 
	self.myspirite_com = self.role:GetComponent("RawImage")
	self.Camera_com = self.Camera:GetComponent("Camera")
	self.myspirite_com.texture = self.render_texture
	self.Camera_com.targetTexture = self.render_texture

	self:AddEvent()
end

function SendGiftPanel:DoSend(gold_id, need_gold)
	local bo = RoleInfoModel:GetInstance():CheckGold(need_gold, Constant.GoldIDMap[gold_id])
	if not bo then
		return
	end

	if self.data == nil then
		Notify.ShowText(ConfigLanguage.Mail.NotSelectFriend)
	else
		FriendController:GetInstance():RequestSendFlower(self.data.id, self.selected_item_id)
	end

	--FriendController:GetInstance():RequestSendFlower(self.data.id, self.selected_item_id)
end

function SendGiftPanel:AddEvent()
	local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.closebtn.gameObject,call_back)

	local function call_back(target,x,y)
		if self.selected_item_id then
			local num = BagController:GetInstance():GetItemListNum(self.selected_item_id)
			if num <= 0 then
				local flower = Config.db_flower[self.selected_item_id]
				local cost = String2Table(flower.cost)
				local gold_id = cost[1][1]
				local gold_num = tonumber(cost[1][2])
				local item = Config.db_item[gold_id]
				local message = string.format(ConfigLanguage.Mail.UseGold, gold_num, item.name)

				local function ok_fun(is_check)
					self:DoSend(gold_id, gold_num)
				end
				Dialog.ShowTwo(ConfigLanguage.Mail.TipsTitle, message, nil, ok_fun,nil,nil,nil,nil, ConfigLanguage.Mail.NoAlert, false, nil, self.__cname)
			else
				if self.data == nil then
					Notify.ShowText(ConfigLanguage.Mail.NotSelectFriend)
				else
					if self.data.id == RoleInfoModel:GetInstance():GetMainRoleId() then
						Notify.ShowText("You can't send flower to yourself")
					else
						FriendController:GetInstance():RequestSendFlower(self.data.id, self.selected_item_id)
					end
				end

			end
		else
			Notify.ShowText("You didn't select anything")
		end
	end
	AddClickEvent(self.sendbtn.gameObject,call_back)

	local function call_back(target,x,y)
		lua_panelMgr:GetPanelOrCreate(MyFriendPanel):Open()
	end
	AddClickEvent(self.change_friend.gameObject,call_back)

	local function call_back(target,x,y)
		local panel = lua_panelMgr:GetPanelOrCreate(FriendlyTipsPanel)
		panel:SetData(self.data.id)
		panel:Open()
	end
	AddClickEvent(self.icon.gameObject,call_back)

	local function call_back(target,x,y)
		ShowHelpTip(HelpConfig.Friend.sendgift)
	end
	AddClickEvent(self.tipsbtn.gameObject,call_back)

	local function call_back(item_id)
		self:UpdateItemValue(item_id)
	end
	self.event_id = self.model:AddListener(FriendEvent.SelectFlower, call_back)

	local function call_back(role)
		self.data = role
		self:ShowRole(role)
	end
	self.event_id2 = self.model:AddListener(FriendEvent.SelectFriend, call_back)

	local function call_back()
		self:UpdateFriendlyValue(self.data)
	end
	self.event_id3 = self.model:AddListener(FriendEvent.UpdateFrinds, call_back)
end

function SendGiftPanel:OpenCallBack()
	self:UpdateView()
	self:SetTitleImgPos(-307,274.9)
end

function SendGiftPanel:UpdateView( )
	self:ShowRole(self.data)
	self:ShowFlowers()
end

function SendGiftPanel:CloseCallBack(  )
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
	end
	self.item_list = nil
	if self.role_model then
		self.role_model:destroy()
	end
	self.role_model = nil
	if self.myspirite_com then
		self.myspirite_com.texture = nil
	end
	if self.Camera_com then
		self.Camera_com.targetTexture = nil
	end
	if self.render_texture then
		ReleseRenderTexture(self.render_texture)
		self.render_texture = nil
	end
end

--data:p_role_base
function SendGiftPanel:SetData(data)
	self.data = data
end

local function sort_flower(a, b)
	return a.id < b.id
end

function SendGiftPanel:ShowFlowers()
	local arr_flower = {}
	for _, flower in pairs(Config.db_flower) do
		tableInsert(arr_flower, flower)
	end
	table.sort(arr_flower, sort_flower)
	for i=1, #arr_flower do
		local flower = arr_flower[i]
		local item = self.item_list[i] or GiftItem(self.Content)
		item:SetData(flower.id)
		table.insert(self.item_list, item)
	end
	self.item_list[1]:Selecte()
end

function SendGiftPanel:ShowRole(role)
	if role then
		self.name.text = role.name
		local res_id = 11001
		if role.gender == 2 then
			res_id = 12001
		end
		if self.role_model then
			self.role_model:destroy()
		end
		local data = {}
		data.res_id = res_id
		self.role_model = UIRoleModel(self.role, handler(self,self.LoadModelCallBack), data)
		self:UpdateFriendlyValue(role)
		SetVisible(self.norole, false)
		self.change_text.text = "Gift another player"
	else
		self.name.text = ""
		self.charming_value.text = string.format(ConfigLanguage.Mail.CharmingValue, 0)
		SetVisible(self.friendly_value, false)
		SetVisible(self.norole, true)
		self.change_text.text = "Select a friend"
	end
end

function SendGiftPanel:UpdateFriendlyValue(role)
	local pfriend = FriendModel:GetInstance():GetPFriend(role.id)
	if pfriend then
		self.friendly_value.text = self:GetFriendValueName(pfriend.intimacy) .. string.format("（%d）", pfriend.intimacy)
	else
		self.friendly_value.text = self:GetFriendValueName(0) .. string.format("（%d）", 0)
	end
	self.charming_value.text = string.format(ConfigLanguage.Mail.CharmingValue, role.charm or 0)
end

function SendGiftPanel:LoadModelCallBack()
	SetLocalPosition(self.role_model.transform, -2000, -89, 538)
    local v3 = self.role_model.transform.localScale
    --SetLocalScale(self.role_model.transform, 280, 280, 280)
    SetLocalRotation(self.role_model.transform, 10, 165, -1.3)
end

function SendGiftPanel:UpdateItemValue(item_id)
	self.selected_item_id = item_id
	local flower = Config.db_flower[item_id]
	self.friendly_value2.text = string.format(ConfigLanguage.Mail.FriendValue, flower.intimacy)
	self.flower_value2.text = string.format(ConfigLanguage.Mail.FlowerValue, flower.charm or 0)
end

function SendGiftPanel:GetFriendValueName(intimacy)
    local name = ""
	for i=1, #Config.db_flower_honey do
		local intimacy_item = Config.db_flower_honey[i]
		if intimacy >= intimacy_item.honey then
			name = intimacy_item.name
		end
	end
	return name
end

