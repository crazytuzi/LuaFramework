-- @Author: lwj
-- @Date:   2019-11-14 22:01:49 
-- @Last Modified time: 2019-11-14 22:01:51

PillarItem = PillarItem or class("PillarItem", BaseCloneItem)
local PillarItem = PillarItem

function PillarItem:ctor(parent_node, layer)
    PillarItem.super.Load(self)
end

function PillarItem:dctor()
end

function PillarItem:LoadCallBack()
    self.nodes = {
    }
    self:GetChildren(self.nodes)

    self:AddEvent()
end

function PillarItem:AddEvent()

end

function PillarItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function PillarItem:UpdateView()
    SetLocalPosition(self.transform, 4, self.data)
end