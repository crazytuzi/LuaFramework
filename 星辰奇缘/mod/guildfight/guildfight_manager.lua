--  公会战
-- @author zgs
GuildfightManager = GuildfightManager or BaseClass(BaseManager)

function GuildfightManager:__init()
    if GuildfightManager.Instance then
        Debug.LogError("")
        return
    end
    GuildfightManager.Instance = self
    self:initHandle()

    self.stateInfo = {} --公会战活动状态
    self.myGuildFightList = {} --我的公会对阵信息
    self.mineinfo = {} --个人行动力等信息
    self.allguildFightList = {} -- 所有公会的对战信息
    self.mode = 0 --预赛=0，决赛=1
    self.enemyInfo = {} --敌方成员信息

    self.guildWarRole = {}
    self.guildWarRoleKeyValue = {}

    self.model = GuildfightModel.New()

    self.isGoIn = false

    self.lastStatus = 0
end

function GuildfightManager:initHandle()
    self:AddNetHandler(15500, self.on15500)
    self:AddNetHandler(15501, self.on15501)
    self:AddNetHandler(15502, self.on15502)
    self:AddNetHandler(15503, self.on15503)
    self:AddNetHandler(15504, self.on15504)
    self:AddNetHandler(15505, self.on15505)
    self:AddNetHandler(15506, self.on15506)
    self:AddNetHandler(15507, self.on15507)
    self:AddNetHandler(15508, self.on15508)
    self:AddNetHandler(15509, self.on15509)
    -- EventMgr.Instance:AddListener(event_name.mainui_btn_init, function ()
    --     Log.Error("GuildfightManager:initHandle()------------------------------")
    --     print(GuildManager.Instance.model:has_guild())
    --     if GuildManager.Instance.model:has_guild() == true then
    --         self:send15500() --登陆后，请求活动状态 =>>收到公会信息协议11100后请求
    --         self:send15501()
    --     end
    --     -- self:send15506()
    -- end)

    EventMgr.Instance:AddListener(event_name.role_event_change, function ()
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFight then
            self:send15501()
        end
    end)
end
function GuildfightManager:IsGuildFightStart()
    return (GuildfightManager.Instance.stateInfo.status == 1 or GuildfightManager.Instance.stateInfo.status == 2)
end
--活动状态
function GuildfightManager:on15500(data)
    -- Log.Error("on15500")
	-- BaseUtils.dump(data, "on15500==="..RoleManager.Instance.RoleData.event)
    local lastStatus = self.stateInfo.status
    self.stateInfo = data
    if (lastStatus == nil or (lastStatus ~= nil and lastStatus ==0))
        and (self.stateInfo.status ==1 or self.stateInfo.status ==2)
        and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.GuildFightReady
        and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.GuildFight
        and GuildManager.Instance.model:has_guild() == true
        and RoleManager.Instance.RoleData.lev >= RoleManager.Instance.world_lev - 25
        then
        -- -- print("------------")
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("%s活动开始了，立即前往？"),ColorHelper.Fill(ColorHelper.color[5],TI18N("公会战")))
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.cancelSecond = 180
        data.sureCallback = function () self:send15502() end

        local role = RoleManager.Instance.RoleData
        if role.cross_type == 1 and role.event == RoleEumn.Event.None  and self.myGuildFightList[1] ~= nil and self.myGuildFightList[1].match_type == 1 then
            if TeamManager.Instance.teamCrossType ~= 1 then
                -- 如果处在中央服，先回到本服在参加活动
                RoleManager.Instance.jump_over_call = function() self:send15502() end
                data.sureCallback = SceneManager.Instance.quitCenter
                data.content = string.format(TI18N("%s活动已经开始，是否<color='#ffff00'>返回原服</color>参加？"),ColorHelper.Fill(ColorHelper.color[5], TI18N("公会战")))
            end
        end

        NoticeManager.Instance:ActiveConfirmTips(data)
    end
    if self.lastStatus == 0 and (GuildfightManager.Instance.stateInfo.status == 1 or GuildfightManager.Instance.stateInfo.status == 2) then
        --开启公会战
        EventMgr.Instance:Fire(event_name.guild_fight_status_update)
    elseif self.lastStatus ~= 0 and (GuildfightManager.Instance.stateInfo.status == 0 or GuildfightManager.Instance.stateInfo.status == 3) then
        --公会战结束
        EventMgr.Instance:Fire(event_name.guild_fight_status_update)
    end
    self.lastStatus = GuildfightManager.Instance.stateInfo.status
    AgendaManager.Instance:SetCurrLimitID(2015,self.stateInfo.status ~= 0) --日程界面，公会战项的显示状态
    -- GuildManager.Instance.model:update_tab_red_point(3) --公会主界面红点检查
    -- GuildManager.Instance:on_show_red_point() --主界面公会按钮红点检查
    if self.stateInfo.status ~= 0 then
        -- Log.Error("send15501")
        self:send15501()
        self:send15505()


        if RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFight or RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFightReady then
            EventMgr.Instance:Fire(event_name.guild_fight_data_update)
        end
    end
    local cfg_data = DataSystem.data_daily_icon[111]
    if self.stateInfo.status == 1 then
        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        iconData.iconPath = cfg_data.res_name
        iconData.text = TI18N("准备中")
        iconData.clickCallBack = function()
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_fight_window)
        end
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        MainUIManager.Instance:AddAtiveIcon(iconData)
    elseif self.stateInfo.status == 2 then
        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        iconData.iconPath = cfg_data.res_name
        iconData.clickCallBack = function()
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_fight_window)
        end
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        iconData.timestamp =self.stateInfo.timeout + Time.time
        iconData.timeoutCallBack = timeout_callback
        iconData.timeoutCallBack = function()
            MainUIManager.Instance:DelAtiveIcon(111)
        end
        MainUIManager.Instance:AddAtiveIcon(iconData)
    elseif self.stateInfo.status == 3 then
        MainUIManager.Instance:DelAtiveIcon(111)
    else
        self.model:ExitScene()
        MainUIManager.Instance:DelAtiveIcon(111)
    end

    self.stateInfo.timeout = self.stateInfo.timeout + Time.time
    -- self:CalTimeOut()
end
-- function GuildfightManager:CalTimeOut()
--     if self.timerId ~= nil and self.timerId ~= 0 then
--         LuaTimer.Delete(self.timerId)
--     end
--     if self.stateInfo.status ~= 0 and self.stateInfo.timeout > 0 then
--         -- self.lastTime = Time.time --记录的上次执行1秒倒计时时间
--         -- self.curTime = Time.time --当前执行1秒倒计时时间
--         self.timerId = LuaTimer.Add(0, 1000, function()
--             if self.stateInfo.timeout > 0 then
--                 -- self.curTime = Time.time
--                 self.stateInfo.timeout = self.stateInfo.timeout - 1 -- (self.curTime - self.lastTime)
--                 -- self.lastTime = Time.time
--             else
--                 LuaTimer.Delete(self.timerId)
--             end
--         end)
--     end
-- end
--查看我的公会对阵信息
function GuildfightManager:on15501(data)
    -- Log.Error("on15501")
    -- BaseUtils.dump(data, "on15501---"..RoleManager.Instance.RoleData.event)
    self.myGuildFightList = data.guild_war_alliance
    -- if self.isGoIn == true and RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFight then
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFight then
        EventMgr.Instance:Fire(event_name.guild_fight_data_update)
    end
end
--参与
function GuildfightManager:on15502(data)
    -- BaseUtils.dump(data, "on15502")
    if RoleManager.Instance.RoleData.lev < RoleManager.Instance.world_lev - 25 then
        NoticeManager.Instance:FloatTipsByString("由于你的等级低于世界等级25级以上，无法参加公会战")
        return
    end
    self.isGoIn = true
    if data.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end
--退出
function GuildfightManager:on15503(data)
    -- BaseUtils.dump(data, "on15503")
    self.isGoIn = false
    if data.flag == 1 then
        self.model:ExitScene()
    end
    if data.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
    self.model:CheckTeamVisible()
end
--发起战斗
function GuildfightManager:on15504(data)
    -- BaseUtils.dump(data, "on15504")
    if data.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end
--查看个人信息
function GuildfightManager:on15505(data)
    -- BaseUtils.dump(data, "on15505")
    self.mineinfo = data
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFight then
        EventMgr.Instance:Fire(event_name.guild_fight_data_update)
    end
end
function GuildfightManager:on15506(data)
    -- BaseUtils.dump(data, "on15506")
    self.allguildFightList = data.guild_war_guild
    self.mode = data.mode
    self.model:UpdateWindow()
end
--成员战绩
function GuildfightManager:on15507(data)
    -- BaseUtils.dump(data, "on15507")
    self.guildWarRole = data.guild_war_role

    for i,v in ipairs(self.guildWarRole) do
        self.guildWarRoleKeyValue[BaseUtils.Key(v.rid, v.platform, v.zone_id)] = v
    end
    -- if RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFight then
        EventMgr.Instance:Fire(event_name.guild_war_role)
    -- end
end

--敌方成员信息
function GuildfightManager:on15508(data)
    -- BaseUtils.dump(data, "on15508")
    self.enemyInfo = data.guild_war_role
    self.model:ShowGuildFightRemainEnemyPanel(true)
end
--活动退出推送
function GuildfightManager:on15509(data)
    -- BaseUtils.dump(data, "on15509")
    self.model:OpenGuildFightIntegralPanel()

    self.model:CheckTeamVisible()
end

--查询活动状态
function GuildfightManager:send15500()
    -- Log.Error("send15500")
    Connection.Instance:send(15500, {})
end
--查看我的公会对阵信息
function GuildfightManager:send15501()
    Connection.Instance:send(15501, {})
end
--参与
function GuildfightManager:send15502()
    -- Log.Debug("send15502"..debug.traceback())
    self.isGoIn = true
    -- self:send15500()
    Connection.Instance:send(15502, {})
end
--退出
function GuildfightManager:send15503()
    -- Log.Error("send15503")
    self.isGoIn = false
    Connection.Instance:send(15503, {})
end
--发起战斗
function GuildfightManager:send15504(idTemp,platformTemp,zoneId)
    -- print(idTemp..","..platformTemp..","..zoneId)
    Connection.Instance:send(15504, {id=idTemp,platform=platformTemp,zone_id=zoneId})
end
--查看个人信息
function GuildfightManager:send15505()
    Connection.Instance:send(15505, {})
end

function GuildfightManager:send15506()
    -- Log.Error("send15506")
    Connection.Instance:send(15506, {})
end

--成员战绩
function GuildfightManager:send15507()
    Connection.Instance:send(15507, {})
end

--敌方成员信息
function GuildfightManager:send15508()
    -- Log.Error("send15508")
    Connection.Instance:send(15508, {})
end

function GuildfightManager:GuildFightCheckIn()
    local role = RoleManager.Instance.RoleData
    if role.cross_type == 1 and role.event == RoleEumn.Event.None and self.myGuildFightList[1].match_type == 1 then
        -- 如果处在中央服，先回到本服在参加活动
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureSecond = -1
        confirmData.cancelSecond = 180
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        RoleManager.Instance.jump_over_call = function() self:send15502() end
        confirmData.sureCallback = SceneManager.Instance.quitCenter
        confirmData.content = string.format(TI18N("%s活动已经开始，是否<color='#ffff00'>返回原服</color>参加？"),ColorHelper.Fill(ColorHelper.color[5], TI18N("公会战")))
        NoticeManager.Instance:ConfirmTips(confirmData)
    else
        self:send15502()
    end
end
