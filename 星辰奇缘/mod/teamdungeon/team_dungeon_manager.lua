-- ----------------------------------------------------------
-- Manager - 组队副本
-- ljh 20170205
-- ----------------------------------------------------------
TeamDungeonManager = TeamDungeonManager or BaseClass(BaseManager)

function TeamDungeonManager:__init()
    if TeamDungeonManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	TeamDungeonManager.Instance = self

    self.model = TeamDungeonModel.New()

    self:InitHandler()

    self.OnUpdate = EventLib.New()
    self.OnUpdateReward = EventLib.New()
    self.OnUpdateRewardText = EventLib.New()
    self.hasRewardData = 0
    self.isNext = false
    self.setText = false
    self.isGetAllNext = false
    self.cardNum = 0
    self.dungeon_status = false
end

function TeamDungeonManager:RequestInitData()
	self.model:InitData()

    self:Send12140()
    self:Send12150()
    self:Send12152()
end

function TeamDungeonManager:__delete()
    self.OnUpdate:DeleteMe()
    self.OnUpdate = nil
end

function TeamDungeonManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(12130, self.On12130)
    self:AddNetHandler(12131, self.On12131)
    self:AddNetHandler(12132, self.On12132)
    self:AddNetHandler(12133, self.On12133)
    self:AddNetHandler(12134, self.On12134)
    self:AddNetHandler(12135, self.On12135)
    self:AddNetHandler(12136, self.On12136)
    self:AddNetHandler(12137, self.On12137)
    self:AddNetHandler(12138, self.On12138)
    self:AddNetHandler(12139, self.On12139)
    self:AddNetHandler(12140, self.On12140)
    self:AddNetHandler(12141, self.On12141)
    self:AddNetHandler(12142, self.On12142)
    self:AddNetHandler(12143, self.On12143)
    self:AddNetHandler(12144, self.On12144)
    self:AddNetHandler(12145, self.On12145)
    self:AddNetHandler(12146, self.On12146)
    self:AddNetHandler(12147, self.On12147)
    self:AddNetHandler(12148, self.On12148)
    self:AddNetHandler(12149, self.On12149)
    self:AddNetHandler(12150, self.On12150)
    self:AddNetHandler(12151, self.On12151)
    self:AddNetHandler(12152, self.On12152)
end

function TeamDungeonManager:Send12130()
    Connection.Instance:send(12130, { })
end

function TeamDungeonManager:On12130(data)
    -- BaseUtils.dump(data, "On12130")
    if #data.members == 0 then
        self.model.dungeon_team = nil
        self.model.status = 0
        -- self.model.quickJionMark = false
        self.OnUpdate:Fire("UpdateTeamToggle")
        self.OnUpdate:Fire("UpdateBar")
        self:Send12131(self.model.dun_id)
        if self.autoStartTimerId ~= nil then
            LuaTimer.Delete(self.autoStartTimerId)
            self.autoStartTimerId = nil
        end
    else
        local list = {}
        local roleData = RoleManager.Instance.RoleData
        local status = 0
        for _,value in pairs(data.members) do
            if value.rid == roleData.id and value.platform == roleData.platform and value.zone_id == roleData.zone_id then
                status = value.status
            end
            if value.status == 1 then
                table.insert(list, 1, value)
            else
                table.insert(list, value)
            end
        end

        if status == 1 and #list == 5 and (self.model.dungeon_team == nil or self.model.dungeon_team.dungeon_mate == nil or #self.model.dungeon_team.dungeon_mate ~= 5) then
            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            confirmData.content = TI18N("队伍人数已满，是否立即开始挑战？")
            confirmData.sureLabel = TI18N("立即开始")
            confirmData.cancelLabel = TI18N("取消")
            confirmData.cancelSecond = 20
            confirmData.sureCallback = function()
                    TeamDungeonManager.Instance:Send12139()
                end
            NoticeManager.Instance:ConfirmTips(confirmData)
        end

        self.model.status = status
        self.model.dungeon_team = data
        self.model.dungeon_team.dungeon_mate = list
        self.model.quickJionMark = false
        self.OnUpdate:Fire("UpdateTeamToggle")
        self.OnUpdate:Fire("UpdateMemberList")

        if data.dun_id ~= self.model.dun_id then
            self.model.dun_id = data.dun_id
            self.OnUpdate:Fire("UpdateSelectDungeon")
        end

        if #list == 5 then
            if self.model.window == nil then
                self.model:OpenTeamDungeonWindow()
            end

            if self.model.status == 1 then
                if self.autoStartTimerId ~= nil then
                    LuaTimer.Delete(self.autoStartTimerId)
                    self.autoStartTimerId = nil
                end
                self.autoStartTimerId = LuaTimer.Add(30000, function()
                    if self.model.status == 1 then
                        TeamDungeonManager.Instance:Send12139()
                    end
                    self.autoStartTimerId = nil
                end)
            end
        else
            if self.autoStartTimerId ~= nil then
                LuaTimer.Delete(self.autoStartTimerId)
                self.autoStartTimerId = nil
            end
        end
    end
end

function TeamDungeonManager:Send12131(id)
    Connection.Instance:send(12131, { id = id })
end

function TeamDungeonManager:On12131(data)
    -- BaseUtils.dump(data, "On12131")
    if data.dun_id == self.model.dun_id then
        self.model.dungeon_enlistment = data.list
        self.OnUpdate:Fire("UpdateTeamList")
    end
end

function TeamDungeonManager:Send12132(dun_id)
    Connection.Instance:send(12132, { dun_id = dun_id })
end

function TeamDungeonManager:On12132(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TeamDungeonManager:Send12133()
    Connection.Instance:send(12133, { })
end

function TeamDungeonManager:On12133(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.flag == 1 then
        if self.autoStartTimerId ~= nil then
            LuaTimer.Delete(self.autoStartTimerId)
            self.autoStartTimerId = nil
        end
    end
end

function TeamDungeonManager:Send12134(dun_id)
    Connection.Instance:send(12134, { dun_id = dun_id })
end

function TeamDungeonManager:On12134(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        self.model.quickJionMark = true
        if self.model.window ~= nil then
            self.model.window.autoJoinTime = nil
        end
        self.OnUpdate:Fire("UpdateTeamToggle")
    end
end

function TeamDungeonManager:Send12135()
    Connection.Instance:send(12135, { })
end

function TeamDungeonManager:On12135(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        self.model.quickJionMark = false
        self.OnUpdate:Fire("UpdateTeamToggle")
    end
end

function TeamDungeonManager:Send12136(id, platform, zone_id, dun_id)
    Connection.Instance:send(12136, { id = id, platform = platform, zone_id = zone_id, dun_id = dun_id })
end

function TeamDungeonManager:On12136(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TeamDungeonManager:Send12137()
    Connection.Instance:send(12137, { })
end

function TeamDungeonManager:On12137(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        self.model.dungeon_team = nil
        self.model.status = 0
        self.OnUpdate:Fire("UpdateTeamList")
    elseif data.result == 2 then
        self.model.dungeon_team = nil
        self.model.status = 0
        if self.model.window ~= nil then
            WindowManager.Instance:CloseWindow(self.model.window)
        end
    end
end

function TeamDungeonManager:Send12138(id, platform, zone_id)
    Connection.Instance:send(12138, { id = id, platform = platform, zone_id = zone_id })
end

function TeamDungeonManager:On12138(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TeamDungeonManager:Send12139()
    Connection.Instance:send(12139, { })
end

function TeamDungeonManager:On12139(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        self.dungeon_status = true
        -- self.model:CloseTeamDungeonWindow()
        -- WindowManager.Instance:CloseWindowById(WindowConfig.WinID.teamdungeonwindow)
        if self.model.window ~= nil then
            WindowManager.Instance:CloseWindow(self.model.window)
        end
        if self.autoStartTimerId ~= nil then
            LuaTimer.Delete(self.autoStartTimerId)
            self.autoStartTimerId = nil
        end
    end
end

function TeamDungeonManager:Send12140()
    Connection.Instance:send(12140, { })
end

function TeamDungeonManager:On12140(data)
    if data.is_matching == 1 then
        self.model.quickJionMark = true

        self.model:OpenTeamDungeonWindow()

        -- self.OnUpdate:Fire("UpdateTeamToggle")
        -- if data.dun_id ~= self.model.dun_id then
        --     self.model.dun_id = data.dun_id
        --     self.OnUpdate:Fire("UpdateSelectDungeon")
        -- end
    else
        self.model.quickJionMark = false
    end
end

function TeamDungeonManager:Send12141()
    Connection.Instance:send(12141, { })
end

function TeamDungeonManager:On12141(data)
    -- BaseUtils.dump(data, "On12141")
    if self.model.dungeon_team == nil then
        return
    end
    local mark = false
    if self.model.dungeon_team == nil or self.model.dungeon_team.dungeon_mate == nil or #self.model.dungeon_team.dungeon_mate ~= 5 then
        mark = true
    end
    for i, member in ipairs(data.members) do
        local mark = true
        for key,value in pairs(self.model.dungeon_team.dungeon_mate) do
            if value.rid == member.rid and value.platform == member.platform and value.zone_id == member.zone_id then
                self.model.dungeon_team.dungeon_mate[key] = member
                mark = false
            end
        end
        if mark then
            table.insert(self.model.dungeon_team.dungeon_mate, member)
        end
    end

    local list = {}
    local roleData = RoleManager.Instance.RoleData
    local status = 0
    for _,value in pairs(self.model.dungeon_team.dungeon_mate) do
        if value.rid == roleData.id and value.platform == roleData.platform and value.zone_id == roleData.zone_id then
            status = value.status
        end
        if value.status == 1 then
            table.insert(list, 1, value)
        else
            table.insert(list, value)
        end
    end

    if status == 1 and #list == 5 and mark then
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.content = TI18N("队伍人数已满，是否立即开始挑战？")
        confirmData.sureLabel = TI18N("立即开始")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.cancelSecond = 20
        confirmData.sureCallback = function()
                TeamDungeonManager.Instance:Send12139()
            end
        NoticeManager.Instance:ConfirmTips(confirmData)
    end

    self.model.status = status
    self.model.dungeon_team.dungeon_mate = list

    self.OnUpdate:Fire("UpdateMemberList")

    if #list == 5 then
        if self.model.window == nil then
            self.model:OpenTeamDungeonWindow()
        end

        if self.model.status == 1 then
            if self.autoStartTimerId ~= nil then
                LuaTimer.Delete(self.autoStartTimerId)
                self.autoStartTimerId = nil
            end
            self.autoStartTimerId = LuaTimer.Add(30000, function()
                    if self.model.status == 1 then
                        TeamDungeonManager.Instance:Send12139()
                    end
                    self.autoStartTimerId = nil
                end)
        end
    else
        if self.autoStartTimerId ~= nil then
            LuaTimer.Delete(self.autoStartTimerId)
            self.autoStartTimerId = nil
        end
    end
end

function TeamDungeonManager:Send12142()
    Connection.Instance:send(12142, { })
end

function TeamDungeonManager:On12142(data)
    if self.model.dungeon_team == nil then
        return
    end
    for i, member in ipairs(data.members) do
        for key,value in pairs(self.model.dungeon_team.dungeon_mate) do
            if value.rid == member.rid and value.platform == member.platform and value.zone_id == member.zone_id then
                table.remove(self.model.dungeon_team.dungeon_mate, key)
            end
        end
    end
    self.OnUpdate:Fire("UpdateMemberList")

    if self.autoStartTimerId ~= nil then
        LuaTimer.Delete(self.autoStartTimerId)
        self.autoStartTimerId = nil
    end
end

function TeamDungeonManager:Send12143(rid, platform, zone_id)
    Connection.Instance:send(12143, { rid = rid, platform = platform, zone_id = zone_id })
end

function TeamDungeonManager:On12143(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TeamDungeonManager:Send12144(rid, platform, zone_id)
    Connection.Instance:send(12144, { rid = rid, platform = platform, zone_id = zone_id, type = 1 })
end

function TeamDungeonManager:On12144(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TeamDungeonManager:Send12145()
    Connection.Instance:send(12145, { })
end

function TeamDungeonManager:On12145(data)
    -- BaseUtils.dump(data, "On12145")
    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.content = TI18N(string.format("%slv.%s邀请你加入<color='#ffff00'>%s</color>挑战队伍", data.name, data.lev, data.dun_name))
    confirmData.sureLabel = TI18N("接受")
    confirmData.cancelLabel = TI18N("拒绝")
    confirmData.cancelSecond = 30
    confirmData.sureCallback = function()
            self:Send12144(data.rid, data.platform, data.zone_id)
            self.model:OpenTeamDungeonWindow()
        end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

function TeamDungeonManager:Send12146()
    Connection.Instance:send(12146, {  })
end

function TeamDungeonManager:On12146(data)
    -- BaseUtils.dump(data, "On12146")
    self.model:CloseTeamDungeonRewardWindow()
    self.model:OpenTeamDungeonRewardWindow({data})
end

function TeamDungeonManager:Send12147(t)
    self.setText = t or false
    Connection.Instance:send(12147, {  })
end

function TeamDungeonManager:On12147(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 and self.rewardWindow ~= nil then
        self.rewardWindow.donotSend12147 = true
        self.rewardWindow:ClickCloseCard(2)
    end

    self:Send12152()


end

function TeamDungeonManager:Send12148(t)
    self.isGetAllNext = t or false
    Connection.Instance:send(12148, {  })
end

function TeamDungeonManager:On12148(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        if self.isGetAllNext == false then
            self.model:CloseTeamDungeonRewardWindow()
        else
            self:Send12151()
        end
    end
end

function TeamDungeonManager:Send12149(dun_id)
    Connection.Instance:send(12149, { dun_id = dun_id })
end

function TeamDungeonManager:On12149(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        if data.dun_id ~= self.model.dun_id then
            self.model.dun_id = data.dun_id
            self.OnUpdate:Fire("UpdateSelectDungeon")
        end
    end
end

function TeamDungeonManager:Send12150()
    Connection.Instance:send(12150, {  })
end

function TeamDungeonManager:On12150(data)
    self.model.passTimes = 0
    for _,value in pairs(data.pass_list) do
        self.model.pass_list[value.dun_id] = value.times
        self.model.passTimes = self.model.passTimes + value.times
    end
    for _,value in pairs(data.rewards) do
        self.model.rewards_list[value.dun_id] = value
    end

    self.OnUpdate:Fire("UpdateBar", 0)
end


function TeamDungeonManager:Send12151()
    Connection.Instance:send(12151,{})
end

function TeamDungeonManager:On12151(data)
    self.model:CloseTeamDungeonRewardWindow()
    self.model:OpenTeamDungeonRewardWindow({data,true})
end

function TeamDungeonManager:Send12152(t,num)
    self.cardNum = num or 0
    self.isNext = t or false
    Connection.Instance:send(12152,{})
end

function TeamDungeonManager:On12152(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.hasRewardData =  data.has_cards
    ImproveManager.Instance:OnStatusChange(true)

    if self.isNext == true then
        self:Send12151()
    end

    if self.cardNum ~= 0 then
        self.OnUpdateReward:Fire(self.cardNum)
    end

    if self.setText == true then
        self.OnUpdateRewardText:Fire()
    end
end

