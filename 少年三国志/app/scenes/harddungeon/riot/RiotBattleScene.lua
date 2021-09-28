local BattleLayer = require("app.scenes.battle.BattleLayer")
local FightEnd = require("app.scenes.common.fightend.FightEnd")

local RiotBattleScene = class("RiotBattleScene", UFCCSBaseScene)


function RiotBattleScene:ctor(msg, isSkip, ...)
	self.super.ctor(self, ...)
	self._tMsg = msg
	self._isSkip = isSkip
	self._tBattleLayer = nil

    local nRiotId = self._tMsg.roit.roit_id
    local nChapterId = self._tMsg.ch_id
    local tChapterTmpl = hard_dungeon_chapter_info.get(nChapterId)
    local tRiotDungeonTmpl = hard_dungeon_roit_info.get(nRiotId)

    local nMapId = (tChapterTmpl and tChapterTmpl.riot_map) and tChapterTmpl.riot_map or 31001
	self._bgPath = G_Path.getDungeonBattleMap(nMapId)
	self._isWin = msg.info.is_win

	self:_startWithBattleReport()
end

function RiotBattleScene:onSceneEnter()
	G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
end

function RiotBattleScene:onSceneExit()
	
end

function RiotBattleScene:_startWithBattleReport()
    local tBattleReport = rawget(self._tMsg, "info") or require "app.battlereport.story_battle_report1"
    self._tBattleLayer = BattleLayer.create( {
                                                msg = tBattleReport, 
                                                battleBg = self._bgPath, 
                                                skip = self._isSkip == true and BattleLayer.SkipConst.SKIP_YES or BattleLayer.SkipConst.SKIP_NO,
                                            }, 
                                            handler(self, self._onHandleBattleEvent) )
    self:addChild(self._tBattleLayer)
end

function RiotBattleScene:play()
    self._tBattleLayer:play()
end

function RiotBattleScene:_onHandleBattleEvent(event)
	local tBattleResult = nil
	if event == BattleLayer.BATTLE_FINISH then
		local isWin = self._tMsg.info.is_win
		self:_onFinishBattleCallback(isWin)
	end
end

function RiotBattleScene:_onFinishBattleCallback(isWin)
	self:_showFightEnd()
end

-- 显示战斗结果界面
function RiotBattleScene:_showFightEnd()
    local tBattleResult = G_Me.hardDungeonData:getRiotBattleResult()
    if tBattleResult then
        local nRiotId = self._tMsg.roit.roit_id
        local tRiotDungeonTmpl = hard_dungeon_roit_info.get(nRiotId)
        local szSuccorName = (tRiotDungeonTmpl and tRiotDungeonTmpl.name) and tRiotDungeonTmpl.name or ""
        local nQuality = (tRiotDungeonTmpl and tRiotDungeonTmpl.quality) and tRiotDungeonTmpl.quality or 1
        local result = G_GlobalFunc.getBattleResult(self._tBattleLayer)
        local FightEnd = require("app.scenes.common.fightend.FightEnd")
        FightEnd.show(FightEnd.TYPE_HARD_RIOT, 
            self._isWin,
            {
              exp=tBattleResult.exp,
              money=tBattleResult.money,
              riot_win_desc1 = G_lang:get("LANG_HARD_RIOT_CONGRATULATION"),
              riot_win_desc2 = G_lang:get("LANG_HARD_RIOT_SUCCOR_RUN_AWAY", {name = szSuccorName, color=Colors.qualityDecColors[nQuality]}),
              awards = tBattleResult.awards,
            },
            function() 
                local flag = G_Me.hardDungeonData:getEnterFlag()
                local hasAliveRiot = G_Me.hardDungeonData:curTimeExistRiotsAlive()
                if hasAliveRiot and flag then
                    uf_sceneManager:replaceScene(require("app.scenes.harddungeon.HardDungeonMainScene").new())
                    return
                end
                if not hasAliveRiot and flag then
                    G_Me.hardDungeonData:setEnterFlag(false)
                end
                uf_sceneManager:replaceScene(require("app.scenes.harddungeon.HardDungeonGateScene").new())
            end 
           ,result
        )
    else
        -- TODO:
    --    __Log("没有战斗结果")
    end 	
end

return RiotBattleScene