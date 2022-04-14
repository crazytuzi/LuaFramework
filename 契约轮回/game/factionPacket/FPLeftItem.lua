-- @Author: lwj
-- @Date:   2019-05-16 15:18:34
-- @Last Modified time: 2019-05-16 15:18:38

FPLeftItem = FPLeftItem or class("FPLeftItem", BaseCloneItem)
local FPLeftItem = FPLeftItem

function FPLeftItem:ctor(parent_node, layer)
    FPLeftItem.super.Load(self)
end

function FPLeftItem:dctor()
end

function FPLeftItem:LoadCallBack()
    self.model = FPacketModel.GetInstance()
    self.nodes = {
        "des",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)

    self:AddEvent()
end

function FPLeftItem:AddEvent()

end

function FPLeftItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function FPLeftItem:UpdateView()
    local time_tbl = TimeManager.GetInstance():GetTimeDate(self.data.time)
    local cf = Config.db_guild_redenvelope[self.data.id]
    local money_name = Config.db_item[cf.item_id].name
    self.des.text = string.format(ConfigLanguage.FPacket.RecoDetail, time_tbl.month, time_tbl.day, time_tbl.hour, time_tbl.min, time_tbl.sec, self.data.role_name, cf.name, cf.money, money_name)
end
