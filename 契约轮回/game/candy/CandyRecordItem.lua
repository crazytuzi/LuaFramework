-- @Author: lwj
-- @Date:   2019-02-25 15:48:35 
-- @Last Modified time: 2019-02-25 15:48:39

CandyRecordItem = CandyRecordItem or class("CandyRecordItem", BaseCloneItem)
local CandyRecordItem = CandyRecordItem

function CandyRecordItem:ctor(parent_node, layer)
    CandyRecordItem.super.Load(self)

end

function CandyRecordItem:dctor()
end

function CandyRecordItem:LoadCallBack()
    self.model = CandyModel.GetInstance()
    self.nodes = {
        "Bg", "name", "times", "btn_give",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.times = GetText(self.times)

    self:AddEvent()
end

function CandyRecordItem:AddEvent()
    local function callback()
        if self.data.id then
            --lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.Bg):Open(self.data.id)
            lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.Bg):Open(nil, self.data.id)
        end
    end
    AddClickEvent(self.Bg.gameObject, callback)

    local function callback()
        self.model.is_open_give_gift = true
        self.model.targetPlayerId = self.data.id
        self.model.targetPlayerName = self.data.name
        self.model:Brocast(CandyEvent.RequestReaminGiveCount)
    end
    AddButtonEvent(self.btn_give.gameObject, callback)
end

function CandyRecordItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView()
    end
end

function CandyRecordItem:UpdateView()
    self.name.text = self.data.name
    self.times.text = self.data.num
end