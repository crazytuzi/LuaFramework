-- @Author: lwj
-- @Date:   2019-01-30 17:11:01
-- @Last Modified time: 2019-01-30 17:11:04

DailyShowProItem = DailyShowProItem or class("DailyShowProItem", BaseCloneItem)
local DailyShowProItem = DailyShowProItem

function DailyShowProItem:ctor(parent_node, layer)
    DailyShowProItem.super.Load(self)
end

function DailyShowProItem:dctor()
    if self.des_list then
        self.des_list = nil
    end
end

function DailyShowProItem:LoadCallBack()
    self.model = DailyModel.GetInstance()
    self.nodes = {
        "text_con/des_2", "text_con/des_1", "title", "text_con/des_3", "up_con",
    }
    self:GetChildren(self.nodes)
    self.des_1 = GetText(self.des_1)
    self.des_2 = GetText(self.des_2)
    self.des_3 = GetText(self.des_3)
    self.title = GetText(self.title)

    self:AddDes()
    self:AddEvent()
end

function DailyShowProItem:AddDes()
    self.des_list = {}
    self.des_list[#self.des_list + 1] = self.des_1
    self.des_list[#self.des_list + 1] = self.des_2
    self.des_list[#self.des_list + 1] = self.des_3
end

function DailyShowProItem:AddEvent()

end

function DailyShowProItem:SetData(data, index)
    self.data = data
    self.index = index

    self:UpdateView()
end

function DailyShowProItem:UpdateView()
    local len = #self.data
    for i = 1, len do
        local atr = self.data[i]
        self.des_list[i].text = string.format(ConfigLanguage.Daily.PropertyDes, enumName.ATTR[atr[1]], atr[2])
    end
    for i = len + 1, #self.des_list do
        self.des_list[i].text = ""
    end

    local cur_lv = self.model:GetillutionLevel()
    if self.index == 1 then
        SetVisible(self.up_con, false)
    else
        cur_lv = cur_lv + 1
    end
    self.title.text = string.format(ConfigLanguage.Daily.CurIllutionLv, cur_lv)
end