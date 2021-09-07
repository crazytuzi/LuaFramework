RuneInlayView = RuneInlayView or BaseClass(BaseRender)

local EFFECT_CD = 1
function RuneInlayView:__init()

end

function RuneInlayView:__delete()
	for k, v in ipairs(self.slot_list) do
		v:DeleteMe()
	end
	self.slot_list = {}

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end

function RuneInlayView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function RuneInlayView:LoadCallBack()
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

	self.attr_type_des = self:FindVariable("AttrTypeDes")
	self.show_two_attr = self:FindVariable("ShowTwoAttr")
	self.have_select = self:FindVariable("HaveSelect")

	self.attr_name1 = self:FindVariable("AttrName1")
	self.now_attr1 = self:FindVariable("NowAttr1")
	self.next_attr1 = self:FindVariable("NextAttr1")
	self.attr_name2 = self:FindVariable("AttrName2")
	self.now_attr2 = self:FindVariable("NowAttr2")
	self.next_attr2 = self:FindVariable("NextAttr2")
	self.power = self:FindVariable("Power")

	self.awaken_gongji = self:FindVariable("awaken_gongji")
	self.awaken_amp = self:FindVariable("awaken_amp")
	self.awaken_fangyu = self:FindVariable("awaken_fangyu")
	self.awaken_shengming = self:FindVariable("awaken_shengming")

	self.need_str = self:FindVariable("NeedStr")
	self.is_max = self:FindVariable("IsMax")
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
end

function RuneInlayView:FlushAwakenAttr()
	local current_awaken_attr = RuneData.Instance:GetAwakenAttrInfoByIndex(self.select_index)
	if nil ~= current_awaken_attr then
		self.awaken_gongji:SetValue(current_awaken_attr.gongji)
		self.awaken_amp:SetValue(current_awaken_attr.ignore_fangyu)
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
	RuneCtrl.Instance:OpenRuneBagView(RUNE_CELL_TYPE.RUNE_TIHUAN_BTN)
end

--点击升级
function RuneInlayView:ClickUpGrade()
	self.up_select_index = self.select_index
	local data = RuneData.Instance:GetSlotDataByIndex(self.select_index)
	self.old_level = data.level or 0
	RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_UPLEVEL, self.select_index - 1)
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
	if data.quality < 0 then
		--没有物品时打开背包
		RuneCtrl.Instance:SetSlotIndex(index)
		RuneCtrl.Instance:OpenRuneBagView(RUNE_CELL_TYPE.RUNE_XIANGQIAN_BTN)
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
	for k,v in pairs(self.slot_list) do
		if v:GetIndex() ~= self.select_index then
			v.hight_line:SetValue(false)
		else
			v.hight_line:SetValue(true)
		end
	end
end

function RuneInlayView:SetLevelDes(data)
	local item_id = RuneData.Instance:GetRealId(data.quality, data.type)
	local type_name = RuneData.Instance:GetRuneNameByItemId(item_id)
	local quality, types = RuneData.Instance:GetQualityTypeByItemId(item_id)
	local type_color = RUNE_COLOR[quality] or TEXT_COLOR.WHITE
	local type_des = string.format(Language.Rune.LevelDes, type_color, type_name, data.level)
	self.attr_type_des:SetValue(type_des)
end

function RuneInlayView:SetAttrDes(data)
	local attr_type_name_0 = Language.Rune.AttrName[data.attr_type1] or ""
	local attr_value_0 = data.attr_value1
	if RuneData.Instance:IsPercentAttr(data.attr_type1) then
		attr_value_0 = (data.attr_value1/100.00) .. "%"
	end
	local show_two_attr = ("" ~= data.attr_type2)
	self.show_two_attr:SetValue(show_two_attr)
	if show_two_attr then
		local attr_type_name_1 = Language.Rune.AttrName[data.attr_type2] or ""
		local attr_value_1 = data.attr_value2
		if RuneData.Instance:IsPercentAttr(data.attr_type2) then
			attr_value_1 = (data.attr_value2/100.00) .. "%"
		end
	end

	-- 设置战斗力
	local attr_info = CommonStruct.AttributeNoUnderline()
	local attr_type2 = data.attr_type1
	local attr_type_2 = data.attr_type2
	if attr_type2 then
		RuneData.Instance:CalcAttr(attr_info, attr_type2, data.attr_value1)
	end
	if attr_type_2 then
		RuneData.Instance:CalcAttr(attr_info, attr_type_2, data.attr_value2)
	end
	local capability = CommonDataManager.GetCapabilityCalculation(attr_info)
	self.power:SetValue(capability)
end

function RuneInlayView:SetLevelUpDes(data)
	local next_data = RuneData.Instance:GetAttrInfo(data.quality, data.type, data.level + 1)
	local attr_type_name_0 = Language.Rune.AttrName[data.attr_type1] or ""
	local attr_value_0 = data.attr_value1
	if RuneData.Instance:IsPercentAttr(data.attr_type1) then
		attr_value_0 = (data.attr_value1/100.00) .. "%"
	end
	self.attr_name1:SetValue(attr_type_name_0)
	self.now_attr1:SetValue(attr_value_0)
	if next(next_data) then
		local next_attr_value_0 = next_data.attr_value1
		if RuneData.Instance:IsPercentAttr(next_data.attr_type1) then
			next_attr_value_0 = (next_data.attr_value1/100.00) .. "%"
		end
		self.next_attr1:SetValue(next_attr_value_0)
	end

	local show_two_attr = ("" ~= data.attr_type2)
	if show_two_attr then
		local attr_type_name_1 = Language.Rune.AttrName[data.attr_type2] or ""
		local attr_value_1 = data.attr_value2
		if RuneData.Instance:IsPercentAttr(data.attr_type2) then
			attr_value_1 = (data.attr_value2/100.00) .. "%"
		end
		self.attr_name2:SetValue(attr_type_name_1)
		self.now_attr2:SetValue(attr_value_1)
		if next(next_data) then
			local next_attr_value_1 = next_data.attr_value2
			if RuneData.Instance:IsPercentAttr(next_data.attr_type2) then
				next_attr_value_1 = (next_data.attr_value2/100.00) .. "%"
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
	local need_str = string.format(Language.Exchange.Expend, jing_hua, need_jinghua)
	if data.level >= GameEnum.RUNE_MAX_LEVEL then
		need_str = "--/--"
	elseif need_jinghua > jing_hua then
		need_str = ToColorStr(need_str, TEXT_COLOR.RED_3)
	elseif need_jinghua <= jing_hua then
		need_str = ToColorStr(need_str, TEXT_COLOR.GREEN)
	end

	self.need_str:SetValue(need_str)

	-- if self.up_select_index == self.select_index and self.old_level > 0 and self.old_level < data.level then
	-- 	--展示升级特效
	-- 	self:PlayUpEffect()
	-- end
	self:FlushAwakenAttr()
end

function RuneInlayView:PlayUpEffect()
	-- if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
	-- 	EffectManager.Instance:PlayAtTransformCenter(
	-- 		"effects2/prefab/ui_prefab",
	-- 		"UI_shengjichenggong",
	-- 		self.effect_obj.transform,
	-- 		2.0)
	-- 	self.effect_cd = Status.NowTime + EFFECT_CD
	-- end
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
	self.hight_line = self:FindVariable("hight_line")
	self.tips = self:FindVariable("tips")
	self.hight_line:SetValue(false)

	self.can_replace = false
	self.can_upgrade = false

	self:ListenEvent("Click", BindTool.Bind(self.Click, self))
end

function RuneEquipCell:__delete()
end

function RuneEquipCell:FlushInit()
	if self:GetIndex() == self.select_rune_index then
		self.hight_line:SetValue(true)
	end
end

function RuneEquipCell:SetCurrentSelect(index)
	self.select_rune_index = index
end

function RuneEquipCell:Click()
	if self.clickcallback then
		self.clickcallback(self, self.data)
	end
	if self.root_node.toggle.isOn then
		self.hight_line:SetValue(true)
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
	if not self.lock_state then
		if data.quality >= 0 then
			local have_jinghua = RuneData.Instance:GetJingHua()
			local need_jinghua = data.uplevel_need_jinghua
			local level = data.level
			if level < RuneData.Instance:GetRuneMaxLevel() and have_jinghua >= need_jinghua then
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
					if data.quality < 0 then
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