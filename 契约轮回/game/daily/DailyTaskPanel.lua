-- @Author: lwj
-- @Date:   2019-01-15 17:38:31
-- @Last Modified time: 2019-11-13 19:45:24

DailyTaskPanel = DailyTaskPanel or class("DailyTaskPanel", BaseItem)
local DailyTaskPanel = DailyTaskPanel

function DailyTaskPanel:ctor(parent_node, layer)
    self.abName = "daily"
    self.assetName = "DailyTaskPanel"
    self.layer = layer

    self.model = DailyModel.GetInstance()
    self.act_item_list = {}
    self.rewa_item_list = {}
    self.limit_item_list = {}
    self.sinProg = 0.2      --单个奖励进度
    self.change_red_time = 18000
    self.modelEventList = {}

    BaseItem.Load(self)
end

function DailyTaskPanel:dctor()
    destroySingle(self.shape_red_dot)
    self.shape_red_dot = nil
    if self.all_act_event_id then
        GlobalEvent:RemoveListener(self.all_act_event_id)
        self.all_act_event_id = nil
    end
    if self.check_hook_time_event_id then
        GlobalEvent:RemoveListener(self.check_hook_time_event_id)
        self.check_hook_time_event_id = nil
    end
    if not table.isempty(self.act_item_list) then
        for i, v in pairs(self.act_item_list) do
            if v then
                v:destroy()
            end
        end
        self.act_item_list = {}
    end
    if not table.isempty(self.rewa_item_list) then
        for i, v in pairs(self.rewa_item_list) do
            if v then
                v:destroy()
            end
        end
        self.rewa_item_list = {}
    end

    if not table.isempty(self.limit_item_list) then
        for i, v in pairs(self.limit_item_list) do
            if v then
                v:destroy()
            end
        end
        self.limit_item_list = {}

    end

    if not table.isempty(self.modelEventList) then
        for i, v in pairs(self.modelEventList) do
            self.model:RemoveListener(v)
        end
        self.modelEventList = {}

    end
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function DailyTaskPanel:LoadCallBack()
    self.nodes = {
        "ActiveContainer/ActiveScroll/Viewport/activeContent/DailyActiveItem", "ActiveContainer/ActiveScroll/Viewport/activeContent",
        "ProgressContent/rewardContent/DailyRewardItem",
        "ProgressContent/rewardContent",
        "ProgressContent/HeadBg/acitveValue",
        "ProgressContent/sliderBg/slider",
        "LimitContent/limitScroll/Viewport/limitContent/DailyLimitItem",
        "LimitContent/limitScroll/Viewport/limitContent",
        "btn_scheduel",
        "btn_shape", "btn_shape/shape_rd_con",
        "LimitContent/limitScroll/Viewport",
        "ActiveContainer/ActiveScroll/Viewport/activeContent/DailyHookItem/te_content", "ActiveContainer/ActiveScroll/Viewport/activeContent/DailyHookItem/btn_increase",
        "ActiveContainer/ActiveScroll/Viewport/activeContent/DailyHookItem/te_content/countdowntext",
    }
    self:GetChildren(self.nodes)
    self.acitveValue = GetText(self.acitveValue)
    self.slider = GetImage(self.slider)
    self.hook_time = GetText(self.countdowntext)

    self.act_Item_gameObject = self.DailyActiveItem.gameObject
    self.reward_item_gameObject = self.DailyRewardItem.gameObject
    self.limit_item_gameObject = self.DailyLimitItem.gameObject

    self:AddEvent()
    ActivityController.GetInstance():RequsetAllActList()
    self:SetMask()
end

function DailyTaskPanel:AddEvent()
    local function callback()
        SettingModel.GetInstance():AddAfkTime()
    end
    AddClickEvent(self.btn_increase.gameObject, callback)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(WeekCalendarPanel):Open()
    end
    AddButtonEvent(self.btn_scheduel.gameObject, call_back)

    local function call_back()
        local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
        local limit_lv = tonumber(string.match(Config.db_game["daily_openlv"].val, "%d+"))
        if lv >= limit_lv then
            self.model.is_open = true
            self.model:Brocast(DailyEvent.RequestIllutionInfo)
        else
            local tip = string.format(ConfigLanguage.Daily.DailyShowLimit, limit_lv)
            Notify.ShowText(tip)
        end
    end
    AddButtonEvent(self.btn_shape.gameObject, call_back)

    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(DailyEvent.UpdatePanel, handler(self, self.HandleAllList))
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(DailyEvent.UpdateRewardItem, handler(self, self.LoadRewardItem))
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(DailyEvent.UpdateShapeRD, handler(self, self.SetShapeRedDot))
    self.check_hook_time_event_id = GlobalEvent:AddListener(SettingEvent.UpdateAfkInfo, handler(self, self.UpdateHookTimeShow))
    self.all_act_event_id = GlobalEvent:AddListener(ActivityEvent.DiliverAllActivity, handler(self, self.HandleAllList))
end

function DailyTaskPanel:HandleAllList(list)
    self.model:SortAllActList(list)
    self:InitPanel()
end

function DailyTaskPanel:InitPanel()
    self:LoadRewardItem()
    self:LoadLimitItem()
    self:LoadActiveItem()
    self.model.isUpdatting = false
    self:UpdateHookTimeShow()
    local is_show = self.model.is_show_shape_rd
    self:SetShapeRedDot(is_show)
end

--挂机时间显示
function DailyTaskPanel:UpdateHookTimeShow()
    local rest_time = SettingModel.GetInstance():GetAfkTimeSeconds()
    if rest_time < self.change_red_time then
        SetColor(self.hook_time, 255, 0, 0, 255)
    else
        SetColor(self.hook_time, 84, 84, 84, 255)
    end
    local without_hour = rest_time % 3600
    local hour = (rest_time - without_hour) / 3600
    local sec = without_hour % 60
    local min = (without_hour - sec) / 60
    self.hook_time.text = string.format("%02d:%02d:%02d", hour, min, sec)
end

function DailyTaskPanel:LoadActiveItem()
    local list = self.model:GetListWithoutSortByIndex(1)
    local finalList = self.model:GetSortedList(list)
    local final_len = #finalList
    for i = 1, final_len do
        local item = self.act_item_list[i]
        if not item then
            item = DailyActiveItem(self.act_Item_gameObject, self.activeContent)
            self.act_item_list[i] = item
        else
            item:SetVisible(true)
        end
        if i == 1 then
            item:AddEffect()
        else
            item:RemoveEffect()
        end
        item:SetData(finalList[i])
    end
    for i = final_len + 1, #self.act_item_list do
        local item = self.act_item_list[i]
        item:SetVisible(false)
    end
end

function DailyTaskPanel:LoadRewardItem()
    local cur_act = self.model:GetActTotal()
    local list = {}
    local data = {}
    local conTbl = Config.db_daily_reward
    data.rewardTbl = {}
    local nextTarget = nil      --当前进度的下一个进度点
    for i = 1, #conTbl do
        data = {}
        data.act_value = conTbl[i].activation
        data.reward_tbl = String2Table(conTbl[i].reward)
        data.id = i
        data.isInDailyPanel = true
        data.isGot = self.model:GetIsGetRewardResultById(data.id)
        list[#list + 1] = data
        if not nextTarget and conTbl[i].activation > cur_act then
            nextTarget = i
        end
    end

    self.rewa_item_list = self.rewa_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.rewa_item_list[i]
        if not item then
            item = DailyRewardItem(self.reward_item_gameObject, self.rewardContent)
            self.rewa_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i])
    end
    for i = len + 1, #self.rewa_item_list do
        local item = self.rewa_item_list[i]
        item:SetVisible(false)
    end

    local curPro = 0        --当前进度条的进度值
    if not nextTarget then
        curPro = 1
    else
        local lastAct = 0       --上一个奖励的活跃值
        local curSumAct = 0     --上下区间之间的活跃值
        local curSinglePro = 0     --上下区间之间的单个活跃值对应的进度值
        local curRestAct = 0      --当前区间存在的活跃值
        local frontPro = (nextTarget - 1) * self.sinProg        --上个区间往上的总进度值
        if nextTarget == 1 then
            --未完成第一个每日奖励
            lastAct = 0
            curRestAct = cur_act
        else
            --最少已完成一个每日奖励
            lastAct = conTbl[nextTarget - 1].activation
            curRestAct = cur_act - lastAct
        end
        curSumAct = conTbl[nextTarget].activation - lastAct
        curSinglePro = self.sinProg / curSumAct
        curPro = (curRestAct * curSinglePro) + frontPro
    end
    self.acitveValue.text = cur_act
    self.slider.fillAmount = curPro
end

function DailyTaskPanel:LoadLimitItem()

    local finalList = self.model:GetCurLimitList()
    --dump(finalList,"DailyTaskPanel,DailyTaskPanelDailyTaskPanelDailyTaskPanelDailyTaskPanel")
    self.limit_item_list = self.limit_item_list or {}
    local len = #finalList
    for i = 1, len do
        local item = self.limit_item_list[i]
        if not item then
            item = DailyLimitItem(self.limit_item_gameObject, self.limitContent)
            self.limit_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(finalList[i], self.StencilId, 3)
    end
    for i = len + 1, #self.limit_item_list do
        local item = self.limit_item_list[i]
        item:SetVisible(false)
    end
end

function DailyTaskPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

function DailyTaskPanel:SetShapeRedDot(isShow)
    if not self.shape_red_dot then
        self.shape_red_dot = RedDot(self.shape_rd_con, nil, RedDot.RedDotType.Nor)
    end
    self.shape_red_dot:SetPosition(0, 0)
    self.shape_red_dot:SetRedDotParam(isShow)
end