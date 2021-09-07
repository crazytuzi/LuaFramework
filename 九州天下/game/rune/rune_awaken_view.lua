RuneAwakenView = RuneAwakenView or BaseClass(BaseView)
function RuneAwakenView:__init()
	self:SetMaskBg()
	self.ui_config = {"uis/views/rune", "RuneAwakenView"}
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
    self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function RuneAwakenView:__delete()

end

function RuneAwakenView:ReleaseCallBack()
	-- 清理变量和对象
	self.hp_des = nil
	self.atk_des = nil
	self.def_des = nil
	self.effect_amp = nil
	self.fight_power = nil
	self.prop_count = nil
	--self.diamond_count = nil
	self.check_none_animation = nil
	self.slot_list_obj = nil
	self.red_point_list = nil
	self.needle = nil
	self.hp_obj = nil
	self.atk_obj = nil
	self.def_obj = nil
	self.amp_obj = nil
	self.diamond_cost = nil
	self.select_rune_img = nil
	self.select_rune_info = nil
	self.tips_txt = nil

	self.awaken_award = {}
	self.data_table = {}

	for _, v in ipairs(self.slot_list) do
		v:DeleteMe()
	end
	self.slot_list = {}

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.tween then
		self.tween:Kill()
		self.tween = nil
	end
end

function RuneAwakenView:LoadCallBack()
	self.hp_des = self:FindVariable("HpDes")				-- 血量加成
	self.atk_des = self:FindVariable("AtkDes")				-- 攻击加成
	self.def_des = self:FindVariable("DefDes")				-- 防御加成
	self.effect_amp = self:FindVariable("EffectAmp")		-- 效果增幅
	self.fight_power = self:FindVariable("FightPower")		-- 战力加成
	self.prop_count = self:FindVariable("PropCount")		-- 道具数量
	self.diamond_cost = self:FindVariable("diamond_cost")	-- 钻石消耗
	self.tips_txt = self:FindVariable("tips")

	self.select_rune_img = self:FindVariable("rune_image")	-- 当前符文
	self.select_rune_info = self:FindVariable("rune_info")

	self:ListenEvent("ClickDiamandAwaken", BindTool.Bind(self.ClickGO, self))
	self:ListenEvent("ClickRule", BindTool.Bind(self.ClickRule, self))
	self:ListenEvent("ClickClosen", BindTool.Bind(self.ClickClosen, self))
	self:ListenEvent("ClickGO", BindTool.Bind(self.ClickGO, self))

	self.item_id = RuneData.Instance:GetCommonAwakenItemID()
	self.hp_obj = self:FindObj("hp")
	self.atk_obj = self:FindObj("atk")
	self.def_obj = self:FindObj("def")
	self.amp_obj = self:FindObj("amp")
	self.slot_list_obj = self:FindObj("IconList")
	self.slot_list = {}
		for i = 0, 9 do
		local slot_obj = self.slot_list_obj.transform:GetChild(i).gameObject
		local slot_cell = RuneAwakenRewardCell.New(slot_obj)
		slot_cell:SetIndex(i+1)
		table.insert(self.slot_list, slot_cell)
	end

	self.check_none_animation = self:FindObj("Check")
	self.needle = self:FindObj("needle")

	self.awaken_award = {}									-- 奖励列表
	self.data_table = {}									-- 数据列表
	self.needle_is_role = false

	self.red_point_list = {
		[RemindName.RuneAwake] = self:FindVariable("CanPropRep"),
	}

	for k in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

-- 打开后调用
function RuneAwakenView:OpenCallBack()
	self.is_click_awake = false

	self.cell_index = RuneData.Instance:GetCellIndex()
	local data = RuneData.Instance:GetSlotDataByIndex(self.cell_index)
	local item_id = RuneData.Instance:GetRealId(data.quality, data.type)
	self.select_rune_img:SetAsset(ResPath.GetItemIcon(item_id))

	-- local type_color = RUNE_COLOR[data.quality] or TEXT_COLOR.WHITE
	-- local type_name = Language.Rune.AttrTypeName[data.type] or ""

	local type_name = RuneData.Instance:GetRuneNameByItemId(data.item_id)
	local quality, types = RuneData.Instance:GetQualityTypeByItemId(data.item_id)
	local type_color = RUNE_COLOR[quality] or TEXT_COLOR.WHITE

	local type_des = string.format(Language.Rune.LevelDes, type_color, type_name, data.level)
	self.select_rune_info:SetValue(type_des)

	self:FlushRightView()
	if 0 == self:GetPropCount() then
		self.prop_count:SetValue("<color=#ff0000>0/1</color>")
	else
		self.prop_count:SetValue(self:GetPropCount().."/1")
	end

	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)

	self:FlushDiamondCost()
end

function RuneAwakenView:ItemDataChangeCallback(item_id)
	self:Flush("prop_count")
end

-- 根据当前cell索引初始化数据
function RuneAwakenView:FlushRightView()
	-- 当前符文格属性table
	if 0 == self.cell_index then
		self.cell_index = 1
	end
	self.data_table = RuneData.Instance:GetAwakenAttrInfoByIndex(self.cell_index)
	if nil == self.data_table then
		return
	end

	local layer = RuneData.Instance:GetPassLayer()
	local awaken_limit = RuneData.Instance:GetAwakenLimitByLevel(layer)
	local next_limit_layer = RuneData.Instance:GetNextLimitLayer(layer)
	local show_tips = false
	if self.data_table.maxhp == awaken_limit.maxhp_limit then
		self.hp_des:SetValue(self.data_table.maxhp..Language.Rune.AttrFull)
		show_tips = true
	else
		self.hp_des:SetValue(self.data_table.maxhp)
	end
	if self.data_table.gongji == awaken_limit.gongji_limit then
		self.atk_des:SetValue(self.data_table.gongji..Language.Rune.AttrFull)
		show_tips = true
	else
		self.atk_des:SetValue(self.data_table.gongji)
	end
	if self.data_table.fangyu == awaken_limit.fangyu_limit then
		self.def_des:SetValue(self.data_table.fangyu..Language.Rune.AttrFull)
		show_tips = true
	else
		self.def_des:SetValue(self.data_table.fangyu)
	end

	if self.data_table.ignore_fangyu == awaken_limit.ignore_fangyu_limit then
		self.effect_amp:SetValue(self.data_table.ignore_fangyu..Language.Rune.AttrFull)
	else
		self.effect_amp:SetValue(self.data_table.ignore_fangyu)
	end

	if show_tips then
		local des = string.format(Language.Rune.AwakenTips, next_limit_layer)
		self.tips_txt:SetValue(des)
	else
		self.tips_txt:SetValue("")
	end

	--当前符文格装备的符文属性table
	local curren_cell_data = RuneData.Instance:GetSlotDataByIndex(self.cell_index)
	-- 计算战斗力
	local attr_base_info = {
		-- attr_type_0 = curren_cell_data.attr_type_0,
		-- add_attributes_0 = curren_cell_data.add_attributes_0,
		-- attr_type_1 = curren_cell_data.attr_type_1,
		-- add_attributes_1 = curren_cell_data.add_attributes_1,
		attr_type1 = curren_cell_data.attr_type1,
		attr_value1 = curren_cell_data.attr_value1,
		attr_type2 = curren_cell_data.attr_type2,
		attr_value2 = curren_cell_data.attr_value2,
	}

	local power = 0
	local attr_type_1_is_calc = false
	local attr_type_2_is_calc = false
	local spe_tag1 = RuneData.Instance:IsPercentAttr(attr_base_info.attr_type1)
	if spe_tag1 then
		local add_attributes = attr_base_info.attr_value1
		add_attributes = add_attributes * (self.data_table.add_per/100)
		local temp_attr_info = CommonStruct.AttributeNoUnderline()
		local attr_type = attr_base_info.attr_type1
		RuneData.Instance:CalcAttr(temp_attr_info, attr_type, add_attributes)
		power = power + CommonDataManager.GetCapability(temp_attr_info)
		attr_type_1_is_calc = true
	end

	local spe_tag2 = RuneData.Instance:IsPercentAttr(attr_base_info.attr_type2)
	if spe_tag2 then
		local add_attributes = attr_base_info.attr_value2
		add_attributes = add_attributes * (self.data_table.add_per/100)
		local temp_attr_info = CommonStruct.AttributeNoUnderline()
		local attr_type = attr_base_info.attr_type2
		RuneData.Instance:CalcAttr(temp_attr_info, attr_type, add_attributes)
		power = power + CommonDataManager.GetCapability(temp_attr_info)
		attr_type_2_is_calc = true
	end

	local attr_info = CommonStruct.AttributeNoUnderline()
	local attr_type1 = attr_base_info.attr_type1
	local attr_type2 = attr_base_info.attr_type2

	if not attr_type_1_is_calc and attr_type1 then
		RuneData.Instance:CalcAttr(attr_info, attr_type1, attr_base_info.attr_value1)
	end
	if not attr_type_2_is_calc and attr_type2 then
		RuneData.Instance:CalcAttr(attr_info, attr_type2, attr_base_info.attr_value2)
	end

	for k,v in pairs(attr_info) do
		if v > 0 then
			attr_info[k] = attr_info[k] * self.data_table.add_per * 0.01
		end
	end
	power = power + CommonDataManager.GetCapability(attr_info)
	self:SetPower(self.data_table, power)
end

function RuneAwakenView:SetAwakenAttrInfoByIndex(cell_index)
	self.data_table = {}
	self.data_table = RuneData.Instance:GetAwakenAttrInfoByIndex(cell_index)
end

function RuneAwakenView:SetPower(data_table, extravalue)
	if nil == extravalue then
		extravalue = 0
	end
	if data_table then
		local capability = CommonDataManager.GetCapability(data_table)
		local power_count = capability + extravalue
		self.fight_power:SetValue(power_count)
	end
	for k,v in ipairs(self.slot_list) do
		v:Flush()
	end
end

function RuneAwakenView:PlayerDataChangeCallback()
	self:Flush("money")
end

-- 关闭前调用
function RuneAwakenView:CloseCallBack()
	--TipsFloatingManager.Instance:StartFloating()

	TipsCtrl.Instance:DestroyFlyEffectByViewName(ViewName.RuneAwakenView)
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
end

function RuneAwakenView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

-- 刷新
function RuneAwakenView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "needle" then
			self:ShowAnimation(RuneData.Instance:GetAwakenSeq())
		end
		if k == "rightview" then
			self:FlushRightView()
		end
		if k == "prop_count" then
			if 0 == self:GetPropCount() then
				self.prop_count:SetValue("<color=#ff0000>0/1</color>")
			else
				self.prop_count:SetValue(self:GetPropCount().."/1")
			end
		end
		if k == "diamondcost" then
			self:FlushDiamondCost()
		end
	end
end

function RuneAwakenView:FlushDiamondCost()
	local current_times = RuneData.Instance:GetAwakenTimes()
	local cost_info = RuneData.Instance:GetAwakenCostInfo()
	for k,v in pairs(cost_info) do
		if v.max_times >= current_times and v.min_times <= current_times then
			self.diamond_cost:SetValue(cost_info[k].gold_cost)
			return
		end
	end
end

--道具觉醒
function RuneAwakenView:ClickPropAwaken()
	if self.is_click_awake then
		return
	end

	if self.needle_is_role then
		return
	end
	if not self.check_none_animation.toggle.isOn then
		self.is_click_awake = true
		--TipsFloatingManager.Instance:PauseFloating()
	end
	--print("ClickPropAwaken=============", RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_AWAKEN, self.cell_index-1, RUNE_SYSTEM_AWAKEN_TYPE.RUEN_AWAKEN_TYPE_COMMON)
	RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_AWAKEN, self.cell_index-1, RUNE_SYSTEM_AWAKEN_TYPE.RUEN_AWAKEN_TYPE_COMMON)
end

function RuneAwakenView:ClickGO()
	if 1 <= self:GetPropCount() then
		self:ClickPropAwaken()
	else
		local function call()
			self:ClickDiamandAwaken()
		end

		local cost = 0
		local current_times = RuneData.Instance:GetAwakenTimes()
		local cost_info = RuneData.Instance:GetAwakenCostInfo()
		for k,v in pairs(cost_info) do
			if v.max_times >= current_times and v.min_times <= current_times then
				cost = cost_info[k].gold_cost
				break
			end
		end

		TipsCtrl.Instance:ShowCommonAutoView("rune_awaken_view", string.format(Language.Rune.AwakenBuyTips, cost), call)
	end
end

--钻石觉醒
function RuneAwakenView:ClickDiamandAwaken()
	if self.is_click_awake then
		return
	end

	if self.needle_is_role then
		return
	end

	if not self.check_none_animation.toggle.isOn then
		self.is_click_awake = true
		--TipsFloatingManager.Instance:PauseFloating()
	end
	--print("ClickDiamandAwaken=============", RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_AWAKEN, self.cell_index-1, RUNE_SYSTEM_AWAKEN_TYPE.RUEN_AWAKEN_TYPE_DIAMOND)
	RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_AWAKEN, self.cell_index-1, RUNE_SYSTEM_AWAKEN_TYPE.RUEN_AWAKEN_TYPE_DIAMOND)
	RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_OTHER_INFO)
end

--index 需要停的位置 time 转的圈数
function RuneAwakenView:ShowAnimation(index, time)
	if self.check_none_animation.toggle.isOn then
		-- 如果屏蔽了动画
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_AWAKEN_CALC_REQ)
		self.needle.transform.localRotation = Quaternion.Euler(0, 0, -(index - 2) * 36)
		self:SetAwakenAttrInfoByIndex(self.cell_index)
		self:SetPower(self.data_table)
		return
	end
	if self.needle_is_role then
		return
	end
	self.needle_is_role = true
	if self.tween then
		self.tween:Kill()
		self.tween = nil
	end
	if nil == time then
		time = 4
	end
  
	local angle = (index-2) * 36
	self.tween = self.needle.transform:DORotate(
		Vector3(0, 0, -360 * time - angle),
		time,
		DG.Tweening.RotateMode.FastBeyond360)
	self.tween:SetEase(DG.Tweening.Ease.OutQuart)
	self.tween:OnComplete(function ()
		--TipsFloatingManager.Instance:StartFloating()

		--动画播放完毕
		--当前奖励格子索引
		local current_reward_index = RuneData.Instance:GetAwakenSeq()
		--如果是属性
		local is_property = RuneData.Instance:GetIsPropertyByIndex(current_reward_index)
		if 1 == is_property then
			local awaken_type = RuneData.Instance:GetAwakenTypeInfoByIndex(current_reward_index).awaken_type
			local end_obj = nil
			if 1 == awaken_type then
				--攻击
				end_obj = self.atk_obj
			end
			if 2 == awaken_type then
				--防御
				end_obj = self.def_obj
			end
			if 3 == awaken_type then
				--血量
				end_obj = self.hp_obj
			end
			if 4 == awaken_type then
				--增益
				end_obj = self.amp_obj
			end
			if self:IsOpen() then
				TipsCtrl.Instance:ShowFlyEffectManager(ViewName.RuneAwakenView, "effects2/prefab/ui/ui_guangdian1_prefab", "UI_guangdian1", self.slot_list[current_reward_index].root_node , end_obj,
							nil, 1, BindTool.Bind(self.EffectComplete, self, current_reward_index))
			else
				self:EffectComplete()
			end
		else
			self:EffectComplete()
		end
		self.needle_is_role = false
		self.is_click_awake = false
	end)
end

function RuneAwakenView:EffectComplete()
	RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_AWAKEN_CALC_REQ)
end

--获取道具数量
function RuneAwakenView:GetPropCount()
	return ItemData.Instance:GetItemNumInBagById(self.item_id)
end

function RuneAwakenView:ClickRule()
	--显示规则信息
	TipsCtrl.Instance:ShowHelpTipView(233)
end

function RuneAwakenView:ClickClosen()
	self.check_none_animation.toggle.isOn = false
	self:Close()
end

-----------------------RuneAwakenRewardCell---------------------------
RuneAwakenRewardCell = RuneAwakenRewardCell or BaseClass(BaseCell)
function RuneAwakenRewardCell:__init()
	self.cur_attribute = self:FindVariable("txt")
	self.pic_res = self:FindVariable("pic")
	self.icon_res = self:FindVariable("icon")
	self.percent_atr = self:FindVariable("percent")
	self.slider_content = self:FindVariable("slider")
	self.awaken_type = 0
end

function RuneAwakenRewardCell:__delete()
end

function RuneAwakenRewardCell:SetToggleIsOn(state)
	self.root_node.toggle.isOn = state
end

function RuneAwakenRewardCell:GetCurrentType()
	return self.awaken_type
end

function RuneAwakenRewardCell:OnFlush()
	-- 拿到当前符文格子的属性table
	local index = RuneData.Instance:GetCellIndex()
	local data = RuneData.Instance:GetAwakenTypeInfoByIndex(index)
	-- 当前奖励格子的索引
	local current_cell_index = self:GetIndex()
	local current_info = RuneData.Instance:GetAwakenTypeInfoByIndex(current_cell_index)
	-- 如果当前的奖励格子为属性奖励
	--根据当前seq值判断是什么属性（type值）
	--拿到当前等级最大值
	self.awaken_type = current_info.awaken_type
	if RuneData.Instance:GetIsPropertyByIndex(current_cell_index) == 1 then
		-- 符文塔等级
		local layer = RuneData.Instance:GetPassLayer()
		local awaken_limit = RuneData.Instance:GetAwakenLimitByLevel(layer)
		local gongji_limit = awaken_limit.gongji_limit
		local fangyu_limit = awaken_limit.fangyu_limit
		local maxhp_limit = awaken_limit.maxhp_limit
		local addper_limit = awaken_limit.addper_limit
		--拿到当前进度值
		local current_rune_data = RuneData.Instance:GetAwakenAttrInfoByIndex(index)
		local curren_limit = 0
		local current_value = 0
		if 1 == self.awaken_type then
			--攻击
			curren_limit = awaken_limit.gongji_limit
			current_value = current_rune_data.gongji
			self.percent_atr:SetValue("+"..current_value)
		end
		if 2 == self.awaken_type then
			--防御
			curren_limit = awaken_limit.fangyu_limit
			current_value = current_rune_data.fangyu
			self.percent_atr:SetValue("+"..current_value)
		end
		if 3 == self.awaken_type then
			--生命
			curren_limit = awaken_limit.maxhp_limit
			current_value = current_rune_data.maxhp
			self.percent_atr:SetValue("+"..current_value)
		end
		if 4 == self.awaken_type then
			--增幅
			curren_limit = awaken_limit.ignore_fangyu_limit
			current_value = current_rune_data.ignore_fangyu
			self.percent_atr:SetValue("+"..current_value)
		end
		if self.slider_content then
			self.slider_content:SetValue(1)
		end
		local str = string.format("<color=#00ff00>%d</color><color=#6098cb>/%d</color>", current_value, curren_limit)
		self.cur_attribute:SetValue(str)
	else
		self.percent_atr:SetValue("")
		self.cur_attribute:SetValue("")
	end
	self.icon_res:SetAsset(ResPath.GetRuneRes("awaken_icon_"..self.awaken_type))
	if self.pic_res then
		self.pic_res:SetAsset(ResPath.GetRuneRes("awaken_icon_"..self.awaken_type))
	end
	self.cur_attribute:SetValue(Language.Rune.AwakenType[self.awaken_type])
end