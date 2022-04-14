---
--- Created by  Administrator
--- DateTime: 2019/8/23 11:13
---
SevenDayPetRankRewardItem = SevenDayPetRankRewardItem or class("SevenDayPetRankRewardItem", BaseCloneItem)
local this = SevenDayPetRankRewardItem

function SevenDayPetRankRewardItem:ctor(obj, parent_node, parent_panel)
    SevenDayPetRankRewardItem.super.Load(self)
    self.events = {}
    self.itemicon = {}
end

function SevenDayPetRankRewardItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
end

function SevenDayPetRankRewardItem:LoadCallBack()
    self.nodes = {
        "itemScrollView/Viewport/itemContent","bg","title/rankTex","itemScrollView/Viewport"
    }
    self:GetChildren(self.nodes)
    self.bgIcon = GetImage(self.bg)
    self.rankTex = GetText(self.rankTex)
    self:InitUI()
    self:AddEvent()
end

function SevenDayPetRankRewardItem:InitUI()

end

function SevenDayPetRankRewardItem:AddEvent()

end

function SevenDayPetRankRewardItem:SetData(data,maskId)
    self.data = data
    self.StencilId = maskId
    self:UpdateInfo()
end

function SevenDayPetRankRewardItem:UpdateInfo()
    -- if self.data.level <= 2 then
    --  lua_resMgr:SetImageTexture(self,self.bgIcon, 'sevenDayActive_image', 'sevenDayActive_itembg'..self.data.level,true)
    --else
    SetVisible(self.bg,false)
    -- end
    self.rankTex.text = self.data.desc
    self:CreateRewards()
end

function SevenDayPetRankRewardItem:CreateRewards()
    local rewardTab = String2Table(self.data.reward)
    for i = 1, #rewardTab do
        --self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
        if self.itemicon[i] == nil then
            self.itemicon[i] = GoodsIconSettorTwo(self.itemContent)
        end
        local param = {}
        param["model"] = self.model
        param["item_id"] = rewardTab[i][1]
        param["num"] = rewardTab[i][2]
        param["bind"] = rewardTab[i][3]
        param["can_click"] = true
        param["size"] = {x = 60,y = 60}
        if self.data.level <= 2 then
            param["effect_type"] = 2
            param["color_effect"] = 5
        else
            param["effect_type"] = 1
            param["color_effect"] = 5
        end
        param["stencil_id"] = self.StencilId
        param["stencil_type"] = 3
        self.itemicon[i]:SetIcon(param)
    end
end