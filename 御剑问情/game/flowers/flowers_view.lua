FlowersView = FlowersView or BaseClass(BaseView)

function FlowersView:__init()
	self.ui_config = {"uis/views/flowersview_prefab","Flowers"}
	self.full_screen = false
	self.play_audio = true
end

function FlowersView:OnFlush(param_t)
	for i=1,4 do
		local num = ItemData.Instance:GetItemNumInBagById(FLOWER_ID_LIST[i])
		if i == 1 then
			local free_time = FlowersData.Instance:GetFreeFlowerTime()
			local max_free = FlowersData.Instance:GetSendFlowerCfgFreeTime()
			if free_time and max_free then
				local had_num = num + (max_free - free_time)
				if had_num >= 1 then
					self.flower_amount_text_list[i]:SetValue(string.format("<color=#0000f1>%s</color>",had_num) .. " / " .. 1)
				else
					self.flower_amount_text_list[i]:SetValue(string.format("<color=#fe3030>%s</color>",had_num) .. " / " .. 1)
				end
				self.btn_text_list[i]:SetValue(free_time < max_free and Language.Common.FreeSend or Language.Common.ZengSong)
			end
		else
			self.btn_text_list[i]:SetValue(Language.Common.ZengSong)
			if num >=1 then
				self.flower_amount_text_list[i]:SetValue(string.format("<color=#0000f1>%s</color>",num) .. " / " .. 1)
			else
				self.flower_amount_text_list[i]:SetValue(string.format("<color=#fe3030>%s</color>",num) .. " / " .. 1)
			end
		end
	end
end

function FlowersView:LoadCallBack()
	self:ListenEvent("close_view", BindTool.Bind(self.CloseView,self))
	self:ListenEvent("chosen_friend", BindTool.Bind(self.ChosenFriend,self))

	self.head = self:FindVariable("friendName")
	self.flower = self:FindVariable("flowerName")
	self.flowerImage = self:FindVariable("flowerImage")
	self.cfg_count = self:FindVariable("cfg_count")
	self.default_icon = self:FindVariable("default_icon")
	self.cfg_count:SetValue(FlowersData.Instance:GetSendFlowerCfgFreeTime())
	self.flower_amount_text_list = {}
	self.btn_text_list = {}
	for i=1,4 do
		self.flower_amount_text_list[i] = self:FindVariable("flower_amount_text_" .. i)
		self.btn_text_list[i] = self:FindVariable("btn_text_" .. i)
		self:ListenEvent("send_click_" .. i, BindTool.Bind2(self.OnSendClick, self, i))
	end

	self.image_obj = self:FindObj("RoleImage")
	self.raw_image_obj = self:FindObj("RawImage")

	self.infotable = {}
	self.flower_nums = {}
	self.is_autochosen = true
end

function FlowersView:ReleaseCallBack()
	-- 清理变量和对象
	self.head = nil
	self.flower = nil
	self.flowerImage = nil
	self.image_obj = nil
	self.raw_image_obj = nil
	self.cfg_count = nil
	self.default_icon = nil
	for i=1,4 do
		self.flower_amount_text_list[i] = nil
		self.btn_text_list[i] = nil
	end
	self.flower_amount_text_list = {}
	self.btn_text_list = {}
end

function FlowersView:OpenCallBack()
	self:SetNotifyDataChangeCallBack()
	if FlowersData.Instance:GetFlowersInfo().target_uid ~= -1 then
		local name, id = FlowersData.Instance:GetFriendInfo()
		self.head:SetValue(name)
		self:SetFriend(name,id)
	else
		self.head:SetValue(Language.Flower.SelectObj)
		local bundle, asset = ResPath.GetRoleHeadSmall(1)
		self.image_obj.image:LoadSprite(bundle, asset)
		self.image_obj.gameObject:SetActive(true)
		self.raw_image_obj.gameObject:SetActive(false)
	end
	self:Flush()
end

--移除物品回调
function FlowersView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

-- 设置物品回调
function FlowersView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function FlowersView:ItemDataChangeCallback()
	self:Flush()
end

function FlowersView:CloseView()
	self.head:SetValue(Language.Flower.SelectObj)
	self.image_obj.gameObject:SetActive(false)
	self.raw_image_obj.gameObject:SetActive(false)
	self.infotable.friend_name = nil
	FlowersData.Instance:ClearFlowerId()
	self:Close()
end

function FlowersView:CloseCallBack()
	self:RemoveNotifyDataChangeCallBack()
end

function FlowersView:OnSendClick(i)
	if self.infotable.user_id and self.infotable.user_id ~= 0 then
		if i == 1 then
			local free_time = FlowersData.Instance:GetFreeFlowerTime()
			local max_free = FlowersData.Instance:GetSendFlowerCfgFreeTime()
			if free_time < max_free then
				FlowersCtrl.Instance:SendFlowersReq(0, FLOWER_ID_LIST[i], self.infotable.user_id, 0, 0)
				return
			end
		end
		local num = ItemData.Instance:GetItemNumInBagById(FLOWER_ID_LIST[i])
		if num > 0 then
			local grid_index = ItemData.Instance:GetItemIndex(FLOWER_ID_LIST[i])
			FlowersCtrl.Instance:SendFlowersReq(grid_index, FLOWER_ID_LIST[i], self.infotable.user_id, 0, 0)
		else
			local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[FLOWER_ID_LIST[i]]
			if item_cfg == nil then
				TipsCtrl.Instance:ShowSystemMsg(Language.Flower.HasNotFlowerTip)
				return
			else
				local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
					MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
				end
				TipsCtrl.Instance:ShowCommonBuyView(func, FLOWER_ID_LIST[i], nil, 1)
			end
		end
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Flower.NotSelectObj)
		return
	end
end

function FlowersView:ChosenFriend()
	local func = function(role_info)
		local name = role_info.gamename
		local id = role_info.user_id
		self.infotable.friend_name = name
		self.infotable.user_id = id
		self.head:SetValue(name)
		local info = ScoietyData.Instance:GetFriendInfoByName(name)
		local prof = info.prof
		local sex = info.sex
		local avatar_key_big = info.avatar_key_big
		local avatar_key_small = info.avatar_key_small

		AvatarManager.Instance:SetAvatarKey(id, avatar_key_big, avatar_key_small)
		local avatar_path_small = AvatarManager.Instance:GetAvatarKey(id)
		CommonDataManager.SetAvatar(id, self.raw_image_obj, self.image_obj, self.default_icon, sex, prof, true)
	end

	ScoietyCtrl.Instance:ShowFriendListView(func)
end

function FlowersView:SetFriend(name,id)
	self.infotable.friend_name = name
	self.infotable.user_id = id

	self.head:SetValue(name)

	local prof = FlowersData.Instance:GetRoleInfo().prof
	local sex = FlowersData.Instance:GetRoleInfo().sex
	local avatar_key_big = FlowersData.Instance:GetRoleInfo().avatar_key_big
	local avatar_key_small = FlowersData.Instance:GetRoleInfo().avatar_key_small

	AvatarManager.Instance:SetAvatarKey(id, avatar_key_big, avatar_key_small)
	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(id)
	CommonDataManager.SetAvatar(id, self.raw_image_obj, self.image_obj, self.default_icon, sex, prof, true)
end

function FlowersView:GetInfoTable()
	return self.infotable
end