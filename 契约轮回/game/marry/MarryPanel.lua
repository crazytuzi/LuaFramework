---
--- Created by  Administrator
--- DateTime: 2019/6/3 10:06
---
MarryPanel = MarryPanel or class("MarryPanel", BasePanel)
local this = MarryPanel

function MarryPanel:ctor(parent_node, parent_panel)
    self.abName = "marry"
    self.assetName = "MarryPanel"
    self.image_ab = "marry_image";
    self.layer = "UI"
    self.panelType = 0
    self.use_background = true
    self.panel_type = 2
    self.events = {}
    self.btnList = {}
    self.index = 0
    self.is_show_money = { Constant.GoldType.Coin, Constant.GoldType.BGold, Constant.GoldType.Gold }
    self.model = MarryModel:GetInstance()

    self.is_show_open_action = true

    --   self.show_sidebar = true        --是否显示侧边栏

    --if self.show_sidebar then
    --    -- 侧边栏配置
    --    self.sidebar_data = {
    --        { text = ConfigLanguage.Marry.Friend, id = 1 },
    --        { text = ConfigLanguage.Marry.Marry, id = 2 },
    --        { text = ConfigLanguage.Marry.Active, id = 3 },
    --    }
    --end
    -- print2(self.model.has_marry,"是否结过婚")
    if self.model.has_marry then
        --结过婚
        self.marryTypes = {
            -- { text = ConfigLanguage.Marry.Friend, id = 1 },
            { text = ConfigLanguage.Marry.info, id = 4 },
            { text = ConfigLanguage.Marry.Marry, id = 2 },
            { text = ConfigLanguage.Marry.ring, id = 3 },
            { text = ConfigLanguage.Marry.Friend, id = 1 },
            -- { text = ConfigLanguage.Marry.Active, id = 3 },
            { text = ConfigLanguage.Marry.CPDungeon, id = 5 },
        }
    else
        self.marryTypes = {
            { text = ConfigLanguage.Marry.Friend, id = 1 },
            { text = ConfigLanguage.Marry.Marry, id = 2 },
            { text = ConfigLanguage.Marry.ring, id = 3 },
            -- { text = ConfigLanguage.Marry.info, id = 4 },
            -- { text = ConfigLanguage.Marry.Active, id = 3 },
            { text = ConfigLanguage.Marry.CPDungeon, id = 5 },
        }

    end
    --self.marryTypes = {
    --    { text = ConfigLanguage.Marry.Friend, id = 1 },
    --    { text = ConfigLanguage.Marry.Marry, id = 2 },
    --    { text = ConfigLanguage.Marry.ring, id = 3 },
    --    { text = ConfigLanguage.Marry.info, id = 4 },
    --   -- { text = ConfigLanguage.Marry.Active, id = 3 },
    --}
end

function MarryPanel:dctor()
    if self.open_cp_panel_event_id then
        GlobalEvent:RemoveListener(self.open_cp_panel_event_id)
        self.open_cp_panel_event_id = nil
    end
    self.model:RemoveTabListener(self.events)
    for _, item in pairs(self.money_list) do
        item:destroy()
    end
    self.money_list = {}

    for _, item in pairs(self.btnList) do
        item:destroy()
    end
    self.btnList = {}

    if self.currentView then
        self.currentView:destroy();
    end
    if self.close_event_id then
        GlobalEvent:RemoveListener(self.close_event_id)
        self.close_event_id = nil
    end
end

function MarryPanel:Open(index)
    self.index = index
    WindowPanel.Open(self)
end

function MarryPanel:LoadCallBack()
    self.nodes = {
        "pageItemParent", "panelParent", "MarryPageItem", "closeBtn", "title/titleImg", "money_con", "static/Image",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    self:SetMoney(self.is_show_money)
    self:MarryRedPoint()
end

function MarryPanel:InitUI()
    DungeonCtrl.GetInstance():RequestDungeonPanel(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COUPLE)
    local index = 0
    for i = 1, #self.marryTypes do
        local id = self.marryTypes[i].id
        if self.marryTypes[i].id == 2 then
            --三步走
            if self.model:IsOpenThreeAct() then
                index = index + 1
                self.btnList[index] = MarryPageItem(self.MarryPageItem.gameObject, self.pageItemParent, "UI")
                self.btnList[index]:SetData(self.marryTypes[i])
            end
        elseif self.marryTypes[i].id == 3 then
            if self.model:IsRingAct() then
                index = index + 1
                self.btnList[index] = MarryPageItem(self.MarryPageItem.gameObject, self.pageItemParent, "UI")
                self.btnList[index]:SetData(self.marryTypes[i])
            end
        elseif self.marryTypes[i].id == 5 then
            if self:CheckSideBarShow() then
                index = index + 1
                self.btnList[index] = MarryPageItem(self.MarryPageItem.gameObject, self.pageItemParent, "UI")
                self.btnList[index]:SetData(self.marryTypes[i])
            end
        else
            index = index + 1
            self.btnList[index] = MarryPageItem(self.MarryPageItem.gameObject, self.pageItemParent, "UI")
            self.btnList[index]:SetData(self.marryTypes[i])
        end
        --index = index + 1
        --self.btnList[index] = MarryPageItem(self.MarryPageItem.gameObject,self.pageItemParent,"UI")
        --self.btnList[index]:SetData(self.marryTypes[i])
    end
    if self.index == 2 then
        self:ClickMarryPageItem(3)
    elseif self.index == 5 then
        self:ClickMarryPageItem(5)
    else
        self:ClickMarryPageItem(self.btnList[1].data.id)
    end

end

function MarryPanel:AddEvent()

    local function call_back()
        self:Close()
    end
    AddClickEvent(self.closeBtn.gameObject, call_back)

    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.ClickMarryPageItem, handler(self, self.ClickMarryPageItem))
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.MarryRedPoint, handler(self, self.MarryRedPoint))
    self.close_event_id = GlobalEvent:AddListener(MarryEvent.CloseMarryPanel, handler(self, self.Close))

    local function callback()
        if CoupleModel.GetInstance().is_need_open_panel then
            if self.currentView then
                self.currentView:destroy()
                self.currentView = nil
            end
            self.currentView = CoupleEnterPanel(self.panelParent, "UI");
            self:PopUpChild(self.currentView)
            CoupleModel.GetInstance().is_need_open_panel = false
        else
            GlobalEvent:Brocast(MarryEvent.UpdateCoupleTimes)
        end
    end
    self.open_cp_panel_event_id = GlobalEvent:AddListener(DungeonEvent.UpdateDungeonData, callback)
end

function MarryPanel:MarryRedPoint()
    for i = 1, #self.btnList do
        --if self.model.redPoints[1]  then
        --
        --end
        --if self.btnList[i].data.id == id then
        --    self.btnList[i]:SetSelect(true)
        --else
        --    self.btnList[i]:SetSelect(false)
        --end
        if self.btnList[i].data.id == 2 then
            --三步走
            self.btnList[i]:SetRedPoint(self.model.redPoints[1])
        elseif self.btnList[i].data.id == 3 then
            --戒指
            self.btnList[i]:SetRedPoint(self.model.redPoints[2])
        elseif self.btnList[i].data.id == 5 then
            --CP副本
            self.btnList[i]:SetRedPoint(self.model.redPoints[5])
        end
    end
end

function MarryPanel:SetMoney(list)
    if table.isempty(list) then
        return
    end
    self.money_list = {}
    local offX = 220
    for i = 1, #list do
        local item = MoneyItem(self.money_con, nil, list[i])
        local x = (i - #list) * offX
        local y = 0
        item:SetPosition(x, y)
        self.money_list[i] = item
    end
end

function MarryPanel:ClickMarryPageItem(id)
    if id == self.panelType then
        return
    end
    self.panelType = id
    for i = 1, #self.btnList do
        if self.btnList[i].data.id == id then
            self.btnList[i]:SetSelect(true)
        else
            self.btnList[i]:SetSelect(false)
        end
    end
    self:SwitchCallBack(id)
end

function MarryPanel:SwitchCallBack(id)
    if self.currentView then
        self.currentView:destroy();
    end
    local is_show_decoration = true
    self.currentView = nil
    if id == 1 then
        self.currentView = MarryFriendPanel(self.panelParent, "UI");
        self:PopUpChild(self.currentView)
    elseif id == 2 then
        self.currentView = MarryMarryPanel(self.panelParent, "UI");
        self:PopUpChild(self.currentView)
    elseif id == 3 then
        self.currentView = MarryRingPanel(self.panelParent, "UI");
        self:PopUpChild(self.currentView)
    elseif id == 4 then
        self.currentView = MarryInfoPanel(self.panelParent, "UI");
        self:PopUpChild(self.currentView)
    elseif id == 5 then
        CoupleModel.GetInstance().is_need_open_panel = true
        is_show_decoration = false
        DungeonCtrl:GetInstance():RequestDungeonPanel(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COUPLE);
        --self.currentView = CoupleEnterPanel(self.panelParent, "UI");
        --self:PopUpChild(self.currentView)
    end
    SetVisible(self.Image, is_show_decoration)
end

function MarryPanel:CheckBindOpenSystemEvent()
    if OpenTipModel.GetInstance():IsOpenSystem(1200, 5) and self.opensys_event_id == nil then
        self.opensys_event_id = GlobalEvent:AddListener()
    end
end

function MarryPanel:CheckSideBarShow()
    if OpenTipModel.GetInstance():IsOpenSystem(1200, 5) then
        return true
    end
    return false
end
