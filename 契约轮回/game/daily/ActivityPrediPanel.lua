-- @Author: lwj
-- @Date:   2019-02-11 17:34:20
-- @Last Modified time: 2019-02-11 17:34:28

ActivityPrediPanel = ActivityPrediPanel or class("ActivityPrediPanel", BaseItem)
local ActivityPrediPanel = ActivityPrediPanel

function ActivityPrediPanel:ctor(parent_node, layer)
    self.abName = "daily"
    self.assetName = "ActivityPrediPanel"
    self.layer = layer

    self.model = DailyModel:GetInstance()
    BaseItem.Load(self)
end

function ActivityPrediPanel:dctor()
    for i, v in pairs(self.pre_item_list) do
        if v then
            v:destroy()
        end
    end
    self.pre_item_list = {}
    if self.handleItemClick_event_id then
        self.model:RemoveListener(self.handleItemClick_event_id)
    end
    self.handleItemClick_event_id = nil
end

function ActivityPrediPanel:LoadCallBack()
    self.nodes = {
        "LeftScroll/Viewport/LeftContent/ActivityPrediItem",
        "LeftScroll/Viewport/LeftContent",
        "RightConten/date", "RightConten/pic", "RightConten/rules", "RightConten/lv_limit", "RightConten/Title", "RightConten/btn_go",
    }
    self:GetChildren(self.nodes)
    self.prediItem_gameObject = self.ActivityPrediItem.gameObject
    self.date = GetText(self.date)
    self.rules = GetText(self.rules)
    self.Title = GetText(self.Title)
    self.lv_limit = GetText(self.lv_limit)
    self.pic = GetImage(self.pic)
    self:AddEvent()
    self:InitPanel()
end

function ActivityPrediPanel:AddEvent()
    self.handleItemClick_event_id = self.model:AddListener(DailyEvent.ActivityPrediItemSelect, handler(self, self.HandleItemClick))

    local function call_back()
        local type = self.cur_click_item_data.link_type
        self.hookData = {}
        self.hookData.id = self.cur_click_item_data.link
        if type == 1 then
            --任务
            if self.cur_click_item_data.link then
                local link_id = tonumber(String2Table(self.cur_click_item_data.link)[1])
                if link_id == 930000 then
                    if RoleInfoModel.GetInstance():GetMainRoleData().guild == "0" then
                        Notify.ShowText("Please join the guild first")
                        return
                    end
                end
                TaskModel.GetInstance():DoTask(link_id)
            end
        elseif type == 2 then
            if self.hookData then
                SceneManager:GetInstance():AttackCreepByTypeId(self.hookData.id)
            end
        elseif type == 3 then
            --界面跳转
            if self.cur_click_item_data.link ~= "" then
                local pTab = String2Table(self.cur_click_item_data.link)
                OpenLink(unpack(pTab[1]))
            end
        elseif type == 4 then
            --挂机
            if self.hookData then
                SceneManager:GetInstance():AttackCreepByTypeId(self.hookData.id)
            end
        elseif type == 5 then
            --npc
            if self.cur_click_item_data.link then
                SceneManager:GetInstance():FindNpc(String2Table(self.cur_click_item_data.link)[1])
            end
        end
    end
    AddButtonEvent(self.btn_go.gameObject, call_back)
end

function ActivityPrediPanel:InitPanel()
    self:LoadPrediItem()
end

function ActivityPrediPanel:LoadPrediItem()
    self.pre_item_list = self.pre_item_list or {}
    local list = self.model:GetAllActivityWithoutToday()
    local len = #list
    for i = 1, len do
        local item = self.pre_item_list[i]
        if not item then
            item = ActivityPrediItem(self.prediItem_gameObject, self.LeftContent)
            self.pre_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i], i)
    end
    for i = len + 1, #self.pre_item_list do
        local item = self.pre_item_list[i]
        item:SetVisible(false)
    end
end

function ActivityPrediPanel:HandleItemClick(id, date, data)
    self.cur_click_item_data = data
    local tbl = Config.db_daily[id]
    lua_resMgr:SetImageTexture(self, self.pic, "iconasset/icon_daily", "ad_" .. tbl.pic, true, nil, false)
    self.Title.text = tbl.name
    self.date.text = ConfigLanguage.Daily.ActivityTime .. date
    local lv = GetLevelShow(String2Table(tbl.reqs)[1][2])
    self.lv_limit.text = string.format(ConfigLanguage.Daily.LimitLvWithoutColor, lv)
    self.rules.text = ConfigLanguage.Daily.ActivityRules .. tbl.desc
    if self.model:CheckIsRunningActById(id) then
        SetVisible(self.btn_go, true)
    else
        SetVisible(self.btn_go, false)
    end
end