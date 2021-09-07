-- 公会英雄战
-- @author zgs
GuildFightEliteManager = GuildFightEliteManager or BaseClass(BaseManager)

function GuildFightEliteManager:__init()
    if GuildFightEliteManager.Instance then
        Debug.LogError("")
        return
    end
    GuildFightEliteManager.Instance = self
    self:initHandle()
    self.model = GuildfightEliteModel.New()

    self.eliteWarInfo = nil --活动状态
    self.eliteLeaderInfo = {} --领队信息
    self.guildEliteWarMatch = nil -- 对战信息
    self.fightLogs = nil --战绩记录

    self.model.isInLookFightRecord = false

    self.isNeedCheckShowTips = false
end

function GuildFightEliteManager:initHandle()
    self:AddNetHandler(16200, self.on16200)
    self:AddNetHandler(16201, self.on16201)
    self:AddNetHandler(16202, self.on16202)
    self:AddNetHandler(16203, self.on16203)
    self:AddNetHandler(16204, self.on16204)
    self:AddNetHandler(16205, self.on16205)
    self:AddNetHandler(16206, self.on16206)
    self:AddNetHandler(16207, self.on16207)
end
--活动状态
function GuildFightEliteManager:on16200(data)
	-- BaseUtils.dump(data, "on16200==="..RoleManager.Instance.RoleData.event)
    local lastStatus = self.eliteWarInfo

    self.eliteWarInfo = data

    if (lastStatus == nil or (lastStatus ~= nil and (lastStatus.status ==0 or lastStatus.status ==1)))
        and (self.eliteWarInfo.status ==2 or self.eliteWarInfo.status ==3)
        and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.GuildEliteFight
        and GuildManager.Instance.model:has_guild() == true
        and GuildManager.Instance.model.my_guild_data.Lev >= 2 --2级以上
        and GuildManager.Instance.model.my_guild_data.MemNum >= 50 -- 50人以上
        and GuildManager.Instance.model.my_guild_data.create_time >= 259200  then --三天以上

        if self.eliteWarInfo.status ==2 then
            self:EnterGuildFightEliteTips()
        elseif self.eliteWarInfo.status ==3 then
            self.isNeedCheckShowTips = true
            self:send16205()
        end
    end

    local cfg_data = DataSystem.data_daily_icon[113]
    if self.eliteWarInfo.status == 1 then
        -- 可分配
        -- local iconData = AtiveIconData.New()
        -- iconData.id = cfg_data.id
        -- iconData.iconPath = cfg_data.res_name
        -- iconData.text = "精英战可分配"
        -- iconData.clickCallBack = function()
        --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guildfightelite_window)
        -- end
        -- iconData.sort = cfg_data.sort
        -- iconData.lev = cfg_data.lev
        -- MainUIManager.Instance:AddAtiveIcon(iconData)
    elseif self.eliteWarInfo.status == 2 then
        --准备
        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        iconData.iconPath = cfg_data.res_name
        iconData.text = TI18N("准备中")
        iconData.clickCallBack = function()
            -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guildfightelite_window)
            self:GuildFightEliteCheckIn()
        end
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        MainUIManager.Instance:AddAtiveIcon(iconData)
    elseif self.eliteWarInfo.status == 3 then
        --开始
        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        iconData.iconPath = cfg_data.res_name
        iconData.clickCallBack = function()
            -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guildfightelite_window)
            self:GuildFightEliteCheckIn()
        end
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        iconData.timestamp =self.eliteWarInfo.timeout + Time.time
        iconData.timeoutCallBack = timeout_callback
        iconData.timeoutCallBack = function()
            MainUIManager.Instance:DelAtiveIcon(113)
        end
        MainUIManager.Instance:AddAtiveIcon(iconData)
    else
        --未开始
        MainUIManager.Instance:DelAtiveIcon(113)
    end

    if self.eliteWarInfo.status > 0 then
        self:send16201()
    end
    EventMgr.Instance:Fire(event_name.guildfight_elite_acitveinfo_change)

    self.eliteWarInfo.timeout = self.eliteWarInfo.timeout + Time.time
end
function GuildFightEliteManager:EnterGuildFightEliteTips()
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = string.format(TI18N("%s已经开始，是否传送进入？"), ColorHelper.Fill(ColorHelper.color[5], TI18N("公会英雄战")))
    data.sureLabel = TI18N("确定")
    data.cancelLabel = TI18N("取消")
    data.cancelSecond = 120
    data.sureCallback = function () self:send16203() end

    if RoleManager.Instance.RoleData.cross_type == 1 then
        -- 如果处在中央服，先回到本服在参加活动
        RoleManager.Instance.jump_over_call = function() self:send16203() end
        data.sureCallback = SceneManager.Instance.quitCenter
        data.content = string.format(TI18N("%s活动已经开始，是否<color='#ffff00'>返回原服</color>参加？"), ColorHelper.Fill(ColorHelper.color[5], TI18N("公会英雄战")))
    end

    NoticeManager.Instance:ActiveConfirmTips(data)
end
function GuildFightEliteManager:checkRedPoint()
    if self.eliteWarInfo ~= nil and self.eliteWarInfo.status > 0 then
        --可分配状态
        if GuildManager.Instance.model:has_guild() == true --有公会
            and GuildManager.Instance.model:get_my_guild_post() >= GuildManager.Instance.model.member_positions.elder --长老以上级别
            and GuildManager.Instance.model.my_guild_data.Lev >= 2 --2级以上
            and GuildManager.Instance.model.my_guild_data.MemNum >= 50 -- 50人以上
            and GuildManager.Instance.model.my_guild_data.create_time >= 259200  then --三天以上
            --有公会，且是长老级别以上
            if self.eliteLeaderInfo ~= nil and #self.eliteLeaderInfo < 3 then
                return true
            end
        end
    end
    return false
end
--活动状态
function GuildFightEliteManager:send16200()
    -- -- print("-------------------==uildFightEliteManager:send16200()================")
    Connection.Instance:send(16200, {})
end
--领队信息
function GuildFightEliteManager:on16201(data)
    -- BaseUtils.dump(data, "on16201==="..RoleManager.Instance.RoleData.event)
    self.eliteLeaderInfo = data.guild_hero_team_leader

    -- if RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildEliteFight then
        EventMgr.Instance:Fire(event_name.guildfight_elite_leaderinfo_change)
    -- end
end
--领队信息
function GuildFightEliteManager:send16201()
    Connection.Instance:send(16201, {})
end
--分配领队
function GuildFightEliteManager:on16202(data)
    -- BaseUtils.dump(data, "on16202==="..RoleManager.Instance.RoleData.event)
    if data.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
    if data.flag == 1 then
        self.model:ShowEliteMemberPanel(false)
    end
end
--分配领队
function GuildFightEliteManager:send16202(id,platform,zone_id,position)
    -- print("GuildFightEliteManager:send16202(id,platform,zone_id,position) = "..position)
    Connection.Instance:send(16202, {id = id,platform = platform,zone_id = zone_id,position = position})
end
--参与
function GuildFightEliteManager:on16203(data)
    -- BaseUtils.dump(data, "on16203==="..RoleManager.Instance.RoleData.event)
    if data.flag == 1 then
        --参与成功
        -- self:send16205()
        -- GuildfightManager.Instance.model:CheckTeamVisible()
    end
    if data.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end
--参与
function GuildFightEliteManager:send16203()
    Connection.Instance:send(16203, {})
end
--退出
function GuildFightEliteManager:on16204(data)
    -- BaseUtils.dump(data, "on16204==="..RoleManager.Instance.RoleData.event)
    -- GuildfightManager.Instance.model:CheckTeamVisible()
end
--退出
function GuildFightEliteManager:send16204()
    Connection.Instance:send(16204, {})
end
--对战信息
function GuildFightEliteManager:on16205(data)
    -- BaseUtils.dump(data, "on16205==="..RoleManager.Instance.RoleData.event)
    self.guildEliteWarMatch = data

    if RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildEliteFight then
        EventMgr.Instance:Fire(event_name.guild_elite_war_match_info_change)
    end

    if self.isNeedCheckShowTips == true then
        self.isNeedCheckShowTips = false
        local isShow = false
        if self.guildEliteWarMatch.round == 1 then
            isShow = true
        elseif self.guildEliteWarMatch.round == 2 then
            for i,v in ipairs(self.guildEliteWarMatch.leaders) do
                if v.is_win == 0 then
                    isShow = true
                    break
                end
            end
        end
        if isShow == true then
            self:EnterGuildFightEliteTips()
        end
    end
end
--对战信息
function GuildFightEliteManager:send16205()
    Connection.Instance:send(16205, {})
end
--战绩记录
function GuildFightEliteManager:on16206(data)
    -- BaseUtils.dump(data, "on16206==="..RoleManager.Instance.RoleData.event)
    self.fightLogs = data.logs

    self.model:UpdateFightLogs(self.fightLogs)
end
--战绩记录
function GuildFightEliteManager:send16206()
    Connection.Instance:send(16206, {})
end

--播放战斗录像
function GuildFightEliteManager:on16207(data)
    -- BaseUtils.dump(data, "on16207==="..RoleManager.Instance.RoleData.event)
    if data.result == 1 then
        self.model.isInLookFightRecord = true
        -- self.model:CloseMain()
        if self.model.gaWin ~= nil then
            self.model.gaWin:Hide()
        end
    end
    if data.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end
--播放战斗录像
function GuildFightEliteManager:send16207(match_type, match_local_id, position)
    -- print(match_id.."-----------------"..position)
    Connection.Instance:send(16207, {match_type = match_type , match_local_id = match_local_id,position = position})
end

function GuildFightEliteManager:GuildFightEliteCheckIn()
    if RoleManager.Instance.RoleData.cross_type == 1 then
        -- 如果处在中央服，先回到本服在参加活动
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureSecond = -1
        confirmData.cancelSecond = 180
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        RoleManager.Instance.jump_over_call = function() self:send16203() end
        confirmData.sureCallback = SceneManager.Instance.quitCenter
        confirmData.content = TI18N("是否<color='#ffff00'>返回原服</color>参加<color='#ffff00'>公会英雄战</color>活动？")
        NoticeManager.Instance:ConfirmTips(confirmData)
    else
        self:send16203()
    end
end