SevenDayActivePanel = SevenDayActivePanel or class("SevenDayActivePanel", BasePanel)
local SevenDayActivePanel = SevenDayActivePanel

function SevenDayActivePanel:ctor()
    self.abName = "sevenDayActive"
    self.assetName = "SevenDayActivePanel"
    self.image_ab = "sevenDayActive_image";
    self.layer = "UI"

    self.is_show_money = { Constant.GoldType.Coin, Constant.GoldType.BGold, Constant.GoldType.Gold }
    self.events = {}
    self.modelEvents = {}
    self.selectedId = -1;
    self.use_background = true
    self.show_sidebar = false
    self.panel_type = 2

    self.panels = {}
    self.panelType =  -1
    self.model = SevenDayActiveModel:GetInstance()
    self.sevenDayType = {
        { text = ConfigLanguage.SevenDayActive.rank, id = 105 },
        { text = ConfigLanguage.SevenDayActive.RushBuy, id = 104 },
        { text = ConfigLanguage.SevenDayActive.RechargeOne, id = 102 },
        { text = ConfigLanguage.SevenDayActive.Target, id = 103 },
        { text = ConfigLanguage.SevenDayActive.Recharge, id = 101 },

    }
    self.btnList = {}



end


function SevenDayActivePanel:dctor()
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
    self.money_list= {}


end

function SevenDayActivePanel:Open(index)
    self.index = index
    print2(self.index)
    if self.btnList[self.index] then
        self:SevenDayActiveClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId)
    end
    WindowPanel.Open(self)
end

function SevenDayActivePanel:LoadCallBack()
    self.nodes = {
        "closeBtn","ScrollView/Viewport/btnListItemContent","SevenDayActivePageItem","ScrollView","panelParent","SevenDayActivePanel","money_con"
    }
    self:GetChildren(self.nodes)
    --self:SetTileTextImage("achieve_image", "achieve_title");
    self:InitUI()
    self:AddEvent()



    if self.btnList[self.index] then
        self:SevenDayActiveClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
    else
        Notify.ShowText("All events are over")
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

function SevenDayActivePanel:SetMoney(list)
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

function SevenDayActivePanel:InitUI()
    local index = 0
    for i = 1, #self.sevenDayType do
        local type = self.sevenDayType[i].id
        local id  = OperateModel:GetInstance():GetActIdByType(type)
        if OperateModel:GetInstance():IsActOpenByTime(id) then
            index = index + 1
            self.btnList[index] = SevenDayActivePageItem(self.SevenDayActivePageItem.gameObject,self.btnListItemContent,"UI")
            self.btnList[index]:SetData(self.sevenDayType[i],id)
           -- print2(index,id)
        end
    end
    self:RedPointInfo()
end
function SevenDayActivePanel:GetCfgIdByType(type)
    local cfg = Config.db_yunying[type]
    local tab = {}
    if not cfg then
        return
    end

end

function SevenDayActivePanel:OpenCallBack()


end

function SevenDayActivePanel:CloseCallBack()

end

function SevenDayActivePanel:AddEvent()


    local function close_callback(target, x, y)
        self:Close()
    end
    AddClickEvent(self.closeBtn.gameObject, close_callback)

    self.events[#self.events + 1] = GlobalEvent:AddListener(SevenDayActiveEvent.SevenDayActiveClickPageItem, handler(self, self.SevenDayActiveClickPageItem))
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(SevenDayActiveEvent.RedPointInfo, handler(self, self.RedPointInfo))

end

function SevenDayActivePanel:RedPointInfo()
    for i, v in pairs(self.btnList) do
        if  self.model.redPoints[v.actId] == true then
            v:SetRedPoint(true)
        else
            v:SetRedPoint(false)
        end
    end
end

function SevenDayActivePanel:SwitchCallBack(index)
    if self.currentView then
        self.currentView:destroy();
    end
end

function SevenDayActivePanel:SevenDayActiveClickPageItem(id,actId)
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

function SevenDayActivePanel:SwitchSubView(actId)
    if self.currentView then
        --    self.currentView:destroy()
        --self.currentView:SetVisible(false)
        self.currentView = nil
    end

    if self.panels[self.panelType] then
        self.currentView = self.panels[self.panelType]
    else
        local p
        if self.panelType == 105 then
            p = SevenDayRankPanel(self.panelParent, self,actId)
        elseif self.panelType == 101 then
            p = SevenDayRechargePanel(self.panelParent, self,actId)
        elseif self.panelType == 102 then
            p = SevenDayRechargeOnePanel(self.panelParent, self,actId)
        elseif self.panelType == 104 then
            p = SevenDayRushBuyPanel(self.panelParent, self,actId)
        elseif self.panelType == 103 then
            p = SevenDayTargetPanel(self.panelParent, self,actId)
        end




        self.panels[self.panelType] = p
        self.currentView = p
    end

    if self.currentView then
        self:PopUpChild(self.currentView)
    end
end

