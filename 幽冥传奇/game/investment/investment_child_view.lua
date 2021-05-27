------------------------------------------------------------
-- 超值投资视图
------------------------------------------------------------

local InvestmentChildView = BaseClass(SubView)

function InvestmentChildView:__init()
	self.texture_path_list[1] = 'res/xui/investment.png'
	self.config_tab = {
		{"investment_ui_cfg", 1, {0}},
	}
end

function InvestmentChildView:__delete()
end

function InvestmentChildView:ReleaseCallBack()
    if self.reward_scroll_list then
        self.reward_scroll_list:DeleteMe()
        self.reward_scroll_list = nil
    end

    if self.extra_award_list then
        self.extra_award_list:DeleteMe()
        self.extra_award_list = nil
    end
    
    if self.need_numberbar then
        self.need_numberbar:DeleteMe()
        self.need_numberbar = nil
    end

    if self.retrun_numberbar then
        self.retrun_numberbar:DeleteMe()
        self.retrun_numberbar = nil
    end

end

function InvestmentChildView:LoadCallBack(index, loaded_times)
    self:CreateRewardListView()
    self:CreateNumberBar()

    XUI.AddClickEventListener(self.node_t_list.btn_pay_money.node, BindTool.Bind(self.OnClickPayBtn, self), true)
    XUI.AddClickEventListener(self.node_t_list.btn_instructions.node, BindTool.Bind(self.OnClickTips, self))

    EventProxy.New(InvestmentData.Instance, self):AddEventListener(InvestmentData.RewardChange, BindTool.Bind(self.Flush, self))
end

--显示索引回调
function InvestmentChildView:ShowIndexCallBack(index)
    self:Flush()
end

----------视图函数----------

function InvestmentChildView:OnFlush()
    self:RefreshView()
end

function InvestmentChildView:RefreshView()
    self.reward_scroll_list:SetDataList(InvestmentData.Instance:GetDaliyList())
    self.extra_award_list:SetDataList(InvestmentData.Instance:GetExtraList())
    local is_active = InvestmentData.Instance:IsActive()
    self.node_t_list.lbl_active.node:setVisible(is_active)
    self.node_t_list.btn_pay_money.node:setVisible(not is_active)
    if InvestmentData.Instance:IsCloseView() then
        self:Close()
    end
end

function InvestmentChildView:CreateRewardListView()
    if nil == self.reward_scroll_list then
        local ph = self.ph_list.ph_qianggou_view_list
        self.reward_scroll_list = ListView.New()
        self.reward_scroll_list:Create( ph.x, ph.y, ph.w, ph.h, nil, self.InvestItemRender, nil, nil, self.ph_list.ph_leichong_list)
        self.node_t_list.layout_investment.node:addChild(self.reward_scroll_list:GetView(), 100)
        self.reward_scroll_list:SetJumpDirection(ListView.Top)
        self.reward_scroll_list:SetMargin(2) --首尾留空
    end

    if nil == self.extra_award_list then
        local ph = self.ph_list.ph_extra_award_list
        self.extra_award_list = ListView.New()
        self.extra_award_list:Create( ph.x, ph.y, ph.w, ph.h, nil, self.ExtraAwardItem, nil, nil, self.ph_list.ph_extra_award_item)
        self.node_t_list.layout_investment.node:addChild(self.extra_award_list:GetView(), 100)
        self.extra_award_list:SetJumpDirection(ListView.Top)
        self.extra_award_list:SetMargin(2) --首尾留空
    end
end

function InvestmentChildView:CreateNumberBar()
    local ph
    ph = self.ph_list["ph_need_number"]
    self.need_numberbar = NumberBar.New()
    self.need_numberbar:Create(ph.x, ph.y, ph.w, ph.y, ResPath.GetCommon("num_115_"))
    self.need_numberbar:SetSpace(-4)
    self.need_numberbar:SetGravity(NumberBarGravity.Center)
    self.need_numberbar:SetNumber(InvestmentCfg.investmentYB)
    -- self.need_numberbar:GetView():setAnchorPoint(0.5, 0.5)
    self.node_t_list.layout_top.node:addChild(self.need_numberbar:GetView(),100)

    ph = self.ph_list["ph_retrun_number"]
    self.retrun_numberbar = NumberBar.New()
    self.retrun_numberbar:Create(ph.x, ph.y, ph.w, ph.y, ResPath.GetCommon("num_115_"))
    self.retrun_numberbar:SetSpace(-4)
    self.retrun_numberbar:SetGravity(NumberBarGravity.Center)
    self.retrun_numberbar:SetNumber(300)
    -- self.retrun_numberbar:GetView():setAnchorPoint(0.5, 0.5)
    self.node_t_list.layout_top.node:addChild(self.retrun_numberbar:GetView(),100)
end

----------end----------

function InvestmentChildView:OnClickTips()
    local content = string.format(Language.Investment.TipContent, InvestmentCfg.investmentYB, InvestmentCfg.investmentYB)
    DescTip.Instance:SetContent(content, Language.Investment.TipTitle)
end

function InvestmentChildView:OnClickPayBtn()
    if IS_ON_CROSSSERVER then return end
    ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
end

--------------------

-------------------------------------------------------------------------------------------------------------------
InvestmentChildView.InvestItemRender = InvestmentChildView.InvestItemRender or BaseClass(BaseCell)
local InvestItemRender = InvestmentChildView.InvestItemRender
function InvestItemRender:__init()
end

function InvestItemRender:__delete()
    self.awards_list:DeleteMe()
end

function InvestItemRender:CreateChild()
    BaseRender.CreateChild(self)
    XUI.AddClickEventListener(self.node_tree.btn_award_lingqu.node, BindTool.Bind(self.OnClickBuyBtn, self))
    local ph = self.ph_list.ph_award_list_view
    self.awards_list = ListView.New()
    self.awards_list:Create( ph.x+5, ph.y, ph.w, ph.h,  ScrollDir.Horizontal, self.InvestBaseCell, nil, nil,self.ph_list.ph_awrad)
    self.view:addChild(self.awards_list:GetView(), 100)
    self.awards_list:SetJumpDirection(ListView.Left)
    self.awards_list:SetItemsInterval(15)
    self.awards_list:SetMargin(5) --首尾留空
end

function InvestItemRender:OnClickBuyBtn()
    InvestmentCtrl.Instance.RequestInvestmentInfo(2,self.data.day)
end

function InvestItemRender:OnFlush()
    if nil == self.data then
        return
    end
    self.node_tree.lbl_reward_day.node:setString(string.format(Language.Investment.DayText,self.data.day))
    if(self.data.awards) then
         self.awards_list:SetDataList(self.data.awards)
    end
    local text = ""
    if self.data.day <= InvestmentData.Instance:GetCanReceivedNum() then
        text = self.data.isReceive == 1 and Language.Common.YiLingQu or Language.Common.LingQu
    else
        text = Language.Common.WeiDaCheng
    end
    self.node_tree.btn_award_lingqu.node:setTitleText(text)

    local bool = self.data.isReceive == 0 and (self.data.day <= InvestmentData.Instance:GetCanReceivedNum())
    self.node_tree.btn_award_lingqu.node:setEnabled(bool)
end

function InvestItemRender:CreateSelectEffect()
	return
end

function InvestItemRender:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end


-----------------------------------------------------------------
InvestItemRender.InvestBaseCell = InvestItemRender.InvestBaseCell or BaseClass(BaseCell)
local InvestBaseCell = InvestItemRender.InvestBaseCell
function InvestBaseCell:OnFlush()
    BaseCell.OnFlush(self)
    self:SetQualityEffect(self.data and self.data.effectId or 0)
    if self.data.lock == 1 then
        self.view:setTouchEnabled(false)
    end
end

function InvestBaseCell:CreateSelectEffect()
    return
end

----------------------------------------
-- 额外奖励item
----------------------------------------
InvestmentChildView.ExtraAwardItem = BaseClass(BaseRender)
local ExtraAwardItem = InvestmentChildView.ExtraAwardItem
function ExtraAwardItem:__init()
    self.cell_list = {}
end

function ExtraAwardItem:__delete()

    if self.cell_list then
        for i,v in ipairs(self.cell_list) do
            v:DeleteMe()
        end
        self.cell_list = nil
    end

end

function ExtraAwardItem:CreateChild()
    BaseRender.CreateChild(self)
    for i = 1, 4 do
        local ph = self.ph_list["ph_cell_" .. i]
        local cell = BaseCell.New()
        cell:SetPosition(ph.x, ph.y)
        cell:GetView():setAnchorPoint(0.5, 0.5)
        self.view:addChild(cell:GetView(), 20)
        self.cell_list[i] = cell
    end

    self.node_tree["btn_1"].node:addClickEventListener(BindTool.Bind(self.OnGet, self, 3))
    self.node_tree["btn_2"].node:addClickEventListener(BindTool.Bind(self.OnGet, self, 4))
end

function ExtraAwardItem:OnFlush()
    if nil == self.data then return end

    local vip_awards = self.data.vip_award_cfg or {}
    local power_awards = self.data.power_award_cfg or {}
    local is_active = InvestmentData.Instance:IsActive() --活动是否激活

    if next(vip_awards) ~= nil then
        local vip_lv = vip_awards.viplvLimt or 0
        local vip_text = string.format(Language.Investment.VipText, vip_lv)
        local bool = self.data.vip_is_received == 0
        local bool2 = VipData.Instance:GetVipLevel() >= vip_lv
        local vip_btn_text = bool and Language.Common.LingQu or Language.Common.YiLingQu
        vip_btn_text = bool2 and vip_btn_text or Language.Common.WeiDaCheng
        self.node_tree["lbl_vip"].node:setString(vip_text)
        self.node_tree["btn_1"].node:setTitleText(vip_btn_text)
        self.node_tree["btn_1"].node:setEnabled(is_active and bool and bool2)
        -- self.node_tree.node:setVisible(true)
    else
        -- self.node_tree.node:setVisible(false)
    end

    if next(power_awards) ~= nil then
        local power = power_awards and power_awards.powerLimit or 0
        if power >= 10000 then
            power = power / 10000 .. "W"
        end
        local power_text = string.format(Language.Investment.PowerText, power)
        local bool = self.data.power_is_received == 0
        local power = power_awards and power_awards.powerLimit or 0
        local bool2 = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BATTLE_POWER) >= power
        local power_btn_text = bool and Language.Common.LingQu or Language.Common.YiLingQu
        power_btn_text = bool2 and power_btn_text or Language.Common.WeiDaCheng
        self.node_tree["lbl_power"].node:setString(power_text)
        self.node_tree["btn_2"].node:setTitleText(power_btn_text)
        self.node_tree["btn_2"].node:setEnabled(is_active and bool and bool2)
        -- self.node_tree.node:setVisible(true)
    else
        -- self.node_tree.node:setVisible(false)
    end

    local award = {}
    award[1] = vip_awards.award and vip_awards.award[1]
    award[2] = vip_awards.award and vip_awards.award[2]
    award[3] = power_awards.award and power_awards.award[1]
    award[4] = power_awards.award and power_awards.award[2]
    for i,v in pairs(self.cell_list) do
        if award[i] then
            v:SetData(award[i])
            v:SetVisible(true)
        else
            v:SetVisible(false)
        end
    end

end

function ExtraAwardItem:OnGet(type)
    InvestmentCtrl.Instance.RequestInvestmentInfo(type, self.data.index)
end

function ExtraAwardItem:CreateSelectEffect()
    return
end

return InvestmentChildView