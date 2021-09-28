local BattleLayer = require("app.scenes.battle.BattleLayer")
local FightEnd = require("app.scenes.common.fightend.FightEnd")

local ExpansionDungeonBattleScene = class("ExpansionDungeonBattleScene", UFCCSBaseScene)


function ExpansionDungeonBattleScene:ctor(msg, isSkip, nChapterId, nStageId, ...)
	self.super.ctor(self, ...)
	self._tMsg = msg
	self._isSkip = isSkip
    self._nChapterId = nChapterId or 1
    self._nStageId = nStageId or 1
	self._tBattleLayer = nil
    self._attack_multiple = 1

    local tStageTmpl = expansion_dungeon_stage_info.get(self._nStageId)
    local nMapId = tStageTmpl.dungeonbattle_map
	self._bgPath = G_Path.getDungeonBattleMap(nMapId)
	self._isWin = msg.report.is_win

	self:_startWithBattleReport()

    --[[
    -- buff layer
    self._buff = require("app.scenes.moshen.rebelboss.RebelBossBattleBuffLayer").create()
    self:addChild(self._buff)
    local winSize = CCDirector:sharedDirector():getWinSize()
    self._buff:setPosition(ccp(0, winSize.height/2+50))
    ]]
end

function ExpansionDungeonBattleScene:onSceneEnter()
	G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
end

function ExpansionDungeonBattleScene:onSceneExit()
	
end

function ExpansionDungeonBattleScene:_startWithBattleReport()
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

function ExpansionDungeonBattleScene:play()
    self._tBattleLayer:play()
end

function ExpansionDungeonBattleScene:_onHandleBattleEvent(event, ...)
    --战斗结束
    if event == BattleLayer.BATTLE_FINISH then
        local isWin = self._tMsg.report.is_win
        self:_onFinishBattleCallback(isWin)
    end
end

function ExpansionDungeonBattleScene:_onFinishBattleCallback(isWin)
	self:_showFightEnd()
end

-- 显示战斗结果界面
function ExpansionDungeonBattleScene:_showFightEnd()
    local tBattleResult = self._tMsg
    if tBattleResult then
        local tAtkStage = G_Me.expansionDungeonData:getAtkStage()
        local tStage = G_Me.expansionDungeonData:getStageById(self._nChapterId, self._nStageId)
        local tStageTmpl = expansion_dungeon_stage_info.get(tStage._nId)
        assert(tStage)
        assert(tStageTmpl)

        local nStar = G_Me.expansionDungeonData:getStageStarNum(tStage)
        local bStarChanged = G_Me.expansionDungeonData:getStageStarNum(tAtkStage) ~= nStar
        G_Me.expansionDungeonData:setStageAwardList(self._tMsg.awards)

        local szDesc = ""
        for i=1, 3 do
            if tStage["_bTarget"..i] then
                szDesc = szDesc .. tStageTmpl["target_description_"..i] .."\n"
            end
        end

        -- 经验及军团加成经验
        local nExp = rawget(self._tMsg, "stage_exp") and self._tMsg.stage_exp or 0
        local szExpAdd, nExpAdd = G_Me.userData:getExpAdd2(nExp)

        local result = G_GlobalFunc.getExDungeonBattleResult(nStar)

        FightEnd.show(FightEnd.TYPE_EX_DUNGEON, 
            self._isWin,
            {
                ex_star = nStar,
                _szDesc = szDesc,
                _tAwards = self._tMsg.awards,
                _bStarChanged = bStarChanged,
                _nExp = nExp,
                _szExpAdd = szExpAdd,
                _nExpAdd = nExpAdd,  -- 军团科技加成的数值
            },
            function() 
                uf_sceneManager:replaceScene(require("app.scenes.expansiondungeon.ExpansionDungeonGateScene").new(self._nChapterId))
            end 
           ,result
        )
    else
        -- TODO:
    --    __Log("没有战斗结果")
    end 
end

return ExpansionDungeonBattleScene