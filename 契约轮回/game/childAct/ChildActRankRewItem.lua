---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Admin.
--- DateTime: 2019/12/24 14:51

ChildActRankRewItem = ChildActRankRewItem or class("ChildActRankRewItem", BaseCloneItem)
local ChildActRankRewItem = ChildActRankRewItem

function ChildActRankRewItem:ctor(parent_node, layer)
    ChildActRankRewItem.super.Load(self)
    self.itemicon = {}
end

function ChildActRankRewItem:dctor()
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function ChildActRankRewItem:LoadCallBack()
    self.nodes = {
        "one","two","rankname","Scroll View/Viewport/Content","Scroll View/Viewport",
    }
    self:GetChildren(self.nodes)
    self.rankTex = GetText(self.rankname)
    self:AddEvent()
    self:SetMask()
end

function ChildActRankRewItem:AddEvent()
end

function ChildActRankRewItem:SetData(data, StencilId, index)
    self.data = data
  --  self.StencilId = StencilId
    self.index = index
    self:UpdateView()
end

function ChildActRankRewItem:UpdateView()
    if self.index == 1 then
        SetVisible(self.one, true)
    elseif self.index == 2 then
        SetVisible(self.two, true)
    else

    end
    self.rankTex.text = self.data.desc
    self:CreateReward()
end

function ChildActRankRewItem:CreateReward()
    local rewardTab = String2Table(self.data.reward)
    for i = 1, #rewardTab do
        if self.itemicon[i] == nil then
            self.itemicon[i] = GoodsIconSettorTwo(self.Content)
        end
        local param = {}
        param["item_id"] = rewardTab[i][1]
        param["num"] = rewardTab[i][2]
        param["bind"] = rewardTab[i][3]
        param["can_click"] = true
        param["size"] = {x = 60,y = 60}
      --[[  if self.data.level <= 2 then
            param["effect_type"] = 2
            param["color_effect"] = 5
        else
            param["effect_type"] = 1
            param["color_effect"] = 5
        end--]]
        param["stencil_id"] = self.StencilId
        param["stencil_type"] = 3
        self.itemicon[i]:SetIcon(param)
    end
end

function ChildActRankRewItem:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

