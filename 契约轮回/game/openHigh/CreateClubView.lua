-- @Author: lwj
-- @Date:   2019-08-12 11:23:12 
-- @Last Modified time: 2019-08-12 11:23:14

CreateClubView = CreateClubView or class("CreateClubView", BaseItem)
local CreateClubView = CreateClubView

function CreateClubView:ctor(parent_node, layer)
    self.abName = "openHigh"
    self.assetName = "CreateClubView"
    self.layer = layer
    self.act_id = 120401

    self.model = OpenHighModel.GetInstance()
    BaseItem.Load(self)
end

function CreateClubView:dctor()
    if self.item_list then
        for i, v in pairs(self.item_list) do
            if v then
                v:destroy()
            end
        end
        self.item_list = {}
    end
end

function CreateClubView:LoadCallBack()
    self.nodes = {
        "Top/act_des", "Top/act_time", "Right/Scroll/Viewport/task_con/CreateClubItem", "Right/Scroll/Viewport/task_con",
        "tips/tips_text",
    }
    self:GetChildren(self.nodes)
    self.act_des = GetText(self.act_des)
    self.act_time = GetText(self.act_time)
    self.item_obj = self.CreateClubItem.gameObject
    self.tips = GetText(self.tips_text)

    self:AddEvent()
    self:InitPanel()
end

function CreateClubView:AddEvent()

end

function CreateClubView:InitPanel()
    self.tips.text = ConfigLanguage.OpenHigh.CreateTips
    self:InitTopShow()
    self:LoadItem()
end

function CreateClubView:InitTopShow()
    local start_stamp = OperateModel.GetInstance():GetActStartTimeByActId(self.act_id)
    local start_time_tbl = TimeManager.GetInstance():GetTimeDate(start_stamp)
    local end_stamp = self.model.act_end_list[self.act_id]
    local end_time_tbl = TimeManager.GetInstance():GetTimeDate(end_stamp)
    local s_min = self:FormatNum(start_time_tbl.min)
    local s_hour = self:FormatNum(start_time_tbl.hour)
    local e_min = self:FormatNum(end_time_tbl.min)
    local e_hour = self:FormatNum(end_time_tbl.hour)
    self.act_time.text = string.format(ConfigLanguage.OpenHigh.WeddingOpenTime, start_time_tbl.year, start_time_tbl.month, start_time_tbl.day, tostring(s_hour), tostring(s_min), end_time_tbl.year, end_time_tbl.month, end_time_tbl.day, tostring(e_hour), tostring(e_min))
    local act_cf = self.model:GetThemeCfById(self.act_id)
    self.act_des.text = act_cf.desc
end

function CreateClubView:FormatNum(num)
    return string.format("%02d", num)
end

function CreateClubView:LoadItem()
    local list = self.model:GetRewaCfByActId(self.act_id)
    self.item_list = self.item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.item_list[i]
        if not item then
            item = CreateClubItem(self.item_obj, self.task_con)
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