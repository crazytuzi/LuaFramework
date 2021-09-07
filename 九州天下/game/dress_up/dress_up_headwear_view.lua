DressUpHeadwearView = DressUpHeadwearView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
function DressUpHeadwearView:__init(instance)
	self.is_auto = false
	self.is_can_auto = true
	self.jinjie_next_time = 0
	self.old_attrs = {}
	self.skill_fight_power = 0
	self.fix_show_time = 10
	self.res_id = -1
	self.cur_select_grade = -1
	self.temp_grade = -1
	self.is_on_look = false
	self.old_grade_bless_val = nil --用于升星提示Tips
	self.old_star_level  = nil
	self.is_block = flase
end

function DressUpHeadwearView:__delete()
	if self.headwear_model ~= nil then
		self.headwear_model:DeleteMe()
		self.headwear_model = nil
	end
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.jinjie_next_time = nil
	self.is_auto = nil
	self.headwear_skill_list = nil
	self.old_attrs = {}
	self.skill_fight_power = nil
	self.fix_show_time = nil
	self.res_id = nil
	self.old_grade_bless_val = nil 
	self.baoju_plus_num = nil
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

	if self.visible_quest then
		GlobalTimerQuest:CancelQuest(self.visible_quest)
		self.visible_quest = nil
	end
end
function DressUpHeadwearView:LoadCallBack()
		self:ListenEvent("StartAdvance", BindTool.Bind(self.OnStartAdvance, self))
	self:ListenEvent("AutomaticAdvance", BindTool.Bind(self.OnAutomaticAdvance, self))
	self:ListenEvent("OnClickUse", BindTool.Bind(self.OnClickUse, self))
	self:ListenEvent("OnClickZiZhi", BindTool.Bind(self.OnClickZiZhi, self))
	-- self:ListenEvent("OnClickChengZhang",
	-- 	BindTool.Bind(self.OnClickChengZhang, self))
	self:ListenEvent("OnClickHuanHua", BindTool.Bind(self.OnClickHuanHua, self))
	self:ListenEvent("OnClickLastButton", BindTool.Bind(self.OnClickLastButton, self))
	self:ListenEvent("OnClickNextButton", BindTool.Bind(self.OnClickNextButton, self))
	self:ListenEvent("OnClickTopLook", BindTool.Bind(self.OnClickTopLook, self))
	self:ListenEvent("OnClickEquipBtn",	BindTool.Bind(self.OnClickEquipBtn, self))
	self:ListenEvent("OnClickSkill", BindTool.Bind(self.OnClickSkill, self))
	self:ListenEvent("OnClickMasking", BindTool.Bind(self.OnClickMasking, self))

	self.headwear_name = self:FindVariable("Name")
	self.headwear_rank = self:FindVariable("Rank")
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
	self.su_du = self:FindVariable("SuDu")
	self.remainder_num = self:FindVariable("RemainderNum")
	self.need_num = self:FindVariable("NeedNun")
	-- self.quality = self:FindVariable("QualityBG")
	self.auto_btn_text = self:FindVariable("AutoButtonText")
	self.look_btn_text = self:FindVariable("LookBtnText")

	self.show_use_button = self:FindVariable("UseButton")
	self.show_use_image = self:FindVariable("UseImage")
	self.show_left_button = self:FindVariable("LeftButton")
	self.show_right_button = self:FindVariable("RightButton")
	self.show_effect = self:FindVariable("ShowEffect")
	self.show_on_look = self:FindVariable("IsOnLookState")
	self.baoju_plus_num = self:FindVariable("BaojuPlusNum")
	self.is_masking = self:FindVariable("IsMasking")
	-- self.no_clear_text = self:FindVariable("ShowNoClear")
	-- self.clear_text = self:FindVariable("ShowClear")
	-- self.cur_hour = self:FindVariable("Hour")
	-- self.cur_min = self:FindVariable("Min")
	-- self.cur_sec = self:FindVariable("Sec")
	-- self.show_time = self:FindVariable("ShowTime")
	self.prop_name = self:FindVariable("PropName")
	self.cur_bless = self:FindVariable("CurBless")
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

	self.headwear_model = RoleModel.New()
	self.headwear_display = self:FindObj("HeadwearDisplay")
	self.headwear_model:SetDisplay(self.headwear_display.ui3d_display)

	self.auto_buy_toggle = self:FindObj("AutoToggle")
	self.auto_buy_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnAutoBuyToggleChange, self))
	self.start_button = self:FindObj("StartButton")
	self.up_grade_gray = self:FindVariable("UpGradeGray")
	self.auto_button = self:FindObj("AutoButton")
	self.auto_up_grade_gray = self:FindVariable("AutoUpGradeGray")
	self.gray_use_button = self:FindObj("GrayUseButton")
	self.skill_funopen = self:FindVariable("showskill_funopen")

	self.headwear_skill_list = {}

	self.star_lists = {}
	for i = 1, 10 do
		self.star_lists[i] = self:FindVariable("Star"..i)
	end

	-- self:GetEquipItemCells()
	self:GetHeadwearSkill()

end
function DressUpHeadwearView:OnClickSkill()
	AdvanceSkillCtrl.Instance:OpenView(ADVANCE_SKILL_TYPE.WING)
end

-- 开始进阶
function DressUpHeadwearView:OnStartAdvance(from_auto)
	local headwear_info = HeadwearData.Instance:GetHeadwearInfo()
	if headwear_info.show_grade == 0 then
		return
	end
	local grade_cfg = HeadwearData.Instance:GetHeadwearShowGradeCfg(headwear_info.show_grade)

	local is_auto_buy_toggle = self.auto_buy_toggle.toggle.isOn

	if headwear_info.show_grade >= HeadwearData.Instance:GetMaxGrade() and (headwear_info.star_level % 10 == 0) then
		return
	end

	if ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id) < grade_cfg.upgrade_stuff_count and not is_auto_buy_toggle then
		self.is_auto = false
		self.is_can_auto = true
		self:SetAutoButtonGray()
		-- 物品不足，弹出TIP框
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[grade_cfg.upgrade_stuff_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowSystemMsg(Language.Exchange.NotEnoughItem)
			return
		end

		-- if item_cfg.bind_gold == 0 then
		-- 	TipsCtrl.Instance:ShowShopView(grade_cfg.upgrade_stuff_id, 2)
		-- 	return
		-- end

		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.auto_buy_toggle.toggle.isOn = true
				if from_auto then
					self:OnAutomaticAdvance()
				else
					self:OnStartAdvance()
				end
			end
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, grade_cfg.upgrade_stuff_id, nofunc,
			(grade_cfg.upgrade_stuff_count - ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id)))
		return
	end

	local is_auto_buy = self.auto_buy_toggle.toggle.isOn and 1 or 0
	HeadwearCtrl.Instance:SendUpGradeReq(is_auto_buy, self.is_auto)
	self.jinjie_next_time = Status.NowTime + (grade_cfg.next_time or 0.1)
end

function DressUpHeadwearView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	if self.cur_select_grade > 0 and self.cur_select_grade <= HeadwearData.Instance:GetMaxGrade() then
		if self.is_auto then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnStartAdvance,self), jinjie_next_time)
		end
	end
end

function DressUpHeadwearView:HeadwearUpgradeResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self:SetAutoButtonGray()
	else
		self:AutoUpGradeOnce()
	end
end

-- 自动进阶
function DressUpHeadwearView:OnAutomaticAdvance()
	local headwear_info = HeadwearData.Instance:GetHeadwearInfo()

	if headwear_info.show_grade == 0 then
		return
	end
	if not self.is_can_auto then
		return
	end
	local function ok_callback()
		if TipsCommonAutoView.AUTO_VIEW_STR_T["auto_headwear_up"] and TipsCommonAutoView.AUTO_VIEW_STR_T["auto_headwear_up"].is_auto_buy then
			self.auto_buy_toggle.toggle.isOn = true
		end
		self.is_auto = self.is_auto == false
		self.is_can_auto = false
		self:OnStartAdvance(true)
		self:SetAutoButtonGray()
	end

	local function cancel_callback()
		self:SetAutoButtonGray()
	end

	if not self.auto_buy_toggle.toggle.isOn then
		TipsCtrl.Instance:ShowCommonAutoView("auto_headwear_up", Language.Mount.AutoUpDes, ok_callback, cancel_callback, true, nil, nil, nil, true)
	else
		ok_callback()
	end
end

-- 顶级预览
function DressUpHeadwearView:OnClickTopLook()
	local headwear_info = HeadwearData.Instance:GetHeadwearInfo()
	if not headwear_info or not next(headwear_info) then return end

	self.is_on_look = self.is_on_look == false

	self.show_on_look:SetValue(self.is_on_look)

	local btn_text = self.is_on_look and Language.Common.CancelLook or Language.Common.Look
	self.look_btn_text:SetValue(btn_text)

	local grade = self.is_on_look and HeadwearData.Instance:GetMaxGrade() or self.cur_select_grade

	self:SwitchGradeAndName(grade)
end

-- 点击进阶装备
function DressUpHeadwearView:OnClickEquipBtn()
	local is_active, activite_grade = HeadwearData.Instance:IsOpenEquip()
	if not is_active then
		local name = Language.Advance.PercentAttrNameList[ADVANCE_EQUIP_TYPE.WING] or ""
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade)))
		return
	end
	ViewManager.Instance:Open(ViewName.AdvanceEquipView, TabIndex.headwear)
end

-- 使用当前羽翼
function DressUpHeadwearView:OnClickUse()
	if self.cur_select_grade == nil then
		return
	end
	local grade_cfg = HeadwearData.Instance:GetHeadwearShowGradeCfg(self.cur_select_grade)
	if not grade_cfg then return end
	self.is_block = false
	self.is_masking:SetValue(self.is_block)
	HeadwearCtrl.Instance:SendUseHeadwearImage(grade_cfg.image_id)
end

--显示上一阶形象
function DressUpHeadwearView:OnClickLastButton()
	if not self.cur_select_grade or self.cur_select_grade <= 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade - 1
	self:SetArrowState(self.cur_select_grade)
	self:SwitchGradeAndName(self.cur_select_grade)

	-- if self.headwear_display ~= nil then
		-- self.headwear_display.ui3d_display:ResetRotation()
	-- end
end

--显示下一阶形象
function DressUpHeadwearView:OnClickNextButton()
	local headwear_info = HeadwearData.Instance:GetHeadwearInfo()
	if not self.cur_select_grade or self.cur_select_grade > headwear_info.show_grade or headwear_info.show_grade == 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade + 1
	self:SetArrowState(self.cur_select_grade)
	self:SwitchGradeAndName(self.cur_select_grade)
	-- if self.headwear_display ~= nil then
		-- self.headwear_display.ui3d_display:ResetRotation()
	-- end
end

function DressUpHeadwearView:SwitchGradeAndName(index)
	if index == nil then return end
	local headwear_grade_cfg = HeadwearData.Instance:GetHeadwearShowGradeCfg(index)
	if headwear_grade_cfg == nil then return end
	local image_cfg = HeadwearData.Instance:GetHeadwearImageCfg(headwear_grade_cfg.image_id)

	local bundle, asset = ResPath.GetDressUpEquipIcon("headwear_name_" .. (image_cfg.title_res or 1))
	self.grade_name_img:SetAsset(bundle, asset)
	self.headwear_rank:SetValue(headwear_grade_cfg.gradename)

	if image_cfg and self.res_id ~= image_cfg.res_id then
		-- local new_attr = HeadwearData.Instance:GetHeadwearAttrSum()
		-- TipsCtrl.Instance:ShowAdvanceSucceView(image_cfg[headwear_grade_cfg.image_id], new_attr, new_attr, "headwear_view")

		local color = (index / 3 + 1) >= 5 and 5 or math.floor(index / 3 + 1)
		local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..image_cfg.image_name.."</color>"
		self.headwear_name:SetValue(name_str)

		local main_role = Scene.Instance:GetMainRole()
		self.headwear_model:SetRoleResid(main_role:GetRoleResId())
		self.headwear_model:SetTouShiResid(image_cfg.res_id)
		self.res_id = image_cfg.res_id
	end
end
 
-- 资质
function DressUpHeadwearView:OnClickZiZhi()
	ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "headwearzizhi", {item_id = HeadwearDanId.ZiZhiDanId})
end

-- -- 成长
-- function DressUpHeadwearView:OnClickChengZhang()
-- 	ViewManager.Instance:Open(ViewName.TipChengZhang, nil,"headwearchengzhang", {item_id = HeadwearDanId.ChengZhangDanId})
-- end

-- 幻化
function DressUpHeadwearView:OnClickHuanHua()
	ViewManager.Instance:Open(ViewName.HeadwearHuanHua)
	HeadwearHuanHuaCtrl.Instance:FlushView("headwearhuanhua")
end

-- 点击技能
function DressUpHeadwearView:OnClickHeadwearSkill(index)
	ViewManager.Instance:Open(ViewName.TipSkillUpgrade, nil, "headwearskill", {index = index - 1})
end

function DressUpHeadwearView:GetHeadwearSkill()
	for i = 1, 4 do
		local skill = self:FindObj("HeadwearSkill"..i)
		local icon = skill:FindObj("Image")
		local activite = skill:FindObj("ImgActivity")
		table.insert(self.headwear_skill_list, {skill = skill, icon = icon, activite = activite})
	end
	for k, v in pairs(self.headwear_skill_list) do
		local bundle, asset = ResPath.GetHeadwearSkillIcon(k)
		v.icon.image:LoadSprite(bundle, asset)
		v.skill.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickHeadwearSkill, self, k))
	end
end

function DressUpHeadwearView:FlushSkillIcon()
	local skill_id_list = HeadwearData.Instance:GetHeadwearSkillId()
	local headwear_info = HeadwearData.Instance:GetHeadwearInfo()
	if nil == skill_id_list then return end
	for k, v in pairs(self.headwear_skill_list) do
		local skill_info = SkillData.Instance:GetSkillInfoById(skill_id_list[k].skill_id) or {}
		local skill_level = skill_info.level or 0
		local activity_info = false
		if v.icon.grayscale then
			v.icon.grayscale.GrayScale = skill_level > 0 and 0 or 255
		end
		-- if skill_level <= 0 and self.skill_arrow_list[k-1] then 					-- 没激活不显示
		-- 	self.skill_arrow_list[k-1]:SetValue(false)
		-- end
		if skill_level <= 0 and headwear_info.show_grade >= 1 then
			activity_info = HeadwearData.Instance:GetHeadwearSkillIsActvity(k - 1, headwear_info.show_grade)
		end
		if v.activite then
			v.activite:SetActive(activity_info)
		end
	end
end

-- 设置属性
function DressUpHeadwearView:SetHeadwearAtrr()
	local headwear_info = HeadwearData.Instance:GetHeadwearInfo()
	--local image_cfg = HeadwearData.Instance:GetHeadwearImageCfg()
	if headwear_info == nil or headwear_info.show_grade == nil then
		self:SetAutoButtonGray()
		return
	end

	self.is_block = (headwear_info.show_grade > 0 and headwear_info.used_imageid == 0) and true or false
	self.is_masking:SetValue(self.is_block)

	if headwear_info.headwear_level == 0 or headwear_info.show_grade == 0 then
		local headwear_grade_cfg = HeadwearData.Instance:GetHeadwearGradeCfg(1)
		self:SetAutoButtonGray()
		self.remainder_num:SetValue(ItemData.Instance:GetItemNumInBagById(headwear_grade_cfg.upgrade_stuff_id))
		-- self.no_clear_text:SetValue(false)
		-- self.clear_text:SetValue(false)
		return
	end
	local headwear_grade_cfg = HeadwearData.Instance:GetHeadwearGradeCfg(headwear_info.grade)

	if not headwear_grade_cfg then return end

	if self.temp_grade < 0 then
		if headwear_grade_cfg.show_grade == 0 then
			self.cur_select_grade = headwear_info.show_grade
		elseif headwear_grade_cfg.show_grade > 0 and headwear_info.used_imageid == 0 then -- 屏蔽
			self.cur_select_grade = headwear_info.show_grade
		else
			self.cur_select_grade = headwear_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and headwear_info.show_grade
									or HeadwearData.Instance:GetHeadwearGradeByUseImageId(headwear_info.used_imageid)
		end
		self:SetAutoButtonGray()
		self:SetArrowState(self.cur_select_grade)
		self:SwitchGradeAndName(self.cur_select_grade)
		self.temp_grade = headwear_info.show_grade
	else
		if self.temp_grade < headwear_info.show_grade then
			-- local new_attr = HeadwearData.Instance:GetHeadwearAttrSum()
			-- local old_capability = CommonDataManager.GetCapabilityCalculation(self.old_attrs) + self.skill_fight_power
			-- local new_capability = CommonDataManager.GetCapabilityCalculation(new_attr) + self.skill_fight_power
			-- TipsCtrl.Instance:ShowAdvanceSucceView(image_cfg[headwear_grade_cfg.image_id], new_attr, self.old_attrs, "headwear_view", new_capability, old_capability)

			-- 升级成功音效
			AudioService.Instance:PlayAdvancedAudio()
			-- 进阶成功提示
			TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordAdvenceSuccess"))
			-- 升级特效
			if not self.effect_cd or self.effect_cd <= Status.NowTime then
				self.show_effect:SetValue(false)
				self.show_effect:SetValue(true)
				self.effect_cd = EFFECT_CD + Status.NowTime
			end

			if headwear_grade_cfg.show_grade == 0 then
				self.cur_select_grade = headwear_info.show_grade
			else
				self.cur_select_grade = headwear_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and headwear_info.show_grade
										or HeadwearData.Instance:GetHeadwearGradeByUseImageId(headwear_info.used_imageid)
			end
			self.is_auto = false
			self.res_id = -1
			self:SetAutoButtonGray()
			self:SetArrowState(self.cur_select_grade)
			self:SwitchGradeAndName(headwear_info.show_grade)

			self.show_on_look:SetValue(false)
			self.look_btn_text:SetValue(Language.Common.Look)
		end
		self.temp_grade = headwear_info.show_grade
	end
	self:SetUseImageButtonState(self.cur_select_grade)

	if self.old_grade_bless_val == nil then 
		self.old_grade_bless_val = headwear_info.grade_bless_val --初始化
	end
	if self.old_star_level == nil then
		self.old_star_level = headwear_info.star_level % 10
	end
	if headwear_info.show_grade >= HeadwearData.Instance:GetMaxGrade() and (headwear_info.star_level % 10 == 0) then
		self:SetAutoButtonGray()
		self.cur_bless:SetValue(Language.Common.YiMan)
		self.exp_radio:InitValue(1)
	else
		self.cur_bless:SetValue(headwear_info.grade_bless_val.."/"..headwear_grade_cfg.bless_val_limit)
		self.exp_radio:SetValue(headwear_info.grade_bless_val/headwear_grade_cfg.bless_val_limit)
		--升星提示
		if self.old_grade_bless_val ~= headwear_info.grade_bless_val then
			if(headwear_info.grade_bless_val-self.old_grade_bless_val >= 100)  then
				TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordUpStarBaoji"))
			end
			self.old_grade_bless_val = headwear_info.grade_bless_val
		end
		if self.old_star_level ~= headwear_info.star_level % 10 then
			--升星提示
			TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordUpStarSuccess"))
			self.old_star_level = headwear_info.star_level % 10
		end
	end

	local skill_capability = 0
	local baoju_plus = AdvanceData.Instance:GetMedalPlusNum("headwear_attr_add")
	local baoju_grade = MedalData.Instance:GetMedalIsOneJie()
	if not baoju_grade then
		baoju_plus = 0
	end		
	for i = 0, 3 do
		if HeadwearData.Instance:GetHeadwearSkillCfgById(i) then
			skill_capability = skill_capability + HeadwearData.Instance:GetHeadwearSkillCfgById(i).capability
		end
	end
	self.skill_fight_power = skill_capability
	local attr = CommonDataManager.GetAttributteByClass(headwear_grade_cfg)
	local capability = CommonDataManager.GetCapabilityCalculation(attr)
	self.old_attrs = attr
	self.fight_power:SetValue(capability + skill_capability + math.floor(capability * baoju_plus / 100))

	self.sheng_ming:SetValue(attr.max_hp + math.floor(attr.max_hp * baoju_plus / 100))
	self.gong_ji:SetValue(attr.gong_ji + math.floor(attr.gong_ji * baoju_plus / 100))
	self.fang_yu:SetValue(attr.fang_yu + math.floor(attr.fang_yu * baoju_plus / 100))
	self.ming_zhong:SetValue(attr.ming_zhong + math.floor(attr.ming_zhong * baoju_plus / 100))
	self.shan_bi:SetValue(attr.shan_bi + math.floor(attr.shan_bi * baoju_plus / 100))
	self.bao_ji:SetValue(attr.shan_bi + math.floor(attr.shan_bi * baoju_plus / 100))
	self.jian_ren:SetValue(attr.jian_ren + math.floor(attr.jian_ren * baoju_plus / 100))
	self.baoju_plus_num:SetValue(baoju_plus)

	self.need_num:SetValue("  " .. headwear_grade_cfg.upgrade_stuff_count)

	local bag_num = string.format(Language.Mount.ShowGreenStr, ItemData.Instance:GetItemNumInBagById(headwear_grade_cfg.upgrade_stuff_id))
	if ItemData.Instance:GetItemNumInBagById(headwear_grade_cfg.upgrade_stuff_id) < headwear_grade_cfg.upgrade_stuff_count then
		bag_num = string.format(Language.Mount.ShowRedStr, ItemData.Instance:GetItemNumInBagById(headwear_grade_cfg.upgrade_stuff_id))
	end
	self.remainder_num:SetValue(bag_num)
	self.prop_name:SetValue(ItemData.Instance:GetItemConfig(headwear_grade_cfg.upgrade_stuff_id).name)
	-- local item_cfg = ItemData.Instance:GetItemConfig(headwear_grade_cfg.upgrade_stuff_id)
	-- self.item_icon:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
	self.item_cell:SetData({item_id=headwear_grade_cfg.upgrade_stuff_id, num=0, is_bind=0})

	self.jia_shang:SetValue(attr.per_pofang)
	self.jian_shang:SetValue(attr.per_mianshang)
	self.show_zizhi_redpoint:SetValue(HeadwearData.Instance:IsShowZizhiRedPoint())
	-- self.show_chengzhang_redpoint:SetValue(HeadwearData.Instance:IsShowChengzhangRedPoint())
	self.show_huanhua_redpoint:SetValue(next(HeadwearData.Instance:CanHuanhuaUpgrade()) ~= nil)
	local can_uplevel_skill_list = HeadwearData.Instance:CanSkillUpLevelList()
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_arrow_list[i]:SetValue(can_uplevel_skill_list[i] ~= nil)
	end

	self:FlushStars()
end

function DressUpHeadwearView:SetArrowState(cur_select_grade)
	local headwear_info = HeadwearData.Instance:GetHeadwearInfo()
	local max_grade = HeadwearData.Instance:GetMaxGrade()
	local grade_cfg = HeadwearData.Instance:GetHeadwearShowGradeCfg(cur_select_grade)
	if not headwear_info or not headwear_info.show_grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end
	self.show_right_button:SetValue(cur_select_grade < headwear_info.show_grade + 1 and cur_select_grade < max_grade)
	self.show_left_button:SetValue(grade_cfg.image_id > 1 or (headwear_info.show_grade  == 1 and cur_select_grade > headwear_info.show_grade))
	self:SetUseImageButtonState(cur_select_grade)
end

--设置使用形象按钮
function DressUpHeadwearView:SetUseImageButtonState(cur_select_grade)
	local headwear_info = HeadwearData.Instance:GetHeadwearInfo()
	local max_grade = HeadwearData.Instance:GetMaxGrade()
	local grade_cfg = HeadwearData.Instance:GetHeadwearShowGradeCfg(cur_select_grade)

	if not headwear_info or not headwear_info.show_grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end
	self.show_use_button:SetValue(cur_select_grade <= headwear_info.show_grade and grade_cfg.image_id ~= headwear_info.used_imageid)
	self.show_use_image:SetValue(grade_cfg.image_id == headwear_info.used_imageid)
end

-- 点击自动进阶，服务器返回信息，设置按钮状态
function DressUpHeadwearView:SetAutoButtonGray()
	local headwear_info = HeadwearData.Instance:GetHeadwearInfo()
	if headwear_info.show_grade == nil then return end

	local max_grade = HeadwearData.Instance:GetMaxGrade()

	if not headwear_info or not headwear_info.show_grade or headwear_info.show_grade <= 0
		or (headwear_info.show_grade >= max_grade and (headwear_info.star_level % 10 == 0)) then
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

-- 物品不足，购买成功后刷新物品数量
function DressUpHeadwearView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local headwear_info = HeadwearData.Instance:GetHeadwearInfo()
	local headwear_grade_cfg = HeadwearData.Instance:GetHeadwearShowGradeCfg(headwear_info.show_grade)
	if headwear_grade_cfg == nil  or self.remainder_num == nil then
		return
	end
	local bag_num = string.format(Language.Mount.ShowGreenNum, ItemData.Instance:GetItemNumInBagById(headwear_grade_cfg.upgrade_stuff_id))
	if ItemData.Instance:GetItemNumInBagById(headwear_grade_cfg.upgrade_stuff_id) < headwear_grade_cfg.upgrade_stuff_count then
		bag_num = string.format(Language.Mount.ShowRedNum, ItemData.Instance:GetItemNumInBagById(headwear_grade_cfg.upgrade_stuff_id))
	end
	self.remainder_num:SetValue(bag_num)
end

function DressUpHeadwearView:SetNotifyDataChangeCallBack()
	if ViewManager.Instance:IsOpen(ViewName.Advance) then
		-- 监听系统事件
		if self.item_data_event == nil then
			self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
			ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
		end
		-- self:SetRestTime()
	end
end

function DressUpHeadwearView:SetModle(is_show)
	if is_show then
		-- if not HeadwearData.Instance:IsActiviteHeadwear() then
		-- 	print_error("Headwear is not activite")
		-- 	return
		-- end
		local headwear_info = HeadwearData.Instance:GetHeadwearInfo()
		local used_imageid = headwear_info.used_imageid or 0
		local headwear_grade_cfg = HeadwearData.Instance:GetHeadwearShowGradeCfg(headwear_info.show_grade)
		if used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			used_imageid = HeadwearData.Instance:GetHeadwearShowGradeCfg(headwear_info.show_grade).image_id
		end

		-- 还原到非预览状态
		self.is_on_look = false
		self.show_on_look:SetValue(false)
		self.look_btn_text:SetValue(Language.Common.Look)

		local cur_select_grade = 0
		if headwear_grade_cfg and used_imageid > 0 and self.cur_select_grade < 0 then
			cur_select_grade = headwear_grade_cfg.show_grade == 0 and headwear_info.show_grade or HeadwearData.Instance:GetHeadwearGradeByUseImageId(used_imageid)
			self:SetArrowState(cur_select_grade)
			self:SwitchGradeAndName(cur_select_grade)
			self.cur_select_grade = self.cur_select_grade and cur_select_grade
		end
		-- 屏蔽形象时
		if headwear_grade_cfg and used_imageid == 0 and self.cur_select_grade < 0 then
			cur_select_grade = headwear_grade_cfg.show_grade 
			self:SwitchGradeAndName(cur_select_grade)
			self.cur_select_grade = self.cur_select_grade and cur_select_grade
		end
	else
		self.temp_grade = -1
		self.cur_select_grade = -1
		if self.show_effect then
			self.show_effect:SetValue(false)
		end
	end
end

function DressUpHeadwearView:ClearTempData()
	self.res_id = -1
	self.cur_select_grade = -1
	self.temp_grade = -1
	self.is_auto = false
end

function DressUpHeadwearView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.temp_grade = -1
	self.res_id = -1
	self.cur_select_grade = -1
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	-- if self.time_quest then
	-- 	GlobalTimerQuest:CancelQuest(self.time_quest)
	-- 	self.time_quest = nil
	-- end
end

function DressUpHeadwearView:ResetModleRotation()
	-- if self.headwear_display ~= nil then
		-- self.headwear_display.ui3d_display:ResetRotation()
	-- end
end

function DressUpHeadwearView:FlushStars()
	local headwear_info = HeadwearData.Instance:GetHeadwearInfo()
	if nil == headwear_info or nil == headwear_info.star_level then
		return
	end
	local index = headwear_info.star_level % 10

	for i = 1, 10 do
		self.star_lists[i]:SetValue(index == 0 or index >= i)
	end
end

function DressUpHeadwearView:OnAutoBuyToggleChange(isOn)
	if TipsCommonAutoView.AUTO_VIEW_STR_T["auto_headwear_up"] then
		TipsCommonAutoView.AUTO_VIEW_STR_T["auto_headwear_up"].is_auto_buy = isOn
	end
end

function DressUpHeadwearView:OpenCallBack()
	if self.show_effect then
		self.show_effect:SetValue(false)
	end
	if TipsCommonAutoView.AUTO_VIEW_STR_T["auto_headwear_up"] then
		self.auto_buy_toggle.toggle.isOn = TipsCommonAutoView.AUTO_VIEW_STR_T["auto_headwear_up"].is_auto_buy
	end
end

function DressUpHeadwearView:OnFlush(param_list)
	if not HeadwearData.Instance:IsActiviteHeadwear() then
		return
	end
	
	if self.root_node.gameObject.activeSelf then
		self:SetHeadwearAtrr()
		self:FlushSkillIcon()
	end
	self.show_skill_redpoint:SetValue(AdvanceSkillData.Instance:ShowSkillRedPoint(ADVANCE_SKILL_TYPE.WING))
	self.show_equip_redpoint:SetValue(DressUpData.Instance:IsEquipRedPointShow(ADVANCE_SKILL_TYPE.HEADWEAR))
	self.upgrade_redpoint:SetValue(HeadwearData.Instance:CanJinjie())
	local bool = OpenFunData.Instance:CheckIsHide("advanceskill")
	self.skill_funopen:SetValue(bool)
end

function DressUpHeadwearView:OnClickMasking()
	local headwear_info = HeadwearData.Instance:GetHeadwearInfo()
	if self.is_block then
		HeadwearCtrl.Instance:SendHeadwearReUseReq()
	else
		HeadwearCtrl.Instance:SendUnuseHeadwearImage(headwear_info.used_imageid)
	end
end
