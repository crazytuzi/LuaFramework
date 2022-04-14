-- @Author: lwj
-- @Date:   2019-01-29 17:08:16
-- @Last Modified time: 2019-10-17 21:52:36

WeekCalendarPanel = WeekCalendarPanel or class("WeekCalendarPanel", WindowPanel)
local WeekCalendarPanel = WeekCalendarPanel

function WeekCalendarPanel:ctor(parent_node, layer)
    self.abName = "daily"
    self.assetName = "WeekCalendarPanel"
    self.layer = "UI"
    self.panel_type = 3

    self.model = DailyModel:GetInstance()
end

function WeekCalendarPanel:dctor()
end

function WeekCalendarPanel:Open()
    WeekCalendarPanel.super.Open(self)
end

function WeekCalendarPanel:LoadCallBack()
    self.nodes = {
        "itemScroll/Viewport/Content/floorItem/weekItemContent", "dialog_text", "itemScroll/Viewport/Content/floorItem/weekItemContent/WeekItem", "itemScroll/Viewport/Content/floorItem/timeContent", "itemScroll/Viewport/Content/floorItem",
        "titlecontent/TitleBg_1/title_1", "titlecontent/TitleBg_2/title_2", "titlecontent/TitleBg_7/title_7", "titlecontent/TitleBg_5/title_5", "titlecontent/TitleBg_4/title_4", "titlecontent/TitleBg_6/title_6", "titlecontent/TitleBg_3/title_3",
    }
    self:GetChildren(self.nodes)
    self.dialog_text = GetText(self.dialog_text)
    self.weekItem_gameObject = self.WeekItem.gameObject
    self.floorItem_Rect = self.floorItem:GetComponent('RectTransform')
    SetLocalPosition(self.transform, 0, 0, 0);
    self:AddTitleItem()

    self:AddEvent()
    --self:SetPanelSize(894, 525)
    self:SetTileTextImage("daily_image", "calendar_panel_title_img");
    self:InitPanel()
end

function WeekCalendarPanel:AddTitleItem()
    self.title_list = {}
    self.title_list[#self.title_list + 1] = self.title_1
    self.title_list[#self.title_list + 1] = self.title_2
    self.title_list[#self.title_list + 1] = self.title_3
    self.title_list[#self.title_list + 1] = self.title_4
    self.title_list[#self.title_list + 1] = self.title_5
    self.title_list[#self.title_list + 1] = self.title_6
    self.title_list[#self.title_list + 1] = self.title_7
end

function WeekCalendarPanel:AddEvent()
end

function WeekCalendarPanel:InitPanel()
    self.week_item_list = self.week_item_list or {}
    local tbl = Config.db_weekly_ad
    local sizeY = 52.8 * #tbl
    SetSizeDelta(self.floorItem_Rect, 660, sizeY)

    for i = 1, #tbl do
        local data = {}
        local strTbl = string.split(tbl[i].open, "$")
        if not strTbl[2] then
            strTbl[2] = ""
        else
            strTbl[2] = "\n" .. strTbl[2]
        end
        data.cont = strTbl[1] .. strTbl[2]
        local item = WeekItem(self.weekItem_gameObject, self.timeContent)
        self:AddItemToList(item, data)
    end

    for i = 1, #tbl do
        for ii = 1, 7 do
            local data = {}
            data.index = ii
            local textTbl = String2Table(tbl[i].test)
            data.cont = textTbl[ii]
            local item = WeekItem(self.weekItem_gameObject, self.weekItemContent)
            self:AddItemToList(item, data)
        end
    end
end

function WeekCalendarPanel:OpenCallBack()
    local date = TimeManager.GetInstance():GetTimeDate(os.time())
    if date.wday == 1 then
        date.wday = 7
    else
        date.wday = date.wday - 1
    end
    self.model:Brocast(DailyEvent.SelectWeekItem, date.wday)
    for i = 1, 7 do
        SetVisible(self.title_list[i], i == date.wday)
    end
    local num = ChineseNumber(date.wday)
    self.dialog_text.text = string.format(ConfigLanguage.Daily.WeekPanelDialogText, num)
end

function WeekCalendarPanel:AddItemToList(item, data)
    item:SetData(data)
    self.week_item_list[#self.week_item_list + 1] = item
end

function WeekCalendarPanel:CloseCallBack()
    for i, v in pairs(self.week_item_list) do
        if v then
            v:destroy()
        end
    end
    self.week_item_list = {}
    self.title_list = {}
end