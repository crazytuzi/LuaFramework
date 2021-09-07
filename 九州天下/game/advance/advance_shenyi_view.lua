AdvanceShenyiView = AdvanceShenyiView or BaseClass(BaseRender)

function AdvanceShenyiView:__init(instance)
	self.is_can_auto = true
	self.is_auto = false
	self.jinjie_next_time = 0
	self.old_attrs = {}
	self.skill_fight_power = 0
	self.old_grade_bless_val = nil
	self.old_star_level  = nil
end

function AdvanceShenyiView:__delete()
	if self.shenyi_model ~= nil then
		self.shenyi_model:DeleteMe()
		self.shenyi_model = nil
	end
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.jinjie_next_time = nil
	self.is_auto = nil
	self.shenyi_skill_list = nil
	self.old_attrs = {}
	self.skill_fight_power = nil
	self.old_grade_bless_val = nil

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end
function AdvanceShenyiView:LoadCallBack()
	self:ListenEvent("StartAdvance", BindTool.Bind(self.OnStartAdvance, self))
	self:ListenEvent("AutomaticAdvance", BindTool.Bind(self.OnAutomaticAdvance, self))
	self:ListenEvent("OnClickUse", BindTool.Bind(self.OnClickUse, self))
	self:ListenEvent("OnClickZiZhi", BindTool.Bind(self.OnClickZiZhi, self))
	self:ListenEvent("OnClickHuanHua", BindTool.Bind(self.OnClickHuanHua, self))
	self:ListenEvent("OnClickLastButton", BindTool.Bind(self.OnClickLastButton, self))
	self:ListenEvent("OnClickNextButton", BindTool.Bind(self.OnClickNextButton, self))
	self:ListenEvent("OnClickCancelButton", BindTool.Bind(self.OnClickCancelButton, self))
	self:ListenEvent("OnPreviewClick", BindTool.Bind(self.OnPreviewClick, self))
	self:ListenEvent("OnClickEquipBtn",BindTool.Bind(self.OnClickEquipBtn, self))
	self:ListenEvent("OnClickSkill", BindTool.Bind(self.OnClickSkill, self))

	self.shenyi_name = self:FindVariable("Name")
	self.shenyi_rank = self:FindVariable("Rank")
	self.exp_radio = self:FindVariable("ExpRadio")
	self.sheng_ming = self:FindVariable("HPValue")
	self.fight_power = self:FindVariable("FightPower")
	self.gong_ji = self:FindVariable("GongJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.ming_zhong = self:FindVariable("MingZhong")
	self.shan_bi = self:FindVariable("ShanBi")
	self.bao_ji = self:FindVariable("BaoJi")
	self.jian_ren = self:FindVariable("JianRen")
	self.jia_shang = self:FindVariable("JiaShang")
	self.jian_shang = self:FindVariable("JianShang")
	-- self.quality = self:FindVariable("QualityBG")
	self.auto_btn_text = self:FindVariable("AutoButtonText")
	self.show_use_button = self:FindVariable("UseButton")
	self.show_use_image = self:FindVariable("UseImage")
	self.show_left_button = self:FindVariable("LeftButton")
	self.show_right_button = self:FindVariable("RightButton")
	self.cur_bless = self:FindVariable("CurBless")
	self.prop_name = self:FindVariable("PropName")
	self.need_num = self:FindVariable("NeedNun")
	self.remainder_num = self:FindVariable("RemainderNum")
	self.show_auto_buy = self:FindVariable("show_auto_buy")
	-- self.show_star = self:FindVariable("show_star")
	-- self.show_star:SetValue(ShenyiData.Instance:GetShenyiInfo().show_grade < ShenyiData.Instance:GetMaxGrade())
	self.show_cancel_btn = self:FindVariable("show_cancel_btn")
	self.show_zizhi_redpoint = self:FindVariable("ShowZizhiRedPoint")
	self.show_huanhua_redpoint = self:FindVariable("ShowHuanhuaRedPoint")
	self.show_equip_redpoint = self:FindVariable("ShowEquipRedPoint")
	self.show_skill_redpoint = self:FindVariable("ShowSkillRedPoint")
	self.upgrade_redpoint = self:FindVariable("UpGradeRedPoint")
	self.skill_arrow_list = {}
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_arrow_list[i] = self:FindVariable("ShowSkillUplevel" .. i)
	end
	-- self.item_icon = self:FindVariable("ItemIcon")
	self.grade_name_img = self:FindVariable("GradeName")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

	self.shenyi_model = RoleModel.New("advance_common_panel")
	self.shenyi_display = self:FindObj("ShenyiDisplay")
	self.auto_buy_toggle = self:FindObj("AutoToggle")
	self.auto_buy_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnAutoBuyToggleChange, self))
	self.start_button = self:FindObj("StartButton")
	self.up_grade_gray = self:FindVariable("UpGradeGray")
	self.auto_button = self:FindObj("AutoButton")
	self.auto_up_grade_gray = self:FindVariable("AutoUpGradeGray")
	self.gray_use_button = self:FindObj("GrayUseButton")
	self.preview_go = self:FindObj("preview_go")
	self.preview_text = self:FindVariable("preview_text")
	self.preview_text:SetValue(Language.Common.Look)
	self.show_preview = self:FindVariable("show_preview")
	self.skill_funopen = self:FindVariable("showskill_funopen")
	self.shenyi_skill_list = {}

	self.item_cells = {}
	self.item_cells = {
		ItemCell.New(self:FindObj("Item1")),
		ItemCell.New(self:FindObj("Item2")),
		ItemCell.New(self:FindObj("Item3"))
	}

	self.star_lists = {}
	for i = 1, 10 do
		self.star_lists[i] = self:FindVariable("Star"..i)
	end

	self:GetShenyiSkill()

end
function AdvanceShenyiView:OnClickSkill()
	AdvanceSkillCtrl.Instance:OpenView(ADVANCE_SKILL_TYPE.MANTLE)
end

-- 开始进阶
function AdvanceShenyiView:OnStartAdvance(from_auto)
	if nil == self.cur_select_prop_index then return end
	local is_auto_buy_toggle = self.auto_buy_toggle.toggle.isOn
	-- local prop_cfg = ShenyiData.Instance:GetShenyiUpStarPropCfg()
	-- local item_id = prop_cfg[self.cur_select_prop_index].up_star_item_id
	local shengyi_info = ShenyiData.Instance:GetShenyiInfo()
	if shengyi_info.grade == nil then return end
	local item_id = ShenyiData.Instance:GetShenyiGradeCfg(shengyi_info.grade).upgrade_stuff_id
	local num = ItemData.Instance:GetItemNumInBagById(item_id)

	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()

	if shenyi_info.show_grade >= ShenyiData.Instance:GetMaxGrade() and (shenyi_info.star_level % 10 == 0) then
		return
	end

	if num <= 0 and not is_auto_buy_toggle then
		-- 物品不足，弹出TIP框
		self.is_auto = false
		self.is_can_auto = true
		self:SetAutoButtonGray()
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(item_id)
			-- TipsCtrl.Instance:ShowSystemMsg(Language.Exchange.NotEnoughItem)
			return
		end

		-- if item_cfg.bind_gold == 0 then
		-- 	TipsCtrl.Instance:ShowShopView(item_id, 2)
		-- 	return
		-- end

		local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
			if is_buy_quick then
				self.auto_buy_toggle.toggle.isOn = true
				if from_auto then
					self:OnAutomaticAdvance()
				else
					self:OnStartAdvance()
				end
			end
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
		return
	end
	local is_auto_buy = self.auto_buy_toggle.toggle.isOn and 1 or 0

	-- if is_auto_buy == 1 then
	-- 	if not ShenyiData.Instance:GetIsRichMoneyUpLevel(item_id) then
	-- 		TipsCtrl.Instance:ShowLackDiamondView()
	-- 		return
	-- 	end
	-- end
	ShenyiCtrl.Instance:SendUpGradeReq(is_auto_buy, self.is_auto)
	self.jinjie_next_time = Status.NowTime + 0.1
end

function AdvanceShenyiView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	if self.cur_select_grade <= ShenyiData.Instance:GetMaxGrade() then
		if self.is_auto then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnStartAdvance, self), 0.1)
		end
	end
end

function AdvanceShenyiView:FlushView()
	-- self:OnFlush("shenyi")
	self:SetAutoButtonGray()
	self:FlushItemNameText()
	self:SetPropItemCellsData()
	self:OpenCallBack()
	self:SetModle(true)
end

function AdvanceShenyiView:ShenyiUpGradeResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self:SetAutoButtonGray()
	else
		self:AutoUpGradeOnce()
	end
end

function AdvanceShenyiView:OnClickCancelButton()
	ShenyiCtrl.SendUnUseShenyiImage(image_id)
	local shenyi_data = ShenyiData.Instance
	self.cur_select_grade = shenyi_data:GetShenyiInfo().show_grade
	local grade_cfg = shenyi_data:GetShenyiShowGradeCfg(self.cur_select_grade)
	if not grade_cfg then return end
	ShenyiCtrl.Instance:SendUseShenyiImage(grade_cfg.image_id)
end

function AdvanceShenyiView:OnPreviewClick(is_click)
	if is_click then
		local shenyi_data = ShenyiData.Instance
		local grade = shenyi_data:GetMaxGrade()
		local name_str = shenyi_data:GetColorName(grade)
		self.shenyi_name:SetValue(name_str)
		self:SetModle(true, grade)
		self:SwitchGradeAndName(grade, true)
		self.preview_text:SetValue(Language.Common.CancelLook)
		self.show_preview:SetValue(true)
	else
		local shenyi_data = ShenyiData.Instance
		self.cur_select_grade = shenyi_data:GetShenyiInfo().show_grade
		self.is_in_preview = true
		self.preview_text:SetValue(Language.Common.Look)
		local name_str = shenyi_data:GetColorName(self.cur_select_grade)
		self.shenyi_name:SetValue(name_str)
		self:SetModle(true, self.cur_select_grade)
		self:SetArrowState(self.cur_select_grade)
		self:SwitchGradeAndName(self.cur_select_grade, true)
		self.show_preview:SetValue(false)
	end
end

-- 点击进阶装备
function AdvanceShenyiView:OnClickEquipBtn()
	local is_active, activite_grade = ShenyiData.Instance:IsOpenEquip()
	if not is_active then
		local name = Language.Advance.PercentAttrNameList[ADVANCE_EQUIP_TYPE.MANTLE] or ""
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade)))
		return
	end
	ViewManager.Instance:Open(ViewName.AdvanceEquipView, TabIndex.shenyi_jinjie)
end


function AdvanceShenyiView:CancelTheQuest()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.time_quest_2 then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest_2 = nil
	end
	if self.upgrade_timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	self.is_auto = false
	self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
end

-- 自动进阶
function AdvanceShenyiView:OnAutomaticAdvance()
	if nil == self.cur_select_prop_index then return end

	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()

	if shenyi_info.show_grade == 0 then
		return
	end

	if not self.is_can_auto then
		return
	end

	local function ok_callback()
		if TipsCommonAutoView.AUTO_VIEW_STR_T["auto_shenyi_up"] and TipsCommonAutoView.AUTO_VIEW_STR_T["auto_shenyi_up"].is_auto_buy then
			self.auto_buy_toggle.toggle.isOn = true
		end
		self.is_auto = self.is_auto == false
		self.is_can_auto = false
		self:OnStartAdvance(true)
		self:SetAutoButtonGray()
	end

	local function canel_callback()
		self:SetAutoButtonGray()
	end

	if self.auto_buy_toggle.toggle.isOn then
		ok_callback()
	else
		TipsCtrl.Instance:ShowCommonAutoView("auto_shenyi_up", Language.Mount.AutoUpDes, ok_callback, canel_callback, true, nil, nil, nil, true)
	end
end

-- 使用当前坐骑
function AdvanceShenyiView:OnClickUse()
	if self.cur_select_grade == nil then
		return
	end
	local grade_cfg = ShenyiData.Instance:GetShenyiShowGradeCfg(self.cur_select_grade)
	if not grade_cfg then return end
	ShenyiCtrl.Instance:SendUseShenyiImage(grade_cfg.image_id)
end

--显示上一阶形象
function AdvanceShenyiView:OnClickLastButton()
	if not self.cur_select_grade or self.cur_select_grade <= 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade - 1
	self:SetArrowState(self.cur_select_grade)
	self:SwitchGradeAndName(self.cur_select_grade)

	if self.shenyi_display ~= nil then
		self.shenyi_display.ui3d_display:ResetRotation()
	end
end

--显示下一阶形象
function AdvanceShenyiView:OnClickNextButton()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	if not self.cur_select_grade or self.cur_select_grade > shenyi_info.show_grade or shenyi_info.show_grade == 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade + 1
	self:SetArrowState(self.cur_select_grade)
	self:SwitchGradeAndName(self.cur_select_grade)

	if self.shenyi_display ~= nil then
		self.shenyi_display.ui3d_display:ResetRotation()
	end
end

function AdvanceShenyiView:SwitchGradeAndName(index, no_flush_modle)
	if index == nil then return end
	local shenyi_grade_cfg = ShenyiData.Instance:GetShenyiShowGradeCfg(index)
	if shenyi_grade_cfg == nil then return end
	local image_cfg = ShenyiData.Instance:GetShenyiImageCfg(shenyi_grade_cfg.image_id)

	local bundle, asset = ResPath.GetAdvanceEquipIcon("mantle_name_" .. (image_cfg.title_res or 1))
	self.grade_name_img:SetAsset(bundle, asset)
	self.shenyi_rank:SetValue(shenyi_grade_cfg.gradename)
	if image_cfg then
		local color = (index / 3 + 1) >= 5 and 5 or math.floor(index / 3 + 1)
		local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..image_cfg.image_name.."</color>"
		self.shenyi_name:SetValue(name_str)

		local info = {}
		info.role_res_id = GoddessData.Instance:GetShowXiannvResId() or -1
		info.wing_res_id = -1
		if self.cur_select_grade == nil then
			self.cur_select_grade = ShenyiData.Instance:GetShenyiInfo().show_grade
		end
		info.wing_res_id = ShenyiData.Instance:GetShowShenyiRes(self.cur_select_grade)

		if not no_flush_modle then
			self:SetModle(true)
		end
	end
end

function AdvanceShenyiView:Set3DModel(cur_select_grade)
	local image_cfg = ShenyiData.Instance:GetShenyiImageCfg(cur_select_grade)
	if not image_cfg then return end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local info = {}

	self.shenyi_model:SetDisplay(self.shenyi_display.ui3d_display)
	local cfg = self.shenyi_model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MANTLE], image_cfg.res_id, DISPLAY_PANEL.FULL_PANEL)
	self.shenyi_model:SetTransform(cfg)
	local main_role = Scene.Instance:GetMainRole()
	self.shenyi_model:SetRoleResid(main_role:GetRoleResId())
	self.shenyi_model:SetMantleResid(image_cfg.res_id)

	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end

	self:CalToShowAnim(true)
end

function AdvanceShenyiView:CalToShowAnim(is_change_tab)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	local timer = GameEnum.GODDESS_ANIM_LONG_TIME
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 0 or is_change_tab == true then
			if is_change_tab then
				if timer <= 6 then
					self:PlayAnim(is_change_tab)
					is_change_tab = false
					timer = GameEnum.GODDESS_ANIM_LONG_TIME
					GlobalTimerQuest:CancelQuest(self.time_quest)
				end
			else
				self:PlayAnim(is_change_tab)
				is_change_tab = false
				timer = GameEnum.GODDESS_ANIM_LONG_TIME
				GlobalTimerQuest:CancelQuest(self.time_quest)
			end
		end
	end, 0)

end

function AdvanceShenyiView:PlayAnim(is_change_tab)
	local is_change_tab = is_change_tab
	if self.time_quest_2 then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest_2 = nil
	end
	local timer = GameEnum.GODDESS_ANIM_SHORT_TIME
	local count = 1
	self.time_quest_2 = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 0 or is_change_tab == true then
			if UIScene.role_model then
				local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
				if part then
					part:SetTrigger(GoddessData.Instance:GetShowTriggerName(count))
					count = count + 1
				end
				timer = GameEnum.GODDESS_ANIM_SHORT_TIME
				is_change_tab = false
				if count == 4 then
					GlobalTimerQuest:CancelQuest(self.time_quest_2)
					self.time_quest_2 = nil
					self:CalToShowAnim()
				end
			end
		end
	end, 0)
end

-- 资质
function AdvanceShenyiView:OnClickZiZhi()
	ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "shenyizizhi", {item_id = ShenyiDanId.ZiZhiDanId})
end

-- 成长
-- function AdvanceShenyiView:OnClickChengZhang()
-- 	ViewManager.Instance:Open(ViewName.TipChengZhang, nil,"shenyichengzhang", {item_id = ShenyiDanId.ChengZhangDanId})
-- end

-- 幻化
function AdvanceShenyiView:OnClickHuanHua()
	ViewManager.Instance:Open(ViewName.ShenyiHuanHua)
	ShenyiHuanHuaCtrl.Instance:FlushView("shenyihuanhua")
end

-- 点击坐骑技能
function AdvanceShenyiView:OnClickShenyiSkill(index)
	ViewManager.Instance:Open(ViewName.TipSkillUpgrade, nil, "shenyiskill", {index = index - 1})
end

function AdvanceShenyiView:GetShenyiSkill()
	for i = 1, 4 do
		local skill = self:FindObj("ShenyiSkill"..i)
		local icon = skill:FindObj("Image")
		local activite = skill:FindObj("ImgActivity")
		table.insert(self.shenyi_skill_list, {skill = skill, icon = icon, activite = activite})
	end
	for k, v in pairs(self.shenyi_skill_list) do
		local bundle, asset = ResPath.GetShenyiSkillIcon(k)
		v.icon.image:LoadSprite(bundle, asset)
		v.skill.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickShenyiSkill, self, k))
	end
end

function AdvanceShenyiView:FlushSkillIcon()
	local skill_id_list = ShenyiData.Instance:GetShenyiSkillId()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	if nil == skill_id_list then return end

	for k, v in pairs(self.shenyi_skill_list) do
		local skill_info = SkillData.Instance:GetSkillInfoById(skill_id_list[k].skill_id) or {}
		local skill_level = skill_info.level or 0
		local activity_info = false
		if v.icon.grayscale then
			v.icon.grayscale.GrayScale = skill_level > 0 and 0 or 255
		end
		-- if skill_level <= 0 and self.skill_arrow_list[k-1] then 					-- 没激活不显示
		-- 	self.skill_arrow_list[k-1]:SetValue(false)
		-- end
		if skill_level <= 0 and shenyi_info.show_grade >= 1 then
			activity_info = ShenyiData.Instance:GetShenyiSkillIsActvity(k - 1, shenyi_info.show_grade)
		end
		if v.activite then
			v.activite:SetActive(activity_info)
		end
	end
end

function AdvanceShenyiView:SetPropItemCellsData()
	-- local prop_cfg = ShenyiData.Instance:GetShenyiUpStarPropCfg()
	local shengyi_info = ShenyiData.Instance:GetShenyiInfo()
	if shengyi_info.grade == nil then return end
	local item_id = ShengongData.Instance:GetShengongGradeCfg(shengyi_info.grade).upgrade_stuff_id
	if item_id then
		-- for k, v in pairs(self.item_cells) do
		-- 	v:ListenClick(BindTool.Bind(self.OnSelectPropItem, self, v, k))
		-- 	if prop_cfg[k] then
		-- 		local data = {}
		-- 		data.item_id = prop_cfg[k].up_star_item_id
		-- 		data.num = ItemData.Instance:GetItemNumInBagById(prop_cfg[k].up_star_item_id)
		-- 		v:IsDestroyEffect(data.num <= 0)
		-- 		v:SetIconGrayScale(data.num <= 0)
		-- 		v:SetShowNumTxtLessNum(0)
		-- 		v:SetData(data)
		-- 		v:ShowQuality(data.num > 0)
		-- 	end
		-- end
		local data = {}
		data.item_id = item_id
		data.num = ItemData.Instance:GetItemNumInBagById(item_id)
		self.item_cells[1]:IsDestroyEffect(data.num <= 0)
		self.item_cells[1]:SetIconGrayScale(data.num <= 0)
		self.item_cells[1]:SetShowNumTxtLessNum(0)
		self.item_cells[1]:SetData(data)
		self.item_cells[1]:ShowQuality(data.num > 0)
		if self.cur_select_prop_index and (not self.item_cells[self.cur_select_prop_index]:GetData().num or
			(self.item_cells[self.cur_select_prop_index]:GetData().num and self.item_cells[self.cur_select_prop_index]:GetData().num <= 0))
		  and not self.is_auto then
			self.cur_select_prop_index = nil
		end

		for k, v in pairs(self.item_cells) do
			if v:GetData().num and v:GetData().num > 0 then
				if not self.cur_select_prop_index then
					self.cur_select_prop_index = k
				end
			elseif v:GetToggleIsOn() then
				if not self.cur_select_prop_index then
					self.cur_select_prop_index = k
				end
			end
		end
		self.cur_select_prop_index = self.cur_select_prop_index or 1
		if self.cur_select_prop_index then
			self.item_cells[self.cur_select_prop_index]:SetHighLight(true)
		end
		-- self:OnSelectPropItem(self.item_cells[self.cur_select_prop_index], self.cur_select_prop_index)
		self.show_auto_buy:SetValue(self.cur_select_prop_index == 1)
	end
	self:FlushItemNameText()
end

function AdvanceShenyiView:OnSelectPropItem(cell, index)
	self.cur_select_prop_index = index
	cell:SetHighLight(self.cur_select_prop_index == index)
	local prop_cfg = ShenyiData.Instance:GetShenyiUpStarPropCfg()
	local item_id = prop_cfg[index] and prop_cfg[index].up_star_item_id
	local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
	-- if item_cfg == nil then
	-- 	self.auto_buy_toggle.toggle.isOn = false
	-- end
	self.auto_buy_toggle.toggle.interactable = item_cfg ~= nil
	self.item_name_text:SetValue(ItemData.Instance:GetItemConfig(item_id).name)
	self.show_auto_buy:SetValue(self.cur_select_prop_index == 1)
end

function AdvanceShenyiView:FlushItemNameText()
	-- local prop_cfg = ShenyiData.Instance:GetShengongUpStarPropCfg()
	-- local item_id = prop_cfg[self.cur_select_prop_index] and prop_cfg[self.cur_select_prop_index].up_star_item_id
	-- self.item_name_text:SetValue(ItemData.Instance:GetItemConfig(item_id).name)
	local shengyi_info = ShenyiData.Instance:GetShenyiInfo()
	local item_id = ShenyiData.Instance:GetShenyiGradeCfg(shengyi_info.grade)
	if item_id == nil then return end
	self.need_num:SetValue("  " .. item_id.upgrade_stuff_count)

	local bag_num = string.format(Language.Mount.ShowGreenStr, ItemData.Instance:GetItemNumInBagById(item_id.upgrade_stuff_id))
	if ItemData.Instance:GetItemNumInBagById(item_id.upgrade_stuff_id) < item_id.upgrade_stuff_count then
		bag_num = string.format(Language.Mount.ShowRedStr, ItemData.Instance:GetItemNumInBagById(item_id.upgrade_stuff_id))
	end
	self.remainder_num:SetValue(bag_num)
	self.prop_name:SetValue(ItemData.Instance:GetItemConfig(item_id.upgrade_stuff_id).name)
	-- local item_cfg = ItemData.Instance:GetItemConfig(item_id.upgrade_stuff_id)
	-- self.item_icon:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
	self.item_cell:SetData({item_id=item_id.upgrade_stuff_id, num=0, is_bind=0})
end

-- 设置坐骑属性
function AdvanceShenyiView:SetShenyiAtrr()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	if shenyi_info == nil or shenyi_info.shenyi_level == nil then
		return
	end

	if shenyi_info.shenyi_level == 0 or shenyi_info.grade == 0 then
		local shenyi_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(1)
		return
	end

	local shenyi_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(shenyi_info.grade)
	if not shenyi_grade_cfg then return end
	local image_cfg = ShenyiData.Instance:GetShenyiImageCfg(shenyi_grade_cfg.image_id)
		
	if not self.temp_grade then
		if shenyi_grade_cfg.show_grade == 0 then
			self.cur_select_grade = shenyi_info.show_grade
		else
			
			self.cur_select_grade = shenyi_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and shenyi_info.show_grade
									or ShenyiData.Instance:GetShenyiGradeByUseImageId(shenyi_info.used_imageid)

		end
		self.cur_select_grade = self.cur_select_grade > 0 and self.cur_select_grade or 1
		
		self:SetAutoButtonGray()
		self:SetArrowState(self.cur_select_grade, true)
		self:SwitchGradeAndName(self.cur_select_grade, true)
		self.temp_grade = shenyi_info.show_grade
	else

		if self.temp_grade < shenyi_info.show_grade then

			-- 进阶成功提示
			TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordAdvenceSuccess"))

			local new_attr = ShenyiData.Instance:GetShenyiAttrSum(nil, true)
			local old_capability = CommonDataManager.GetCapability(self.old_attrs) + self.skill_fight_power
			local new_capability = CommonDataManager.GetCapability(new_attr) + self.skill_fight_power
			TipsCtrl.Instance:ShowAdvanceSucceView(image_cfg, new_attr, self.old_attrs, "shenyi_view", new_capability, old_capability)

			if shenyi_grade_cfg.show_grade == 0 then
				self.cur_select_grade = shenyi_info.show_grade
			else
				self.cur_select_grade = shenyi_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and shenyi_info.show_grade
										or ShenyiData.Instance:GetShenyiGradeByUseImageId(shenyi_info.used_imageid)
			end
			
			self.is_auto = false
			self:SetAutoButtonGray()
			self:SetArrowState(self.cur_select_grade, true)
			self:SwitchGradeAndName(shenyi_info.show_grade, true)
		end
		self.temp_grade = shenyi_info.show_grade
	end
	self:SetUseImageButtonState(self.cur_select_grade, true)
	if self.old_grade_bless_val == nil then 
		self.old_grade_bless_val = shenyi_info.grade_bless_val --初始化
	end
	if self.old_star_level == nil then
		self.old_star_level = shenyi_info.star_level % 10
	end
	if shenyi_info.show_grade >= ShenyiData.Instance:GetMaxGrade() and (shenyi_info.star_level % 10 == 0) then
		self.cur_bless:SetValue(Language.Common.YiMan)
		self.exp_radio:InitValue(1)
	else
		self.cur_bless:SetValue(shenyi_info.grade_bless_val.."/".. shenyi_grade_cfg.bless_val_limit)
		if shenyi_grade_cfg then
			self.exp_radio:SetValue(shenyi_info.grade_bless_val/shenyi_grade_cfg.bless_val_limit)
		end
		--升星提示
		if self.old_grade_bless_val ~= shenyi_info.grade_bless_val then
			if(shenyi_info.grade_bless_val-self.old_grade_bless_val >= 100)  then
				TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordUpStarBaoji"))
			end
			self.old_grade_bless_val = shenyi_info.grade_bless_val
		end
		if self.old_star_level ~= shenyi_info.star_level % 10 then
			--升星提示
			TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordUpStarSuccess"))
			self.old_star_level = shenyi_info.star_level % 10
		end
	end
	local skill_capability = 0
	for i = 0, 3 do
		if ShenyiData.Instance:GetShenyiSkillCfgById(i) then
			skill_capability = skill_capability + ShenyiData.Instance:GetShenyiSkillCfgById(i).capability
		end
	end
	self.skill_fight_power = skill_capability
	local attr = CommonDataManager.GetAttributteByClass(shenyi_grade_cfg)
	local capability = CommonDataManager.GetCapability(attr)
	self.old_attrs = attr
	self.fight_power:SetValue(capability)

	self.sheng_ming:SetValue(attr.max_hp)
	self.gong_ji:SetValue(attr.gong_ji)
	self.fang_yu:SetValue(attr.fang_yu)
	self.ming_zhong:SetValue(attr.hurt_reduce)
	self.shan_bi:SetValue(attr.shan_bi)
	self.bao_ji:SetValue(attr.bao_ji)
	self.jian_ren:SetValue(attr.jian_ren)

	if self.index then
		image_cfg = ShenyiData.Instance:GetShenyiImageCfg(self.index)
		self.shenyi_rank:SetValue(ShenyiData.Instance:GetShenyiShowGradeCfg(self.index).gradename)
		self.shenyi_name:SetValue(image_cfg.image_name or "")
		local bundle, asset = nil, nil
		if math.floor(self.index / 3 + 1) >= 5 then
			bundle, asset = ResPath.GetShenyiGradeQualityBG(5)
		else
			bundle, asset = ResPath.GetShenyiGradeQualityBG(math.floor(self.index / 3 + 1))
		end

		-- self.quality:SetAsset(bundle, asset)
	end

	self.jia_shang:SetValue(attr.per_pofang)
	self.jian_shang:SetValue(attr.per_mianshang)
	self.show_zizhi_redpoint:SetValue(ShenyiData.Instance:IsShowZizhiRedPoint())
	-- self.show_chengzhang_redpoint:SetValue(ShenyiData.Instance:IsShowChengzhangRedPoint())
	self.show_huanhua_redpoint:SetValue(next(ShenyiData.Instance:CanHuanhuaUpgrade()) ~= nil)
	local can_uplevel_skill_list = ShenyiData.Instance:CanSkillUpLevelList()
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_arrow_list[i]:SetValue(can_uplevel_skill_list[i] ~= nil)
	end

	self:FlushStars()
	-- self.show_star:SetValue(ShenyiData.Instance:GetShenyiInfo().show_grade < ShenyiData.Instance:GetMaxGrade())
end

function AdvanceShenyiView:SetArrowState(cur_select_grade, no_flush_modle)
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	local max_grade = ShenyiData.Instance:GetMaxGrade()
	local grade_cfg = ShenyiData.Instance:GetShenyiShowGradeCfg(cur_select_grade)
	if not shenyi_info or not shenyi_info.show_grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end
	self.show_right_button:SetValue(cur_select_grade < shenyi_info.show_grade + 1 and cur_select_grade < max_grade)
	self.show_left_button:SetValue(grade_cfg.image_id > 1 or (shenyi_info.show_grade  == 1 and cur_select_grade > shenyi_info.show_grade))
	self:SetUseImageButtonState(cur_select_grade, no_flush_modle)
end

function AdvanceShenyiView:SetUseImageButtonState(cur_select_grade, no_flush_modle)
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	local max_grade = ShenyiData.Instance:GetMaxGrade()
	local grade_cfg = ShenyiData.Instance:GetShenyiShowGradeCfg(cur_select_grade)

	if not shenyi_info or not shenyi_info.show_grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end
	local is_show_cancel_btn = ShenyiData.Instance:IsShowCancelHuanhuaBtn(cur_select_grade)
	self.show_use_button:SetValue(cur_select_grade <= shenyi_info.show_grade and grade_cfg.image_id ~= shenyi_info.used_imageid and not is_show_cancel_btn)
	self.show_use_image:SetValue(grade_cfg.image_id == shenyi_info.used_imageid)
	self.show_cancel_btn:SetValue(is_show_cancel_btn)
	self:SwitchGradeAndName(self.cur_select_grade, no_flush_modle)
end

-- 物品不足，购买成功后刷新物品数量
function AdvanceShenyiView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	if shenyi_info.show_grade == nil then
		return
	end
	self:SetPropItemCellsData()
end

-- 设置进阶按钮状态
function AdvanceShenyiView:SetAutoButtonGray()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	if shenyi_info.show_grade == nil then return end

	local max_grade = ShenyiData.Instance:GetMaxGrade()

	if not shenyi_info or not shenyi_info.show_grade or shenyi_info.show_grade <= 0
		or (shenyi_info.show_grade >= max_grade and (shenyi_info.star_level % 10 == 0)) then
		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
		self.start_button.button.interactable = false
		self.up_grade_gray:SetValue(false)
		self.auto_button.button.interactable = false
		self.auto_up_grade_gray:SetValue(false)
		return
	end
	if self.is_auto then
		self.auto_btn_text:SetValue(Language.Common.Stop)
		self.start_button.button.interactable = false
		self.up_grade_gray:SetValue(false)
		self.auto_button.button.interactable = true
		self.auto_up_grade_gray:SetValue(true)
		self.is_can_auto = true
	else
		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
		self.start_button.button.interactable = true
		self.up_grade_gray:SetValue(true)
		self.auto_button.button.interactable = true
		self.auto_up_grade_gray:SetValue(true)
	end
end

function AdvanceShenyiView:SetModle(is_show, grade, flush_flag)
	if is_show then
		if not ShenyiData.Instance:IsActiviteShenyi() then
			return
		end
		local goddess_data = GoddessData.Instance
		local info = {}
		info.role_res_id = goddess_data:GetShowXiannvResId()
		info.wing_res_id = -1
		if grade then
			self.cur_select_grade = grade
		else
			if self.cur_select_grade == nil or self.is_in_preview == true or flush_flag then
				self.is_in_preview = false
				self.cur_select_grade = ShenyiData.Instance:GetShenyiInfo().used_imageid
			end
		end
		local grade_cfg = ShenyiData.Instance:GetShenyiShowGradeCfg(self.cur_select_grade)
		if grade_cfg then
			info.wing_res_id = ShenyiData.Instance:GetShowShenyiRes(self.cur_select_grade)
			self:Set3DModel(self.cur_select_grade)
		end
	end
end

function AdvanceShenyiView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function AdvanceShenyiView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	self.temp_grade = nil
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function AdvanceShenyiView:FlushStars()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	if nil == shenyi_info or nil == shenyi_info.star_level then
		return
	end
	local index = shenyi_info.star_level

	for i = 1, 10 do
		self.star_lists[i]:SetValue(index == 0 or index >= i)
	end
end

function AdvanceShenyiView:OnAutoBuyToggleChange(isOn)
	if TipsCommonAutoView.AUTO_VIEW_STR_T["auto_shenyi_up"] then
		TipsCommonAutoView.AUTO_VIEW_STR_T["auto_shenyi_up"].is_auto_buy = isOn
	end
end

function AdvanceShenyiView:OpenCallBack()
	if TipsCommonAutoView.AUTO_VIEW_STR_T["auto_shenyi_up"] then
		self.auto_buy_toggle.toggle.isOn = TipsCommonAutoView.AUTO_VIEW_STR_T["auto_shenyi_up"].is_auto_buy
	end
end

function AdvanceShenyiView:CancelPreviewToggle()
	if self.preview_go.toggle.isOn then
		self.preview_go.toggle.isOn = false
	end
end

function AdvanceShenyiView:OnFlush(param_list)
	if not ShenyiData.Instance:IsActiviteShenyi() then
		return
	end

	if self.shenyi_display ~= nil then
		self.shenyi_display.ui3d_display:ResetRotation()
	end

	self:SetPropItemCellsData()
	self:SetShenyiAtrr()
	self:FlushSkillIcon()
	self.show_skill_redpoint:SetValue(AdvanceSkillData.Instance:ShowSkillRedPoint(ADVANCE_SKILL_TYPE.MANTLE))
	self.show_equip_redpoint:SetValue(AdvanceData.Instance:IsEquipRedPointShow(ADVANCE_SKILL_TYPE.MANTLE))
	self.upgrade_redpoint:SetValue(ShenyiData.Instance:CanJinjie())
	local bool = OpenFunData.Instance:CheckIsHide("advanceskill")
	self.skill_funopen:SetValue(bool)
end
