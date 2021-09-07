AdvanceHalidomView = AdvanceHalidomView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
function AdvanceHalidomView:__init(instance)
	self.is_auto = false
	self.is_can_auto = true
	self.jinjie_next_time = 0
	self.temp_grade = -1
	self.cur_select_grade = -1
	self.old_attrs = {}
	self.skill_fight_power = 0
	self.fix_show_time = 10
	self.res_id = -1
	self.is_on_look = false
	self.old_grade_bless_val = nil --用于升星成功Tips
	self.old_star_level  = nil
end

function AdvanceHalidomView:__delete()
	if self.halidom_model ~= nil then
		self.halidom_model:DeleteMe()
		self.halidom_model = nil
	end
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.jinjie_next_time = nil
	self.is_auto = nil
	self.mount_skill_list = nil
	self.temp_grade = nil
	self.cur_select_grade = nil
	self.old_attrs = {}
	self.skill_fight_power = nil
	self.res_id = nil
	self.old_grade_bless_val = nil 

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
end
function AdvanceHalidomView:LoadCallBack()
		self:ListenEvent("StartAdvance",BindTool.Bind(self.OnStartAdvance, self))
	self:ListenEvent("AutomaticAdvance",BindTool.Bind(self.OnAutomaticAdvance, self))
	self:ListenEvent("OnClickUse",BindTool.Bind(self.OnClickUse, self))
	self:ListenEvent("OnClickZiZhi",BindTool.Bind(self.OnClickZiZhi, self))
	-- self:ListenEvent("OnClickChengZhang",BindTool.Bind(self.OnClickChengZhang, self))
	self:ListenEvent("OnClickHuanHua",BindTool.Bind(self.OnClickHuanHua, self))
	self:ListenEvent("OnClickLastButton",BindTool.Bind(self.OnClickLastButton, self))
	self:ListenEvent("OnClickNextButton",BindTool.Bind(self.OnClickNextButton, self))
	self:ListenEvent("OnClickTopLook",BindTool.Bind(self.OnClickTopLook, self))
	self:ListenEvent("OnClickEquipBtn",BindTool.Bind(self.OnClickEquipBtn, self))
	self:ListenEvent("OnClickSkill", BindTool.Bind(self.OnClickSkill, self))

	self.mount_name = self:FindVariable("Name")
	self.mount_rank = self:FindVariable("Rank")
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

	self.halidom_model = RoleModel.New("advance_common_panel")
	self.halidom_display = self:FindObj("Display")
	self.halidom_model:SetDisplay(self.halidom_display.ui3d_display)
	self.auto_buy_toggle = self:FindObj("AutoToggle")
	self.auto_buy_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnAutoBuyToggleChange, self))

	self.start_button = self:FindObj("StartButton")
	self.up_grade_gray = self:FindVariable("UpGradeGray")
	self.auto_button = self:FindObj("AutoButton")
	self.auto_up_grade_gray = self:FindVariable("AutoUpGradeGray")
	self.gray_use_button = self:FindObj("GrayUseButton")
	self.skill_funopen = self:FindVariable("showskill_funopen")
	self.mount_skill_list = {}

	self.star_lists = {}
	for i = 1, 10 do
		self.star_lists[i] = self:FindVariable("Star"..i)
	end

	self:GetMountSkill()
end
function AdvanceHalidomView:OnClickSkill()
	AdvanceSkillCtrl.Instance:OpenView(ADVANCE_SKILL_TYPE.HALIDOM)
end

-- 开始进阶
function AdvanceHalidomView:OnStartAdvance(from_auto)
	local mount_info = HalidomData.Instance:GetHalidomInfo()
	if mount_info.show_grade == 0 then
		return
	end

	local grade_cfg = HalidomData.Instance:GetHalidomGradeCfg(mount_info.show_grade)

	local is_auto_buy_toggle = self.auto_buy_toggle.toggle.isOn
	if mount_info.show_grade >= HalidomData.Instance:GetMaxGrade() and (mount_info.star_level % 10 == 0) then
		return
	end

	if ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id) < grade_cfg.upgrade_stuff_count and not is_auto_buy_toggle then
		self.is_auto = false
		self.is_can_auto = true
		self:SetAutoButtonGray()
		-- 物品不足，弹出TIP框
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[grade_cfg.upgrade_stuff_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(grade_cfg.upgrade_stuff_id)
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

	HalidomCtrl.Instance:SendSpiritFazhenUpStar(is_auto_buy,self.is_auto)
	self.jinjie_next_time = Status.NowTime + (grade_cfg.next_time or 0.1)
end

function AdvanceHalidomView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	if self.cur_select_grade > 0 and self.cur_select_grade <= HalidomData.Instance:GetMaxGrade() then
		if self.is_auto then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnStartAdvance,self), jinjie_next_time)
		end
	end
end

function AdvanceHalidomView:SetHalidomUppGradeOptResult(result)
	self.is_can_auto = true
	--print_error("result",result)
	if 0 == result then
		self.is_auto = false
		-- local info_list = HalidomData.Instance:GetHalidomInfo()
		-- AdvanceCtrl.Instance:ShowFloatingTips(HalidomData.Instance, info_list)
		self:SetAutoButtonGray()
	else
		self:AutoUpGradeOnce()
	end
end

-- 自动进阶
function AdvanceHalidomView:OnAutomaticAdvance()
	local mount_info = HalidomData.Instance:GetHalidomInfo()

	if mount_info.show_grade == 0 then
		return
	end
	if not self.is_can_auto then
		return
	end

	local function ok_callback()
		if TipsCommonAutoView.AUTO_VIEW_STR_T["auto_mount_up"] and TipsCommonAutoView.AUTO_VIEW_STR_T["auto_mount_up"].is_auto_buy then
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
	if not self.auto_buy_toggle.toggle.isOn then
		TipsCtrl.Instance:ShowCommonAutoView("auto_mount_up", Language.Mount.AutoUpDes, ok_callback, canel_callback, true, nil, nil, nil, true)
	else
		ok_callback()
	end
end

function AdvanceHalidomView:OnClickTopLook()
	local mount_info = HalidomData.Instance:GetHalidomInfo()
	if not mount_info or not next(mount_info) then return end

	self.is_on_look = self.is_on_look == false

	self.show_on_look:SetValue(self.is_on_look)

	local btn_text = self.is_on_look and Language.Common.CancelLook or Language.Common.Look
	self.look_btn_text:SetValue(btn_text)

	local grade = self.is_on_look and HalidomData.Instance:GetMaxGrade() or self.cur_select_grade

	self:SwitchGradeAndName(grade)
end

-- 点击进阶装备
function AdvanceHalidomView:OnClickEquipBtn()
 	local is_active, activite_grade = HalidomData.Instance:IsOpenEquip()
	if not is_active then
		local name = Language.Advance.PercentAttrNameList[ADVANCE_EQUIP_TYPE.HALIDOM] or ""
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade)))
		return
	end
	ViewManager.Instance:Open(ViewName.AdvanceEquipView, TabIndex.halidom_jinjie)
end

-- 使用当前坐骑
function AdvanceHalidomView:OnClickUse()
	if self.cur_select_grade == nil then
		return
	end
	local grade_cfg = HalidomData.Instance:GetShowHalidomGradeCfg(self.cur_select_grade)
	if not grade_cfg then return end
	HalidomCtrl.Instance:SendSpiritFazhenUseImage(grade_cfg.image_id)
end

--显示上一阶形象
function AdvanceHalidomView:OnClickLastButton()
	if not self.cur_select_grade or self.cur_select_grade <= 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade - 1
	self:SetArrowState(self.cur_select_grade)
	self:SwitchGradeAndName(self.cur_select_grade)
	-- if self.mount_display ~= nil then
	-- 	self.mount_display.ui3d_display:ResetRotation()
	-- end
end

--显示下一阶形象
function AdvanceHalidomView:OnClickNextButton()
	local mount_info = HalidomData.Instance:GetHalidomInfo()
	if not self.cur_select_grade or self.cur_select_grade > mount_info.show_grade or mount_info.show_grade == 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade + 1
	self:SetArrowState(self.cur_select_grade)
	self:SwitchGradeAndName(self.cur_select_grade)

	-- if self.mount_display ~= nil then
	-- 	self.mount_display.ui3d_display:ResetRotation()
	-- end
end

-- 资质
function AdvanceHalidomView:OnClickZiZhi()
	ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "halidomzizhi", {item_id = HalidomDanId.ZiZhiDanId})
end

-- 成长
-- function AdvanceHalidomView:OnClickChengZhang()
-- 	ViewManager.Instance:Open(ViewName.TipChengZhang, nil,"mountchengzhang", {item_id = MountDanId.ChengZhangDanId})
-- end

-- 幻化
function AdvanceHalidomView:OnClickHuanHua()
	ViewManager.Instance:Open(ViewName.HalidomHuanhua)
	HalidomHuanHuaCtrl.Instance:FlushView("halidomhuanhua")
end

-- 点击坐骑技能
function AdvanceHalidomView:OnClickMountSkill(index)
	ViewManager.Instance:Open(ViewName.TipSkillUpgrade, nil, "halidomskill", {index = index - 1})
end

function AdvanceHalidomView:GetMountSkill()
	for i = 1, 4 do
		local skill = self:FindObj("MountSkill"..i)
		local icon = skill:FindObj("Image")
		local activite = skill:FindObj("ImgActivity")
		table.insert(self.mount_skill_list, {skill = skill, icon = icon, activite = activite})
	end
	for k, v in pairs(self.mount_skill_list) do
		local bundle, asset = ResPath.GetBaoJuSkillIcon(k)
		v.icon.image:LoadSprite(bundle, asset)
		v.skill.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickMountSkill, self, k))
	end
end

function AdvanceHalidomView:FlushSkillIcon()
	local skill_id_list = HalidomData.Instance:GetHalidomSkillId()
	local mount_info = HalidomData.Instance:GetHalidomInfo()
	if nil == skill_id_list then return end

	for k, v in pairs(self.mount_skill_list) do
		local skill_info = SkillData.Instance:GetSkillInfoById(skill_id_list[k].skill_id) or {}
		local skill_level = skill_info.level or 0
		local activity_info = false
		if v.icon.grayscale then
			v.icon.grayscale.GrayScale = skill_level > 0 and 0 or 255
		end
		-- if skill_level <= 0 and self.skill_arrow_list[k-1] then 					-- 没激活不显示
		-- 	self.skill_arrow_list[k-1]:SetValue(false)
		-- end
		if skill_level <= 0 and mount_info.show_grade >= 1 then
			activity_info = HalidomData.Instance:GetHalidomSkillIsActvity(k - 1, mount_info.show_grade)
		end
		if v.activite then
			v.activite:SetActive(activity_info)
		end
	end
end

-- 设置坐骑属性
function AdvanceHalidomView:SetMountAtrr()
	local mount_info = HalidomData.Instance:GetHalidomInfo()
	local image_cfg = HalidomData.Instance:GetImageCfg()
	if mount_info == nil or mount_info.mount_level == nil then
		self:SetAutoButtonGray()
		return
	end

	if mount_info.mount_level == 0 or mount_info.show_grade == 0 then
		local mount_grade_cfg = HalidomData.Instance:GetHalidomGradeCfg(1)
		self:SetAutoButtonGray()
		self.remainder_num:SetValue(ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id))
		self.gray_use_button.button.interactable = false
		return
	end
	local mount_grade_cfg = HalidomData.Instance:GetHalidomGradeCfg(mount_info.grade)

	if not mount_grade_cfg then return end

	if self.temp_grade < 0 then
		if mount_grade_cfg.grade == 0 then
			self.cur_select_grade = mount_info.show_grade
		else
			self.cur_select_grade = mount_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and mount_info.show_grade
									or HalidomData.Instance:GetHalidomGradeByUseImageId(mount_info.used_imageid)
		end
		self:SetAutoButtonGray()
		self:SetArrowState(self.cur_select_grade)
		self:SwitchGradeAndName(self.cur_select_grade)
		self.temp_grade = mount_info.show_grade
	else
		if self.temp_grade < mount_info.show_grade then
			-- local new_attr = HalidomData.Instance:GetMountAttrSum()
			-- local old_capability = CommonDataManager.GetCapabilityCalculation(self.old_attrs) + self.skill_fight_power
			-- local new_capability = CommonDataManager.GetCapabilityCalculation(new_attr) + self.skill_fight_power
			-- TipsCtrl.Instance:ShowAdvanceSucceView(image_cfg[mount_grade_cfg.image_id], new_attr, self.old_attrs, "mount_view", new_capability, old_capability)

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

			if mount_grade_cfg.show_grade == 0 then
				self.cur_select_grade = mount_info.show_grade
			else
				self.cur_select_grade = mount_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and mount_info.show_grade
										or HalidomData.Instance:GetHalidomGradeByUseImageId(mount_info.used_imageid)
			end
			self.is_auto = false
			self.res_id = -1
			self:SetAutoButtonGray()
			self:SetArrowState(self.cur_select_grade)
			self:SwitchGradeAndName(mount_info.show_grade)

			self.show_on_look:SetValue(false)
			self.look_btn_text:SetValue(Language.Common.Look)
		end
		self.temp_grade = mount_info.show_grade
	end
	self:SetUseImageButtonState(self.cur_select_grade)
	

	if self.old_grade_bless_val == nil then 
		self.old_grade_bless_val = mount_info.grade_bless_val --初始化
	end
	if self.old_star_level == nil then
		self.old_star_level = mount_info.star_level % 10
	end
	if mount_info.show_grade >= HalidomData.Instance:GetMaxGrade() and (mount_info.star_level % 10 == 0) then
		self.cur_bless:SetValue(Language.Common.YiMan)
		self:SetAutoButtonGray()
		self.exp_radio:InitValue(1)
	else
		self.cur_bless:SetValue(mount_info.grade_bless_val.."/"..mount_grade_cfg.bless_val_limit)
		self.exp_radio:SetValue(mount_info.grade_bless_val/mount_grade_cfg.bless_val_limit)
		--升星提示
		if self.old_grade_bless_val ~= mount_info.grade_bless_val then
			if(mount_info.grade_bless_val-self.old_grade_bless_val >= 100)  then
				TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordUpStarBaoji"))
			end
			self.old_grade_bless_val = mount_info.grade_bless_val
		end
		if self.old_star_level ~= mount_info.star_level % 10 then
			--升星提示
			TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordUpStarSuccess"))
			self.old_star_level = mount_info.star_level % 10
		end
	end

	local skill_capability = 0
	for i = 0, 3 do
		if HalidomData.Instance:GetSkillCfgById(i) then
			skill_capability = skill_capability + HalidomData.Instance:GetSkillCfgById(i).capability
		end
	end
	self.skill_fight_power = skill_capability
	local attr = CommonDataManager.GetAttributteByClass(mount_grade_cfg)
	self.old_attrs = attr
	local capability = CommonDataManager.GetCapabilityCalculation(attr)
	self.fight_power:SetValue(capability + skill_capability)

	self.sheng_ming:SetValue(attr.max_hp)
	self.gong_ji:SetValue(attr.gong_ji)
	self.fang_yu:SetValue(attr.fang_yu)
	self.ming_zhong:SetValue(attr.ignore_fangyu)
	self.shan_bi:SetValue(attr.shan_bi)
	self.bao_ji:SetValue(attr.ignore_fangyu)
	self.jian_ren:SetValue(attr.jian_ren)
	-- self.su_du:SetValue(attr.move_speed)

	self.need_num:SetValue("  " .. mount_grade_cfg.upgrade_stuff_count)

	local bag_num = string.format(Language.Mount.ShowGreenStr, ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id))
	if ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id) < mount_grade_cfg.upgrade_stuff_count then
		bag_num = string.format(Language.Mount.ShowRedStr, ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id))
	end
	self.remainder_num:SetValue(bag_num)
	self.prop_name:SetValue(ItemData.Instance:GetItemConfig(mount_grade_cfg.upgrade_stuff_id).name)
	-- local item_cfg = ItemData.Instance:GetItemConfig(mount_grade_cfg.upgrade_stuff_id)
	-- self.item_icon:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
	self.item_cell:SetData({item_id=mount_grade_cfg.upgrade_stuff_id, num=0, is_bind=0})

	self.jia_shang:SetValue(attr.per_pofang)
	self.jian_shang:SetValue(attr.per_mianshang)
	self.show_zizhi_redpoint:SetValue(HalidomData.Instance:IsShowZizhiRedPoint())

	self.show_huanhua_redpoint:SetValue(next(HalidomData.Instance:CanHuanhuaUpgrade()) ~= nil)
	local can_uplevel_skill_list = HalidomData.Instance:CanSkillUpLevelList()
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_arrow_list[i]:SetValue(can_uplevel_skill_list[i] ~= nil)
	end

	self:FlushStars()
end

function AdvanceHalidomView:SetArrowState(cur_select_grade)
	local mount_info = HalidomData.Instance:GetHalidomInfo()
	local max_grade = HalidomData.Instance:GetMaxGrade()
	local grade_cfg = HalidomData.Instance:GetShowHalidomGradeCfg(cur_select_grade)
	if not mount_info or not mount_info.show_grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end
	self.show_right_button:SetValue(cur_select_grade < mount_info.show_grade + 1 and cur_select_grade < max_grade)
	self.show_left_button:SetValue(grade_cfg.image_id > 1 or (mount_info.show_grade  == 1 and cur_select_grade > mount_info.show_grade))
	self:SetUseImageButtonState(cur_select_grade)
end

function AdvanceHalidomView:SetUseImageButtonState(cur_select_grade)
	local mount_info = HalidomData.Instance:GetHalidomInfo()
	local max_grade = HalidomData.Instance:GetMaxGrade()
	local grade_cfg = HalidomData.Instance:GetShowHalidomGradeCfg(cur_select_grade)

	if not mount_info or not mount_info.show_grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end
	self.show_use_button:SetValue(cur_select_grade <= mount_info.show_grade and grade_cfg.image_id ~= mount_info.used_imageid)
	self.show_use_image:SetValue(grade_cfg.image_id == mount_info.used_imageid)
end

-- 物品不足，购买成功后刷新物品数量
function AdvanceHalidomView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local mount_info = HalidomData.Instance:GetHalidomInfo()
	local mount_grade_cfg = HalidomData.Instance:GetShowHalidomGradeCfg(mount_info.show_grade)
	if mount_grade_cfg == nil or self.remainder_num == nil then
		return
	end
	local bag_num = string.format(Language.Mount.ShowGreenNum, ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id))
	if ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id) < mount_grade_cfg.upgrade_stuff_count then
		bag_num = string.format(Language.Mount.ShowRedNum, ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id))
	end
	self.remainder_num:SetValue(bag_num)
end

-- 切换坐骑阶数、名字、模型
function AdvanceHalidomView:SwitchGradeAndName(cur_select_grade)
	if cur_select_grade == nil then return end
	local mount_grade_cfg = HalidomData.Instance:GetShowHalidomGradeCfg(cur_select_grade)
	local image_cfg = HalidomData.Instance:GetImageCfg(cur_select_grade)
	local mount_res_cfg = HalidomData.Instance:GetImageCfg(mount_grade_cfg.image_id)

	if mount_grade_cfg == nil or not image_cfg and mount_res_cfg == nil then return end

	local bundle, asset = ResPath.GetAdvanceEquipIcon("halidom_name_" .. (image_cfg.title_res or 1))
	self.grade_name_img:SetAsset(bundle, asset)
	self.mount_name:SetValue(image_cfg.image_name)
	self.mount_rank:SetValue(HalidomData.Instance:GetShowHalidomGradeCfg(cur_select_grade).gradename)
	
	if image_cfg.image_id and self.res_id ~= image_cfg.image_id then
		self.halidom_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.ZHIBAO], mount_res_cfg.res_id)
		self.halidom_model:SetMainAsset(ResPath.GetBaoJuModel(image_cfg.res_id))
		self.halidom_model:SetLayer(1, 1.0)
		-- self.halidom_model:SetLoopAnimal("bj_rest", "rest_stop")
	end

end

-- 设置进阶按钮状态
function AdvanceHalidomView:SetAutoButtonGray()
	local mount_info = HalidomData.Instance:GetHalidomInfo()
	if mount_info.show_grade == nil then return end

	local max_grade = HalidomData.Instance:GetMaxGrade()

	if not mount_info or not mount_info.show_grade or mount_info.show_grade <= 0
		or (mount_info.show_grade >= max_grade and (mount_info.star_level % 10 == 0)) then
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

function AdvanceHalidomView:SetModle(is_show)
	if is_show then
		if not HalidomData.Instance:IsActiviteHalidom() then
			print_error("Mount is not activite")
			return
		end
		local mount_info = HalidomData.Instance:GetHalidomInfo()
		local used_imageid = mount_info.used_imageid
		local mount_grade_cfg = HalidomData.Instance:GetShowHalidomGradeCfg(mount_info.show_grade)
		if used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			local grade_cfg = HalidomData.Instance:GetShowHalidomGradeCfg(mount_info.show_grade)
			used_imageid = grade_cfg and grade_cfg.image_id
		end
		-- 还原到非预览状态
		self.is_on_look = false
		self.show_on_look:SetValue(false)
		self.look_btn_text:SetValue(Language.Common.Look)

		if used_imageid and mount_grade_cfg and self.cur_select_grade < 0 then
			local cur_select_grade = mount_grade_cfg.show_grade == 0 and mount_info.show_grade or HalidomData.Instance:GetHalidomGradeByUseImageId(used_imageid)
			self:SetArrowState(cur_select_grade)
			self:SwitchGradeAndName(cur_select_grade)
			self.cur_select_grade = self.cur_select_grade and cur_select_grade
		end
		-- self:SetModleRestAni()
	else
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
		self.cur_select_grade = -1
		self.temp_grade = -1
		if self.show_effect then
			self.show_effect:SetValue(false)
		end
	end
end

function AdvanceHalidomView:ClearTempData()
	self.res_id = -1
	self.cur_select_grade = -1
	self.temp_grade = -1
	self.is_auto = false
end

function AdvanceHalidomView:SetModleRestAni()
	self.timer = self.fix_show_time
	if not self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			self.timer = self.timer - UnityEngine.Time.deltaTime
			if self.timer <= 0 then
				if UIScene.role_model then
					local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
					if part then
						part:SetTrigger("rest")
					end
				end
				self.timer = self.fix_show_time
			end
		end, 0)
	end
end

function AdvanceHalidomView:SetNotifyDataChangeCallBack()
	if ViewManager.Instance:IsOpen(ViewName.Advance) then
		-- 监听系统事件
		if self.item_data_event == nil then
			self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
			ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
		end

		-- self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		-- PlayerData.Instance:ListenerAttrChange(self.data_listen)
		-- self:SetRestTime()
	end
end

function AdvanceHalidomView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.temp_grade = -1
	self.cur_select_grade = -1
	self.res_id = -1
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	-- if self.data_listen then
	-- 	PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
	-- 	self.data_listen = nil
	-- end
end

function AdvanceHalidomView:FlushStars()
	local mount_info = HalidomData.Instance:GetHalidomInfo()
	if nil == mount_info or nil == mount_info.star_level then
		return
	end
	local index = mount_info.star_level % 10

	for i = 1, 10 do
		self.star_lists[i]:SetValue(index == 0 or index >= i)
	end
end

function AdvanceHalidomView:OnAutoBuyToggleChange(isOn)
	if TipsCommonAutoView.AUTO_VIEW_STR_T["auto_mount_up"] then
		TipsCommonAutoView.AUTO_VIEW_STR_T["auto_mount_up"].is_auto_buy = isOn
	end
end

function AdvanceHalidomView:OpenCallBack()
	if self.show_effect then
		self.show_effect:SetValue(false)
	end
	if TipsCommonAutoView.AUTO_VIEW_STR_T["auto_mount_up"] then
		self.auto_buy_toggle.toggle.isOn = TipsCommonAutoView.AUTO_VIEW_STR_T["auto_mount_up"].is_auto_buy
	end
end

function AdvanceHalidomView:OnFlush()
	if not HalidomData.Instance:IsActiviteHalidom() then
		return
	end
	if self.root_node.gameObject.activeSelf then
		self:SetMountAtrr()
		self:FlushSkillIcon()
	end
	self.show_skill_redpoint:SetValue(AdvanceSkillData.Instance:ShowSkillRedPoint(ADVANCE_SKILL_TYPE.HALIDOM))
	self.show_equip_redpoint:SetValue(AdvanceData.Instance:IsEquipRedPointShow(ADVANCE_SKILL_TYPE.HALIDOM))
	self.upgrade_redpoint:SetValue(HalidomData.Instance:CanJinjie())
	local bool = OpenFunData.Instance:CheckIsHide("advanceskill")
	self.skill_funopen:SetValue(bool)
end
