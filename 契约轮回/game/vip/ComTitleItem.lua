-- @Author: lwj
-- @Date:   2018-12-03 14:42:51
-- @Last Modified time: 2018-12-03 14:43:30

ComTitleItem = ComTitleItem or class("ComTitleItem", BaseCloneItem)
local ComTitleItem = ComTitleItem

function ComTitleItem:ctor(obj,parent_node, layer)
    ComTitleItem.super.Load(self)
end

function ComTitleItem:dctor()

end

function ComTitleItem:LoadCallBack()
    self.nodes = {
        "titleText",
    }
    self:GetChildren(self.nodes)
    self:AddEvent()
end

function ComTitleItem:AddEvent()

end

function ComTitleItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function ComTitleItem:UpdateView()
    self.titleText:GetComponent('Text').text=self.data
end

