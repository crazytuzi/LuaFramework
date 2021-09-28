AdvanceCloakView = AdvanceCloakView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
function AdvanceCloakView:__init(instance)
	if instance == nil then
		return
	end

	self:ListenEvent("StartAdvance",
		BindTool.Bind(self.OnStartAdvance, self))
	self:ListenEvent("AutomaticAdvance",
		BindTool.Bind(self.OnAutomaticAdvance, self))
	self:ListenEvent("OnClickUse",
		BindTool.Bind(self.OnClickUse, self))
	self:ListenEvent("OnClickZiZhi",
		BindTool.Bind(self.OnClickZiZhi, self))
	self:ListenEvent("OnClickHuanHua",
		BindTool.Bind(self.OnClickHuanHua, self))
	self:ListenEvent("OnClickLastButton",
		BindTool.Bind(self.OnClickLastButton, self))
	self:ListenEvent("OnClickNextButton",
		BindTool.Bind(self.OnClickNextButton, self))
	self:ListenEvent("OnClickTopLook",
		BindTool.Bind(self.OnClickTopLook, self))
	self:ListenEvent("OnClickEquipBtn",
		BindTool.Bind(self.OnClickEquipBtn, self))
	self:ListenEvent("OnClickSendMsg",
		BindTool.Bind(self.OnClickSendMsg, self))

	self.cloak_name = self:FindVariable("Name")
	self.cloak_level = self:FindVariable("Level")
	self.cloak_rank = self:FindVariable("Rank")
	self.exp_radio = self:FindVariable("ExpRadio")
	self.fight_power = self:FindVariable("FightPower")

	self.maxhp_cur_value = self:FindVariable("maxhp_cur_value")
	self.maxhp_next_value = self:FindVariable("maxhp_next_value")
	self.gongji_cur_value = self:FindVariable("gongji_cur_value")
	self.gongji_next_value = self:FindVariable("gongji_next_value")
	self.fangyu_cur_value = self:FindVariable("fangyu_cur_value")
	self.fangyu_next_value = self:FindVariable("fangyu_next_value")

	self.quality = self:FindVariable("QualityBG")
	self.auto_btn_text = self:FindVariable("AutoButtonText")
	self.look_btn_text = self:FindVariable("LookBtnText")

	self.show_use_button = self:FindVariable("UseButton")
	self.show_use_image = self:FindVariable("UseImage")
	self.show_left_button = self:FindVariable("LeftButton")
	self.show_right_button = self:FindVariable("RightButton")
	self.show_effect = self:FindVariable("ShowEffect")
	self.hide_effect = self:FindVariable("HideEffect")
	self.show_on_look = self:FindVariable("IsOnLookState")
	self.show_equip_remind = self:FindVariable("ShowEquipRemind")
	self.show_stars = self:FindVariable("ShowStars")

	self.prop_name = self:FindVariable("PropName")
	self.cur_bless = self:FindVariable("CurBless")
	self.show_zizhi_redpoint = self:FindVariable("ShowZizhiRedPoint")

	self.show_huanhua_redpoint = self:FindVariable("ShowHuanhuaRedPoint")
	self.show_skill_arrow1 = self:FindVariable("ShowSkillUplevel1")
	self.show_skill_arrow2 = self:FindVariable("ShowSkillUplevel2")
	self.show_skill_arrow3 = self:FindVariable("ShowSkillUplevel3")

	self.show_next_attr = self:FindVariable("show_next_attr")
	self.next_img_active_level = self:FindVariable("next_img_active_level")
	self.next_img_active_name = self:FindVariable("next_img_active_name")
	self.is_show_next_str = self:FindVariable("is_show_next_str")
	self.button_text = self:FindVariable("button_text")
	self.button_is_max = self:FindVariable("button_is_max")
	self.show_plus = self:FindVariable("show_plus")

	self.start_button = self:FindObj("StartButton")
	self.auto_button = self:FindObj("AutoButton")
	--self.gray_use_button = self:FindObj("GrayUseButton")

	self.stars_list = {}
	local stars_obj = self:FindObj("Stars")
	for i = 1, 10 do
		self.stars_list[i] = stars_obj:FindObj("Star"..i)
	end

	self.skill_mask_list = {}
	for i=1,4 do
		self.skill_mask_list[i] = {
		skill_mask = self:FindVariable("skill_mask"..i)
	}
	end

	self.display = self:FindObj("display")
	self.model_view = RoleModel.New("advance_cloak_panel")
	self.model_view:SetDisplay(self.display.ui3d_display)

	self.item_index = 1
	self.toggle_group = self:FindObj("items").toggle_group
	self.item_cell_list = {}
	for i=1,3 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self:FindObj("item"..i))
		self.item_cell_list[i]:SetToggleGroup(self.toggle_group)
		local handler = function()
			self.item_index = i
			for i=1,3 do
				self.item_cell_list[i]:SetToggle(self.item_index == i)
			end
		end
		self.item_cell_list[i]:ListenClick(handler)
	end

	self.cloak_skill_list = {}

	self:GetCloakSkill()

	self.is_auto = false
	self.is_can_auto = true
	self.jinjie_next_time = 0
	self.old_attrs = {}
	self.skill_fight_power = 0
	self.fix_show_time = 10
	self.res_id = -1
	self.cur_select_img_index = -1
	self.temp_img_index = -1
	self.is_on_look = false
	self.prefab_preload_id = 0
	self.last_level = 0
	self.cloak_asset_id = 0
	self.is_fulsh_zhanli = true
end

function AdvanceCloakView:__delete()
	-- if self.cloak_model ~= nil then
	-- 	self.cloak_model:DeleteMe()
	-- 	self.cloak_model = nil
	-- end

	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end

	self.show_next_attr = nil

	self.toggle_group = nil
	for i=1,3 do
		self.item_cell_list[i]:DeleteMe()
	end

	self.cloak_skill_list = {}
	self.skill_mask_list = nil

	self.jinjie_next_time = nil
	self.is_auto = nil

	self.old_attrs = {}
	self.skill_fight_power = nil
	self.fix_show_time = nil
	self.res_id = nil
	self.last_level = nil
	self.is_fulsh_zhanli = nil
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
end

function AdvanceCloakView:CheckSelectItem()
	local index = CloakData.Instance:CheckSelectItem(self.item_index)
	self.item_index = index

	for i = 1, 3 do
		self.item_cell_list[i]:SetToggle(self.item_index == i)
	end
end

-- 开始进阶
function AdvanceCloakView:OnStartAdvance()
	local cloak_info = CloakData.Instance:GetCloakInfo()
	if not cloak_info or not next(cloak_info) then return end
	local level_cfg = CloakData.Instance:GetCloakLevelCfg(cloak_info.cloak_level)

	if cloak_info.cloak_level >= CloakData.Instance:GetMaxCloakLevel() then
		return
	end

	local stuff_item_id = CloakData.Instance:GetCloakUpLevelStuffCfg(self.item_index).up_level_item_id

	if ItemData.Instance:GetItemNumInBagById(stuff_item_id) <= 0 then
		self.is_auto = false
		self.is_can_auto = true
		self:SetAutoButtonGray()
		TipsCtrl.Instance:ShowItemGetWayView(stuff_item_id)
		return
	end

	local pack_num = level_cfg and level_cfg.pack_num or 1
	local next_time = level_cfg and level_cfg.next_time or 0.1

	CloakCtrl.Instance:SendCloakUpLevelReq(self.item_index, is_auto_buy, self.is_auto and pack_num or 1) -- , self.is_auto
	self.jinjie_next_time = Status.NowTime + next_time
end

function AdvanceCloakView:AutoUpLevelOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	local cloak_info = CloakData.Instance:GetCloakInfo()
	if not cloak_info or not next(cloak_info) then return end
	if cloak_info.cloak_level < CloakData.Instance:GetMaxCloakLevel() then
		if self.is_auto then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnStartAdvance,self), jinjie_next_time)
		end
	end
end

function AdvanceCloakView:CloakUpgradeResult(result)
	self.is_can_auto = true

	self:CheckSelectItem()

	local up_level_cfg = CloakData.Instance:GetCloakUpLevelStuffCfg(self.item_index)
	local num = ItemData.Instance:GetItemNumInBagById(up_level_cfg.up_level_item_id)

	if num <= 0 then
		self.is_auto = false
		self:SetAutoButtonGray()
	else
		self:AutoUpLevelOnce()
	end
end

-- 自动进阶
function AdvanceCloakView:OnAutomaticAdvance()
	local cloak_info = CloakData.Instance:GetCloakInfo()
	if cloak_info.cloak_level == 0 then
		return
	end

	if not self.is_can_auto then
		return
	end

	self.is_auto = self.is_auto == false
	self.is_can_auto = false
	self:OnStartAdvance()
	self:SetAutoButtonGray()
end

-- 顶级预览
function AdvanceCloakView:OnClickTopLook(is_click)
	local cloak_info = CloakData.Instance:GetCloakInfo()
	if not cloak_info or not next(cloak_info) then return end

	self.is_on_look = self.is_on_look == false

	self.show_on_look:SetValue(self.is_on_look)

	local btn_text = self.is_on_look and Language.Common.CancelLook or Language.Common.Look
	self.look_btn_text:SetValue(btn_text)

	local max_level = CloakData.Instance:GetMaxCloakLevel()
	local max_level_cfg = CloakData.Instance:GetCloakLevelCfg(max_level)
	local select_index = self.is_on_look and max_level_cfg.active_image or self.cur_select_img_index

	self:SwitchGradeAndName(select_index)
	self:OnFlush()

	if is_click then
		self.show_plus:SetValue(true)
		local CloakMaxAttrSum = CloakData.Instance:GetCloakMaxAttrSum()
		self.maxhp_cur_value:SetValue(CloakMaxAttrSum.max_hp)
	    self.gongji_cur_value:SetValue(CloakMaxAttrSum.gong_ji)
	    self.fangyu_cur_value:SetValue(CloakMaxAttrSum.fang_yu)

	    --顶级战力计算
		local skill_capability = 0
		for i = 0, 3 do
			if CloakData.Instance:GetCloakSkillCfgById(i) then
			skill_capability = skill_capability+CloakData.Instance:GetCloakSkillCfgById(i).capability
			end
		end
		self.skill_fight_power = skill_capability
		local attr = CloakData.Instance:GetCloakMaxAttrSum()
		self.old_attrs = attr
		local capability = CommonDataManager.GetCapabilityCalculation(attr)
		self.fight_power:SetValue(capability + skill_capability)

	    self.is_fulsh_zhanli = false

	else
		self.show_plus:SetValue(false)
		local CloakAttrSum = CloakData.Instance:GetCloakAttrSum()
		self.maxhp_cur_value:SetValue(CloakAttrSum.max_hp)
	    self.gongji_cur_value:SetValue(CloakAttrSum.gong_ji)
	    self.fangyu_cur_value:SetValue(CloakAttrSum.fang_yu)

	   	--顶级战力计算
		local skill_capability = 0
		for i = 0, 3 do
			if CloakData.Instance:GetCloakSkillCfgById(i) then
			skill_capability = skill_capability+CloakData.Instance:GetCloakSkillCfgById(i).capability
			end
		end
		self.skill_fight_power = skill_capability
		local attr = CloakData.Instance:GetCloakAttrSum()
		self.old_attrs = attr
		local capability = CommonDataManager.GetCapabilityCalculation(attr)
		self.fight_power:SetValue(capability + skill_capability)

	    self.is_fulsh_zhanli = true
	end
end

function AdvanceCloakView:OnClickSendMsg()
	local cloak_info = CloakData.Instance:GetCloakInfo()
	if not cloak_info or not next(cloak_info) then return end

	-- 发送冷却CD
	if not ChatData.Instance:GetChannelCdIsEnd(CHANNEL_TYPE.WORLD) then
		local time = ChatData.Instance:GetChannelCdEndTime(CHANNEL_TYPE.WORLD) - Status.NowTime
		time = math.ceil(time)
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Chat.SendFail, time))
		return
	end

	local cloak_grade = cloak_info.cloak_level
	local name = ""
	local color = TEXT_COLOR.WHITE
	local btn_color = 0
	if cloak_grade > 1000 then
		local image_list = CloakData.Instance:GetSpecialImageCfg(cloak_grade - 1000)
		if nil ~= image_list and nil ~= image_list.image_name then
			name = image_list.image_name
			local item_cfg = ItemData.Instance:GetItemConfig(image_list.item_id)
			if nil ~= item_cfg then
				color = SOUL_NAME_COLOR_CHAT[item_cfg.color]
				btn_color = item_cfg.color
			end
		end
	else
		local image_list = CloakData.Instance:GetCloakImageCfg()[cloak_info.used_imageid]
		if nil ~= image_list and nil ~= image_list.image_name then
			name = image_list.image_name
			local temp_grade = CloakData.Instance:GetCloakGradeByUseImageId(cloak_info.used_imageid)
			local temp_color = (temp_grade / 3 + 1) >= 5 and 5 or math.floor(temp_grade / 3 + 1)
			color = SOUL_NAME_COLOR_CHAT[temp_color]
			btn_color = temp_color
		end
	end
	if cloak_grade < 2 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Chat.SendCancel)
	else
		local game_vo = GameVoManager.Instance:GetMainRoleVo()
		local content = string.format(Language.Chat.AdvancePreviewLinkList[9], game_vo.role_id, name, color, btn_color, CHECK_TAB_TYPE.CLOAK)
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, content, CHAT_CONTENT_TYPE.TEXT)
		ChatData.Instance:SetChannelCdEndTime(CHANNEL_TYPE.WORLD)
		TipsCtrl.Instance:ShowSystemMsg(Language.Chat.SendSucc)
	end
end

function AdvanceCloakView:SwitchGradeAndName(index)
	if index == nil then return end
	local cut_index = index == 0 and 1 or index
	local cloak_info = CloakData.Instance:GetCloakInfo()
	if not cloak_info or not next(cloak_info) then return end
	local image_cfg = CloakData.Instance:GetImageListInfo(cut_index)

	local max_level = CloakData.Instance:GetMaxCloakLevel()
	local level = self.is_on_look and max_level or cloak_info.cloak_level
	self.cloak_level:SetValue(level)

	local color = math.floor((index - 1) / 2) + 1
	local name_str = image_cfg.image_name
	self.cloak_name:SetValue(name_str)

	if image_cfg and self.res_id ~= image_cfg.res_id then
		local call_back = function(model, obj)
			if obj then
				local cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.CLOAK], image_cfg.res_id, DISPLAY_PANEL.FULL_PANEL)
				if cfg then
					obj.transform.localPosition = cfg.position
					obj.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
					obj.transform.localScale = cfg.scale
				else
					obj.transform.localPosition = Vector3(0, 0, 0)
					obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
					obj.transform.localScale = Vector3(1, 1, 1)
				end
			end
		end

		UIScene:SetModelLoadCallBack(call_back)

		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)

		local bundle, asset = ResPath.GetPifengModel(image_cfg.res_id)
		self.cloak_bundle = bundle
		self.cloak_asset = asset
		self:Flush()
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local vo = GameVoManager.Instance:GetMainRoleVo()
				local info = {}
				info.cloak_info = {used_imageid = index}
				info.prof = PlayerData.Instance:GetRoleBaseProf()
				info.sex = vo.sex
				info.is_not_show_weapon = true
				info.shizhuang_part_list = {{use_index = 0}, {use_index = vo.appearance.fashion_body}}

				UIScene:SetRoleModelResInfo(info, 1, false, true)
			end)

		self.res_id = image_cfg.res_id
	end
end

-- 使用当前形象
function AdvanceCloakView:OnClickUse()
	if self.cur_select_img_index == nil then
		return
	end

	if nil == CloakData.Instance:GetImageListInfo(self.cur_select_img_index) then
		return
	end

	CloakCtrl.Instance:SendUseCloakImage(self.cur_select_img_index)
end

-- 资质
function AdvanceCloakView:OnClickZiZhi()
	ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "cloakzizhi", {item_id = CloakDanId.ZiZhiDanId})
end

-- 点击进阶装备
function AdvanceCloakView:OnClickEquipBtn()
	-- local is_active, activite_grade = CloakData.Instance:IsOpenEquip()
	-- if not is_active then
	-- 	local name = Language.Advance.PercentAttrNameList[TabIndex.cloak_jinjie] or ""
	-- 	TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade)))
	-- 	return
	-- end
	-- ViewManager.Instance:Open(ViewName.AdvanceEquipView, TabIndex.cloak_jinjie)
end

-- 幻化
function AdvanceCloakView:OnClickHuanHua()
	-- ViewManager.Instance:Open(ViewName.CloakHuanHua)
	-- CloakHuanHuaCtrl.Instance:FlushView("cloakhuanhua")
end

-- 点击披风技能
function AdvanceCloakView:OnClickCloakSkill(index)
	--ViewManager.Instance:Open(ViewName.TipSkillUpgrade, nil, "cloakskill", {index = index - 1})
	TipsCtrl.Instance:ShowTipSkillView(index - 1, "cloak")
end

function AdvanceCloakView:GetCloakSkill()
	for i = 1, 4 do
		local skill = self:FindObj("CloakSkill"..i)
		local icon = skill:FindObj("Image")
		table.insert(self.cloak_skill_list, {skill = skill, icon = icon})
	end
	for k, v in pairs(self.cloak_skill_list) do
		local bundle, asset = ResPath.GetCloakSkillIcon(k)
		v.icon.image:LoadSprite(bundle, asset)
		v.skill.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickCloakSkill, self, k))
	end
end

function AdvanceCloakView:FlushSkillIcon()
	for k, v in pairs(self.cloak_skill_list) do
		if v.icon.grayscale then
			local is_active = CloakData.Instance:GetSkillIsActive(k - 1)
			v.icon.grayscale.GrayScale = is_active and 0 or 255
		end
	end
	for k,v in pairs(self.skill_mask_list) do
		local is_active = CloakData.Instance:GetSkillIsActive(k - 1)
		v.skill_mask:SetValue(is_active)
	end
end

--显示上一形象
function AdvanceCloakView:OnClickLastButton()
	if not self.cur_select_img_index or self.cur_select_img_index < 0 then
		return
	end
	self.cur_select_img_index = self.cur_select_img_index - 1
	self:SetArrowState(self.cur_select_img_index)
	self:SwitchGradeAndName(self.cur_select_img_index)
	self:OnFlush()
end

--显示下一形象
function AdvanceCloakView:OnClickNextButton()
	local cloak_info = CloakData.Instance:GetCloakInfo()
	if not cloak_info or not next(cloak_info) then return end
	local level_cfg = CloakData.Instance:GetCloakLevelCfg(cloak_info.cloak_level)
	local max_level = CloakData.Instance:GetMaxCloakLevel()
	local max_level_cfg = CloakData.Instance:GetCloakLevelCfg(max_level)

	if self.cur_select_img_index >= max_level_cfg.active_image or self.cur_select_img_index > level_cfg.active_image + 1 then
		return
	end

	self.cur_select_img_index = self.cur_select_img_index + 1
	self:SetArrowState(self.cur_select_img_index)
	self:SwitchGradeAndName(self.cur_select_img_index)
	self:OnFlush()
end

-- 设置披风属性
function AdvanceCloakView:SetCloakAtrr()
	local cloak_info = CloakData.Instance:GetCloakInfo()
	if cloak_info == nil or cloak_info.cloak_level == 0 then
		self:SetAutoButtonGray()
		return
	end

	self:FlushItemNum()

	local cloak_level_cfg = CloakData.Instance:GetCloakLevelCfg(cloak_info.cloak_level)
	if not cloak_level_cfg then return end

	local up_level_cfg = CloakData.Instance:GetCloakUpLevelStuffCfg(self.item_index)
	local stuff_item_id = up_level_cfg.up_level_item_id

	if cloak_info.cloak_level == 0 then
		self:SetAutoButtonGray()
		return
	end

	if self.cur_select_img_index < 0 or self.temp_img_index < 0 then
		local cur_select_img_index = cloak_level_cfg.active_image
		self.cur_select_img_index = cur_select_img_index
		self.temp_img_index = cur_select_img_index
	end

	if self.temp_img_index < cloak_level_cfg.active_image then
		-- 升级成功音效
		AudioService.Instance:PlayAdvancedAudio()
		-- 升级特效
		if not self.effect_cd or self.effect_cd <= Status.NowTime then
			self.show_effect:SetValue(false)
			self.show_effect:SetValue(true)
			self.effect_cd = EFFECT_CD + Status.NowTime
		end
		CloakCtrl.Instance:SendUseCloakImage(CloakData.Instance:GetUsedImageid() + 1)
		self.is_auto = false
		self.res_id = -1
		self.show_on_look:SetValue(false)
		self.look_btn_text:SetValue(Language.Common.Look)

		self.cur_select_img_index = cloak_level_cfg.active_image
		self.temp_img_index = cloak_level_cfg.active_image
	end

	self:SetAutoButtonGray()
	self:SetArrowState(self.cur_select_img_index)
	self:SwitchGradeAndName(self.cur_select_img_index)

	if cloak_info.cloak_level >= CloakData.Instance:GetMaxCloakLevel() then
		self.cur_bless:SetValue(Language.Common.YiMan)
		self.exp_radio:InitValue(1)
		self.hide_effect:SetValue(true)
	else
		self.cur_bless:SetValue(cloak_info.cur_exp .. "/" .. cloak_level_cfg.up_level_exp)
		self.exp_radio:SetValue(cloak_info.cur_exp / cloak_level_cfg.up_level_exp)
	end
	local skill_capability = 0
	for i = 0, 3 do
		if CloakData.Instance:GetCloakSkillCfgById(i) then
			skill_capability = skill_capability + CloakData.Instance:GetCloakSkillCfgById(i).capability
		end
	end

	local attr = CloakData.Instance:GetCloakAttrSum()
	local capability = CommonDataManager.GetCapabilityCalculation(attr)
	self.old_attrs = attr
	local next_attr = CloakData.Instance:GetCloakAttrSum(nil, true)
	--属性
	if self.is_fulsh_zhanli then
		self.fight_power:SetValue(capability)
		self.maxhp_cur_value:SetValue(attr.max_hp)
		self.gongji_cur_value:SetValue(attr.gong_ji)
		self.fangyu_cur_value:SetValue(attr.fang_yu)

		self.maxhp_next_value:SetValue(next_attr.max_hp)
		self.gongji_next_value:SetValue(next_attr.gong_ji)
		self.fangyu_next_value:SetValue(next_attr.fang_yu)

	else
		local  attr1 =  CloakData.Instance:GetCloakMaxAttrSum()
		local capability = CommonDataManager.GetCapabilityCalculation(attr1)
	    self.fight_power:SetValue(capability + skill_capability)
		--self.show_next_attr:SetValue(false)
		self.maxhp_cur_value:SetValue(attr1.max_hp)
		self.gongji_cur_value:SetValue(attr1.gong_ji)
		self.fangyu_cur_value:SetValue(attr1.fang_yu)

		self.maxhp_next_value:SetValue(next_attr.max_hp)
		self.gongji_next_value:SetValue(next_attr.gong_ji)
		self.fangyu_next_value:SetValue(next_attr.fang_yu)
	end

	local max_level = CloakData.Instance:GetMaxCloakLevel()
	if cloak_info.cloak_level >= max_level then
		self.show_next_attr:SetValue(false)
	end

	local next_ative_img_level = CloakData.Instance:GetNextActiveImgLevel()
	self.is_show_next_str:SetValue(nil ~= next_ative_img_level)
	self.next_img_active_level:SetValue(next_ative_img_level or cloak_info.cloak_level)

	local cloak_level_cfg = CloakData.Instance:GetCloakLevelCfg(next_ative_img_level or cloak_info.cloak_level)
	if cloak_level_cfg then
		local image_cfg = CloakData.Instance:GetImageListInfo(cloak_level_cfg.active_image)
		self.next_img_active_name:SetValue(image_cfg.image_name)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(stuff_item_id)
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">" ..item_cfg.name.."</color>"
	self.prop_name:SetValue(name_str)

	self.show_zizhi_redpoint:SetValue(CloakData.Instance:IsShowZizhiRedPoint())
	self.show_huanhua_redpoint:SetValue(AdvanceData.Instance:IsShowCloakRedPoint())
	self:CheckSelectItem()
end

function AdvanceCloakView:FlushItemNum()
	for i = 1, 3 do
		local up_stuff_cfg = CloakData.Instance:GetCloakUpLevelStuffCfg(i)
		local data = {}
		data.item_id = up_stuff_cfg.up_level_item_id
		data.num = ItemData.Instance:GetItemNumInBagById(up_stuff_cfg.up_level_item_id)
		self.item_cell_list[i]:SetShowNumTxtLessNum(-1)
		self.item_cell_list[i]:SetData(data)
		self.item_cell_list[i]:SetIconGrayScale(false)
		self.item_cell_list[i]:ShowQuality(true)
	end
end

function AdvanceCloakView:SetArrowState(cur_select_img_index)
	local cloak_info = CloakData.Instance:GetCloakInfo()
	if not cloak_info or not next(cloak_info) then return end
	local level_cfg = CloakData.Instance:GetCloakLevelCfg(cloak_info.cloak_level)
	local max_level = CloakData.Instance:GetMaxCloakLevel()
	local max_level_cfg = CloakData.Instance:GetCloakLevelCfg(max_level)

	if not cloak_info or not cloak_info.cloak_level or not cur_select_img_index or not max_level then
		return
	end

	self.show_right_button:SetValue(cur_select_img_index < level_cfg.active_image + 1 and cur_select_img_index < max_level_cfg.active_image)
	self.show_left_button:SetValue(cur_select_img_index >= 1)

	self.show_use_button:SetValue(cur_select_img_index ~= cloak_info.used_imageid and cur_select_img_index <= level_cfg.active_image and cur_select_img_index ~= 0)
	self.show_use_image:SetValue(cur_select_img_index == cloak_info.used_imageid and cur_select_img_index ~= 0)
end

-- 点击自动进阶，服务器返回信息，设置按钮状态
function AdvanceCloakView:SetAutoButtonGray()
	local cloak_info = CloakData.Instance:GetCloakInfo()
	if cloak_info.cloak_level == nil then return end

	local max_level = CloakData.Instance:GetMaxCloakLevel()

	if not cloak_info or not cloak_info.cloak_level or cloak_info.cloak_level <= 0
		or cloak_info.cloak_level >= max_level then
		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
		self.start_button.button.interactable = false
		self.auto_button.button.interactable = false
		self.button_is_max:SetValue(false)
		return
	end

	if self.is_auto then
		self.auto_btn_text:SetValue(Language.Common.Stop)
		self.start_button.button.interactable = false
		self.auto_button.button.interactable = true
		self.button_text:SetValue(false)
	else
		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
		self.start_button.button.interactable = true
		self.auto_button.button.interactable = true
		self.button_text:SetValue(true)
		self.button_is_max:SetValue(true)
	end
end

-- 物品不足，购买成功后刷新物品数量
function AdvanceCloakView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:FlushItemNum()
end

-- function AdvanceCloakView:SetNotifyDataChangeCallBack()
-- 	if ViewManager.Instance:IsOpen(ViewName.Advance) then
-- 		-- 监听系统事件
-- 		if self.item_data_event == nil then
-- 			self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
-- 			ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
-- 		end
-- 		-- self:SetRestTime()
-- 	end
-- end

function AdvanceCloakView:SetModle(is_show)
	if is_show then
		if not CloakData.Instance:IsActiviteCloak() then
			return
		end
		local cloak_info = CloakData.Instance:GetCloakInfo()
		if not cloak_info or not next(cloak_info) then return end
		local used_imageid = cloak_info.used_imageid
		local cloak_level_cfg = CloakData.Instance:GetCloakLevelCfg(cloak_info.cloak_level)
		if used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			used_imageid = used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID
		end

		-- 还原到非预览状态
		self.is_on_look = false
		self.show_on_look:SetValue(false)
		self.look_btn_text:SetValue(Language.Common.Look)

		if cloak_level_cfg and used_imageid and self.cur_select_img_index < 0 then
			local cur_select_img_index = used_imageid
			self:SetArrowState(cur_select_img_index)
			self:SwitchGradeAndName(cur_select_img_index)
			self.cur_select_img_index = self.cur_select_img_index and cur_select_img_index
		end
	else
		self.temp_img_index = -1
		self.cur_select_img_index = -1
		if self.show_effect then
			self.show_effect:SetValue(false)
		end
	end
end

function AdvanceCloakView:ClearTempData()
	self.res_id = -1
	self.cur_select_img_index = -1
	self.temp_img_index = -1
	self.is_auto = false
	self.cloak_asset = 0
end

function AdvanceCloakView:RemoveNotifyDataChangeCallBack()
	-- if self.item_data_event ~= nil then
	-- 	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	-- 	self.item_data_event = nil
	-- end
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.temp_img_index = -1
	self.res_id = -1
	self.cur_select_img_index = -1
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	-- if self.time_quest then
	-- 	GlobalTimerQuest:CancelQuest(self.time_quest)
	-- 	self.time_quest = nil
	-- end
end

function AdvanceCloakView:ResetModleRotation()
	-- if self.cloak_display ~= nil then
		-- self.cloak_display.ui3d_display:ResetRotation()
	-- end
end

-- 设置清空祝福值的剩余时间
function AdvanceCloakView:SetRestTime()
	-- local cloak_info = CloakData.Instance:GetCloakInfo()
	-- local cloak_level_cfg = CloakData.Instance:GetCloakLevelCfg(cloak_info.cloak_level)
	-- if cloak_level_cfg == nil or cloak_info == nil then
	-- 	self.show_time:SetValue(false)
	-- 	return
	-- end

	-- if cloak_info.clear_upgrade_time > 0 and cloak_info.clear_upgrade_time ~= nil and cloak_level_cfg.is_clear_bless == 1
	-- 	and (cloak_info.clear_upgrade_time - TimeCtrl.Instance:GetServerTime()) > 0 then
	-- 	self.show_time:SetValue(true)
	-- 	local diff_time = cloak_info.clear_upgrade_time - TimeCtrl.Instance:GetServerTime()
	-- 	if self.count_down == nil then
	-- 		local function diff_time_func(elapse_time, total_time)
	-- 			local left_time = math.floor(diff_time - elapse_time + 0.5)
	-- 			if left_time <= 0 then
	-- 				self.show_time:SetValue(false)
	-- 				CloakCtrl.Instance:SendGetCloakInfo()
	-- 				if self.count_down ~= nil then
	-- 					CountDown.Instance:RemoveCountDown(self.count_down)
	-- 					self.count_down = nil
	-- 				end
	-- 				return
	-- 			end
	-- 			local left_hour = math.floor(left_time / 3600)
	-- 			local left_min = math.floor((left_time - left_hour * 3600) / 60)
	-- 			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
	-- 			self.cur_hour:SetValue(left_hour)
	-- 			self.cur_min:SetValue(left_min)
	-- 			self.cur_sec:SetValue(left_sec)
	-- 		end

	-- 		diff_time_func(0, diff_time)
	-- 		self.count_down = CountDown.Instance:AddCountDown(
	-- 			diff_time, 0.5, diff_time_func)
	-- 	end
	-- else
	-- 	if self.count_down ~= nil then
	-- 		CountDown.Instance:RemoveCountDown(self.count_down)
	-- 		self.count_down = nil
	-- 	end
	-- 	self.show_time:SetValue(false)
	-- end
end

function AdvanceCloakView:OnAutoBuyToggleChange(isOn)
	-- if TipsCommonAutoView.AUTO_VIEW_STR_T["auto_cloak_up"] then
	-- 	TipsCommonAutoView.AUTO_VIEW_STR_T["auto_cloak_up"].is_auto_buy = isOn
	-- end
end

function AdvanceCloakView:OpenCallBack()
	if self.show_effect then
		self.show_effect:SetValue(false)
	end
	local cloak_info = CloakData.Instance:GetCloakInfo()
	if not cloak_info or not next(cloak_info) then return end
	self.last_level = cloak_info.star_level
	-- if TipsCommonAutoView.AUTO_VIEW_STR_T["auto_cloak_up"] then
	-- 	self.auto_buy_toggle.toggle.isOn = TipsCommonAutoView.AUTO_VIEW_STR_T["auto_cloak_up"].is_auto_buy
	-- end
end

function AdvanceCloakView:FlushStars()
	local cloak_info = CloakData.Instance:GetCloakInfo()
	if nil == cloak_info.star_level then
		return
	end
	local index = cloak_info.star_level % 10
	if index == 0 then
		for k, v in pairs(self.stars_list) do
			v.grayscale.GrayScale = 255
		end
	else
		for i = 1, index do
			self.stars_list[i].grayscale.GrayScale = 0
		end
		for i = index + 1, 10 do
			self.stars_list[i].grayscale.GrayScale = 255
		end
	end
	if cloak_info.star_level == self.last_level + 1 then
		self.last_level = cloak_info.star_level
		if index == 0 then
			index = 10
		end
		EffectManager.Instance:PlayAtTransformCenter("effects2/prefab/ui/ui_star_prefab", "UI_star", self.stars_list[index].transform, 1.0)
	end
end

function AdvanceCloakView:OnFlush(param_list, uplevel_list)
	if not CloakData.Instance:IsActiviteCloak() then
		return
	end

	local bundle = self.cloak_bundle
	local asset = self.cloak_asset

	if nil ~= bundle and nil ~= asset and self.cloak_asset_id ~= asset then
		local main_role = Scene.Instance:GetMainRole()
		self.model_view:SetRoleResid(main_role:GetRoleResId())
		-- if self.cur_select_img_index == 0 then
		-- 	self.model_view:SetCloakResid(self.cur_select_img_index)
		-- else
		-- 	self.model_view:SetCloakResid(asset)
		-- end
		self.model_view:SetCloakResid(self.cloak_asset)
		--self.model_view:SetMainAsset(bundle, asset)
		self.cloak_asset_id = asset
	end
	-- if self.cur_select_img_index == 0 then
	-- 	self.model_view:SetCloakResid(0)
	-- else
	-- 	self.model_view:SetCloakResid(self.cloak_asset)
	-- end
	self.model_view:SetCloakResid(self.cloak_asset)
	if param_list == "cloak" or type(param_list) == "table" then
		if self.root_node.gameObject.activeSelf then
			self:SetCloakAtrr()
			self:FlushSkillIcon()
			--self:FlushStars()
		end
		return
	end

	-- for k, v in pairs(param_list) do
	-- 	if k == "cloak" or k == "all" then
	-- 		if self.root_node.gameObject.activeSelf then
	-- 			self:SetCloakAtrr()
	-- 			self:FlushSkillIcon()
	-- 			--self:FlushStars()
	-- 		end
	-- 	end
	-- end
end
