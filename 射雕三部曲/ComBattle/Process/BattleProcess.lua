--[[
    文件名：BattleProcess
    描述：核心战斗流程
    创建人：luoyibo
    创建时间：2016.08.12
-- ]]

local ipairs = ipairs
local pairs = pairs
local next = next
local table_insert = table.insert
local table_remove = table.remove

local BattleProcess = class("BattleProcess", function()
    return bd.func.bindEvent({})
end)


function BattleProcess:ctor(params)
    self.battleLayer = params.battleLayer
    self.battleData  = params.battleData

    -- 正在执行的step数量
    self.runningActionCnt_ = 0
    -- 施法切屏数量
    self.skillingCnt_ = 0
    -- 正在请求的手动技能
    self.requestSkill_ = 0
    -- 等待执行的step
    self.waitingAtom_ = {}
    -- 等待执行的死亡动作
    self.waitingDead_ = {}
    -- 等待执行的重生动作
    self.waitingReborn_ = {}
    -- 暂存手动施法后数据
    self.castSkillData_ = {}
    -- 记录施法成功的位置，用于多人施法切屏
    self.castSuccessPos_ = {}
    -- 记录手动施法的调用数量
    self.castReqCnt_ = 0
    -- 排队施法
    self.castQueue_ = {}

    -- 记录操作数据
    self.records_ = {
        calcVer = require("ComLogic.LogicVersion"),
        sysVer  = SystemVersionNumber.items[1].systemNum,
    }

    -- 死亡中的数量(战斗结束等待死亡特效播放完成)
    self.dyingCnt_ = 0

    self.battleData
        -- 监听主将死亡
        :on(bd.event.eHeroDead, function(posId, data)
            self.dyingCnt_ = self.dyingCnt_ + 1
            if self.waitingDead_[posId] then
                for k, v in ipairs(self.waitingDead_[posId]) do
                    if v == data then
                        table_remove(self.waitingDead_[posId], k)
                        break
                    end
                end
            end
        end)

        -- 监听死亡动作结束
        :on(bd.event.eHeroDeadActionEnd, function(posId, data)
            self.dyingCnt_ = self.dyingCnt_ - 1
        end)


    -- 正在移动的主将(战斗结束等待主将归位)
    self.movingHeroPos_ = {}
    self.battleData
        -- 主将移动开始
        :on(bd.event.eMoveOut, function(posId)
            self.movingHeroPos_[posId] = true
        end)
        -- 主将移动结束
        :on(bd.event.eMoveBack, function(posId)
            self.movingHeroPos_[posId] = nil
        end)

    -- 监听buff
    self.battleData
        -- buff开始
        :on(bd.event.eBuffAdd, function(posId, buffId)
            -- 对应玩家的怒气条变灰
            if buffId == 90050000 or buffId == 90060000 then
                local buffHeroNode = self.battleData:getHeroNode(posId)
                buffHeroNode.bar:setRpVisible(false)
            end
        end)
        -- buff结束
        :on(bd.event.eBuffDel, function(posId, buffId)
            -- 恢复对应玩家的怒气条
            if buffId == 90050000 or buffId == 90060000 then
                local buffHeroNode = self.battleData:getHeroNode(posId)
                buffHeroNode.bar:setRpVisible(true)
            end
        end)
end


-- @战斗开始(BattleLayer中预加载资源后调用)
function BattleProcess:battleBegin()
    bd.log.info(TR("战斗开始"))
    self:emit(bd.event.eBattleBegin)

    local data = self.battleData:getCurrentStageData()
    if data then
        self:stageBegin(data)
    else
        self:battleEnd()
    end
end


-- @战斗结束
function BattleProcess:battleEnd(isSkip)
    if isSkip then
        bd.log.info(TR("跳过战斗"))
    else
        bd.log.info(TR("战斗结束"))
    end
    self.battleData:set_battle_records(self.records_)

    -- 隐藏托管、跳过按钮
    self.battleData:set_ctrl_trustee_viewable(false)
    self.battleData:set_ctrl_skip_clickable(false)

    if (not isSkip) then
        -- 正常结束时，获取最后stage结果作为战斗结果
        local result = self.battleData:get_stage_finishValue()
        self.battleData:set_battle_finishValue(result)

        for k, v in pairs(self.battleData:getHeroNodeList()) do
            if result == bd.interface.isFriendly(k) then
                v:action_win()
            end
        end
    end

    self:emit(bd.event.eBattleEnd, isSkip)
end


-- @关卡开始
function BattleProcess:stageBegin(data)
    -- 清空Buff缓存
    self.battleData.heroBuff_ = {}
    -- 重置关卡数据
    self.battleData:set_stage_roundIdx(1)
    self.battleData.set_stage_finishValue(nil)

    local stageIdx = self.battleData:get_battle_stageIdx()

    -- 创建一份操作记录
    self.records_[stageIdx] = {
        input = {}, -- 操作数据
        mStep = 0,  -- 本地已计算的步数
        skip = nil, -- 是否跳过
    }
    self.autoPlayState_ = nil   -- 是否托管
    self.step_ = 1              -- 当前步骤
    self.recording_ = self.records_[stageIdx]

    -- 创建解析器(LogicCenter)
    self.parse = require("ComBattle.Process.BattleParse").new({
        layer      = self.battleLayer,
        battleData = self.battleData,
    })

    if data.TeamData.Friend.DecSuitId then
        self.battleData:set_battle_dressID({
            [1] = data.TeamData.Friend.DecSuitId ~= 0 and data.TeamData.Friend.DecSuitId or nil,
            [2] = data.TeamData.Enemy.DecSuitId ~= 0 and data.TeamData.Enemy.DecSuitId or nil,
        })
    end

    -- 如果有该信息，则获取FullInfo用于计算奖励
    -- FullInfo 为true, LogicCenter每次计算会返回所有主将的当前血量
    local treasureInfo = self.battleData:get_battle_treasure()
    data.FullInfo = treasureInfo and (#treasureInfo ~= 0)

    -- 初始化LogicCenter
    self.parse:coreInit({
        data     = data,
        callback = function(data)
            bd.log.debug(data, "[process]init")

            self.battleData:dispatchEvent_("stage_stageIdx", stageIdx)

            -- if bd.project == "project_shediao" then
            --     -- 异步加载资源
            --     bd.func.performWithDelay(function()
            --         local spines = self.battleData:getSpineFiles()
            --         dump(spines, "spines")
            --         bd.func.eachSeries(spines, function(cont, v)
            --             local jsonFile = v .. ".skel"
            --             local atlasFile = v .. ".atlas"
            --             SkeletonCache:getDataAsync(jsonFile, atlasFile, 1, function()
            --                 cont()
            --             end)
            --         end)
            --     end, 0)
            -- end

            -- 创建主将形象
            self:createHeroNode(function()
                self:emit(bd.event.eCreateHeroFinish)

                if data.heroList then
                    -- 如果有heroList，则保存
                    self.battleData:set_battle_fullinfo({
                        heroList    = data.heroList,
                        storageList = data.storageList,
                    })
                end

                local function start()
                    self:beforeStage(data, function()
                        -- 战斗前气泡对话
                        self:execStoryData(data, function()
                            -- 宠物开场技
                            self:execStartPetData(data, function()
                                self:execSkillBeforeFight(data, function()
                                    -- 刷新施法框
                                    for k in pairs(self.battleData:getHeroNodeList()) do
                                        self:emit(bd.event.eHeroIn, k)
                                    end

                                    -- 开始战斗数据
                                    self:stepBegin(data)
                                end)
                            end)
                        end)
                    end)
                end

                if stageIdx == 1 then
                    self:beforeFight(start)
                else
                    start()
                end
            end)
        end
    })
end

-- @关卡开始前调用
function BattleProcess:beforeStage(data, cb)
    if bd.project ~= "project_huanzhu" then
        return cb()
    end

    self.battleLayer.parentLayer:addChild(require("ComBattle.Custom.BDStartAction").new({
        callback   = cb,
        battleData = self.battleData,
        ctrlInfo   = self.battleData:get_battle_params().startPet,
    }), bd.ui_config.zOrderFirst)
end

-- @执行战斗前调用
function BattleProcess:beforeFight(cb)
    local function call_patch()
        if bd.patch and bd.patch.onBattleBegin then
            return bd.patch.onBattleBegin(cb)
        else
            return cb()
        end
    end

    local params = self.battleData:get_battle_params()
    if params.data and params.data.beforeBattleFunc then
        params.data.beforeBattleFunc(call_patch)
    else
        call_patch()
    end
end

-- @执行战斗前气泡对话
function BattleProcess:execStoryData(data, cb)
    -- 气泡数据
    local storyData = self.battleData:get_battle_params().storyData
    if not storyData then
        return cb()
    end
    local bpg = require("ComBattle.Process.BattleProcess_guide").new({battleLayer = self.battleLayer , battleData = self.battleData})
    -- Todo: 实现气泡对话
    local exec = function(frame , callback)
        if next(frame) ~= nil then
            local k = #frame
            for i , v in pairs(frame) do
                if v.delay then
                    bpg:exec_eDelay(v.delay , function( ... )
                        k = k - 1
                        if k == 0 then
                            callback()
                        end
                    end)
                elseif v.chat then
                    bpg:exec_eChat(v.chat , function( ... )
                        k = k - 1
                        if k == 0 then
                            callback()
                        end
                    end)
                end
            end
        else
            callback()
        end
    end
    local idx = 1
    local circle
    circle = function( ... )
        if storyData[idx] then
            exec(storyData[idx] , function( ... )
                idx = idx + 1
                circle()
            end)
        else
            return cb()
        end
    end
    circle()
end


-- @执行宠物开场技
function BattleProcess:execStartPetData(data, cb)
    if (not data.StartPet) then
        return cb()
    elseif (not bd.patch) or (not bd.patch.startPetAction) then
        bd.log.warnning(TR("没有实现宠物开场技"))
        return cb()
    end

    -- 顺序检查，拆分敌我数据
    local friendlyData, enemyData = {}, {}
    local first
    bd.func.eachSeries(data.StartPet, function(cont, v, i)
        -- 记录第一个，用于判断友方还是敌方先执行
        if not first then
            first = v
        end

        if bd.interface.isFriendly(v.fromPos) then
            table_insert(friendlyData, v)
        else
            table_insert(enemyData, v)
        end

        cont()
    end, function()
        if not first then
            return cb()
        end

        friendlyData = next(friendlyData) and friendlyData
        enemyData = next(enemyData) and enemyData

        -- 开场技先手值比拼
        local team_data = self.battleData:getCurrentStageData().TeamData
        self.battleLayer.parentLayer:addChild(bd.patch.startPetAction.new({
            friendly   = {data = friendlyData, fsp = team_data.Friend.Fsp},
            enemy      = {data = enemyData, fsp = team_data.Enemy.Fsp},
            first      = bd.interface.isFriendly(first.fromPos),
            ctrlInfo   = self.battleData:get_battle_params().startPet,
            battleData = self.battleData,
            callback   = cb,
        }), bd.ui_config.zOrderFirst)
    end)
end


-- @执行人物开场技
function BattleProcess:execSkillBeforeFight(data, cb)
    if true then
        -- Todo:未实现开场技
        return cb()
    end

    if (not bd.patch) or (not bd.patch.firstDataAction) then
        -- 刷新施法框
        bd.log.warnning(TR("没有实现开场技"))
        return cb()
    end

    local firstData_friendly = {}
    local firstData_enemy = {}
    local before_first = {}  -- 开场buff前数据
    local after_first = {}   -- 开场buff后数据

    local first = nil -- 先手方

    -- 顺序检查，筛选开场技
    bd.func.eachSeries(data.FightAtom, function(cont, v, i)
        v.start = true
        if v.first and v.value then
            -- 开场技
            first = first or v
            if bd.interface.isFriendly(v.fromPos) then
                table_insert(firstData_friendly, v)
            else
                table_insert(firstData_enemy, v)
            end
        elseif first then
            -- 已找到开场技，则需要在执行开场技后执行这个数据
            table_insert(after_first, v)
        else
            -- 没有开场技，则在执行开场技前执行
            table_insert(before_first, v)
        end
        cont()
    end, function()
        -- Todo:开场技
    end)
end


-- @关卡结束
function BattleProcess:stageEnd()
    local function _try()
        -- 等待死亡和移动结束后再尝试进入下一关
        if self.dyingCnt_ > 0
            or self.runningActionCnt_ > 0
            or next(self.movingHeroPos_)
          then
            bd.func.performWithDelay(_try, 0.15)

        -- 根据战斗结果判断是否继续下一关
        else
            -- 释放LogicCore，开启多线程时，需要调用release释放资源
            local core = self.battleData:get_battle_LogicCore()
            local _ = core and core:release()
            self.battleData:set_battle_LogicCore(nil)

            local result = self.battleData:get_stage_finishValue()
            bd.assert(result ~= nil, TR("关卡战斗结果为nil"))

            local isTeamBattle = (self.battleData:get_battle_teaminfo() ~= nil)
            if isTeamBattle then
                -- 组队战:当前关卡战斗失败后继续下一关，胜利则战斗结束
                if result then
                    return self:battleEnd()
                end
            elseif result == false then
                -- 非组队战:当前关卡失败则战斗结束
                return self:battleEnd()
            end

            -- 继续下一关
            self:stageNext()
        end
    end
    _try()
end


-- @进入下一关
function BattleProcess:stageNext()
    -- 继续进行下一关
    local stageIdx = self.battleData.battle_.stageIdx + 1
    self.battleData.battle_.stageIdx = stageIdx -- 不调用set_battle_stageIdx

    local data = self.battleData:getCurrentStageData()
    if data then
        local isTeamBattle = (self.battleData:get_battle_teaminfo() ~= nil)
        -- 组队战避免敌方主将被BattleLayer移除(避免出现地方重复出场的现象)
        local tmpHeroNode = {}
        if isTeamBattle then
            local heroNodeList = self.battleData:getHeroNodeList()
            for k, v in pairs(heroNodeList) do
                if bd.interface.isEnemy(k) then
                    tmpHeroNode[k] = v
                    heroNodeList[k] = nil
                end
            end
        end

        -- 通知上一关卡结束
        self:emit(bd.event.eStageEnd)

        -- 重新绑定敌方主将
        for k, v in pairs(tmpHeroNode) do
            self.battleData:bindHeroNode(v)
        end

        -- 进入下一关
        self:stageBegin(data)
    else
        self:battleEnd()
    end
end


-- @步骤开始
function BattleProcess:stepBegin(data)    
    if data.FightResult ~= nil then
        -- 保存关卡结果
        self.battleData:set_stage_finishValue(data.FightResult)
    end

    if data.FightAtom and next(data.FightAtom) then
        -- 查找友方技能，播放技能蓄力提示
        -- self:tryPlayCastingTips({
        --     atoms    = data.FightAtom,
        --     callback = function()
        --         self:inputStepData({data})
        --     end,
        -- })
        self:inputStepData({data})
        return

    -- 回合技(宠物)
    elseif data.RoundPet then
        self:inputStepData({data})
        return
    -- 回合开始宠物技
    elseif data.ZhenShou then
        self.battleData.stage_.isZhenshouAttacking = data.ZhenShou.nextPet3

        -- 查找友方技能，播放技能蓄力提示
        self:tryPlayCastingTips({
            atoms    = data.ZhenShou,
            callback = function()
                self:inputStepData({data})
            end,
        })
        return
    end

    if (data.FightResult == nil) and (not data.RoundEnding) then
        bd.log.warnning("neither FightAtom or FightResult was found.")
    end

    self:stepNext()
end


-- @获取下一步
function BattleProcess:stepNext()
    local result = self.battleData:get_stage_finishValue()
    if result ~= nil then
        -- 已有本关卡战斗结果，则应该结束关卡
        self:stageEnd()
        return
    end

    self:getStepData(nil, nil, function(data)
        if data then
            self:stepBegin(data)
        elseif not self.skiping_ then
            bd.log.error(TR("获取战斗数据出错!"))
        end
    end)
end


-- @步骤结束
function BattleProcess:stepEnd()
    self:stepNext()
end


-- @获取逻辑数据
-- 统一调用这个接口获取逻辑数据，以便记录操作
function BattleProcess:getStepData(posID, multiple, cb)
    if self.skiping_ or (self.battleData:get_stage_finishValue() ~= nil) then
        return cb()
    end

    local opt = {
        autoPlay = self.battleData:get_ctrl_trustee_state() == bd.trusteeState.eSpeedUpAndTrustee,
        skill    = posID,
        multi    = multiple,
        callback = function(data)
            bd.log.debug(data, "process[step]")
            if data.heroList then
                -- 如果有heroList，则保存
                self.battleData:set_battle_fullinfo({
                    heroList    = data.heroList,
                    storageList = data.storageList,
                })
            end
            self.recording_.mStep = self.step_
            return cb(data)
        end,
    }

    -- 状态与上一次不一样，则记录操作数据
    if opt.skill or (opt.autoPlay ~= self.autoPlayState_) then
        self.autoPlayState_ = opt.autoPlay
        self.recording_.input[self.step_] = {opt.autoPlay, opt.skill, opt.multi}
    end

    self.step_ = self.step_ + 1

    -- 请求数据
    self.parse:coreNext(opt)
end


-- @输入动作数据，检查哪些可以执行，哪些需要等待执行
function BattleProcess:inputStepData(datas, cb)
    local executableData = {}

    for _, data in ipairs(datas) do
        local waiting = false

        local able, dead
        if data.FightAtom or data.ZhenShou then
            able, dead = self:checkExcutable(data.FightAtom or data.ZhenShou)
        else
            able, dead = true, {}
        end

        if not able then
            waiting = true
        else
            data.deadInfo = dead

            if data.RoundPet and self.skillingCnt_ > 0 then
                waiting = true
            else
                waiting = false
            end
        end

        if not waiting then
            table_insert(executableData, data)
        else
            table_insert(self.waitingAtom_, data)
        end
    end

    -- 搜索本次执行的数据中，死亡的数据
    for _, data in ipairs(executableData) do
        local deadInfo = data.deadInfo
        for k, v in pairs(deadInfo) do
            if not self.waitingDead_[k] then
                self.waitingDead_[k] = {}
            end

            for _, d in ipairs(v) do
                table_insert(self.waitingDead_[k], d)
            end
        end
    end

    if next(executableData) then
        self:executeStepData(executableData)
    end
end


-- @检查这一步动作能否执行 (如果目标正在执行死亡动作，则需要等待)
function BattleProcess:checkExcutable(atoms, dead)
    dead = dead or {}

    local function search(what, dead)
        if what.value then
            if what.value.dead then
                if not dead[what.value.dead.to] then
                    dead[what.value.dead.to] = {}
                end
                table_insert(dead[what.value.dead.to], what.value.dead)
            end
        end

        for _, k in ipairs({"beforeExec", "onExec", "afterExec"}) do
            if what[k] then
                local able = self:checkExcutable(what[k], dead)
                if not able then
                    return false
                end
            end
        end

        return true
    end

    for _, atom in ipairs(atoms) do
        if atom.type == bd.adapter.config.atomType.eATTACK then
            for _, target in ipairs(atom.to) do
                if self.waitingDead_[target.posId] and next(self.waitingDead_[target.posId]) then
                    return false
                end

                local able = search(target, dead)
                if not able then
                    return false
                end
            end
        else
            local able = search(atom, dead)
            if not able then
                return false
            end
        end
    end

    return true, dead
end

-- @执行数据
function BattleProcess:executeStepData(executableData)
    -- 直接执行传入的数据
    if executableData and #executableData > 0 then
        self.runningActionCnt_ = self.runningActionCnt_ + #executableData

        bd.func.each(executableData, function(cont, v, i)
            -- 改回合数
            self.battleData:set_stage_roundIdx(v.Round)
            -- 执行
            self:executeAtom(v, function(err)
                self.runningActionCnt_ = self.runningActionCnt_ - 1
                cont(err)
            end)
        end, function()
            return self:executeStepData()
        end)

    -- 有进行中的动作，直接返回
    elseif self.runningActionCnt_ > 0 then
        return

    -- 执行等待中的动作
    elseif #self.waitingAtom_ > 0 then
        local t = self.waitingAtom_
        self.waitingAtom_ = {}
        return self:inputStepData(t)

    -- 排队施法
    elseif next(self.castQueue_) then
        if self.battleData:get_stage_finishValue() ~= nil then
            self.castQueue_ = {}
            return self:stepNext()
        end
        local p1 = {
            [self.castQueue_[1]] = true
        }
        table_remove(self.castQueue_, 1)
        return self:castSkill(p1)

    -- 所有动作完成，继续下一步
    elseif self.runningActionCnt_ == 0 then
        return self:stepNext()
    end
end


-- @执行单步数据
function BattleProcess:executeAtom(data, cb)
    bd.atom.execute({
        battleLayer = self.battleLayer,
        battleData  = self.battleData,
        atoms       = data.FightAtom or data.ZhenShou,
        callback    = function()
            -- 当所有攻击动作执行完后，检查是否有回合技
            if data.RoundPet then
                -- 依次执行先手方、后手方的回合技
                bd.func.eachSeries(data.RoundPet, function(cont, atoms)
                    -- 回合技
                    if bd.patch and bd.patch.roundPetAction then
                        bd.layer.parentLayer:addChild(bd.patch.roundPetAction.new({
                            battleData = self.battleData,
                            atoms      = atoms,
                            callback   = cont,
                        }), bd.ui_config.zOrderSkill)
                    else
                        bd.log.warnning(TR("没有实现回合技效果"))
                        return self:executeAtom({FightAtom = atoms}, cont)
                    end
                end, cb)
            else
                return cb()
            end
        end,
    })
end

-- @排队施法
function BattleProcess:queueCast(posIdList)
    local curCnt = #self.castQueue_
    for posId in pairs(posIdList) do
        table_insert(self.castQueue_, posId)
    end

    if curCnt == 0 then
        local p1 = {
            [self.castQueue_[1]] = true
        }
        table_remove(self.castQueue_, 1)
        self:castSkill(p1)
    end
end

-- @手动施法
-- posIdList:  施法者列表
function BattleProcess:castSkill(posIdList)
    -- 是否多人同时施法
    local multiple = false
    local cnt = 0

    if next(self.castSkillData_) then
        -- 假如短时间内第二次调用施法，认为多人施法
        multiple = true
    else
        -- 检查传入的数据是否多个
        for k, v in pairs(posIdList) do
            cnt = cnt + 1
            if cnt > 1 then
                multiple = true
                break
            end
        end
    end

    -- 执行计算
    self.castReqCnt_ = self.castReqCnt_ + 1

    bd.func.foreach(posIdList, function(cont, _, skillPos)
        -- 蓄力提示和数据都准备好后回调
        local both_done_ = bd.func.getChecker(function()
            self.runningActionCnt_ = self.runningActionCnt_ - 1
            cont()
        end, 1)

        -- 避免其他动作结束后请求新的数据
        -- 否则:播放蓄力提示过程中
        --     如果上一个动作恰好完成，runningActionCnt_ == 0 则会请求数据
        self.runningActionCnt_ = self.runningActionCnt_ + 1

        -- 获取数据
        self:getStepData(skillPos, multiple, function(data)
            if data then
                if data.FightAtom then
                    if data.FightResult ~= nil then
                        self.battleData:set_stage_finishValue(data.FightResult)
                    end

                    if bd.project == "project_sanguo"
                        or bd.project == "project_shediao" then
                        table_insert(self.castSuccessPos_, {
                            pos     = skillPos,
                            skillId = self:getAttackSkill(data.FightAtom, skillPos),
                        })
                    else
                        table_insert(self.castSuccessPos_, skillPos)
                    end

                    table_insert(self.castSkillData_, data)

                    bd.log.info(TR("施法成功: %d", skillPos))
                else
                    -- 检查是否有回合技数据
                    if data.RoundPet then
                        table_insert(self.castSkillData_, data)
                    end

                    bd.log.info(TR("施法失败: %d", skillPos))
                end
            end

            both_done_()
        end)

        -- 不论是否成功，播放蓄力提示
        -- self:castingTips({
        --     posId    = skillPos,
        --     callback = both_done_,
        -- })
    end, function()
        self.castReqCnt_ = self.castReqCnt_ - 1
        if self.castReqCnt_ > 0 then
            return
        end

        local tmpStepData, tmpPos = self.castSkillData_, self.castSuccessPos_
        self.castSkillData_, self.castSuccessPos_ = {}, {}

        if next(tmpPos) then
            -- 施法成功，播放技能切屏
            self:skillFeature(tmpPos, function()
                -- 然后输入数据
                self:inputStepData(tmpStepData)
            end)

        elseif self.runningActionCnt_ == 0 then
            -- 全部都施法失败，如果没有执行中的动作，则调用executeStepData，否则战斗会中断
            self:executeStepData(next(tmpStepData) and tmpStepData or nil)
        elseif next(tmpStepData) then
            -- 有执行中的动作，则添加到等待队列
            for _, v in ipairs(tmpStepData) do
                table_insert(self.waitingAtom_, v)
            end
        end
    end)
end


-- @施法蓄力提示
function BattleProcess:castingTips(params)
    local node = self.battleData:getHeroNode(params.posId)
    if node and (true ~= node.isDead_) then
        self.battleData:emit(bd.event.eCastTip, node.idx)

        local checker = bd.func.getChecker(params.callback, 2)

        if bd.project == "project_shediao" then
            self.skillingCnt_ = self.skillingCnt_ + 1
            local pos = bd.interface.getStandPos(node.idx)
            self.battleData:get_battle_layer():cameraTo(pos, 1.5, 0.2, function()
                bd.func.performWithDelay(function()
                    self.skillingCnt_ = self.skillingCnt_ - 1
                    self.battleData:get_battle_layer():cameraTo(cc.p(0, 0), 1, 0, checker)
                end, 0.5)
            end)
        else
            checker()
        end

        bd.audio.playSound("effect_c_nujichufa.mp3")
        bd.interface.newEffect({
            effectName    = bd.ui_config.castingEffect[1],
            animation     = bd.ui_config.castingEffect[2],
            loop          = false,
            endRelease    = true,
            parent        = node,
            scale         = 1.1,
            position      = cc.p(0, 100),
            zorder        = 1,
            eventListener = function(p)
                if p.event.stringValue == "start" and params.callback then
                    checker()
                end
            end
        })

        return -- **
    end

    return params.callback()
end


-- @检查自动战斗数据是否需要播放技能蓄力提示
function BattleProcess:tryPlayCastingTips(params)
    bd.func.eachSeries(params.atoms, function(cont, v)
        if v.type == bd.adapter.config.atomType.eATTACK then
            local from = v.from.posId
            if from and (bd.interface.isFriendly(from) or bd.project == "project_shediao")
                    and v.skillId then
                local node = self.battleData:getHeroNode(from)

                -- 判断是否正在施法
                if node and node.normalId ~= v.skillId then
                    -- 播放蓄力
                    self:castingTips({
                        posId    = from,
                        force    = true,
                        callback = function()
                            if bd.project == "project_sanguo"
                                or bd.project == "project_shediao" then
                                self:skillFeature({{pos = from, skillId = v.skillId,},}, cont)
                            else
                                -- 播放切屏
                                self:skillFeature({from}, cont)
                            end
                        end,
                    })

                    -- 避免后面调用cont
                    return
                end
            end
        end

        cont()
    end, params.callback)
end


-- @获取攻击数据中的技能ID
function BattleProcess:getAttackSkill(atoms, pos)
    for _, v in ipairs(atoms) do
        if v.type == bd.adapter.config.atomType.eATTACK then

            -- 与要求检查的位置匹配
            local from = v.from.posId
            if pos == nil or (from and from == pos) then
                return v.skillId
            end
        end
    end
end


-- @施法切屏
function BattleProcess:skillFeature(pos, cb)
    if bd.project == "project_shediao" then
        -- 射雕在AttackAtom中调用切屏
        return cb()
    end
    if bd.patch and bd.patch.skillFeature
        and self.battleData:get_ctrl_skillFeature_enable() then
        -- increase skilling-feature count
        self.skillingCnt_ = self.skillingCnt_ + 1
        -- 避免其他动作结束后请求新的数据
        self.runningActionCnt_ = self.runningActionCnt_ + 1

        -- -- 等待其他动作结束后再播放切屏动画
        -- local function _try()
        --     if self.runningActionCnt_ ~= self.skillingCnt_ then
        --         bd.func.performWithDelay(_try, 0.15)
        --     else
                self.battleLayer.parentLayer:addChild(bd.patch.skillFeature.new({
                    pos      = pos,
                    callback = function()
                        self.runningActionCnt_ = self.runningActionCnt_ - 1

                        -- decrease skilling-feature count
                        self.skillingCnt_ = self.skillingCnt_ - 1

                        return cb and cb()
                    end,
                    battleData = self.battleData,
                }), bd.ui_config.zOrderSkill)
        --     end
        -- end
        -- _try()
    else
        return cb and cb()
    end
end


-- @跳过战斗
function BattleProcess:skip()
    if self.battleData:get_battle_finishValue() ~= nil then
        return
    end

    self.skiping_ = true

    self.recording_.skip = true
    self:battleEnd(true)
end


-- @跳过战斗之后回调战斗结果
function BattleProcess:setResult(result)
    self.battleData:set_battle_finishValue(result)
    if result then
        for k, v in pairs(self.battleData:getHeroNodeList()) do
            if result and bd.interface.isFriendly(k) then
                v:action_win()
            elseif (not result) and bd.interface.isEnemy(k) then
                v:action_win()
            end
        end
    end
end

-- @创建当前关卡主将
function BattleProcess:createHeroNode(cb)
    local heroList = self.battleData:getCurrentStageData().HeroList

    local friendlyDress = nil
    local enemyDress = nil

    local teaminfo = self.battleData:get_battle_teaminfo()
    local stageIdx = self.battleData:get_battle_stageIdx()
    if teaminfo then
        local info = teaminfo[stageIdx]
        if info then
            local origin_ = cb
            cb = bd.func.getChecker(origin_, 2)
            self.battleData:get_battle_layer().ctrlLayer_:teamBattleView(info, cb)
        end
    end

    local cameraEntry = function(ctype , callback)
        --我方镜头动画
        if self.battleData:get_ctrl_camera_enable()
            and bd.patch and bd.patch.cameraEntry then
            bd.patch.cameraEntry({
                battledata = self.battleData,
                type = ctype,
                callback = callback,
            })
        else
            if callback then
                callback()
            end
        end
    end

    local heroNodes = {}
    local petNode = {}
    bd.func.each({1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}, function(cont, index)
        if teaminfo and stageIdx > 1 and bd.interface.isEnemy(index) then
            -- 组队战不重复创建敌方
            return cont()
        end

        local v = heroList[index]
        if (not v) or next(v) == nil then
            return cont()
        end

        self:createOneHero(index, v, function(node)
            node.shadow:setVisible(true)
            node:setVisible(false)
            heroNodes[index] = node

            local pet = pet3List and pet3List[index]
            if not pet then
                return cont()
            end
        end)
    end, function()
        local pet3List = self.battleData:getCurrentStageData().PetList3
        bd.func.each({1, 2}, function(cont, index)
            local petData = pet3List[index]
            if not petData then
                return cont()
            end

            self:createOnePet(bd.ui_config.petBase+index, petData, function(node)
                node:setVisible(false)
                heroNodes[bd.ui_config.petBase+index] = node
                return cont()
            end)
        end, function()
            if bd.patch and bd.patch.heroEnter then
                return bd.patch.heroEnter(heroNodes, cb)
            end

            -- 默认直接显示
            for _, v in pairs(heroNodes) do
                v:setVisible(true)
            end
            return cb()
        end)
    end)
end


function BattleProcess:createOneHero(posId, data, cb)
    local done_flag_ = true
    local function after_create(node)
        if done_flag_ == nil then
            return
        end
        done_flag_ = nil

        node:action_idle() -- 待机
        node.figure:setRotationSkewY(bd.ui_config.posSkew[posId] and 180 or 0)

        -- 血条
        local bar = require("ComBattle.UICtrl.BDBar").new({
            curHP   = node.cHP,
            maxHP   = node.mHP,
            curRP   = node.cRP,
            maxRP   = node.mRP,
            isBoss  = data.IsBoss,
            name    = bd.interface.getHeroNodeName(node),
            quality = node.quality,
        })
        node.bar = bar
        if data.IsBoss then
            self.battleData:get_battle_layer().parentLayer:addChild(bar)
            node.bar:setScale(bd.ui_config.MinScale)
            node.bar:setPosition(bd.ui_config.autoPos({midX = 0, top = 80}))

            if bd.ui_config.bossHPBarConfig then
                if bd.ui_config.bossHPBarConfig.barPos then
                    node.bar:setPosition(bd.ui_config.bossHPBarConfig.barPos)
                end
            end
        else
            bd.func.performWithDelay(node.figure, function()
                local boundingBox = node.figure:getBoundingBox()
                bar:setPosition(0, boundingBox.height - 10)
                node.boundingBoxSize = boundingBox
            end, 0.01)
            node:addChild(bar)
        end

        if not data.IsBoss then
            local nameWidth = bar.nameNode_:getContentSize().width
            -- 尊，圣图片显示
            if node.step and node.step > 10 and node.step <= 15 then
                node.titleSprite = bd.interface.newSprite({image = "zd_22.png"})
            elseif node.step and node.step > 15 and node.step <= 20 then
                node.titleSprite = bd.interface.newSprite({image = "zd_21.png"})
            elseif node.step and node.step > 20 and node.step <= 25 then
                node.titleSprite = bd.interface.newSprite({image = "zd_23.png"})
            end

            if node.titleSprite then
                bd.func.performWithDelay(node.figure, function()
                    local boundingBox = node.figure:getBoundingBox()
                    node.titleSprite:setScale(1.5)
                    node.titleSprite:setAnchorPoint(cc.p(0, 0))
                    node.titleSprite:setPosition(-60-nameWidth/2, boundingBox.height - 20)
                end,0.01)
                node:addChild(node.titleSprite)
            end
        end

        return cb and cb(node)
    end

    -- 幻化id
    local illusionModelId = bd.interface.getIllusionId(data.LargePic)
    -- 骨骼动画
    local node = bd.interface.newFigureNode({
        idx             = posId,
        name            = data.NpcName and data.NpcName ~= "" and type(data.NpcName) ~= "userdata" and bd.interface.b64decode(data.NpcName) or nil,
        heroId          = data.HeroModelId,
        figureName      = data.LargePic,
        cHP             = data.HP,
        mHP             = data.MHP,
        cRP             = data.RP,
        mRP             = bd.CONST.maxRP,
        normalId        = data.NAId,
        skillId         = data.RAId,
        comboSkillId    = data.UAId or self.battleData:getHeroItem(data.HeroModelId).comboSkillId,
        reborn          = data.RebornStep,
        figureScale     = (data.BodyTypeR or 10000) / 10000,
        scale           = bd.ui_config.MinScale,
        step            = data.Step or data.step or data.tupo,
        quality         = data.Quality or data.quality or bd.interface.getBaseQuality(data.HeroModelId),
        async           = after_create,
        battleData      = self.battleData,
        illusionModelId = illusionModelId,
    })

    local pos = bd.interface.getStandPos(posId)
    node:setPosition3D(pos)
    node:setLocalZOrder(bd.interface.getHeroZOrder(pos))
    self.battleData:bindHeroNode(node)
    self.battleData:get_battle_layer().heroPlant:addChild(node)

    if node.figure then
        after_create(node)
    end
end

function BattleProcess:createOnePet(posId, data, cb)
    if data.LargePic == "" then
        data.LargePic = ZhenshouModel.items[data.HeroModelId].bigPic
    end

    data.NAId = ZhenshouStepupModel.items[data.HeroModelId][data.Step].baseAtkBuffID
    data.RAId = ZhenshouStepupModel.items[data.HeroModelId][data.Step].skillAtkBuffID
    data.Quality = ZhenshouModel.items[data.HeroModelId].quality
    data.isPet3 = true
    data.BodyTypeR = 20000

    local done_flag_ = true
    local function after_create(node)
        if done_flag_ == nil then
            return
        end
        done_flag_ = nil

        node:action_idle() -- 待机
        node.figure:setRotationSkewY(bd.ui_config.posSkew[posId] and 180 or 0)

        -- 血条
        local bar = require("ComBattle.UICtrl.BDBar").new({
            curHP   = node.cHP,
            maxHP   = node.mHP,
            curRP   = node.cRP,
            maxRP   = node.mRP,
            isBoss  = data.IsBoss,
            isPet   = true,
            name    = bd.interface.getPetNodeName(node),
            quality = node.quality,
        })
        node.bar = bar

        bd.func.performWithDelay(node.figure, function()
            local boundingBox = node.figure:getBoundingBox()
            bar:setPosition(0, boundingBox.height - 10)
            node.boundingBoxSize = boundingBox
        end, 0.01)
        node:addChild(bar)

        return cb and cb(node)
    end

    -- 骨骼动画
    local node = bd.interface.newFigureNode({
        idx             = posId,
        name            = data.NpcName and data.NpcName ~= "" and type(data.NpcName) ~= "userdata" and bd.interface.b64decode(data.NpcName) or nil,
        heroId          = data.HeroModelId,
        figureName      = data.LargePic,
        cHP             = data.HP,
        mHP             = data.MHP,
        cRP             = data.RP,
        mRP             = bd.CONST.maxRP,
        normalId        = data.NAId,
        skillId         = data.RAId,
        comboSkillId    = 0,
        reborn          = data.RebornStep,
        figureScale     = (data.BodyTypeR or 10000) / 10000,
        scale           = bd.ui_config.MinScale,
        step            = data.Step or data.step or data.tupo,
        quality         = data.Quality or data.quality or bd.interface.getBaseQuality(data.HeroModelId),
        -- async           = after_create,
        battleData      = self.battleData,
    })

    local pos = bd.interface.getStandPos(posId)
    node:setLocalZOrder(bd.interface.getHeroZOrder(pos))
    self.battleData:bindHeroNode(node)
    self.battleData:get_battle_layer().heroPlant:addChild(node)

    if node.figure then
        after_create(node)
    end
end

return BattleProcess
