TipsTimeLimitEquipView = TipsTimeLimitEquipView or BaseClass(BaseView)

function TipsTimeLimitEquipView:__init()
	self.ui_config = {"uis/views/tips/equiptips_prefab","TimeLimitEquipTips"}
	self.view_layer = UiLayer.Pop
end

function TipsTimeLimitEquipView:__delete()

end

function TipsTimeLimitEquipView:ReleaseCallBack()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.btn_used = nil
	self.btn_off = nil
	self.btn_sell = nil
	self.time = nil
	self.attr_des = nil
	self.title = nil
	self.title_bg = nil
	self.used_btn_text = nil
	self.level = nil
	self.equip_type = nil
	self.power = nil
	self.maxhp = nil
	self.gongji = nil
	self.fangyu = nil
end

function TipsTimeLimitEquipView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))

	self.btn_used = self:FindObj("btn_used")
	self.btn_used.button:SetClickListener(BindTool.Bind(self.ClickUsed, self))
	self.btn_off = self:FindObj("btn_off")
	self.btn_off.button:SetClickListener(BindTool.Bind(self.ClickTakeOff, self))
	self.btn_sell = self:FindObj("btn_sell")
	self.btn_sell.button:SetClickListener(BindTool.Bind(self.ClickSell, self))

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item_cell"))
	self.item_cell:SetInteractable(false)

	self.time = self:FindVariable("time")
	self.attr_des = self:FindVariable("attr_des")
	self.title = self:FindVariable("title")
	self.title_bg = self:FindVariable("title_bg")
	self.used_btn_text = self:FindVariable("used_btn_text")
	self.level = self:FindVariable("level")
	self.equip_type = self:FindVariable("equip_type")
	self.power = self:FindVariable("power")
	self.maxhp = self:FindVariable("maxhp")
	self.gongji = self:FindVariable("gongji")
	self.fangyu = self:FindVariable("fangyu")
end

function TipsTimeLimitEquipView:CloseWindow()
	self:Close()
end

function TipsTimeLimitEquipView:ClickUsed()
	if self.data == nil then
		return
	end

	local imp_guard_cfg_info = PlayerData.Instance:GetImpGuardCfgInfoByItemId(self.data.item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)

	if self.is_time_out then
		--续费（在背包里的）
		local function ok_func()
			PlayerCtrl.Instance:ReqImpGuardOpera(IMP_GUARD_REQ_TYPE.IMP_GUARD_REQ_TYPE_RENEW_KNAPSACK, self.data.index)
			self:Close()
		end

		local des = string.format(Language.Common.ReNewItemDes, imp_guard_cfg_info.gold_price, item_cfg.name, imp_guard_cfg_info.use_day)
		TipsCtrl.Instance:ShowCommonAutoView("imp_guard" .. imp_guard_cfg_info.imp_type, des, ok_func)
	elseif TipsFormDef.FROM_BAG_EQUIP == self.from_view then
		--续费（在装备栏里的）
		local function ok_func()
			PlayerCtrl.Instance:ReqImpGuardOpera(IMP_GUARD_REQ_TYPE.IMP_GUARD_REQ_TYPE_RENEW_PUTON, imp_guard_cfg_info.imp_type)
			self:Close()
		end

		local des = string.format(Language.Common.ReNewItemDes, imp_guard_cfg_info.gold_price, item_cfg.name, imp_guard_cfg_info.use_day)
		TipsCtrl.Instance:ShowCommonAutoView("imp_guard" .. imp_guard_cfg_info.imp_type, des, ok_func)
	else
		--装备
		PackageCtrl.Instance:SendUseItem(self.data.index)
		self:Close()
	end
end

function TipsTimeLimitEquipView:ClickTakeOff()
	if self.data == nil then
		return
	end

	local imp_guard_cfg_info = PlayerData.Instance:GetImpGuardCfgInfoByItemId(self.data.item_id)
	PlayerCtrl.Instance:ReqImpGuardOpera(IMP_GUARD_REQ_TYPE.IMP_GUARD_REQ_TYPE_TAKEOFF, imp_guard_cfg_info.imp_type)
	self:Close()
end

function TipsTimeLimitEquipView:ClickSell()
	if self.data == nil then
		return
	end

	local function ok_func()
		PackageCtrl.Instance:SendDiscardItem(self.data.index)
		self:Close()
	end

	TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Tip.IsSureRecoverProp, ok_func)
end

function TipsTimeLimitEquipView:SetData(data)
	self.data = data
end

function TipsTimeLimitEquipView:SetFrom(from_view)
	self.from_view = from_view
end

function TipsTimeLimitEquipView:SetCloseCallBack(close_call_back)
	self.close_call_back = close_call_back
end

function TipsTimeLimitEquipView:OpenCallBack()
	self:Flush()
end

function TipsTimeLimitEquipView:CloseCallBack()
	if self.close_call_back then
		self.close_call_back()
	end

	self:RemoveCountDown()
end

function TipsTimeLimitEquipView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function TipsTimeLimitEquipView:StartCountDown(left_time)
	left_time = math.ceil(left_time)
	local time_str = TimeUtil.FormatSecond2Str(left_time)

	self.count_down = CountDown.Instance:AddCountDown(left_time, 1, function(elapse_time, total_time)
		if elapse_time >= total_time then
			self:RemoveCountDown()
			self.time:SetValue(ToColorStr(Language.Common.HadOverdue, TEXT_COLOR.RED2))
			self.is_time_out = true
			self:FlushBtnText()
			return
		end

		elapse_time = math.floor(elapse_time)

		left_time = total_time - elapse_time

		time_str = TimeUtil.FormatSecond2Str(left_time)
		time_str = string.format(Language.Common.TimeOutStr, time_str)
		self.time:SetValue(time_str)
	end)

	time_str = string.format(Language.Common.TimeOutStr, time_str)
	self.time:SetValue(time_str)
end

--设置时间
function TipsTimeLimitEquipView:CheckTime()
	self:RemoveCountDown()

	if TipsFormDef.FROM_BAG_EQUIP ~= self.from_view and TipsFormDef.FROM_BAG ~= self.from_view then
		self.time:SetValue("")
		return
	end

	if self.data == nil then
		return
	end

	local server_time = TimeCtrl.Instance:GetServerTime()
	local invalid_time = self.data.invalid_time
	if not invalid_time or server_time >= invalid_time then
		--已过期了
		self.time:SetValue(ToColorStr(Language.Common.HadOverdue, TEXT_COLOR.RED2))
		self.is_time_out = true
		return
	end
	self.is_time_out = false

	self:StartCountDown(invalid_time - server_time)
end

function TipsTimeLimitEquipView:FlushBtnText()
	if self.is_time_out or TipsFormDef.FROM_BAG_EQUIP == self.from_view then
		self.used_btn_text:SetValue(Language.Common.XuFei)
	else
		self.used_btn_text:SetValue(Language.Common.Use)
	end
end

function TipsTimeLimitEquipView:OnFlush()
	self:CheckTime()

	self:FlushBtnText()

	self.btn_used:SetActive(TipsFormDef.FROM_BAG_EQUIP == self.from_view or TipsFormDef.FROM_BAG == self.from_view)
	self.btn_off:SetActive(TipsFormDef.FROM_BAG_EQUIP == self.from_view)
	self.btn_sell:SetActive(TipsFormDef.FROM_BAG == self.from_view)

	if self.data == nil then
		return
	end

	local item_id = self.data.item_id
	self.item_cell:SetData({item_id = item_id})
	self.item_cell:SetInteractable(false)

	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		return
	end

	--设置属性
	local attr = CommonStruct.AttributeNoUnderline()
	attr.maxhp = item_cfg.hp
	attr.gongji = item_cfg.attack
	attr.fangyu = item_cfg.fangyu
	self.maxhp:SetValue(attr.maxhp)
	self.gongji:SetValue(attr.gongji)
	self.fangyu:SetValue(attr.fangyu)
	self.power:SetValue(CommonDataManager.GetCapabilityCalculation(attr))

	self.title:SetValue(ToColorStr(item_cfg.name, ITEM_TIP_NAME_COLOR[item_cfg.color]))
	local bundle, asset = ResPath.GetQualityBgIcon(item_cfg.color)
	self.title_bg:SetAsset(bundle, asset)

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	local lv, zhuan = PlayerData.GetLevelAndRebirth(item_cfg.limit_level)
	local level_str = string.format(Language.Common.LevelFormat, lv, zhuan)
	local color = TEXT_COLOR.BLACK_1
	if main_role_vo.level < item_cfg.limit_level then
		color = TEXT_COLOR.RED
	end
	level_str = ToColorStr(level_str, color)
	self.level:SetValue(level_str)

	self.equip_type:SetValue(Language.EquipTypeName.ShouHu)

	self.attr_des:SetValue(item_cfg.description or "")
end