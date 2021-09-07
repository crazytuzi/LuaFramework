AgendaManager = AgendaManager or BaseClass(BaseManager)

function AgendaManager:__init()
    if AgendaManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    AgendaManager.Instance = self
    self.currTimeLimitID = 0
    self.currLimitList = {}
    self.recommend_list = {}
    self.agenda_list = {}
    self.model = AgendaModel.New()
    self:InitHandler()
    self.DefaultDoubleNum = 150

    self.endfrightcallback = function()
        LuaTimer.Add(1000, function()self:Require12003()end)
    end
    self.frightingFreez = false

    self.double_point = 0
    self.max_double_point = 0
    self.refreshTime = 0
    self.redpoint_state = false

    for k,v in pairs(DataAgenda.data_list) do
        DataAgenda.data_list[k].engaged = 0
    end

    self.showtWeekRewardRedPoint = false

    self.OnUpdateAgendaWeekData = EventLib.New()
end

function AgendaManager:__delete()
    self.model:DeleteMe()
end

function AgendaManager:InitHandler()
    self:AddNetHandler(12000, self.On12000)
    self:AddNetHandler(12001, self.On12001)
    self:AddNetHandler(12002, self.On12002)
    self:AddNetHandler(12003, self.On12003)
    self:AddNetHandler(12004, self.On12004)
    self:AddNetHandler(12005, self.On12005)
    self:AddNetHandler(12006, self.On12006)
    self:AddNetHandler(12007, self.On12007)
    self:AddNetHandler(12010, self.On12010)
    self:AddNetHandler(12011, self.On12011)

    EventMgr.Instance:AddListener(event_name.self_loaded, function() self:Require12001() if self.agenda_list == nil then self:Require12000() end end)
    EventMgr.Instance:AddListener(event_name.logined, function() self:LoadDailyList()    self:LoadTimeLimit()    self:LoadCommingSoon() self:LoadDungeonList() self:LoadChallangeList() self:Require12000() end)
    EventMgr.Instance:AddListener(event_name.role_level_change, function() self:LoadDailyList()    self:LoadTimeLimit()    self:LoadCommingSoon() self:LoadChallangeList() self:LoadDungeonList() self:UpdateTrace() end)
    EventMgr.Instance:AddListener(event_name.world_lev_change, function() self:LoadDailyList()    self:LoadTimeLimit()    self:LoadCommingSoon() self:LoadChallangeList() self:LoadDungeonList() end)

end

function AgendaManager:ReqOnReConnect()
    self:DeleteCustom()
    self:Require12001()
    self:Require12000()
    self:Require12010()
end

function AgendaManager:SetCurrLimitID(id, open)
    if DataAgenda.data_list[id] == nil then
        return
    end
    if open then
        self.currTimeLimitID = id
        if DataAgenda.data_list[id].max_try>0 and DataAgenda.data_list[id].engaged >= DataAgenda.data_list[id].max_try then
            self.currTimeLimitID = 0
        end
        self.currLimitList[id] = true
    else
        if self.currTimeLimitID == id then
            self.currTimeLimitID = 0
        end
        self.currLimitList[id] = nil
    end

    local show = self.currTimeLimitID ~= 0 and DataAgenda.data_list[self.currTimeLimitID].open_leve <= RoleManager.Instance.RoleData.lev and self.currTimeLimitID ~= 2013
    show = show or self.redpoint_state
    self.redpoint_state = show
    if MainUIManager.Instance.MainUIIconView ~= nil then
        if self.redpoint_state then
    end
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(14, self.redpoint_state or self.showtWeekRewardRedPoint)
    end
end

--
function AgendaManager:SetCurrLimitID_Public(open)
    if MainUIManager.Instance.MainUIIconView ~= nil then
        if open or (self.currTimeLimitID ~= 0 and DataAgenda.data_list[self.currTimeLimitID].open_leve <= RoleManager.Instance.RoleData.lev) and self.currTimeLimitID ~= 2013 then
            self.redpoint_state = true
            MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(14, self.redpoint_state or self.showtWeekRewardRedPoint)
        end
    end
end

function AgendaManager:SetWeekRewardRedPoint()
    self.showtWeekRewardRedPoint = false
    for k,v in pairs(self.model.week_rewards_info) do
        if v.flag == 0 and self.model.week_activity >= v.activity_need then
            self.showtWeekRewardRedPoint = true
        end
    end
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(14, self.redpoint_state or self.showtWeekRewardRedPoint)
    end
end

function AgendaManager:OpenWindow(tab)
    -- self.model.currentTab = tab
    self.model:OpenWindow(tab)
end

function AgendaManager:Require12000()
    Connection.Instance:send(12000,{})
end

function AgendaManager:Require12001()
    Connection.Instance:send(12001,{})
end

function AgendaManager:Require12002()
    Connection.Instance:send(12002,{})
end

function AgendaManager:Require12003()
    if CombatManager.Instance.isFighting and not CombatManager.Instance.isWatching and not CombatManager.Instance.isWatchRecorder  and self.frightingFreez == false then
        self.frightingFreez = true
        EventMgr.Instance:RemoveListener(event_name.server_end_fight, self.endfrightcallback)
        EventMgr.Instance:AddListener(event_name.server_end_fight, self.endfrightcallback)
        NoticeManager.Instance:FloatTipsByString(TI18N("当前处于战斗中，冻结将自动在战斗结束后生效，再次点击冻结可取消操作"))
        BuffPanelManager.Instance.model:UpdateFreezBtn()
        return
    elseif CombatManager.Instance.isFighting and self.frightingFreez then
        NoticeManager.Instance:FloatTipsByString(TI18N("已取消冻结操作"))
        self.frightingFreez = false
        EventMgr.Instance:RemoveListener(event_name.server_end_fight, self.endfrightcallback)
        BuffPanelManager.Instance.model:UpdateFreezBtn()
        return
    elseif CombatManager.Instance.isFighting == false and self.frightingFreez then
        self.frightingFreez = false
        EventMgr.Instance:RemoveListener(event_name.server_end_fight, self.endfrightcallback)
        BuffPanelManager.Instance.model:UpdateFreezBtn()
    end
    Connection.Instance:send(12003,{})
end

-- 获取活跃度信息
function AgendaManager:Require12004()
    Connection.Instance:send(12004,{})
end

-- 领取活跃度奖励
function AgendaManager:Require12005(id)
    Connection.Instance:send(12005,{item_id = id})
end

-- 获取今日活力值
function AgendaManager:Require12006()
    Connection.Instance:send(12006,{})
end

-- 打工
function AgendaManager:Require12007()
    Connection.Instance:send(12007,{})
end

--周活跃度信息
function AgendaManager:Require12010()
    --print("Require12010")
    Connection.Instance:send(12010,{})
end

--领取周活跃度奖励
function AgendaManager:Require12011(activity_id)
    Connection.Instance:send(12011, { activity_id = activity_id })
end

-- 日程次数信息
function AgendaManager:On12000(dat)
    if self.agenda_list ~= {} then
        self.agenda_list = {}
    end
    -- BaseUtils.dump(dat,"<color='#f000af'>On12000</color>")
    self.agenda_list = dat.list
    self.recommend_list = {}
    if dat.recommends ~= nil then
        for i,v in ipairs(dat.recommends) do
            self.recommend_list[v.rcd_id] = v.rcd_id
        end
    end
    self:UpdateTimes()
    self.refreshTime = BaseUtils.BASE_TIME
    EventMgr.Instance:Fire(event_name.agenda_update)
end

-- 查询双倍点数结果
function AgendaManager:On12001(dat)
    self.double_point = dat.double_point
    self.max_double_point = dat.max_double_point
    self.model:SetPoint()
    AutoFarmManager.Instance:setPoint(  )
    EventMgr.Instance:Fire(event_name.buff_update)
end

-- 领取点数结果
function AgendaManager:On12002(dat)
    NoticeManager.Instance:FloatTipsByString(TI18N(dat.msg))
    AutoFarmManager.Instance.model:SetPoint()
end

-- 冻结点数结果
function AgendaManager:On12003(dat)
    NoticeManager.Instance:FloatTipsByString(TI18N(dat.msg))
    AutoFarmManager.Instance.model:SetPoint()
end
-- 获取活跃度信息
function AgendaManager:On12004(dat)
    self.activitypoint = dat
    local iseffect = false
    for i,v in pairs(DataAgenda.data_reward) do
        local get = false
        for _k,_v in pairs(dat.rewarded) do
            if v.item_id == _v.item_id then
                get = true
            end
        end
        if not get and not iseffect then
            if dat.activity >= i then
                iseffect = true
            end
        end
    end
    -- ui_basefunctioiconarea.show_red_point(14, iseffect)
    if MainUIManager.Instance.MainUIIconView ~= nil and iseffect then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(14, iseffect)
    elseif MainUIManager.Instance.MainUIIconView ~= nil and not iseffect and self.currTimeLimitID == 0 then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(14, false)
    end
    self.model:SetReward(dat)

    -- if CampaignManager.Instance.campaignTree[CampaignEumn.Type.Valentine] ~= nil then
    --     ValentineManager.Instance:CheckRed()
    -- end
    OpenServerManager.Instance:CheckRed()

    EventMgr.Instance:Fire(event_name.active_point_update)
end

-- 领取活跃度奖励
function AgendaManager:On12005(dat)
    -- BaseUtils.dump(dat,"领取结果")
    NoticeManager.Instance:FloatTipsByString(TI18N(dat.msg))
end

-- 获取今日活力值
function AgendaManager:On12006(dat)
    NoticeManager.Instance:FloatTipsByString(TI18N(dat.msg))
     -- ui_skill_life_activity.update_current_huoli(dat.energy_added)
end

-- 打工
function AgendaManager:On12007(dat)
    NoticeManager.Instance:FloatTipsByString(TI18N(dat.msg))
end

--周活跃度信息
function AgendaManager:On12010(dat)
    --BaseUtils.dump(dat, "On12010")
    self.model.week_activity = dat.activity
    self.model.week_rewards_info = dat.rewards_info
    self.OnUpdateAgendaWeekData:Fire()
    self:SetWeekRewardRedPoint()
end

--领取周活跃度奖励
function AgendaManager:On12011(dat)
    NoticeManager.Instance:FloatTipsByString(dat.msg)
end

--=============================================================================================================
--====================分割线===================================================================================
--=============================================================================================================
function AgendaManager:GetDataById(id)
    for i,v in ipairs(self.agenda_list) do
        if id == v.id then
            return v
        end
    end
    return nil
end

function AgendaManager:GetDungeonStatus(ID)
    DungeonManager.Instance:Require12112(ID)
end

function AgendaManager:SetDungeonStatus(data)
    self.model:SetDungeonStatus(data)
end

-- 先请求AgendaManager:Require12004()
-- 更新活跃度信息
function AgendaManager:GetActivitypoint()
    return (self.activitypoint or {}).activity or 0
end

function AgendaManager:UpdateTimes()
    local unitStateMark = false
    for k,v in pairs(DataAgenda.data_list) do
        for _,_v in pairs(self.agenda_list) do
            if _v.id == v.id then
                DataAgenda.data_list[k].engaged = _v.engaged
            end
        end

        if k == 1007 or k == 2013 then
            unitStateMark = true
        end
    end
    self:LoadDailyList()
    self:LoadTimeLimit()
    self:LoadCommingSoon()
    self:LoadDungeonList()
    self:LoadChallangeList()
    self.model:UpdateTimes()

    -- 宝图任务 满了不显示追踪判断(已经废除)
    -- if RoleManager.Instance.RoleData.lev >= DataAgenda.data_list[1011].open_leve then
    --     MainUIManager.Instance:HideTreasuremap()
    -- end

    if unitStateMark then
        UnitStateManager.Instance:CheckShow()
        UnitStateManager.Instance:ShowIcon()
    end

    self:UpdateTrace()
end

function AgendaManager:LoadDailyList()
    local currentWeek = tonumber(os.date("%w", BaseUtils.BASE_TIME))
    local currentWeek5 = tonumber(os.date("%w", BaseUtils.BASE_TIME-5*3600))
    local currentHour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
    local currentMinute = tonumber(os.date("%M", BaseUtils.BASE_TIME))
    if currentWeek == 0 then currentWeek = 7 end
    if currentWeek5 == 0 then currentWeek5 = 7 end

    local temp = BaseUtils.copytab(DataAgenda.data_list)
    if RoleManager.Instance.world_lev < 60 then
        temp[2010].args = {1,3}
        temp[2019] = nil
    end
    --BaseUtils.dump(temp,"temp>>>>>>")
    -- 客户端特殊处理隐藏一些日程
    local selfnoguild = GuildManager.Instance.model.my_guild_data == nil or GuildManager.Instance.model.my_guild_data.GuildId == 0
    self.day_list = {}
    for i,v in pairs(temp) do
        if v.open_leve <= RoleManager.Instance.RoleData.lev
            and (v.max_leve == 0 or v.max_leve >= RoleManager.Instance.RoleData.lev)
            -- and v.time == TI18N("全天")
            and v.type ~= 4
            and v.id < 3000
            and not (v.is_guild == 1 and selfnoguild)
            -- and (v.open_timestamp[1] == nil or (BaseUtils.BASE_TIME>v.open_timestamp[1][1] and BaseUtils.BASE_TIME<v.open_timestamp[1][2]) )
            then

            local isOpen = false
            if #v.open_timestamp > 0 then
                for _,stemps in ipairs(v.open_timestamp) do
                    if stemps[1] < BaseUtils.BASE_TIME and BaseUtils.BASE_TIME <= stemps[2] then
                        isOpen = true
                        break
                    end
                end
            else
                isOpen = true
            end
            if isOpen then
                v.item = nil
                if next(v.args) == nil then
                    table.insert( self.day_list, v )
                else
                    for i,vv in ipairs(v.args) do
                        if (v.reset_time == 1 and currentWeek == vv) or (v.reset_time == 2 and currentWeek5 == vv) then
                            table.insert( self.day_list, v )
                        end
                    end
                end
            end
        end
    end
    --BaseUtils.dump(self.day_list,"self.day_list------------")
    local sortfunc = function(a,b)
        local af = (a.engaged ~= nil and a.engaged >= a.max_try and a.max_try ~= 0) or (a.time ~= TI18N("全天") and a.endtime/3600 < currentHour+currentMinute/60)
        local bf = (b.engaged ~= nil and b.engaged >= b.max_try and b.max_try ~= 0) or (b.time ~= TI18N("全天") and b.endtime/3600 < currentHour+currentMinute/60)
        local ar = (self.recommend_list[a.id] ~= nil)
        local br = (self.recommend_list[b.id] ~= nil)
        local result1
        if af and not bf then
            result1 = false
        elseif not af and bf then
            result1 = true
        elseif ar and not br then
            result1 = true
        elseif not ar and br then
            result1 = false
        else
            result1 = (a.rank < b.rank)
        end
        local result = (result1 == true)
        return result
    end
    table.sort( self.day_list, sortfunc )
    local limit1 = nil
    local limit1index = nil
    local limit2 = nil
    local limit2index = nil
    for k,v in pairs(self.day_list) do
        -- and (limit1 == nil or limit2 == nil)
        if v.id ~= 1030 and v.id ~= 2013 and v.id ~= 2101 and v.id ~= 2102 and v.id ~= 99 and v.time ~= TI18N("全天")  then
            if ((v.engaged ~= nil and v.engaged < v.max_try and v.max_try ~= 0) or (v.engaged ~= nil and v.engaged*v.activity < v.max_activity and v.max_activity ~= 0))
                and (self.currLimitList[v.id] or (v.starttime/3600 > currentHour+currentMinute/60 or v.endtime/3600 > currentHour+currentMinute/60)) then
                if limit1 == nil then
                    limit1 = v
                    limit1index = k
                elseif limit2 == nil then
                    limit2 = v
                    limit2index = k
                else
                    if v.starttime < limit1.starttime then
                        limit1 = limit2
                        limit1index = limit2index
                        limit2 = v
                        limit2index = k
                        -- 要保证table的顺序，limit1的数据必须是Limite2前面的
                    elseif v.starttime < limit2.starttime then
                        limit2 = v
                        limit2index = k
                    end
                end
            end
        end
    end
    if limit2index ~= nil then
        table.remove(self.day_list, limit2index)
    end
    if limit1index ~= nil then
        table.remove(self.day_list, limit1index)
    end
    if limit1index ~= nil then
        table.insert(self.day_list, 3, limit1)
    end
    if limit2index ~= nil then
        table.insert(self.day_list, 4, limit2)
    end
    --BaseUtils.dump(self.day_list,"self.day_list")
end

function AgendaManager:LoadTimeLimit()
    --print("<color='#FFFF00'>aaaaaaaa:  </color>"..tostring(self.currTimeLimitID))

    local currentWeek = tonumber(os.date("%w", BaseUtils.BASE_TIME))
    local currentWeek5 = tonumber(os.date("%w", BaseUtils.BASE_TIME-5*3600))
    local currentHour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
    local currentMinute = tonumber(os.date("%M", BaseUtils.BASE_TIME))
    if currentWeek == 0 then currentWeek = 7 end
    if currentWeek5 == 0 then currentWeek5 = 7 end

    -- local currentWeek = 7
    -- local currentWeek5 = 7
    -- local currentHour = 10
    -- local currentMinute = 10
    -- if currentWeek == 0 then currentWeek = 7 end
    -- if currentWeek5 == 0 then currentWeek5 = 7 end
    self.day_limited_list = {}
    local temp = BaseUtils.copytab(DataAgenda.data_list)
    if RoleManager.Instance.world_lev < 60 then
        temp[2010].args = {1,3}
        temp[2019] = nil
    end

    if temp[2028] ~= nil then
        -- 武道会中午场结束了显示晚上场
        if temp[2028].endtime/3600 < currentHour+currentMinute/60 then
            temp[2028].starttime = 81000
            temp[2028].endtime = 84600
        end
    end
    if temp[2049] ~= nil then
        -- 武道会2V2中午场结束了显示晚上场
        if temp[2049].endtime/3600 < currentHour+currentMinute/60 then
            temp[2049].starttime = 81000
            temp[2049].endtime = 84600
        end
    end
    -- --设置2072 全天开启
    -- if temp[2072] ~= nil then
    --     self:SetCurrLimitID(2072, true)
    -- end
    -- --设置2082 全天开启
    -- if temp[2082] ~= nil then
    --     self:SetCurrLimitID(2082, true)
    -- end

    for i,v in pairs(temp) do
        if v.open_leve <= RoleManager.Instance.RoleData.lev                             -- 开放等级
            and (v.max_leve == 0 or v.max_leve >= RoleManager.Instance.RoleData.lev)    -- 最大等级
            and (v.time ~= TI18N("全天") or v.id == 1025 or v.id == 2044 ) and v.type ~= 4
            and v.id < 3000
            -- and (v.open_timestamp[1] == nil or (BaseUtils.BASE_TIME>v.open_timestamp[1][1] and BaseUtils.BASE_TIME<v.open_timestamp[1][2]))     -- 开放时间
            then

            local isOpen = false
            if #v.open_timestamp > 0 then
                for _,stemps in ipairs(v.open_timestamp) do
                    if stemps[1] < BaseUtils.BASE_TIME and BaseUtils.BASE_TIME <= stemps[2] then
                        isOpen = true
                        break
                    end
                end
            else
                isOpen = true
            end
            if isOpen then
                v.item = nil
                if next(v.args) == nil then
                    table.insert( self.day_limited_list, v )
                    if v.id == self.currTimeLimitID then
                        if v.max_try>0 and v.engaged == v.max_try then
                            self:SetCurrLimitID(v.id, false)
                        end
                    end
                else
                    for i,vv in ipairs(v.args) do
                        if (v.reset_time == 1 and currentWeek == vv) or (v.reset_time == 2 and currentWeek5 == vv) then
                            table.insert( self.day_limited_list, v )
                            if v.id == self.currTimeLimitID then
                                if v.max_try>0 and v.engaged == v.max_try then
                                    self:SetCurrLimitID(v.id, false)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    --BaseUtils.dump(self.day_limited_list,"self.day_limited_list")
    -- table.sort( self.day_limited_list, function (a,b)  return a.open_leve<b.open_leve   end )
    local sortfunc = function(a,b)
        local af = (a.engaged ~= nil and a.engaged >= a.max_try and a.max_try ~= 0)
        local bf = (b.engaged ~= nil and b.engaged >= b.max_try and b.max_try ~= 0)
        local ar = (self.recommend_list[a.id] ~= nil)
        local br = (self.recommend_list[b.id] ~= nil)
        local result1
        if a.id == 99 and b.id ~= 99 then
            return false
        end
        if af and not bf then
            result1 = false
        elseif not af and bf then
            result1 = true
        elseif ar and not br then
            result1 = true
        elseif not ar and br then
            result1 = false
        else
            result1 = (a.rank < b.rank)
        end
        local result = (result1 == true)
        return result
    end
    table.sort( self.day_limited_list, sortfunc )

    local limit1 = nil
    local limit1index = nil
    local limit2 = nil
    local limit2index = nil
    for k,v in pairs(self.day_list) do
        -- and (limit1 == nil or limit2 == nil)
        local idList = {1030,2013,2101,2102,99,2028,2049}
        if v.id ~= idList[1] and v.id ~= idList[2] and v.id ~= idList[3] and v.id ~= idList[4] and v.id ~= idList[5] and v.id ~= idList[6] and v.id ~= idList[7] and v.time ~= TI18N("全天")  then
            if ((v.engaged ~= nil and v.engaged < v.max_try and v.max_try ~= 0) or (v.engaged ~= nil and v.engaged*v.activity < v.max_activity and v.max_activity ~= 0))
                and (self.currLimitList[v.id] or (v.starttime/3600 > currentHour+currentMinute/60 or v.endtime/3600 > currentHour+currentMinute/60)) then
                if limit1 == nil then
                    limit1 = v
                    limit1index = k
                elseif limit2 == nil then
                    limit2 = v
                    limit2index = k
                else
                    if v.starttime < limit1.starttime then
                        limit1 = limit2
                        limit1index = limit2index
                        limit2 = v
                        limit2index = k
                        -- 要保证table的顺序，limit1的数据必须是Limite2前面的
                    elseif v.starttime < limit2.starttime then
                        limit2 = v
                        limit2index = k
                    end
                end
            end
        end
    end
    if limit2index ~= nil then
        table.remove(self.day_list, limit2index)
    end
    if limit1index ~= nil then
        table.remove(self.day_list, limit1index)
    end
    if limit1index ~= nil then
        table.insert(self.day_list, 3, limit1)
    end
    if limit2index ~= nil then
        table.insert(self.day_list, 4, limit2)
    end

    --BaseUtils.dump(self.day_limited_list,"self.day_limited_list--------")
end

function AgendaManager:LoadDungeonList()
    local currentWeek = tonumber(os.date("%w", BaseUtils.BASE_TIME))
    local currentWeek5 = tonumber(os.date("%w", BaseUtils.BASE_TIME-5*3600))
    local currentHour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
    if currentWeek == 0 then currentWeek = 7 end
    if currentWeek5 == 0 then currentWeek5 = 7 end
    self.dungeon_list = {}
    local temp = {}  -- 组装一个有序的列表
    for k,v in pairs(DataAgenda.data_list) do
        if v.type == 2 then
            local baseDunData = DataDungeon.data_get[v.panel_id]
            if baseDunData.type == 2 then
                if next(v.args) == nil then
                    table.insert( temp, v )
                else
                    for i,vv in ipairs(v.args) do
                        if (v.reset_time == 1 and currentWeek == vv) or (v.reset_time == 2 and currentWeek5 == vv) then
                            table.insert( temp, v )
                        end
                    end
                end
            end
        end
    end
    local bestChallenge = nil
    for k,v in pairs(DataAgenda.data_list) do
        if v.type == 2 then
            local baseDunData = DataDungeon.data_get[v.panel_id]
            if baseDunData.type == 3 and v.open_leve <= RoleManager.Instance.RoleData.lev then
                if bestChallenge == nil or bestChallenge.open_leve<v.open_leve then
                    bestChallenge = v
                end
            end
        end
    end
    if bestChallenge ~= nil then
        table.insert( temp, bestChallenge )
    end
    table.sort(temp, function (a,b)  return a.rank<b.rank   end)
    local last = false
    self.dungeon_list = temp
end

function AgendaManager:LoadCommingSoon()
    self.commingsoon_list = {}
    for k,v in pairs(DataAgenda.data_list) do
        if v.open_leve > RoleManager.Instance.RoleData.lev
            and v.id < 3000 and v.id ~= 1022 and v.id ~= 1028
            -- and (v.open_timestamp[1] == nil or (BaseUtils.BASE_TIME>v.open_timestamp[1][1] and BaseUtils.BASE_TIME<v.open_timestamp[1][2]))
            then
            local isOpen = false
            if #v.open_timestamp > 0 then
                for _,stemps in ipairs(v.open_timestamp) do
                    if stemps[1] < BaseUtils.BASE_TIME and BaseUtils.BASE_TIME <= stemps[2] then
                        isOpen = true
                        break
                    end
                end
            else
                isOpen = true
            end
            if isOpen then
                v.item = nil
                table.insert( self.commingsoon_list, v )
            end
        end
    end
    -- table.sort( self.commingsoon_list, function (a,b)  return a.open_leve<b.open_leve   end )
    table.sort( self.commingsoon_list, function (a,b)  return a.rank<b.rank   end )
    --BaseUtils.dump(self.commingsoon_list,"self.commingsoon_list")
end

function AgendaManager:LoadChallangeList()

    local currentWeek = tonumber(os.date("%w", BaseUtils.BASE_TIME))
    local currentWeek5 = tonumber(os.date("%w", BaseUtils.BASE_TIME-5*3600))
    local currentHour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
    local currentMinute = tonumber(os.date("%M", BaseUtils.BASE_TIME))
    if currentWeek == 0 then currentWeek = 7 end
    if currentWeek5 == 0 then currentWeek5 = 7 end
    self.challange_list = {}
    local idsList = {1007, 1024, 2072, 2082, 2057, 2058, 2059, 2060, 2073, 2074, 2075, 2076, 2013}
    local temp = {}
    --BaseUtils.dump(self.day_list,"1212")
    for k, v in pairs(idsList) do
        if BaseUtils.ContainKeyTable(DataAgenda.data_list,v) then
            table.insert(temp,DataAgenda.data_list[v])
        end
    end
    --self.challange_list = temp
    --BaseUtils.dump(self.challange_list,"1212")

    for i,v in pairs(temp) do
        if v.open_leve <= RoleManager.Instance.RoleData.lev
            and (v.max_leve == 0 or v.max_leve >= RoleManager.Instance.RoleData.lev) and v.type ~= 4 and v.id < 3000 then
            local isOpen = false
            if #v.open_timestamp > 0 then
                for _,stemps in ipairs(v.open_timestamp) do
                    if stemps[1] < BaseUtils.BASE_TIME and BaseUtils.BASE_TIME <= stemps[2] then
                        isOpen = true
                        break
                    end
                end
            else
                isOpen = true
            end
            if isOpen then
                v.item = nil
                if next(v.args) == nil then
                    if (v.id ~= 2072 and v.id ~= 2082) or (v.id == 2072 and RoleManager.Instance.world_lev >= 60) or (v.id == 2082 and RoleManager.Instance.world_lev >= 80) then
                        table.insert(self.challange_list, v)
                    end
                else
                    for i,vv in ipairs(v.args) do
                        if(v.reset_time == 1 and currentWeek == vv) or (v.reset_time == 2 and currentWeek5 == vv) then
                            if (v.id ~= 2072 and v.id ~= 2082) or (v.id == 2072 and RoleManager.Instance.world_lev >= 60) or (v.id == 2082 and RoleManager.Instance.world_lev >= 80) then
                                table.insert(self.challange_list, v)
                            end
                        end
                    end
                end
            end

        end
    end

    -- ljh 调顺序的代码，不知道是为啥要这么调，跟策划确认过没有此需求，屏蔽
    -- local limit1 = nil
    -- local limit1index = nil
    -- local limit2 = nil
    -- local limit2index = nil
    -- for k,v in pairs(self.challange_list) do
    --     -- and (limit1 == nil or limit2 == nil)
    --     local idList = {1030,2013,2101,2102,99}
    --     if v.id ~= idList[1] and v.id ~= idList[2] and v.id ~= idList[3] and v.id ~= idList[4] and v.id ~= idList[5] and v.time ~= TI18N("全天")  then
    --         if ((v.engaged ~= nil and v.engaged < v.max_try and v.max_try ~= 0) or (v.engaged ~= nil and v.engaged*v.activity < v.max_activity and v.max_activity ~= 0))
    --             and (self.currLimitList[v.id] or (v.starttime/3600 > currentHour+currentMinute/60 or v.endtime/3600 > currentHour+currentMinute/60)) then
    --             if limit1 == nil then
    --                 limit1 = v
    --                 limit1index = k
    --             elseif limit2 == nil then
    --                 limit2 = v
    --                 limit2index = k
    --             else
    --                 if v.starttime < limit1.starttime then
    --                     limit1 = limit2
    --                     limit1index = limit2index
    --                     limit2 = v
    --                     limit2index = k
    --                     -- 要保证table的顺序，limit1的数据必须是Limite2前面的
    --                 elseif v.starttime < limit2.starttime then
    --                     limit2 = v
    --                     limit2index = k
    --                 end
    --             end
    --         end
    --     end
    -- end
    -- if limit2index ~= nil then
    --     table.remove(self.challange_list, limit2index)
    -- end
    -- if limit1index ~= nil then
    --     table.remove(self.challange_list, limit1index)
    -- end
    -- if limit1index ~= nil then
    --     table.insert(self.challange_list, 3, limit1)
    -- end
    -- if limit2index ~= nil then
    --     table.insert(self.challange_list, 4, limit2)
    -- end


end

function AgendaManager:SortList()
    -- if self.controller.currindex == 1 then
    --     for i,v in pairs(self.day_list) do
    --         if not utils.is_null(v.item) and v.engaged == v.max_try and v.max_try ~= 0 then
    --             v.item.transform:SetAsLastSibling()
    --         end
    --     end
    -- elseif self.controller.currindex == 3 then
    --     for i,v in pairs(self.day_limited_list) do
    --         if not utils.is_null(v.item) and ((v.engaged == v.max_try and v.max_try ~= 0 )or v.item.transform:Find("TimeLimit").gameObject.activeSelf == true) then
    --             v.item.transform:SetAsLastSibling()
    --         end
    --     end
    -- elseif self.controller.currindex == 4 then
    --     for i,v in pairs(self.commingsoon_list) do
    --         if not utils.is_null(v.item) and v.engaged == v.max_try and v.max_try ~= 0 then
    --             v.item.transform:SetAsLastSibling()
    --         end
    --     end
    -- end
end

function AgendaManager:WelfareData()
    if self.welfareList == nil then
        self.welfareList = {}
        self.currentGiftLev = self:CheckWelfare()
        for i,v in pairs(DataAgenda.data_lev_gift) do
            if v.classes == RoleManager.Instance.RoleData.classes then
                table.insert(self.welfareList, v)
            end
        end
        table.sort(self.welfareList, function(a, b) return a.base_id < b.base_id end)
    end
    return self.welfareList
end

--检查礼包可领
function AgendaManager:CheckWelfare()
    AgendaManager.Instance.levHasGift = false
    -- EventMgr.Instance:RemoveListener(event_name.mainui_loaded, self.listener)
    self.currentGiftLev = self:GetCurrGiftLev()
    if self.currentGiftLev ~= 0 then
        for i,v in ipairs(AgendaManager.Instance:WelfareData()) do
            if RoleManager.Instance.RoleData.lev >= self.currentGiftLev then
                -- ui_basefunctioiconarea.show_effect(22, true)
                AgendaManager.Instance.levHasGift = true
                return self.currentGiftLev
            end
        end
    end

    -- mod_checkin.check_for_welfera()
    return self.currentGiftLev
end

function AgendaManager:GetCurrGiftLev()
    for i,v in ipairs(AgendaManager.Instance:WelfareData()) do
        local bag_count = BackpackManager.Instance:GetItemCount(v.base_id)
        local gift_base = data_item.data_get[v.base_id]
        if bag_count > 0 then
            return gift_base.lev
        end
    end
    return 0
end

-- 更新任务追踪
function AgendaManager:UpdateTrace()
    if MainUIManager.Instance.mainuitracepanel == nil then
        return
    end

    if MainUIManager.Instance.mainuitracepanel.traceQuest == nil or not MainUIManager.Instance.mainuitracepanel.traceQuest.isInit then
        return
    end

    -- 上古
    -- 5次以下显示，以上删除
    local data = DataAgenda.data_list[1014]
    if RoleManager.Instance.RoleData.lev >= 35 and data.engaged < 5 then
        if self.quest_track == nil then
            self.quest_track, self.quest_item = MainUIManager.Instance.mainuitracepanel.traceQuest:AddCustom()
            self.quest_track.callback = function () self.model:SpecialDaily(1014) end
            self.quest_track.type = CustomTraceEunm.Type.Monster
        end
        self.quest_track.title = string.format(TI18N("[上古]上古妖魔<color='#ff0000'>(%s/5)</color>"), data.engaged)
        self.quest_track.Desc = TI18N("击败<color='#00ff12'>上古妖魔</color>")
        MainUIManager.Instance.mainuitracepanel.traceQuest:UpdateCustom(self.quest_track)
    else
        self:DeleteCustom()
    end
end

function AgendaManager:DeleteCustom()
    if self.quest_track ~= nil then
        MainUIManager.Instance.mainuitracepanel.traceQuest:DeleteCustom(self.quest_track.customId)
        self.quest_track = nil
        self.quest_item = nil
    end
end

-- function AgendaManager:CreateChallangeIcon_level()
--     if RoleManager.Instance.RoleData.lev >= 40 then
--         MainUIManager.Instance:DelAtiveIcon(387)
--         if self.activeIconData ~= nil then
--             self.activeIconData:DeleteMe()
--             self.activeIconData = nil
--         end

--         local systemIconId = 387  --挑战活动
--         self.activeIconData = AtiveIconData.New()
--         local iconData = DataSystem.data_daily_icon[systemIconId]
--         self.activeIconData.id = iconData.id
--         self.activeIconData.iconPath = iconData.res_name
--         self.activeIconData.sort = iconData.sort
--         self.activeIconData.lev = iconData.lev
--         if RoleManager.Instance.RoleData.lev == 40 then
--             self.activeIconData.effectId = 20256
--             self.activeIconData.effectPos = Vector3(0, 32, -400)
--             self.activeIconData.effectScale = Vector3(1, 1, 1)
--         end
--         self.activeIconData.clickCallBack = function()
--             MainUIManager.Instance:OpenChallengePanel()
--             if self.iconObject.transform:Find("Effect") ~= nil then
--                 self.iconObject.transform:Find("Effect").gameObject:SetActive(false)
--             end
--         end

--         self.iconObject = MainUIManager.Instance:AddAtiveIcon(self.activeIconData)

--     end
-- end

-- function AgendaManager:CreateChallangeIcon_login()
--     if RoleManager.Instance.RoleData.lev >= 40 then
--         MainUIManager.Instance:DelAtiveIcon(387)
--         if self.activeIconData ~= nil then
--             self.activeIconData:DeleteMe()
--             self.activeIconData = nil
--         end

--         local systemIconId = 387  --挑战活动
--         self.activeIconData = AtiveIconData.New()
--         local iconData = DataSystem.data_daily_icon[systemIconId]
--         self.activeIconData.id = iconData.id
--         self.activeIconData.iconPath = iconData.res_name
--         self.activeIconData.sort = iconData.sort
--         self.activeIconData.lev = iconData.lev
--         self.activeIconData.clickCallBack = function()
--             MainUIManager.Instance:OpenChallengePanel()
--         end
--         MainUIManager.Instance:AddAtiveIcon(self.activeIconData)

--     end
-- end