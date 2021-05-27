
ActChargeFanliView = ActChargeFanliView or BaseClass(BaseView)

function ActChargeFanliView:__init()

	if	ActChargeFanliView.Instance then
		ErrorLog("[ActChargeFanliView]:Attempt to create singleton twice!")
	end

	self:SetBackRenderTexture(true)
	
	self.texture_path_list[1] = 'res/xui/act_limit_charge.png'
	self.config_tab = {
		{"charge_fanli_ui_cfg", 1, {0}},
		{"charge_fanli_ui_cfg", 2, {0}},
	}
end

function ActChargeFanliView:__delete()
end

function ActChargeFanliView:ReleaseCallBack()
    if self.act_spare_time then
		GlobalTimerQuest:CancelQuest(self.act_spare_time)
		self.act_spare_time = nil
	end

	if self.charge_level_list then
		self.charge_level_list:DeleteMe()
		self.charge_level_list = nil
	end
end

function ActChargeFanliView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateSpareTimer()
		self:CreateChargeLevelList()
		XUI.AddClickEventListener(self.node_t_list.layout_charge_now.node, BindTool.Bind(self.OnClickCharge, self), true)
	end
	self:Flush()
end

function ActChargeFanliView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self:Flush()
end

function ActChargeFanliView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ActChargeFanliView:CreateChargeLevelList()
	local ph = self.ph_list.ph_charge_list
	self.charge_level_list = ListView.New()
	self.charge_level_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, ChargeFanliRender, nil, nil, self.ph_list.ph_charge_item)
	self.charge_level_list:GetView():setAnchorPoint(0.5, 0.5)
	-- self.charge_level_list:SetItemsInterval(-20)
	self.node_t_list.layout_charge_fanli.node:addChild(self.charge_level_list:GetView(), 100)
end

function ActChargeFanliView:OnFlush(param_list, index)
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CZFL)
	self.node_t_list.lbl_fanli_gold.node:setString(ActivityBrilliantData.Instance:GetChargeFanli() .. Language.Common.Gold)
	if cfg and cfg.config then 
		self.charge_level_list:SetDataList(cfg.config)
	end	
end

function ActChargeFanliView:UpdateSpareTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CZFL)
	if nil == cfg then return end
	local now_time =TimeCtrl.Instance:GetServerTime()
	local end_time = cfg.end_time 
	local spare_time = end_time - now_time 
	self.node_t_list.layout_charge_fanli.lbl_limit_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function ActChargeFanliView:CreateSpareTimer()
	self.act_spare_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateSpareTime, self), 1)
end

function ActChargeFanliView:OnClickCharge()
	ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
end




ChargeFanliRender = ChargeFanliRender or BaseClass(BaseRender)
function ChargeFanliRender:__init()	
end

function ChargeFanliRender:__delete()	
end

function ChargeFanliRender:CreateChild()
	BaseRender.CreateChild(self)
end

function ChargeFanliRender:OnFlush()
	if nil == self.data then return end
	local range_str = string.format(Language.ActivityBrilliant.SingleChargeRange[2], self.data.minPayMoney)
	if self.data.maxPayMoney then 
		range_str = string.format(Language.ActivityBrilliant.SingleChargeRange[1], self.data.minPayMoney, self.data.maxPayMoney)
	end
	local rate_str = string.format(Language.ActivityBrilliant.ChargeFanliRate, self.data.rebateRate / 100 .. "%")
	self.node_tree.lbl_chrage_range.node:setString(range_str)
	self.node_tree.lbl_fanli_rate.node:setString(rate_str)
end

function ChargeFanliRender:CreateSelectEffect()
end