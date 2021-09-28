local BattleLayer = require("app.scenes.battle.BattleLayer")
local FightEnd = require("app.scenes.common.fightend.FightEnd")

local CrossPVPBattleScene = class("CrossPVPBattleScene", UFCCSBaseScene)


function CrossPVPBattleScene:ctor(msg, isSkip, tEnemyInfo, ...)
	self.super.ctor(self, ...)
	self._tMsg = msg
	self._isSkip = isSkip
	self._tBattleLayer = nil
    self._attack_multiple = 1
    self._tEnemyInfo = tEnemyInfo or {}

    local nMapId = 31002
	self._bgPath = G_Path.getDungeonBattleMap(nMapId)
	self._isWin = msg.report.is_win
    self._harm = 0

	self:_startWithBattleReport()

    --[[
    -- buff layer
    self._buff = require("app.scenes.moshen.rebelboss.RebelBossBattleBuffLayer").create()
    self:addChild(self._buff)
    local winSize = CCDirector:sharedDirector():getWinSize()
    self._buff:setPosition(ccp(0, winSize.height/2+50))
    ]]
end

function CrossPVPBattleScene:onSceneEnter()
	G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
end

function CrossPVPBattleScene:onSceneExit()
	
end

function CrossPVPBattleScene:_startWithBattleReport()
    local tBattleReport = rawget(self._tMsg, "report") or require "app.battlereport.story_battle_report1"
    self._tBattleLayer = BattleLayer.create( {
                                                battleType = BattleLayer.DUNGEON_BATTLE,
                                                msg = tBattleReport, 
                                                battleBg = self._bgPath, 
                                                skip = self._isSkip == true and BattleLayer.SkipConst.SKIP_YES or BattleLayer.SkipConst.SKIP_NO,
                                            }, 
                                            handler(self, self._onHandleBattleEvent) )
    self:addChild(self._tBattleLayer)
end

function CrossPVPBattleScene:play()
    self._tBattleLayer:play()
end

function CrossPVPBattleScene:_onHandleBattleEvent(event, ...)
    --战斗结束
    if event == BattleLayer.BATTLE_FINISH then
        local isWin = self._tMsg.report.is_win
        self:_onFinishBattleCallback(isWin)
    end
end

function CrossPVPBattleScene:_onFinishBattleCallback(isWin)
	self:_showFightEnd()
end

-- 显示战斗结果界面
function CrossPVPBattleScene:_showFightEnd()
    local tBattleResult = self._tMsg
    if tBattleResult then
        local result = G_GlobalFunc.getBattleResult(self._tBattleLayer)

        local nEngagedScore = self._tMsg.score or 0

        local szEnemyName = self._tEnemyInfo._szName or ""
        local nEnemyBaseId = self._tEnemyInfo._nBaseId or 1
        local tEnemyTmpl = knight_info.get(nEnemyBaseId)
        assert(tEnemyTmpl)
        local nEnemyQuality = tEnemyTmpl.quality or 1

        local nArenaIndex = self:_getArenaIndexByFlag(self._tMsg.flag or 1)
        local tArenaTmpl = crosspvp_fight_info.get(nArenaIndex)
        assert(tArenaTmpl)
        local szArenaName = tArenaTmpl.name or ""
        local nArenaQuality = tArenaTmpl.quality or 1

        FightEnd.show(FightEnd.TYPE_CROSSPVP, 
            self._isWin,
            {
                engaged_score = nEngagedScore,
                crosspvp_win = self._isWin,
                enemyName = szEnemyName,
                enemyColor = Colors.qualityColors[nEnemyQuality],
                arenaName = szArenaName,
                arenaColor = Colors.qualityColors[nArenaQuality],
            },
            function() 
                uf_sceneManager:popScene()
            end 
           ,result
        )
    else
        -- TODO:
    --    __Log("没有战斗结果")
    end 
end


-- 因为后端传来的坑位号是唯一的，所以要算一下坑位的index
function CrossPVPBattleScene:_getArenaIndexByFlag(nFlag)
    if type(nFlag) ~= "number" then
        assert(false, "nFlag must be a number type")
        return 1
    end
    local nIndex = nFlag % 6
    nIndex = nIndex ~= 0 and nIndex or 6
    return nIndex
end

return CrossPVPBattleScene