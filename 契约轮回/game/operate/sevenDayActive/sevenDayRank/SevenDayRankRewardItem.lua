---
--- Created by  Administrator
--- DateTime: 2019/4/17 19:41
---
SevenDayRankRewardItem = SevenDayRankRewardItem or class("SevenDayRankRewardItem", BaseCloneItem)
local this = SevenDayRankRewardItem

function SevenDayRankRewardItem:ctor(obj, parent_node, parent_panel)
    SevenDayRankRewardItem.super.Load(self)
    self.events = {}
    self.itemicon = {}
    self.model = SevenDayActiveModel:GetInstance()
end

function SevenDayRankRewardItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
end

function SevenDayRankRewardItem:LoadCallBack()
    self.nodes = {
        "itemScrollView/Viewport/itemContent","bg","title/rankTex","itemScrollView/Viewport"
    }
    self:GetChildren(self.nodes)
    self.bgIcon = GetImage(self.bg)
    self.rankTex = GetText(self.rankTex)
    self:InitUI()
    self:AddEvent()
   -- self:SetMask()
end

function SevenDayRankRewardItem:InitUI()

end

function SevenDayRankRewardItem:AddEvent()

end
function SevenDayRankRewardItem:SetData(data,maskId)
    self.data = data
    self.StencilId = maskId
    self:UpdateInfo()
end

function SevenDayRankRewardItem:UpdateInfo()
   -- if self.data.level <= 2 then
      --  lua_resMgr:SetImageTexture(self,self.bgIcon, 'sevenDayActive_image', 'sevenDayActive_itembg'..self.data.level,true)
    --else
        SetVisible(self.bg,false)
   -- end
    self.rankTex.text = self.data.desc
    self:CreateRewards()
end

function SevenDayRankRewardItem:CreateRewards()
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

--function SevenDayRankRewardItem:SetMask()
--    self.StencilId = GetFreeStencilId()
--    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
--    self.StencilMask.id = self.StencilId
--end