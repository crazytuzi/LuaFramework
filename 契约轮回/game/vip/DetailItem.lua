-- @Author: lwj
-- @Date:   2018-12-06 11:17:28
-- @Last Modified time: 2018-12-06 11:17:38

DetailItem = DetailItem or class("DetailItem", BaseItem)
local DetailItem = DetailItem

function DetailItem:ctor(parent_node, layer)
    self.abName = "vip"
    self.assetName = "DetailItem"
    self.layer = layer

    BaseItem.Load(self)
    self.lineHeight = 24
end

function DetailItem:dctor()
    --if self.setsize_scheld_id ~= nil then
    --    GlobalSchedule:Stop(self.setsize_scheld_id)
    --end
end

function DetailItem:LoadCallBack()
    self.nodes = {
        "des",
    }
    self:GetChildren(self.nodes)
    self.desRectTran = self.des:GetComponent('RectTransform')
    self.rectTran = self.transform:GetComponent('RectTransform')
    self.desT = self.des:GetComponent('Text')
    self:AddEvent()
    self:ShowPanel()
end

function DetailItem:AddEvent()
end

function DetailItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:ShowPanel()
    end
end

function DetailItem:ShowPanel()

    self.des:GetComponent('Text').text = self.data
    self:SetSize()
end

function DetailItem:SetSize()
    local y = self.desT.preferredHeight
    if y > 24 then
        local delta = y - 24
        SetSizeDelta(self.rectTran, 374, self.rectTran.sizeDelta.y + delta)
    else
        SetSizeDelta(self.rectTran, 374, 37)
    end
end
