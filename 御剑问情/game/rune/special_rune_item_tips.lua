SpecialRuneItemTips = SpecialRuneItemTips or BaseClass(BaseView)
function SpecialRuneItemTips:__init()
    self.ui_config = {"uis/views/rune_prefab", "SpecialRuneItemTips"}
    self.play_audio = true
    self.view_layer = UiLayer.Pop
end

function SpecialRuneItemTips:__delete()
end

function SpecialRuneItemTips:ReleaseCallBack()
	self:RemoveCountDown()
	self.equip_name = nil
	for k,v in pairs(self.attr_list) do
		v = nil
	end
	self.attr_list = nil
	self.fight_power = nil
	self.free_time = nil
	self.btn_text = nil
	self.cost = nil
	self.is_active = nil
	self.require = nil
	self.quality = nil
	self.is_free = nil
	self.is_show_red = nil
	self.is_can_get = nil
	self.is_got = nil

	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function SpecialRuneItemTips:LoadCallBack()
	self.equip_name = self:FindVariable("EquipName")
	self.attr_list = {}
	self.attr_list.attr_0 = self:FindVariable("AttrAtack")
	self.attr_list.attr_1 = self:FindVariable("AttrHp")
	self.attr_list.attr_2 = self:FindVariable("AttrDefence")
	self.attr_list.special_attr = self:FindVariable("SpecialEffect")
	self.fight_power = self:FindVariable("FightPower")
	self.free_time = self:FindVariable("FreeTime")
	self.btn_text = self:FindVariable("BtnText")
	self.cost = self:FindVariable("Cost")
	self.is_active = self:FindVariable("IsActive")
	self.require = self:FindVariable("Require")
	self.quality = self:FindVariable("Quality")
	self.is_free = self:FindVariable("IsFree")
	self.is_show_red = self:FindVariable("IsShowRed")
	self.is_can_get = self:FindVariable("IsCanGet")
	self.is_got = self:FindVariable("IsGot")

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))

	self:ListenEvent("ClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("ClickActive", BindTool.Bind(self.OnClickActive, self))
end

function SpecialRuneItemTips:SetCloseCallBack()
end

function SpecialRuneItemTips:OpenCallBack()
	self:Flush()
end

function SpecialRuneItemTips:CloseCallBack()
end

function SpecialRuneItemTips:OnFlush()
	self:FlushContent()
end

function SpecialRuneItemTips:FlushContent()
	local other_cfg = RuneData.Instance:GetOtherCfg()
	if next(other_cfg) == nil then
		return
	end

	self.cost:SetValue(other_cfg.buy_best_rune_cost or 0)
	self.require:SetValue(other_cfg.need_red_rune_num or 0)
	local item_id = other_cfg.best_rune_item
	if item_id then
		self.item:SetData({item_id = item_id})
		self.item:SetInteractable(false)
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		if item_cfg == nil then
			return
		end
		local quality = item_cfg.color or 1
		self.equip_name:SetValue(ToColorStr(item_cfg.name, ITEM_TIP_NAME_COLOR[quality]))
		local bundle, sprite = ResPath.GetQualityBgIcon(item_cfg.color)
		self.quality:SetAsset(bundle, sprite)
	end

	-- 属性显示
	local special_attr_cfg = RuneData.Instance:GetSpecialRuneCfg()
	if next(special_attr_cfg) == nil then
		return
	end

	self.attr_list.attr_0:SetValue(special_attr_cfg.add_attributes_0 or 0)
	self.attr_list.attr_1:SetValue(special_attr_cfg.add_attributes_1 or 0)
	self.attr_list.attr_2:SetValue(special_attr_cfg.add_attributes_2 or 0)
	self.attr_list.special_attr:SetValue(special_attr_cfg.attr_percent / 100)

	-- 战力显示
	local capability = RuneData.Instance:GetSpecialRunePower()
	self.fight_power:SetValue(capability)

	-- 激活状态
	local is_can_get = RuneData.Instance:GetSpecialRuneCanActived()
	local is_got = RuneData.Instance:GetSpecialRuneCardIsGot()
	local is_actived = RuneData.Instance:GetSpecialRuneIsActivate()

	self.is_show_red:SetValue(false)
	if is_can_get == 1 and is_got ~= 1 and is_actived ~= 1 then
		self.is_show_red:SetValue(true)
	end
	if is_got == 1 and RuneData.Instance:GetSpecialRuneIsInBag() == 1 then
		self.is_show_red:SetValue(true)
	end

	if is_actived == 1 then
		self.is_active:SetValue(true)
		return
	else
		self.is_active:SetValue(false)
		-- 已经获取物品卡
		if is_got == 1 then
			self.is_can_get:SetValue(true)
			self.btn_text:SetValue(Language.Rune.SpecialBtnText3)
		-- 达到条件，可以领取物品卡
		elseif is_can_get == 1 then
			self.is_can_get:SetValue(true)
			self.btn_text:SetValue(Language.Rune.SpecialBtnText2)
		else
			self.is_can_get:SetValue(false)
			self.btn_text:SetValue(Language.Rune.SpecialBtnText1)
		end
	end

	-- 时间倒计时
	local free_remind_time = RuneData.Instance:GetSpecialRuneRemainFreeTime()
	if free_remind_time <= 0 then
		self.is_free:SetValue(false)
	else
		self:RemoveCountDown()
		self.count_down = CountDown.Instance:AddCountDown(free_remind_time, 1, BindTool.Bind(self.FlushCountDown, self))
	end
end

function SpecialRuneItemTips:RemoveCountDown()
	--释放计时器
	if CountDown.Instance:HasCountDown(self.count_down) then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function SpecialRuneItemTips:FlushCountDown(elapse_time, total_time)
	local time_interval = total_time - elapse_time
	if time_interval > 0 then
		self:SetTime(time_interval)
	else
		self.is_free:SetValue(false)
	end
end

function SpecialRuneItemTips:FlushRightFrame()
end

function SpecialRuneItemTips:OnClickClose()
	self:Close()
end

function SpecialRuneItemTips:OnClickActive()
	local other_cfg = RuneData.Instance:GetOtherCfg()
	if next(other_cfg) == nil then
		return
	end

	local is_can_get = RuneData.Instance:GetSpecialRuneCanActived()
	local is_got = RuneData.Instance:GetSpecialRuneCardIsGot()
	local is_actived = RuneData.Instance:GetSpecialRuneIsActivate()

	-- 购买
	local cost_gold = other_cfg.buy_best_rune_cost or 0
	if is_can_get == 0 and is_got == 0 and is_actived == 0 then
		local ok_fun = function ()
			local vo = GameVoManager.Instance:GetMainRoleVo()
			if vo.gold < cost_gold then
				TipsCtrl.Instance:ShowLackDiamondView()
				return
			else
				RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_BUY_BEST_RUNE_ACTIVATE_CARD)
			end
		end
		local tips_text = string.format(Language.Rune.BuySpecialTips, cost_gold)
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, tips_text)
		return
	end

	-- 领取
	if is_can_get == 1 and is_got == 0 and is_actived == 0 then
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_GET_BEST_RUNE_ACTIVATE_CARD)
		return
	end

	-- 激活
	if is_got == 1 and is_actived == 0 then
		local item_id = other_cfg.best_rune_item or 0
		local index = ItemData.Instance:GetItemIndex(item_id)
		if index < 0 then
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			if item_cfg == nil then
				return
			end
			TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Common.ActivedErrorTips, item_cfg.name))
		else
			PackageCtrl.Instance:SendUseItem(index)
		end
		return
	end
end

--设置时间
function SpecialRuneItemTips:SetTime(time)
	local show_time_str = ""
	if time > 3600 * 24 then
		show_time_str = TimeUtil.FormatSecond(time, 7)
	elseif time > 3600 then
		show_time_str = TimeUtil.FormatSecond(time, 1)
	else
		show_time_str = TimeUtil.FormatSecond(time, 4)
	end
	self.free_time:SetValue(show_time_str)
end