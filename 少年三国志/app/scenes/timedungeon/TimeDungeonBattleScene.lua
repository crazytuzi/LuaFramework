local BattleLayer = require("app.scenes.battle.BattleLayer")
local FightEnd = require("app.scenes.common.fightend.FightEnd")

local TimeDungeonBattleScene = class("TimeDungeonBattleScene", UFCCSBaseScene)


function TimeDungeonBattleScene:ctor(msg, isSkip, scenePack, ...)
	self.super.ctor(self, ...)

	self._tMsg = msg
	self._isSkip = isSkip
	self._scenePack = scenePack

	self._tBattleLayer = nil

    local tAttackStageInfo = G_Me.timeDungeonData:getAttackStageInfo()
    local nStageId = 1
    local nStageIndex = 1
    if tAttackStageInfo then
        nStageId = tAttackStageInfo._nStageId
        nStageIndex = tAttackStageInfo._nStageIndex
    end
    local tDungeonInfo = time_dungeon_info.get(nStageId)
    local nMapId = tDungeonInfo and tDungeonInfo.map or 31001
	self._bgPath = G_Path.getDungeonBattleMap(nMapId)
	self._isWin = msg.battle_report.is_win

	self:_startWithBattleReport()

    -- buff layer
    self._buff = require("app.scenes.timedungeon.TimeDungeonBattleBuffLayer").create()
    self:addChild(self._buff)
    local winSize = CCDirector:sharedDirector():getWinSize()
    self._buff:setPosition(ccp(0, winSize.height/2+50))
end

function TimeDungeonBattleScene:onSceneEnter()
	G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
end

function TimeDungeonBattleScene:onSceneExit()
	
end

function TimeDungeonBattleScene:_startWithBattleReport()
    local tBattleReport = rawget(self._tMsg, "battle_report") or require "app.battlereport.story_battle_report1"
    self._tBattleLayer = BattleLayer.create( {
                                                msg = self._tMsg.battle_report, 
                                                battleBg = self._bgPath, 
                                                skip = self._isSkip == true and BattleLayer.SkipConst.SKIP_YES or BattleLayer.SkipConst.SKIP_NO,
                                            }, 
                                            handler(self, self._onHandleBattleEvent) )
    self:addChild(self._tBattleLayer)
end

function TimeDungeonBattleScene:play()
    self._tBattleLayer:play()
end

function TimeDungeonBattleScene:_onHandleBattleEvent(event)
	local tBattleResult = nil
	if event == BattleLayer.BATTLE_FINISH then
		local isWin = self._tMsg.battle_report.is_win
		self:_onFinishBattleCallback(isWin)
	end
end

function TimeDungeonBattleScene:_onFinishBattleCallback(isWin)
	self:_showFightEnd()
end

-- 显示战斗结果界面
function TimeDungeonBattleScene:_showFightEnd()
    local tBattleResult = G_Me.timeDungeonData:getBattleResult()
    if tBattleResult then
        local result = G_GlobalFunc.getBattleResult(self._tBattleLayer)
        FightEnd.show(FightEnd.TYPE_TIME_DUNGEON, 
        	self._isWin,
        	{awards = tBattleResult.award},
        	function() 
                if self._scenePack then
                    -- TODO:
                    return
                end

                local scene = nil
                local hasDungeon, nChapterId, nEndTime = G_Me.timeDungeonData:currentTimeHasDungeon()
                if hasDungeon then
                    scene = require("app.scenes.timedungeon.TimeDungeonMainScene").new(nil, false)
                else
                    G_MovingTip:showMovingTip(G_lang:get("LANG_TIME_DUNGEON_CUR_DUNGEON_FINISHED"))
                    scene = require("app.scenes.mainscene.PlayingScene").new()
                end
                uf_sceneManager:replaceScene(scene)
            end 
           ,result
        )
    else
        -- TODO:
    --    __Log("没有战斗结果")
    end 	
end

return TimeDungeonBattleScene