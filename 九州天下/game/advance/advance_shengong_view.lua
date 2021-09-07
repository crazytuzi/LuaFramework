
AdvanceShengongView = AdvanceShengongView or BaseClass(BaseRender)

function AdvanceShengongView:__init(instance)
	self.is_auto = false
	self.is_can_auto = true
	self.jinjie_next_time = 0
	self.grade = nil
	self.old_attrs = {}
	self.skill_fight_power = 0
	self.is_in_preview = false

	self.old_grade_bless_val = nil --用于升星提示Tips
	self.old_star_level  = nil
end

function AdvanceShengongView:__delete()
	self.index = nil
	self.grade = nil
	self.jinjie_next_time = nil
	self.is_auto = nil
	self.shengong_skill_list = nil
	self.old_attrs = {}
	self.skill_fight_power = nil
	self.old_grade_bless_val = nil

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	-- if self.left_model then
	-- 	self.left_model:DeleteMe()
	-- 	self.left_model = nil
	-- end
	if self.right_model then
		self.right_model:DeleteMe()
		self.name = nil
	end
	if self.right_top_model then
		self.right_top_model:DeleteMe()
		self.right_top_model = nil
	end
end
function AdvanceShengongView:LoadCallBack()
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

	self.shengong_name = self:FindVariable("Name")
	self.shengong_rank = self:FindVariable("Rank")
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
	self.show_zizhi_redpoint = self:FindVariable("ShowZizhiRedPoint")
	self.show_huanhua_redpoint = self:FindVariable("ShowHuanhuaRedPoint")
	self.show_equip_redpoint = self:FindVariable("ShowEquipRedPoint")
	self.show_skill_redpoint = self:FindVariable("ShowSkillRedPoint")
	self.upgrade_redpoint = self:FindVariable("UpGradeRedPoint")
	self.show_star = self:FindVariable("show_star")
	self.show_auto_buy = self:FindVariable("show_auto_buy")
	self.show_cancel_btn = self:FindVariable("show_cancel_btn")
	self.show_star:SetValue(ShengongData.Instance:GetShengongInfo().show_grade < ShengongData.Instance:GetMaxGrade())	
	self.skill_arrow_list = {}
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_arrow_list[i] = self:FindVariable("ShowSkillUplevel" .. i)
	end
	-- self.item_icon = self:FindVariable("ItemIcon")
	self.grade_name_img = self:FindVariable("GradeName")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

	self.left_display = self:FindObj("ShengongDisplay")
	local ui_foot = self:FindObj("UI_Foot")
	local foot_camera = self:FindObj("FootCamera")
	self.skill_funopen = self:FindVariable("showskill_funopen")
	self.foot_parent = {}
	for i = 1, 3 do
		self.foot_parent[i] = self:FindObj("Foot_" .. i)
	end
	local camera = foot_camera:GetComponent(typeof(UnityEngine.Camera))
	local random_num = math.random(100, 9999)
	if not IsNil(camera) then
		-- self.left_display.ui3d_display:Display(ui_foot.gameObject, camera)
		self.left_display.ui3d_display:DisplayPerspectiveWithOffset(ui_foot.gameObject, Vector3(random_num, random_num, random_num), Vector3(0, 14, 1.8), Vector3(90, 0, 0))
		self.left_display.raw_image.raycastTarget = false
	end

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
	self.shengong_skill_list = {}

	self.star_lists = {}
	for i = 1, 10 do
		self.star_lists[i] = self:FindVariable("Star"..i)
	end
	self:GetShengongSkill()
	self:InitRoleModel()
end
function AdvanceShengongView:OnClickSkill()
	AdvanceSkillCtrl.Instance:OpenView(ADVANCE_SKILL_TYPE.FOOT)
end

-- 提升一次
function AdvanceShengongView:OnStartAdvance(from_auto)
	if nil == self.cur_select_prop_index then return end
	local is_auto_buy_toggle = self.auto_buy_toggle.toggle.isOn
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	if shengong_info.grade == nil then return end
	local item_id = ShengongData.Instance:GetShengongGradeCfg(shengong_info.grade).upgrade_stuff_id
	local num = ItemData.Instance:GetItemNumInBagById(item_id)

	if shengong_info.show_grade >= ShengongData.Instance:GetMaxGrade() and (shengong_info.star_level % 10 == 0) then
		return
	end
	
	if num <= 0 and not is_auto_buy_toggle then
		-- 物品不足，弹出TIP框
		self.is_auto = false
		self.is_can_auto = true
		self:SetAutoButtonGray()
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
		if item_cfg == nil then
			-- TipsCtrl.Instance:ShowSystemMsg(Language.Exchange.NotEnoughItem)
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
	-- 	if not ShengongData.Instance:GetIsRichMoneyUpLevel(item_id) then
	-- 		TipsCtrl.Instance:ShowLackDiamondView()
	-- 		return
	-- 	end
	-- end
	-- self.cur_select_prop_index - 1,
	ShengongCtrl.Instance:SendUpGradeReq(is_auto_buy, self.is_auto)
	self.jinjie_next_time = Status.NowTime + 0.1
end

function AdvanceShengongView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	if self.cur_select_grade > 0 and self.cur_select_grade <= ShengongData.Instance:GetMaxGrade() then
		if self.is_auto then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnStartAdvance, self), jinjie_next_time)
		end
	end
end

function AdvanceShengongView:FlushView()
	-- self:OnFlush("shengong")
	self:SetAutoButtonGray()
	self:FlushItemNameText()
	self:SetPropItemCellsData()
	-- self:OpenCallBack()
	-- self.cur_select_grade = ShengongData.Instance:GetShengongInfo().show_grade
	-- self:SetModle(true, self.cur_select_grade)
end

function AdvanceShengongView:ShengongUpGradeResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
--		local info_list = ShengongData.Instance:GetShengongInfo()
--		AdvanceCtrl.Instance:ShowFloatingTips(ShengongData.Instance, info_list)
		self:SetAutoButtonGray()
	else
		self:AutoUpGradeOnce()
	end
end

-- 一键提升
function AdvanceShengongView:OnAutomaticAdvance()
	if nil == self.cur_select_prop_index then return end
	local shengong_info = ShengongData.Instance:GetShengongInfo()

	if shengong_info.show_grade == 0 then
		return
	end

	if not self.is_can_auto then
		return
	end

	local function ok_callback()
		if TipsCommonAutoView.AUTO_VIEW_STR_T["auto_shengong_up"] and TipsCommonAutoView.AUTO_VIEW_STR_T["auto_shengong_up"].is_auto_buy then
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
		TipsCtrl.Instance:ShowCommonAutoView("auto_shengong_up", Language.Mount.AutoUpDes, ok_callback, canel_callback, true, nil, nil, nil, true)
	end
end

-- 使用当前坐骑
function AdvanceShengongView:OnClickUse()
	if self.cur_select_grade == nil then
		return
	end
	local grade_cfg = ShengongData.Instance:GetShengongShowGradeCfg(self.cur_select_grade)
	if not grade_cfg then return end
	ShengongCtrl.Instance:SendUseShengongImage(grade_cfg.image_id)
end

--显示上一阶形象
function AdvanceShengongView:OnClickLastButton()
	if not self.cur_select_grade or self.cur_select_grade <= 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade - 1
	self:SetArrowState(self.cur_select_grade)
	local image_id = ShengongData.Instance:GetShengongShowGradeCfg(self.cur_select_grade).image_id
	local color = (self.cur_select_grade / 3 + 1) >= 5 and 5 or math.floor(self.cur_select_grade / 3 + 1)
	local cfg = ShengongData.Instance:GetShengongImageCfg(image_id)
	local str = cfg ~= nil and cfg.image_name or ""
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">".. str .."</color>"
	self.shengong_name:SetValue(name_str)
	self:SwitchGradeAndName(self.cur_select_grade)
	-- if self.left_display ~= nil then
	-- 	self.left_display.ui3d_display:ResetRotation()
	-- end
end

--显示下一阶形象
function AdvanceShengongView:OnClickNextButton()
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	if not self.cur_select_grade or self.cur_select_grade > shengong_info.show_grade or shengong_info.show_grade == 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade + 1
	self:SetArrowState(self.cur_select_grade)
	local image_id = ShengongData.Instance:GetShengongShowGradeCfg(self.cur_select_grade).image_id
	local color = (self.cur_select_grade / 3 + 1) >= 5 and 5 or math.floor(self.cur_select_grade / 3 + 1)
	local cfg = ShengongData.Instance:GetShengongImageCfg(image_id)
	local str = cfg ~= nil and cfg.image_name or ""
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">".. str .."</color>"
	self.shengong_name:SetValue(name_str)
	self:SwitchGradeAndName(self.cur_select_grade)
	-- if self.left_display ~= nil then
	-- 	self.left_display.ui3d_display:ResetRotation()
	-- end
end

function AdvanceShengongView:OnClickCancelButton()
	ShengongCtrl.SendUnUseShengongImage(image_id)
	local shengong_data = ShengongData.Instance
	self.cur_select_grade = shengong_data:GetShengongInfo().show_grade
	local grade_cfg = shengong_data:GetShengongShowGradeCfg(self.cur_select_grade)
	if not grade_cfg then return end
	ShengongCtrl.Instance:SendUseShengongImage(grade_cfg.image_id)
end

function AdvanceShengongView:OnPreviewClick(is_click)
	if is_click then
		local shengong_data = ShengongData.Instance
		local grade = shengong_data:GetMaxGrade()
		local name_str = shengong_data:GetColorName(grade)
		self.shengong_name:SetValue(name_str)
		self:SetModle(true, grade)
		self:SwitchGradeAndName(grade, true)
		self.preview_text:SetValue(Language.Common.CancelLook)
		self.show_preview:SetValue(true)
	else
		local shengong_data = ShengongData.Instance
		self.cur_select_grade = shengong_data:GetShengongInfo().show_grade
		self.is_in_preview = true
		self.preview_text:SetValue(Language.Common.Look)
		local name_str = shengong_data:GetColorName(self.cur_select_grade)
		self.shengong_name:SetValue(name_str)
		self:SetModle(true, self.cur_select_grade)
		self:SetArrowState(self.cur_select_grade)
		self:SwitchGradeAndName(self.cur_select_grade, true)
		self.show_preview:SetValue(false)
	end
end

-- 点击进阶装备
function AdvanceShengongView:OnClickEquipBtn()
	local is_active, activite_grade = ShengongData.Instance:IsOpenEquip()
	if not is_active then
		local name = Language.Advance.PercentAttrNameList[ADVANCE_EQUIP_TYPE.FOOT] or ""
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade)))
		return
	end
	ViewManager.Instance:Open(ViewName.AdvanceEquipView, TabIndex.shengong_jinjie)
end

function AdvanceShengongView:SwitchGradeAndName(index, no_flush_modle)
	if index == nil then return end

	local shengong_grade_cfg = ShengongData.Instance:GetShengongShowGradeCfg(index)
	local image_list = ShengongData.Instance:GetShengongImageCfg(index) or {}
	local image_cfg = ShengongData.Instance:GetShengongImageCfg()
	if shengong_grade_cfg == nil then return end
	local bundle, asset = ResPath.GetAdvanceEquipIcon("foot_name_" .. (image_list.title_res or 1))
	self.grade_name_img:SetAsset(bundle, asset)
	self.shengong_rank:SetValue(shengong_grade_cfg.gradename)
	if not no_flush_modle then
		self:SetModle(true)
	end
end

-- 资质
function AdvanceShengongView:OnClickZiZhi()
	ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "shengongzizhi", {item_id = ShengongDanId.ZiZhiDanId})
end

-- 成长
-- function AdvanceShengongView:OnClickChengZhang()
-- 	ViewManager.Instance:Open(ViewName.TipChengZhang, nil,"shengongchengzhang", {item_id = ShengongDanId.ChengZhangDanId})
-- end

-- 幻化
function AdvanceShengongView:OnClickHuanHua()
	ViewManager.Instance:Open(ViewName.ShengongHuanHua)
	ShengongHuanHuaCtrl.Instance:FlushView("shengonghuanhua")
end

-- 点击坐骑技能
function AdvanceShengongView:OnClickShengongSkill(index)
	ViewManager.Instance:Open(ViewName.TipSkillUpgrade, nil, "shengongskill", {index = index - 1})
end

function AdvanceShengongView:GetShengongSkill()
	for i = 1, 4 do
		local skill = self:FindObj("ShengongSkill"..i)
		local icon = skill:FindObj("Image")
		local activite = skill:FindObj("ImgActivity")
		table.insert(self.shengong_skill_list, {skill = skill, icon = icon, activite = activite})
	end
	for k, v in pairs(self.shengong_skill_list) do
		local bundle, asset = ResPath.GetShengongSkillIcon(k)
		v.icon.image:LoadSprite(bundle, asset)
		v.skill.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickShengongSkill, self, k))
	end
end

function AdvanceShengongView:FlushSkillIcon()
	local skill_id_list = ShengongData.Instance:GetShengongSkillId()
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	if nil == skill_id_list then return end

	for k, v in pairs(self.shengong_skill_list) do
		local skill_info = SkillData.Instance:GetSkillInfoById(skill_id_list[k].skill_id) or {}
		local skill_level = skill_info.level or 0
		local activity_info = false
		if v.icon.grayscale then
			v.icon.grayscale.GrayScale = skill_level > 0 and 0 or 255
		end
		-- if skill_level <= 0 and self.skill_arrow_list[k-1] then 					-- 没激活不显示
		-- 	self.skill_arrow_list[k-1]:SetValue(false)
		-- end
		if skill_level <= 0 and shengong_info.show_grade >= 1 then
			activity_info = ShengongData.Instance:GetShengongSkillIsActvity(k - 1, shengong_info.show_grade)
		end
		if v.activite then
			v.activite:SetActive(activity_info)
		end
	end
end

-- 设置提升物品格子数据
function AdvanceShengongView:SetPropItemCellsData()
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	if shengong_info.grade == nil then return end
	local item_id = ShengongData.Instance:GetShengongGradeCfg(shengong_info.grade).upgrade_stuff_id
	if item_id then
		local data = {}
		data.item_id = item_id
		data.num = ItemData.Instance:GetItemNumInBagById(item_id)

		-- if self.cur_select_prop_index and (not self.item_cells[self.cur_select_prop_index]:GetData().num or
		-- 	(self.item_cells[self.cur_select_prop_index]:GetData().num and self.item_cells[self.cur_select_prop_index]:GetData().num <= 0))
		--   and not self.is_auto then
		-- 	self.cur_select_prop_index = nil
		-- end

		-- for k, v in pairs(self.item_cells) do
		-- 	if v:GetData().num and v:GetData().num > 0 then
		-- 		if not self.cur_select_prop_index then
		-- 			self.cur_select_prop_index = k
		-- 		end
		-- 	elseif v:GetToggleIsOn() then
		-- 		if not self.cur_select_prop_index then
		-- 			self.cur_select_prop_index = k
		-- 		end
		-- 	end
		-- end
		self.cur_select_prop_index = self.cur_select_prop_index or 1
		-- if self.cur_select_prop_index then
		-- 	self.item_cells[self.cur_select_prop_index]:SetHighLight(true)
		-- end
		-- self:OnSelectPropItem(self.item_cells[self.cur_select_prop_index], self.cur_select_prop_index)
		self.show_auto_buy:SetValue(self.cur_select_prop_index == 1)
	end
	self:FlushItemNameText()
end

function AdvanceShengongView:OnSelectPropItem(cell, index)
	self.cur_select_prop_index = index
	cell:SetHighLight(self.cur_select_prop_index == index)
	local prop_cfg = ShengongData.Instance:GetShengongUpStarPropCfg()
	local item_id = prop_cfg[index] and prop_cfg[index].up_star_item_id
	local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]

	self.auto_buy_toggle.toggle.interactable = item_cfg ~= nil
	self.show_auto_buy:SetValue(self.cur_select_prop_index == 1)
end

function AdvanceShengongView:FlushItemNameText()
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	local item_id = ShengongData.Instance:GetShengongGradeCfg(shengong_info.grade)
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
function AdvanceShengongView:SetShengongAtrr()
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	if shengong_info == nil or shengong_info.shengong_level == nil then
		self:SetAutoButtonGray()
		return
	end
	if shengong_info.shengong_level == 0 or shengong_info.show_grade == 0 then
		local shengong_grade_cfg = ShengongData.Instance:GetShengongGradeCfg(1)
		self:SetAutoButtonGray()
		return
	end
	local shengong_grade_cfg = ShengongData.Instance:GetShengongGradeCfg(shengong_info.grade)
	if not shengong_grade_cfg then return end
	local image_cfg = ShengongData.Instance:GetShengongImageCfg(shengong_grade_cfg.image_id)

	if not self.temp_grade then
		if shengong_grade_cfg.show_grade == 0 then
			self.cur_select_grade = shengong_info.show_grade
		else
			self.cur_select_grade = shengong_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and shengong_info.show_grade
									or ShengongData.Instance:GetShengongGradeByUseImageId(shengong_info.used_imageid)
		end

		self:SetAutoButtonGray()
		self:SetArrowState(self.cur_select_grade, true)
		self:SwitchGradeAndName(self.cur_select_grade, true)
		self.temp_grade = shengong_info.show_grade
	else
		if self.temp_grade < shengong_info.show_grade then
		
			-- 进阶成功提示
			TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordAdvenceSuccess"))

			local new_attr = ShengongData.Instance:GetShengongAttrSum(nil, true)
			local old_capability = CommonDataManager.GetCapability(self.old_attrs) + self.skill_fight_power
			local new_capability = CommonDataManager.GetCapability(new_attr) + self.skill_fight_power
			TipsCtrl.Instance:ShowAdvanceSucceView(image_cfg, new_attr, self.old_attrs, "shengong_view", new_capability, old_capability)

			if shengong_grade_cfg.show_grade == 0 then
				self.cur_select_grade = shengong_info.show_grade
			else
				self.cur_select_grade = shengong_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and shengong_info.show_grade
										or ShengongData.Instance:GetShengongGradeByUseImageId(shengong_info.used_imageid)
			end
			self.is_auto = false
			self:SetAutoButtonGray()
			self:SetArrowState(self.cur_select_grade, true)
			self:SwitchGradeAndName(shengong_info.show_grade, true)
		end
		self.temp_grade = shengong_info.show_grade
	end
	self:SetUseImageButtonState(self.cur_select_grade, true)

	-- local shengong_up_level_cfg = ShengongData.Instance:GetShengongUpStarCfgByLevel(shengong_info.star_level)

	if self.old_grade_bless_val == nil then 
		self.old_grade_bless_val = shengong_info.grade_bless_val --初始化
	end
	if self.old_star_level == nil then
		self.old_star_level = shengong_info.star_level % 10
	end
	if shengong_info.show_grade >= ShengongData.Instance:GetMaxGrade() and (shengong_info.star_level % 10 == 0) then
		self:SetAutoButtonGray()
		self.cur_bless:SetValue(Language.Common.YiMan)
		self.exp_radio:InitValue(1)
	else
		self.cur_bless:SetValue(shengong_info.grade_bless_val.."/"..shengong_grade_cfg.bless_val_limit)
		if shengong_grade_cfg then
			self.exp_radio:SetValue(shengong_info.grade_bless_val/shengong_grade_cfg.bless_val_limit)
		end
		--升星提示
		if self.old_grade_bless_val ~= shengong_info.grade_bless_val then
			if(shengong_info.grade_bless_val-self.old_grade_bless_val >= 100)  then
				TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordUpStarBaoji"))
			end
			self.old_grade_bless_val = shengong_info.grade_bless_val
		end
		if self.old_star_level ~= shengong_info.star_level % 10 then
			--升星提示
			TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordUpStarSuccess"))
			self.old_star_level = shengong_info.star_level % 10
		end
	end

	local skill_capability = 0
	for i = 0, 3 do
		if ShengongData.Instance:GetShengongSkillCfgById(i) then
			skill_capability = skill_capability + ShengongData.Instance:GetShengongSkillCfgById(i).capability
		end
	end
	self.skill_fight_power = skill_capability
	local attr = CommonDataManager.GetAttributteByClass(shengong_grade_cfg)
	local capability = CommonDataManager.GetCapability(attr)
	self.old_attrs = attr
	self.fight_power:SetValue(capability)

	self.sheng_ming:SetValue(attr.max_hp)
	self.gong_ji:SetValue(attr.gong_ji)
	self.fang_yu:SetValue(attr.fang_yu)
	self.ming_zhong:SetValue(attr.hurt_increase)
	self.shan_bi:SetValue(attr.shan_bi)
	self.bao_ji:SetValue(attr.bao_ji)
	self.jian_ren:SetValue(attr.jian_ren)

	self.jia_shang:SetValue(attr.per_pofang)
	self.jian_shang:SetValue(attr.per_mianshang)
	self.show_zizhi_redpoint:SetValue(ShengongData.Instance:IsShowZizhiRedPoint())
	-- self.show_chengzhang_redpoint:SetValue(ShengongData.Instance:IsShowChengzhangRedPoint())
	self.show_huanhua_redpoint:SetValue(next(ShengongData.Instance:CanHuanhuaUpgrade()) ~= nil)
	local can_uplevel_skill_list = ShengongData.Instance:CanSkillUpLevelList()
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_arrow_list[i]:SetValue(can_uplevel_skill_list[i] ~= nil)
	end

	self:FlushStars()
	self.show_star:SetValue(ShengongData.Instance:GetShengongInfo().show_grade < ShengongData.Instance:GetMaxGrade())
	local image_id = ShengongData.Instance:GetShengongShowGradeCfg(self.cur_select_grade).image_id
	local color = (self.cur_select_grade / 3 + 1) >= 5 and 5 or math.floor(self.cur_select_grade / 3 + 1)
	local cfg = ShengongData.Instance:GetShengongImageCfg(image_id)
	local str = cfg ~= nil and cfg.image_name or ""
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">".. str .."</color>"
	self.shengong_name:SetValue(name_str)
end

function AdvanceShengongView:SetArrowState(cur_select_grade, no_flush_modle)
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	local max_grade = ShengongData.Instance:GetMaxGrade()
	local grade_cfg = ShengongData.Instance:GetShengongShowGradeCfg(cur_select_grade)
	if not shengong_info or not shengong_info.show_grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end

	self.show_right_button:SetValue(cur_select_grade < shengong_info.show_grade + 1 and cur_select_grade < max_grade)
	self.show_left_button:SetValue(grade_cfg.image_id > 1 or (shengong_info.show_grade == 1 and cur_select_grade > shengong_info.show_grade))
	self:SetUseImageButtonState(cur_select_grade, no_flush_modle)
end

function AdvanceShengongView:SetUseImageButtonState(cur_select_grade, no_flush_modle)
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	local max_grade = ShengongData.Instance:GetMaxGrade()
	local grade_cfg = ShengongData.Instance:GetShengongShowGradeCfg(cur_select_grade)

	if not shengong_info or not shengong_info.show_grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end
	local is_show_cancel_btn = ShengongData.Instance:IsShowCancelHuanhuaBtn(cur_select_grade)
	self.show_use_button:SetValue(cur_select_grade <= shengong_info.show_grade and grade_cfg.image_id ~= shengong_info.used_imageid and not is_show_cancel_btn)
	self.show_use_image:SetValue(grade_cfg.image_id == shengong_info.used_imageid)
	self.show_cancel_btn:SetValue(is_show_cancel_btn)
	self:SwitchGradeAndName(self.cur_select_grade, no_flush_modle)
end

-- 物品不足，购买成功后刷新物品数量
function AdvanceShengongView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	if nil == shengong_info.show_grade then
		return
	end
	self:SetPropItemCellsData()
end

-- 设置进阶按钮状态
function AdvanceShengongView:SetAutoButtonGray()
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	if shengong_info.show_grade == nil then return end

	local max_grade = ShengongData.Instance:GetMaxGrade()

	if not shengong_info or not shengong_info.show_grade or shengong_info.show_grade <= 0
		or shengong_info.show_grade >= max_grade and (shengong_info.star_level % 10 == 0) then
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

function AdvanceShengongView:SetModle(is_show, grade, flush_flag)
	if is_show then
		if not ShengongData.Instance:IsActiviteShengong() then
			return
		end

		local info = {}
		info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
		if grade then
			self.cur_select_grade = grade
		else
			if self.cur_select_grade == nil or self.is_in_preview == true or flush_flag then
				self.is_in_preview = false
				self.cur_select_grade = ShengongData.Instance:GetShengongInfo().used_imageid
			end
		end

		info.weapon_res_id = ShengongData.Instance:GetShowShengongRes(self.cur_select_grade)
		self:Set3DModel(self.cur_select_grade)
	end
end

function AdvanceShengongView:Set3DModel(cur_select_grade)
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end

	local res_cfg = ShengongData.Instance:GetShengongImageCfg(cur_select_grade)
	local res_id = res_cfg and res_cfg.res_id or 1
	for i = 1, 3 do
		local bundle, asset = ResPath.GetFootEffec("Foot_" .. res_id)
		PrefabPool.Instance:Load(AssetID(bundle, asset), function (prefab)
			if nil == prefab then
				return
			end
			if self.foot_parent[i] then
				local parent_transform = self.foot_parent[i].transform
				for j = 0, parent_transform.childCount - 1 do
					GameObject.Destroy(parent_transform:GetChild(j).gameObject)
				end
				local obj = GameObject.Instantiate(prefab)
				local obj_transform = obj.transform
				obj_transform:SetParent(parent_transform, false)
				PrefabPool.Instance:Free(prefab)
			end
		end)
	end
end

-- 初始化人物模型处理函数
function AdvanceShengongView:InitRoleModel()
	-- if not self.left_model and self.left_display then
	-- 	self.left_model = RoleModel.New()
	-- 	self.left_model:SetDisplay(self.left_display.ui3d_display)
	-- end
end

function AdvanceShengongView:RoleInfoCallBack(role_id, protocol)
	
end

function AdvanceShengongView:CancelTheQuest()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.upgrade_timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	self.is_auto = false
	self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
end

function AdvanceShengongView:CalToShowAnim()
	self.timer = FIX_SHOW_TIME
	local part = nil
	-- if UIScene.role_model then
	-- 	part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
	-- end
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		self.timer = self.timer - UnityEngine.Time.deltaTime
		if self.timer <= 0 then
			if part then
				-- part:SetTrigger("attack1")
			end
			self.timer = FIX_SHOW_TIME
		end
	end, 0)
end

function AdvanceShengongView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function AdvanceShengongView:RemoveNotifyDataChangeCallBack()
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

function AdvanceShengongView:FlushStars()
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	if nil == shengong_info or nil == shengong_info.star_level then
		return
	end

	local index = shengong_info.star_level

	for i = 1, 10 do
		self.star_lists[i]:SetValue(index == 0 or index >= i)
	end
end

function AdvanceShengongView:OnAutoBuyToggleChange(isOn)
	if TipsCommonAutoView.AUTO_VIEW_STR_T["auto_shengong_up"] then
		TipsCommonAutoView.AUTO_VIEW_STR_T["auto_shengong_up"].is_auto_buy = isOn
	end
end

function AdvanceShengongView:OpenCallBack()
	if TipsCommonAutoView.AUTO_VIEW_STR_T["auto_shengong_up"] then
		self.auto_buy_toggle.toggle.isOn = TipsCommonAutoView.AUTO_VIEW_STR_T["auto_shengong_up"].is_auto_buy
	end
end

function AdvanceShengongView:CancelPreviewToggle()
	if self.preview_go.toggle.isOn then
		self.preview_go.toggle.isOn = false
	end
end

function AdvanceShengongView:OnFlush(param_list)
	if not ShengongData.Instance:IsActiviteShengong() then
		return
	end

	self:SetPropItemCellsData()
	self:SetShengongAtrr()
	self:FlushSkillIcon()
	self:SetModle(true)
	self.show_skill_redpoint:SetValue(AdvanceSkillData.Instance:ShowSkillRedPoint(ADVANCE_SKILL_TYPE.FOOT))
	self.show_equip_redpoint:SetValue(AdvanceData.Instance:IsEquipRedPointShow(ADVANCE_SKILL_TYPE.FOOT))
	self.upgrade_redpoint:SetValue(ShengongData.Instance:CanJinjie())
	local bool = OpenFunData.Instance:CheckIsHide("advanceskill")
	self.skill_funopen:SetValue(bool)
end
