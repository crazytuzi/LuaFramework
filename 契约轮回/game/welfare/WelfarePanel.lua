---
--- Created by R2D2.
--- DateTime: 2019/1/8 15:18
---

WelfarePanel = WelfarePanel or class("WelfarePanel", BasePanel)
local WelfarePanel = WelfarePanel

function WelfarePanel:ctor()
    --货币顶栏配置
    self.is_show_money = { Constant.GoldType.Gold, Constant.GoldType.BGold, Constant.GoldType.Coin }

    self.abName = "welfare"
    self.assetName = "WelfarePanel"
    self.layer = "UI"

    self.events = {}
    self.selectedId = -1;
    self.use_background = true
    self.show_sidebar = false

    self.is_show_open_action = true
    
    self.panel_type = 2

    self.panels = {}

    self.model = WelfareModel.GetInstance()
end

function WelfarePanel:dctor()

    if self.events then
        GlobalEvent:RemoveTabListener(self.events)
        self.events = nil
    end

    if self.panels then
        for _, item in pairs(self.panels) do
            item:destroy()
        end
        self.panels = {}
    end

    if self.money_list then
        for _, item in pairs(self.money_list) do
            item:destroy()
        end
        self.money_list = {}
    end

    if self.toggleItems then
        for _, v in pairs(self.toggleItems) do
            v:destroy()
        end
        self.toggleItems = {}
    end

    self.sidebar_data = nil
end

function WelfarePanel:Open(openParam)
    self.openParam = openParam	
    WelfarePanel.super.Open(self)
end

function WelfarePanel:LoadCallBack()
    self.nodes = {
        "money_con",
        "SubPanel",
        "ToggleList",
        "ToggleList/TogglePrefab",
        "Background/CloseBtn",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()

    --默认选中页
    local openIndex = self:GetOpenIndex()

    self.toggleItems[openIndex]:SetItOn(true)
    self:SetMoney(self.is_show_money)

    self:RequestData()
end

function WelfarePanel:GetOpenIndex()
	if self.openParam and type(self.openParam) == "number" then
		if self.openParam < 10 then
			---页面标签Step是100
			self.openParam = self.openParam * 100
		end
		for i, v in ipairs(self.toggleItems) do
			if (v.data.id == self.openParam) then
				self.openParam = nil
				return i
			end
		end
	end
	
	return 1
end

function WelfarePanel:SetMoney(list)
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

function WelfarePanel:InitUI()

    self.toggleGroup = GetToggleGroup(self.ToggleList)
    self.toggleItems = {}


    self.sidebar_data = SidebarConfig[self.__cname]
    local typeTab = self.model:GetWelfareType(self.sidebar_data)

    for i = 1, #typeTab, 1 do
        local tempTab = typeTab[i]
        local tempItem = WelfareToggleItemView(newObject(self.TogglePrefab), tempTab)
        tempItem.gameObject.name = "welfare_toggle" .. i
        tempItem.transform:SetParent(self.ToggleList)
        tempItem:SetTogGroup(self.toggleGroup)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        SetLocalPosition(tempItem.transform, 0, (i - 1) * -60, 0)
        self.toggleItems[i] = tempItem
    end
    self.TogglePrefab.gameObject:SetActive(false)
end

function WelfarePanel:AddEvent()
    local function close_callback(target, x, y)
        self:Close()
    end
    AddClickEvent(self.CloseBtn.gameObject, close_callback)

    local OnWelfareChangePage = function(typeId)
        --print("福利标签切换至--------->" .. typeId)
        if self.selectedId ~= typeId then
            self.selectedId = typeId
            self:SwitchSubView()
        end
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(WelfareEvent.Welfare_ChangePageEvent, OnWelfareChangePage)

    local function call_back()
        for _, v in pairs(self.toggleItems) do
            v:RefreshRedPoint()
        end
    end
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(WelfareEvent.Welfare_SignedEvent, call_back)
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(WelfareEvent.Welfare_OnlineRewardEvent, call_back)
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(WelfareEvent.Welfare_LevelRewardEvent, call_back)
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(WelfareEvent.Welfare_PowerRewardEvent, call_back)
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(WelfareEvent.Welfare_GrailRefreshEvent, call_back)
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(WelfareEvent.Welfare_OnlineLocalCountDownEvent, call_back)
    local function call_back2()
        for _, v in pairs(self.toggleItems) do
            if (v.data.id == 500) then
                v:RefreshRedPoint()
            end
        end
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back2)
end

function WelfarePanel:RequestData()
    WelfareController.GetInstance():RequestLevelInfo()
    WelfareController.GetInstance():RequestPowerInfo()
    WelfareController.GetInstance():RequestSignInfo()
end

function WelfarePanel:SwitchSubView()
    if self.currentView then
        --    self.currentView:destroy()
        --self.currentView:SetVisible(false)
        self.currentView = nil
    end

    if self.panels[self.selectedId] then
        self.currentView = self.panels[self.selectedId]
    else
        local p
        if self.selectedId == 100 then
            p = WelfareOnlinePanel(self.SubPanel, self)
        elseif self.selectedId == 200 then
            p = WelfareSignPanel(self.SubPanel, self)
        elseif self.selectedId == 300 then
            p = WelfareLevelPanel(self.SubPanel, self)
        elseif self.selectedId == 400 then
            p = WelfarePowerPanel(self.SubPanel, self)
        elseif self.selectedId == 500 then
            p = WelfareGrailPanel(self.SubPanel, self)
        elseif self.selectedId == 600 then
            p = WelfareNoticePanel(self.SubPanel, self)
        elseif self.selectedId == 700 then
            p = WelfareDownloadPanel(self.SubPanel, self)
        elseif self.selectedId == 800 then
            p = WelfareExchangePanel(self.SubPanel, self)
        end

        self.panels[self.selectedId] = p
        self.currentView = p
    end

    if self.currentView then
        self:PopUpChild(self.currentView)
    end
end