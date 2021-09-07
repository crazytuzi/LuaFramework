ApocalypseLordModel = ApocalypseLordModel or BaseClass(BaseModel)

function ApocalypseLordModel:__init()
    self:InitData()

    self.window = nil
    self.fightPanel = nil
    self.fightRewardPanel = nil
    self.towerendwin = nil
    self.ApocalypseLordSettlementWindow = nil
    self.ApocalypseLordTeamPanel = nil

    self.helpWin = nil -- by 嘉俊 2017/8/29
end

function ApocalypseLordModel:InitData()
    self.status = 1
    self.group = 0
    self.is_offer = false
    self.max_wave = 0
    self.spirit_treasure_unit = {
        [1] = {base_id = 32004, difficulty = 1, kill_times = 0, offer_teams = {}, now_star = 1, diff_num = 0 },
        [2] = {base_id = 32000, difficulty = 1, kill_times = 0, offer_teams = {}, now_star = 1, diff_num = 0 },
        [3] = {base_id = 32001, difficulty = 1, kill_times = 0, offer_teams = {}, now_star = 1, diff_num = 0 },
        [4] = {base_id = 32002, difficulty = 1, kill_times = 0, offer_teams = {}, now_star = 1, diff_num = 0 },
        [5] = {base_id = 32003, difficulty = 1, kill_times = 0, offer_teams = {}, now_star = 1, diff_num = 0 },
    }
    self.myRank = 0
    self.myRankFormUnitConfigData = nil
    self.wave = 0
    self.reward_info = {}
    self.rank_list = {}

    self.wave_list = {}
    self.qualificationNum = 0

    self.helpGet = 0 -- 是否获取了帮助奖励 by 嘉俊 2017/8/29
end

function ApocalypseLordModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function ApocalypseLordModel:OpenWindow(args)
    if self.window == nil then
        self.window = ApocalypseLordWindow.New(self)
    end
    self.window:Open(args)
end

function ApocalypseLordModel:CloseWindow()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function ApocalypseLordModel:OpenTowerEnd(args)
    if self.towerendwin == nil then
        self.towerendwin = ApocalypseLordTowerEndWindow.New(self)
    else
        self:CloseTower()
        self.towerendwin = ApocalypseLordTowerEndWindow.New(self)
    end
    self.towerendwin:Open(args)
end

function ApocalypseLordModel:OpenBox(data)
    if self.towerendwin ~= nil then
        self.towerendwin:OpenBox(data.order, data.gain_list[1])
        -- local callback =  function()
        --     local lastorder = 0
        --     for k,v in pairs(data.show_list) do
        --         local ok = false
        --         for i = 1, 3 do
        --             if i ~= data.order and i ~= lastorder and not ok then
        --                 lastorder = i
        --                 ok = true
        --                 if self.towerendwin ~= nil then
        --                     self.towerendwin:OpenBox(lastorder, v)
        --                 end
        --             end
        --         end
        --     end
        -- end
        -- LuaTimer.Add(500, function() callback() end)
    end
end

function ApocalypseLordModel:CloseTower()
    if self.towerendwin ~= nil then
        WindowManager.Instance:CloseWindow(self.towerendwin)
    end
end

function ApocalypseLordModel:OpenApocalypseLordIcon()
    if self.ApocalypseLordIcon == nil then
        self.ApocalypseLordIcon = ApocalypseLordIcon.New(self)
    end
    self.ApocalypseLordIcon:Show()
end

function ApocalypseLordModel:CloseApocalypseLordIcon()
    if self.ApocalypseLordIcon ~= nil then
        self.ApocalypseLordIcon:DeleteMe()
        self.ApocalypseLordIcon = nil
    end
end

function ApocalypseLordModel:OpenApocalypseLordSettlementWindow()
    if self.ApocalypseLordSettlementWindow == nil then
        self.ApocalypseLordSettlementWindow = ApocalypseLordSettlementWindow.New(self)
    end
    self.ApocalypseLordSettlementWindow:Show()
end

function ApocalypseLordModel:CloseApocalypseLordSettlementWindow()
    if self.ApocalypseLordSettlementWindow ~= nil then
        self.ApocalypseLordSettlementWindow:DeleteMe()
        self.ApocalypseLordSettlementWindow = nil
    end
end

function ApocalypseLordModel:OpenApocalypseLordTeamPanel(args)
    if self.ApocalypseLordTeamPanel == nil then
        self.ApocalypseLordTeamPanel = ApocalypseLordTeamPanel.New(self)
    end
    self.ApocalypseLordTeamPanel:Show(args)
end

function ApocalypseLordModel:CloseApocalypseLordTeamPanel()
    if self.ApocalypseLordTeamPanel ~= nil then
        self.ApocalypseLordTeamPanel:DeleteMe()
        self.ApocalypseLordTeamPanel = nil
    end
end

function ApocalypseLordModel:EnterScene(args)
    if self.status == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("活动暂未开放，请耐心等待{face_1,3}"))
    else
        ApocalypseLordManager.Instance:Send20801()
    end
end

function ApocalypseLordModel:ExitScene(args)
    ApocalypseLordManager.Instance:Send20802()
end


function ApocalypseLordModel:On20805(data)
    self.spirit_treasure_unit = {
        [1] = {base_id = 32031, difficulty = 1, kill_times = 0, offer_teams = {}, now_star = 1, diff_num = 0 },
        [2] = {base_id = 32027, difficulty = 1, kill_times = 0, offer_teams = {}, now_star = 1, diff_num = 0 },
        [3] = {base_id = 32028, difficulty = 1, kill_times = 0, offer_teams = {}, now_star = 1, diff_num = 0 },
        [4] = {base_id = 32029, difficulty = 1, kill_times = 0, offer_teams = {}, now_star = 1, diff_num = 0 },
        [5] = {base_id = 32030, difficulty = 1, kill_times = 0, offer_teams = {}, now_star = 1, diff_num = 0 },
    }

    for index, unitData in ipairs(data.oracle_treasure_unit) do
        for index2, unitData2 in ipairs(self.spirit_treasure_unit) do
            if unitData.base_id == unitData2.base_id then
                self.spirit_treasure_unit[index2] = unitData
            end
        end
    end

    self.myRank = 0
    self.myRankFormUnitConfigData = nil

    -- local sortfun = function(a,b)
    --     return self:GetUnitData(a.base_id).stage == 2
    --         or (self:GetUnitData(a.base_id).stage ~= 2 and a.base_id < b.base_id)
    -- end
    -- table.sort(self.spirit_treasure_unit, sortfun)

    local boss_wave_list = {}
    local qualification_list = {}

    local roleData = RoleManager.Instance.RoleData
    for index, unitData in ipairs(self.spirit_treasure_unit) do
        for index2, teamData in ipairs(unitData.offer_teams) do
            local teamLeaderIndex = 1
            for index3, mateData in ipairs(teamData.team_mates) do
                if teamData.lid == mateData.rid and teamData.platform == mateData.platform and teamData.zone_id == mateData.zone_id then
                    teamLeaderIndex = index3
                end

                if self.is_offer then
                    if roleData.id == mateData.rid and roleData.platform == mateData.platform and roleData.zone_id == mateData.zone_id then
                        self.myRank = index2
                        self.myRankFormUnitConfigData = self:GetUnitData(unitData.base_id, unitData.difficulty)

                        teamData.isMyTeam = true
                    end
                end

                local key = string.format("%s_%s_%s", mateData.rid, mateData.platform, mateData.zone_id)
                if unitData.base_id == 32031 then -- 如果不是boss处理最高波数
                    if boss_wave_list[key] == nil then
                        boss_wave_list[key] = teamData.wave
                    elseif boss_wave_list[key] < teamData.wave then
                        boss_wave_list[key] = teamData.wave
                    end
                else -- 如果不是boss则累加发放资格数
                    if qualification_list[key] == nil then
                        qualification_list[key] = true
                    end
                end
            end

            if teamLeaderIndex ~= 1 then -- 还是把队长排到最前面比较方便
                local temp = teamData.team_mates[1]
                teamData.team_mates[1] = teamData.team_mates[teamLeaderIndex]
                teamData.team_mates[teamLeaderIndex] = temp
            end
        end
    end

    self.wave_list = {}
    self.qualificationNum = 0
    for key, value in pairs(qualification_list) do
        self.qualificationNum = self.qualificationNum + 1
    end
    for key, value in pairs(boss_wave_list) do
        if self.wave_list[value] == nil then
            self.wave_list[value] = 1
        else
            self.wave_list[value] = self.wave_list[value] + 1
        end
    end
    -- BaseUtils.dump(self.spirit_treasure_unit, "<color='#ffff00'>self.spirit_treasure_unit</color>")
    -- BaseUtils.dump(self.wave_list)
    -- print(self.qualificationNum)

    -- BaseUtils.dump(boss_wave_list)
end

function ApocalypseLordModel:GetUnitData(id, star)
    for index, unitData in ipairs(DataOracleTreasure.data_unit) do
        if unitData.index == id and (star == nil or unitData.star == star) then
            return unitData
        end
    end
end

function ApocalypseLordModel:GetUnitAttrAdd(id, star, kill_times)
    for index, unitData in ipairs(DataOracleTreasure.data_attr_add) do
        if unitData.unit_id == id and unitData.star == star and unitData.times == kill_times then
            return unitData.desc
        end
    end
end

function ApocalypseLordModel:GetSpiritTreasureUnit(id)
    -- local index = self:GetUnitData(id)
    local index = id
    for _, unitData in ipairs(self.spirit_treasure_unit) do
        if unitData.base_id == index then
            return unitData
        end
    end
end

function ApocalypseLordModel:ShowFightPanel()
    if self.fightPanel == nil then
        self.fightPanel = ApocalypseLordFightPanel.New(self)
    end
    self.fightPanel:Show()
end

function ApocalypseLordModel:ShowFightRewardPanel()
    if self.fightRewardPanel == nil then
        self.fightRewardPanel = ApocalypseLordFightRewardPanel.New(self)
    end
    self.fightRewardPanel:Show()
end

function ApocalypseLordModel:MakeBuff()
    if self.is_offer == 1 then
        --构造挑战天启资格buff
        local sBuff = {}
        sBuff.id = 99995            --buff_ID
        sBuff.duration = -1         --剩余时间
        sBuff.cancel = 0            --是否可取消
        sBuff.effect_lev = 1        --当前层次
        sBuff.start_time = 0        --开始时间
        sBuff.dynamic_attr = nil    --动态属性
        BuffPanelManager.Instance.model.buffDic[sBuff.id] = sBuff
    else
        BuffPanelManager.Instance.model.buffDic[99995] = nil
    end
end

function ApocalypseLordModel:GetFriendOnlyRankList(list)
    local result_list = {}
    local friend_List = FriendManager.Instance.friend_List
    local roleData = RoleManager.Instance.RoleData
    local myKey = string.format("%s_%s_%s", roleData.id, roleData.platform, roleData.zone_id)

    for i=1, #list do
        local data = list[i]
        local key = string.format("%s_%s_%s", data.rid, data.platform, data.zone_id)
        if friend_List[key] ~= nil or myKey == key then
            table.insert(result_list, data)
        end
    end
    return result_list
end

function ApocalypseLordModel:GetBossWaveNum(wave)
    local num = 0
    for i=wave, #DataOracleTreasure.data_wave do
        if self.wave_list[i] ~= nil then
            num = num + self.wave_list[i]
        end
    end
    -- return string.format("%.1f", num / self.qualificationNum * 100)
    if self.qualificationNum == 0 then
        return "0"
    else
        return string.format("%s", BaseUtils.Round(num / self.qualificationNum * 100))
    end
end

function ApocalypseLordModel:GetTeamType()
    -- if self.group == nil then
    --     self.group = 0
    -- end
    -- return self.group + 300
    return 250
end

function ApocalypseLordModel:OpenHelp(args) -- by 嘉俊 2017/8/29
    if self.helpWin == nil then
        self.helpWin = ApocalypseLordHelpWindow.New(self)
    end
    self.helpWin:Open(args)
end

-- -- 获取活动阶段 1.预赛 2.正赛
-- function ApocalypseLordModel:GetState()
--     local weekDay = os.date("%w", BaseUtils.BASE_TIME)
--     local hour = os.date("%H", BaseUtils.BASE_TIME)
--     if weekDay == 0 then weekDay = 7 end

--     if weekDay < 4 or ( weekDay == 4 and hour < 13 ) then
--         return 1
--     else
--         return 2
--     end
-- end
