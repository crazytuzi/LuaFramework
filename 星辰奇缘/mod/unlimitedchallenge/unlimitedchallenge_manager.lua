-- 无尽挑战 manager
-- hzf
-- 8/29

UnlimitedChallengeManager  = UnlimitedChallengeManager or BaseClass(BaseManager)

function UnlimitedChallengeManager:__init()
    if UnlimitedChallengeManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    UnlimitedChallengeManager.Instance = self
    self.model = UnlimitedChallengeModel.New()
    self.mateData = {}
    self.combatReward = {}
    self.rankData = {}
    self.lastWave = 0
    self.currWave = 1

    self.best_wave = 0
    self.fight_times = 0
    self:InitHandler()
    self.skillData = {skill_list = {}, choose_skills = {}}
    -- EventMgr.Instance:RemoveListener(event_name.role_event_change, self.roleEventChange)
    self.UnlimitedChallengeUpdate = EventLib.New()  -- 单条动态更新
    self.UnlimitedChallengeRankUpdate = EventLib.New()  -- 单条动态更新
    self.UnlimitedChallengeFightTimesUpdate = EventLib.New()  -- 单条动态更新
    EventMgr.Instance:AddListener(event_name.role_event_change, function(event,oldEvent)
        self:CheckEvent(event,oldEvent)
    end)
    EventMgr.Instance:AddListener(event_name.end_fight, function()
        self.currWave = 1
    end)
end

function UnlimitedChallengeManager:InitHandler()
    self:AddNetHandler(17200, self.On17200)
    self:AddNetHandler(17201, self.On17201)
    self:AddNetHandler(17202, self.On17202)
    self:AddNetHandler(17203, self.On17203)
    self:AddNetHandler(17204, self.On17204)
    self:AddNetHandler(17205, self.On17205)
    self:AddNetHandler(17206, self.On17206)
    self:AddNetHandler(17207, self.On17207)
    self:AddNetHandler(17208, self.On17208)
    self:AddNetHandler(17209, self.On17209)
    self:AddNetHandler(17210, self.On17210)
    self:AddNetHandler(17211, self.On17211)
    self:AddNetHandler(17212, self.On17212)
    self:AddNetHandler(17213, self.On17213)
    self:AddNetHandler(17214, self.On17214)
    self:AddNetHandler(17215, self.On17215)
    self:AddNetHandler(17216, self.On17216)
end

function UnlimitedChallengeManager:ReqOnConnect()
    self:Require17200()
    self:Require17206()
    self:Require17210()
    self:Require17212()
end

function UnlimitedChallengeManager:Require17200()
    Connection.Instance:send(17200,{})
end


function UnlimitedChallengeManager:On17200(data)
    print("on17200")
    -- BaseUtils.dump(data)
    self.mateData = data.mates
    if #self.mateData <= 2 then
        self.model:CloseMainPanel()
    else
        LuaTimer.Add(500, function()
            self.model:UpdateMember()
        end)
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function UnlimitedChallengeManager:Require17201()
    Connection.Instance:send(17201,{})
end

function UnlimitedChallengeManager:On17201(data)
    print("on17201")
    BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function UnlimitedChallengeManager:Require17202()
    Connection.Instance:send(17202,{})
end

function UnlimitedChallengeManager:On17202(data)
    print("on17202")
    BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function UnlimitedChallengeManager:Require17203(index, skill_id)
    Connection.Instance:send(17203,{index = index, skill_id = skill_id})
end

function UnlimitedChallengeManager:On17203(data)
    print("on17203")
    BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function UnlimitedChallengeManager:Require17204(flag)
    Connection.Instance:send(17204,{flag = flag})
end

function UnlimitedChallengeManager:On17204(data)
    -- print("on17204")
    -- BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function UnlimitedChallengeManager:Require17205()
    Connection.Instance:send(17205,{})
end

function UnlimitedChallengeManager:On17205(data)
    print("on17205")
    -- BaseUtils.dump(data)
    self.lastWave = self.currWave
    self.currWave = data.wave
    if self.lastWave > self.currWave then
        self.lastWave = self.currWave
    end
    self.roundReward = data.reward_info
    -- self.model:OpenFrightInfoPanel()
end

function UnlimitedChallengeManager:Require17206()
    Connection.Instance:send(17206,{})
end

function UnlimitedChallengeManager:On17206(data)
    --print("on17206")
    -- BaseUtils.dump(data)
    self.rankData = data.rank_list
    self.UnlimitedChallengeRankUpdate:Fire()
end

function UnlimitedChallengeManager:Require17207(skill_id)
    Connection.Instance:send(17207,{skill_id = skill_id})
end

function UnlimitedChallengeManager:On17207(data)
    print("on17207")
    -- BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function UnlimitedChallengeManager:Require17208()
    Connection.Instance:send(17208,{})
end

function UnlimitedChallengeManager:On17208(data)
    -- print("on17208")
    -- BaseUtils.dump(data)
    for i,v in ipairs(self.mateData) do
        if data.rid == v.rid and data.platform == v.platform and data.zone_id == v.zone_id then
            for k,vv in pairs(data) do
                self.mateData[i][k] = vv
            end
        end
    end
    self.model:UpdateMember()
end

function UnlimitedChallengeManager:Require17209()
    Connection.Instance:send(17209,{})
end

function UnlimitedChallengeManager:On17209(data)
    print("on17209")
    -- BaseUtils.dump(data)
    local reward = {}
    for k,v in pairs(data.gl_list) do
        table.insert(reward, {id = v.base_id, num = v.val})
    end
    FinishCountManager.Instance.model.reward_win_data = {
        titleTop = TI18N("无尽挑战")
        , val = valdes
        , val1 = ""
        , val2 = data.msg
        , title = TI18N("挑战结算")
        , confirm_str = "确定"
        , share_str = TI18N("查看排行榜")
        , reward_list = reward
        , noreward_text = TI18N("当前波次奖励今日已领取\n努力突破今日纪录或明日再战吧！")
        , share_callback = function()
            self.model:OpenRankPanel()
        end
    }
    FinishCountManager.Instance.model:InitRewardWin_Common()
end


function UnlimitedChallengeManager:Require17210()
    Connection.Instance:send(17210,{})
end

function UnlimitedChallengeManager:On17210(data)
    print("on17210")
    -- BaseUtils.dump(data)
    self.combatReward = data.reward_info
    self.model:OpenFrightInfoPanel()
end

function UnlimitedChallengeManager:Require17211()
    Connection.Instance:send(17211,{})
end

function UnlimitedChallengeManager:On17211(data)
    print("on17211")
    BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function UnlimitedChallengeManager:Require17212()
    Connection.Instance:send(17212,{})
end

function UnlimitedChallengeManager:On17212(data)
    -- print("on17212$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
    -- BaseUtils.dump(data)
    self.skillData = data
    self.UnlimitedChallengeUpdate:Fire()
end


-- function UnlimitedChallengeManager:Require17213()
--     Connection.Instance:send(17213,{})
-- end

function UnlimitedChallengeManager:On17213(data)
    print("on1翻牌数据")
    BaseUtils.dump(data)
    self.best_wave = data.best_wave
    self.model:OpenCardWindow(data)
end


function UnlimitedChallengeManager:Require17214(index)
    Connection.Instance:send(17214,{index = index})
end

function UnlimitedChallengeManager:On17214(data)
    print("On17214$")
    BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    -- self.skillData = data
    -- self.UnlimitedChallengeUpdate:Fire()
end



function UnlimitedChallengeManager:Require17215()
    Connection.Instance:send(17215,{})
end

function UnlimitedChallengeManager:On17215(data)
    print("On17215$")
    BaseUtils.dump(data)
    self.fight_times = data.fight_times
    self.best_wave = data.best_wave
    self.UnlimitedChallengeFightTimesUpdate:Fire()
end


function UnlimitedChallengeManager:Require17216()
    Connection.Instance:send(17216,{})
end

function UnlimitedChallengeManager:On17216(data)
    print("On17216$")
    BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-----------------------
function UnlimitedChallengeManager:AutoMatch()
    TeamManager.Instance.TypeOptions = {}
    TeamManager.Instance.TypeOptions[4] = 48
    TeamManager.Instance.LevelOption = 1
    -- TeamManager.Instance:Send11701()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {1})
    -- LuaTimer.Add(500, function() TeamManager.Instance:AutoFind() end)
end

function UnlimitedChallengeManager:CheckEvent(event,oldEvent)
    if event == 29 and #self.mateData > 0 then
        LuaTimer.Add(1000, function()
            self.model:OpenMainPanel()
        end)
    elseif event ~= 29 then
        self.model:CloseMainPanel()
    end
end

function UnlimitedChallengeManager:CheckReady()
    if TeamManager.Instance:IsSelfCaptin() and TeamManager.Instance:HasTeam() and TeamManager.Instance:MemberCount() >= 3 then
        local list = TeamManager.Instance:GetMemberByTeamStatus(RoleEumn.TeamStatus.Away)
        local list2 = TeamManager.Instance:GetMemberByTeamStatus(RoleEumn.TeamStatus.Offline)
        if #list2 > 0 or #list > 0 then
            -- for k,v in pairs(list) do
            --     NoticeManager.Instance:FloatTipsByString(TI18N("队员%s处于暂离状态"))
            -- end
            -- for k,v in pairs(list2) do
            --     NoticeManager.Instance:FloatTipsByString(string.format(TI18N("队员%s处于离线状态")))
            -- end
            NoticeManager.Instance:FloatTipsByString(TI18N("还有人未准备好"))

            return
        end
        if TeamManager.Instance:MemberCount() < 5 then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("队伍成员未满，开始准备后将<color='#ffff00'>停止招募</color>")
            data.sureLabel = TI18N("开始准备")
            data.cancelLabel = TI18N("招募队员")
            data.sureCallback = function()
                TeamManager.Instance:Send11720()
                self:Require17211()
            end
            data.cancelCallback = function()
                self:AutoMatch()
            end
            NoticeManager.Instance:ConfirmTips(data)
        else
            self:Require17211()
        end
    else
        -- NoticeManager.Instance:FloatTipsByString("无尽挑战需要最少3人组队参加")
        if TeamManager.Instance:HasTeam() and TeamManager.Instance:IsSelfCaptin() then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("无尽挑战需要最少3名玩家组队参加")
            data.sureLabel = TI18N("招募队员")
            data.sureCallback = function()
                self:AutoMatch()
            end
            NoticeManager.Instance:ConfirmTips(data)
        else
            if TeamManager.Instance:HasTeam() then
                NoticeManager.Instance:FloatTipsByString(TI18N("只有队长能操作"))
            else
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = TI18N("无尽挑战需要最少3名玩家组队参加")
                data.sureLabel = TI18N("开始匹配")
                data.sureCallback = function()
                    self:AutoMatch()
                end
                NoticeManager.Instance:ConfirmTips(data)
            end
        end
    end
end

function UnlimitedChallengeManager:IsLearned(skillid)
    for k,v in pairs(self.skillData.skill_list) do
        if v.skill_id == skillid then
            return true
        end
    end
    return false
end

function UnlimitedChallengeManager:Isused(skillid)
    for k,v in pairs(self.skillData.choose_skills) do
        if v.skill_id == skillid then
            return true, v.idnex
        end
    end
    return false
end