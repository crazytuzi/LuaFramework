-- @Author: lwj
-- @Date:   2019-08-28 15:40:30 
-- @Last Modified time: 2019-08-28 15:40:32

ClubFightView = ClubFightView or class("ClubFightView", BaseItem)
local ClubFightView = ClubFightView

function ClubFightView:ctor(parent_node, layer)
    self.abName = "openHigh"
    self.assetName = "ClubFightView"
    self.layer = layer
    self.act_id = OperateModel.GetInstance():GetActIdByType(205)

    self.model = OpenHighModel.GetInstance()
    BaseItem.Load(self)
end

function ClubFightView:dctor()
    if not table.isempty(self.item_list) then
        for i, v in pairs(self.item_list) do
            if v then
                v:destroy()
            end
        end
        self.item_list = {}
    end
    if self.update_event_id then
        self.model:RemoveListener(self.update_event_id)
        self.update_event_id = nil
    end
end

function ClubFightView:LoadCallBack()
    self.nodes = {
        "Top/act_time", "Top/act_des", "Bottom/Scroll/Viewport/item_con", "Bottom/Scroll/Viewport/item_con/ClubFightItem",
    }
    self:GetChildren(self.nodes)
    self.act_time = GetText(self.act_time)
    self.act_des = GetText(self.act_des)
    self.item_obj = self.ClubFightItem.gameObject

    self:AddEvent()
    self:InitPanel()
end

function ClubFightView:AddEvent()
    self.update_event_id = self.model:AddListener(OpenHighEvent.UpdateTaskPro, handler(self, self.InitPanel))
end

function ClubFightView:InitPanel()
    self:LoadItems()
    self:InitTimeShow()
end

function ClubFightView:InitTimeShow()
    local opday = LoginModel.GetInstance():GetOpenTime()
    self.act_time.text = string.format(ConfigLanguage.OpenHigh.ServiceOpenDayTime, opday)
    local act_cf = self.model:GetThemeCfById(self.act_id)
    self.act_des.text = "Event Rules:" .. act_cf.desc
end

function ClubFightView:LoadItems()
    local list = self.model:GetClubFightRewaCFByLevel()
    self.item_list = self.item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.item_list[i]
        if not item then
            item = ClubFightItem(self.item_obj, self.item_con)
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