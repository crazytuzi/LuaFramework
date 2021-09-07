-- @author 黄耀聪
-- @date 2017年2月25日

GuildSiegeManager = GuildSiegeManager or BaseClass(BaseManager)

function GuildSiegeManager:__init()
    if GuildSiegeManager.Instance ~= nil then
        Log.Error("不可重复实例化 GuildSiegeManager")
    end
    GuildSiegeManager.Instance = self
    self.model = GuildSiegeModel.New()

    self.onUpdateStatus = EventLib.New()
    self.onUpdateCastle = EventLib.New()
    self.onUpdateLog = EventLib.New()
    self.onUpdateMy = EventLib.New()
    self.onUpdateCheck = EventLib.New()

    self:SetShowTime()

    self:InitHandler()
end

function GuildSiegeManager:__delete()
end

function GuildSiegeManager:InitHandler()
    self:AddNetHandler(19100, self.on19100)
    self:AddNetHandler(19101, self.on19101)
    self:AddNetHandler(19102, self.on19102)
    self:AddNetHandler(19103, self.on19103)
    self:AddNetHandler(19104, self.on19104)
    self:AddNetHandler(19105, self.on19105)
    self:AddNetHandler(19106, self.on19106)
    self:AddNetHandler(19107, self.on19107)
    self:AddNetHandler(19108, self.on19108)
    self:AddNetHandler(19109, self.on19109)
    self:AddNetHandler(19110, self.on19110)
    self:AddNetHandler(19111, self.on19111)
    self:AddNetHandler(19112, self.on19112)

    EventMgr.Instance:AddListener(event_name.end_fight, function(type, result) self:EndFight(type, result) end)
    EventMgr.Instance:AddListener(event_name.begin_fight, function() self:BeginFight() end)
end

function GuildSiegeManager:OpenCastleWindow(args)
    -- if self.model.status == GuildSiegeEumn.Status.Disactive or (not self:IsMyGuildIn()) then
    --     NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开放，敬请期待"))
    -- elseif self.model.canOpenPanel ~= 1 then
    --     NoticeManager.Instance:FloatTipsByString(self.model.msg)
    -- else
        self.model:OpenCastleWindow(args)
    -- end
end

function GuildSiegeManager:CloseCastleWindow()
    self.model:CloseCastleWindow()
end

function GuildSiegeManager:ReqOnConnect()
    self.noMainUIIcon = true
    self.model:ClearStatus()
    self:send19100()
end

-- 战斗结束回调
function GuildSiegeManager:EndFight(type, result)
    if type == 112 and (CombatManager.Instance.lastCombatType == 1 or CombatManager.Instance.lastCombatType == 2) then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_siege_castle_window)
        -- GuildSiegeManager.Instance:OpenCastleWindow()
    end
end

-- 战斗开始回调
function GuildSiegeManager:BeginFight()
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.guild_siege_castle_window)
end

function GuildSiegeManager:SetIcon()
    if ((not self:IsMyGuildIn()) and (not self:CheckMeIn())) or self.noMainUIIcon ~= false or self.model.status == GuildSiegeEumn.Status.Disactive then
        MainUIManager.Instance:DelAtiveIcon(118)
        return
    end

    self:OnPush()

    if self.activeIconData == nil then
        self.activeIconData = AtiveIconData.New()
        local iconData = DataSystem.data_daily_icon[118]
        self.activeIconData.id = iconData.id
        self.activeIconData.iconPath = iconData.res_name
        self.activeIconData.sort = iconData.sort
        self.activeIconData.lev = iconData.lev

        self.activeIconData.clickCallBack = function()
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_siege_castle_window)
        end
    end
    self.activeIconData.timestamp = (self.model.targetTime - BaseUtils.BASE_TIME) + Time.time
    MainUIManager.Instance:AddAtiveIcon(self.activeIconData)
end

-- ================================== 外部接口 =============================================

-- 获取战斗结果，枚举值见GuildSiegeEumn.ResultType
function GuildSiegeManager:FinalResult()
    return self.model:FinalResult()
end

function GuildSiegeManager:Castle(type, order)
    for i,v in ipairs((((self.model.statusData or {}).guild_match_list or {})[type] or {}).castle_list) do
        if v.order == order then
            return v
        end
    end
    return nil
end

function GuildSiegeManager:IsMyGuildIn()
    local guild = ((self.model.statusData or {}).guild_match_list or {})[1] or {}
    local myGuild = GuildManager.Instance.model.my_guild_data or {}

    return myGuild.GuildId ~= nil and guild.guild_rid == myGuild.GuildId and guild.guild_plat == myGuild.PlatForm and guild.guild_zone == myGuild.ZoneId
end

function GuildSiegeManager:CheckMeIn()
    return self.model.myCastle ~= nil and self.model.myCastle.atk_times ~= nil and self.model.myCastle.atk_times < 2
end

function GuildSiegeManager:OpenSettle(args)
    self.model:OpenSettle(args)
end

-- ================================== 协议对接 =============================================

-- 请求活动状态
function GuildSiegeManager:send19100()
    Connection.Instance:send(19100, {})
end

function GuildSiegeManager:on19100(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>on19100</color>")
    self.model.status = data.status
    self.model.targetTime = BaseUtils.BASE_TIME + data.time
    self.model.statusData = self.model.statusData or {}
    self.model.statusData.round = data.round
    self.onUpdateStatus:Fire()

    self.model.guard_attack_log = nil
    self.model.enemy_attack_log = nil

    self:send19108()

    AgendaManager.Instance:SetCurrLimitID(2036, data.status == GuildSiegeEumn.Status.Acceptable or data.status == GuildSiegeEumn.Status.Ready)

    if self.showIconTimer ~= nil then LuaTimer.Delete(self.showIconTimer) self.showIconTimer = nil end

    if data.status == GuildSiegeEumn.Status.Acceptable then
        self:SetShowTime()
        -- self:send19101()

        -- 晚上9点半之前不能出来

        if self.showStemp > (BaseUtils.BASE_TIME or Time.Time) then
            -- self.showIconTimer = LuaTimer.Add((showStemp - (BaseUtils.BASE_TIME or Time.Time)) * 1000, function() self.noMainUIIcon = false self:SetIcon() end)
        else
            self.noMainUIIcon = false
            self:SetIcon()
        end
    end
    GuildManager.Instance:on_show_red_point()
end

-- 请求战局
function GuildSiegeManager:send19101()
    Connection.Instance:send(19101, {})
end

function GuildSiegeManager:on19101(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "<color='#0fff00'>on19101</color>")
    end
    self.model:SetStatus(data)
    self.onUpdateStatus:Fire()

    self:SetIcon()
    GuildManager.Instance:on_show_red_point()
end

-- 查看城堡
function GuildSiegeManager:send19102(flag, order)
    Connection.Instance:send(19102, {flag = flag, order = order})
end

function GuildSiegeManager:on19102(data)
    -- BaseUtils.dump(data, "<color='#ff8f00'>on19102</color>")
    self.model:SetCastle(data)
    self.onUpdateCastle:Fire(data.flag, data.order)
    self.onUpdateMy:Fire()
end

-- 攻击城堡
function GuildSiegeManager:send19103(order, star)
    print(string.format("send19103 order=%s  star=%s", order, star))
    if self.model.status ~= GuildSiegeEumn.Status.Disactive then
        Connection.Instance:send(19103, {order = order, star = star})
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("攻城战已结束"))
    end
end

function GuildSiegeManager:on19103(data)
    -- if data.flag == 0 then
    --     self:send19101()
    -- end
    NoticeManager.Instance:FloatTipsByString(data.reason)
end

-- 更改个人防御阵型
-- force = {formation, guard_id_1, guard_id_2, guard_id_3, guard_id_4, pet_id}
function GuildSiegeManager:send19104(force)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(force, "send19104")
    end

    if self.model.status ~= GuildSiegeEumn.Status.Disactive then
        Connection.Instance:send(19104, force)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("攻城战已结束"))
    end
end

function GuildSiegeManager:on19104(data)
    -- BaseUtils.dump(data, "on19104")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:SetMyCastle(data)
    if data.flag == 1 then
        self.onUpdateMy:Fire()
    end
end

-- 请求战斗记录
function GuildSiegeManager:send19105(flag)
    print("send19105")

    if self.model.status ~= GuildSiegeEumn.Status.Disactive then
        Connection.Instance:send(19105, {flag = flag})
    end
end

function GuildSiegeManager:on19105(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "on19105")
    end
    self.model.guard_attack_log = self.model.guard_attack_log or {}
    self.model.enemy_attack_log = self.model.enemy_attack_log or {}
    if data.flag == 1 then
        -- 己方公会
        for _,log in ipairs(data.castle_log) do
            self.model.guard_attack_log[log.time] = self.model.guard_attack_log[log.time] or log
            for key,value in pairs(log) do
                self.model.guard_attack_log[log.time][key] = value
            end
        end
    else
        -- 敌方公会
        for _,log in ipairs(data.castle_log) do
            self.model.enemy_attack_log[log.time] = self.model.enemy_attack_log[log.time] or log
            for key,value in pairs(log) do
                self.model.enemy_attack_log[log.time][key] = value
            end
        end
    end
    self.onUpdateLog:Fire(data.flag)
end

-- 请求自己阵型
function GuildSiegeManager:send19106()
    print("send19106")
    if self.model.status ~= GuildSiegeEumn.Status.Disactive then
        Connection.Instance:send(19106, {})
    end
end

function GuildSiegeManager:on19106(data)
    BaseUtils.dump(data, "on19106")
    self.model:SetMyCastle(data)
    self.onUpdateMy:Fire()
end

-- 更改个人宠物
function GuildSiegeManager:send19107(pet_id)
    if self.model.status ~= GuildSiegeEumn.Status.Disactive then
        Connection.Instance:send(19107, {pet_id = pet_id})
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("攻城战已结束"))
    end
end

function GuildSiegeManager:on19107(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:SetMyCastle(data)
    if data.flag == 1 then
        self.onUpdateMy:Fire()
    end
end

function GuildSiegeManager:send19108()
    Connection.Instance:send(19108, {})
end

function GuildSiegeManager:on19108(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "on19108")
    end
    self.model.myCastle = self.model.myCastle or {}
    self.model.canOpenPanel = data.flag
    self.model.msg = data.msg
    self.model.myCastle.atk_times = data.atk_num
    self.model.myCastle.type = 1
    self.model.myCastle.order = 0
    self.model.myCastle.classes = RoleManager.Instance.RoleData.classes
    self.model.myCastle.sex = RoleManager.Instance.RoleData.sex
    self.model.myCastle.lev = RoleManager.Instance.RoleData.lev
    self.model.myCastle.r_id = RoleManager.Instance.RoleData.id
    self.model.myCastle.r_plat = RoleManager.Instance.RoleData.platform
    self.model.myCastle.r_zone = RoleManager.Instance.RoleData.zone_id
    self.model.myCastle.castle_log = data.atk_log
    table.sort(self.model.myCastle.castle_log, function(a,b) return a.time < b.time end)
    self.onUpdateMy:Fire()

    if data.has_join == 1 then
        self:send19101()
    else
        self.model.statusData = {}
    end
end

-- 战斗结算
function GuildSiegeManager:send19109()
    Connection.Instance:send(19109, {})
end

function GuildSiegeManager:on19109(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "on19109")
    end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_siege_settle, {data})
end

-- 更新提示
function GuildSiegeManager:send19110()
end

function GuildSiegeManager:on19110(data)
    if data.flag == 1 then
        self.onUpdateCheck:Fire()
    end
end

-- 播放战斗录像
function GuildSiegeManager:send19111(replay_id, replay_plat, replay_zone)
    local tab = {replay_id = replay_id, replay_plat = replay_plat, replay_zone = replay_zone}
    BaseUtils.dump(tab, "send19111")
    Connection.Instance:send(19111, tab)
end

function GuildSiegeManager:on19111(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 观战
function GuildSiegeManager:send19112(flag, order)
    self.tempType = flag
    self.tempOrder = order

    Connection.Instance:send(19112, {flag = flag, order = order})
end

function GuildSiegeManager:on19112(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 0 and (self.tempType ~= nil and self.tempOrder ~= nil) then
        self:send19102(self.tempType, self.tempOrder)
        local castle = self:Castle(self.tempType, self.tempOrder)
        -- BaseUtils.dump(castle)
        self.model:ShowPlayer(castle)
        self.tempType = nil
        self.tempOrder = nil
    end
end

function GuildSiegeManager:OnPush()
    if ActivityManager.Instance:GetNoticeState(GlobalEumn.ActivityEumn.guild_siege) == false then
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.content = TI18N("<color=#FFFF00>公会攻城战</color>活动已开启，是否前往参加？")
        confirmData.sureSecond = -1
        confirmData.cancelSecond = 180
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_siege_castle_window) end

        -- if RoleManager.Instance.RoleData.cross_type == 1 then
        --     -- 如果处在中央服，先回到本服在参加活动
        --     RoleManager.Instance.jump_over_call = function() self:send14201() end
        --     confirmData.sureCallback = SceneManager.Instance.quitCenter
        --     confirmData.content = TI18N("<color='#ffff00'>公会攻城战</color>活动已开启，是否<color='#ffff00'>返回原服</color>参加？")
        -- end

        NoticeManager.Instance:ActiveConfirmTips(confirmData)
        ActivityManager.Instance:MarkNoticeState(GlobalEumn.ActivityEumn.guild_siege)
    end
end

function GuildSiegeManager:OnTick()
    local bool = (BaseUtils.BASE_TIME < self.showStemp)

    if self.noMainUIIcon ~= bool then
        self.noMainUIIcon = bool
        self:SetIcon()
    end
end

function GuildSiegeManager:SetShowTime()
    local year = os.date("%Y", BaseUtils.BASE_TIME)
    local month = os.date("%m", BaseUtils.BASE_TIME)
    local day = os.date("%d", BaseUtils.BASE_TIME)
    self.showStemp = tonumber(os.time{year = year, month = month, day = day, hour = 21, min = 30, sec = 0})
end


