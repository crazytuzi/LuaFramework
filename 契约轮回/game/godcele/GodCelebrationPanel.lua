-- @Author: lwj
-- @Date:   2019-09-06 10:07:54 
-- @Last Modified time: 2019-09-06 10:07:57

GodCelebrationPanel = GodCelebrationPanel or class("GodCelebrationPanel", BasePanel)
local GodCelebrationPanel = GodCelebrationPanel

function GodCelebrationPanel:ctor()
    self.abName = "sevenDayActive"
    self.assetName = "GodCelebrationPanel"
    self.image_ab = "godcele_image";
    self.layer = "UI"

    self.is_show_money = { Constant.GoldType.Coin, Constant.GoldType.BGold, Constant.GoldType.Gold }
    self.events = {}
    self.modelEvents = {}
    self.selectedId = -1;
    self.use_background = true
    self.show_sidebar = false

    self.panels = {}
    self.panelType = -1
    self.model = GodCelebrationModel:GetInstance()
    --活动类型
    self.sevenDayType = {
        { text = ConfigLanguage.GodCele.RushList, id = 501 },
        { text = ConfigLanguage.GodCele.Target, id = 502 },
        { text = ConfigLanguage.GodCele.Recharge, id = 503 },
        { text = ConfigLanguage.GodCele.RushBuy, id = 504 },
        { text = ConfigLanguage.GodCele.Exchange, id = 505 },
        { text = ConfigLanguage.GodCele.Dunge, id = 506 },
    }
    self.btnList = {}


end

function GodCelebrationPanel:dctor()
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

    for _, item in pairs(self.money_list) do
        item:destroy()
    end
    self.money_list = {}


end

function GodCelebrationPanel:Open(index)
    self.index = index or 1
    WindowPanel.Open(self)
end

function GodCelebrationPanel:LoadCallBack()
    self.nodes = {
        "closeBtn", "ScrollView/Viewport/btnListItemContent", "GodCelePageItem", "ScrollView", "panelParent", "GodCelebrationPanel", "money_con"
    }
    self:GetChildren(self.nodes)
    --self:SetTileTextImage("achieve_image", "achieve_title");
    self:InitUI()
    self:AddEvent()

    if self.btnList[self.index] then
        self:SevenDayActiveClickPageItem(self.btnList[self.index].data.id, self.btnList[self.index].actId) --默认选择第一个
    else
        --Notify.ShowText("活动已经全部结束")
    end
    --self:SevenDayActiveClickPageItem(self.btnList[1].data.id,self.btnList[1].actId) --默认选择第一个

    self:SetMoney(self.is_show_money)

    --  print2( self.btnList[1].data.id)
    --  dump(OperateModel:GetInstance():GetAct(10501))
    --  dump(OperateModel:GetInstance():GetAct(10501))
    --  dump(OperateModel:GetInstance():GetAct(10501))
    --  dump(self.btnList)
    -- dump(OperateModel:GetInstance().act_info_list )
    -- dump(OperateModel:GetInstance().act_info_list )
end

function GodCelebrationPanel:SetMoney(list)
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

function GodCelebrationPanel:InitUI()
    local index = 0
    for i = 1, #self.sevenDayType do
        local type = self.sevenDayType[i].id
        local id = OperateModel:GetInstance():GetActIdByType(type)
        if OperateModel:GetInstance():IsActOpenByTime(id) then
            index = index + 1
            self.btnList[index] = GodCelePageItem(self.GodCelePageItem.gameObject, self.btnListItemContent, "UI")
            self.btnList[index]:SetData(self.sevenDayType[i], id)
        end
    end
    self:RedPointInfo()
end

function GodCelebrationPanel:OpenCallBack()
    if self.btnList[self.index] then
        self:SevenDayActiveClickPageItem(self.btnList[self.index].data.id, self.btnList[self.index].actId) --默认选择第一个
    end
end

function GodCelebrationPanel:CloseCallBack()
end

function GodCelebrationPanel:AddEvent()
    local function close_callback(target, x, y)
        self:Close()
    end
    AddButtonEvent(self.closeBtn.gameObject, close_callback)

    --DungePanelInfo
    self.events[#self.events + 1] = GlobalEvent:AddListener(GodCeleEvent.SevenDayActiveClickPageItem, handler(self, self.SevenDayActiveClickPageItem))
    self.events[#self.events + 1] = GlobalEvent:AddListener(GodCeleEvent.CloseGodCelePanel, handler(self, self.Close))

    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(GodCeleEvent.RedPointInfo, handler(self, self.RedPointInfo))
    --local function callback()
    --    logError("fuck")
    --end
    --self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(GodCeleEvent.StartDungeonCD, callback)

end

function GodCelebrationPanel:RedPointInfo()
    for i, v in pairs(self.btnList) do
        if self.model.redPoints[v.actId] == true then
            v:SetRedPoint(true)
        else
            v:SetRedPoint(false)
        end
    end
end

function GodCelebrationPanel:SwitchCallBack(index)
    if self.currentView then
        self.currentView:destroy();
    end
end

function GodCelebrationPanel:SevenDayActiveClickPageItem(id, actId)
    --print2(actId,id)
    --print2(actId,id)
    --print2(actId,id)


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

function GodCelebrationPanel:SwitchSubView(actId)
    if self.currentView then
        --    self.currentView:destroy()
        --self.currentView:SetVisible(false)
        self.currentView = nil
    end

    if self.panels[self.panelType] then
        self.currentView = self.panels[self.panelType]
    else
        local p
        if self.panelType == 501 then
            p = GodCeleRankPanel(self.panelParent, self, actId)
        elseif self.panelType == 502 then
            p = GodCeleTargetPanel(self.panelParent, self, actId)
        elseif self.panelType == 503 then
            p = GodCeleRechargeOnePanel(self.panelParent, self, actId)

        elseif self.panelType == 504 then
            p = GodCeleRushBuyPanel(self.panelParent, self, actId)
        elseif self.panelType == 505 then
            p = GodCeleExchangeView(self.panelParent, self, actId)
        elseif self.panelType == 506 then
            DungeonCtrl.GetInstance():RequestDungeonPanel(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_TOWER)
            p = GodScoreDungeView(self.panelParent, self, actId)
        end

        self.panels[self.panelType] = p
        self.currentView = p
    end

    if self.currentView then
        self:PopUpChild(self.currentView)
    end
end

