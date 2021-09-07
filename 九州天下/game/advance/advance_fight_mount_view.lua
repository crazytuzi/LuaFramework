AdvanceFightMountView = AdvanceFightMountView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
function AdvanceFightMountView:__init(instance)
	self.is_auto = false
	self.is_can_auto = true
	self.jinjie_next_time = 0
	self.cur_select_grade = -1
	self.temp_grade = -1
	self.is_first_open = true
	self.old_attrs = {}
	self.res_id = -1
	self.is_on_look = false
	self.old_grade_bless_val = nil --用于升星成功Tips
	self.old_star_level  = nil
	self.mount_skill_list = {}
	local main_role = Scene.Instance:GetMainRole()
	self.mount_model:SetDisplay(self.mount_display.ui3d_display)
	self.mount_model:SetRoleResid(main_role:GetRoleResId())
end

function AdvanceFightMountView:__delete()
	if self.mount_model ~= nil then
		self.mount_model:DeleteMe()
		self.mount_model = nil
	end
	self.cur_select_grade = nil
	self.jinjie_next_time = nil
	self.is_auto = nil
	self.mount_skill_list = nil
	self.temp_grade = nil
	self.is_first_open = nil
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
	self.old_attrs = {}
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function AdvanceFightMountView:OnClickSkill()
	AdvanceSkillCtrl.Instance:OpenView()
end
function AdvanceFightMountView:LoadCallBack()
	self:ListenEvent("StartAdvance", BindTool.Bind(self.OnStartAdvance, self))
	self:ListenEvent("AutomaticAdvance", BindTool.Bind(self.OnAutomaticAdvance, self))
	self:ListenEvent("OnClickUse", BindTool.Bind(self.OnClickUse, self))
	self:ListenEvent("OnClickLastButton", BindTool.Bind(self.OnClickLastButton, self))
	self:ListenEvent("OnClickNextButton", BindTool.Bind(self.OnClickNextButton, self))
	self:ListenEvent("OnClickZiZhi", BindTool.Bind(self.OnClickZiZhi, self))
	self:ListenEvent("OnClickHuanHua", BindTool.Bind(self.OnClickHuanHua, self))
	self:ListenEvent("OnClickTopLook", BindTool.Bind(self.OnClickTopLook, self))
	self:ListenEvent("OnClickEquipBtn",BindTool.Bind(self.OnClickEquipBtn, self))
	self:ListenEvent("OnClickSkill", BindTool.Bind(self.OnClickSkill, self))

	self.mount_name = self:FindVariable("Name")
	self.mount_rank = self:FindVariable("Rank")
	self.exp_radio = self:FindVariable("ExpRadio")
	self.max_hp = self:FindVariable("HPValue")
	self.fight_power = self:FindVariable("FightPower")
	self.gong_ji = self:FindVariable("GongJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.ming_zhong = self:FindVariable("MingZhong")
	self.shan_bi = self:FindVariable("ShanBi")
	self.bao_ji = self:FindVariable("BaoJi")
	self.jian_ren = self:FindVariable("JianRen")
	self.su_du = self:FindVariable("SuDu")

	self.prop_bag_num = self:FindVariable("RemainderNum")
	self.need_num = self:FindVariable("NeedNun")
	-- self.quality = self:FindVariable("QualityBG")
	self.auto_btn_text = self:FindVariable("AutoButtonText")
	self.prop_name = self:FindVariable("PropName")
	self.cur_bless = self:FindVariable("CurBless")
	self.look_btn_text = self:FindVariable("LookBtnText")

	self.show_use_button = self:FindVariable("UseButton")
	self.show_use_image_sprite = self:FindVariable("UseImage")
	self.show_left_button = self:FindVariable("LeftButton")
	self.show_right_button = self:FindVariable("RightButton")
	self.show_zizhi_redpoint = self:FindVariable("ShowZizhiRedPoint")
	self.show_huanhua_redpoint = self:FindVariable("ShowHuanhuaRedPoint")
	self.show_effect = self:FindVariable("ShowEffect")
	self.show_on_look = self:FindVariable("IsOnLookState")
	self.item_icon = self:FindVariable("ItemIcon")

	self.mount_model = RoleModel.New()
	self.mount_display = self:FindObj("Display")
	self.auto_buy_toggle = self:FindObj("AutoToggle")
	self.auto_buy_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnAutoBuyToggleChange, self))
	self.start_button = self:FindObj("StartButton")
	self.up_grade_gray = self:FindVariable("UpGradeGray")
	self.auto_button = self:FindObj("AutoButton")
	self.auto_up_grade_gray = self:FindVariable("AutoUpGradeGray")
	self.gray_use_button = self:FindObj("GrayUseButton")
	--self.skill_funopen = self:FindVariable("showskill_funopen")
	self.skill_arrow_list = {}
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_arrow_list[i] = self:FindVariable("ShowSkillUplevel" .. i)
	end

	self.star_lists = {}
	for i = 1, 10 do
		self.star_lists[i] = self:FindVariable("Star"..i)
	end
	self:GetMountSkill()
end
-- 开始进阶
function AdvanceFightMountView:OnStartAdvance()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	local grade_cfg = FightMountData.Instance:GetMountShowGradeCfg(mount_info.show_grade)
	local is_auto_buy_toggle = self.auto_buy_toggle.toggle.isOn

	if not grade_cfg then return end

	local item_id = grade_cfg.upgrade_stuff_id
	local prop_bag_num = ItemData.Instance:GetItemNumInBagById(item_id)

	if prop_bag_num < grade_cfg.upgrade_stuff_count and not is_auto_buy_toggle then
		-- 物品不足，弹出TIP框
		self.is_auto = false
		self.is_can_auto = true
		self:SetAutoButtonGray()
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(item_id)
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
				self:OnAutomaticAdvance()
			end
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil,
			(grade_cfg.upgrade_stuff_count - ItemData.Instance:GetItemNumInBagById(item_id)))
		return
	end

	local is_auto_buy = is_auto_buy_toggle and 1 or 0

	FightMountCtrl.Instance:SendUpGradeReq(is_auto_buy, self.is_auto)
	self.jinjie_next_time = Status.NowTime + (grade_cfg.next_time or 0.1)
end

function AdvanceFightMountView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	if self.cur_select_grade and self.cur_select_grade > 0 and self.cur_select_grade <= MountData.Instance:GetMaxGrade() then
		if self.is_auto then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnStartAdvance,self), jinjie_next_time)
		end
	end
end

function AdvanceFightMountView:OnFightMountUpgradeResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self:SetAutoButtonGray()
	else
		self:AutoUpGradeOnce()
	end
end

-- 自动进阶
function AdvanceFightMountView:OnAutomaticAdvance()
	if not self.is_can_auto then
		return
	end

	local function ok_callback()
		if TipsCommonAutoView.AUTO_VIEW_STR_T["auto__fight_mount_up"] and TipsCommonAutoView.AUTO_VIEW_STR_T["auto__fight_mount_up"].is_auto_buy then
			self.auto_buy_toggle.toggle.isOn = true
		end
		self.is_auto = self.is_auto == false
		self.is_can_auto = false
		self:OnStartAdvance()
		self:SetAutoButtonGray()
	end

	local function canel_callback()
		self:SetAutoButtonGray()
	end

	if not self.auto_buy_toggle.toggle.isOn then
		TipsCtrl.Instance:ShowCommonAutoView("auto__fight_mount_up", Language.Mount.AutoUpDes, ok_callback, canel_callback, true, nil, nil, nil, true)
	else
		ok_callback()
	end
end

-- 顶级预览
function AdvanceFightMountView:OnClickTopLook()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	if not mount_info or not next(mount_info) then return end

	self.is_on_look = self.is_on_look == false

	self.show_on_look:SetValue(self.is_on_look)

	local btn_text = self.is_on_look and Language.Common.CancelLook or Language.Common.Look
	self.look_btn_text:SetValue(btn_text)

	local grade = self.is_on_look and FightMountData.Instance:GetMaxGrade() or self.cur_select_grade

	self:SwitchGradeAndName(grade)
end

-- 点击进阶装备
function AdvanceFightMountView:OnClickEquipBtn()
	local is_active, activite_grade = FightMountData.Instance:IsOpenEquip()
	if not is_active then
		local name = Language.Advance.PercentAttrNameList[TabIndex.fight_mount] or ""
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade)))
		return
	end
	ViewManager.Instance:Open(ViewName.AdvanceEquipView, TabIndex.fight_mount)
end

function AdvanceFightMountView:OnClickHuanHua()
	ViewManager.Instance:Open(ViewName.FightMountHuanHua)
	FightMountHuanHuaCtrl.Instance:FlushView("fightmounthuanhua")
end

function AdvanceFightMountView:OnClickZiZhi()
	ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "fightmountzizhi", {item_id = FightMountDanId.ZiZhiDanId})
end

-- 使用当前坐骑
function AdvanceFightMountView:OnClickUse()
	if not self.cur_select_grade then
		return
	end
	local grade_cfg = FightMountData.Instance:GetMountShowGradeCfg(self.cur_select_grade)
	if not grade_cfg then return end
	print("grade_cfg.image_id = ", grade_cfg.image_id)
	FightMountCtrl.Instance:SendUseFightMountImage(grade_cfg.image_id)
end

--显示上一阶形象
function AdvanceFightMountView:OnClickLastButton()
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
function AdvanceFightMountView:OnClickNextButton()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	--local image_cfg = FightMountData.Instance:GetMountImageCfg()
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

function AdvanceFightMountView:SwitchGradeAndName(cur_select_grade)
	if cur_select_grade == nil then return end

	local mount_grade_cfg = FightMountData.Instance:GetMountShowGradeCfg(cur_select_grade)
	local image_cfg = FightMountData.Instance:GetMountImageCfg(mount_grade_cfg.image_id)
	if mount_grade_cfg == nil or not image_cfg then return end

	local bundle, asset = nil, nil
	if math.floor(cur_select_grade / 3 + 1) >= 5 then
		 bundle, asset = ResPath.GetMountGradeQualityBG(5)
	else
		 bundle, asset = ResPath.GetMountGradeQualityBG(math.floor(cur_select_grade / 3 + 1))
	end
	-- self.quality:SetAsset(bundle, asset)

	self.mount_rank:SetValue(mount_grade_cfg.gradename)
	local color = (cur_select_grade / 3 + 1) >= 5 and 5 or math.floor(cur_select_grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..image_cfg.image_name.."</color>"
	self.mount_name:SetValue(name_str)
	if mount_grade_cfg and self.res_id ~= image_cfg.res_id then
		self.mount_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MOUNT], image_cfg.res_id)
		self.mount_model:SetFightMountResid(image_cfg.res_id)
		self.mount_model:SetTrigger("rest")
		
		self.res_id = image_cfg.res_id
	end
end

-- 设置坐骑属性
function AdvanceFightMountView:SetMountAtrr()
	local attr_list = FightMountData.Instance:GetMountAttrSum()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	local image_cfg = FightMountData.Instance:GetMountImageCfg(mount_grade_cfg.image_id)

	if not mount_info or not mount_info.show_grade or mount_info.show_grade <= 0 then
		self:SetAutoButtonGray()
		return
	end

	local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(mount_info.grade)
	if not mount_grade_cfg then return end

	if self.temp_grade < 0 then
		if mount_grade_cfg.show_grade == 0 then
			self.cur_select_grade = mount_info.show_grade
		else
			self.cur_select_grade = mount_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and mount_info.show_grade
									or FightMountData.Instance:GetMountGradeByUseImageId(mount_info.used_imageid)
		end
		self:SetAutoButtonGray()
		self:SetArrowState(self.cur_select_grade)
		self:SwitchGradeAndName(self.cur_select_grade)
		self.temp_grade = mount_info.show_grade
	else
		if self.temp_grade < mount_info.show_grade then
			-- local old_capability = CommonDataManager.GetCapability(self.old_attrs)
			-- local new_capability = CommonDataManager.GetCapability(attr_list)
			-- TipsCtrl.Instance:ShowAdvanceSucceView(image_cfg[mount_grade_cfg.image_id], attr_list, self.old_attrs, "fight_mount_view", new_capability, old_capability)

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
										or FightMountData.Instance:GetMountGradeByUseImageId(mount_info.used_imageid)
			end
			self.is_auto = false
			self:SetAutoButtonGray()
			self:SetArrowState(self.cur_select_grade)
			self:SwitchGradeAndName(mount_info.show_grade)

			self.show_on_look:SetValue(false)
			self.look_btn_text:SetValue(Language.Common.Look)
		end
		self.temp_grade = mount_info.show_grade
	end
	local cur_attr = CommonDataManager.GetAttributteByClass(mount_grade_cfg)
	self.max_hp:SetValue(cur_attr.max_hp)
	self.gong_ji:SetValue(cur_attr.gong_ji)
	self.fang_yu:SetValue(cur_attr.fang_yu)
	self.ming_zhong:SetValue(cur_attr.ming_zhong)
	self.shan_bi:SetValue(cur_attr.shan_bi)
	self.bao_ji:SetValue(cur_attr.bao_ji)
	self.jian_ren:SetValue(cur_attr.jian_ren)
	self.su_du:SetValue(cur_attr.move_speed)

	local capability = CommonDataManager.GetCapability(cur_attr)
	self.fight_power:SetValue(capability)
	self.old_attrs = cur_attr

	if self.old_grade_bless_val == nil then 
		self.old_grade_bless_val = mount_info.grade_bless_val --初始化
	end
	if self.old_star_level == nil then
		self.old_star_level = mount_info.star_level % 10
	end
	if mount_info.show_grade >= FightMountData.Instance:GetMaxGrade() then
		self.cur_bless:SetValue(Language.Common.YiMan)
		self.exp_radio:InitValue(1)
	else
		if self.is_first_open then
			self.exp_radio:InitValue(mount_info.grade_bless_val/mount_grade_cfg.bless_val_limit)
		else
			self.exp_radio:SetValue(mount_info.grade_bless_val/mount_grade_cfg.bless_val_limit)
		end
		self.cur_bless:SetValue(mount_info.grade_bless_val.."/"..mount_grade_cfg.bless_val_limit)
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

	local item_cfg = ItemData.Instance:GetItemConfig(mount_grade_cfg.upgrade_stuff_id)

	self.prop_name:SetValue(item_cfg and item_cfg.name or "")
	self.item_icon:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))

	local bag_num = string.format(Language.Mount.ShowGreenStr, "/" .. ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id))
	if ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id) < mount_grade_cfg.upgrade_stuff_count then
		bag_num = string.format(Language.Mount.ShowRedStr, "/" .. ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id))
	end
	self.prop_bag_num:SetValue(bag_num)
	self.need_num:SetValue("  " .. mount_grade_cfg.upgrade_stuff_count)
	self:SetUseImageButtonState(self.cur_select_grade)
	self.show_zizhi_redpoint:SetValue(FightMountData.Instance:IsShowZizhiRedPoint())
	self.show_huanhua_redpoint:SetValue(next(FightMountData.Instance:CanHuanhuaUpgrade()) ~= nil)
	self.is_first_open = false
	local can_uplevel_skill_list = FightMountData.Instance:CanSkillUpLevelList()
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_arrow_list[i]:SetValue(can_uplevel_skill_list[i] ~= nil)
	end

	self:FlushStars()
end


function AdvanceFightMountView:SetArrowState(cur_select_grade)
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	local max_grade = FightMountData.Instance:GetMaxGrade()
	local grade_cfg = FightMountData.Instance:GetMountShowGradeCfg(cur_select_grade)
	if not mount_info or not mount_info.show_grade or not cur_select_grade or not max_grade then
		return
	end
	self.show_right_button:SetValue(cur_select_grade < mount_info.show_grade + 1 and cur_select_grade < max_grade)
	self.show_left_button:SetValue(grade_cfg.image_id > 1 or (mount_info.show_grade  == 1 and cur_select_grade > mount_info.show_grade))
	self:SetUseImageButtonState(cur_select_grade)
end

function AdvanceFightMountView:SetUseImageButtonState(cur_select_grade)
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	local max_grade = FightMountData.Instance:GetMaxGrade()
	local grade_cfg = FightMountData.Instance:GetMountShowGradeCfg(cur_select_grade)

	if not mount_info or not mount_info.show_grade or not cur_select_grade or not max_grade then
		return
	end
	self.show_use_button:SetValue(cur_select_grade <= mount_info.show_grade and grade_cfg.image_id ~= mount_info.used_imageid)
	self.show_use_image_sprite:SetValue(grade_cfg.image_id == mount_info.used_imageid)
end

-- 物品不足，购买成功后刷新物品数量
function AdvanceFightMountView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	local mount_grade_cfg = FightMountData.Instance:GetMountShowGradeCfg(mount_info.show_grade)
	if mount_grade_cfg == nil or self.prop_bag_num == nil then
		return
	end
	local bag_num = string.format(Language.Mount.ShowGreenNum, ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id))
	if ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id) < mount_grade_cfg.upgrade_stuff_count then
		bag_num = string.format(Language.Mount.ShowRedNum, ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id))
	end
	self.prop_bag_num:SetValue(bag_num)
end

-- 设置进阶按钮状态
function AdvanceFightMountView:SetAutoButtonGray()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	if mount_info.show_grade == nil then return end

	local max_grade = FightMountData.Instance:GetMaxGrade()

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

function AdvanceFightMountView:SetModle(is_show)
	if is_show then
		if not FightMountData.Instance:IsActiviteMount() then
			return
		end
		local mount_info = FightMountData.Instance:GetFightMountInfo()
		local used_imageid = mount_info.used_imageid
		if used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			local grade_cfg = FightMountData.Instance:GetMountShowGradeCfg(mount_info.show_grade)
			used_imageid = grade_cfg and grade_cfg.image_id
		end
		local mount_grade_cfg = FightMountData.Instance:GetMountShowGradeCfg(mount_info.show_grade)

		-- 还原到非预览状态
		self.is_on_look = false
		self.show_on_look:SetValue(false)
		self.look_btn_text:SetValue(Language.Common.Look)

		if used_imageid and mount_grade_cfg and self.cur_select_grade < 0 then
			local cur_select_grade = mount_grade_cfg.show_grade == 0 and mount_info.show_grade or FightMountData.Instance:GetMountGradeByUseImageId(used_imageid)
			self:SetArrowState(cur_select_grade)
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

function AdvanceFightMountView:ClearTempData()
	self.res_id = -1
	self.cur_select_grade = -1
	self.temp_grade = -1
	self.is_auto = false
end

function AdvanceFightMountView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	self.is_first_open = true
end

function AdvanceFightMountView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.temp_grade = -1
	self.cur_select_grade = -1
	self.res_id = -1
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function AdvanceFightMountView:ResetModleRotation()
	if self.mount_display ~= nil then
		self.mount_display.ui3d_display:ResetRotation()
	end
end

function AdvanceFightMountView:FlushStars()
	local fight_mount_info = FightMountData.Instance:GetFightMountInfo()
	if nil == fight_mount_info or nil == fight_mount_info.star_level then
		return
	end
	local index = fight_mount_info.star_level % 10

	for i = 1, 10 do
		self.star_lists[i]:SetValue(index == 0 or index >= i)
	end
end

function AdvanceFightMountView:OnAutoBuyToggleChange(isOn)
	if TipsCommonAutoView.AUTO_VIEW_STR_T["auto__fight_mount_up"] then
		TipsCommonAutoView.AUTO_VIEW_STR_T["auto__fight_mount_up"].is_auto_buy = isOn
	end
end

function AdvanceFightMountView:OpenCallBack()
	if self.show_effect then
		self.show_effect:SetValue(false)
	end
	if TipsCommonAutoView.AUTO_VIEW_STR_T["auto__fight_mount_up"] then
		self.auto_buy_toggle.toggle.isOn = TipsCommonAutoView.AUTO_VIEW_STR_T["auto__fight_mount_up"].is_auto_buy
	end
end

function AdvanceFightMountView:OnFlush(param_list)
	if not FightMountData.Instance:IsActiviteMount() then
		return
	end
	if param_list == "fightmount" then
		self:SetMountAtrr()
		return
	end
	for k, v in pairs(param_list) do
		if k == "fightmount" then
			self:SetMountAtrr()
			self:FlushSkillIcon()
		end
	end
	--local bool = OpenFunData.Instance:CheckIsHide("advanceskill")
	--self.skill_funopen:SetValue(OpenFunData.Instance:CheckIsHide("advanceskill"))
end

function AdvanceFightMountView:GetMountSkill()
	for i = 1, 4 do
		local skill = self:FindObj("Skill"..i)
		local icon = skill:FindObj("Image")
		local activite = skill:FindObj("ImgActivity")
		table.insert(self.mount_skill_list, {skill = skill, icon = icon, activite = activite})
	end
	for k, v in pairs(self.mount_skill_list) do
		local bundle, asset = ResPath.GetFightMountSkillIcon(k)
		v.icon.image:LoadSprite(bundle, asset)
		v.skill.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickMountSkill, self, k))
	end
end

-- 点击技能
function AdvanceFightMountView:OnClickMountSkill(index)
	ViewManager.Instance:Open(ViewName.TipSkillUpgrade, nil, "fightmountskill", {index = index - 1})
end

function AdvanceFightMountView:FlushSkillIcon()
	local mount_skill_id_list = FightMountData.Instance:GetMountSkillId()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	if nil == mount_skill_id_list then return end
	for k, v in pairs(self.mount_skill_list) do
		local skill_info = SkillData.Instance:GetSkillInfoById(mount_skill_id_list[k].skill_id) or {}
		local skill_level = skill_info.level or 0
		local activity_info = false
		if v.icon.grayscale then
			v.icon.grayscale.GrayScale = skill_level > 0 and 0 or 255
		end
		if skill_level <= 0 and self.skill_arrow_list[k-1] then 					-- 没激活不显示
			self.skill_arrow_list[k-1]:SetValue(false)
		end
		if skill_level <= 0 and mount_info.show_grade >= 1 then
			activity_info = FightMountData.Instance:GetFightMountSkillIsActvity(k - 1, mount_info.show_grade)
		end
		if v.activite then
			v.activite:SetActive(activity_info)
		end
	end
end