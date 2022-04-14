---
--- Created by  Administrator
--- DateTime: 2020/3/14 10:29
---
MergeSerActivePanel = MergeSerActivePanel or class("MergeSerActivePanel", SevenDayActivePanel)
local this = MergeSerActivePanel

function MergeSerActivePanel:ctor()

    self.abName = "sevenDayActive"
    self.assetName = "MergeSerActivePanel"
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
        { text = ConfigLanguage.SevenDayActive.rank, id = 805 },
        { text = ConfigLanguage.SevenDayActive.RushBuy, id = 804 },
        { text = ConfigLanguage.SevenDayActive.RechargeOne, id = 802 },
        { text = ConfigLanguage.SevenDayActive.Target, id = 803 },


    }
    self.btnList = {}
end

function MergeSerActivePanel:LoadCallBack()
    self.nodes = {
        "title"
    }
    self:GetChildren(self.nodes)
    self.titleImg = GetImage(self.title)
    MergeSerActivePanel.super.LoadCallBack(self)
end


function MergeSerActivePanel:SwitchSubView(actId)
    if self.currentView then
        --    self.currentView:destroy()
        --self.currentView:SetVisible(false)
        self.currentView = nil
    end

    if self.panels[self.panelType] then
        self.currentView = self.panels[self.panelType]
    else
        local p
        if self.panelType == 805 then
            p = MergeSerRankPanel(self.panelParent, self,actId)
        elseif self.panelType == 804 then
            p = MergeSerRushBuy(self.panelParent, self,actId)
        elseif self.panelType == 802 then
            p = MergeRechargePanel(self.panelParent, self,actId)
        elseif self.panelType == 803 then
            p = MergeRechargeTarget(self.panelParent, self,actId)
        --elseif self.panelType == 103 then
        --    p = SevenDayTargetPanel(self.panelParent, self,actId)
        end




        self.panels[self.panelType] = p
        self.currentView = p
    end

    if self.currentView then
        self:PopUpChild(self.currentView)
    end
    self:SetTitle(self.panelType)
end

function MergeSerActivePanel:SetTitle(type)
    local id  = OperateModel:GetInstance():GetActIdByType(type)
    local cfg = OperateModel:GetInstance():GetConfig(id)
   -- logError(cfg.sundries,self.panelType)
    lua_resMgr:SetImageTexture(self,self.titleImg,"iconasset/icon_mergeser",cfg.sundries, false)
end

function MergeSerActivePanel:RedPointInfo()
    for i, v in pairs(self.btnList) do
        if  self.model.mergeRedPoints[v.actId] == true then
            v:SetRedPoint(true)
        else
            v:SetRedPoint(false)
        end
    end
end