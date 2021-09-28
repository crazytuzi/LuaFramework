local BattleLayer = require("app.scenes.battle.BattleLayer")
local FightEnd = require("app.scenes.common.fightend.FightEnd")

local RebelBossBattleScene = class("RebelBossBattleScene", UFCCSBaseScene)


function RebelBossBattleScene:ctor(msg, isSkip, nBossLevel, ...)
	self.super.ctor(self, ...)
	self._tMsg = msg
	self._isSkip = isSkip
	self._tBattleLayer = nil
    self._attack_multiple = 1
    self._nBossLevel = nBossLevel

    local nMapId = 31012
	self._bgPath = G_Path.getDungeonBattleMap(nMapId)
	self._isWin = msg.report.is_win
    self._harm = msg.harm

	self:_startWithBattleReport()

    -- buff layer
    self._buff = require("app.scenes.moshen.rebelboss.RebelBossBattleBuffLayer").create()
    self:addChild(self._buff)
    local winSize = CCDirector:sharedDirector():getWinSize()
    self._buff:setPosition(ccp(0, winSize.height/2+50))
end

function RebelBossBattleScene:onSceneEnter()
	G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
end

function RebelBossBattleScene:onSceneExit()
	
end

function RebelBossBattleScene:_startWithBattleReport()
    local tBattleReport = rawget(self._tMsg, "report") or require "app.battlereport.story_battle_report1"
    self._tBattleLayer = BattleLayer.create( {
                                                battleType = BattleLayer.REBEL_BOSS,
                                                msg = tBattleReport, 
                                                battleBg = self._bgPath, 
                                                skip = self._isSkip == true and BattleLayer.SkipConst.SKIP_YES or BattleLayer.SkipConst.SKIP_NO,
                                                knightLevel = self._nBossLevel
                                            }, 
                                            handler(self, self._onHandleBattleEvent) )
    self:addChild(self._tBattleLayer)
end

function RebelBossBattleScene:play()
    self._tBattleLayer:play()
end

function RebelBossBattleScene:_onHandleBattleEvent(event, ...)
    -- 表示开场动画结束
    if event == BattleLayer.BATTLE_OPENING_FINISH then
        -- 魔神战斗显示
        local entrySets = require("app.scenes.battle.entry.Entry").new()
        
        local knights = self._tBattleLayer:getHeroKnight()
        
        -- 入口集
        local entrySet = require("app.scenes.battle.entry.Entry").new()
        
        local MoshenOpeningEntry = require "app.scenes.moshen.MoShenOpeningEntry"
        local moshenOpeningEntry = MoshenOpeningEntry.create(self._tBattleLayer)
        entrySet:addEntryToQueue(moshenOpeningEntry, moshenOpeningEntry.updateEntry)
        
        local MoshenAdditionEntry = require "app.scenes.moshen.MoShenAdditionEntry"
        for k, knight in pairs(knights) do
            local cardConfig = knight:getCardConfig()
            local additionEntry = MoshenAdditionEntry.create(cardConfig.advanced_level+1, knight, self._tBattleLayer)
            entrySet:addEntryToNewQueue(additionEntry, additionEntry.updateEntry)
        end
        entrySets:addEntryToQueue(entrySet, entrySet.updateEntry)
        
        -- 入口集
        local entrySet = require("app.scenes.battle.entry.Entry").new()
        local RebelBossGroupAdditionEntry = require "app.scenes.moshen.rebelboss.RebelBossGroupAdditionEntry"
        for k, knight in pairs(knights) do
            local cardConfig = knight:getCardConfig()
            -- 武将是否属于自己加入的阵营
            if cardConfig.group == G_Me.moshenData:getMyGroup() then
                local additionEntry = RebelBossGroupAdditionEntry.create(knight, self._tBattleLayer)
                entrySet:addEntryToNewQueue(additionEntry, additionEntry.updateEntry)
            end
        end
        entrySets:addEntryToQueue(entrySet, entrySet.updateEntry)
        
        -- 添加至当前队列的顶层，表示马上需要播放
        self._tBattleLayer:insertEntryToQueueAtTop(entrySets, entrySets.updateEntry)
        
        --战斗结束
    elseif event == BattleLayer.BATTLE_FINISH then
        self._buff:updateDamage(self._harm)

        if event == BattleLayer.BATTLE_FINISH then
            local isWin = self._tMsg.report.is_win
            self:_onFinishBattleCallback(isWin)
        end
    elseif event == BattleLayer.BATTLE_ROUND_UPDATE then
        --[[
        local params = {...}
        self._round = params[1]
        self._buff:updateRound(params[1])
        ]]
    elseif event == BattleLayer.BATTLE_DAMAGE_UPDATE then
        local params = {...}
        if params[1] == 2 then  -- 2表示是敌方
            self._damage = self._tBattleLayer:getKnightTotalHP(2) - self._tBattleLayer:getKnightCurrentHP(2)
            self._buff:updateDamage(self._damage)
        end
    end
end

function RebelBossBattleScene:_onFinishBattleCallback(isWin)
	self:_showFightEnd()
end

-- 显示战斗结果界面
function RebelBossBattleScene:_showFightEnd()
    local tBattleResult = G_Me.moshenData:getRebelBossBattleResult()
    if tBattleResult then
        local tFirstAward = {}
        if rawget(tBattleResult, "faward") then
            tFirstAward = tBattleResult.faward
        end
        local tKillAward = {}
        if rawget(tBattleResult, "kaward") then
            tKillAward = tBattleResult.kaward
        end

        local nCritId = tBattleResult.crit_id
        G_Me.moshenData:setCritId(nCritId)
        local nZhangGong = 0
        local tTmpl = rebel_boss_attack_reward_info.get(nCritId)
        if tTmpl then
            nZhangGong = tTmpl.attack_reward
        end

        local result = G_GlobalFunc.getBattleResult(self._tBattleLayer)
        local FightEnd = require("app.scenes.common.fightend.FightEnd")
        FightEnd.show(FightEnd.TYPE_REBEL_BOSS, 
            true,
            {
              damage=tBattleResult.harm,
              rongyu=tBattleResult.honor,
              zhangongboss=nZhangGong,
              rebelboss_result = 
              {
                  ["First"] = tFirstAward,
                  ["Kill"]  = tKillAward,
              },
            },
            function() 
                uf_sceneManager:replaceScene(require("app.scenes.moshen.rebelboss.RebelBossMainScene").new())
            end 
           ,result
        ) 

    else
        -- TODO:
    --    __Log("没有战斗结果")
    end 	
end

return RebelBossBattleScene