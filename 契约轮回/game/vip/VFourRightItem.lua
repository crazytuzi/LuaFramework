-- @Author: lwj
-- @Date:   2019-07-11 21:38:17 
-- @Last Modified time: 2019-07-11 21:38:19

VFourRightItem = VFourRightItem or class("VFourRightItem", BaseCloneItem)
local VFourRightItem = VFourRightItem

function VFourRightItem:ctor(parent_node, layer)
    VFourRightItem.super.Load(self)
end

function VFourRightItem:dctor()
end

function VFourRightItem:LoadCallBack()
    self.nodes = {
        "des",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)

    self:AddEvent()
end

function VFourRightItem:AddEvent()

end

function VFourRightItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function VFourRightItem:UpdateView()
    self.des.text = self.data
end
