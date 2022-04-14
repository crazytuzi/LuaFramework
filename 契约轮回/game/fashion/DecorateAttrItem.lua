-- @Author: lwj
-- @Date:   2019-11-15 15:02:29 
-- @Last Modified time: 2019-11-15 15:02:30

DecorateAttrItem = DecorateAttrItem or class("DecorateAttrItem", BaseCloneItem)
local DecorateAttrItem = DecorateAttrItem

function DecorateAttrItem:ctor(parent_node, layer)
    DecorateAttrItem.super.Load(self)
end

function DecorateAttrItem:dctor()
end

function DecorateAttrItem:LoadCallBack()
    self.nodes = {
        "name", "cur",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.cur = GetText(self.cur)

    self:AddEvent()
end

function DecorateAttrItem:AddEvent()

end

function DecorateAttrItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function DecorateAttrItem:UpdateView()
    self.name.text = self.data.title
    self.cur.text = self.data.cur
end