MolongMibaoChapterView = MolongMibaoChapterView or BaseClass(BaseRender)
function MolongMibaoChapterView:__init()
	self.chapter_id = 0
	self.reward_rate = self:FindVariable("RewardRate")
	self.is_finish = self:FindVariable("IsFinish")
	self.cap = self:FindVariable("Cap")
	self.display = self:FindObj("Display")
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self:FindObj("RewardItem"))
	self.reward_item:IsDestoryActivityEffect(false)
	self.reward_item:SetActivityEffect()
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)
	self.cell_list = {}
	self:InitScroller()
	self:ChapterChange(1)
end

function MolongMibaoChapterView:__delete()
	if self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function MolongMibaoChapterView:InitScroller()
	self.data = MolongMibaoData.Instance:GetMibaoChapterDataList(self.chapter_id) or {}
	self.scroller = self:FindObj("ListView")
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  MolongMibaoChapterCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell.mother_view = self
		end
		local cell_data = self.data[data_index]
		-- cell_data.data_index = data_index
		target_cell:SetData(cell_data)
	end
end

function MolongMibaoChapterView:OpenCallBack()
	self:ChangeModel()
end

function MolongMibaoChapterView:ChapterChange(index)
	self.chapter_id = index - 1
	local finish_reward = MolongMibaoData.Instance:GetMibaoFinishChapterReward(self.chapter_id)
	self.reward_item:SetData(finish_reward)
	self:OnFlush()
end

function MolongMibaoChapterView:OnFlush()
	self.data = MolongMibaoData.Instance:GetMibaoChapterDataList(self.chapter_id) or {}
	local reward_count = 0
	for k,v in pairs(self.data) do
		if MolongMibaoData.Instance:GetMibaoChapterHasReward(v.chapter_id, v.reward_index) then
			reward_count = reward_count + 1
		end
	end
	self.reward_rate:SetValue(string.format("<color=#%s>%s</color>/<color=#00ff00>%s</color>", reward_count < #self.data and "ff0000" or "00ff00", reward_count, #self.data))
	self.is_finish:SetValue(reward_count >= #self.data)
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function MolongMibaoChapterView:ChangeModel()
	if self.model then
		local cap = 0
		for k,v in pairs(ConfigManager.Instance:GetAutoConfig("magicalprecious_auto").finish_chapter_reward_cfg) do
			local finish_reward = v.reward_item[0]
			local cfg = ItemData.Instance:GetItemConfig(finish_reward.item_id)
			if cfg == nil then
				return
			end
			local item_id = finish_reward.item_id
			local display_role = cfg.is_display_role
			cap = cap + self:GetFightPower(display_role, item_id)
			local game_vo = GameVoManager.Instance:GetMainRoleVo()
			local res_id = 0

			if display_role == DISPLAY_TYPE.MOUNT then
				for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
					if v.item_id == item_id then
						res_id = v.res_id
						break
					end
				end
				self.model:SetMountResid(res_id)
			elseif display_role == DISPLAY_TYPE.WING then
				for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
					if v.item_id == item_id then
						res_id = v.res_id
						break
					end
				end
				self.model:SetWingResid(res_id)
			elseif display_role == DISPLAY_TYPE.FASHION then
				for k, v in pairs(FashionData.Instance:GetFashionCfgs()) do
					if v.active_stuff_id == item_id then
						local weapon_res_id = 0
						local weapon2_res_id = 0
						if v.part_type == 1 then
							res_id = v["resouce"..game_vo.prof..game_vo.sex]
							self.model:SetRoleResid(res_id)
						else
							weapon_res_id = v["resouce"..game_vo.prof..game_vo.sex]
							local temp = Split(weapon_res_id, ",")
							weapon_res_id = temp[1]
							weapon2_res_id = temp[2]
							self.model:SetWeaponResid(weapon_res_id)
							if weapon2_res_id then
								self.model:SetWeapon2Resid(weapon2_res_id)
							end
						end
						break
					end
				end
			elseif display_role == DISPLAY_TYPE.HALO then
					for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
						if v.item_id == item_id then
							res_id = v.res_id
							break
						end
					end
					self.model:SetHaloResid(res_id)
			elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
				for k, v in pairs(FaZhenData.Instance:GetSpecialImagesCfg()) do
					if v.item_id == item_id then
						res_id = v.res_id
						break
					end
				end
				self.model:SetMountResid(res_id)
			end
		end
		self.cap:SetValue(cap)
	end
end

function MolongMibaoChapterView:GetFightPower(display_role, item_id)
	local fight_power = 0
	local cfg = {}

	if display_role == DISPLAY_TYPE.MOUNT then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = MountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = WingData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FASHION then
		for k, v in pairs(FashionData.Instance:GetFashionCfgs()) do
			if v.active_stuff_id == item_id then
				cfg = FashionData.Instance:GetFashionUpgradeCfg(v.index, v.part_type, false, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.HALO then
			for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					cfg = HaloData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
					break
				end
			end
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		-- for k, v in pairs(SpiritData.Instance:GetSpiritResourceCfg()) do
		-- 	if v.id == item_id then
		-- 	end
		-- end
	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		for k, v in pairs(FaZhenData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = FaZhenData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENGONG then
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENYI then
		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.XIAN_NV then
		local beauty_cfg = ConfigManager.Instance:GetAutoConfig("beautyconfig_auto")
		local beauty_huanhua_cfg = beauty_cfg.beauty_huanhua
		for k, v in pairs(beauty_huanhua_cfg) do
			if v.need_item == item_id then
				cfg = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(v.seq, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
			end
		end

	elseif display_role == DISPLAY_TYPE.BUBBLE then
		cfg = CoolChatData.Instance:GetBubbleCfgByItemId(item_id)
		fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
	end

	return fight_power
end

function MolongMibaoChapterView.GetFightCap(item_id, item_id2)
	local fight_power = 0
	local cfg = {}
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg == nil then
		return 0
	end
	local display_role = item_cfg.is_display_role

	if display_role == DISPLAY_TYPE.MOUNT then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = MountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = WingData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FASHION then
		local item_id2 = item_id2 or 0
		for k, v in pairs(FashionData.Instance:GetFashionCfgs()) do
			if v.active_stuff_id == item_id or (0 ~= item_id2 and v.active_stuff_id == item_id2) then
				cfg = FashionData.Instance:GetFashionUpgradeCfg(v.index, v.part_type, false, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg)) + fight_power
			end
		end
	elseif display_role == DISPLAY_TYPE.HALO then
			for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					cfg = HaloData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
					break
				end
			end
	elseif display_role == DISPLAY_TYPE.FOOTPRINT then
			for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					cfg = FootData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
					break
				end
			end
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		for k, v in pairs(SpiritData.Instance:GetSpiritHuanImageConfig()) do
			if v.item_id == item_id then
				cfg = SpiritData.Instance:GetSpiritHuanhuaCfgById(v.active_image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = FightMountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENGONG then
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENYI then
		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.XIAN_NV then
		local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
		for k, v in pairs(goddess_cfg.huanhua) do
			if v.active_item == item_id then
				cfg = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(v.id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
			end
		end
	elseif display_role == DISPLAY_TYPE.ZHIBAO then
		cfg = ZhiBaoData.Instance:FindZhiBaoHuanHuaByStuffID(item_id)
		fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))

	elseif display_role == DISPLAY_TYPE.BUBBLE then
		cfg = CoolChatData.Instance:GetBubbleCfgByItemId(item_id)
		fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
	end
	return fight_power
end


---------------------------------------------------------------
--滚动条格子

MolongMibaoChapterCell = MolongMibaoChapterCell or BaseClass(BaseCell)

function MolongMibaoChapterCell:__init()
	self.task_dec = self:FindVariable("Dec")
	self.reward_btn_enble = self:FindVariable("BtnEnble")
	self.reward_btn_txt = self:FindVariable("RewardBtnTxt")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.rate = self:FindVariable("Rate")
	self.reward_img = self:FindVariable("RewardImg")
	self.goto_text = self:FindVariable("GotoText")
	self.reward_list = {}
	for i = 1, 3 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
		self.reward_list[i]:IgnoreArrow(true)
	end
	self:ListenEvent("Reward",
		BindTool.Bind(self.ClickReward, self))
	self:ListenEvent("Goto",
		BindTool.Bind(self.ClickGoto, self))
end

function MolongMibaoChapterCell:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
end

function MolongMibaoChapterCell:ClickReward()
	if self.data == nil then return end
	MolongMibaoCtrl.SendFetchMagicalPreciousRewardReq(self.data.chapter_id,  self.data.reward_index)
end

function MolongMibaoChapterCell:ClickGoto()
	if self.data == nil then return end
	local client_cfg = MolongMibaoData.Instance:GetMibaoChapterClientCfg(self.data.chapter_id)
	if client_cfg then
		ViewManager.Instance:OpenByCfg(client_cfg.open_panel)
	end
end

function MolongMibaoChapterCell:OnFlush()
	self:OnFlushView()
	local tuijian_item = self:TuiJianItem()
	for k,v in pairs(self.reward_list) do
		v:SetData(tuijian_item[k])
		v.root_node:SetActive(tuijian_item[k] ~= nil)
	end
end

function MolongMibaoChapterCell:TuiJianItem()
	local tuijian_item = {}
	for k,v in pairs(self.data.tuijian_item) do
		local cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if cfg and (cfg.limit_prof == 5 or cfg.limit_prof == PlayerData.Instance.role_vo.prof) then
			table.insert(tuijian_item, v)
		end
	end
	return tuijian_item
end

function MolongMibaoChapterCell:OnFlushView()
	local has_reward = MolongMibaoData.Instance:GetMibaoChapterHasReward(self.data.chapter_id, self.data.reward_index)
	local cur_value, max_value = MolongMibaoData.Instance:GetMibaoChapterValue(self.data)
	local reward = 0
	if self.data.mojing_reward > 0 then
		reward = self.data.mojing_reward
		self.reward_img:SetAsset(ResPath.GetCurrencyIcon("shengwang"))
	else
		reward = self.data.bind_gold_reward
		self.reward_img:SetAsset(ResPath.GetCurrencyIcon("bind_diamond"))
	end

	self.task_dec:SetValue(MolongMibaoData.GetMibaoChapterDec(self.data) .. "<color=#00ff00ff>" .. CommonDataManager.ConverMoney(reward) .. "</color> ")
	local rate = string.format(" (<color=%s>%s</color>/<color=#B7D3F9FF>%s</color>)", cur_value < max_value and "#ff0000" or TEXT_COLOR.GRAY_WHITE, cur_value, max_value)
	self.rate:SetValue(rate)
	self.reward_btn_enble:SetValue(not has_reward)
	self.reward_btn_txt:SetValue(has_reward and Language.Common.YiLingQu or Language.Common.LingQu)
	self.show_red_point:SetValue(not has_reward and cur_value >= max_value)
	local client_cfg = MolongMibaoData.Instance:GetMibaoChapterClientCfg(self.data.chapter_id)
	if client_cfg then
		self.goto_text:SetValue(client_cfg.button_name)
	end
end