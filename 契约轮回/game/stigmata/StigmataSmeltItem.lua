---
---Author: wry
---Date: 2019/9/21 16:33:27
---

StigmataSmeltItem = StigmataSmeltItem or class("StigmataSmeltItem",BaseItem)
local StigmataSmeltItem = StigmataSmeltItem

function StigmataSmeltItem:ctor(parent_node,layer)
    self.abName = "bag"
    self.assetName = "StigmataSmeltItem"
    self.layer = layer

    self.model = BagModel:GetInstance()
    StigmataSmeltItem.super.Load(self)
end

function StigmataSmeltItem:dctor()
    if self.goodsItem then
        self.goodsItem:destroy()
        self.goodsItem = nil
    end
    self.model = nil
end

function StigmataSmeltItem:LoadCallBack()
    self.nodes = {
        "item","select",
    }
    self:GetChildren(self.nodes)
    self:AddEvent()
    self:UpdateView()
end

function StigmataSmeltItem:AddEvent()
    local function call_back(target,x,y)
        if not self.data then
            return
        end
        if self.selected then
            self:Select(false)
        else
            self:Select(true)
        end
        self.model:Brocast(BagEvent.SmeltItemClick, self.data)
    end
    AddClickEvent(self.item.gameObject,call_back)
end

--data:p_item_base
function StigmataSmeltItem:SetData(data, selected, StencilId)
    self.data = data
    self.selected = selected
    self.StencilId = StencilId
    if self.is_loaded then
        self:UpdateView()
    end
end

function StigmataSmeltItem:GetData()
    return self.data
end

function StigmataSmeltItem:UpdateView()
    if self.goodsItem then
        self.goodsItem:destroy()
    end
    if self.data then
        local param = {}
        param["model"] = self.model
        param["item_id"] = self.data.id
        param["p_item_base"] = self.data
        param["color_effect"] = enum.COLOR.COLOR_PINK
        param["stencil_id"] = self.StencilId
        param["stencil_type"] = 3
        param["num"] = self.data.num
        param["p_item"] = self.data
        self.goodsItem = GoodsIconSettorTwo(self.item)
        self.goodsItem:SetIcon(param)
    else
        self.goodsItem = GoodsIconSettorTwo(self.item)
    end
    SetVisible(self.select, self.selected)
end

function StigmataSmeltItem:Select(flag)
    SetVisible(self.select, flag)
    self.selected = flag
end