---
--- Created by  Administrator
--- DateTime: 2019/11/21 19:08
---
CompeteRewardPanel = CompeteRewardPanel or class("CompeteRewardPanel", BaseItem)
local this = CompeteRewardPanel

function CompeteRewardPanel:ctor(parent_node, parent_panel)
    self.abName = "compete";
    self.image_ab = "compete_image";
    self.assetName = "CompeteRewardPanel"
    self.layer = "UI"
    self.events = {}
    self.model = CompeteModel:GetInstance()
    self.rewards = {}
    CompeteRewardPanel.super.Load(self)
end

function CompeteRewardPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.rewards then
        for i, v in pairs(self.rewards) do
            v:destroy()
        end
        self.rewards = {}
    end
end

function CompeteRewardPanel:LoadCallBack()
    self.nodes = {
        "CompeteRewardItem","ScrollView/Viewport/leftContent","moneyObj/moneyText","moneyObj/moneyIcon",
    }
    self:GetChildren(self.nodes)
    self.moneyIcon = GetImage(self.moneyIcon)
    self.moneyText = GetText(self.moneyText)
    self:InitUI()
    self:AddEvent()
    if self.is_need_setData  then
        self:UpdateInfo(self.typeId,self.islocal)
    end
  --  logError(self.typeId )
end

function CompeteRewardPanel:InitUI()
    local costTab = self.model:GetEnterCost()
    if costTab then
        self.costId = costTab[1]
        -- local num = costTab[2]
        local iconName = Config.db_item[self.costId].icon
        GoodIconUtil:CreateIcon(self, self.moneyIcon, iconName, true)
        local num =  BagModel:GetInstance():GetItemNumByItemID(self.costId)
        local color = "eb0000"
        if num >= 1 then
            color = "6CFE00"
        end
        self.moneyText.text = string.format("<color=#%s>%s</color>",color,num)
    end
end

function CompeteRewardPanel:AddEvent()

end

--islocal:0-跨服，1-本服
function CompeteRewardPanel:UpdateInfo(typeId, islocal)
    self.typeId = typeId
    self.islocal = islocal
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    self:UpdateRewardItems()
end

function CompeteRewardPanel:UpdateRewardItems()
    --local cfg = Config.db_compete_rank_reward
    local tab = {}
    if self.typeId == 2 then --天榜胜利
        tab  = self.model:GetTianWinReward(2)
    elseif self.typeId == 3 then --地榜胜利
        tab  = self.model:GetTianWinReward(3)
    elseif self.typeId == 4 then--小组赛
        tab = self.model:GetLittleRewards()
    elseif self.typeId == 1  then --跨服
        tab = self.model:GetCrossReward(self.islocal)
    end
   -- if  not table.isempty(tab) then
        for i = 1, #tab do
            local buyItem =  self.rewards[i]
            if  not buyItem then
                buyItem = CompeteRewardItem(self.CompeteRewardItem.gameObject,self.leftContent,"UI")
                self.rewards[i] = buyItem
            else
                buyItem:SetVisible(true)
            end
            buyItem:SetData(tab[i],i,self.typeId)
        end
        for i = #tab + 1,#self.rewards do
            local buyItem = self.rewards[i]
            buyItem:SetVisible(false)
        end
    --end
end