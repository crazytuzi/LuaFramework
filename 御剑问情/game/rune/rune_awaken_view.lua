RuneAwakenView = RuneAwakenView or BaseClass(BaseView)
function RuneAwakenView:__init()
	self.ui_config = {"uis/views/rune_prefab", "RuneAwakenView"}
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
    self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
    self.state = false     --记住用户上次的是否选择十连抽
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
	self.diamond_count = nil
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
	self.check_ten_times = nil

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
	self.diamond_count = self:FindVariable("DiamondCount")	-- 钻石数量
	self.diamond_cost = self:FindVariable("diamond_cost")	-- 钻石消耗
	self.tips_txt = self:FindVariable("tips")

	self.select_rune_img = self:FindVariable("rune_image")	-- 当前符文
	self.select_rune_info = self:FindVariable("rune_info")

	self:ListenEvent("ClickPropAwaken", BindTool.Bind(self.ClickPropAwaken, self))
	self:ListenEvent("ClickDiamandAwaken", BindTool.Bind(self.ClickDiamandAwaken, self))
	self:ListenEvent("ClickRule", BindTool.Bind(self.ClickRule, self))
	self:ListenEvent("ClickClosen", BindTool.Bind(self.ClickClosen, self))
	self:ListenEvent("ClickRecharge", BindTool.Bind(self.ClickRecharge, self))
	self:ListenEvent("ClickGO", BindTool.Bind(self.ClickGO, self))
	self:ListenEvent("ClickTenTimes", BindTool.Bind(self.ClickTenTimes, self))

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
		--slot_cell:SetClickCallBack(BindTool.Bind(self.SlotClick, self))
		table.insert(self.slot_list, slot_cell)
	end

	self.check_none_animation = self:FindObj("AnimationCheck")
	self.check_ten_times = self:FindObj("TenTimesCheck")
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
	self.is_ten_flag = false
	-- 是否屏蔽动画
	self.check_none_animation.toggle.isOn = RuneData.Instance:IsStopPlayAni()
	-- 默认非十连
	self.check_ten_times.toggle.isOn = self.state

	--初始化钻石
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	self.diamond_count:SetValue(self:GetMoney())

	self.cell_index = RuneData.Instance:GetCellIndex()
	local data = RuneData.Instance:GetSlotDataByIndex(self.cell_index)
	local item_id = RuneData.Instance:GetRealId(data.quality, data.type)
	self.select_rune_img:SetAsset(ResPath.GetItemIcon(item_id))

	local type_color = RUNE_COLOR[data.quality] or TEXT_COLOR.WHITE
	local type_name = Language.Rune.AttrTypeName[data.type] or ""
	local type_des = string.format(Language.Rune.LevelDes, type_color, type_name, data.level)
	self.select_rune_info:SetValue(type_des)

	self:FlushRightView()

	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)

	self:FlushPropCost(false)
	self:FlushDiamondCost(false)
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

	local effect_amp = self.data_table.add_per * 0.01
	if effect_amp == (awaken_limit.addper_limit * 0.01) then
		self.effect_amp:SetValue(effect_amp.."%"..Language.Rune.AttrFull)
		show_tips = true
	else
		self.effect_amp:SetValue(effect_amp.."%")
	end

	if show_tips then
		local des = string.format(Language.Rune.AwakenTips, next_limit_layer)
		self.tips_txt:SetValue(des)
	else
		self.tips_txt:SetValue("")
	end

	self:SetPower()
end

function RuneAwakenView:SetAwakenAttrInfoByIndex(cell_index)
	self.data_table = {}
	self.data_table = RuneData.Instance:GetAwakenAttrInfoByIndex(cell_index)
end

function RuneAwakenView:SetPower()
	local power = RuneData.Instance:CalcAwakePowerByIndex(self.cell_index)
	self.fight_power:SetValue(power)

	for k,v in ipairs(self.slot_list) do
		v:Flush()
	end
end

function RuneAwakenView:PlayerDataChangeCallback()
	self:Flush("money")
end

-- function RuneAwakenView:SlotClick(cell)
-- 	--打开属性面板
-- 	local index = cell:GetIndex()
-- 	RuneData.Instance:SetAwakenTypeIndex(index)
-- 	local function close_call_back()
-- 		if cell:IsNil() then
-- 			return
-- 		end
-- 		cell:SetToggleIsOn(false)
-- 	end
-- 	RuneCtrl.Instance:SetAwakenTipsCallBack(close_call_back)

-- 	local function open_call_back()
-- 		return index, cell:GetCurrentType()
-- 	end
-- 	RuneCtrl.Instance:SetAwakenTipsOpenCallBack(open_call_back)
-- 	ViewManager.Instance:Open(ViewName.RuneAwakenTipsView)
-- end

-- 关闭前调用
function RuneAwakenView:CloseCallBack()
	TipsFloatingManager.Instance:StartFloating()

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
			if self.check_ten_times.toggle.isOn then
				self:FlushPropCost(true)
			else
				self:FlushPropCost(false)
			end
		end
		if k == "money" then
			self.diamond_count:SetValue(self:GetMoney())
		end
		if k == "diamondcost" then
			if self.check_ten_times.toggle.isOn then
				self:FlushDiamondCost(true)
			else
				self:FlushDiamondCost(false)
			end
		end
	end
end

function RuneAwakenView:FlushDiamondCost(flag)
	local gold_cost = RuneData.Instance:GetAwakenGoldCost(flag)
	self.diamond_cost:SetValue(gold_cost)
end

function RuneAwakenView:FlushPropCost(flag)
	local prop_num = RuneData.Instance:GetAwakenPropCount()
	local prop_total_cost = flag and 10 or 1

	if prop_num == 0 then
		prop_num = ToColorStr(prop_num, TEXT_COLOR.RED)
	else
		prop_num = ToColorStr(prop_num, TEXT_COLOR.BLUE_4)
	end

	self.prop_count:SetValue(prop_num.." / "..prop_total_cost)
end

function RuneAwakenView:GetMoney()
	return CommonDataManager.ConverMoney(GameVoManager.Instance:GetMainRoleVo().gold)
end

--道具觉醒
function RuneAwakenView:ClickPropAwaken()
	if self.is_click_awake then
		return
	end

	if self.needle_is_role then
		return
	end

	-- 道具不足
	if RuneData.Instance:GetAwakenPropCount() <= 0 then
		TipsCtrl.Instance:ShowItemGetWayView(RuneData.Instance:GetCommonAwakenItemID())
		return
	end

	if not self.check_none_animation.toggle.isOn then
		self.is_click_awake = true
		TipsFloatingManager.Instance:PauseFloating()
	end

	if self.check_ten_times.toggle.isOn then
		self.is_ten_flag = true
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_AWAKEN, self.cell_index-1, RUNE_SYSTEM_AWAKEN_TYPE.RUEN_AWAKEN_TYPE_COMMON, RUNE_SYSTEM_AWAKEN_TYPE.RUNE_AWAKEN_TYPE_IS_TEN)
	else
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_AWAKEN, self.cell_index-1, RUNE_SYSTEM_AWAKEN_TYPE.RUEN_AWAKEN_TYPE_COMMON, RUNE_SYSTEM_AWAKEN_TYPE.RUNE_AWAKEN_TYPE_NOT_TEN)
	end
end

function RuneAwakenView:ClickGO()
	if 1 <= RuneData.Instance:GetAwakenPropCount() then
		self:ClickPropAwaken()
	else
		self:ClickDiamandAwaken()
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

	--元宝不足
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local gold_cost = 0
	if self.check_ten_times.toggle.isOn then
		gold_cost = RuneData.Instance:GetAwakenGoldCost(true)
	else
		gold_cost = RuneData.Instance:GetAwakenGoldCost(false)
	end
	if vo.gold < gold_cost then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end

	if not self.check_none_animation.toggle.isOn then
		self.is_click_awake = true
		TipsFloatingManager.Instance:PauseFloating()
	end

	if self.check_ten_times.toggle.isOn then
		self.is_ten_flag = true
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_AWAKEN, self.cell_index-1, RUNE_SYSTEM_AWAKEN_TYPE.RUEN_AWAKEN_TYPE_DIAMOND, RUNE_SYSTEM_AWAKEN_TYPE.RUNE_AWAKEN_TYPE_IS_TEN)
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_OTHER_INFO)
	else
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_AWAKEN, self.cell_index-1, RUNE_SYSTEM_AWAKEN_TYPE.RUEN_AWAKEN_TYPE_DIAMOND, RUNE_SYSTEM_AWAKEN_TYPE.RUNE_AWAKEN_TYPE_NOT_TEN)
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_OTHER_INFO)
	end

end

--index 需要停的位置 time 转的圈数
function RuneAwakenView:ShowAnimation(index, time)
	if self.check_none_animation.toggle.isOn then
		-- 如果屏蔽了动画
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_AWAKEN_CALC_REQ)
		self.needle.transform.localRotation = Quaternion.Euler(0, 0, -(index-1) * 36)
		self:SetAwakenAttrInfoByIndex(self.cell_index)

		self.is_ten_flag = false
		self.is_click_awake = false
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

	local angle = (index-1) * 36
	self.tween = self.needle.transform:DORotate(
		Vector3(0, 0, -360 * time - angle),
		time,
		DG.Tweening.RotateMode.FastBeyond360)
	self.tween:SetEase(DG.Tweening.Ease.OutQuart)
	self.tween:OnComplete(function ()
		TipsFloatingManager.Instance:StartFloating()

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
				TipsCtrl.Instance:ShowFlyEffectManager(ViewName.RuneAwakenView, "effects2/prefab/ui_x/ui_guangdian1_prefab", "UI_guangdian1", self.slot_list[current_reward_index].root_node , end_obj,
							nil, 1, BindTool.Bind(self.EffectComplete, self, current_reward_index))
			else
				self:EffectComplete()
			end
		else
			self.is_click_awake = false
			self.is_ten_flag = false
		end
		self.needle_is_role = false
	end)
end

function RuneAwakenView:EffectComplete()
	RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_AWAKEN_CALC_REQ)
	self.is_click_awake = false
end

function RuneAwakenView:ClickRule()
	--显示规则信息
	TipsCtrl.Instance:ShowHelpTipView(182)
end

function RuneAwakenView:ClickClosen()
	RuneData.Instance:SetPlayTreasureAni(self.check_none_animation.toggle.isOn)
	self:Close()
end

function RuneAwakenView:ClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function RuneAwakenView:ClickTenTimes()
	self.state = self.check_ten_times.toggle.isOn
	if self.check_ten_times.toggle.isOn then
		self:FlushPropCost(true)
		self:FlushDiamondCost(true)
	else
		self:FlushPropCost(false)
		self:FlushDiamondCost(false)
	end
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
    --self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
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
			curren_limit = awaken_limit.addper_limit
			current_value = current_rune_data.add_per
			self.percent_atr:SetValue("+"..current_value / 100 .."%")
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