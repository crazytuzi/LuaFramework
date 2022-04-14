-- @Author: lwj
-- @Date:   2019-08-06 15:07:18 
-- @Last Modified time: 2019-08-06 15:07:21

WordCollectView = WordCollectView or class("WordCollectView", BaseItem)
local WordCollectView = WordCollectView

function WordCollectView:ctor(parent_node, layer)
    self.abName = "openHigh"
    self.assetName = "WordCollectView"
    self.layer = layer

    self.act_id = 120301
    self.model = OpenHighModel.GetInstance()
    BaseItem.Load(self)
end

function WordCollectView:dctor()
    for i, v in pairs(self.item_list) do
        if v then
            v:destroy()
        end
    end
    self.item_list = {}
end

function WordCollectView:LoadCallBack()
    self.nodes = {
        "Top/act_des", "Top/act_time", "Scroll/Viewport/item_con", "Scroll/Viewport/item_con/ColeItem",
    }
    self:GetChildren(self.nodes)
    self.act_des = GetText(self.act_des)
    self.act_time = GetText(self.act_time)
    self.cole_obj = self.ColeItem.gameObject

    self:AddEvent()
    self:InitPanel()
end

function WordCollectView:AddEvent()
end

function WordCollectView:InitPanel()
    self:InitTop()
    self:LoadItems()
end

function WordCollectView:InitTop()
    local act_cf = self.model:GetThemeCfById(self.act_id)
    self.act_des.text = act_cf.desc
    local start_stamp = OperateModel.GetInstance():GetActStartTimeByActId(self.act_id)
    local start_time_tbl = TimeManager.GetInstance():GetTimeDate(start_stamp)
    local end_stamp = self.model.act_end_list[self.act_id]
    local end_time_tbl = TimeManager.GetInstance():GetTimeDate(end_stamp)
    local s_min = self:FormatNum(start_time_tbl.min)
    local s_hour = self:FormatNum(start_time_tbl.hour)
    local e_min = self:FormatNum(end_time_tbl.min)
    local e_hour = self:FormatNum(end_time_tbl.hour)
    self.act_time.text = string.format(ConfigLanguage.OpenHigh.WeddingOpenTime, start_time_tbl.year, start_time_tbl.month, start_time_tbl.day, tostring(s_hour), tostring(s_min), end_time_tbl.year, end_time_tbl.month, end_time_tbl.day, tostring(e_hour), tostring(e_min))
end

function WordCollectView:LoadItems()
    local list = self.model:GetRewaCfByActId(self.act_id)
    self.item_list = self.item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.item_list[i]
        if not item then
            item = ColeItem(self.cole_obj, self.item_con)
            self.item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i])
    end
    for i = len + 1, #self.item_list do
        local item = self.item_list[i]
        item:SetVisible(false)
    end
end

function WordCollectView:FormatNum(num)
    return string.format("%02d", num)
end
