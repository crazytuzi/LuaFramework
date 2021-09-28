RuneInlayView = RuneInlayView or BaseClass(BaseRender)

local EFFECT_CD = 1
function RuneInlayView:__init()
	self.effect_obj = self:FindObj("EffectObj")

	self.slot_list_obj = self:FindObj("IconList")
	self.slot_list = {}
	for i = 1, 8 do
		local slot_obj = self.slot_list_obj.transform:FindHard("Slot_" .. i)
		local slot_cell = RuneEquipCell.New(slot_obj)
		slot_cell:SetIndex(i)
		slot_cell:SetClickCallBack(BindTool.Bind(self.SlotClick, self, i))
		table.insert(self.slot_list, slot_cell)
	end
	self.special_slot = SpecialSlotCell.New(self:FindObj("SpecialRune"))
	self.title_slot = TargetTitleCell.New(self:FindObj("LittleTargetButton"))

	self.attr_type_des = self:FindVariable("AttrTypeDes")
	self.attr_des1 = self:FindVariable("AttrDes1")
	self.attr_des2 = self:FindVariable("AttrDes2")
	self.show_two_attr = self:FindVariable("ShowTwoAttr")
	self.attr_image1 = self:FindVariable("AttrImage1")
	self.attr_image2 = self:FindVariable("AttrImage2")
	self.have_select = self:FindVariable("HaveSelect")

	self.attr_name1 = self:FindVariable("AttrName1")
	self.now_attr1 = self:FindVariable("NowAttr1")
	self.next_attr1 = self:FindVariable("NextAttr1")
	self.attr_name2 = self:FindVariable("AttrName2")
	self.now_attr2 = self:FindVariable("NowAttr2")
	self.next_attr2 = self:FindVariable("NextAttr2")
	self.power = self:FindVariable("Power")
	self.total_power = self:FindVariable("TotalPower")

	self.awaken_gongji = self:FindVariable("awaken_gongji")
	self.awaken_amp = self:FindVariable("awaken_amp")
	self.awaken_fangyu = self:FindVariable("awaken_fangyu")
	self.awaken_shengming = self:FindVariable("awaken_shengming")

	self.need_str = self:FindVariable("NeedStr")
	self.is_max = self:FindVariable("IsMax")
	self.is_level_limit = self:FindVariable("IsLevelLimit")
	self.limit_level = self:FindVariable("LimitLevel")
	self.icon_image = self:FindVariable("IconImage")

	self.show_can_replace = self:FindVariable("ShowCanReplace")
	self.show_can_upgrade = self:FindVariable("ShowCanUpGrade")

	self:ListenEvent("OpenOverView", BindTool.Bind(self.OpenOverView, self))
	self:ListenEvent("ClickRelpace", BindTool.Bind(self.ClickRelpace, self))
	self:ListenEvent("ClickUpGrade", BindTool.Bind(self.ClickUpGrade, self))
	self:ListenEvent("ClickGet", BindTool.Bind(self.ClickGet, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))
	--觉醒
	self:ListenEvent("ClickAwaken", BindTool.Bind(self.ClickAwaken, self))

	--监听红点变化
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.red_point_list = {
		[RemindName.RuneAwake] = self:FindVariable("ShowCanAwaken"),
	}
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
	RemindManager.Instance:Fire(RemindName.RuneAwake)
end

function RuneInlayView:__delete()
	for k, v in ipairs(self.slot_list) do
		v:DeleteMe()
	end
	self.slot_list = {}

	if self.special_slot then
		self.special_slot:DeleteMe()
		self.special_slot = nil
	end

	if self.title_slot then
		self.title_slot:DeleteMe()
		self.title_slot = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end

function RuneInlayView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function RuneInlayView:InitView()
	GlobalTimerQuest:AddDelayTimer(function()
		self.select_index = 0
		self.old_level = 0
		self.effect_cd = 0
		self.up_select_index = -1
		self:FlushView()
	end, 0)
end

function RuneInlayView:FlushView()
	local slot_list = RuneData.Instance:GetSlotList()
	for k, v in ipairs(self.slot_list) do
		local slot_data = slot_list[k]
		if self.select_index == 0 then
			if slot_data and slot_data.type >= 0 then
				--自动选择有装备的一个格子（顺序选择）
				self.select_index = k
				v:SetHighLight(true)
			end
		end
		v:SetData(slot_data)
		v:SetCurrentSelect(self.select_index)
	end
	RuneData.Instance:SetCurrentSelect(self.select_index)
	self:FlushLeftView()
	self:FlushRightView()
	self.special_slot:FlushCell()
	self.title_slot:FlushCell()
end

function RuneInlayView:FlushAwakenAttr()
	local current_awaken_attr = RuneData.Instance:GetAwakenAttrInfoByIndex(self.select_index)
	if nil ~= current_awaken_attr then
		self.awaken_gongji:SetValue(current_awaken_attr.gongji)
		self.awaken_amp:SetValue((current_awaken_attr.add_per * 0.01).."%")
		self.awaken_fangyu:SetValue(current_awaken_attr.fangyu)
		self.awaken_shengming:SetValue(current_awaken_attr.maxhp)
	end
end

--打开符文总览界面
function RuneInlayView:OpenOverView()
	ViewManager.Instance:Open(ViewName.RunePreview)
end

--点击替换
function RuneInlayView:ClickRelpace()
	RuneCtrl.Instance:SetSlotIndex(self.select_index)
	ViewManager.Instance:Open(ViewName.RuneBag)
end

--点击升级
function RuneInlayView:ClickUpGrade()
	self.up_select_index = self.select_index
	local data = RuneData.Instance:GetSlotDataByIndex(self.select_index)
	self.old_level = data.level or 0
	local rune_level_limit_info = RuneData.Instance:GetRuneLevelLimitInfo() or {}
	local rune_level_limit = rune_level_limit_info.rune_level or 0
	if self.old_level < GameEnum.RUNE_MAX_LEVEL and rune_level_limit > self.old_level then
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_UPLEVEL, self.select_index - 1)
	end
end

function RuneInlayView:ClickGet()
	ViewManager.Instance:Open(ViewName.Rune, TabIndex.rune_treasure)
end

function RuneInlayView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(162)
end

--打开觉醒面板
function RuneInlayView:ClickAwaken()
	--如果当前未镶嵌符文
	local solt_list = RuneData.Instance:GetSlotList()
	if nil == solt_list[self.select_index] or 0 == solt_list[self.select_index].level then
		local des = string.format(Language.Rune.NoRuneTips)
		SysMsgCtrl.Instance:ErrorRemind(des)
		return
	end
	RuneData.Instance:SetCellIndex(self.select_index)
	ViewManager.Instance:Open(ViewName.RuneAwakenView)
end

function RuneInlayView:SlotClick(index, cell, data)
	if cell:IsLock() then
		local layer = RuneData.Instance:GetSlotOpenLayerByIndex(index)
		local des = string.format(Language.Rune.OpenSlotDes, layer)
		SysMsgCtrl.Instance:ErrorRemind(des)
		return
	end
	if nil == data or data.quality < GameEnum.RUNE_COLOR_WHITE then
		--没有物品时打开背包
		RuneCtrl.Instance:SetSlotIndex(index)
		ViewManager.Instance:Open(ViewName.RuneBag)
		return
	end
	self.old_level = 0
	self.effect_cd = 0
	cell.root_node.toggle.isOn = true
	if self.select_index == index then
		return
	end
	self.select_index = index
	self:FlushLeftView()
	self:FlushRightView()
end

function RuneInlayView:FlushLeftView()
	self:SetTotalPower()
end

function RuneInlayView:SetLevelDes(data)
	local type_color = RUNE_COLOR[data.quality] or RUNE_COLOR[GameEnum.RUNE_COLOR_WHITE]
	local type_name = Language.Rune.AttrTypeName[data.type] or ""
	local type_des = string.format(Language.Rune.LevelDes, type_color, type_name, data.level)
	self.attr_type_des:SetValue(type_des)
end

function RuneInlayView:SetAttrDes(data)
	local attr_type_name_0 = Language.Rune.AttrName[data.attr_type_0] or ""
	local attr_value_0 = data.add_attributes_0
	if RuneData.Instance:IsPercentAttr(data.attr_type_0) then
		attr_value_0 = (data.add_attributes_0/100.00) .. "%"
	end
	local attr_des_1 = string.format(Language.Rune.AttrDes, attr_type_name_0, attr_value_0)
	self.attr_des1:SetValue(attr_des_1)
	local asset, bundle = ResPath.GetRuneIconResPath(attr_type_name_0)
	self.attr_image1:SetAsset(asset, bundle)
	local show_two_attr = data.attr_type_1 > 0
	self.show_two_attr:SetValue(show_two_attr)
	if show_two_attr then
		local attr_type_name_1 = Language.Rune.AttrName[data.attr_type_1] or ""
		local attr_value_1 = data.add_attributes_1
		if RuneData.Instance:IsPercentAttr(data.attr_type_1) then
			attr_value_1 = (data.add_attributes_1/100.00) .. "%"
		end
		local attr_des_2 = string.format(Language.Rune.AttrDes, attr_type_name_1, attr_value_1)
		self.attr_des2:SetValue(attr_des_2)
		local asset, bundle = ResPath.GetRuneIconResPath(attr_type_name_1)
		self.attr_image2:SetAsset(asset, bundle)
	end

	-- 设置战斗力
	local capability = RuneData.Instance:GetRunePowerByIndex(self.select_index)
	self.power:SetValue(capability)
end

function RuneInlayView:SetLevelUpDes(data)
	local next_data = RuneData.Instance:GetAttrInfo(data.quality, data.type, data.level + 1)
	local attr_type_name_0 = Language.Rune.AttrName[data.attr_type_0] or ""
	local attr_value_0 = data.add_attributes_0
	if RuneData.Instance:IsPercentAttr(data.attr_type_0) then
		attr_value_0 = (data.add_attributes_0/100.00) .. "%"
	end
	self.attr_name1:SetValue(attr_type_name_0)
	self.now_attr1:SetValue(attr_value_0)
	if next(next_data) then
		local next_attr_value_0 = next_data.add_attributes_0
		if RuneData.Instance:IsPercentAttr(next_data.attr_type_0) then
			next_attr_value_0 = (next_data.add_attributes_0/100.00) .. "%"
		end
		self.next_attr1:SetValue(next_attr_value_0)
	end

	local show_two_attr = data.attr_type_1 > 0
	if show_two_attr then
		local attr_type_name_1 = Language.Rune.AttrName[data.attr_type_1] or ""
		local attr_value_1 = data.add_attributes_1
		if RuneData.Instance:IsPercentAttr(data.attr_type_1) then
			attr_value_1 = (data.add_attributes_1/100.00) .. "%"
		end
		self.attr_name2:SetValue(attr_type_name_1)
		self.now_attr2:SetValue(attr_value_1)
		if next(next_data) then
			local next_attr_value_1 = next_data.add_attributes_1
			if RuneData.Instance:IsPercentAttr(next_data.attr_type_1) then
				next_attr_value_1 = (next_data.add_attributes_1/100.00) .. "%"
			end
			self.next_attr2:SetValue(next_attr_value_1)
		end
	end
end

function RuneInlayView:FlushRightView()
	local select_index = self.select_index
	local cell = self.slot_list[select_index]
	if not cell then
		self.select_index = 0
		self.have_select:SetValue(false)
		return
	end
	local data = cell:GetData()
	if not data or not next(data) then
		self.select_index = 0
		self.have_select:SetValue(false)
		return
	end
	self.have_select:SetValue(true)
	self.is_max:SetValue(data.level >= GameEnum.RUNE_MAX_LEVEL)

	if data.level < GameEnum.RUNE_MAX_LEVEL then
		--没有超过最大等级
		local rune_level_limit_info = RuneData.Instance:GetRuneLevelLimitInfo() or {}
		local rune_level_limit = rune_level_limit_info.rune_level or 0
		self.is_level_limit:SetValue(data.level >= rune_level_limit)

		local next_rune_level_limit_info = RuneData.Instance:GetRuneLevelLimitInfo(true) or {}
		local rune_layer_limit = next_rune_level_limit_info.need_rune_tower_layer or 0
		self.limit_level:SetValue(rune_layer_limit)
	else
		self.is_level_limit:SetValue(false)
	end

	local item_id = RuneData.Instance:GetRealId(data.quality, data.type)
	if item_id > 0 then
		self.icon_image:SetAsset(ResPath.GetItemIcon(item_id))
	end

	self.show_can_replace:SetValue(cell:CanReplace())
	self.show_can_upgrade:SetValue(cell:CanUpGrade())

	--设置等级描述
	self:SetLevelDes(data)

	--设置属性描述
	self:SetAttrDes(data)

	--设置升级描述
	self:SetLevelUpDes(data)

	--设置消耗描述
	local need_jinghua = data.uplevel_need_jinghua or 0
	local jing_hua = RuneData.Instance:GetJingHua()
	--local need_str = string.format(Language.Exchange.Expend, jing_hua, need_jinghua)
	if data.level >= GameEnum.RUNE_MAX_LEVEL then
		need_str = "-- / --"
	elseif need_jinghua > jing_hua then
		need_jinghua = CommonDataManager.ConverTenNum(need_jinghua)
		jing_hua = CommonDataManager.ConverTenNum(jing_hua)
		need_str = "<color=#fe3030>"..jing_hua.."</color> / "..need_jinghua
	else
		need_jinghua = CommonDataManager.ConverTenNum(need_jinghua)
		jing_hua = CommonDataManager.ConverTenNum(jing_hua)
		need_str = "<color=#0000f1>"..jing_hua.."</color> / "..need_jinghua
	end

	self.need_str:SetValue(need_str)

	if self.up_select_index == self.select_index and self.old_level > 0 and self.old_level < data.level then
		--展示升级特效
		self:PlayUpEffect()
	end
	self:FlushAwakenAttr()
end

function RuneInlayView:PlayUpEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		EffectManager.Instance:PlayAtTransformCenter(
			"effects2/prefab/ui_x/ui_sjcg_prefab",
			"UI_sjcg",
			self.effect_obj.transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

function RuneInlayView:SetTotalPower()
	local total = RuneData.Instance:GetRuneTotalPower()

	-- 激活特殊符文加上特殊符文战力
	local is_active = RuneData.Instance:GetSpecialRuneIsActivate()
	if is_active == 1 then
		total = total + RuneData.Instance:GetSpecialRunePower()
	end

	self.total_power:SetValue(total)
end

-----------------------RuneEquipCell---------------------------
RuneEquipCell = RuneEquipCell or BaseClass(BaseRender)
function RuneEquipCell:__init()
	self.is_lock = self:FindVariable("IsLock")
	self.have_item = self:FindVariable("HaveItem")

	self.image_res = self:FindVariable("ImageRes")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.level = self:FindVariable("Level")
	self.is_show_tips = self:FindVariable("IsShowTips")
	self.tips = self:FindVariable("tips")

	self.can_replace = false
	self.can_upgrade = false

	self:ListenEvent("Click", BindTool.Bind(self.Click, self))
end

function RuneEquipCell:__delete()
end

function RuneEquipCell:FlushInit()
end

function RuneEquipCell:SetCurrentSelect(index)
	self.select_rune_index = index
end

function RuneEquipCell:Click()
	if self.clickcallback then
		self.clickcallback(self, self.data)
	end
end

function RuneEquipCell:SetClickCallBack(callback)
	self.clickcallback = callback
end

function RuneEquipCell:SetIndex(index)
	self.index = index
end

function RuneEquipCell:GetIndex()
	return self.index
end

function RuneEquipCell:ShowRedPoint(state)
	self.show_red_point:SetValue(state)
end

function RuneEquipCell:SetHighLight(state)
	self.root_node.toggle.isOn = state
end

function RuneEquipCell:SetData(data)
	if not data or not next(data) then
		return
	end
	self.data = data

	local item_id = RuneData.Instance:GetRealId(data.quality, data.type)
	if item_id > 0 then
		self.image_res:SetAsset(ResPath.GetItemIcon(item_id))
	end

	self.lock_state = RuneData.Instance:GetIsLockByIndex(self.index)
	self.is_lock:SetValue(self.lock_state)
	local openLayer = RuneData.Instance:GetSlotOpenLayerByIndex(self.index)

	self.last_cell_is_lock = RuneData.Instance:GetIsLockByIndex(self.index - 1)
	self.is_show_tips:SetValue(self.is_lock:GetBoolean() and not self.last_cell_is_lock)
	self.tips:SetValue(openLayer)

	self.have_item:SetValue(data.type >= 0)
	self.root_node.toggle.enabled = not self.lock_state and data.type >= 0

	local show_red_point = false
	self.can_replace = false
	self.can_upgrade = false
	local bag_list = RuneData.Instance:GetBagList()
	local rune_level_limit_info = RuneData.Instance:GetRuneLevelLimitInfo() or {}
	local rune_level_limit = rune_level_limit_info.rune_level or 0
	if not self.lock_state then
		if data.quality >= GameEnum.RUNE_COLOR_WHITE then
			local have_jinghua = RuneData.Instance:GetJingHua()
			local need_jinghua = data.uplevel_need_jinghua
			local level = data.level
			if level < rune_level_limit and level < RuneData.Instance:GetRuneMaxLevel() and have_jinghua >= need_jinghua then
				--存在可升级的格子
				self.can_upgrade = true
				show_red_point = true
			end
			for k, v in ipairs(bag_list) do
				if data.type == v.type and v.quality > data.quality then
					--存在可替换的格子
					self.can_replace = true
					show_red_point = true
					break
				end
			end
		end
		if not show_red_point then
			for k, v in ipairs(bag_list) do
				if not v.is_repeat and v.type ~= GameEnum.RUNE_JINGHUA_TYPE then
					if data.quality < GameEnum.RUNE_COLOR_WHITE then
						--存在未镶嵌的格子
						show_red_point = true
						break
					end
				end
			end
		end
	end

	self.show_red_point:SetValue(show_red_point)
	if self.data.level <= 0 then
		self.level:SetValue("")
	else
		self.level:SetValue("LV." .. data.level)
	end
	self:FlushInit()
end

function RuneEquipCell:GetData()
	return self.data
end

function RuneEquipCell:IsLock()
	return self.lock_state
end

function RuneEquipCell:CanReplace()
	return self.can_replace
end

function RuneEquipCell:CanUpGrade()
	return self.can_upgrade
end

-----------------------SpecialSlotCell---------------------------
SpecialSlotCell = SpecialSlotCell or BaseClass(BaseRender)
function SpecialSlotCell:__init()
	self.is_lock = self:FindVariable("IsLock")
	self.have_item = self:FindVariable("HaveItem")

	self.image_res = self:FindVariable("ImageRes")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.level = self:FindVariable("Level")
	self.is_show_tips = self:FindVariable("IsShowTips2")
	self.tips1 = self:FindVariable("tips1")
	self.tips2 = self:FindVariable("tips2")
	self.is_show_special = self:FindVariable("IsShowSpecial")

	self.can_replace = false
	self.can_upgrade = false

	self:ListenEvent("Click", BindTool.Bind(self.Click, self))
end

function SpecialSlotCell:__delete()
	self:RemoveCountDown()
end

function SpecialSlotCell:Click()
	ViewManager.Instance:Open(ViewName.SpecialRuneItemTips)
end

function SpecialSlotCell:FlushCell()
	local other_cfg = RuneData.Instance:GetOtherCfg()
	if next(other_cfg) == nil then
		return
	end
	local special_attr_cfg = RuneData.Instance:GetSpecialRuneCfg()
	if next(special_attr_cfg) == nil then
		return
	end

	local title_is_got = RuneData.Instance:GetSmallTargetCardIsGot()
	if title_is_got == false then
		self.is_show_special:SetValue(false)
		return
	end
	self.is_show_special:SetValue(true)

	local is_can_get = RuneData.Instance:GetSpecialRuneCanActived()
	local is_got = RuneData.Instance:GetSpecialRuneCardIsGot()
	local is_active = RuneData.Instance:GetSpecialRuneIsActivate()

	local tip_text = ""
	self.tips1:SetValue(special_attr_cfg.attr_percent / 100)
	local item_id = other_cfg.best_rune_item
	if item_id > 0 then
		self.image_res:SetAsset(ResPath.GetItemIcon(item_id))
	end

	-- 特效显示
	self.show_red_point:SetValue(is_active ~= 1)
	self.is_show_tips:SetValue(false)

	-- 时间倒计时
	local free_remind_time = RuneData.Instance:GetSpecialRuneRemainFreeTime()
	if free_remind_time <= 0 or is_can_get == 1 or is_got == 1 or is_active == 1 then
		self:RemoveCountDown()
		self.is_show_tips:SetValue(false)
	else
		self.is_show_tips:SetValue(true)
		self:RemoveCountDown()
		self.count_down = CountDown.Instance:AddCountDown(free_remind_time, 1, BindTool.Bind(self.FlushCountDown, self))
	end
end

function SpecialSlotCell:RemoveCountDown()
	--释放计时器
	if CountDown.Instance:HasCountDown(self.count_down) then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function SpecialSlotCell:FlushCountDown(elapse_time, total_time)
	local time_interval = total_time - elapse_time
	if time_interval > 0 then
		self.is_show_tips:SetValue(true)
		self:SetTime(time_interval)
	else
		self.is_show_tips:SetValue(false)
	end
end

--设置时间
function SpecialSlotCell:SetTime(time)
	local show_time_str = ""
	if time > 3600 * 24 then
		show_time_str = TimeUtil.FormatSecond(time, 7)
	elseif time > 3600 then
		show_time_str = TimeUtil.FormatSecond(time, 1)
	else
		show_time_str = TimeUtil.FormatSecond(time, 4)
	end
	self.tips2:SetValue(show_time_str)
end

-----------------------TargetTitleCell---------------------------
TargetTitleCell = TargetTitleCell or BaseClass(BaseRender)
function TargetTitleCell:__init()
	self.title_asset = self:FindVariable("TitleAsset")
	self.title_power = self:FindVariable("TitlePower")
	self.is_can_fetch = self:FindVariable("IsCanFetchTitle")
	self.time_limit = self:FindVariable("TimeLimit")
	self.is_show_time = self:FindVariable("IsShowTime")
	self.is_show_title = self:FindVariable("IsShowTitle")

	self:ListenEvent("ClickTitle", BindTool.Bind(self.OnClickTitle, self))
end

function TargetTitleCell:__delete()
	self:RemoveCountDown()
end

function TargetTitleCell:OnClickTitle()
	local target_title_cfg = RuneData.Instance:GetTargetTitleAllCfg()
	if target_title_cfg == nil then
		return
	end

	local is_can_get = RuneData.Instance:GetSmallTargetCanActivated()
	local is_got = RuneData.Instance:GetSmallTargetCardIsGot()

	local function fetch_callback()
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_GET_RUNE_SMALL_TARGET_TITLE_CARD)
	end

	local function buy_callback()
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_BUY_RUNE_SMALL_TARGET_TITLE_CARD)
	end

	local pet_target_info = CommonStruct.TimeLimitTitleInfo()
	pet_target_info.item_id = target_title_cfg.small_target_reward_item
	pet_target_info.cost = target_title_cfg.small_target_buy_reward_item_cost
	pet_target_info.left_time = target_title_cfg.time_stamp
	pet_target_info.can_fetch = is_can_get == 1
	pet_target_info.from_panel = "rune"
	if is_can_get == 1 and is_got == false then
		pet_target_info.call_back = fetch_callback
	else
		pet_target_info.call_back = buy_callback
	end

	TipsCtrl.Instance:ShowTimeLimitTitleView(pet_target_info)

end

function TargetTitleCell:FlushCell()
	local target_title_cfg = RuneData.Instance:GetTargetTitleAllCfg()
	if target_title_cfg == nil then
		return
	end

	local is_can_get = RuneData.Instance:GetSmallTargetCanActivated()
	local is_got = RuneData.Instance:GetSmallTargetCardIsGot()
	if is_got then
		self.is_show_title:SetValue(false)
		return
	end
	self.is_show_title:SetValue(true)

	local bundle, asset = ResPath.GetTitleIcon(target_title_cfg.title_id)
	self.title_asset:SetAsset(bundle, asset)
	self.title_power:SetValue(target_title_cfg.power or 0)
	self.is_can_fetch:SetValue(is_can_get == 1)

	-- 时间倒计时
	local free_remind_time = RuneData.Instance:GetSpecialRuneRemainFreeTime()
	if free_remind_time <= 0 or is_can_get == 1 or is_got then
		self:RemoveCountDown()
		self.is_show_time:SetValue(false)
	else
		self.is_show_time:SetValue(true)
		self:RemoveCountDown()
		self.count_down = CountDown.Instance:AddCountDown(free_remind_time, 1, BindTool.Bind(self.FlushCountDown, self))
	end
end

function TargetTitleCell:RemoveCountDown()
	--释放计时器
	if CountDown.Instance:HasCountDown(self.count_down) then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function TargetTitleCell:FlushCountDown(elapse_time, total_time)
	local time_interval = total_time - elapse_time
	if time_interval > 0 then
		self.is_show_time:SetValue(true)
		self:SetTime(time_interval)
	else
		self.is_show_time:SetValue(false)
	end
end

--设置时间
function TargetTitleCell:SetTime(time)
	local show_time_str = ""
	if time > 3600 * 24 then
		show_time_str = TimeUtil.FormatSecond(time, 7)
	elseif time > 3600 then
		show_time_str = TimeUtil.FormatSecond(time, 1)
	else
		show_time_str = TimeUtil.FormatSecond(time, 4)
	end
	self.time_limit:SetValue(show_time_str)
end