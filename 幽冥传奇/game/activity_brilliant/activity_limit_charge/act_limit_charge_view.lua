------------------------------------------------------------
-- 运营活动 74 限时充值 
------------------------------------------------------------

ActLimitChargeView = ActLimitChargeView or BaseClass(BaseView)

function ActLimitChargeView:__init()
	self:SetBackRenderTexture(true)

	self.texture_path_list[1] = 'res/xui/act_limit_charge.png'
	self.config_tab = {
		{"limit_charge_ui_cfg", 1, {0}},
		{"limit_charge_ui_cfg", 2, {0}},
	}
end

function ActLimitChargeView:__delete()
end

function ActLimitChargeView:ReleaseCallBack()
    if self.tower_spare_time then
		GlobalTimerQuest:CancelQuest(self.tower_spare_time)
		self.tower_spare_time = nil
	end

	if self.charge_num then
		self.charge_num:DeleteMe()
		self.charge_num = nil
	end

	if self.award_list then
		self.award_list:DeleteMe()
		self.award_list = nil
	end

	if self.charge_level_list then
		self.charge_level_list:DeleteMe()
		self.charge_level_list = nil
	end
end

function ActLimitChargeView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateSpareTimer()
		self:CreateAwardList()
		self:CreateChargeLevelList()
		self:CreateChargeNumber()
		XUI.AddClickEventListener(self.node_t_list.layout_lingqu_btn.node, BindTool.Bind(self.OnClickGetAward, self), true)
		XUI.AddClickEventListener(self.node_t_list.layout_charge_btn.node, BindTool.Bind(self.OnClickCharge, self), true)
		self.node_t_list.layout_lingqu_btn.node:setVisible(false)
		self.node_t_list.layout_charge_btn.node:setVisible(false)
		self.get_gift_btn_eff = RenderUnit.CreateEffect(909, self.node_t_list.layout_lingqu_btn.node, 10, nil, nil, 95, 75)
		self.get_gift_btn_eff:setScaleX(0.85)
		self.selevt_index = 1
		self.has_lingqu = nil
	end
end

function ActLimitChargeView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	-- ActivityBrilliantCtrl.ActivityReq(2, ACT_ID.XSCZ)
end

function ActLimitChargeView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ActLimitChargeView:ShowIndexCallBack(index)
	self:Flush()
end

function ActLimitChargeView:CreateChargeNumber()
	local ph = self.ph_list.ph_num
	self.charge_num = NumberBar.New()
	self.charge_num:SetRootPath(ResPath.GeActLimitCharge("num_act_73_"))
	self.charge_num:SetPosition(ph.x + 54, ph.y + 2)
	self.charge_num:SetSpace(5)
	self.charge_num:SetGravity(NumberBarGravity.Center)
	self.node_t_list.layout_limit_charge.node:addChild(self.charge_num:GetView(), 300, 300)
end

function ActLimitChargeView:CreateAwardList()
	local ph = self.ph_list.ph_award_list
	self.award_list = ListView.New()
	self.award_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	self.award_list:GetView():setAnchorPoint(0, 0)
	self.award_list:SetItemsInterval(10)
	self.node_t_list.layout_limit_charge.node:addChild(self.award_list:GetView(), 100)
end

function ActLimitChargeView:CreateChargeLevelList()
	local ph = self.ph_list.ph_btn_list
	self.charge_level_list = ListView.New()
	self.charge_level_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ChargeLevelRender, nil, nil, self.ph_list.ph_btn_item)
	self.charge_level_list:GetView():setAnchorPoint(0, 0)
	self.charge_level_list:SetItemsInterval(0)
	self.charge_level_list:SetSelectCallBack(BindTool.Bind(self.OnSelectCallBack, self))
	self.node_t_list.layout_limit_charge.node:addChild(self.charge_level_list:GetView(), 100)
end

function ActLimitChargeView:OnFlush(param_list, index)
	local charge_list = ActivityBrilliantData.Instance:GetLimitChargeList()
	self.charge_level_list:SetDataList(charge_list)

	local bool = true
	for i,v in ipairs(charge_list) do
		if v.sign == 0 then
			self.selevt_index = i
			bool = false
			break
		end
	end

	if bool then
		ViewManager.Instance:CloseViewByDef(self.view_def)
	end

	self.charge_level_list:SelectIndex(self.selevt_index)
end

function ActLimitChargeView:UpdateSpareTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.XSCZ)
	if nil == cfg then return end
	local now_time =TimeCtrl.Instance:GetServerTime()
	local end_time = cfg.end_time 
	local spare_time = end_time - now_time 
	self.node_t_list.layout_limit_charge.lbl_limit_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function ActLimitChargeView:CreateSpareTimer()
	self.tower_spare_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateSpareTime, self), 1)
end

function ActLimitChargeView:OnSelectCallBack(item)
	local data = item:GetData()
	self.selevt_index = data.index
	local ph = self.ph_list.ph_award_list
	local lost_money = data.paymoney - data.charge_money
	local margin = ph.w - table.getn(data.award) * (BaseCell.SIZE + 10)
	local data_list = {}
	for k, v in pairs(data.award) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.FormatItemData(v))
		end
	end
	self.award_list:SetDataList(data_list)
	self.award_list:SetMargin(margin > 0 and margin / 2 or 0)
	self.charge_num:SetNumber(lost_money > 0 and lost_money or 0)
	self.node_t_list.layout_lingqu_btn.node:setVisible(lost_money <= 0)
	self.node_t_list.layout_charge_btn.node:setVisible(lost_money > 0)
	self:SetGetGiftBtnGrey(data.sign == 1)
end

function ActLimitChargeView:SetGetGiftBtnGrey(is_grey)
	if not self.node_t_list.layout_lingqu_btn then return end
	self.node_t_list.layout_lingqu_btn.img_bg.node:setGrey(is_grey)
	self.node_t_list.layout_lingqu_btn.img_txt.node:setGrey(is_grey)
	self.get_gift_btn_eff:setVisible(not is_grey)
	self.has_lingqu = is_grey
	self.node_t_list.layout_lingqu_btn.node:setIsHittedScale(not is_grey)
end

function ActLimitChargeView:OnClickCharge()
	ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
end

function ActLimitChargeView:OnClickGetAward()
	if not self.has_lingqu then
		ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.XSCZ, self.selevt_index)
	end
end




ChargeLevelRender = ChargeLevelRender or BaseClass(BaseRender)
function ChargeLevelRender:__init()	
end

function ChargeLevelRender:__delete()	
	if self.charge_money then
		self.charge_money:DeleteMe()
		self.charge_money = nil
	end
end

function ChargeLevelRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_num
	self.charge_money = NumberBar.New()
	self.charge_money:SetRootPath(ResPath.GeActLimitCharge("num_act_75_"))
	self.charge_money:SetPosition(ph.x + 20, ph.y)
	self.charge_money:SetSpace(-7)
	self.charge_money:SetGravity(NumberBarGravity.Center)
	self.view:addChild(self.charge_money:GetView(), 300, 300)
	
	-- self.danwei = XUI.CreateImageView(ph.x, ph.y, "")
	-- self.danwei:setAnchorPoint(0, 0)
	-- self.view:addChild(self.danwei, 300, 300)
end

function ChargeLevelRender:OnFlush()
	if self.data == nil then return end
	local ph = self.ph_list.ph_num
	local money = self.data.paymoney
	local res_path = ""
	if self.data.paymoney % 10000 == 0 then
		money = self.data.paymoney / 10000
		res_path = "num_wan"
	elseif self.data.paymoney % 1000 == 0 then 
		money = self.data.paymoney / 1000
		res_path = "num_qian"
	end
	money = self.data.paymoney / ChongzhiData.Instance:GetRechargeRate()
	self.charge_money:SetNumber(money)
	-- local size = self.charge_money:GetNumberBar():getContentSize()
	-- self.danwei:loadTexture(ResPath.GeActLimitCharge(res_path))
	-- self.danwei:setPosition(ph.x + size.width + 3, ph.y - 5)
	self.node_tree.img_btn_bg.node:loadTexture(ResPath.GeActLimitCharge("btn_" .. self.data.index))
end

function ChargeLevelRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width + 2, size.height + 2, ResPath.GetCommon("img9_285"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end