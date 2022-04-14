-- @Author: lwj
-- @Date:   2019-04-11 20:02:21
-- @Last Modified time: 2019-04-11 20:02:21

StrongerItem = StrongerItem or class("StrongerItem", BaseCloneItem)
local StrongerItem = StrongerItem

function StrongerItem:ctor(parent_node, layer)
    StrongerItem.super.Load(self)
end

function StrongerItem:dctor()
end

function StrongerItem:LoadCallBack()
    --self.model = CanMdyModel.GetInstance()
    self.nodes = {
        "bg",
        "Text",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.Text)

    self:AddEvent()
end

function StrongerItem:AddEvent()
    local function callback()
        --local param = string.split(self.data.cf_data.jump, '@')
        local param = String2Table(self.data.cf_data.jump)
        --for i = 1, #param do
        --    param[i] = tonumber(param[i])
        --end
        GlobalEvent:Brocast(MainEvent.StrongerItemClick, self.data.cf_data.id)
        OpenLink(unpack(param))
        GlobalEvent:Brocast(MainEvent.CloseStrongerPanel)
    end
    AddClickEvent(self.bg.gameObject, callback)
end

function StrongerItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function StrongerItem:UpdateView()
    self.name.text = self.data.cf_data.name
end
