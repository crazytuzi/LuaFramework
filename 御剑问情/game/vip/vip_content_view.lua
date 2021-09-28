VipContentView = VipContentView or BaseClass(BaseRender)

function VipContentView:__init(instance)
	VipContentView.Instance = self
	self.vip_list = {}
	self.vip_desc_list = {}
	self:InitListView()
	self:ListenEvent("reward_click", BindTool.Bind(self.RewardClick,self))
	self:ListenEvent("week_reward_click", BindTool.Bind(self.WeekRewardClick,self))
	self:ListenEvent("pre_click", BindTool.Bind(self.OnPreClick,self))

	for i=1,10 do
	 	self["reward_vip_des"..i]   = self:FindVariable("reward_vip_des"..i)
	 	self["icon_is_show"..i]     = self:FindVariable("icon_is_show"..i)
	end
	self.reward_vip_text    = self:FindVariable("reward_vip_text")

	self.reward_vip_num 	= self:FindVariable("reward_vip_num")
	self.btn_text 			= self:FindVariable("btn_text")
	self.btn_text_gray 		= self:FindVariable("btn_text_gray")
	self.week_text_btn 		= self:FindVariable("week_text_btn")
	self.week_gift_max_num 	= self:FindVariable("week_gift_max_num")
	self.model_name 		= self:FindVariable("model_name")
	self.inset_1 			= self:FindVariable("inset_1")
	self.inset_2 			= self:FindVariable("inset_2")
	self.reward_btn 		= self:FindObj("reward_btn")
	self.week_gift_btn 		= self:FindObj("week_gift_btn")
	-- self.display 			= self:FindObj("display")
	self.libao_name         = self:FindVariable("libao_name")

	self.item_list = {}
	for i=1,8 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("item_"..i))
	end

	self.item_week_gift = ItemCell.New()
	self.item_week_gift:SetInstanceParent(self:FindObj("item_9"))
	-- self:InitModle()
	self.model_name:SetValue("")
	self.current_vip_id = VipData.Instance:GetVipInfo().vip_level
	-- 当前vip的index
	self.cur_index = self.current_vip_id
	self.last_select_cell = nil
end

function VipContentView:OnPreClick()
	VipView.Instance:OpenTeToggle()
end

function VipContentView:SetCurIndex(index)
	self.cur_index = index
end

function VipContentView:GetCurIndex()
	return self.cur_index
end

function VipContentView:__delete()
	if self.dis_modle ~= nil then
		self.dis_modle:DeleteMe()
		self.dis_modle = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.time_quest1 then
		GlobalTimerQuest:CancelQuest(self.time_quest1)
		self.time_quest1 = nil
	end

	if self.vip_list then
		for k,v in pairs(self.vip_list) do
			v:DeleteMe()
		end
	end
	self.vip_list = {}

	if self.item_week_gift then
		self.item_week_gift:DeleteMe()
		self.item_week_gift = nil
	end

	for _,v in pairs(self.item_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.item_list = {}
end

function VipContentView:SetVipRewardItemData(reward_vip_id)
	self.reward_vip_text:SetValue(reward_vip_id)
	self:SetRewardDes(reward_vip_id)

	local reward_list = VipData.Instance:GetRewardList(self.current_vip_id)
	local effect_cfg = Split(VipData.Instance:GetGiftEffectCfgById(reward_vip_id),",")


	for i=1,6 do
		self.item_list[i]:SetData({item_id = reward_list[i].item_id, num = reward_list[i].item_num})
		self.item_list[i].root_node.transform.parent.gameObject:SetActive(reward_list[i].item_id > 0)
		-- if i == 1 then
		-- 	--直接写死第一个
		-- 	self.item_list[i]:ShowSpecialEffect(true)
		-- 	local bunble, asset = ResPath.GetItemActivityEffect()
		-- 	self.item_list[i]:SetSpecialEffect(bunble, asset)
		-- end
		--礼物特效配置
		for k,v in pairs(effect_cfg) do
			if k==i and v=="1" then
               self.item_list[i]:ShowSpecialEffect(true)
		 	   local bunble, asset = ResPath.GetItemActivityEffect()
		 	   self.item_list[i]:SetSpecialEffect(bunble, asset)

			end
		end
	end
end

function VipContentView:SetVipWeekRewarditem(reward_vip_id)
	local vip_reward_cfg = VipData.Instance:GetVipRewardCfg()
	local week_gift_cfg = VipData.Instance:GetVipWeekGiftCfg()
	local week_gift_item_id = week_gift_cfg.week_reward_id
	local week_gift_num = vip_reward_cfg[reward_vip_id-1].week_reward_num
	local vip_week_gift_fetch_flag = VipData.Instance:GetVipInfo().vip_week_gift_resdiue_times
	local get_gift_num = week_gift_num - vip_week_gift_fetch_flag
	if self.current_vip_id == 0 then
		get_gift_num = 0
		self.week_gift_max_num:SetValue(string.format("%s",get_gift_num))
	else
		if VipData.Instance:GetVipWeekRewardNum() == 0 then
			self.week_gift_max_num:SetValue(string.format("<color=#ff0000>%s</color>/%s",VipData.Instance:GetVipWeekRewardNum(),VipData.Instance:GetVipInfo().vip_level))
		else
			self.week_gift_max_num:SetValue(string.format("%s/%s",VipData.Instance:GetVipWeekRewardNum(),VipData.Instance:GetVipInfo().vip_level))
		end
	end
	self.item_week_gift:SetData({item_id = week_gift_item_id, num = get_gift_num})
	if VipData.Instance:GetVipWeekRewardFetchFlag() then
		self.week_gift_btn.button.interactable = true
		self.week_gift_btn.grayscale.GrayScale = 0
	else
		self.week_gift_btn.button.interactable = false
		self.week_gift_btn.grayscale.GrayScale = 255
	end
end

function VipContentView:OpenCallBack()
	local reward_vip_id = self.current_vip_id
	if reward_vip_id == 0 then
		reward_vip_id = 1
	end
	self:SetVipWeekRewarditem(reward_vip_id)

	self.week_text_btn:SetValue(Language.Common.LingQuJiangLi)
end

function VipContentView:JumpToCurrentVip()
	self.time_quest = GlobalTimerQuest:AddDelayTimer(function()
		-- self.current_vip_id = VipData.Instance:GetVipInfo().vip_level
		self.current_vip_id = VipData.Instance:GetFirstCanFetchGiftVip() or VipData.Instance:GetVipInfo().vip_level
		local cur_id = VipData.Instance:GetOpenParam()
		if 0 ~= cur_id then
			self.current_vip_id = cur_id
		end

		if self.current_vip_id ~= 0 then
			self:BagJumpPage(self.current_vip_id - 1)
		else
			self:BagJumpPage(0)
		end
		self:OnFlushAllVipItem()
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end, 0.4)
end

--跳转到下一个可以领取奖励的vip等级
function VipContentView:JumpToCanGetGiftVip(vip_level)
	local vip_page = VipData.Instance:GetFirstCanFetchGiftVip(vip_level)
	if nil == vip_page then
		return
	end
	self:OnFlushAllVipItem()
	self:BagJumpPage(vip_page - 1)

	if self.time_quest1 then
		GlobalTimerQuest:CancelQuest(self.time_quest1)
		self.time_quest1 = nil
	end
	self.time_quest1 = GlobalTimerQuest:AddRunQuest(function()
		self:OnFlushVipItem(vip_page)
		GlobalTimerQuest:CancelQuest(self.time_quest1)
		self.time_quest1 = nil
	end, 0.1)
end

function VipContentView:InitModle()
	-- if self.dis_modle ~= nil then
	-- 	return
	-- end

	-- self.dis_modle = RoleModel.New()
	-- self.dis_modle:SetDisplay(self.display.ui3d_display)
end

function VipContentView:FlushRewardState()
	local reward_vip_id = self.current_vip_id
	if reward_vip_id == nil or reward_vip_id == 0 then
		reward_vip_id = 1
	end
	self:SetVipRewardItemData(reward_vip_id)

	local is_reward = VipData.Instance:GetVipRewardFlag(reward_vip_id)
	if is_reward then
		self.reward_btn.grayscale.GrayScale = 255
		self.reward_btn.button.interactable = false
		self.btn_text:SetValue(Language.Common.YiLingQu)
		self.btn_text_gray:SetValue(false)
	else
		self.reward_btn.grayscale.GrayScale = 0
		self.reward_btn.button.interactable = true
		self.btn_text:SetValue(Language.Common.LingQuJiangLi)
		self.btn_text_gray:SetValue(true)


	end
	local reward_vip_id = self.current_vip_id
	if reward_vip_id == 0 then
		reward_vip_id = 1
	end
	self:SetVipWeekRewarditem(reward_vip_id)
	--设置展示图和模型
	local vip_cfg 			= VipData.Instance:GetVipRewardCfg()

	local inset_name_1 		= vip_cfg[reward_vip_id-1].show_item4
	local bundle_1, asset_1 = ResPath.GetVipIcon(inset_name_1)
	self.inset_1:SetAsset(bundle_1, asset_1)

	local inset_name_2 		= vip_cfg[reward_vip_id-1].show_item5
	local bundle_2, asset_2 = ResPath.GetVipIcon(inset_name_2)
	self.inset_2:SetAsset(bundle_2, asset_2)

	local main_role 		= Scene.Instance:GetMainRole()
	local modle_bundle 		= vip_cfg[reward_vip_id-1].path
	local model_asset 		= vip_cfg[reward_vip_id-1].show_item6
	-- self.dis_modle:SetMainAsset(modle_bundle, tostring(model_asset))
	self:OnFlushAllVipItem()
end

function VipContentView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function VipContentView:GetNumberOfCells()
	return 15
end

function VipContentView:GetListView()
	return self.list_view
end

function VipContentView:RefreshCell(cell, cell_index)
	local vip_cell = self.vip_list[cell]
	if vip_cell == nil then
		vip_cell = VipItem.New(cell.gameObject, self)
		self.vip_list[cell] = vip_cell
		vip_cell:SetToggleGroup(self.list_view.toggle_group)
	end
	-- vip_cell:SetToggleActive(false)
	cell_index = cell_index + 1
	vip_cell:SetVipLevel(cell_index)
	vip_cell:SetIndex(cell_index)
end

function VipContentView:RechargeClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	VipCtrl.Instance:GetView():OnCloseBtnClick()
end

function VipContentView:BagJumpPage(page)
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:JumpToDataIndex(page)
	end
end

function VipContentView:RewardClick()
	if self.current_vip_id > 0 then
		VipCtrl.Instance:SendFetchVipLevelRewardReq(self.current_vip_id)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.VipLimitTips)
	end
	if VipData.Instance:GetVipInfo().vip_level >= self.current_vip_id then
		self:JumpToCanGetGiftVip(self.current_vip_id)
	end
end

function VipContentView:WeekRewardClick()
	local vip_week_gift_fetch_flag = VipData.Instance:GetVipInfo().vip_week_gift_resdiue_times
	VipCtrl.Instance:SendFetchVipWeekRewardReq()
	self.week_gift_btn.button.interactable = false
	self.week_text_btn:SetValue(Language.Common.YiLingQu)
	self.item_week_gift.number:SetValue(0)
end

function VipContentView:GetCurrentVipId()
	return self.current_vip_id
end

function VipContentView:SetCurrentVipId(current_vip_id)
	self.current_vip_id = current_vip_id
end

function VipContentView:OnFlushAllVipItem()
	for k,v in pairs(self.vip_list) do
		v:OnFlush()
	end
end

--刷新指定vip格子
function VipContentView:OnFlushVipItem(vip)
	self:SetCurrentVipId(vip)
	for k,v in pairs(self.vip_list) do
		v:OnFlushFistGiftVipCell(vip)
	end
end

function VipContentView:SetRewardText()
	self.reward_vip_text:SetValue(self.current_vip_id)
end

function VipContentView:SetRewardDes(index)
	local vip_des = VipData.Instance:GetVipCurDescList(index)
	if vip_des then
		for i=1,10 do
			self["reward_vip_des" .. i]:SetValue(vip_des["desc" ..i])
			if  vip_des["desc" ..i] == "" then
				self["icon_is_show" .. i]:SetValue(false)
			else
				self["icon_is_show" .. i]:SetValue(true)
			end
		end
	end

	self.reward_vip_num:SetValue(index)
end

function VipContentView:SetVipActive(is_active)
	self.root_node:SetActive(is_active)
end

function VipContentView:FlushSelectEffect(cell)
	if self.last_select_cell and self.last_select_cell ~= cell then
		self.last_select_cell:SetHighLight(false)
	end
	self.last_select_cell = cell
	if cell then
		cell:SetHighLight(true)
	end
end

----------------------------------------------------------------------------
VipItem = VipItem or BaseClass(BaseCell)

function VipItem:__init()
	self.vip_level = 0
	self.bg = self:FindObj("bg")
	-- self.hl = self:FindObj("hl")

	self.libao_name = self:FindVariable("libao_name")
	self.libao_icon = self:FindVariable("libao_icon")

	self.vip_icon = self:FindVariable("vip_icon")
	self.vip_hl = self:FindVariable("vip_hl")
	self.power_desc = self:FindVariable("power_desc")
	self.vip_level_text = self:FindVariable("vip_level_text")
	self.show_red_point = self:FindVariable("show_red_point")
	self.show_hl = self:FindVariable("Show_Hl")
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnValueChange,self))
	self:ListenEvent("Click", BindTool.Bind(self.OnVipClick,self))
end

function VipItem:SetVipLevel(vip_level)
	self.vip_level = vip_level
	self:OnFlush()
end

function VipItem:OnVipClick()
	if self.index == VipContentView.Instance:GetCurIndex() then
		return
	end

	VipContentView.Instance:SetCurIndex(self.index)
	VipContentView.Instance:SetCurrentVipId(self.vip_level)
	VipContentView.Instance:SetRewardText()
	VipContentView.Instance:FlushRewardState()
	VipContentView.Instance:FlushSelectEffect(self)
	self.root_node.toggle.isOn = true
end

function VipItem:SetRedPoint(is_show)
	self.show_red_point:SetValue(is_show)
end

function VipItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function VipItem:OnFlush()
	self:SetVipItemData()
	local current_vip_id = VipContentView.Instance:GetCurrentVipId()

	if current_vip_id == 0 then
		current_vip_id = 1
	end
	if current_vip_id == self.vip_level  then
		self.root_node.toggle.isOn = true
	else
		self.root_node.toggle.isOn = false
	end
	local reward_flag = VipData.Instance:GetVipRewardFlag(self.vip_level)
	if VipData.Instance:GetVipInfo().vip_level >= self.vip_level then
		self:SetRedPoint(not reward_flag)
	else
		self:SetRedPoint(false)
	end
end

function VipItem:OnFlushFistGiftVipCell(vip)
	self:SetVipItemData()
	if vip == 0 then
		vip = 1
	end

	if vip == self.vip_level  then
		self.root_node.toggle.isOn = true
	else
		self.root_node.toggle.isOn = false
	end
	local reward_flag = VipData.Instance:GetVipRewardFlag(self.vip_level)
	if VipData.Instance:GetVipInfo().vip_level >= self.vip_level then
		self:SetRedPoint(not reward_flag)
	else
		self:SetRedPoint(false)
	end

	VipContentView.Instance:SetRewardText()
	VipContentView.Instance:FlushRewardState()
end

function VipItem:SetVipItemData()
	local bundle, asset = ResPath.GetVipIcon("vip_bibao_bg")
	self.vip_icon:SetAsset(bundle, asset)
	self.vip_level_text:SetValue(self.vip_level .. "")

	self.power_desc:SetValue(VipData.Instance:GetVipPowerDesc(self.vip_level))

	local vip_item = VipData.Instance:GetVipInfoList(self.vip_level)
	local vip_cfg = ItemData.Instance:GetItemConfig(vip_item.reward_item.item_id)
	if vip_item and vip_cfg then
		self.libao_name:SetValue(vip_cfg.name)
	end

	local bundle2, asset2 = ResPath.GetVipIcon("vip_reward_" .. self.vip_level)
	self.libao_icon:SetAsset(bundle2, asset2)

	if VipContentView.Instance:GetCurrentVipId() == self.vip_level then
		VipContentView.Instance:FlushSelectEffect(self)
	else
		self:SetHighLight(false)
	end
end

function VipItem:OnValueChange(is_click)
	if is_click then
		if self.root_node.toggle.isOn == true then
			VipItem.Instance = self
		end
	end
end

function VipItem:SetToggleActive(is_on)
	self.root_node.toggle.isOn = is_on
end

function VipItem:SetHighLight(enabled)
	self.show_hl:SetValue(enabled)
end