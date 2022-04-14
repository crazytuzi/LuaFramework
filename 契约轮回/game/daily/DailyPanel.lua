-- @Author: lwj
-- @Date:   2019-01-15 15:07:47
-- @Last Modified time: 2019-01-15 15:07:51

DailyPanel = DailyPanel or class("DailyPanel", WindowPanel)
local DailyPanel = DailyPanel

function DailyPanel:ctor()
    self.abName = "daily"
    self.assetName = "DailyPanel"
    self.layer = "UI"

    self.panel_type = 2
    --self.show_sidebar = true        --是否显示侧边栏
    --if self.show_sidebar then
    --     侧边栏配置
    --self.sidebar_data = {
    --    { text = ConfigLanguage.Daily.DailyTask, id = 1, icon = "bag:bag_icon_bag_s", dark_icon = "bag:bag_icon_bag_n", },
    --    { text = ConfigLanguage.Daily.ActivityPrediction, id = 2, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", },
    --{ text = ConfigLanguage.Daily.WeeklyTask, id = 3, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", },
    --}
    --end
    self.model = DailyModel.GetInstance()
end

function DailyPanel:dctor()
end

function DailyPanel:Open(default_tag)
    self.default_table_index = default_tag or 1
    WindowPanel.Open(self)
end

function DailyPanel:LoadCallBack()
    self.nodes = {
    }
    self:GetChildren(self.nodes)
    self:AddEvent()
    self:SetTileTextImage("daily_image", "Title_img_Daily")
end

function DailyPanel:AddEvent()
    self.modelEventList = {}
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(DailyEvent.CloseDailyActPanel, handler(self, self.Close))
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(DailyEvent.UpdateFindBackInfo, handler(self, self.CheckFindbackRedDot))
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(DailyEvent.UpdateDailyRD, handler(self, self.CheckDailyRD))
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(DailyEvent.UpdateGodTempleRD, handler(self, self.UpdateGodTempleRD))

end

function DailyPanel:OpenCallBack()
    self:CheckFindbackRedDot()
    local is_show = self.model:CheckDailyRewardRD()
    self:CheckDailyRD(is_show)
    self:UpdateGodTempleRD()
end

function DailyPanel:SwitchCallBack(index)
    if self.child_node then
        self.child_node:SetVisible(false)
    end
    if index == 1 then
        self.model:Brocast(DailyEvent.RequestDailyInfo)
        if not self.taskPanel then
            self.taskPanel = DailyTaskPanel(self.child_transform, "UI")
        end
        self:PopUpChild(self.taskPanel)
    elseif index == 3 then
        if not self.prediPanel then
            self.prediPanel = ActivityPrediPanel(self.child_transform, "UI")
        end
        self:PopUpChild(self.prediPanel)
    elseif index == 2 then
        self.model:Brocast(DailyEvent.RequestRefindInfo)
        if not self.refind_panel then
            self.refind_panel = ResReFindPanel(self.child_transform, "UI")
        end
        self:PopUpChild(self.refind_panel)
        --elseif index == 4 then
        --    GlobalEvent:Brocast(DailyEvent.RequestWeeklyInfo)
        --    if not self.weeklyPanel then
        --        self.weeklyPanel = WeeklyPanel(self.child_transform, "UI")
        --    end
        --    self:PopUpChild(self.weeklyPanel)
    elseif index == 4 then
        if not self.weeklyPanel then
            self.weeklyPanel = FactionBattleTemplePanel(self.child_transform, "UI")
        end
        self:PopUpChild(self.weeklyPanel)

    end
end

function DailyPanel:CloseCallBack()
    for i, v in pairs(self.modelEventList) do
        self.model:RemoveListener(v)
    end
    self.modelEventList = {}
    if self.weeklyPanel then
        self.weeklyPanel:destroy()
        self.weeklyPanel = nil
    end
    if self.prediPanel then
        self.prediPanel:destroy()
        self.prediPanel = nil
    end
    if self.taskPanel then
        self.taskPanel:destroy()
        self.taskPanel = nil
    end
    if self.refind_panel then
        self.refind_panel:destroy()
        self.refind_panel = nil
    end
end

function DailyPanel:CheckFindbackRedDot()
    local flag = self.model:IsHaveCoinCount()
    self:SetIndexRedDotParam(2, flag)
end

function DailyPanel:UpdateGodTempleRD()
    if not table.isempty(self.model.side_rd_list) then
        local flag = self.model.side_rd_list[3]
        self:SetIndexRedDotParam(4, flag)
    end
end

function DailyPanel:CheckDailyRD(is_show)
    self:SetIndexRedDotParam(1, is_show)
end
