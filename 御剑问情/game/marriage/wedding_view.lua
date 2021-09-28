WeddingView = WeddingView or BaseClass(BaseView)

function WeddingView:__init()
	self.ui_config = {"uis/views/marriageview_prefab","WeddingView"}
	self.play_audio = true
	-- self.view_layer = UiLayer.Pop
end

function WeddingView:__delete()

end

function WeddingView:LoadCallBack()
	self.select_wedding_index = 0			--选择的婚礼

	self.level_limit = self:FindVariable("LevelLimit")
	self.online_limit = self:FindVariable("OnlineLimit")
	self.intimacy_limit = self:FindVariable("IntimacyLimit")
	self.gold_limit = self:FindVariable("GoldLimit")
	self.one_fight_power = self:FindVariable("one_fight_power")

	self.level = self:FindVariable("Level")
	self.intimacy = self:FindVariable("Intimacy")

	local level = MarriageData.Instance:GetMarryLevelLimit()
	local intimacy = MarriageData.Instance:GetMarryIntimacyLimit()
	self.level:SetValue(level)
	self.intimacy:SetValue(intimacy)

	--头像相关
	self.my_image_res = self:FindVariable("MyImageRes")
	-- self.my_rawimage_res = self:FindVariable("MyRawImageRes")
	self.other_image_res = self:FindVariable("OtherImageRes")
	self.other_name_var = self:FindVariable("OtherName")
	-- self.other_rawimage_res = self:FindVariable("OtherRawImageRes")
	self.my_image_state = self:FindVariable("MyImageState")				--是否显示自己的默认头像
	self.other_image_state = self:FindVariable("OtherImageState")		--是否显示别人的默认头像
	self.have_other_people = self:FindVariable("HaveOtherPeople")		--是否显示别人头像
	self.show_rawimg_text = self:FindVariable("ShowRawImgText")
	self.is_marriage = self:FindVariable("Is_Marriage")

	self.my_rawimage = self:FindObj("MyRawImage")
	self.other_rawimage = self:FindObj("OtherRawImage")
	self.lover_rawimage = self:FindObj("LoverRawImage")

	self.wedding_item_list = {}
	for i = 1, 3 do
		local wedding_item = WeddingItemCell.New(self:FindObj("WeddingItem" .. i))
		wedding_item:SetIndex(i)
		wedding_item.parent_view = self
		table.insert(self.wedding_item_list, wedding_item)
	end
	self:ListenEvent("OpenFriendList",BindTool.Bind(self.OpenFriendList, self))
	self:ListenEvent("ClickPropose",BindTool.Bind(self.ClickPropose, self))
	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("OpenHelp", BindTool.Bind(self.OpenHelp, self))

	self.role_attr_change = BindTool.Bind(self.RoleAttrChange, self)
end

function WeddingView:ReleaseCallBack()
	for k, v in ipairs(self.wedding_item_list) do
		v:DeleteMe()
	end
	self.wedding_item_list = {}

	-- 清理变量和对象
	self.level_limit = nil
	self.online_limit = nil
	self.intimacy_limit = nil
	self.gold_limit = nil
	self.level = nil
	self.intimacy = nil
	self.my_image_res = nil
	-- self.my_rawimage_res = nil
	self.other_image_res = nil
	self.other_name_var = nil
	-- self.other_rawimage_res = nil
	self.my_image_state = nil
	self.other_image_state = nil
	self.have_other_people = nil
	self.my_rawimage = nil
	self.other_rawimage = nil
	self.lover_rawimage = nil
	self.wedding_item_list = nil
	self.show_rawimg_text = nil
	self.one_fight_power = nil
	self.is_marriage = nil
end

function WeddingView:OpenCallBack()
	self.other_name = ""					--对方的名字
	self.other_name_var:SetValue(Language.Society.FriendListDes)

	--限制条件
	self.level_enough = false
	self.online_enough = false
	self.intimacy_enough = false
	self.gold_enough = false
	self.is_bind_gold = false			--是否使用绑定钻石
	self.lover_vo = nil

	self:SetMyHead()
	--先隐藏他人头像
	self.role_is_marriage = Scene.Instance:GetMainRole():IsMarriage()
	if self.role_is_marriage then
		self.is_marriage:SetValue(true)
		self.lover_vo = ScoietyData.Instance:GetFriendInfoById(GameVoManager.Instance:GetMainRoleVo().lover_uid)
		self:SetLoverHead(self.lover_vo)
	else
		self.have_other_people:SetValue(false)
	end
	self:Flush()

	--监听钻石变化
	PlayerData.Instance:ListenerAttrChange(self.role_attr_change)
	self:GetFifhtPower()

end

function WeddingView:CloseCallBack()
	if self.role_attr_change then
		PlayerData.Instance:UnlistenerAttrChange(self.role_attr_change)
	end
end

function WeddingView:RoleAttrChange(attr_name, value, old_value)
	if attr_name == "gold" or attr_name == "bind_gold" then
		self:FlushGoldLimit()
	end
end

function WeddingView:SelectFriendCallBack(role_info)
	self.other_name = role_info.gamename or ""
	self.other_name_var:SetValue(self.other_name)
	self.have_other_people:SetValue(true)
	self:SetOtherHead(role_info)
	self:FlushLimit()
end

function WeddingView:OpenFriendList()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local sex = main_role_vo.sex == 1 and 0 or 1
	local callback = BindTool.Bind(self.SelectFriendCallBack, self)
	ScoietyCtrl.Instance:ShowFriendListView(callback, sex)
end

function WeddingView:OpenHelp()
	local tips_id = 251
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function WeddingView:ClickPropose()
	local other_name = self.other_name
	if not self.role_is_marriage then
		if other_name == "" then
			--SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotOtherRoleDes)
			self:OpenFriendList()
			return
		end

		if not self.level_enough then
			local level = MarriageData.Instance:GetMarryLevelLimit()
			local des = string.format(Language.Marriage.LevelLimitDes, level)
			SysMsgCtrl.Instance:ErrorRemind(des)
			return
		end

		if not self.online_enough then
			SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.OnlineLimitDes)
			return
		end
	end

	local marry_type = self.select_wedding_index - 1
	if marry_type < 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotSelectWeddingDes)
		return
	end

	-- if not self.intimacy_enough then
	-- 	local intimacy = MarriageData.Instance:GetMarryIntimacyLimit()
	-- 	local des = string.format(Language.Marriage.IntimacyLimitDes, intimacy)
	-- 	SysMsgCtrl.Instance:ErrorRemind(des)
	-- 	return
	-- end
	if not self.gold_enough then
		if self.is_bind_gold then
			local main_vo = GameVoManager.Instance:GetMainRoleVo()
			-- SysMsgCtrl.Instance:ErrorRemind(Language.Common.BindGoldNotEnougth)
			local hunli_info = MarriageData.Instance:GetHunliInfoByType(marry_type)
			local cost = hunli_info.need_bind_gold
			local diff_gold = cost - main_vo.bind_gold
			local des = string.format(Language.Common.ToUseGold, diff_gold)

			local function ok_callback()
				if diff_gold > main_vo.gold then
					TipsCtrl.Instance:ShowLackDiamondView()
					return
				end
				local other_vo = ScoietyData.Instance:GetFriendInfoByName(other_name) or {}
				if self.role_is_marriage then
					MarriageCtrl.Instance:SendCSQingYuanBuyWeddingGiftBagReq(marry_type)
				else
					MarriageCtrl.Instance:SendMarryReq(marry_type, other_vo.user_id)
				end
			end
			TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
		return
	end

	local other_vo = ScoietyData.Instance:GetFriendInfoByName(other_name) or {}
	local hunli_info = MarriageData.Instance:GetHunliInfoByType(marry_type)
	local cost = hunli_info.need_gold
	local des = string.format(Language.Marriage.BuyMarryTypeDes, cost)
	local function ok_callback()
		if self.role_is_marriage then
			MarriageCtrl.Instance:SendCSQingYuanBuyWeddingGiftBagReq(marry_type)
		else
			MarriageCtrl.Instance:SendMarryReq(marry_type, other_vo.user_id)
		end
	end
	TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
end

function WeddingView:CloseWindow()
	self:Close()
end

--设置我的头像
function WeddingView:SetMyHead()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_id = main_role_vo.role_id
	local prof = main_role_vo.prof
	local sex = main_role_vo.sex

	CommonDataManager.NewSetAvatar(role_id, self.my_image_state, self.my_image_res, self.my_rawimage, sex, prof, false)

end

--设置他人头像
function WeddingView:SetOtherHead(info)
	local role_id = info.user_id
	local prof = info.prof
	local sex = info.sex

	CommonDataManager.NewSetAvatar(role_id, self.other_image_state, self.other_image_res, self.other_rawimage, sex, prof, false)

end

--设置伴侣头像
function WeddingView:SetLoverHead(info)
	local role_id = info.user_id
	local prof = info.prof
	local sex = info.sex

	CommonDataManager.NewSetAvatar(role_id, self.other_image_state, self.other_image_res, self.lover_rawimage, sex, prof, false)

end

function WeddingView:FlushGoldLimit()
	if self.other_name ~= "" or self.role_is_marriage then
		local cost_enough, is_bind_gold = MarriageData.Instance:CostEnoughByHunliType(self.select_wedding_index - 1)
		self.is_bind_gold = is_bind_gold
		if cost_enough then
			self.gold_enough = true
			self.gold_limit:SetValue(true)
		else
			self.gold_enough = false
			self.gold_limit:SetValue(false)
		end
	else
		self.gold_enough = false
		self.gold_limit:SetValue(false)
	end
end

function WeddingView:FlushLimit()
	if self.other_name ~= "" then
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		local other_vo = ScoietyData.Instance:GetFriendInfoByName(self.other_name) or {}
		local level = MarriageData.Instance:GetMarryLevelLimit()
		local intimacy = MarriageData.Instance:GetMarryIntimacyLimit()

		if main_vo.level >= level and other_vo.level >= level then
			self.level_enough = true
			self.level_limit:SetValue(true)
		else
			self.level_enough = false
			self.level_limit:SetValue(false)
		end

		if other_vo.is_online == 1 then
			self.online_enough = true
			self.online_limit:SetValue(true)
		else
			self.online_enough = false
			self.online_limit:SetValue(false)
		end

		if other_vo.intimacy >= intimacy then
			self.intimacy_enough = true
			self.intimacy_limit:SetValue(true)
		else
			self.intimacy_enough = false
			self.intimacy_limit:SetValue(false)
		end
	else
		if self.role_is_marriage then
			self.online_limit:SetValue(self.lover_vo.is_online == 1)
			self.level_limit:SetValue(true)
			self.intimacy_limit:SetValue(true)
		else
			self.level_enough = false
			self.online_enough = false
			self.intimacy_enough = false
			self.level_limit:SetValue(false)
			self.online_limit:SetValue(false)
			self.intimacy_limit:SetValue(false)
		end

	end

	self:FlushGoldLimit()
end

function WeddingView:OnFlush()
	self:FlushLimit()

	local hunli_data = MarriageData.Instance:GetHunLiData()
	for k, v in ipairs(self.wedding_item_list) do
		v:SetData(hunli_data[k])
	end
end

function WeddingView:SetSelectWeddingIndex(index)
	self.select_wedding_index = index
end

function WeddingView:GetSelectWeddingIndex()
	return self.select_wedding_index
end

function WeddingView:GetFifhtPower()
	local hunli_type = MARRIAGE_SELECT_TYPE.MARRIAGE_SELECT_TYPE_SWEET.index - 1
	local power = MarriageData.Instance:GetMarriageTipPower(hunli_type, WEDDING_TIPS_POWER_TYPE.RING)
	if nil ~= power then
		self.one_fight_power:SetValue(power)
	end
end

WeddingItemCell = WeddingItemCell or BaseClass(BaseCell)

function WeddingItemCell:__init()
	self.parent_view = nil

	self.cost = self:FindVariable("Cost")
	self.have_title_reward = self:FindVariable("HaveTitleReward")		--是否有称号奖励
	self.is_gold = self:FindVariable("IsGold")							--是否元宝

	self.title_res = self:FindVariable("TitleRes")
	self.has_get = self:FindVariable("HasGet")

	self.parent_item = self:FindObj("ItemCell1")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.parent_item)
	self.item_cell:SetData(nil)

	self.equip_item_obj = self:FindObj("ItemCell2")
	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.equip_item_obj)
	self.equip_cell:SetData(nil)

	self:ListenEvent("Click",BindTool.Bind(self.Click, self))
end

function WeddingItemCell:__delete()
	self.parent_view = nil

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end
end

function WeddingItemCell:SetImage(variable, str)
	local res_str = str .. self.index
	local bundle, asset = ResPath.GetMarryImageBg(res_str)
	variable:SetAsset(bundle, asset)
end

function WeddingItemCell:SetGoldImage()
	self.is_gold:SetValue(self.data.need_gold > 0)
end

function WeddingItemCell:SetCost()
	local cost = 0
	if self.data.need_bind_gold > 0 then
		cost = self.data.need_bind_gold
	else
		cost = self.data.need_gold
	end
	self.cost:SetValue(cost)
end

function WeddingItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	self:SetCost()

	self:SetGoldImage()

	-- 是否可以领取婚礼奖励
	local can_get_reward = MarriageData.Instance:IsCanGetHunliReward(self.index)
	self.has_get:SetValue(can_get_reward)
	local reward_item = self.data.reward_type
	--物品格子
	if nil ~= reward_item[0] then
		self.item_cell:SetParentActive(true)
		self.item_cell:SetData(reward_item[0])
	else
		self.item_cell:SetParentActive(false)
	end

	--装备格子
	if nil ~= reward_item[1] then
		self.equip_cell:SetParentActive(true)
		self.equip_cell:SetData(reward_item[1])
	else
		self.equip_cell:SetParentActive(false)
	end

	self.have_title_reward:SetValue(false)
	if self.data.title_id > 0 then
		local bunble, asset = ResPath.GetTitleModel(self.data.title_id .. "_H")
		self.title_res:SetAsset(bunble, asset)
		self.have_title_reward:SetValue(true)
	end

end

function WeddingItemCell:Click()
	self.root_node.toggle.isOn = true
	local select_index = self.parent_view:GetSelectWeddingIndex()
	if self.has_get:GetBoolean() then
		MarriageCtrl.Instance:OpenMarriageTipView(self.index)
	end
	if select_index == self.index then
		return
	end

	self.parent_view:SetSelectWeddingIndex(self.index)
	self.parent_view:FlushGoldLimit()
	self.parent_view.show_rawimg_text:SetValue(self.index ~= 1)
end