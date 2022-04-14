--超值福利界面
WorthWelfarePanel = WorthWelfarePanel or class("WorthWelfarePanel",BasePanel)

function WorthWelfarePanel:ctor()
    self.abName = "WorthWelfare"
    self.assetName = "WorthWelfarePanel"
    self.layer = "UI"

    self.panel_type = 2
    self.is_hide_other_panel = true

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI

    self.ww_model = WorthWelfareModel.GetInstance()

    self.vip_model = VipModel.GetInstance()
    self.vip_model_events = {}
   
    self.gift_panel = nil  --超值礼包界面
    self.investment_panel = nil  --多倍投资界面
    
    self.investment_reddot = nil   --多倍投资页签红点
end

function WorthWelfarePanel:dctor()

    destroySingle(self.gift_panel)
    self.gift_panel = nil

    destroySingle(self.investment_panel)
    self.investment_panel = nil

    destroySingle(self.investment_reddot)
    self.investment_reddot = nil

    self.vip_model:RemoveTabListener(self.vip_model_events)
    self.vip_model_events = nil
end

function WorthWelfarePanel:LoadCallBack(  )
    self.nodes = {
        "btn_close",
        "btn_parent/btn_investment","btn_parent","btn_parent/btn_gift/gift_highlight","btn_parent/btn_investment/investment_highlight","btn_parent/btn_gift",
        "panel_parent",

        "btn_help",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end

    self:SwitchPanel(1)
end

function WorthWelfarePanel:InitUI(  )
   
end

function WorthWelfarePanel:AddEvent(  )

    --关闭按钮
    local function callback(  )
        self:Close()
    end
    AddClickEvent(self.btn_close.gameObject,callback)

    --问号按钮
    local function callback(  )
        lua_panelMgr:GetPanelOrCreate(WorthWelfareTipPanel):Open()
    end
    AddClickEvent(self.btn_help.gameObject,callback)

    --超值礼包按钮
    local function callback(  )
        self:SwitchPanel(1)
    end
    AddClickEvent(self.btn_gift.gameObject,callback)

    --多倍投资按钮
    local function callback(  )
        self:SwitchPanel(2)
    end
    AddClickEvent(self.btn_investment.gameObject,callback)

    --投资计划信息返回
    local function callback(type,grade,list)
        --刷新多倍投资页签红点
        self:UpdateInvestmentReddot(list)  
    end
    self.vip_model_events[#self.vip_model_events + 1] = self.vip_model:AddListener(VipEvent.HandleInvestInfo2,callback)
end

--data
function WorthWelfarePanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function WorthWelfarePanel:UpdateView()
    self.need_update_view = false

    VipController.GetInstance():RequestInvestInfo2()
end

--切换子界面 1-超值礼包 2-多倍投资
function WorthWelfarePanel:SwitchPanel(index)
    if index == 1 then
        SetVisible(self.gift_highlight,true)
        SetVisible(self.investment_highlight,false)

        if self.investment_panel then
            SetVisible(self.investment_panel.transform,false)
        end

        if self.gift_panel then
            SetVisible(self.gift_panel.transform,true)
        else
            self.gift_panel = WorthWelfareGiftPanel(self.panel_parent)
            self.gift_panel:SetData()
        end

    elseif index == 2 then
        SetVisible(self.gift_highlight,false)
        SetVisible(self.investment_highlight,true)

        if self.gift_panel then
            SetVisible(self.gift_panel.transform,false)
        end

        if self.investment_panel then
            SetVisible(self.investment_panel.transform,true)
        else
            self.investment_panel = WorthWelfareInvestmentPanel(self.panel_parent)
            self.investment_panel:SetData()
        end
    end
end

--刷新多倍投资页签红点和超值福利icon红点
function WorthWelfarePanel:UpdateInvestmentReddot(list)
    local is_reddot = self.ww_model:CheckInvestmentReddot(list)
    self.investment_reddot = self.investment_reddot or RedDot(self.btn_investment)
    SetVisible(self.investment_reddot.transform,is_reddot)
    SetLocalPosition(self.investment_reddot.transform,34,59,0)

    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "worthWelfare", is_reddot)
end
