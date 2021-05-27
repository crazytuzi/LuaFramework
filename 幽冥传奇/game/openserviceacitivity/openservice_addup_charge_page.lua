-- 开服连续充值
OpenServiceAddupChargePage = OpenServiceAddupChargePage or BaseClass()

function OpenServiceAddupChargePage:__init()
	self.view = nil
	
end	

function OpenServiceAddupChargePage:__delete()
	self:RemoveEvent()
	self.view = nil
end	

--初始化页面接口
function OpenServiceAddupChargePage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.end_time = OtherData.Instance.open_server_time + 6 * 24 * 60 * 60
	self:InitEvent()
	self:CreateList()
	self:CreateRewardCell()
	self:OnOpenSerAddupChargeDataChange()
	XUI.RichTextSetCenter(self.view.node_t_list.rich_addupcharge_rest_ftime.node)
end	

--初始化事件
function OpenServiceAddupChargePage:InitEvent()
	self.hero_wing_evt = GlobalEventSystem:Bind(OpenServerActivityEventType.OPENSERVER_ADDUP_CHARGE_GIVE, BindTool.Bind(self.OnOpenSerAddupChargeDataChange, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushRestTime, self), 1)
	XUI.AddClickEventListener(self.view.node_t_list.btn_fetch_final_gift.node, BindTool.Bind(self.OnFetchAward, self))
	XUI.AddClickEventListener(self.view.node_t_list.btn_go_charge_now_1.node, BindTool.Bind(self.OnGoCharge, self), true)
end

--移除事件
function OpenServiceAddupChargePage:RemoveEvent()
	if self.hero_wing_evt then
		GlobalEventSystem:UnBind(self.hero_wing_evt)
		self.hero_wing_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

	if self.cell_gift_list then
		for k, v in pairs(self.cell_gift_list) do
			v:DeleteMe()
		end
		self.cell_gift_list = nil
	end

	if self.grid_list_view then
		self.grid_list_view:DeleteMe()
		self.grid_list_view = nil
	end

	if self.item_cells_list then
		for _, v in pairs(self.item_cells_list) do
			v:DeleteMe()
		end
		self.item_cells_list = nil
	end

end

--更新视图界面
function OpenServiceAddupChargePage:UpdateData(data)
	-- OpenServiceAcitivityCtrl.Instance:GetAddupChargeGiveData(0)
	self:FlushRestTime()
end

function OpenServiceAddupChargePage:CreateRewardCell()
	self.cell_gift_list = {}
	local data = OpenServiceAcitivityData.GetAddupChargeExtraAwards()
	for i = 1, 7 do
		local cell = BaseCell.New()
		local ph = self.view.ph_list["ph_addup_gift_cell_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		cell:SetData(data[i])
		self.view.node_t_list.layout_final_gift_cells.node:addChild(cell:GetView(), 300)

		local cell_effect = AnimateSprite:create()
		cell_effect:setPosition(ph.x, ph.y)
		local path, name = ResPath.GetEffectUiAnimPath(920)
		if path and name then
			cell_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		end
		self.view.node_t_list.layout_final_gift_cells.node:addChild(cell_effect, 300)
		cell.cell_effect = cell_effect

		table.insert(self.cell_gift_list, cell)
	end
end

function OpenServiceAddupChargePage:CreateList()
	self.item_cells_list = {}
	local ph = self.view.ph_list.ph_item_grid_addup
	local item_ui_cfg = self.view.ph_list.ph_addup_charge_item
	local item, x, y = nil, nil, item_ui_cfg.y
	local interval = (ph.w - item_ui_cfg.w * 5 - 8) / 4
	-- self.grid_list_view = ListView.New()	
	-- self.grid_list_view:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, OpenSerAddupChargeItem, nil, false, item_ui_cfg)
	-- self.grid_list_view:SetItemsInterval(interval)
	-- self.grid_list_view:SetMargin(4)
	for i = 1, 5 do
		x = item_ui_cfg.x + (i - 1) * (interval + item_ui_cfg.w)
		item = OpenSerAddupChargeItem.New()
		item:SetIndex(i)
		item:SetUiConfig(item_ui_cfg, true)
		item:SetPosition(x, y)
		self.view.node_t_list.layout_addup_charge_give_gift.node:addChild(item:GetView(), 999)
		table.insert(self.item_cells_list, item)
	end
	-- self.view.node_t_list.layout_addup_charge_give_gift.node:addChild(self.grid_list_view:GetView(), 999)
	
end

function OpenServiceAddupChargePage:OnOpenSerAddupChargeDataChange()
	local data = OpenServiceAcitivityData.Instance:GetAddupChargeGiveGiftData()
	if data then
		local percent = (data.charge_day - 1) * 25
		self.view.node_t_list.addup_charge_prog.node:setPercent(percent)
		self.view.node_t_list.btn_fetch_final_gift.node:setEnabled(data.fetch_state == 1)
	end
	data = OpenServiceAcitivityData.Instance:GetAddupChargeNormalAwarInfo()
	for k, v in pairs(data) do
		local item = self.item_cells_list[k]
		if item then
			item:SetData(v)
		end
	end
	-- self.grid_list_view:SetData(data)
end

function OpenServiceAddupChargePage:FlushRestTime()
	local rest_time = self.end_time - TimeCtrl.Instance:GetServerTime()
	if rest_time >= 0 then
		local time_str = TimeUtil.FormatSecond2Str(rest_time)
		time_str = string.format(Language.OpenServiceAcitivity.AddupCharFetCdContect, time_str)
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_addupcharge_rest_ftime.node, time_str, 20)
	end
end

function OpenServiceAddupChargePage:OnFetchAward()
	OpenServiceAcitivityCtrl.Instance:GetAddupChargeGiveData(1)
end

function OpenServiceAddupChargePage:OnGoCharge()
	ViewManager.Instance:Open(ViewName.ChargePlatForm)
end