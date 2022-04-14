-- @Author: lwj
-- @Date:   2019-03-4 15:39:24
-- @Last Modified time: 2019-3-24 15:39:27

CandyLeftCenter = CandyLeftCenter or class("CandyLeftCenter", BasePanel)
local CandyLeftCenter = CandyLeftCenter

CandyLeftCenter.SwitchType = {
    Rank = 1,
    Task = 2,
}

function CandyLeftCenter:ctor()
    self.abName = "candy"
    self.assetName = "CandyLeftCenter"
    self.layer = "Bottom"

    --self.change_scene_close = true
    self.model = CandyModel.GetInstance()
    self.reward_item_list = {}
    self.events = {}

    self.task_item_list = {}  --每日任务列表项UI 
end

function CandyLeftCenter:dctor()
    for i, v in pairs(self.reward_item_list) do
        v:destroy()
    end
end

function CandyLeftCenter:Open()
    BasePanel.Open(self)
end

function CandyLeftCenter:LoadCallBack()
    self.nodes = {
        "Rank/btn_to_rank", "Rank/top_name", "Rank/exp","Rank/reward_content", "endTime/endTitleTxt", "endTime",
        "Task","Rank",
        "Switch/img_rank_show","Switch/img_task_show",
        "Switch/text_rank","Switch/text_task",
        "Switch/btn_rank","Switch/btn_task",
        "Task/task_scroll/task_viewport/task_content",
    }
    self:GetChildren(self.nodes)
    self.top_name = GetText(self.top_name)
    self.exp = GetText(self.exp)
    self.endTitleTxt = GetText(self.endTitleTxt)

    self.img_rank_show = GetImage(self.img_rank_show)
    self.img_task_show = GetImage(self.img_task_show)
    self.text_rank = GetText(self.text_rank)
    self.text_task = GetText(self.text_task)

    self.switch_type = nil
    --self:SwitchRankOrTask(CandyLeftCenter.SwitchType.Rank)
    
    --SetAnchoredPosition(self.transform,600,0)
    SetAlignType(self.transform, bit.bor(AlignType.Left, AlignType.Null))
    self:AddEvent()
    self:LoadTopReward()
    self:UpdateView()
end

function CandyLeftCenter:AddEvent()
    self.end_time = self.model:GetEndTime()
    self.cd_schedual = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);

    self.update_view_event_id = self.model:AddListener(CandyEvent.UpdateLeftCenter, handler(self, self.UpdateView))
    GlobalEvent.AddEventListenerInTab(CandyEvent.CloseLeftCenter, handler(self, self.HandleCloseLeftCenter), self.events)
    GlobalEvent.AddEventListenerInTab(EventName.GameReset, function()
        self:destroy()
    end, self.events);
    self.change_end_event_id = GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.Close))

    local function callback()
        self.model.cur_rank_mode = 2
        GlobalEvent:Brocast(CandyEvent.RequestCandyRankInfo, 100)
    end
    AddButtonEvent(self.btn_to_rank.gameObject, callback)

    --排行与每日的按钮切换
    local function call_back(target, x, y)
        self:SwitchRankOrTask(CandyLeftCenter.SwitchType.Rank)
    end
    AddClickEvent(self.btn_rank.gameObject, call_back)
    local function call_back(target, x, y)
        self:SwitchRankOrTask(CandyLeftCenter.SwitchType.Task)
    end
    AddClickEvent(self.btn_task.gameObject, call_back)
end

function CandyLeftCenter:OpenCallBack()
    self.model.isOpenningLeftCenter = true
    CandyController.GetInstance():SetUpdateLeftCenterState(true)
end

--加载魅力排行第一的奖励UI
function CandyLeftCenter:LoadTopReward()
    local info = self.model:GetLeftCenterInfo()

    --判断是否为跨服活动
    local str = Config.db_candyroom_reward[1].reward
    if self.model:IsCross() then
        str = Config.db_candyroom_reward[1].cross_reward
    end
    
    local reward_tbl = String2Table(str)
    for i = 1, #reward_tbl do
        local param = {}
        local operate_param = {}
        local item_id = reward_tbl[i][1]
        param["item_id"] = item_id
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 70, y = 70 }  --奖励图标的大小
        local final_num = reward_tbl[i][2]
        if item_id == enum.ITEM.ITEM_PLAYER_EXP or item_id == enum.ITEM.ITEM_WORLDLV_EXP then
            final_num = GetProcessedExpNum(item_id, final_num)
        end
        param["num"] = final_num
        local itemIcon = GoodsIconSettorTwo(self.reward_content)
        itemIcon:SetIcon(param)
        self.reward_item_list[#self.reward_item_list + 1] = itemIcon
    end
end

function CandyLeftCenter:UpdateView()
    local info = self.model:GetLeftCenterInfo()
    if info then
        if self.top_name.text ~= info.top.name then
            self.top_name.text = info.top.name
        end
        local after_transfer_exp = GetShowNumber(tonumber(info.exp))
        if self.exp.text ~= after_transfer_exp then
            self.exp.text = after_transfer_exp
        end
    end

    --每日任务
    local taskConfig = Config.db_candyroom_task
    for i=1,#taskConfig do
        if not self.task_item_list[i] then
            self.task_item_list[i] = CandyTaskItem(self.task_content,self.layer)
            self.task_item_list[i]:SetData(taskConfig[i])
        end
    end

    --self:ShowTaskRedDot()
end

function CandyLeftCenter:HandleCloseLeftCenter()
    self:Close()
end

function CandyLeftCenter:EndDungeon()
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%02d";
    --整个副本的结束时间
    if self.end_time then
        --if not self.startSchedule and not self.hideByIcon then
        SetGameObjectActive(self.endTime.gameObject, true);
        --else
        --    SetGameObjectActive(self.endTime.gameObject, false);
        --end

        timeTab = TimeManager:GetLastTimeData(os.time(), self.end_time);
        if table.isempty(timeTab) then
            --Notify.ShowText("副本结束了,需要做清理了");
            GlobalSchedule.StopFun(self.cd_schedual);
        else
            if not timeTab.min then
                timeTab.min = 0
            end
            timestr = timestr .. string.format(formatTime, timeTab.min) .. ":";
            if not timeTab.sec then
                timeTab.sec = 0
            end
            timestr = timestr .. string.format(formatTime, timeTab.sec);
            self.endTitleTxt.text = timestr;--"副本倒计时: " ..
        end
    end
end

function CandyLeftCenter:CloseCallBack()
    if self.cd_schedual then
        GlobalSchedule:Stop(self.cd_schedual)
        self.cd_schedual = nil
    end
    if self.change_end_event_id then
        GlobalEvent:RemoveListener(self.change_end_event_id)
        self.change_end_event_id = nil
    end
    GlobalEvent:RemoveTabListener(self.events)
    self.model.isOpenningLeftCenter = false
    CandyController.GetInstance():SetUpdateLeftCenterState(false)
    for i, v in pairs(self.reward_item_list) do
        if v then
            v:destroy()
        end
    end
    self.reward_item_list = {}
    if self.update_view_event_id then
        self.model:RemoveListener(self.update_view_event_id)
        self.update_view_event_id = nil
    end
end

--选择排行或每日任务
function CandyLeftCenter:SwitchRankOrTask(switch_type)
    if self.switch_type == switch_type then
        return
    end

    self.switch_type = switch_type

    local rank_color
    local task_color
    if self.switch_type == CandyLeftCenter.SwitchType.Rank then
        rank_color = Color(252, 245, 224, 255)
        task_color = Color(162, 162, 162, 255)

        SetVisible(self.Rank,true)
        SetVisible(self.Task,false)
        SetVisible(self.img_rank_show,true)
        SetVisible(self.img_task_show,false)
        SetVisible(self.btn_to_rank,true)
    else
        rank_color = Color(162, 162, 162, 255)
        task_color = Color(252, 245, 224, 255)
        SetVisible(self.Rank,false)
        SetVisible(self.Task,true)
        SetVisible(self.img_rank_show,false)
        SetVisible(self.img_task_show,true)
        SetVisible(self.btn_to_rank,false)
    end

    SetColor(self.text_rank, rank_color.r, rank_color.g, rank_color.b, rank_color.a)
    SetColor(self.text_task, task_color.r, task_color.g, task_color.b, task_color.a)
end

--显示每日任务按钮的红点
function CandyLeftCenter:ShowTaskRedDot()
    if not self.task_reddot then
        self.task_reddot = RedDot(self.btn_task.transform)
        SetLocalPosition(self.task_reddot.transform, 75, 14)
    end
    SetVisible(self.task_reddot,true)
end 

