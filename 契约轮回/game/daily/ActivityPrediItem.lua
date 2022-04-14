-- @Author: lwj
-- @Date:   2019-02-11 17:54:33
-- @Last Modified time: 2019-02-11 17:55:11

ActivityPrediItem = ActivityPrediItem or class("ActivityPrediItem", BaseCloneItem)
local ActivityPrediItem = ActivityPrediItem

function ActivityPrediItem:ctor(parent_node, layer)
    ActivityPrediItem.super.Load(self)

    self.reward_items = {}
    self.single_goods_width = 60
    self.left_offset = 3
    self.con_span = 5
    self.last_with = 54
    self.max_show_num = 4
    self.max_width = 249
end

function ActivityPrediItem:dctor()
    for i, v in pairs(self.reward_items) do
        if v then
            v:destroy()
        end
    end
    self.reward_items = {}
    if self.selected_event_id then
        self.model:RemoveListener(self.selected_event_id)
    end
    self.selected_event_id = nil
end

function ActivityPrediItem:LoadCallBack()
    self.model = DailyModel.GetInstance()
    self.nodes = {
        "bg", "TimeBg", "time", "date", "icon", "sel_img", "Scroll/Viewport/rewardContent", "flag",
        "Scroll", "Scroll/Viewport",
    }
    self:GetChildren(self.nodes)
    self.icon = GetImage(self.icon)
    self.flag = GetImage(self.flag)
    self.date = GetText(self.date)
    self.time = GetText(self.time)
    self.scroll_rect = GetRectTransform(self.Scroll)
    self.view_rect = GetRectTransform(self.Viewport)
    self:AddEvent()
end

function ActivityPrediItem:AddEvent()
    --local function call_back()
    --    lua_panelMgr:GetPanelOrCreate(ActivityTips):Open(self.data.dailyData.id, self.icon.transform)
    --end
    --AddClickEvent(self.icon.gameObject, call_back)

    local function call_back()
        self.model:Brocast(DailyEvent.ActivityPrediItemSelect, self.data.dailyData.id, self.date.text, self.data.dailyData)
        --lua_panelMgr:GetPanelOrCreate(ActivityTips):Open(self.data.dailyData.id, self.icon.transform)
    end
    AddClickEvent(self.bg.gameObject, call_back)

    self.selected_event_id = self.model:AddListener(DailyEvent.ActivityPrediItemSelect, handler(self, self.Select))
end

function ActivityPrediItem:SetData(data, index)
    self.data = data
    self.index = index
    self:UpdateView()
end

function ActivityPrediItem:UpdateView()
    lua_resMgr:SetImageTexture(self, self.icon, "iconasset/icon_daily", tostring(self.data.dailyData.pic), false, nil, false)
    lua_resMgr:SetImageTexture(self, self.flag, "iconasset/icon_daily", self.data.dailyData.tips, true, nil, false)
    local reward_list = String2Table(self.data.dailyData.reward)
    local len = #reward_list
    local width = self.max_width
    if len < self.max_show_num then
        width = (self.single_goods_width * len) + (len * self.con_span) + self.left_offset
    end
    SetAnchoredPosition(self.scroll_rect, -140, 38)
    SetSizeDelta(self.scroll_rect, width, self.scroll_rect.sizeDelta.y)
    local goods_width = self.single_goods_width * len
    local span_width = self.con_span * (len - 1)
    SetSizeDelta(self.rewardContent, goods_width + span_width, self.rewardContent.sizeDelta.y)
    for i = 1, #reward_list do
        local cfg = Config.db_item[reward_list[i][1]]
        if cfg then
            local param = {}
            local operate_param = {}
            param["cfg"] = cfg
            param["model"] = self.model
            param["can_click"] = true
            param["operate_param"] = operate_param
            param["size"] = { x = 60, y = 60 }
            param["is_dont_set_pos"] = true
            --param["num"] = reward_list[i][2]
            local goodsItem = GoodsIconSettorTwo(self.rewardContent)
            goodsItem:SetIcon(param)
            self.reward_items[#self.reward_items + 1] = goodsItem
        else
            logError("物品表不存在" .. reward_list[i][1] .. '这个物品')
        end
    end
    local cycle = self.data.actData.cycle
    local cycle_text = ""
    if cycle == "daily" then
        cycle_text = ConfigLanguage.Daily.ActivityCycleEveryDay
    elseif cycle == "weekly" then
        local str = ""
        local tbl = String2Table(self.data.actData.days)
        for i = 1, #tbl do
            --local num = ChineseNumber(tonumber(tbl[i]))
            local num = TimeManager:GetWeekDay(tonumber(tbl[i]))
            if i == #tbl then
                str = str .. num
            else
                str = str .. num .. "、"
            end
        end
        cycle_text = string.format(ConfigLanguage.Daily.ActivityCycleWeekly, str)
    end
    self.date.text = cycle_text
    if self.index == 1 then
        self.model:Brocast(DailyEvent.ActivityPrediItemSelect, self.data.dailyData.id, self.date.text, self.data.dailyData)
    end
    local tbl = DailyModel.GetInstance():GetTimeTblByStr(self.data.actData.time)
    local len = #tbl
    local str = ""
    for i = 1, len do
        local tail = ""
        if i ~= len then
            tail = "\n"
        end
        str = str .. string.format("%02d:%02d-%02d:%02d", tbl[i][1][1], tbl[i][1][2], tbl[i][2][1], tbl[i][2][2]) .. tail
    end
    self.time.text = str
    SetVisible(self.rewardContent, true)

    if len == 3 then
        --3个时间段的处理
        SetAnchoredPosition(self.TimeBg,216,-22)
        SetSizeDelta(self.TimeBg,116.78,53.764)

        SetAnchoredPosition(self.time.transform,210,-22.3)
        SetSizeDelta(self.time.transform,100.56,56.76)
    end
end

function ActivityPrediItem:Select(id)
    SetVisible(self.sel_img, self.data.dailyData.id == id)
end


