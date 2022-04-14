-- @Author: lwj
-- @Date:   2019-02-12 15:49:23
-- @Last Modified time: 2019-02-12 15:49:25

WeeklyPanel = WeeklyPanel or class("WeeklyPanel", BaseItem)
local WeeklyPanel = WeeklyPanel

function WeeklyPanel:ctor(parent_node, layer)
    self.abName = "daily"
    self.assetName = "WeeklyPanel"
    self.layer = layer

    self.model = DailyModel:GetInstance()
    self.task_item_list = {}
    self.sinProg = 0.2
    self.cur_move_percent = 0
    self.len_of_slider_per = 0.508
    self.slider_start_pos_x = -478.4
    self.slider_pos_y = -237
    BaseItem.Load(self)
end

function WeeklyPanel:dctor()
    if self.task_item_list then
        for i, v in pairs(self.task_item_list) do
            if v then
                v:destroy()
            end
        end
        self.task_item_list = {}
    end
    if self.rewa_item_list then
        for i, v in pairs(self.rewa_item_list) do
            if v then
                v:destroy()
            end
        end
        self.rewa_item_list = {}
    end
    for i, v in pairs(self.globalEventList) do
        if v then
            GlobalEvent:RemoveListener(v)
        end
    end
    self.globalEventList = {}
end

function WeeklyPanel:LoadCallBack()
    self.nodes = {
        "LeftScroll/Viewport/LeftContent/HookItem", "LeftScroll/Viewport/LeftContent",
        "prefabContent/WeeklyPanelItem",
        "LeftScroll/Viewport/LeftContent/HookItem/Scroll/Viewport/rewardContent",
        "prefabContent/DailyRewardItem",
        "week_act", "sliderBg/slider",
        "sliderBg",
        "weekRewardCont",
        "eft",
    }
    self:GetChildren(self.nodes)
    self.week_act = GetText(self.week_act)
    self.slider = GetImage(self.slider)
    self.weekItem_gamObject = self.WeeklyPanelItem.gameObject
    self.reward_item_gameObject = self.DailyRewardItem.gameObject
    self.slider_bg_rect = GetRectTransform(self.sliderBg)
    self.slider_rect = GetRectTransform(self.slider)
    self.eft_rect = GetRectTransform(self.eft)
    self:AddEvent()
    self:InitPanel()
end

function WeeklyPanel:AddEvent()
    --self.handleItemClick_event_id = self.model:AddListener(DailyEvent.ActivityPrediItemSelect, handler(self, self.HandleItemClick))
    self.globalEventList = self.globalEventList or {}
    self.globalEventList[#self.globalEventList + 1] = GlobalEvent:AddListener(DailyEvent.UpdateWeeklyItem, handler(self, self.LoadTaskItem))
    self.globalEventList[#self.globalEventList + 1] = GlobalEvent:AddListener(DailyEvent.WeeklyStartMoveStar, handler(self, self.HandleMoveStar))
    self.globalEventList[#self.globalEventList + 1] = GlobalEvent:AddListener(DailyEvent.UpdateRewardItem, handler(self, self.LoadRewardItem))
end

function WeeklyPanel:InitPanel()
    self:LoadRewardItem()
    self:LoadTaskItem()
end

function WeeklyPanel:LoadTaskItem()
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    local preview_list = {}
    local list = self.model:GetWeeklyItemInfo()
    local interator = table.pairsByKey(list)
    local finalList = {}
    for i, v in interator do
        local data_lv = String2Table(v.conData.reqs)[1][2]
        if data_lv > lv then
            if not preview_list[1] then
                preview_list[1] = v
            else
                local vData = String2Table(preview_list[1].conData.reqs)[1][2]
                if data_lv == vData then
                    --等于  在后面加
                    preview_list[#preview_list + 1] = v
                elseif data_lv < vData then
                    preview_list = {}
                    preview_list[1] = v
                end
            end
        else
            finalList[#finalList + 1] = v
        end
    end
    for i = 1, #preview_list do
        finalList[#finalList + 1] = preview_list[i]
    end

    self.task_item_list = self.task_item_list or {}
    local len = #finalList
    for i = 1, len do
        local item = self.task_item_list[i]
        if not item then
            item = WeeklyPanelItem(self.weekItem_gamObject, self.LeftContent)
            self.task_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(finalList[i])
    end
    for i = len + 1, #self.task_item_list do
        local item = self.task_item_list[i]
        item:SetVisible(false)
    end
end

function WeeklyPanel:LoadRewardItem()
    local cur_act = self.model:GetWeekTotalAct()
    local list = {}
    local data = {}
    local conTbl = Config.db_weekly_reward
    data.rewardTbl = {}
    local nextTarget = nil      --当前进度的下一个进度点
    for i = 1, #conTbl do
        data = {}
        data.act_value = conTbl[i].activation
        data.reward_tbl = String2Table(conTbl[i].reward)
        data.id = i
        data.isGot = self.model:GetWeekIsRewarded(data.id)
        data.isInDailyPanel = false
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
            item = DailyRewardItem(self.reward_item_gameObject, self.weekRewardCont)
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
    self.week_act.text = cur_act
    self.cur_move_percent = curPro
    self.slider.fillAmount = curPro
end

function WeeklyPanel:HandleMoveStar()
    SetAnchoredPosition(self.eft_rect, self.model.cur_btn_anchored_pos.x, self.model.cur_btn_anchored_pos.y)
    self:LoadModelEffect()
    local traslated_cur_percent = self.cur_move_percent * 1000
    local slider_ass = self.len_of_slider_per * traslated_cur_percent
    local time = 1.2
    local x = self.slider_start_pos_x + slider_ass
    local y = -237
    local moveAction = cc.MoveTo(time, x, y, 0)
    local function end_call_back()
        self:InitPanel()
        self.effect:destroy()
        self.effect = nil
    end
    local delay_action = cc.DelayTime(0)
    local call_action = cc.CallFunc(end_call_back)
    local sys_action = cc.Sequence(delay_action, moveAction, call_action)
    cc.ActionManager:GetInstance():addAction(sys_action, self.eft)
end

function WeeklyPanel:LoadModelEffect()
    if self.effect ~= nil then
        self.effect:destroy()
    end
    self.effect = UIEffect(self.eft, 10002, false, self.layer)
    --self.effect:SetConfig({ is_loop = true })
    self.effect.is_hide_clean = false
    self.effect:SetOrderIndex(250)
end


