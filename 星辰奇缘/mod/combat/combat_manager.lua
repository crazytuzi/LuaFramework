-- 战斗系统管理器
CombatManager = CombatManager or BaseClass(BaseManager)

function CombatManager:__init()
    -- 模型全局变更
    if CombatManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    CombatManager.Instance = self
    -- self.objPool = CombatObjectPool.New()

    self.controller = nil

    self.MaxAnger = 100

    -- 战斗进入初始数据
    self.enterData = nil
    -- 是否战斗中
    self.isFighting = false
    -- 播报中
    self.isBrocasting = false
    -- 是否触发战斗结束
    self.FireEndFightScene = false
    -- 是否触发播报结束
    self.FireEndFightBroad = false
    --是否观战
    self.isWatching = false
    --观看录像
    self.isWatchRecorder = false
    -- 上次结束的战斗（0表示正常战斗，1表示观战，2表示观看录像）
    self.lastCombatType = 0
    -- 录像快进标志
    self.RecorderSkip = false
    -- 格子数对应的坐标{string, Vector3}
    self.gridToPostDict = {}
    -- 技能特效表
    self.skillEffectDict = {}
    -- 音效表
    self.soundDict = {}
    -- 讲话表
    self.talkDict = {}
    -- 场景加载完成标志
    self.loadFinish = false
    -- 缓存进入数据
    self.cacheData = nil
    -- 自动战斗标志
    self.isAutoFighting = false
    --战斗进入中
    self.Creating = false

    self.combatType = 1

    self.roleSelectSkillTime = 0

    self.petSelectSkillTime = 0
    -- EventMgr.Instance:AddListener(event_name.mainui_loaded, function() self:OnMainUiLoaded() end)
    -- EventMgr.Instance:AddListener(event_name.self_loaded, function() self:OnSceneLoaded() end)
    EventMgr.Instance:AddListener(event_name.mainui_loaded, function() LuaTimer.Add(1200, function() self:OnMainUiLoaded() end)  end)
    -- EventMgr.Instance:AddListener(event_name.socket_reconnect, function() self:OnDisConnect() end)

    self.selectState = CombatSeletedState.Idel

    self:InitData()
    self:AddAllHandlers()

    self.SelfResCache = {}
    self.EnemyResCache = {}

    self.self_preside = {}
    self.target_preside = {}

    self.danmakuHistory = {}

    self.combatHelpSkillData = {}
    -- 战斗投票数据
    self.voteData = nil

    self.lastEnterTime = -999
    self.OnCmdChangeEvent = EventLib.New()
    self.OnCurrLogChange = EventLib.New()
    self.OnKeepLogChange = EventLib.New()
    self.OnGoodLogChange = EventLib.New()
    self.OnHotLogChange = EventLib.New()
    self.OnFirstKillChange = EventLib.New()
    self.OnKuafuGoodChange = EventLib.New()
    self.OnLikeChange = EventLib.New()
    self.OnZanChange = EventLib.New()
    self.OnRecordListChange = EventLib.New()
    self.WatchLogmodel = CombatLogModel.New()
    self.OnDanmakuPoolChange = EventLib.New()
end

function CombatManager:__delete()
    self.controller = nil
end

function CombatManager:AddAllHandlers()
    self:AddNetHandler(10705, self.On10705);
    self:AddNetHandler(10706, self.On10706);
    self:AddNetHandler(10707, self.On10707);
    self:AddNetHandler(10710, self.On10710);
    self:AddNetHandler(10711, self.On10711);
    self:AddNetHandler(10720, self.On10720);
    self:AddNetHandler(10721, self.On10721);
    self:AddNetHandler(10722, self.On10722);
    self:AddNetHandler(10723, self.On10723);

    -- self:AddNetHandler(10731, self.On10731);
    self:AddNetHandler(10732, self.On10732);
    self:AddNetHandler(10733, self.On10733);
    self:AddNetHandler(10734, self.On10734);
    self:AddNetHandler(10735, self.On10735);

    self:AddNetHandler(10740, self.On10740);
    self:AddNetHandler(10741, self.On10741);
    self:AddNetHandler(10742, self.On10742);
    self:AddNetHandler(10743, self.On10743);

    self:AddNetHandler(10760, self.On10760);
    self:AddNetHandler(10761, self.On10761);
    self:AddNetHandler(10762, self.On10762);

    self:AddNetHandler(10789, self.On10789);
    self:AddNetHandler(10790, self.On10790);
    self:AddNetHandler(10744, self.On10744);

    self:AddNetHandler(10747, self.On10747);
    self:AddNetHandler(10748, self.On10748);
    self:AddNetHandler(10749, self.On10749);
    self:AddNetHandler(10750, self.On10750);
    self:AddNetHandler(10751, self.On10751);
    self:AddNetHandler(10752, self.On10752);
    self:AddNetHandler(10753, self.On10753);
    self:AddNetHandler(10754, self.On10754);
    self:AddNetHandler(10755, self.On10755);
    self:AddNetHandler(10756, self.On10756);
    self:AddNetHandler(10757, self.On10757);
    self:AddNetHandler(10758, self.On10758);
    self:AddNetHandler(10759, self.On10759);
    self:AddNetHandler(10769, self.On10769);
    self:AddNetHandler(10770, self.On10770);
    self:AddNetHandler(10771, self.On10771);
    self:AddNetHandler(10772, self.On10772);
    self:AddNetHandler(10773, self.On10773);
    self:AddNetHandler(10774, self.On10774);
    self:AddNetHandler(10775, self.On10775);
    self:AddNetHandler(10776, self.On10776);
    self:AddNetHandler(10777, self.On10777);
    self:AddNetHandler(10778, self.On10778);
    self:AddNetHandler(10779, self.On10779);
    self:AddNetHandler(10780, self.On10780);
    --
    EventMgr.Instance:RemoveListener(event_name.end_fight, function() self:OpenLittleVedioPanel()end )
    EventMgr.Instance:AddListener(event_name.end_fight, function() self:OpenLittleVedioPanel()end )
end

function CombatManager:InitData()
    self:InitSkillEffectData()
    self:InitSoundData()
    self:InitTalkData()
end

function CombatManager:SendOnConnect()
    self:Send10742()
    -- self:Send10747()
    -- self:Send10748()
    -- self:Send10749()
end

function CombatManager:InitSkillEffectData()
    -- local list = DataSkillEffect.data_skill_effect
    -- local key = nil
    -- for _, val in ipairs(list) do
    --     key = CombatUtil.Key(val.skill_id, val.motion_id)
    --     if val.hit_distance == 0 then
    --         val.hit_distance = 500
    --     end
    --     if val.hit_time == 0 then
    --         val.hit_time = 0
    --     end
    --     if val.end_time == 0 then
    --         val.end_time = 300
    --     end

    --     if self.skillEffectDict[key] == nil then
    --         self.skillEffectDict[key] = {val}
    --     else
    --         table.insert(self.skillEffectDict[key], val)
    --     end
    -- end
end

function CombatManager:InitSoundData()
    local list = DataSkillSound.data_skill_sound
    local key = nil
    for _, val in ipairs(list) do
        key = CombatUtil.Key(val.skill_id, val.motion_id)
        if self.soundDict[key] == nil then
            self.soundDict[key] = {val}
        else
            table.insert(self.soundDict[key], val)
        end
    end
end

function CombatManager:InitTalkData()
    local temp = {}
    for k,v in pairs(DataNpcTalk.data_npc_talk) do
        if temp[v.npc_id] == nil then
            temp[v.npc_id] = {}
        end
        table.insert(temp[v.npc_id], v)
    end
    self.talkDict = temp
end

-- 请求观战返回
function CombatManager:On10705(data)
    if data.result == 1 then
        self.isWatching = true
    else
        self.isWatching = false
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CombatManager:Send10705(_rid, _platform, _zone_id)
    if self.isFighting then
        NoticeManager.Instance:FloatTipsByString(TI18N("正在观看中"))
        return
    end
    self.watchindTarget = {id = _rid, platform = _platform, zone_id = _zone_id}
    Connection.Instance:send(10705, {rid = _rid, platform = _platform, zone_id = _zone_id})
end
-- 退出观战
function CombatManager:On10706(data)
    if data.result == 1 then
        if self.isFighting then
            -- self.controller.brocastCtx.islastRound = true
            if self.controller ~= nil then
                self.controller:OnEndFighting(data.result, data.msg)
            end
        end
    end
end

-- 请求NPC观战
function CombatManager:On10707(data)
    if data.result == 1 then
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end


function CombatManager:Send10707(battle_id, id)
    if self.isFighting then
        NoticeManager.Instance:FloatTipsByString(TI18N("正在观看中"))
        return
    end
    Connection.Instance:send(10707, {battle_id = battle_id, id = id})
end

function CombatManager:Send10706()
    -- print("退出观战")
    self.lastCombatType = 1
    Connection.Instance:send(10706, {})
end

function CombatManager:On10710(data)
    -- print("收到10710")
    -- BaseUtils.dump(data, "10710")
    self.isFighting = true
    self.combatType = data.combat_type
    RoleManager.Instance.RoleData.status = RoleEumn.Status.Fight
    RoleManager.Instance.RoleData.status = RoleEumn.Status.Fight
    SoundManager.Instance:PlayBGM(404)
    self.isWatching = data.enter_type == 2
    self.isWatchRecorder = data.enter_type == 3
    EventMgr.Instance:Fire(event_name.begin_fight, data.combat_type)
    local fighterList = data.fighter_list
    for _, fdata in ipairs(fighterList) do
        if fdata.group == 0 then
            self:ChangeFighterPos(data.atk_formation, data.atk_formation_lev, fdata, data.dfd_formation, data.dfd_formation_lev)
        else
            self:ChangeFighterPos(data.dfd_formation, data.dfd_formation_lev, fdata, data.atk_formation, data.atk_formation_lev)
        end
    end
    self.enterData = data
    if DataBuff.data_transform_combat_type[self.combatType] == nil then
        self:ProcessingLooksBuffData(self.enterData.fighter_list)
    end

    self.isAutoFighting = data.is_auto == 1
    -- print("直接进去")
    self:GotoCombatScene(data.start_time)
    Connection.Instance:OpenCachSend()

end

function CombatManager:On10711(data)
    -- print("On10711")
    -- BaseUtils.dump(data,"<color='#FF0000'>重新进入</color>")
    -- if data.result == 0 and self.isFighting and self.controller ~= nil then
    --     self.controller:EndOfCombat()
    -- end
end
-- 请求重进战斗
function CombatManager:Send10711()
    if self.isFighting and self.controller ~= nil then
        Connection.Instance:CloseCach(nil, true)
        Connection.Instance:CloseCachSend()
        self.controller:EndOfCombat()
        LuaTimer.Add(1500, function() Connection.Instance:send(10711, {}) end)
    else
        Connection.Instance:CloseCach(nil, true)
        Connection.Instance:CloseCachSend()
        if self.controller ~= nil then
            self.controller:EndOfCombat()
        end
        LuaTimer.Add(1500, function() Connection.Instance:send(10711, {}) end)
    end
end


function CombatManager:On10720(data)
    -- print("收到10720")
    -- BaseUtils.dump(data, "10720")
    if self.enterData == nil or self.enterData.start_time < data.start_time then
        print(string.format("有没有进战斗：%s", tostring(LoginManager.Instance.has_login)))
        if LoginManager.Instance.has_login then
            self:Send10711()
        elseif self.controller ~= nil then
            self.controller:EndOfCombat()
        end
        return
    elseif self.enterData.start_time > data.start_time then
        return
    end
    if self.controller ~= nil and self.isFighting and self.controller.SceneLoaded then
        local summonList = data.summon_play_list

        for _, sdata in ipairs(summonList) do
            local flist = sdata.summons
            if DataBuff.data_transform_combat_type[self.combatType] == nil then
                self:ProcessingLooksBuffData(flist)
            end
            for _, fdata in ipairs(flist) do
                if fdata.group == 0 then
                    self:ChangeFighterPos(self.enterData.atk_formation, self.enterData.atk_formation_lev, fdata, self.enterData.dfd_formation, self.enterData.dfd_formation_lev)
                else
                    self:ChangeFighterPos(self.enterData.dfd_formation, self.enterData.dfd_formation_lev, fdata, self.enterData.atk_formation, self.enterData.atk_formation_lev)
                end
            end
        end
        local eastList = self.controller.eastFighterList
        local westList = self.controller.westFighterList
        self.controller.mainPanel:SetPreparing(false, eastList)
        self.controller.mainPanel:SetPreparing(false, westList)

        self.controller.mainPanel:OnFighting()
        self.controller:OnFighting(data)
        -- 分离出选招数据
        local dataSelectSkill = self.controller:BuildSelectSkillData(data)
        dataSelectSkill.round = data.round+1 -- 10720选招当前回合数加一
        dataSelectSkill.combat_result = data.combat_result
        -- print("Manager的10733")
        self.controller.mainPanel:OnBeginFighting(dataSelectSkill)
    -- elseif self.isFighting then -- 进了战斗没加载完
    --     self.controller.brocastCtx:SetNextBrocastData(data)
    elseif self.loadFinish then -- 加载完了，没进入战斗，收到选找通知
        self:OnMainUiLoaded()
    else
        print(TI18N("由于某种原因未加载完战斗场景，请稍等"..tostring(self.loadFinish)))
    end

    EventMgr.Instance:Fire(event_name.fight_change, data)
end

function CombatManager:On10721(data)
    -- print("收到10721")
    if self.isFighting then
        self.controller:PlayBuff(data)
    end
end

-- 特殊事件播报
function CombatManager:On10722(data)
    print("收到10722")
    if self.isFighting and self.controller ~= nil then
        self.controller:PlaySpecial(data)
    end
end

-- 特殊事件播报
function CombatManager:On10723(data)
    print("收到10723")
    -- BaseUtils.dump(data)
    if self.isFighting then
        self.controller:PlaySpecial(data)
        -- if self.isWatchRecorder then
        --     self:Send10745()
        -- end
    end
end

function CombatManager:Send10730()
    Connection.Instance:send(10730, {})
end


-- 确认自动选找
function CombatManager:Send10731(round)
    -- print("发送确认请求")
    if self.isWatching or self.isWatchRecorder then
        return
    end
    Connection.Instance:send(10731, {round = round})
end

function CombatManager:On10732(data)
    -- print("收到10732")
    if self.isFighting then
        self.controller.mainPanel:OnSelectedSkill(data)
    end
end
function CombatManager:Send10732(skillId, TargetId, OtherId)
    local currT = Time.time
    if currT - self.roleSelectSkillTime < 0.5 then
        self.controller.mainPanel:OnSkillSelectedResult({id = self.controller.selfData.id, result = 0, msg = ""})
        return
    end
    self.roleSelectSkillTime = currT
    Connection.Instance:send(10732, {skill_id = skillId, target_id = TargetId, other_id = OtherId})
    self:On10732({result = 1, msg = "", id = self.controller.selfData.id})

if LoginManager.Instance.isWhiteList then
    if self.controller ~= nil and self.controller.brocastCtx ~= nil then
        local fighter = self.controller.brocastCtx:FindFighter(TargetId)
        if fighter ~= nil and fighter.fighterData ~= nil then
            local msg = string.format("玩家选招，目标名字：%s", fighter.fighterData.name)
            NoticeManager.Instance:FloatTipsByString(msg)
        end
    end
end
end

-- 通知玩家选招情况
function CombatManager:On10733(data)
    print("收到10733")
    BaseUtils.dump(data, "On10733")
    self.roleSelectSkillTime = 0
    if self.isFighting and self.controller ~= nil and self.controller.SceneLoaded then
        self.controller.mainPanel:OnSkillSelectedResult(data)
    elseif self.loadFinish then -- 加载完了，没进入战斗，收到选找通知
        if self.cacheData ~= nil then
            self.enterData = self.cacheData
            self.cacheData = nil
            Log.Debug("收到选招而进入战斗")
            self:GotoCombatScene(self.enterData.start_time)
        end
    else
        print("没进入战斗，收到选招通知")
    end
end

-- 宠物选招
function CombatManager:On10734(data)
    print("收到10734")
    self.petSelectSkillTime = 0
end
function CombatManager:Send10734(skillId, TargetId, OtherId)
    local currT = Time.time
    if currT - self.petSelectSkillTime < 0.5 then
        return
    end
    self.petSelectSkillTime = currT
    Connection.Instance:send(10734, {skill_id = skillId, target_id = TargetId, other_id = OtherId})

if LoginManager.Instance.isWhiteList then
    if self.controller ~= nil and self.controller.brocastCtx ~= nil then
        local fighter = self.controller.brocastCtx:FindFighter(TargetId)
        if fighter ~= nil and fighter.fighterData ~= nil then
            local msg = string.format("宠物选招，目标名字：%s", fighter.fighterData.name)
            NoticeManager.Instance:FloatTipsByString(msg)
        end
    end
end
end

-- 重新选招
function CombatManager:On10735(data)
    print("收到10735")
    -- BaseUtils.dump(data, "10735")
    -- if data.result == 0 then
    --     self:On10732({result = 0, msg = "", id = self.controller.selfData.id})
    -- end
    if data.result == 0 and (data.id == self.controller.selfData.id or data.id == (self.controller.selfPetData or {}).id) then
        if self.controller ~= nil then
            self.controller.mainPanel:ReSelectSkill(data)
        end
    end
    self.controller.mainPanel:OnSkillSelectedResult(data)
end
function CombatManager:Send10735()
    print("请求重选技能")
    Connection.Instance:send(10735, {})
end


function CombatManager:On10740(data)
    -- print("收到10740")
    -- BaseUtils.dump(data)
    if self.isFighting and self.controller ~= nil then
        self.controller.mainPanel:OnAutoSetting(data)
    end
end

--- 发送指挥
function CombatManager:Send10741(target_id, preside_type)
    Connection.Instance:send(10741, {target_id = target_id, preside_type = preside_type})
end
-- 发送指挥返回
function CombatManager:On10741(data)
end

function CombatManager:Send10742()
    Connection.Instance:send(10742, {})
end

function CombatManager:On10742(data)
    -- BaseUtils.dump(data)
    self.self_preside = data.self_preside
    self.target_preside = data.target_preside
    self.OnCmdChangeEvent:Fire()
end

function CombatManager:Send10743(type, flag, text)
    Connection.Instance:send(10743, {type = type, flag = flag, text = text})
end

function CombatManager:On10743(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    -- BaseUtils.dump(data)
end
-- 发起切磋
function CombatManager:Send10760(_rid, _platform, _zone_id)
    if not BaseUtils.IsTheSamePlatform(_platform, _zone_id) and RoleManager.Instance.RoleData.cross_type ~= 1 then
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureLabel = TI18N("进入跨服")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.content = TI18N("该玩家不是本服玩家，是否<color='#ffff00'>进入跨服区</color>发送切磋邀请？?")
        local cb = function()
            RoleManager.Instance.jump_over_call = function() Connection.Instance:send(10760, {rid = _rid, platform = _platform, zone_id = _zone_id}) end
            SceneManager.Instance.enterCenter()
        end
        confirmData.sureCallback = cb

        NoticeManager.Instance:ConfirmTips(confirmData)
    else
        Connection.Instance:send(10760, {rid = _rid, platform = _platform, zone_id = _zone_id})
    end
end
function CombatManager:On10760(data)
    NoticeManager.Instance:FloatTipsByString(TI18N(data.msg))
end

-- 收到切磋
function CombatManager:On10761(data)
    --不接收陌生人切磋邀请
    print(SettingManager.Instance:GetResult(SettingManager.Instance.TRefusingStrangers))
    if SettingManager.Instance:GetResult(SettingManager.Instance.TRefusingStrangers) and not FriendManager.Instance:IsFriend(data.rid, data.platform, data.zone_id) then
        return
    end

    if SceneManager.Instance.sceneElementsModel:IsOnArena(SceneManager.Instance.sceneElementsModel.self_view) then
        self:Send10762(data.rid, data.platform, data.zone_id, 1, data.type)
    else
        local accept = function ()
            self:Send10762(data.rid, data.platform, data.zone_id, 1, data.type)
        end
        local reject = function ()
            -- self:Send10762(data.rid, data.platform, data.zone_id, 0, data.type)
            if not FriendManager.Instance:IsFriend(data.rid, data.platform, data.zone_id) then
                NoticeManager.Instance:FloatTipsByString(TI18N("可前往[设置-不接收陌生人邀请]{face_1,2}"))
            end
        end
        local d = NoticeConfirmData.New()
        d.type = ConfirmData.Style.Normal
        if data.type == 1 then
            d.content = string.format(TI18N("玩家<color='#ffff00'>%s</color>邀请你前往<color='#ffff00'>［跨服］</color>擂台进行切磋比试"), tostring(data.name))
        elseif data.type == 0 then
            d.content = string.format(TI18N("玩家<color='#ffff00'>%s</color>邀请你前往擂台进行切磋比试"), tostring(data.name))
        end
        d.sureLabel = TI18N("接受")
        d.cancelLabel = TI18N("拒绝")
        d.sureCallback = accept
        d.cancelCallback = reject
        NoticeManager.Instance:ConfirmTips(d)
    end
end

-- 回应切磋
function CombatManager:Send10762(_rid, _platform, _zone_id, _flag, type)
    Connection.Instance:send(10762, {rid = _rid, platform = _platform, zone_id = _zone_id, flag = _flag, type = type})
end
function CombatManager:On10762(data)
    print(data.msg)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function CombatManager:Send10769(msg, round)
print("Send10769"..msg)
    Connection.Instance:send(10769, {msg = msg, type = self.currRecData.type, rec_id = self.currRecData.rec_id, platform = self.currRecData.platform, zone_id = self.currRecData.zone_id, round = round})
end

-- 发送弹幕
function CombatManager:On10769(data)
    BaseUtils.dump(dat, "On10769")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    EventMgr.Instance:Fire(event_name.combat_danmaku_cd)
end
-- 战斗弹幕
function CombatManager:On10770(data)
    BaseUtils.dump(data, "战斗弹幕")
    if self.isFighting or self.isWatching then
        self.danmakuPool = data.combat_record_chat_mgr
        self.danmakuHistory = {}
        if self.danmakuTimer ~= nil then
            LuaTimer.Delete(self.danmakuTimer)
            self.danmakuTimer = nil
        end
        self.danmakuTimer = LuaTimer.Add(0, 3000, function()
            if next(self.danmakuPool) ~= nil and self.isFighting then
                local item = table.remove(self.danmakuPool)
                DanmakuManager.Instance:AddNewMsg(item.msg)
                item.channel = MsgEumn.ChatChannel.Danmaku
                item.msgData = {}
                item.roleid = item.rid
                -- item.platform = item.platform
                -- item.zone_id = item.zone_id
                item.msgData.showString = item.msg
                table.insert(self.danmakuHistory, item)
                self.OnDanmakuPoolChange:Fire()
            else
                return false
            end
        end)

    end
end

function CombatManager:Send10771(skill_id, target_id, other_id)
    -- print(string.format("Send10771 %s, %s, %s", skill_id, target_id, other_id))
    local currT = Time.time
    if currT - self.roleSelectSkillTime < 0.5 then
        self.controller.mainPanel:OnSkillSelectedResult({id = self.controller.selfData.id, result = 0, msg = ""})
        return
    end
    self.roleSelectSkillTime = currT
    Connection.Instance:send(10771, { skill_id = skill_id, target_id = target_id, other_id = other_id })
end

function CombatManager:On10771(data)
    -- BaseUtils.dump(data, "On10771")
    NoticeManager.Instance:FloatTipsByString(data.msg)

    -- self.roleSelectSkillTime = 0
    -- if self.isFighting and self.controller ~= nil and self.controller.SceneLoaded then
    --     self.controller.mainPanel:OnTalismanSkillSelectedResult(data)
    -- elseif self.loadFinish then -- 加载完了，没进入战斗，收到选找通知
    --     if self.cacheData ~= nil then
    --         self.enterData = self.cacheData
    --         self.cacheData = nil
    --         Log.Debug("收到选招而进入战斗")
    --         self:GotoCombatScene(self.enterData.start_time)
    --     end
    -- else
    --     print("没进入战斗，收到选招通知")
    -- end
end

function CombatManager:Send10772()
    -- print("Send10772")
    Connection.Instance:send(10772, {})
end

function CombatManager:On10772(data)
    -- BaseUtils.dump(data, "On10772")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CombatManager:Send10773(skill_id, target_id, other_id)
    -- print(string.format("Send10773 %s, %s, %s", skill_id, target_id, other_id))
    local currT = Time.time
    if currT - self.petSelectSkillTime < 0.5 then
        return
    end
    self.petSelectSkillTime = currT
    Connection.Instance:send(10773, { skill_id = skill_id, target_id = target_id, other_id = other_id })



    -- self:On10733({
    --         id = self.controller.selfPetData.id
    --         ,result = 1
    --         ,target_id = target_id
    --         ,skill_id = skill_id
    --         ,skill_lev = 1
    --     })
end

function CombatManager:On10773(data)
    -- BaseUtils.dump(data, "On10773")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CombatManager:Send10774()
    -- print("Send10774")
    Connection.Instance:send(10774, {})
end

function CombatManager:On10774(data)
    -- BaseUtils.dump(data, "On10774")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CombatManager:Send10740(flag)
    Connection.Instance:send(10740, {flag = flag})
end

function CombatManager:Send10775()
    -- print("Send10775")
    Connection.Instance:send(10775, {})
end

function CombatManager:On10775(data)
    BaseUtils.dump(data, "On10775")
    for i,v in ipairs(data.help_combat_info) do
        local combatHelpSkillData = self.combatHelpSkillData[v.skill_id]
        if combatHelpSkillData == nil then
            combatHelpSkillData = { skill_id = v.skill_id, times = v.times, skill_status = v.skill_status, my_skill_status = 0, round = data.round }
            self.combatHelpSkillData[v.skill_id] = combatHelpSkillData
        else
            combatHelpSkillData.times = v.times
            combatHelpSkillData.skill_status = v.skill_status
            combatHelpSkillData.round = data.round
        end
    end
    EventMgr.Instance:Fire(event_name.combat_watch_skill, "Update")
end

function CombatManager:Send10776()
    -- print("Send10776")
    Connection.Instance:send(10776, {})
end

function CombatManager:On10776(data)
    BaseUtils.dump(data, "On10776")
    for i,v in ipairs(data.observer_skill_cd) do
        local combatHelpSkillData = self.combatHelpSkillData[v.skill_id]
        if combatHelpSkillData == nil then
            combatHelpSkillData = { skill_id = v.skill_id, times = 0, skill_status = 0, my_skill_status = v.skill_status, round = 1 }
            self.combatHelpSkillData[v.skill_id] = combatHelpSkillData
        else
            combatHelpSkillData.my_skill_status = v.skill_status
        end
    end
    EventMgr.Instance:Fire(event_name.combat_watch_skill, "Update")
end

function CombatManager:Send10777(skill_id)
    -- print("Send10777")
    Connection.Instance:send(10777, { skill_id = skill_id })
end

function CombatManager:On10777(data)
    -- BaseUtils.dump(data, "On10777")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        EventMgr.Instance:Fire(event_name.combat_watch_skill, "SkillUseSuccess")
    end
end

function CombatManager:On10778(data)
    -- BaseUtils.dump(data, "On10778")
    -- data.reward = {
    --     { reward_id = 1, id = 2, type = 1, end_time = 30 + BaseUtils.BASE_TIME }
    --     , { reward_id = 2, id = 2, type = 2, end_time = 30 + BaseUtils.BASE_TIME }
    --     , { reward_id = 3, id = 2, type = 3, end_time = 30 + BaseUtils.BASE_TIME }
    -- }

    if self.controller ~= nil and self.controller.mainPanel ~= nil and self.controller.mainPanel.mixPanel ~= nil then
        self.controller.mainPanel.mixPanel:ShowWatchRewardItem(data.reward)
    end
end

function CombatManager:Send10779(combat_type, reward_id)
    -- print("Send10779")
    Connection.Instance:send(10779, { combat_type = combat_type, reward_id = reward_id })
end

function CombatManager:On10779(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CombatManager:On10780(data)
    BaseUtils.dump(data, "On10780")
    self.WatchLogmodel.watchRewardTime = data.end_time
    if self.controller ~= nil and self.controller.mainPanel ~= nil and self.controller.mainPanel.mixPanel ~= nil then
        self.controller.mainPanel.mixPanel:ShowWatchRewardItem()
    end
end

-- 战斗结束预告
function CombatManager:On10789(data)
    -- BaseUtils.dump(data, "战斗结束预告")
    if self.isFighting and self.controller ~= nil then
        Connection.Instance:OpenCach()
    end
    if self.controller ~= nil then
        self.controller.fightResult = data.result
        if self.controller.brocastCtx ~= nil then
            self.controller.brocastCtx.islastRound = true
        end
        if self.isBrocasting == false then
            self.controller:EndOfCombat()
        end
    end
end


-- 战斗结束
function CombatManager:On10790(data)
    -- print("战斗结果:" .. (data.result == 1 and "胜利" or "失败").."类型："..tostring(self.combatType))
    -- scene_manager:JumpToScene("Normal")
    -- Application.LoadLevel("Normal")
    EventMgr.Instance:Fire(event_name.server_end_fight, self.combatType, data.result)
    if (data.msg ~= nil and data.msg ~= "") then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end

    if data.result == 0 and CombatUtil.ShowFailedType[self.combatType] ~= nil then
        if self.failedWin == nil then
            self.failedWin = CombatFailedWindow.New(self)
        end
        self.failedWin:Open()
        -- inserted by 嘉俊 当战斗失败时停止自动历练和自动职业任务
        print("战斗失败导致自动停止") -- 输出信息找bug
        AutoQuestManager.Instance.disabledAutoQuest:Fire()
        -- end by 嘉俊
    end
    if self.controller == nil or self.isFighting == false then return end
    self.controller.fightResult = data.result
    if self.controller ~= nil then
        self.controller.brocastCtx.islastRound = true
        if self.isBrocasting == false then
            self.controller:EndOfCombat()
        end
        -- self.controller:OnEndFighting(data.result, data.msg, data.gl_list)
    end
end

--战斗录像
function CombatManager:Send10744(type, rec_id, platform, zone_id)
    if (self.isWatchRecorder or self.isWatching)and self.isFighting then
        NoticeManager.Instance:FloatTipsByString(TI18N("正在在观看中"))
        return
    end
    local _platform = platform ~= nil and platform or RoleManager.Instance.RoleData.platform
    local _zone_id = zone_id ~= nil and zone_id or RoleManager.Instance.RoleData.zone_id
    self.currRecData = {type = type, rec_id = rec_id, platform = _platform, zone_id = _zone_id}
    Connection.Instance:send(10744, {type = type, rec_id = rec_id, platform = _platform, zone_id = _zone_id})
end

function CombatManager:On10744(data)
    if data.result == 1 then
        -- WorldBossManager.Instance.model:CloseWorldBossRankUI()
    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
--录像下回合
function CombatManager:Send10745()
    if self.controller.brocastCtx.nextbrocastData ~= nil then
        return
    end
    Connection.Instance:send(10745, {})
end

function CombatManager:Send10746()
    self.isFighting = false
    self.lastCombatType = 2
    Connection.Instance:send(10746, {})
end

--最近录像
function CombatManager:Send10747()
    print("-=--------------发送10747")
    Connection.Instance:send(10747, {})
end

function CombatManager:On10747(data)
    -- print("-----------------------ddddd==========10747")
    -- BaseUtils.dump(data, "最近录像")
    self.WatchLogmodel.currList = data.list
    table.sort( self.WatchLogmodel.keepList, function(a,b)
        return a.time > b.time
    end )
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
    self.OnCurrLogChange:Fire()
end

--收藏录像
function CombatManager:Send10748()
    print("-=--------------发送10748")
    Connection.Instance:send(10748, {})
end

function CombatManager:On10748(data)
    -- BaseUtils.dump(data, "收藏录像")
    self.WatchLogmodel.keepList = data.list
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
    table.sort( self.WatchLogmodel.keepList, function(a,b)
        return a.time > b.time
    end )
    self.OnKeepLogChange:Fire()
end

--精彩录像
function CombatManager:Send10749()
    -- print("<color='#00ff00'>Send10749</color>")
    Connection.Instance:send(10749, {})
end

function CombatManager:On10749(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>精彩录像</color>")
    self.WatchLogmodel.goodList = data.list
    table.sort( self.WatchLogmodel.goodList, function(a,b)
        return a.time > b.time
    end )
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
    self.OnGoodLogChange:Fire()
end


function CombatManager:Send10750(type, id, platform, zone_id)
    -- BaseUtils.dump({type = type, id = id, platform = platform, zone_id = zone_id}, "收藏录像@@@@")
    Connection.Instance:send(10750, {type = type, id = id, platform = platform, zone_id = zone_id})
end

function CombatManager:On10750(data)
    -- BaseUtils.dump(data, "keep")
    if data.result == 1 then
        self:Send10748()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CombatManager:Send10751(type, id, platform, zone_id)
-- BaseUtils.dump({type = type, id = id, platform = platform, zone_id = zone_id}, "取消收藏录像@@@@")
    Connection.Instance:send(10751, {type = type, id = id, platform = platform, zone_id = zone_id})
end

function CombatManager:On10751(data)
    if data.result == 1 then
        self:Send10748()
    end
    -- BaseUtils.dump(data, "unkeep")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CombatManager:Send10752(type, id, platform, zone_id)
-- BaseUtils.dump({type = type, id = id, platform = platform, zone_id = zone_id}, "喜欢录像@@@@")
    Connection.Instance:send(10752, {type = type, id = id, platform = platform, zone_id = zone_id})
end

function CombatManager:On10752(data)
    if data.result == 1 then
        self:Send10747()
        self:Send10748()
        self:Send10749()
        self.OnLikeChange:Fire()
    end
    -- BaseUtils.dump(data, "喜欢录像")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--请求单个录像详细信息
function CombatManager:Send10753(_type, id, platform, zone_id)
-- BaseUtils.dump({type = _type, id = id, platform = platform, zone_id = zone_id}, "详细录像@@@@  Send10753")
    self.vedioDataRecord = {type = _type, id = id, platform = platform, zone_id = zone_id}
    Connection.Instance:send(10753, self.vedioDataRecord)
end

--录像战斗结束调用
function CombatManager:OpenLittleVedioPanel()
    if self.isWatchRecorder then
        if self.vedioDataRecord ~= nil then
            self:Send10753(self.vedioDataRecord.type, self.vedioDataRecord.id, self.vedioDataRecord.platform, self.vedioDataRecord.zone_id)
        end
    end
    self.vedioDataRecord = nil
end

function CombatManager:On10753(data)
    -- print("------------------------ddddddddddddddddddddddddddd")
    -- BaseUtils.dump(data, "On10753")
    self.WatchLogmodel:OpenViewPanel(data)
end

--查看热榜
function CombatManager:Send10754(rank_type)
    Connection.Instance:send(10754, {rank_type = rank_type}) --"1周热门，2历史热门"
end

--查看热榜
function CombatManager:On10754(data)
    print("============sdfjiosdjio===========收到10754")
    -- BaseUtils.dump(data, "热门录像")
    self.WatchLogmodel.hotList = data.list
    table.sort( self.WatchLogmodel.hotList, function(a,b)
        local aScore = a.liked*20 + a.shared*10 + a.replayed
        local bScore = b.liked*20 + b.shared*10 + b.replayed
        return aScore > bScore
    end )
    self.OnHotLogChange:Fire(data.rank_type)
end

--查看首杀
function CombatManager:Send10755(rank_type)
    print("-------------------------发送10755")
    print(rank_type)
    Connection.Instance:send(10755, {type = rank_type}) --"1boss首杀，3爵位首杀，14星座首杀"}
end

--查看首杀
function CombatManager:On10755(data)

    print("---------------收到-------10755")
    BaseUtils.dump(data)
    self.WatchLogmodel.firstKillList = data.list
    table.sort( self.WatchLogmodel.firstKillList, function(a,b)
        return a.time > b.time
    end )
    self.OnFirstKillChange:Fire()
end

--记录分享次数
function CombatManager:Send10756(type, rec_id, platform, zone_id)
    print("-------------------------发送10756")
    Connection.Instance:send(10756, {type = type, rec_id = rec_id, platform = platform, zone_id = zone_id})
end

--记录分享次数
function CombatManager:On10756(data)
    print("-------------------------收到10756")
    -- BaseUtils.dump(data, "记录分享次数")
    if data.result == 1 then

    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


--点赞信息
function CombatManager:Send10757()
    print("-------------------------发送10757")
    Connection.Instance:send(10757, {})
end

--点赞信息
function CombatManager:On10757(data)
    -- BaseUtils.dump(data, "点赞信息")
    self.WatchLogmodel.zanData = data
    self.OnZanChange:Fire()
    -- {uint32, online, "在线秒数"}
    -- {uint32, liked, "点赞次数"}
end

--查看精彩录像跨服
function CombatManager:Send10758(combat_type)
    print("-------------------------发送10758")
    Connection.Instance:send(10758, {combat_type = combat_type})
end

--查看精彩录像跨服
function CombatManager:On10758(data)
    BaseUtils.dump(data, "精彩录像跨服")
    self.WatchLogmodel.kuafuGoodList[data.combat_type] = data.list
    table.sort(self.WatchLogmodel.kuafuGoodList[data.combat_type], function(a,b)
        return a.time > b.time
    end )
    self.OnKuafuGoodChange:Fire(data.combat_type)
end


--系统录像统计
function CombatManager:Send10759()
    print("-------------------------发送10759")
    Connection.Instance:send(10759, {})
end

--系统录像统计
function CombatManager:On10759(data)
    print("------------------------------------收到10759")
    self.WatchLogmodel.recordList = data.list
    self.OnRecordListChange:Fire()
end

------------------------------------------------------------------------------------------------------------------------------------------------

function CombatManager:OnCombatTest()
    -- Connection.Instance:send(9900, {cmd = "打自己"})
    -- Connection.Instance:send(9900, {cmd = "打群架"})
    Connection.Instance:send(9900, {cmd = "击杀NPC 99999"})
    -- Connection.Instance:send(9900, {cmd = TI18N("击杀NPC 99997")})
    -- Connection.Instance:send(9900, {cmd = "获取物品 21400"})
    -- Connection.Instance:send(9900, {cmd = "获取物品 21401"})
    -- Connection.Instance:send(9900, {cmd = "获取物品 21406"})
    -- Connection.Instance:send(9900, {cmd = "获取物品 21407"})
    -- Connection.Instance:send(9900, {cmd = "击杀NPC 99994"})
end

function CombatManager:OnCombatTestSkill()
    Connection.Instance:send(9900, {cmd = TI18N("技能")})
end

function CombatManager:OnSceneLoaded()
    if SceneManager.Instance.sceneModel.map_loading == false and SceneManager.Instance.sceneModel.map_data_cache == nil and self.cacheData ~= nil then
        if self.cacheData ~= nil then
            self.enterData = self.cacheData
            self.cacheData = nil
            Log.Debug("场景加载完进入战斗")
            LuaTimer.Add(5000,function () self:GotoCombatScene(self.enterData.start_time) end)
        end
    end
end

function CombatManager:OnMainUiLoaded()
    self.loadFinish = true
    if self.cacheData ~= nil then
        self.enterData = self.cacheData
        self.cacheData = nil
        self:GotoCombatScene(self.enterData.start_time)
        -- print("UI加载完")
    else
        self:Send10711()
    end
end

function CombatManager:GotoCombatScene(combatID, delay)
    if self.Creating and Time.time < self.lastEnterTime + 5 then
        return
    elseif self.controller ~= nil and self.controller.combatID ~= nil and self.controller.combatID == combatID and self.controller.isdestroying == false then
        self.Creating = false
        return
    elseif self.controller ~= nil and self.controller.SceneLoaded then
        self.controller:EndOfCombat()
        if not delay then
            LuaTimer.Add(600, function()
                self:GotoCombatScene(combatID, true)
            end)
        end
        return
    elseif MainUIManager.Instance.MainUIIconView == nil or BaseUtils.isnull(MainUIManager.Instance.MainUIIconView.gameObject) then
        if not delay then
            LuaTimer.Add(2000, function()
                self:GotoCombatScene(combatID, true)
            end)
        end
        return
    end
    self.Creating = true
    self.lastEnterTime = Time.time
    -- Log.Info("调用进入战斗场景")
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:showbaseicon(true)
        MainUIManager.Instance.MainUIIconView:hidebaseicon4()
    else
        LuaTimer.Add(1000, function()
            if MainUIManager.Instance.MainUIIconView ~= nil then
                MainUIManager.Instance.MainUIIconView:showbaseicon(true)
                MainUIManager.Instance.MainUIIconView:hidebaseicon4()
            end
        end)
    end
    if self.controller ~= nil and self.controller.combatID ~= nil and self.controller.combatID ~= combatID and self.controller.isdestroying == false then
        self.controller:EndOfCombat()
    end
    local callback = function()
        if self.controller == nil then
            self.controller = CombatController.New(combatID)
        else
            if self.controller.combatID ~= nil and self.controller.combatID == combatID and self.controller.isdestroying == false then
                self.Creating = false
                return
            else
                LuaTimer.Add(10, function()
                    self.controller:Show(combatID)
                end)
            end
        end
        self.Creating = false
    end
    self.resList = {}
    for _, data in ipairs(CombatUtil.startResources) do
        table.insert(self.resList, data)
    end
    self.mapPath = CombatUtil.GetMapPath(self.enterData.combat_type)
    table.insert(self.resList, {file = self.mapPath, type = CombatAssetType.Main, holdTime = BaseUtils.DefaultHoldTime()})
    -- table.insert(self.resList, {file = BaseUtils.SkillIconPath(), type = CombatAssetType.Dep, holdTime = BaseUtils.DefaultHoldTime()})
    table.insert(self.resList, {file = AssetConfig.normalbufficon, type = CombatAssetType.Dep, holdTime = BaseUtils.DefaultHoldTime()})
    if self.assetWrapper == nil then
        self.assetWrapper = AssetBatchWrapper.New()
    elseif self.assetWrapper ~= nil then
        local lastAssetWrapper = self.assetWrapper
        self.assetWrapper = nil
        self.assetWrapper = AssetBatchWrapper.New()
        xpcall(function() LuaTimer.Add(1000, function() lastAssetWrapper:DeleteMe() end) end,
                function() Log.Error(debug.traceback()) end )
    end
    xpcall(function() self.assetWrapper:LoadAssetBundle(self.resList, callback) end,
            function() self.Creating = false Log.Error(debug.traceback()) end )
    -- self.assetWrapper:LoadAssetBundle(self.resList, callback)
end

function CombatManager:ChangeFighterPos(formationId, lev, fighterData, anotherformation, anotherlev)
    local formationData = self:GetFormation(formationId, lev)
    local another_formationData = self:GetFormation(anotherformation, anotherlev)
    if formationData == nil then
        fighterData.formation_pos = fighterData.pos
        return fighterData
    end
    local pos = fighterData.pos
    local needanother = false
    for k,v in pairs(fighterData.looks) do
        if v.looks_type == 72 then
            pos = v.looks_val
            needanother = true
        end
    end
        local list = formationData.pos_desc
        if needanother then
            list = another_formationData.pos_desc
        end
        local newPos = pos
        for _, pdata in ipairs(list) do
            if pdata[1] == pos then
                -- if pdata[2] > 5 then
                --     newPos = pdata[2] + 5
                -- else
                    newPos = pdata[2]
                -- end
                break
            end
        end
        fighterData.formation_pos = newPos
        -- fighterData.pos = newPos
        return fighterData
    -- end
end

function CombatManager:DoFireEndFight(result)
    if self.FireEndFightScene then--and self.FireEndFightBroad then
        RoleManager.Instance.RoleData.status = RoleEumn.Status.Normal
        EventMgr.Instance:Fire(event_name.end_fight, self.enterData.combat_type, result)
    end
end
---------------------------------------------------------------------
-- 获取基础数据
---------------------------------------------------------------------
function CombatManager:GetCombatSkillObject(skillId, skillLev, classes)
    local key = CombatUtil.Key(skillId, skillLev)
    local baseSkillData = DataSkill.data_skill_role[key]
    if baseSkillData == nil then
        baseSkillData = DataSkill.data_petSkill[key]
    end
    if baseSkillData == nil then
        baseSkillData = DataSkill.data_wing_skill[key]
    end
    if baseSkillData == nil then
        baseSkillData = DataSkill.data_marry_skill[key]
    end
    local combatSkill = DataCombatSkill.data_combat_skill[key]
    if (combatSkill == nil) then
        if skillId == 1000 then
            combatSkill = CombatUtil.GetDefaultCombatSkillObject(skillId, skillLev, TI18N("普攻"))
        elseif skillId == 2000 then
            combatSkill = CombatUtil.GetDefaultCombatSkillObject(skillId, skillLev, TI18N("施法"))
            combatSkill.attack_type = 1
        elseif skillId == 1003 or skillId == 60126 then
            combatSkill = CombatUtil.GetDefaultCombatSkillObject(skillId, skillLev, TI18N("保护"))
            combatSkill.target_type = SkillTargetType.SelfGroup
        elseif skillId == 1004 then
            combatSkill = CombatUtil.GetDefaultCombatSkillObject(skillId, skillLev, TI18N("使用物品"))
            combatSkill.target_type = SkillTargetType.SelfGroup
            combatSkill.attack_type = 1
            if classes ~= nil then
                local motionId = CombatUtil.GetNormalSKillMotion(classes)
                combatSkill.motion_id = {motionId}
            end
        elseif skillId == 1006 then
            combatSkill = CombatUtil.GetDefaultCombatSkillObject(skillId, skillLev, TI18N("捕宠"))
            combatSkill.target_type = SkillTargetType.Enemy
        end
        if baseSkillData ~= nil then
            combatSkill.icon = baseSkillData.icon
        end
        return combatSkill
    else
        if baseSkillData ~= nil then
            combatSkill.icon = baseSkillData.icon
        end
        return combatSkill
    end
end

function CombatManager:GetMotionEventData(motionId, modelId)
    local key = CombatUtil.Key(motionId, modelId)
    local data = DataMotionEvent.data_motion_event[key]
    if data ~= nil then
        return data
    else
        if motionId == 1000 then
            data = CombatUtil.GetDefaultMotionEvent(motionId, modelId)
            data.total = 700
            data.hit_time = 300
            data.multi_time =300
            data.soundcfg = {{sound_id0 = 0,sound_id1 = 0}}
            return data
        else
            return nil
        end
    end
end

function CombatManager:GetSkillEffectList(skillId, motionId)
    local key = CombatUtil.Key(skillId, motionId)
    -- local skillEffectList = self.skillEffectDict[key]
    local skillEffectList = DataSkillEffect.data_skill_effect[key]
    return skillEffectList
end

function CombatManager:GetEffectObject(effectId)
    local effect = DataEffect.data_effect[effectId]
    if effect == nil then
        Log.Error("EffectData表缺少特效信息ID:" .. effectId)
    end
    return effect
end

function CombatManager:GetNpcBaseData(baseId)
    return DataUnit.data_unit[baseId]
end

function CombatManager:GetRoleSkillObject(skillId, skillLev)
    local key = CombatUtil.Key(skillId, skillLev)
    local roleSkill = DataSkill.data_skill_role[key]
    return roleSkill
end

function CombatManager:GetPetBaseData(baseId)
    return DataPet.data_pet[baseId]
end

function CombatManager:GetChildBaseData(baseId)
    return DataChild.data_child[baseId]
end

function CombatManager:GetCombatBuffData(buffId)
    local buffData = DataSkillBuff.data_skill_buff[buffId]
    return buffData
end

function CombatManager:GetAnimationData(animationId)
    local animationData = DataAnimation.data_npc_data[animationId]
    if animationData == nil then
        Log.Error("[战斗]缺少动作基础信息(animation_data):[animation_id:" .. animationId .. "]")
    end
    return animationData
end

function CombatManager:GetGuardBaseData(baseId)
    local data = DataShouhu.data_guard_base_cfg[baseId]
    if data == nil then
        Log.Error("缺少守护基础信息[baseId:" .. baseId .. "]")
    end
    return data
end

function CombatManager:GetPetSkillData(skillId, skillLev)
    local key = CombatUtil.Key(skillId, skillLev)
    local data = DataSkill.data_petSkill[key]
    local combatSkill = DataCombatSkill.data_combat_skill[key]
    if data == nil and skillId == 1000 then
        return {id = 1000, lev = 1, name = TI18N("普攻"), icon = 1000, step = 1, max_exp = 1, desc = TI18N("普攻"), cost_mp = 0}
    else
        if combatSkill ~= nil then
            data.cost_mp = combatSkill.cost_mp
        end
        return data
    end
end

function CombatManager:GetChildSkillData(skillId, skillLev)
    local key = CombatUtil.Key(skillId, skillLev)
    local data = DataSkill.data_child_skill[skillId]
    local combatSkill = DataCombatSkill.data_combat_skill[key]
    if data == nil and skillId == 1000 then
        return {id = 1000, lev = 1, name = TI18N("普攻"), icon = 1000, step = 1, max_exp = 1, desc = TI18N("普攻"), cost_mp = 0}
    else
        if combatSkill ~= nil then
            data.cost_mp = combatSkill.cost_mp
        end
        return data
    end
end

function CombatManager:GetNpcTalkData(baseId, round, motion_type)
    local data = {}
    if self.talkDict[baseId] ~= nil then
        for k,v in pairs(self.talkDict[baseId]) do
            if v.round == round and motion_type == v.type then
                table.insert(data, v)
            end
        end
    end
    return data
end

function CombatManager:GetSoundData(skillId, motionId)
    local key = CombatUtil.Key(skillId, motionId)
    local data = self.soundDict[key]
    return data
end

function CombatManager:GetFormation(formationId, lev)
    local key = CombatUtil.Key(formationId, lev)
    local data = DataFormation.data_list[key]
    return data
end

function CombatManager:FighterResCacheHoldTimeSetting(cacheList)
    for _, data in ipairs(cacheList) do
        if data.group == 1 then
            table.insert(self.SelfResCache, {file = data.file, HoldTime = 130, new = true})
        else
            table.insert(self.EnemyResCache, {file = data.file, holdTime = BaseUtils.DefaultHoldTime(), new = true})
        end
    end

    local sLeave = #self.SelfResCache - 20
    local eLeave = #self.EnemyResCache - 15
    local fileRes = nil
    if sLeave > 0 then
        for i = 1, sLeave do
            fileRes = self.SelfResCache[1]
            table.remove(self.SelfResCache, 1)
            if fileRes.new ~= true then
                ctx.ResourcesManager:SetHoldTime(fileRes.file, 0)
            end
        end
    end
    if eLeave > 0 then
        for i = 1, eLeave do
            fileRes = self.EnemyResCache[1]
            table.remove(self.EnemyResCache, 1)
            if fileRes.new ~= true then
                ctx.ResourcesManager:SetHoldTime(fileRes.file, 0)
            end
        end
    end
    for _, data in ipairs(self.SelfResCache) do
        if data.new == true then
            ctx.ResourcesManager:SetHoldTime(data.file, data.HoldTime)
            data.new = false
        end
    end
    for _, data in ipairs(self.EnemyResCache) do
        if data.new == true then
            ctx.ResourcesManager:SetHoldTime(data.file, data.HoldTime)
            data.new = false
        end
    end
end

function CombatManager:ShowTeamMsg(id, platform, zone_id, msg)
    if self.isFighting and self.controller ~= nil then
        self.controller:ShowMemberMsg(id, platform, zone_id, msg)
    end
end

function CombatManager:GetBuffRes(buff_list)
    local paths = {}
    for k,v in pairs(buff_list) do
        local buffData = self:GetCombatBuffData(v.buff_id)
        if buffData == nil then
            Log.Error("[战斗buff]SkillBuff表中找不到id:" .. v.buff_id)
        else
            local layer = v.layer
            local effectIds = {}
            if layer == 1 then
                effectIds = buffData.effect_ids_layer1
            elseif layer == 2 then
                effectIds = buffData.effect_ids_layer2
            elseif layer == 3 then
                effectIds = buffData.effect_ids_layer3
            end
            for _, effectId in ipairs(effectIds) do
                local  effectData = self:GetEffectObject(effectId)
                if effectData ~= nil then
                    local effectPath = "prefabs/effect/" .. effectData.res_id .. ".unity3d"
                    table.insert(paths,effectPath)
                else
                    Log.Error("[战斗buff]缺少特效配置信息effectId:" .. effectId)
                end
            end
        end
    end
    return paths
end

function CombatManager:OnDisConnect()
    if self.controller ~= nil then
        self.controller:EndOfCombat()
    end
end

function CombatManager:OpenCmdSetting()
    if self.cmdsetting == nil then
        self.cmdsetting = CombatCmdSetPanel.New()
    end
    self.cmdsetting:Show()
end

function CombatManager:CloseCmdSetting()
    if self.cmdsetting ~= nil then
        self.cmdsetting:DeleteMe()
        self.cmdsetting = nil
    end
end

function CombatManager:CloseFailedWind()
    if self.failedWin ~= nil then
        WindowManager.Instance:CloseWindow(self.failedWin)
        self.failedWin = nil
    end
end

function CombatManager:SkipRound()
    if self.RecorderSkip or self.controller.brocastCtx.nextbrocastData ~= nil then
        if self.controller.brocastCtx.nextbrocastData ~= nil then
            self.RecorderSkip = true
        end
        self.skiptimer = Time.time
        NoticeManager.Instance:FloatTipsByString(TI18N("请稍等。。。"))
        return
    end
    if self.skiptimer ~= nil and Time.time - self.skiptimer < 0.5 then
        self.skiptimer = Time.time
        return
    end
    self.skiptimer = Time.time
    self.RecorderSkip = true
    if self.isBrocasting then
        if self.RecorderSkip then
            self.controller:ChangeTransitionAmount(1)
        end
    end
    if self.controller.brocastCtx ~= nil then
        if self.controller.brocastCtx.nextbrocastData == nil then
            CombatManager.Instance:Send10745()
        end
    end
end

function CombatManager:ProcessingLooksBuffData(list)
    for fighterIndex, fighter in ipairs(list) do
        local mark = false
        for looksIndex, looks in ipairs(fighter.looks) do
            if looks.looks_type == SceneConstData.looktype_transform then
                mark = true
                break
            end
        end

        -- if not mark or not SceneManager.Instance.sceneElementsModel.Show_Transform_Mark then
        if not mark then
            for looksIndex, looks in ipairs(fighter.looks) do
                if looks.looks_type == SceneConstData.looktype_transform_buff
                or looks.looks_type == SceneConstData.looks_type_unreal_buff then
                    local transform_data = DataTransform.data_transform[looks.looks_val]
                    if transform_data ~= nil then
                        local specialBuffMark = false
                        for buffIndex, buffInfo in pairs(fighter.buff_infos) do
                            if  buffInfo.special == 1 then
                                specialBuffMark = true
                            end
                        end
                        if not specialBuffMark then
                            local buff_id = transform_data.buff_id
                            local buff_data = { special = 1 -- 特殊战斗buff 1.变身buff
                                                , buff_id = buff_id
                                                , layer = 1
                                                , duration = 0
                                                , duration_left = 0
                                                , can_dispel = 0
                                            }
                            table.insert(fighter.buff_infos, buff_data)
                            break
                        end
                    end
                end
            end
        end
    end
end
