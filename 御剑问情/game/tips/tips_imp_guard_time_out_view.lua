ImpGuardTimeOutTipView = ImpGuardTimeOutTipView or BaseClass(BaseView)

function ImpGuardTimeOutTipView:__init()
	self.ui_config = {"uis/views/tips/impguardtips_prefab", "ImpGuardTimeOutTips"}
	self.view_layer = UiLayer.Pop
	self.select_type = -1
	self.item_cell_list = {}
	self.data = {}
end

function ImpGuardTimeOutTipView:__delete()
end

function ImpGuardTimeOutTipView:ReleaseCallBack()
	for _, v in ipairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = nil

	self.cost = nil
	self.gold_res = nil
end

function ImpGuardTimeOutTipView:LoadCallBack()
	self:ListenEvent("CloseWindow",
		BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickBtn",
		BindTool.Bind(self.ClickBtn, self))

	self.item_cell_list = {}
	local item_group = self:FindObj("ItemGroup")
	for i = 1, 2 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("ItemCell" .. i))
		item_cell:SetToggleGroup(item_group.toggle_group)
		item_cell:ListenClick(BindTool.Bind(self.ClickItem, self, i))
		table.insert(self.item_cell_list, item_cell)
	end

	self.cost = self:FindVariable("Cost")
	self.gold_res = self:FindVariable("GoldRes")
end

function ImpGuardTimeOutTipView:CloseWindow()
	self:Close()
end

function ImpGuardTimeOutTipView:ClickBtn()
	local imp_guard_cfg_info = PlayerData.Instance:GetImpGuardCfgInfoByImpType(self.select_type)
	if imp_guard_cfg_info == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(imp_guard_cfg_info.item_id)
	if nil == item_cfg then
		return
	end

	local function ok_callback()
		PlayerCtrl.Instance:ReqImpGuardOpera(IMP_GUARD_REQ_TYPE.IMP_GUARD_REQ_TYPE_RENEW_KNAPSACK, self.data[self.select_type] and self.data[self.select_type].pack_index)
	end
	local des = string.format(Language.Common.ReNewItemDes, imp_guard_cfg_info.gold_price, item_cfg.name, imp_guard_cfg_info.use_day)
	TipsCtrl.Instance:ShowCommonAutoView("imp_guard_time_out", des, ok_callback)
end

function ImpGuardTimeOutTipView:ClickItem(imp_type)
	if imp_type == self.select_type then
		return
	end
	self.select_type = imp_type

	self:FlushCost()
end

function ImpGuardTimeOutTipView:ReSetData(imp_type, data)
	self.data[imp_type] = data
end

function ImpGuardTimeOutTipView:OpenCallBack()
	self.select_type = -1

	self:Flush()
end

function ImpGuardTimeOutTipView:CloseCallBack()
	self.data = {}
end

function ImpGuardTimeOutTipView:FlushActiveItem()
	for k, v in ipairs(self.item_cell_list) do
		local info = self.data[k]
		if nil == info or info.is_pop_up ~= 1 then
			v:SetParentActive(false)
			if self.select_type == k then
				self.select_type = -1
			end
		else
			v:SetParentActive(true)
			local item_data = ItemData.Instance:GetGridData(info.pack_index) or {}
			v:SetData({item_id = item_data.item_id})
		end
	end


end

function ImpGuardTimeOutTipView:UpDateSelectType()
	for k, _ in pairs(self.data) do
		if self.select_type < 0 then
			self.select_type = k
			break
		end
	end
end

function ImpGuardTimeOutTipView:UpDateToggleIsOn()
	for k, v in ipairs(self.item_cell_list) do
		v:SetToggle(self.select_type == k)
	end
end

--刷新花费
function ImpGuardTimeOutTipView:FlushCost()
	local imp_guard_cfg_info = PlayerData.Instance:GetImpGuardCfgInfoByImpType(self.select_type)
	if imp_guard_cfg_info == nil then
		return
	end

	local bundle, asset = nil, nil
	local cost = 0
	--可以绑元消耗优先显示绑元
	if imp_guard_cfg_info.bind_gold_price > 0 then
		bundle, asset = ResPath.GetImages("bind_diamon")
		cost = imp_guard_cfg_info.bind_gold_price
	else
		bundle, asset = ResPath.GetImages("diamon")
		cost = imp_guard_cfg_info.gold_price
	end
	self.gold_res:SetAsset(bundle, asset)
	self.cost:SetValue(cost)
end

function ImpGuardTimeOutTipView:CheckCanOpen()
	local have_item = false
	for k, v in pairs(self.data) do
		if v.is_pop_up == 1 then
			have_item = true
			break
		end
	end

	if not have_item then
		return false
	end

	return true
end

function ImpGuardTimeOutTipView:OnFlush()
	self:FlushActiveItem()
	self:UpDateSelectType()
	self:UpDateToggleIsOn()
	self:FlushCost()
end