TopCompeteManager = TopCompeteManager or BaseClass(BaseManager)

function TopCompeteManager:__init()
    if TopCompeteManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    TopCompeteManager.Instance = self
    self.status_timer_id = 0
    self:InitHandler()
    self.model = TopCompeteModel.New()
    self.last_status = nil
    self.team_tips = false
end

function TopCompeteManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function TopCompeteManager:InitHandler()
    self:AddNetHandler(15100, self.on15100)
    self:AddNetHandler(15101, self.on15101)
    self:AddNetHandler(15102, self.on15102)
    self:AddNetHandler(15103, self.on15103)
    self:AddNetHandler(15104, self.on15104)
    self:AddNetHandler(15105, self.on15105)
    self.on_role_change = function(data)
        self:request15100()
    end
    EventMgr.Instance:AddListener(event_name.role_level_change, self.on_role_change)


    self.on_mainui_btn_init = function(data)
        self:request15100()
    end
    EventMgr.Instance:AddListener(event_name.mainui_btn_init, self.on_mainui_btn_init)

    self.time_out_callback = function()
        self:request15100()
    end

    self.icon_click_callback = function()
        -- self:request15101()
        self:TopCheckIn()
    end
end


----------------------------------------------协议接收处理逻辑
--活动状态
function TopCompeteManager:on15100(data)
    -- print("--------------------------------------收到15100")
    self.model.top_compete_status_data = data
    local cfg_data = DataSystem.data_daily_icon[109]
    if cfg_data.lev > RoleManager.Instance.RoleData.lev then
        --等级不够，图标和弹窗都不要
        return
    end

    if RoleManager.Instance.RoleData.event == RoleEumn.Event.TopCompete then
        if MainUIManager.Instance.mainuitracepanel ~= nil and MainUIManager.Instance.mainuitracepanel.childTab[TraceEumn.ShowType.TopCompete] ~= nil and MainUIManager.Instance.mainuitracepanel.childTab[TraceEumn.ShowType.TopCompete].gameObject ~= nil then
            MainUIManager.Instance.mainuitracepanel.childTab[TraceEumn.ShowType.TopCompete]:update_status()
        end
    end

    if data.status == 0 then
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
        AgendaManager.Instance:SetCurrLimitID(2014, false)
    elseif data.status == 1 then
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
        AgendaManager.Instance:SetCurrLimitID(2014, true)
    else
        AgendaManager.Instance:SetCurrLimitID(2014, true)
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        iconData.iconPath = cfg_data.res_name
        iconData.clickCallBack = self.icon_click_callback
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        iconData.timestamp = data.time + Time.time
        iconData.timeoutCallBack = self.time_out_callback
        MainUIManager.Instance:AddAtiveIcon(iconData)

        if data.status == 2 then
            --弹出确认框，通知是否参加
            if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.TopCompete then
                if ActivityManager.Instance:GetNoticeState(GlobalEumn.ActivityEumn.top_compete) == false then
                    local data = NoticeConfirmData.New()
                    data.type = ConfirmData.Style.Normal
                    data.content = TI18N("<color='#ffff00'>巅峰对决</color>开启了，是否加入？")
                    data.sureLabel = TI18N("确认")
                    data.cancelSecond = 30
                    data.cancelLabel = TI18N("取消")
                    data.sureCallback = function() TopCompeteManager.Instance:request15101() end

                    if RoleManager.Instance.RoleData.cross_type == 1 then
                        -- 如果处在中央服，先回到本服在参加活动
                        RoleManager.Instance.jump_over_call = function() TopCompeteManager.Instance:request15101() end
                        data.sureCallback = SceneManager.Instance.quitCenter
                        data.content = TI18N("<color=#FFFF00>巅峰对决</color>活动已开启，是否<color='#ffff00'>返回原服</color>参加？")
                    end

                    NoticeManager.Instance:ActiveConfirmTips(data)
                    ActivityManager.Instance:MarkNoticeState(GlobalEumn.ActivityEumn.top_compete)
                end
            end
            self.last_status = data.status
        elseif data.status == 3 then
            --弹出确认框，通知是否参加
            if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.TopCompete then
                if ActivityManager.Instance:GetNoticeState(GlobalEumn.ActivityEumn.top_compete) == false then
                    local data = NoticeConfirmData.New()
                    data.type = ConfirmData.Style.Normal
                    data.content = TI18N("<color='#ffff00'>巅峰对决</color>开启了，是否加入？")
                    data.sureLabel = TI18N("确认")
                    data.cancelSecond = 30
                    data.cancelLabel = TI18N("取消")
                    data.sureCallback = function() TopCompeteManager.Instance:request15101() end

                    if RoleManager.Instance.RoleData.cross_type == 1 then
                        -- 如果处在中央服，先回到本服在参加活动
                        RoleManager.Instance.jump_over_call = function() TopCompeteManager.Instance:request15101() end
                        data.sureCallback = SceneManager.Instance.quitCenter
                        data.content = TI18N("<color=#FFFF00>巅峰对决</color>活动已开启，是否<color='#ffff00'>返回原服</color>参加？")
                    end

                    NoticeManager.Instance:ActiveConfirmTips(data)
                    ActivityManager.Instance:MarkNoticeState(GlobalEumn.ActivityEumn.top_compete)
                end
            else
                --如果状态是3，上个状态是2且已经在里面，则进行队伍判断
                if self.last_status == 2 then
                    --上一个状态是2
                    self.last_status = data.status
                    self:show_team_tips(true)
                end
            end
        elseif data.status == 4 then
            --宝箱
            self.last_status = 4
            self:show_team_tips(false)
        end

        self:star_status_timer()
    end
end

--显示队伍提示
function TopCompeteManager:show_team_tips(tips)
    if self.team_tips == tips then
        return
    end
    self.team_tips = tips
    if self.team_tips == false then
        return
    end
    if TeamManager.Instance:HasTeam() then
        local leave_num = 0
        local total_num = 0
        for k, v in pairs(TeamManager.Instance.memberTab) do
            total_num = total_num + 1
            if v.status == RoleEumn.TeamStatus.Away then
                leave_num = leave_num + 1
            end
        end
        if total_num - leave_num < 3 then
            local c_data = NoticeConfirmData.New()
            c_data.type = ConfirmData.Style.Sure
            c_data.content = TI18N("活动正式开始，但队伍当前人数不足，<color='#ffff00'>3人以上</color>组队才能加入匹配队列哦！")
            c_data.sureLabel = TI18N("确认")
            NoticeManager.Instance:ConfirmTips(c_data)
        end
    else
        local c_data = NoticeConfirmData.New()
        c_data.type = ConfirmData.Style.Sure
        c_data.content = TI18N("活动正式开始，但队伍当前人数不足，<color='#ffff00'>3人以上</color>组队才能加入匹配队列哦！")
        c_data.sureLabel = TI18N("确认")
        NoticeManager.Instance:ConfirmTips(c_data)
    end
end


--中部计时器
function TopCompeteManager:star_status_timer()
    self:stop_status_timer()
    if self.status_timer_id ~= 0 then
        return
    end
    self.status_timer_id = LuaTimer.Add(0, 1000, function()
        self:status_timer_tick()
    end)
end

function TopCompeteManager:stop_status_timer()
    if self.status_timer_id ~= 0 then
        LuaTimer.Delete(self.status_timer_id)
        self.status_timer_id = 0
    end
end

function TopCompeteManager:status_timer_tick()
    self.model.top_compete_status_data.time = self.model.top_compete_status_data.time - 1
    if self.model.top_compete_status_data.time <= 0 then
        self:stop_status_timer()
    end
end

--请求进入战区
function TopCompeteManager:on15101(data)
    -- print("------------------------------------------------收到15101")
    if data.result == 0 then
        --失败

    elseif data.result == 1 then
        --成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--请求退出战区
function TopCompeteManager:on15102(data)
    -- print("------------------------------------------------收到15102")
    if data.result == 0 then
        --失败

    elseif data.result == 1 then
        --成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--当前战区数据
function TopCompeteManager:on15103(data)
    -- print("------------------------------------------------收到15103")
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.TopCompete then
        if MainUIManager.Instance.mainuitracepanel.childTab[TraceEumn.ShowType.TopCompete] ~= nil and MainUIManager.Instance.mainuitracepanel.childTab[TraceEumn.ShowType.TopCompete].gameObject ~= nil then
            MainUIManager.Instance.mainuitracepanel.childTab[TraceEumn.ShowType.TopCompete]:update_info(data)
        end
    end
end

--结算数据
function TopCompeteManager:on15104(data)
    -- print("-------------------------------------------------收到15104")
    self.model.top_compete_finish_data = data
    self.model:InitFinishUI()
end


function TopCompeteManager:on15105(data)
    self.model.box_data = data
    self.model:InitBoxUI()
end


-----------------------------------------------协议请求处理逻辑
--活动状态
function TopCompeteManager:request15100()
    -- print("-------------------------------发送15100")
    Connection.Instance:send(15100, {})
end

--请求进入战区
function TopCompeteManager:request15101()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.TopCompete then
        NoticeManager.Instance:FloatTipsByString(TI18N("你已经在战区中"))
        return
    end
    -- print("-------------------------------发送15101")
    Connection.Instance:send(15101, {})
end

--请求退出战区
function TopCompeteManager:request15102()
    -- print("-------------------------------发送15102")
    Connection.Instance:send(15102, {})
end

--当前战区数据
function TopCompeteManager:request15103()
    -- print("-------------------------------发送15103")
    Connection.Instance:send(15103, {})
end

--结算数据
function TopCompeteManager:request15104()
    -- print("-------------------------------发送15104")
    Connection.Instance:send(15104, {})
end

function TopCompeteManager:TopCheckIn()
    if RoleManager.Instance.RoleData.cross_type == 1 then
        -- 如果处在中央服，先回到本服在参加活动
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureSecond = -1
        confirmData.cancelSecond = 180
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        RoleManager.Instance.jump_over_call = function() self:request15101() end
        confirmData.sureCallback = SceneManager.Instance.quitCenter
        confirmData.content = TI18N("<color='#ffff00'>巅峰对决</color>活动已开启，是否<color='#ffff00'>返回原服</color>参加？")
        NoticeManager.Instance:ConfirmTips(confirmData)
    else
        self:request15101()
    end
end