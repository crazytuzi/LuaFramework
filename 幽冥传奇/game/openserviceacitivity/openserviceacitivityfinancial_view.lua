------------------------------------------------------------
-- 超值理财 配置 FinancingCfg
------------------------------------------------------------

local OpenServiceAcitivityFinancialView = OpenServiceAcitivityFinancialView or BaseClass(SubView)

function OpenServiceAcitivityFinancialView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/openserviceacitivity.png'
	self.config_tab = {
		{"openserviceacitivity_ui_cfg", 13, {0}},
	}

	self.cfg = FinancingCfg
end

function OpenServiceAcitivityFinancialView:LoadCallBack()
	self.info = WelfareData.Instance:GetFinancingInfo()

	self:CreateNumberBar()
	self:CreateFinancialView()

	XUI.AddClickEventListener(self.node_t_list["btn_buy"].node, BindTool.Bind(self.OnBuy, self), true)
	EventProxy.New(WelfareData.Instance, self):AddEventListener(WelfareData.FINANCING_INFO_CHANGE, BindTool.Bind(self.OnFinancingInfoChange, self))
end

function OpenServiceAcitivityFinancialView:ReleaseCallBack()
	if self.yuanbao_num then
		self.yuanbao_num:DeleteMe()
		self.yuanbao_num = nil
	end

	if self.precent_num then
		self.precent_num:DeleteMe()
		self.precent_num = nil
	end

	if self.count_num then
		self.count_num:DeleteMe()
		self.count_num = nil
	end

	if self.vip_num then
		self.vip_num:DeleteMe()
		self.vip_num = nil
	end

	if nil ~= self.update_spare_timer then
		GlobalTimerQuest:CancelQuest(self.update_spare_timer)
		self.update_spare_timer = nil
	end
end

function OpenServiceAcitivityFinancialView:ShowIndexCallBack()
	WelfareCtrl.Instance.FinancingReq(FINANCING_TYPE_DEF.INFO)

	self:Flush()
end

function OpenServiceAcitivityFinancialView:OnFlush()
	self:FlushLeftTime()
	self.count_num:SetNumber(self.info.left_num)

	local list = WelfareData.Instance:GetFinancingItemData()
	self.grid_scroll:SetDataList(list)
	self.grid_scroll:RefreshItems()
	self.grid_scroll:JumpToTop()

	local boor = (not WelfareData.Instance:IsBuyFinancing()) and self.info.left_num > 0
	self.node_t_list["btn_buy"].node:setEnabled(boor)
end

function OpenServiceAcitivityFinancialView:CreateNumberBar()
	local ph

	-- 花费元宝
	ph = self.ph_list["ph_num_yuan"]
	self.yuanbao_num = NumberBar.New()
	self.yuanbao_num:Create(ph.x, ph.y, 0, 0, ResPath.GetCommon("num_150_"))
	self.yuanbao_num:SetGravity(NumberBarGravity.Left)
	self.node_t_list["layout_overflow_financial"].node:addChild(self.yuanbao_num:GetView(), 101)
	self.yuanbao_num:SetSpace(-3)
	self.yuanbao_num:SetNumber(self.cfg.buyPrice)

	-- 百分比
	ph = self.ph_list["ph_num_precent"]
	self.precent_num = NumberBar.New()
	self.precent_num:Create(ph.x, ph.y, 0, 0, ResPath.GetCommon("num_150_"))
	self.precent_num:SetGravity(NumberBarGravity.Left)
	self.node_t_list["layout_overflow_financial"].node:addChild(self.precent_num:GetView(), 101)
	self.precent_num:SetSpace(-4)
	self.precent_num:SetNumber(self.cfg.retYb / self.cfg.buyPrice * 100)

	-- 剩余份数
	ph = self.ph_list["ph_num_count"]
	self.count_num = NumberBar.New()
	self.count_num:Create(ph.x, ph.y, 0, 0, ResPath.GetCommon("num_150_"))
	self.count_num:SetGravity(NumberBarGravity.Left)
	self.node_t_list["layout_overflow_financial"].node:addChild(self.count_num:GetView(), 101)
	self.count_num:SetNumber(self.info.left_num)
	self.count_num:GetView():setColor(COLOR3B.RED)

	-- vip等级
	ph = self.ph_list["ph_num_vip"]
	self.vip_num = NumberBar.New()
	self.vip_num:Create(ph.x, ph.y, 0, 0, ResPath.GetCommon("num_170_"))
	self.vip_num:SetGravity(NumberBarGravity.Left)
	self.node_t_list["layout_overflow_financial"].node:addChild(self.vip_num:GetView(), 101)
	self.vip_num:SetNumber(self.cfg.vipLevel)
end

-- 创建"理财项目"视图
function OpenServiceAcitivityFinancialView:CreateFinancialView()
	local ph_item = self.ph_list["ph_overflow_financial_item"]
	local ph = self.ph_list["ph_overflow_invest"]
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.h + 5, self.ItemsShow, ScrollDir.Vertical, false, ph_item)
	self.node_t_list["layout_overflow_financial"].node:addChild(grid_scroll:GetView(), 20)
	local list = WelfareData.Instance:GetFinancingItemData()
	grid_scroll:SetDataList(list)
	self.grid_scroll = grid_scroll
end

-- 刷新剩余时间
function OpenServiceAcitivityFinancialView:FlushLeftTime()
	local left_time = WelfareData.Instance.GetFinancingLeftTime()
	self.node_t_list["lbl_time"].node:setString("有效时间:" .. TimeUtil.FormatSecond2Str(left_time))
	if nil ~= self.update_spare_timer then
		GlobalTimerQuest:CancelQuest(self.update_spare_timer)
		self.update_spare_timer = nil
	end
	self.update_spare_timer = GlobalTimerQuest:AddRunQuest(function ()
		local left_time = WelfareData.Instance.GetFinancingLeftTime()
		self.node_t_list["lbl_time"].node:setString("有效时间:" .. TimeUtil.FormatSecond2Str(left_time))
	end, 1)
end

----------------------------------------

function OpenServiceAcitivityFinancialView:OnBuy()
	WelfareCtrl.Instance.FinancingReq(FINANCING_TYPE_DEF.BUY)
end

function OpenServiceAcitivityFinancialView:OnFinancingInfoChange()
	self:Flush()
end

----------------------------------------
-- 超值理财项目
----------------------------------------

OpenServiceAcitivityFinancialView.ItemsShow = BaseClass(BaseRender)
local ItemsShow = OpenServiceAcitivityFinancialView.ItemsShow
function ItemsShow:__init()
	self.level_num = nil
	self.earning_num = nil
end

function ItemsShow:__delete()
	if self.level_num then
		self.level_num:DeleteMe()
		self.level_num = nil
	end
	if self.earning_num then
		self.earning_num:DeleteMe()
		self.earning_num = nil
	end
end

function ItemsShow:CreateChild()
	BaseRender.CreateChild(self)
	ph = self.ph_list["ph_num_level"]
	self.level_num = NumberBar.New()
	self.level_num:Create(ph.x, ph.y, 0, 0, ResPath.GetCommon("num_150_"))
	self.level_num:SetGravity(NumberBarGravity.Left)
	self.view:addChild(self.level_num:GetView(), 101)

	ph = self.ph_list["ph_num_earning"]
	self.earning_num = NumberBar.New()
	self.earning_num:Create(ph.x, ph.y, 0, 0, ResPath.GetCommon("num_171_"))
	self.earning_num:SetGravity(NumberBarGravity.Left)
	self.view:addChild(self.earning_num:GetView(), 101)

	self.node_tree["btn_get"].remind_eff = RenderUnit.CreateEffect(23, self.node_tree["btn_get"].node, 1)

	XUI.AddClickEventListener(self.node_tree["btn_get"].node, BindTool.Bind(self.OnGet, self))
end

function ItemsShow:OnFlush()
	if nil == self.data then return end
	self.level_num:SetNumber(self.data.circle + self.data.level)
	self.earning_num:SetNumber(self.data.yb)

	local w = self.level_num.number_bar:getContentSize().width
	w = w > 22 and 0 or 10
	local x = 103 + w
	self.level_num:GetView():setPositionX(x)

	if self.data.circle > 0 then
		self.node_tree["img_level"].node:loadTexture(ResPath.GetOpenServerActivity("overflow_invest_2"))
	end

	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local role_zhuan = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local vis = role_zhuan >= self.data.circle and role_level >= self.data.level
	self.node_tree["btn_get"].node:setVisible(vis)
	self.node_tree["btn_get"].remind_eff:setVisible(vis)
	self.node_tree["img_miss"].node:setVisible(not vis)

	local boor = WelfareData.Instance:IsBuyFinancing()
	self.node_tree["btn_get"].remind_eff:setVisible(boor and vis)
	self.node_tree["btn_get"].node:setEnabled(boor)
end

function ItemsShow:OnGet()
	WelfareCtrl.Instance.FinancingReq(FINANCING_TYPE_DEF.RECEIVE, self.data.index)
end

function ItemsShow:CreateSelectEffect()
	return
end

function ItemsShow:OnClickBuyBtn()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function ItemsShow:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end
--------------------

return OpenServiceAcitivityFinancialView