require("game/beauty/beauty_item")
BeautyUpgradeView = BeautyUpgradeView or BaseClass(BaseRender)

function BeautyUpgradeView:__init(instance)
	self.cur_index = 1
	self.is_grade_auto = false
	self.is_active_shenwu = false
	self.cur_show_red_render = -1
	self.show_level = false
end

function BeautyUpgradeView:__delete()
	if self.model_display then
		self.model_display:DeleteMe()
		self.model_display = nil
	end
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	if self.level_item_cell then
		self.level_item_cell:DeleteMe()
		self.level_item_cell = nil
	end
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	self:RemoveNotifyDataChangeCallBack()

	if self.quest then
		GlobalTimerQuest:CancelQuest(self.quest)
		self.quest = nil
	end
	if self.chuchang_quest then
		GlobalTimerQuest:CancelQuest(self.chuchang_quest)
		self.chuchang_quest = nil
	end
	if self.icon_cell_list then	
		for k,v in pairs(self.icon_cell_list) do
			v:DeleteMe()
		end
		self.icon_cell_list = {}
	end
	if self.skill_summary then
		self.skill_summary:DeleteMe()
		self.skill_summary = nil
	end

	self.cur_show_red_render = -1
	self.add_level_btn_str = nil
end

function BeautyUpgradeView:LoadCallBack(instance)
	self:ListenEvent("OnUpLevelBtn", BindTool.Bind(self.OnUpLevelHandle, self, 0))
	self:ListenEvent("OnAutoUpBtn", BindTool.Bind(self.OnAutoUpHandle, self))
	self:ListenEvent("OnHuanhuaBtn", BindTool.Bind(self.OnHuanhuaHandle, self))
	self:ListenEvent("OnSkillBtn", BindTool.Bind(self.OnSkillHandle, self))
	self:ListenEvent("OnShenWuBtn", BindTool.Bind(self.OnShenWuHandle, self))
	self:ListenEvent("OnChangeNameBtn", BindTool.Bind(self.OnChangeNameBtn, self))
	self:ListenEvent("OnBeautSkill", BindTool.Bind(self.OnBeautSkill, self))
	self:ListenEvent("OnBeautSkillInfoBg", BindTool.Bind(self.OnBeautSkillInfoBg, self))
	-- self:ListenEvent("OnAutoBuy", BindTool.Bind(self.OnAutoBuy, self))

	self.beauty_name = self:FindVariable("BeautyName")
	self.skill_name = self:FindVariable("SkillName")
	self.skill_time = self:FindVariable("SkillTime")
	self.skill_dose = self:FindVariable("SkillDose")
	self.show_up_btn = self:FindVariable("ShowUpBtn")
	self.dose = self:FindVariable("Dose")
	self.skill_icon = self:FindVariable("Image")
	self.gongji = self:FindVariable("Gongji")
	self.fangyu = self:FindVariable("Fangyu")
	self.shengming = self:FindVariable("Shengming")
	self.power = self:FindVariable("PowerValue")
	self.up_btn_gray = self:FindVariable("UpBtnGray")
	self.auto_up_btn_gray = self:FindVariable("AutoUpBtnGray")
	--self.battle_btn_gray = self:FindVariable("BattleBtnGray")
	self.show_skill_info = self:FindVariable("ShowSkillInfo")
	self.show_skill_info:SetValue(false)

	self.exp_radio = self:FindVariable("ExpRadio")
	self.proge_cur_value = self:FindVariable("ProgeCurValue")
	self.proge_next_value = self:FindVariable("ProgeNextValue")
	self.stuff_num = self:FindVariable("StuffNum")
	self.stuff_image = self:FindVariable("StuffImage")
	self.btn_text = self:FindVariable("BtnText")
	self.heti_attr = self:FindVariable("HeTiAttr")
	self.auto_uplevel_text = self:FindVariable("AutoUpLevelText")
	self.image_name = self:FindVariable("ImageName")
	self.level = self:FindVariable("Level")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

	self.display = self:FindObj("Display")
	self.auto_buy = self:FindObj("AutoBuy")

	--self.battle_btn_text = self:FindObj("BattleBtnText")

	self.show_shenwu_red = self:FindVariable("ShowShenwuRedPoint")
	self.show_up_btn_red = self:FindVariable("ShowUpBtnRed")

	self.icon_cell_list = {}
	self.list_data = BeautyData.Instance:GetBeautyInfo()
	if self.list_data[1] then
		self.is_active_shenwu = self.list_data[1].is_active_shenwu == 1
	end
	self.icon_list = self:FindObj("IconList")
	local list_view_delegate = self.icon_list.list_simple_delegate
	--生成数量
	list_view_delegate.NumberOfCellsDel = function()
		return #self.list_data or 0
	end
	--刷新函数
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshIconListView, self)


	self.up_btn_str = self:FindVariable("UpBtnStr")
	self.level_gong_ji = self:FindVariable("LevelGongji")
	self.level_fang_yu = self:FindVariable("LevelFangyu")
	self.level_max_hp = self:FindVariable("LevelMaxHp")
	self.level_consume = self:FindVariable("LevelConsume")
	self.level_cap = self:FindVariable("LevelCap")
	self.level_desc = self:FindVariable("LevelDesc")
	self.show_level_view = self:FindVariable("ShowLevelView")
	self.level_item_cell = ItemCell.New()
	self.level_item_cell:SetInstanceParent(self:FindObj("LevelItem"))
	self.level_btn_str = self:FindVariable("LevelBtnStr")
	self.is_max_level = self:FindVariable("IsMaxLevel")
	self.add_level_btn_str = self:FindVariable("AddLevelBtnStr")
	self.level_btn = self:FindObj("LevelBtn")
	self.show_level_red = self:FindVariable("ShowLevelRed")
	self.show_up_red = self:FindVariable("ShowUpRed")

	self:ListenEvent("OnChangeView", BindTool.Bind(self.OnChangeView, self))
	self:ListenEvent("OnAddLevel", BindTool.Bind(self.OnAddLevel, self))

	self:FlushModel()
	self:SetNotifyDataChangeCallBack()
end

function BeautyUpgradeView:OnChangeNameBtn()
	local callback = function (new_name)
		PlayerCtrl.Instance:SendRoleResetName(1, new_name)
	end
	TipsCtrl.Instance:ShowRename(callback, true, PlayerDataReNameItemId.ItemId)
end

function BeautyUpgradeView:OnAddLevel()
	if self.cur_index == nil then
		return
	end

	BeautyCtrl.Instance:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_CHANMIAN_UPGRADE, self.cur_index - 1, 0, 1)
end

function BeautyUpgradeView:OnBeautSkill()
	self.show_skill_info:SetValue(true)
end

function BeautyUpgradeView:OnBeautSkillInfoBg()
	self.show_skill_info:SetValue(false)
end

function BeautyUpgradeView:OnChangeView()
	self.show_level = not self.show_level
	if self.show_level_view ~= nil then
		self.show_level_view:SetValue(self.show_level)
	end

	self:Flush()
end

function BeautyUpgradeView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function BeautyUpgradeView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

-- 物品不足，购买成功后刷新物品数量
function BeautyUpgradeView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local info = BeautyData.Instance:GetBeautyInfo()[self.cur_index]
	local grade_cfg = BeautyData.Instance:GetBeautyUpgrade(self.cur_index - 1, info.grade > 0 and info.grade or 1)
	if item_id == grade_cfg.item_id then
		RemindManager.Instance:Fire(RemindName.BeautyUpgrade)
	end
end

-- 初始化模型处理函数
function BeautyUpgradeView:FlushModel()
	if nil == self.model_display then
		self.model_display = RoleModel.New("beauty_panel")
		self.model_display:SetDisplay(self.display.ui3d_display)
	end

	local beaut_info = BeautyData.Instance:GetBeautyActiveInfo(self.cur_index - 1)
	if self.model_display and beaut_info then
		local bundle, asset = ResPath.GetGoddessNotLModel(beaut_info.model)
		self.model_display:SetMainAsset(bundle, asset, function ()
			self.model_display:ShowAttachPoint(AttachPoint.Weapon, self.is_active_shenwu)
			self.model_display:ShowAttachPoint(AttachPoint.Weapon2, self.is_active_shenwu)
			self.model_display:SetLayer(4, 1.0)
			self.model_display:SetTrigger("chuchang", false)
		end)
		self.model_display:ResetRotation()
	end

	if self.quest then
		GlobalTimerQuest:CancelQuest(self.quest)
		self.quest = nil
	end
	self.quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ChangeTime, self), 15)
end

function BeautyUpgradeView:ChuchangChangeTime()
	if self.model_display then
		self.model_display:ShowAttachPoint(AttachPoint.BuffMiddle, false)
		self.model_display:ShowAttachPoint(AttachPoint.BuffMiddle, true)
	end
end

function BeautyUpgradeView:BeautyShenwuFlush()
	--local beaut_info = BeautyData.Instance:GetBeautyActive()[self.cur_index]
	BeautyData.Instance:SetBeautyIndex(self.cur_index)
	local beaut_info = BeautyData.Instance:GetBeautyActiveInfo(self.cur_index - 1)
	if self.model_display and beaut_info then
		self.model_display:ShowAttachPoint(AttachPoint.Weapon, self.is_active_shenwu)
		self.model_display:ShowAttachPoint(AttachPoint.Weapon2, self.is_active_shenwu)
	end
end

function BeautyUpgradeView:ChangeTime()
	local animator_list = {"attack1", "attack2"}
	local index = GameMath.Rand(1, 2)
	if self.model_display then
		self.model_display:SetTrigger(animator_list[index])
	end
end

function BeautyUpgradeView:RefreshIconListView(cell, data_index, cell_index)
	data_index = data_index + 1
	local icon_cell = self.icon_cell_list[cell]
	if icon_cell == nil then
		icon_cell = BeautyNameCell.New(cell.gameObject)
		icon_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		icon_cell:SetToggleGroup(self.icon_list.toggle_group, data_index == 1)
		self.icon_cell_list[cell] = icon_cell
	end
	--local beaut_info = BeautyData.Instance:GetBeautyActive()[data_index]
	local beaut_info = BeautyData.Instance:GetBeautyActiveInfo(data_index - 1)
	local data = self.list_data[data_index]
	data.name = ""
	if beaut_info ~= nil then
		data.name = beaut_info.name or ""
	end
	icon_cell:SetIndex(data_index)
	icon_cell:SetRedFlag(data_index - 1 == self.cur_show_red_render or BeautyData.Instance:GetIsCanAddLevel(data_index) or BeautyData.Instance:GetIsCanActiveShenWu(data_index, false))
	icon_cell:SetData(data)
end

function BeautyUpgradeView:OnClickItemCallBack(cell)
	if nil == cell or nil == cell.data or self.cur_index == cell.index then return end
	self.cur_index = cell.index
	self.is_grade_auto = false
	if nil ~= self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	self:FlushModel()
	--self:UpStateInfo()
	self:Flush("flush_right")
end

function BeautyUpgradeView:OnSummaryCallBack(item_seq)
	if nil == item_seq or self.cur_index == item_seq then return end
	self.cur_index = item_seq
	if self.icon_list.scroller.isActiveAndEnabled then
		self.icon_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
	for k,v in pairs(self.icon_cell_list) do
		v:SetToggleOn(self.cur_index)
	end
	self:FlushModel()
	--self:UpStateInfo()
	self:Flush("flush_right")
end

function BeautyUpgradeView:UpStateInfo()
	local info = BeautyData.Instance:GetBeautyInfo()[self.cur_index]
	local beaut_info = BeautyData.Instance:GetBeautyActiveInfo(self.cur_index - 1)
	local is_max_level = false
	if info and beaut_info then
		local max_grade_cfg = BeautyData.Instance:GetBeautyMaxLevelCfg(self.cur_index - 1)
		if max_grade_cfg then
			is_max_level = info.grade >= max_grade_cfg.grade
		end
		self:SetBeautyButtonEnabled(not self.is_grade_auto and not is_max_level)
		self.auto_up_btn_gray:SetValue(not is_max_level)
		self.show_up_btn:SetValue(info.is_active == 1)
		self.is_active_shenwu = info.is_active_shenwu == 1

		local grade_cfg = BeautyData.Instance:GetBeautyUpgrade(self.cur_index - 1, info.grade > 0 and info.grade or 0)
		if grade_cfg then
			--local beuty_cfg = BeautyData.Instance:GetBeautyActiveInfo(info.seq)
			local beauty_cap = CommonDataManager.GetCapabilityCalculation(beaut_info)

			self.gongji:SetValue(grade_cfg.gongji + beaut_info.gongji)
			self.fangyu:SetValue(grade_cfg.fangyu + beaut_info.fangyu)
			self.shengming:SetValue(grade_cfg.maxhp + beaut_info.maxhp)
			self.heti_attr:SetValue(BeautyData.Instance:GetHeTiAttr(self.cur_index - 1))
			local grade_power = CommonDataManager.GetCapabilityCalculation(grade_cfg)
			self.power:SetValue(grade_power + beauty_cap)

			self.proge_cur_value:SetValue(info.upgrade_val .. "/" .. grade_cfg.need_val)
			-- self.proge_next_value:SetValue(grade_cfg.need_val)
			self.exp_radio:SetValue(info.upgrade_val / grade_cfg.need_val)
			-- self.beauty_name:SetValue(string.format(Language.Beaut.UpgradeName, info.grade, beaut_info.name))
			local bundle, asset = ResPath.GetBeautyNameRes(self.cur_index)
			self.image_name:SetAsset(bundle, asset)
			--self.level:SetValue("LV." .. info.grade)

			self.item_cell:SetData({item_id = grade_cfg.item_id})
			local has_stuff = ItemData.Instance:GetItemNumInBagById(grade_cfg.item_id)
			self.stuff_num:SetValue(BeautyData:GetStuffNumStr(has_stuff, grade_cfg.item_num))
			local bundle, asset = ResPath.GetItemIcon(grade_cfg.item_id)
			self.stuff_image:SetAsset(bundle, asset)
			self.dose:SetValue(beaut_info.description)

			if TipsCommonBuyView.AUTO_LIST[grade_cfg.item_id] then
				self.auto_buy.toggle.isOn = true
			end
		end
		if is_max_level then
			self.proge_cur_value:SetValue(Language.Common.YiManJi)
			self.exp_radio:SetValue(1/1)
			self.stuff_num:SetValue("-/-")
		end
	end

	-- self.list_data = BeautyData.Instance:GetBeautyInfo()
	-- if self.icon_list.scroller.isActiveAndEnabled then
	-- 	self.icon_list.scroller:RefreshAndReloadActiveCellViews(true)
	-- end

	self:FlushRed()
end

function BeautyUpgradeView:FlushSkill()
	local cfg = BeautyData.Instance:GetBeautyActiveInfo(self.cur_index - 1)
	if cfg == nil or next(cfg) == nil then
		return
	end
	
	local skill_info = BeautyData.Instance:GetBeautySkill(cfg.active_skill_type)
	if skill_info then
		self.skill_name:SetValue(skill_info.name)
		local skill_param = skill_info.skill_type == 9 and skill_info.param3 or skill_info.param1
		local str = skill_info.is_show_cd == 1 and string.format(Language.Beaut.CoolingTime, skill_param) or Language.Beaut.NoCoolingTime
		self.skill_time:SetValue(str)
		self.skill_dose:SetValue(string.format(Language.Beaut.SkillDose, skill_info.desc))
		self.skill_icon:SetAsset(ResPath.GetItemIcon(skill_info.kill_icon))
	end

	if self.up_btn_str ~= nil then
		local str = self.show_level and Language.Beaut.UpgardeLabel or Language.Beaut.AddLevelLable
		self.up_btn_str:SetValue(str)
	end

	local all_info = BeautyData.Instance:GetBeautyInfo()
	if all_info == nil or next(all_info) == nil then
		return
	end

	local info = all_info[self.cur_index]
	if info == nil or next(info) == nil then
		return
	end

	if self.level then
		local value = self.show_level and info.level or info.grade
		self.level:SetValue("LV." .. value)
	end

		-- local battle_flag = info.is_active == 1 and BeautyData.Instance:GetCurBattleBeauty() ~= self.cur_index - 1
		-- self.battle_btn_gray:SetValue(battle_flag)
		-- if self.battle_btn_text ~= nil then
		-- 	self.battle_btn_text.grayscale.GrayScale = battle_flag and 0 or 255
		-- end
		-- self.btn_text:SetValue(battle_flag and Language.Beaut.BeautYichuzhan or Language.Beaut.BeautBattle)
end

function BeautyUpgradeView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "SkillSmmary" then
			self:OnSummaryCallBack(v.item_seq)
		elseif k == "flush_right" then
			if not self.show_level then
				self:UpStateInfo()
			else
				self:FlushLevelView()
			end

			self:FlushSkill()
		else
			if not self.show_level then
				self:UpStateInfo()
			else
				self:FlushLevelView()
			end

			self:FlushSkill()
			self:BeautyShenwuFlush()
		end
	end	
end

function BeautyUpgradeView:FlushLevelView()
	if self.cur_index == nil then
		return
	end

	local all_info = BeautyData.Instance:GetBeautyInfo()
	if all_info == nil or next(all_info) == nil then
		return
	end

	local info = all_info[self.cur_index]
	if info == nil or next(info) == nil then
		return
	end

	local beauty_cfg, max_level = BeautyData.Instance:GetChanMianLevelCfg(self.cur_index - 1, info.level)
	if beauty_cfg == nil or next(beauty_cfg) == nil then
		return
	end

	-- if self.up_btn_str ~= nil then
	-- 	local str = self.show_level and Language.Beaut.UpgardeLabel or Language.Beaut.AddLevelLable
	-- 	self.up_btn_str:SetValue(str)
	-- end

	if self.level_gong_ji ~= nil then
		self.level_gong_ji:SetValue(beauty_cfg.gongji)
	end

	if self.level_fang_yu ~= nil then
		self.level_fang_yu:SetValue(beauty_cfg.fangyu)
	end

	if self.level_max_hp ~= nil then
		self.level_max_hp:SetValue(beauty_cfg.maxhp)
	end

	local has_num = ItemData.Instance:GetItemNumInBagById(beauty_cfg.item_id) or 0
	if self.level_consume ~= nil then
		local color = has_num >= beauty_cfg.item_num and COLOR.GREEN or COLOR.RED
		self.level_consume:SetValue(ToColorStr(has_num .. "/" .. beauty_cfg.item_num, color))
	end

	local bundle, asset = ResPath.GetBeautyNameRes(self.cur_index)
	self.image_name:SetAsset(bundle, asset)

	local is_max = info.level >= max_level
	-- if self.show_level_red ~= nil then
	-- 	self.show_level_red:SetValue((has_num >= beauty_cfg.item_num) and not is_max)
	-- end

	if self.level_cap ~= nil then
		local attr = CommonDataManager.GetAttributteByClass(beauty_cfg)
		self.level_cap:SetValue(CommonDataManager.GetCapability(attr))
	end

	local beaut_info = BeautyData.Instance:GetBeautyActiveInfo(self.cur_index - 1)
	if self.level_desc ~= nil and beaut_info ~= nil then
		self.level_desc:SetValue(beaut_info.description or "")
	end

	if self.level_item_cell ~= nil then
		self.level_item_cell:SetData({item_id = beauty_cfg.item_id})
	end

	if self.level_btn_str ~= nil then
		local btn_str = is_max and Language.Common.YiManJi or Language.Common.UpGrade
		self.level_btn_str:SetValue(btn_str)
	end

	if self.is_max_level ~= nil then
		self.is_max_level:SetValue(not is_max)
	end

	self.add_level_btn_str:SetValue(is_max and Language.Common.YiManJi or Language.Common.UpGrade)

	if self.level_btn ~= nil then
		self.level_btn.button.interactable = not is_max
	end

	self:FlushRed()
end

function BeautyUpgradeView:OnUpLevelHandle(is_auto)
	local is_auto = is_auto or 0
	local pack_num = 1
	local info = BeautyData.Instance:GetBeautyInfo()[self.cur_index]
	local grade_cfg = BeautyData.Instance:GetBeautyUpgrade(self.cur_index - 1, info.grade)
	if grade_cfg then
		if ItemData.Instance:GetItemNumInBagById(grade_cfg.item_id) < grade_cfg.item_num and not self.auto_buy.toggle.isOn then
			self.is_grade_auto = false
		end
		self:SetBeautyButtonEnabled(not self.is_grade_auto)
		pack_num = self.is_grade_auto and grade_cfg.pack_num or 1
	end

	local is_auto_buy = self.auto_buy.toggle.isOn and 1 or 0
	BeautyCtrl.Instance:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_UPGRADE, self.cur_index - 1, is_auto_buy, pack_num)
end

function BeautyUpgradeView:OnAutoUpHandle()
	self.is_grade_auto = not self.is_grade_auto
	if self.is_grade_auto then
		self:AutoBeautyGradeUpOnce()
	end
end

function BeautyUpgradeView:SetIsGradeAuto(bool)
	if self.is_grade_auto then
		self.is_grade_auto = bool
	end
end

function BeautyUpgradeView:SetBeautyButtonEnabled(bool)
	if self.up_btn_gray and self.auto_up_btn_gray then
		self.up_btn_gray:SetValue(bool)
		self.auto_uplevel_text:SetValue(self.is_grade_auto and Language.Beaut.AutoStopText or Language.Beaut.AutoUplevelText)
	end
end

-- 自动进行进阶操作
function BeautyUpgradeView:AutoBeautyGradeUpOnce()
	if nil ~= self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	if self.is_grade_auto then
		self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnUpLevelHandle,self, 1), 0.1)
	end
end

function BeautyUpgradeView:OnHuanhuaHandle()
	ViewManager.Instance:Open(ViewName.BeautyHuanhua)
end

function BeautyUpgradeView:OnShenWuHandle()
	self.is_grade_auto = false
	if nil ~= self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	ViewManager.Instance:Open(ViewName.BeautyShenwu, nil, "beauty_upgrade", {seq = self.cur_index})
end

function BeautyUpgradeView:OnSkillHandle()
	BeautyCtrl.Instance:SkillSmmaryView()
end

function BeautyUpgradeView:FlushRed()
	if self.cur_index == nil then
		return
	end

	if self.show_shenwu_red ~= nil then
		self.show_shenwu_red:SetValue(BeautyData.Instance:GetIsCanActiveShenWu(self.cur_index, false))
	end

	if self.show_up_btn_red ~= nil then
		self.show_up_btn_red:SetValue(BeautyData.Instance:GetIsCanUpgrade(self.cur_index))
	end

	self.cur_show_red_render = BeautyData.Instance:GetUpgradeRedRender()
	if self.icon_list ~= nil then
		self.icon_list.scroller:ReloadData(0)
	end

	local all_info = BeautyData.Instance:GetBeautyInfo()
	if all_info == nil or next(all_info) == nil then
		return
	end

	local info = all_info[self.cur_index]
	if info == nil or next(info) == nil then
		return
	end

	local beauty_cfg, max_level = BeautyData.Instance:GetChanMianLevelCfg(self.cur_index - 1, info.level)
	if beauty_cfg == nil or next(beauty_cfg) == nil then
		return
	end

	--local is_max = info.level >= max_level
	--local has_num = ItemData.Instance:GetItemNumInBagById(beauty_cfg.item_id) or 0
	if self.show_level_red ~= nil then
		self.show_level_red:SetValue(BeautyData.Instance:GetIsCanAddLevel(self.cur_index))
	end

	if self.show_up_red ~= nil then
		if not self.show_level then
			self.show_up_red:SetValue(BeautyData.Instance:GetIsCanAddLevel(self.cur_index))
		else
			self.show_up_red:SetValue(BeautyData.Instance:GetIsCanUpgrade(self.cur_index))
		end
	end
end