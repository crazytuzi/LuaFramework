---
--- Created by  Administrator
--- DateTime: 2019/8/22 16:48
---
SevenDayPetMainPanel = SevenDayPetMainPanel or class("SevenDayPetMainPanel", BasePanel)
local this = SevenDayPetMainPanel

function SevenDayPetMainPanel:ctor(parent_node, parent_panel)
    self.abName = "sevenDayActive"
    self.assetName = "SevenDayPetMainPanel"
    self.image_ab = "sevenDayActive_image";
    self.layer = "UI"
   -- self.is_show_money = { Constant.GoldType.Coin, Constant.GoldType.BGold, Constant.GoldType.Gold }
    self.events = {}
    self.modelEvents = {}
    self.selectedId = -1;
    self.use_background = true
    self.show_sidebar = false

    self.panels = {}
    self.panelType =  -1
    self.model = SevenDayActiveModel:GetInstance()
    self.sevenDayType = {
        { text = ConfigLanguage.PetActive.rank, id = 301 },
        { text = ConfigLanguage.PetActive.buy, id = 302 },
        { text = ConfigLanguage.PetActive.vip, id = 303 },
        { text = ConfigLanguage.PetActive.Recharge, id = 304 },
        { text = ConfigLanguage.PetActive.Target, id = 305 },
        { text = ConfigLanguage.PetActive.box, id = 306 },
    }
    self.btnList = {}

end
function SevenDayPetMainPanel:Open(index)
    self.index = index
    WindowPanel.Open(self)
    --if self.btnList[self.index] then
    --    self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
    --else
    --    Notify.ShowText("活动已经全部结束")
    --end
end

function SevenDayPetMainPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.modelEvents)
    for _, item in pairs(self.panels) do
        item:destroy()
    end
    self.panels = {}

    for _, item in pairs(self.btnList) do
        item:destroy()
    end
    self.btnList = {}


    --for _, item in pairs(self.money_list) do
    --    item:destroy()
    --end
    --self.money_list= {}
end

function SevenDayPetMainPanel:LoadCallBack()
    self.nodes = {
        "closeBtn","ScrollView/Viewport/btnListItemContent","SevenDayPetPageItem","ScrollView","panelParent","SevenDayActivePanel","money_con"
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()

    if self.btnList[self.index] then
        self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
    else
        Notify.ShowText("All events are over")
    end

   -- self:SetMoney(self.is_show_money)
end

function SevenDayPetMainPanel:InitUI()
    local index = 0
    for i = 1, #self.sevenDayType do
        local type = self.sevenDayType[i].id
        local id  = OperateModel:GetInstance():GetActIdByType(type)
        if OperateModel:GetInstance():IsActOpenByTime(id) then
            index = index + 1
            self.btnList[index] = SevenDayPetPageItem(self.SevenDayPetPageItem.gameObject,self.btnListItemContent,"UI")
            self.btnList[index]:SetData(self.sevenDayType[i],id)
            -- print2(index,id)
        end
    end
    self:RedPointInfo()
end

function SevenDayPetMainPanel:AddEvent()

    local function close_callback(target, x, y)
        self:Close()
    end
    AddClickEvent(self.closeBtn.gameObject, close_callback)

    self.events[#self.events + 1] = GlobalEvent:AddListener(SevenDayActiveEvent.SevenDayPetClickPageItem, handler(self, self.SevenDayPetClickPageItem))
   -- self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(SevenDayActiveEvent.RedPointInfo, handler(self, self.RedPointInfo))


    local function call_back()
        self.index = 1
        if self.btnList[self.index] then
            self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
        else
            Notify.ShowText("All events are over")
        end

    end
    self.events[#self.events + 1] =  GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenDayPetPanel, call_back)

    local function call_back()
        self.index = 2
        if self.btnList[self.index] then
            self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
        else
            Notify.ShowText("All events are over")
        end
    end
    self.events[#self.events + 1] =   GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenDayPetBuyPanel, call_back)

    local function call_back()
        self.index = 3
        if self.btnList[self.index] then
            self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
        else
            Notify.ShowText("All events are over")
        end
    end
    self.events[#self.events + 1] =    GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenDayPetVipPanel, call_back)
    local function call_back()
        self.index = 4
        if self.btnList[self.index] then
            self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
        else
            Notify.ShowText("All events are over")
        end
    end
    self.events[#self.events + 1] =   GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenDayPetRechargePanel, call_back)
    local function call_back()
        self.index = 5
        if self.btnList[self.index] then
            self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
        else
            Notify.ShowText("All events are over")
        end
    end
    self.events[#self.events + 1] =  GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenDayPetTargetPanel, call_back)
    --local function call_back()
    --    lua_panelMgr:GetPanelOrCreate(SevenDayPetBuyPanel):Open(6)
    --end
    --GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenDayBuyPanel, call_back)
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(SevenDayActiveEvent.PetRedPointInfo, handler(self, self.RedPointInfo))

end

function SevenDayPetMainPanel:RedPointInfo()
    for i, v in pairs(self.btnList) do
        if  self.model.petRedPoints[v.actId] == true then
            v:SetRedPoint(true)
        else
            v:SetRedPoint(false)
        end
    end
end

function SevenDayPetMainPanel:SetMoney(list)
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

function SevenDayPetMainPanel:SevenDayPetClickPageItem(id,actId)
    if self.panelType == id then
        return
    end
    self.panelType = id
    self:SwitchSubView(actId)
    for i, v in pairs(self.btnList) do
        if v.data.id == id then
            v:SetSeletc(true)
        else
            v:SetSeletc(false)
        end
    end
end


function SevenDayPetMainPanel:SwitchSubView(actId)
    if self.currentView then
        --    self.currentView:destroy()
        --self.currentView:SetVisible(false)
        self.currentView = nil
    end

    if self.panels[self.panelType] then
        self.currentView = self.panels[self.panelType]
    else
        local p
        if self.panelType == 301 then
            p = SevenDayPetRankPanel(self.panelParent, self,actId)
        elseif self.panelType == 302 then
            p = SevenDayPetBuyPanel(self.panelParent, self,actId)
        elseif self.panelType == 303 then
            p = SevenDayPetVipPanel(self.panelParent, self,actId)
        elseif self.panelType == 304 then
            p = SevenDayPetRechargePanel(self.panelParent, self,actId)
        elseif self.panelType == 305 then
            p = SevenDayPetTargetPanel(self.panelParent, self,actId)
        elseif self.panelType == 306 then
            p = SevenDayPetBoxPanel(self.panelParent, self,actId)
        end




        self.panels[self.panelType] = p
        self.currentView = p
    end

    if self.currentView then
        self:PopUpChild(self.currentView)
    end
end


