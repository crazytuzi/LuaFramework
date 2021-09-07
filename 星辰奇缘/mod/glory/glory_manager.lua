GloryManager = GloryManager or BaseClass(BaseManager)

function GloryManager:__init()
    if GloryManager.Instance ~= nil then
        return
    end

    GloryManager.Instance = self
    self.model = GloryModel.New()

    self.noShowed = false
    self:InitHandler()

    self.skillTips = GlorySkillTips.New()

    EventMgr.Instance:AddListener(event_name.role_level_change, function()
        self.noShowed = not self:ChallengeLevel()
        self:RedPointMainUI()
    end )

    self.onUpdateInfo = EventLib.New()
    self.onUpdateRank = EventLib.New()
    self.onUpdateVideo = EventLib.New()
    self.onUpdateRecent = EventLib.New()
    self.onUpdateLevel = EventLib.New()
    self.onUpdateTime = EventLib.New()
    self.sureHandler =
    function()
        self:SureCallBack();
    end
    -- 已经提示的列表
    self.ShowedList = { };

    -- 是否处于观看录像状态
    self.isWatching = false
    self.isFailure = true
    self.name = TI18N("爵位闯关")
end

function GloryManager:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

function GloryManager:InitHandler()
    -- self:AddNetHandler(14400, self.on14400)
    -- self:AddNetHandler(14401, self.on14401)
    -- self:AddNetHandler(14402, self.on14402)
    -- self:AddNetHandler(14403, self.on14403)
    -- self:AddNetHandler(14404, self.on14404)
    -- self:AddNetHandler(14405, self.on14405)
    -- self:AddNetHandler(14406, self.on14406)
    -- self:AddNetHandler(14407, self.on14407)
    -- self:AddNetHandler(14408, self.on14408)

    self:AddNetHandler(14420, self.on14420)
    self:AddNetHandler(14421, self.on14421)
    self:AddNetHandler(14422, self.on14422)
    self:AddNetHandler(14423, self.on14423)
    self:AddNetHandler(14424, self.on14424)
    self:AddNetHandler(14425, self.on14425)
    self:AddNetHandler(14426, self.on14426)
    self:AddNetHandler(14427, self.on14427)
    self:AddNetHandler(14428, self.on14428)
    self:AddNetHandler(14429, self.on14429)

    EventMgr.Instance:AddListener(event_name.end_fight, function(type, result) self:OnEndFight(type, result) end)
    EventMgr.Instance:AddListener(event_name.begin_fight, function(type) self:OnBeginFight(type) end)
    EventMgr.Instance:AddListener(event_name.role_attr_change, function() self:ShowGloryFunTuips() end)
end

function GloryManager:OpenWindow(args)
    self.noShowed = true
    self.model:OpenWindow()
    self:RedPointMainUI()
end

function GloryManager:OpenConfirm(args)
    self.model:OpenConfirm(args)
end

function GloryManager:OpenVideo(args)
    self.model:OpenVideo(args)
end

function GloryManager:OpenNewRecored(args)
    self.model:OpenNewRecored(args)
end

function GloryManager:OpenReward(args)
    self.model:OpenReward(args)
end

-- -------------------------- 以下协议弃用 ---------------------

function GloryManager:send14400()
    Connection.Instance:Send(14400, { })
end

function GloryManager:on14400(data)
    print("接收14400")
    -- BaseUtils.dump(data, "我的试炼数据")
    self.model:SetMyData(data)

    self.model.levelDataList[self.model.level_id] = nil

    if self.model.end_time > 0 then
        self.timerid = LuaTimer.Add(0, 1000, function() self:OnTick() end)
    end

    self:RedPointMainUI()
    self.onUpdateInfo:Fire()
end

-- 请求挑战
function GloryManager:send14401(callback)
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.glory_window)
    if callback ~= nil then
        self.on14401_callback = callback
    end
    Connection.Instance:Send(14401, { })
end

function GloryManager:on14401(data)
    -- print("接收14401 "..data.result.." "..data.msg)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.glory_window, {})
end

-- 请求晋升 {skill_id = xxx}
function GloryManager:send14402(data)
    Connection.Instance:Send(14402, data)
end

function GloryManager:on14402(data)
    -- print("接收14402 "..data.result.." "..data.msg)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 重新选择技能 {skill_order = xxx, skill_id = xxx}
function GloryManager:send14403(data)
    Connection.Instance:Send(14403, data)
end

function GloryManager:on14403(data)
    -- print("接收14403 "..data.result.." "..data.msg)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 清除荣耀试炼冷却
function GloryManager:send14404(data)
    Connection.Instance:Send(14404, { })
end

function GloryManager:on14404(data)
    -- print("接收14404 "..data.result.." "..data.msg)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        self:send14401()
    end
end

function GloryManager:RequestInitData()
    self.model.lastLevel = nil
     self.isFailure = true
    self:send14424()
end

-- 请求某关的排行数据 {id = xxx}
function GloryManager:send14405(data)
    -- print("send14405")
    Connection.Instance:Send(14405, data)
end

function GloryManager:on14405(data)
    -- BaseUtils.dump(data, data.id.."级试炼数据")
    self.model:SetRankById(data)
    self.onUpdateLevel:Fire(data.id)

    self.onUpdateRank:Fire()
    self.onUpdateRecent:Fire()
    self.onUpdateTime:Fire()
    self.onUpdateInfo:Fire()
end

function GloryManager:on14406(data)
    -- print("接收14406")
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.glory_confirm_window, { data })
end

function GloryManager:send14407(rid, platform, zoneid, lev_id)
    local dat = { rid = rid, r_platform = platform, r_zone_id = zoneid, lev_id = lev_id }
    -- BaseUtils.dump(dat, "发送14407")
    Connection.Instance:Send(14407, dat)
end

function GloryManager:on14407(data)
    -- BaseUtils.dump(data, "接收14407")
    if data.result == 1 then
        self.isWatching = true
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.glory_window)
    else
        self.isWatching = false
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

function GloryManager:send14408(rid, platform, zoneid, lev_id)
    local dat = { rid = rid, r_platform = platform, r_zone_id = zoneid, lev_id = lev_id }
    -- BaseUtils.dump(dat, "发送14408")
    Connection.Instance:Send(14408, dat)
end

function GloryManager:on14408(data)
    -- BaseUtils.dump(data, "接收14408")
    if data.result == 1 then
        self.isWatching = true
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.glory_window)
    else
        self.isWatching = false
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end
-- -------------------------- 以上协议弃用 ---------------------

-- --------------------- 以下协议为新的爵位挑战 ----------------

-- 请求挑战
function GloryManager:send14420()
    Connection.Instance:send(14420, { })
end

function GloryManager:on14420(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 关卡信息
function GloryManager:send14421()
    Connection.Instance:send(14421, { })
end

function GloryManager:on14421(data)
    self.model.currentData.wave = data.wave
    self.onUpdateInfo:Fire()
end

-- 战斗关卡奖励
function GloryManager:send14422()
    Connection.Instance:send(14422, { })
end

function GloryManager:on14422(data)
    self.model.currentData.waveReward = self.model.currentData.waveReward or { }
    self.model.currentData.new_id = data.wave
    self.model.currentData.waveReward[data.wave] = data
    self.onUpdateInfo:Fire()
end

-- 战斗结算
function GloryManager:send14423()
    Connection.Instance:send(14423, { })
end

function GloryManager:on14423(data)
    -- BaseUtils.dump(data, "on14423")
    if data.result == 1 then
        self.isFailure = false
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.glory_confirm_window, { data })
    elseif data.result == 0 then
        self.isFailure = true
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.glory_window);
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

-- 个人信息
function GloryManager:send14424()
    -- Log.Error("=======================")
    -- print(debug.traceback())
    Connection.Instance:send(14424, { })
end

function GloryManager:on14424(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>===================================14424===============================")
    for k, v in pairs(data) do
        self.model.currentData[k] = v
    end
    self.onUpdateInfo:Fire()
    self:ShowGloryFunTuips()
end

-- 领取今天奖励
function GloryManager:send14425()
    Connection.Instance:send(14425, { })
end

function GloryManager:on14425(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 当前排行榜
function GloryManager:send14426(data)
    Connection.Instance:send(14426, { })
end

function GloryManager:on14426(data)
    -- BaseUtils.dump(data, "on14426")
    self.model.currentData.rank_list = data.list
    self.onUpdateRank:Fire()
end

-- 最近层数人数
function GloryManager:send14427()
    Connection.Instance:send(14427, { })
end

function GloryManager:on14427(data)
    -- BaseUtils.dump(data, "on14427")
    self.model.nearData = data.list
    table.sort(self.model.nearData, function(a, b) return a.floor < b.floor end)

    self.onUpdateLevel:Fire()
end

-- 录像排行榜
function GloryManager:send14428(floor)
    -- print("send14428")
    Connection.Instance:send(14428, { floor = floor })
end

function GloryManager:on14428(data)
    -- BaseUtils.dump(data, "on14428")
    self.model.videoData[data.floor] = data

    self.onUpdateVideo:Fire(data.floor)
end

-- 清除挑战CD
function GloryManager:send14429()
    Connection.Instance:send(14429, { })
end

function GloryManager:on14429()

end


-- -------------------------------------------------------------

-- currentSkill = skilldata1, anotherSkillList = {[1] = skillData, [2] = skillData, ...}
function GloryManager:ShowSkillTips(args)
    -- BaseUtils.dump(args, "参数")
    self.skillTips:Show(args)
    -- self.skillTips:Init1()
end

function GloryManager:OnTick()
    self.onUpdateTime:Fire()
    if self.model.end_time == nil or self.model.end_time == 0 or self.model.end_time - BaseUtils.BASE_TIME <= 0 then
        LuaTimer.Delete(self.timerid)
    end
end

function GloryManager:ChallengeGlory()
    if self.model ~= nil then
        return self.model:newGlory()
    else
        return false
    end
end

-- 判断能否挑战，不计时
function GloryManager:ChallengeLevel()
    -- if self.model ~= nil then
    --     local res = self.model:newLevel()
    --     if res == true then
    --         DataAgenda.data_list[1024].engaged = 0
    --     else
    --         DataAgenda.data_list[1024].engaged = 1
    --     end
    --     return res
    -- else
    --     return false
    -- end
    return true
end

-- 检查主UI是否有红点
function GloryManager:RedPointMainUI()
    -- if self.icon == nil then
    --     if DataSystem.data_icon[27].icon ~= nil then
    --         self.icon = DataSystem.data_icon[27].icon.transform
    --     end
    -- end

    -- local bool =
    -- if self.icon ~= nil then
    --     if bool == true and self.noShowed ~= true then
    --         MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(27, true)
    --     else
    --         MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(27, false)
    --     end
    -- end

    local red = self:ChallengeLevel() and self.noShowed ~= true
    -- AgendaManager.Instance:SetCurrLimitID(1024, red)
    return red
end


function GloryManager:OnEndFight(type, result)
    if self.isWatching then
        self.isWatching = false
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.glory_window)
    end

    if type == 60 then
        if self.model.fightPanel ~= nil then
            self.model.fightPanel:DeleteMe()
            self.model.fightPanel = nil
        end
    end
end

function GloryManager:OnBeginFight(type)
    if type == 60 then
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.glory_window, false)
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.glory_video, false)
    end
end

function GloryManager:ShowFightPanel()
    self.model:ShowFightPanel()
end

function GloryManager:ShowGloryFunTuips()
    if self.showTimer ~= nil then
        LuaTimer.Delete(self.showTimer);
    end
    self.showTimer = LuaTimer.Add(3000,
    function()
        if self.showTimer ~= nil then
            LuaTimer.Delete(self.showTimer);
        end
        self.showTimer = nil
        self:DoShowGloryFunTuips();
    end )
end

function GloryManager:DoShowGloryFunTuips()
    if not self.isFailure then
        return
    end
    local autoList = BackpackManager.Instance.autoList;
    if #autoList > 0 then
       -- return
    end
    if TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.None then
        return
    end
    if RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight then
        return
    end
    local curID = self.model.currentData.new_id;
    if curID == nil or curID == DataGlory.data_level_length then
        return
    end
    curID = curID + 1;
    local tmp = DataGlory.data_level[curID];
    if tmp == nil then
        return;
    end
    local myfc = RoleManager.Instance.RoleData.fc;
    if tmp.need_fc > myfc or tmp.need_lev > RoleManager.Instance.RoleData.lev then
        return
    end
    if PlayerPrefs.GetInt("GloryIDTips"..BaseUtils.get_self_id(),0) >= curID then
        return
    end
    PlayerPrefs.SetInt("GloryIDTips"..BaseUtils.get_self_id(), curID);
    table.insert(self.ShowedList, curID);
    local autoData = AutoUseData.New()
    autoData.type = AutoUseEumn.types.guide_glory;
    autoData.title = TI18N("爵位闯关");
    autoData.label = TI18N("前往挑战");
    autoData.name = string.format(TI18N("评分已达爵位挑战推荐评分 <color='#ffff00'>%s</color>分"), tmp.need_fc);
    autoData.callback = self.sureHandler
    autoData.itemId = 30000
    NoticeManager.Instance:AutoUse(autoData)
end

function GloryManager:SureCallBack()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.glory_window);
end

function GloryManager.RewardFilter(list)
    local classes = RoleManager.Instance.RoleData.classes
    local sex = RoleManager.Instance.RoleData.sex

    local datalist = { }
    for _, v in ipairs(list) do
        if #v == 5 then
            if (v[4] == 0 or v[4] == classes) and(v[5] == 2 or v[5] == sex) then
                table.insert(datalist, { v[1], v[3] })
            end
        elseif #v == 3 then
            table.insert(datalist, { v[1], v[3] })
        elseif #v == 2 then
            table.insert(datalist, BaseUtils.copytab(v))
        end
    end

    return datalist
end
