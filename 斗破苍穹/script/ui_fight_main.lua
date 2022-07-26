local Fight = require "fight"

UIFightMain = { }
UIFightMain.data = nil
local param = { }
local fightType = nil
local flag = false
local callBackFunc = nil

local function checkIsHaveEquip()
    local FormationNum = utils.getDictTableNum(net.InstPlayerFormation)
    local number = 0
    if net.InstPlayerLineup then
        for key, obj in pairs(net.InstPlayerLineup) do
            if obj.int["4"] == StaticEquip_Type.equip then
                number = number + 1
            end
        end
    end

    if FormationNum > number then
        return true
    else
        return false
    end
end

local function netCallbackFunc(pack)
    if tonumber(pack.header) == StaticMsgRule.activityWar or tonumber(pack.header) == StaticMsgRule.eliteWar or tonumber(pack.header) == StaticMsgRule.commonWar then
        UITeam.checkRecoverState()
        if tonumber(pack.header) == StaticMsgRule.commonWar then
            local function sendTaskStep()
                local data = {
                    header = StaticMsgRule.guidStep,
                    msgdata =
                    {
                        string =
                        {
                            step = param.barrierId .. "B1",
                        }
                    }
                }
                netSendPackage(data)
            end
            UIGuidePeople.param = param.barrierId
            -- 这里触发关卡引导
            if UIGuidePeople.newBarrier and net.InstPlayer.string["29"] ~= "f&f" and net.InstPlayer.string["14"] ~= "f&f" then
                if param.barrierId == 1 then
                    UIGuidePeople.guideStep = guideInfo["1B1"].step
                elseif param.barrierId == 2 then
                    UIGuidePeople.guideStep = guideInfo["2B1"].step
                elseif param.barrierId == 3 then
                    UIGuidePeople.guideStep = guideInfo["3B1"].step
                elseif param.barrierId == 4 then
                    UIGuidePeople.guideStep = guideInfo["4B1"].step
                elseif param.barrierId == 5 then
                    UIGuidePeople.guideStep = guideInfo["5B1"].step
                elseif param.barrierId == 6 then
                    UIGuidePeople.guideStep = guideInfo["6B1"].step
                elseif param.barrierId == 7 then
                    UIGuidePeople.guideStep = guideInfo["7B1"].step
                elseif param.barrierId == 8 then
                    UIGuidePeople.guideStep = guideInfo["8B1"].step
                elseif param.barrierId == 15 then
                    UIGuidePeople.guideStep = guideInfo["15B1"].step
                elseif param.barrierId == 18 then
                    if checkIsHaveEquip() then
                        UIGuidePeople.guideStep = guideInfo["18B1"].step
                    else
                        UIGuidePeople.guideStep = nil
                    end
                elseif param.barrierId == 20 then
                    UIGuidePeople.guideStep = guideInfo["20B1"].step
                elseif param.barrierId == 25 then
                    UIGuidePeople.guideStep = guideInfo["25B1"].step
                elseif param.barrierId == DictFunctionOpen[tostring(StaticFunctionOpen.fight)].level then
                    -- 斗魂引导
                    UIGuidePeople.guideStep = guideInfo["45B1"].step
                end
            else
                UIGuidePeople.guideStep = nil
            end
            if UIGuidePeople.guideStep then
                sendTaskStep()
            end
        end
        UIGuidePeople.AFSLevelGuide()
        local _param = { }
        table.insert(_param, param)
        table.insert(_param, pack.msgdata)
        UIFightWin.setParam(fightType, _param)
        UIManager.pushScene("ui_fight_win")
    elseif tonumber(pack.header) == StaticMsgRule.lootWarWin then
        local _param = { }
        table.insert(_param, pack.msgdata.string["2"])
        table.insert(_param, pack.msgdata.int["1"])
        UILootFight.setParam(fightType, _param)
        UIManager.pushScene("ui_loot_fight")
    elseif tonumber(pack.header) == StaticMsgRule.tryToPracticeBarrier then
        callBackFunc(1, param)
    end
    param = { }
end

--- 精英关卡战斗
local function sendEliteBarrierRequest(_barrierLevelId)
    local sendData = {
        header = StaticMsgRule.eliteWar,
        msgdata =
        {
            int =
            {
                barrierLevelId = _barrierLevelId,
            },
            --            string =
            --            {
            --                coredata = GlobalLastFightCheckData
            --            }
        }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end
--- 活动关卡挑战
local function sendActivityWarRequest(_barrierId)
    local sendData = {
        header = StaticMsgRule.activityWar,
        msgdata =
        {
            int =
            {
                barrierId = _barrierId,
            },
            --            string =
            --            {
            --                coredata = GlobalLastFightCheckData
            --            }
        }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end
--- 普通副本战斗
local function sendFightRequest(_barrierLevelId)
    local sendData = {
        header = StaticMsgRule.commonWar,
        msgdata =
        {
            int =
            {
                barrierLevelId = _barrierLevelId,
                barrierLevel = param and param.levelId
            },
            --            string =
            --            {
            --                coredata = GlobalLastFightCheckData
            --            }
        }
    }
    RequstBarrierLevelId = _barrierLevelId
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end
-- ----副本战斗失败
-- local function sendFightFailData(_type,_barrierId,_barrierLevelId)

--     local  sendData = {
--       header = StaticMsgRule.warFailed,
--       msgdata = {
--         int = {
--           type   = _type ,
--           barrierId  =  _barrierId,
--           barrierLevelId= _barrierLevelId ,
--         }
--       }
--     }
--     UIManager.showLoading()
--     netSendPackage(sendData, netCallbackFunc)
-- end
----抢夺碎片战斗胜利
local function sendlootWarWinData()
    local sendData = {
        header = StaticMsgRule.lootWarWin,
        msgdata =
        {
            int =
            {
                type = UILootChoose.warParam[1],
                chipId = UILootChoose.warParam[2],
                playerId = UILootChoose.warParam[3],
            },
            string =
            {
                step = UIGuidePeople.guideStep or "",
                --                coredata = GlobalLastFightCheckData,
                yzm = UILootChoose.warParam[#UILootChoose.warParam]
            }
        }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end

-- 试炼日战斗胜利
local function sendTryPractice(_tryId)
    local sendData = {
        header = StaticMsgRule.tryToPracticeBarrier,
        msgdata =
        {
            int =
            {
                id = _tryId,
                instPlayerTryToPracticeId = net.InstPlayerTryToPractice and net.InstPlayerTryToPractice.int["1"] or 0
            },
            --            string =
            --            {
            --                coredata = GlobalLastFightCheckData
            --            }
        }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end

-- 丹塔战斗
local function sendPilltowerFight(_params)
    local _medalNums = 0
    if _params.isWin then
        if _params.fightRound >= DictSysConfig[tostring(StaticSysConfig.MinStar3)].value and
            _params.fightRound <= DictSysConfig[tostring(StaticSysConfig.MaxStar3)].value then
            _medalNums = 3
        elseif _params.fightRound >= DictSysConfig[tostring(StaticSysConfig.MinStar2)].value and
            _params.fightRound <= DictSysConfig[tostring(StaticSysConfig.MaxStar2)].value then
            _medalNums = 2
        elseif _params.fightRound >= DictSysConfig[tostring(StaticSysConfig.MinStar1)].value and
            _params.fightRound <= DictSysConfig[tostring(StaticSysConfig.MaxStar1)].value then
            _medalNums = 1
        end
    end
    UIPilltower.netSendPackage( { int = { p2 = 6, p5 = _params.isWin and 1 or 2, p6 = _medalNums } }, function(_msgData)
        local _state = _msgData and _msgData.msgdata.int.r2 or nil
        -- 0成功,1失败
        if type(_state) == "number" and _state == 1 then
            utils.showSureDialog(_msgData.msgdata.string.r3, function()
                UIPilltower.resetData()
                UIManager.showScreen("ui_notice", "ui_pilltower", "ui_menu")
            end )
        else
            callBackFunc( {
                isWin = _params.isWin,
                -- 战斗是否胜利
                fightRound = _params.fightRound,
                -- 战斗回合数
                fightersHP = _params.fightersHP,
                -- 每张卡牌的剩余血值([cardId])
                awardThings = _msgData and _msgData.msgdata.string.r4 or nil
            } )
        end
    end )
end

function UIFightMain.init()
end

function UIFightMain.free()
    UILootFight.replay = false
    Fight.doFree()
end
-- isWin 是否胜利
-- fightIndex 战斗场数
-- bigRound 战斗回合数
-- myDeaths 我方死亡人数
-- hpPercent 剩余血量百分比
-- isSkipFight 是否跳过战斗
local function onFightDone(isWin, fightIndex, bigRound, myDeaths, hpPercent, hurtValue, isSkipFight, fightersHP, otherDamage)
    if fightType == dp.FightType.FIGHT_TASK.COMMON then
        local levelId = 0
        if isWin then
            local barrierId = DictBarrierLevel[tostring(param.barrierLevelId)].barrierId
            local maxBarrierLevel = DictBarrierLevel[tostring(param.barrierLevelId)].level

            if myDeaths <= 0 then
--                if bigRound == DictBarrierLevel[tostring(param.barrierLevelId)].waveNum then
--                    levelId = 4
--                else
--                    levelId = 3
--                end
                levelId = 4
            elseif myDeaths <= 1 then
                levelId = 3
            elseif myDeaths <= 2 then
                levelId = 2
            else
                levelId = 1
            end
            levelId = math.min(levelId, maxBarrierLevel)
        end
        param.levelId = levelId
    end

    local function checkCallBack(package)
        --- 只有普通副本才会跳过战斗---
        if isSkipFight and fightType == dp.FightType.FIGHT_TASK.COMMON and isWin then
            sendFightRequest(param.barrierLevelId)
            return
        end
        ------------------------------
        if isWin then
            if fightType == dp.FightType.FIGHT_TASK.COMMON then
                sendFightRequest(param.barrierLevelId)
                SDK.doLevelFightResult(param.barrierId .. "_1")
            elseif fightType == dp.FightType.FIGHT_TASK.ELITE then
                sendEliteBarrierRequest(param.barrierLevelId)
                SDK.doLevelFightResult(param.barrierId .. "_1")
            elseif fightType == dp.FightType.FIGHT_WING then
                sendEliteBarrierRequest(param.barrierLevelId)
                SDK.doLevelFightResult(param.barrierId .. "_1")
            elseif fightType == dp.FightType.FIGHT_TASK.ACTIVITY then
                sendActivityWarRequest(param.barrierId)
                SDK.doLevelFightResult(param.barrierId .. "_1")
            elseif fightType == dp.FightType.FIGHT_OVERLORD_WAR or fightType == dp.FightType.FIGHT_MINE or fightType == dp.FightType.FIGHT_UNION_REPLAY then
                callBackFunc(true)
            elseif fightType == dp.FightType.FIGHT_CHIP.NPC or fightType == dp.FightType.FIGHT_CHIP.PC then
                --- 抢碎片
                if UILootFight.replay == false then
                    sendlootWarWinData()
                else
                    UIManager.pushScene("ui_loot_fight")
                end
            elseif fightType == dp.FightType.FIGHT_ARENA then
                callBackFunc(1)
            elseif fightType == dp.FightType.FIGHT_ESCORT then
                callBackFunc(1)
            elseif fightType == dp.FightType.FIGHT_BAG_OPEN_BOX then
                callBackFunc(1)
            elseif fightType == dp.FightType.FIGHT_PAGODA then
                --- 爬塔
                local dictPagodaStoreyId = param
                local DictData = DictPagodaStorey[tostring(dictPagodaStoreyId)]
                local victoryValue = nil
                if DictData.victoryMeans == 1 then
                    -- 战斗回合数不超过
                    victoryValue = bigRound
                elseif DictData.victoryMeans == 2 then
                    -- 死亡卡牌数不超过
                    victoryValue = myDeaths
                elseif DictData.victoryMeans == 3 then
                    -- 战斗结束后血量不少于%
                    victoryValue = hpPercent * 100
                elseif DictData.victoryMeans == 4 then
                    -- 消灭全部敌人
                    victoryValue = 0
                end
                callBackFunc(victoryValue)
            elseif fightType == dp.FightType.FIGHT_FIRST then
                callBackFunc()
            elseif fightType == dp.FightType.FIGHT_BOSS then
                callBackFunc(hurtValue)
            elseif fightType == dp.FightType.FIGHT_TRY_PRACTICE then
                sendTryPractice(param.tryId)
            elseif fightType == dp.FightType.FIGHT_PILL_TOWER then
                param.isWin = true
                -- 战斗是否胜利
                param.fightRound = bigRound
                -- 战斗回合数
                param.fightersHP = fightersHP
                -- 每张卡牌的剩余血值([cardId])
                sendPilltowerFight(param)
            elseif fightType == dp.FightType.FIGHT_TOWER_UP then
                callBackFunc(true, otherDamage)
            elseif fightType == dp.FightType.FIGHT_3V3 then
                callBackFunc( 1 )
            end
        else
            if fightType == dp.FightType.FIGHT_CHIP.NPC or fightType == dp.FightType.FIGHT_CHIP.PC then
                if UIGuidePeople.guideFlag then
                    sendlootWarWinData()
                else
                    if UILootFight.replay == false then
                        UILootFight.setParam(fightType, nil)
                        UIManager.pushScene("ui_loot_fight")
                    else
                        UIManager.pushScene("ui_loot_fight")
                    end
                end
            elseif fightType == dp.FightType.FIGHT_OVERLORD_WAR or fightType == dp.FightType.FIGHT_MINE or fightType == dp.FightType.FIGHT_UNION_REPLAY then
                callBackFunc(false)
            elseif fightType == dp.FightType.FIGHT_PAGODA then
                --- 爬塔
                local dictPagodaStoreyId = param
                local DictData = DictPagodaStorey[tostring(dictPagodaStoreyId)]
                local victoryValue = DictData.victoryValue
                callBackFunc(victoryValue + 1)
            elseif fightType == dp.FightType.FIGHT_ARENA then
                callBackFunc(0)
            elseif fightType == dp.FightType.FIGHT_ESCORT then
                callBackFunc(0)
            elseif fightType == dp.FightType.FIGHT_BAG_OPEN_BOX then
                callBackFunc(0)
            elseif fightType == dp.FightType.FIGHT_FIRST then
                callBackFunc()
            elseif fightType == dp.FightType.FIGHT_BOSS then
                callBackFunc(hurtValue)
            elseif fightType == dp.FightType.FIGHT_TRY_PRACTICE then
                callBackFunc(0)
            elseif fightType == dp.FightType.FIGHT_PILL_TOWER then
                sendPilltowerFight(param)
            elseif fightType == dp.FightType.FIGHT_TOWER_UP then
                callBackFunc(false, otherDamage)
            elseif fightType == dp.FightType.FIGHT_3V3 then
                callBackFunc( 0 )
            else
                UIFightFail.setParam(fightType, param)
                UIManager.pushScene("ui_fight_fail")
                SDK.doLevelFightResult(param.barrierId .. "_0")
            end
        end
    end

    ---------------------------------------------
    local sendData = {
        header = StaticMsgRule.checkFight,
        msgdata =
        {
            string =
            {
                coredata = GlobalLastFightCheckData
            }
        }
    }
    UIManager.showLoading()
    netSendPackage(sendData, checkCallBack)
    ---------------------------------------------
end

local playBossFightMusicState = 0
local playCommonFightMusicState = 0 
local function playFightMusic()
    if fightType == dp.FightType.FIGHT_ARENA then
        AudioEngine.playMusic("sound/arena.mp3", true)
    elseif fightType == dp.FightType.FIGHT_TASK.COMMON then
        local barrierData = DictBarrier[tostring(param.barrierId)]
        if barrierData then
            if barrierData.type == 3 then
                if playBossFightMusicState == 0 then
                    playBossFightMusicState = 1
                    AudioEngine.playMusic("sound/boss1.mp3", true)
                else
                    playBossFightMusicState = 0
                    AudioEngine.playMusic("sound/boss2.mp3", true)
                end
            else
                AudioEngine.playMusic("sound/commonfight1.mp3", true)
            end
        end
    else
        AudioEngine.playMusic("sound/commonfight1.mp3", true)
    end
end

function UIFightMain.setup()
    UIFightMain.Widget:removeAllChildren()
    UIFightMain.Widget:setEnabled(true)
    GlobalLastFightCheckData = utils.fightVerifyData()
    Fight.doInit(UIFightMain.data, onFightDone)
    playFightMusic()
    UIFightMain.Widget:addChild(Fight.scene)
    UIFightMain.data = nil
end

function UIFightMain.loading()
    -- local function callBack(armature)
    --   armature:removeFromParent()
    UIManager.showScreen("ui_fight_main")
    -- end
    -- local size = cc.Director:getInstance():getVisibleSize()
    -- local armature = ActionManager.getUIAnimation(33,callBack)
    -- armature:setPosition(cc.p(size.width/2,size.height/2))
    -- UIManager.uiLayer:addChild(armature,100,100)
end
-- 副本
-- param.chapterId = _param.chapterId
-- param.barrierId = _param.barrierId
-- param.barrierLevelId = _param.barrierLevelId
function UIFightMain.setData(data, _param, _fightType, _callBackFunc, cbOfCalcResult)
    if cbOfCalcResult then
        Fight.calcFight(data, cbOfCalcResult)
    end
    UIFightMain.data = data
    fightType = _fightType
    callBackFunc = _callBackFunc
    param = _param
    if fightType == dp.FightType.FIGHT_TASK.COMMON then
        local taskStory = FightTaskInfo.getData(param.chapterId, _param.barrierId)
        if taskStory and taskStory["middle"] and taskStory["middle"].flag == nil then
            UIFightMain.data.script = taskStory["middle"]
        end
    end
end
