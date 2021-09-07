WeddingView = WeddingView or BaseClass(BaseView)

function WeddingView:__init()
	self.ui_config = {"uis/views/marriageview","WeddingView"}
	self:SetMaskBg()
	self.play_audio = true
	-- self.view_layer = UiLayer.Pop
end

function WeddingView:__delete()

end

function WeddingView:LoadCallBack()
	self.level_limit = self:FindVariable("LevelLimit")
	self.online_limit = self:FindVariable("OnlineLimit")
	self.intimacy_limit = self:FindVariable("IntimacyLimit")
	self.gold_limit = self:FindVariable("GoldLimit")

	self.level = self:FindVariable("Level")
	self.intimacy = self:FindVariable("Intimacy")

	local level = MarriageData.Instance:GetMarryLevelLimit()
	local intimacy = MarriageData.Instance:GetMarryIntimacyLimit()
	self.level:SetValue(level)
	self.intimacy:SetValue(intimacy)

	--头像相关
	self.my_image_res = self:FindVariable("MyImageRes")
	self.my_rawimage_res = self:FindVariable("MyRawImageRes")
	self.other_image_res = self:FindVariable("OtherImageRes")
	self.other_rawimage_res = self:FindVariable("OtherRawImageRes")
	self.my_image_state = self:FindVariable("MyImageState")				--是否显示自己的默认头像
	self.other_image_state = self:FindVariable("OtherImageState")		--是否显示别人的默认头像
	self.have_other_people = self:FindVariable("HaveOtherPeople")		--是否显示别人头像
	self.my_rawimage = self:FindObj("MyRawImage")
	self.other_rawimage = self:FindObj("OtherRawImage")

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
	self.my_rawimage_res = nil
	self.other_image_res = nil
	self.other_rawimage_res = nil
	self.my_image_state = nil
	self.other_image_state = nil
	self.have_other_people = nil
	self.my_rawimage = nil
	self.other_rawimage = nil
	self.wedding_item_list = nil
end

function WeddingView:OpenCallBack()
	self.select_wedding_index = 0			--选择的婚礼
	self.other_name = ""					--对方的名字

	--限制条件
	self.level_enough = false
	self.online_enough = false
	self.intimacy_enough = false
	self.gold_enough = false
	self.is_bind_gold = false			--是否使用绑定钻石

	self:SetMyHead()
	--先隐藏他人头像
	self.have_other_people:SetValue(false)
	self:Flush()

	--监听钻石变化
	PlayerData.Instance:ListenerAttrChange(self.role_attr_change)
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
	self.other_name = role_info.gamename
	self.have_other_people:SetValue(true)
	self:SetOtherHead(role_info)
	self:FlushLimit()
end

function WeddingView:OpenFriendList()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local sex = main_role_vo.sex == 1 and 0 or 1
	local camp = main_role_vo.camp
	local callback = BindTool.Bind(self.SelectFriendCallBack, self)
	ScoietyCtrl.Instance:ShowFriendListView(callback, sex, camp)
end

function WeddingView:ClickPropose()
	local other_name = self.other_name
	if other_name == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotOtherRoleDes)
		return
	end

	local marry_type = self.select_wedding_index - 1
	if marry_type < 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotSelectWeddingDes)
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
				MarriageCtrl.Instance:SendMarryReq(marry_type, other_vo.user_id)
			end
			TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
		return
	end

	local other_vo = ScoietyData.Instance:GetFriendInfoByName(other_name) or {}
	MarriageCtrl.Instance:SendMarryReq(marry_type, other_vo.user_id)
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
	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(role_id)
	if AvatarManager.Instance:isDefaultImg(role_id) == 0 or avatar_path_small == 0 then
		self.my_image_state:SetValue(true)
		local bundle, asset = AvatarManager.GetDefAvatar(prof, false, sex)
		self.my_image_res:SetAsset(bundle, asset)
	else
		local function callback(path)
			if IsNil(self.my_rawimage.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(role_id, false)
			end
			self.my_rawimage.raw_image:LoadSprite(path, function ()
				self.my_image_state:SetValue(false)
			end)
		end
		AvatarManager.Instance:GetAvatar(role_id, false, callback)
	end
end

--设置他人头像
function WeddingView:SetOtherHead(info)
	local role_id = info.user_id
	local prof = info.prof
	local sex = info.sex
	local avatar_key_small = info.avatar_key_small
	local avatar_key_big = info.avatar_key_big
	AvatarManager.Instance:SetAvatarKey(role_id, avatar_key_big, avatar_key_small)
	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(role_id)
	if AvatarManager.Instance:isDefaultImg(role_id) == 0 or avatar_path_small == 0 then
		self.other_image_state:SetValue(true)
		local bundle, asset = AvatarManager.GetDefAvatar(prof, false, sex)
		self.other_image_res:SetAsset(bundle, asset)
	else
		local function callback(path)
			if IsNil(self.other_rawimage.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(role_id, false)
			end
			self.other_rawimage.raw_image:LoadSprite(path, function ()
				self.other_image_state:SetValue(false)
			end)
		end
		AvatarManager.Instance:GetAvatar(role_id, false, callback)
	end
end

function WeddingView:FlushGoldLimit()
	if self.other_name ~= "" then
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
		self.level_enough = false
		self.online_enough = false
		self.intimacy_enough = false
		self.level_limit:SetValue(false)
		self.online_limit:SetValue(false)
		self.intimacy_limit:SetValue(false)
	end

	self:FlushGoldLimit()
end

function WeddingView:OnFlush()
	self:FlushLimit()

	local select_index = 1
	for i = 0, 2 do
		local cost_enough, is_bind_gold = MarriageData.Instance:CostEnoughByHunliType(i)
		if cost_enough then
			select_index = i + 1
		end
	end
	self.select_wedding_index = select_index

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

WeddingItemCell = WeddingItemCell or BaseClass(BaseCell)

function WeddingItemCell:__init()
	self.parent_view = nil

	self.cost = self:FindVariable("Cost")
	self.image_bg = self:FindVariable("ImageBg")						--背景图
	self.title_bg = self:FindVariable("TitleBg")						--婚礼标题
	self.have_title_reward = self:FindVariable("HaveTitleReward")		--是否有称号奖励
	self.gold_image = self:FindVariable("GoldImage")					--钻石图标
	self.zhan_li = self:FindVariable("zhanlibaozhang")				--战力暴涨

	self.title_image = self:FindVariable("TitleImage")
	self.have_item = self:FindVariable("HaveItem")
	self.show_discount = self:FindVariable("ShowDiscount")

	self.equip_item_obj = self:FindObj("ItemCell")
	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.equip_item_obj)
	self.equip_cell:SetData(nil)

	-- self.item_cell_obj = self:FindObj("ItemCell1")
	-- self.item_cell = ItemCell.New()
	-- self.item_cell:SetInstanceParent(self.item_cell_obj)
	-- self.item_cell:SetData(nil)

	self.item_cell_list = {}
	for i = 1, 3 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self:FindObj("ItemCell" .. i))
		self.item_cell_list[i]:SetActive(false) 
	end

	self:ListenEvent("Click",BindTool.Bind(self.Click, self))
end

function WeddingItemCell:__delete()
	self.parent_view = nil

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	for i=1,3 do
		self.item_cell_list[i]:DeleteMe()
		self.item_cell_list[i] = nil
	end

	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end
	self.equip_item_obj = nil
end

function WeddingItemCell:SetImage(variable, str)
	local res_str = str .. self.index
	local bundle, asset = ResPath.GetMarryImage(res_str)
	variable:SetAsset(bundle, asset)
end

function WeddingItemCell:SetGoldImage()
	if self.data.need_bind_gold > 0 then
		self.gold_image:SetAsset(ResPath.GetYuanBaoIcon(1))
	else
		self.gold_image:SetAsset(ResPath.GetYuanBaoIcon(0))
	end
end

function WeddingItemCell:SetCost()
	local hunli_cfg = MarriageData.Instance:GetHunliInfoByType(self.index - 1)
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cost = 0
	if self.data.need_bind_gold > 0 then
		cost = self.data.need_bind_gold
		cost = day < 8 and hunli_cfg.openserver_discount or cost 	-- 开服前七天有折扣
	else
		cost = self.data.need_gold
		cost = day < 8 and hunli_cfg.openserver_discount or cost
	end
	self.show_discount:SetValue(day < 8)

	local is_qixi_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QIXI_MARRIAGE)
	if is_qixi_open then
		if QiXiMarriageData:GetHunLiOtherCfg() and self.index == 3 then 
			local qixi_hunli_cfg = QiXiMarriageData:GetHunLiOtherCfg()[self.index]
			cost = qixi_hunli_cfg.marry_gold
		end
	end

	self.cost:SetValue(cost)
end


function WeddingItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	local select_index = self.parent_view:GetSelectWeddingIndex()
	if select_index == self.index then
		self.root_node.toggle.isOn = true
	else
		self.root_node.toggle.isOn = false
	end

	self:SetCost()

	self:SetImage(self.image_bg, "wedding_bg_")
	self:SetImage(self.title_bg, "wedding_title_")
	self:SetGoldImage()

	local reward_item = self.data.reward_item
	local item_data = {}

	--物品格子
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	self.zhan_li:SetValue(self.data.power_show)
	
	-- item_data = reward_item[0]
	-- if item_data and next(item_data) then
	-- 	self.item_cell_obj:SetActive(true)
	-- 	self.item_cell:SetData(item_data)
	-- else
	-- 	self.item_cell_obj:SetActive(false)
	-- end

	for i=1,3 do
		if reward_item[i - 1] then
			self.item_cell_list[i]:SetActive(true)
			self.item_cell_list[i]:SetData(reward_item[i - 1])
		else
			self.item_cell_list[i]:SetActive(false)
		end
	end

	--装备格子
	local is_equip = true
	local equip_data = {}
	if main_vo.last_marry_time <= 0 then
		local equip_reward_data = MarriageData.Instance:GetHunliEquipReward()
		equip_data.item_id = equip_reward_data.item_id
	end
	if equip_data and next(equip_data) then
		self.equip_item_obj:SetActive(true)
		self.equip_cell:SetData(equip_data, is_equip)
	else
		self.equip_item_obj:SetActive(false)
	end

	--显示称号
	if self.data.title_id > 0 then
		self.have_title_reward:SetValue(true)
		local bunble, asset = ResPath.GetTitleIcon(self.data.title_id)
		self.title_image:SetAsset(bunble, asset)
	else
		self.have_title_reward:SetValue(false)
	end

	if main_vo.last_marry_time > 0 and self.data.hunli_type == nil then
		self.have_item:SetValue(false)
	else
		self.have_item:SetValue(true)
	end
end

function WeddingItemCell:Click()
	self.root_node.toggle.isOn = true
	local select_index = self.parent_view:GetSelectWeddingIndex()
	if select_index == self.index then
		return
	end

	self.parent_view:SetSelectWeddingIndex(self.index)
	self.parent_view:FlushGoldLimit()
end