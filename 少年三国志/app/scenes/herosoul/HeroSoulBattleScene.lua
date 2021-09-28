local BattleLayer = require("app.scenes.battle.BattleLayer")
local FightEnd = require("app.scenes.common.fightend.FightEnd")

local HeroSoulBattleScene = class("HeroSoulBattleScene", UFCCSBaseScene)


function HeroSoulBattleScene:ctor(msg, isSkip, ...)
	self.super.ctor(self, ...)
	self._tMsg = msg
	self._isSkip = isSkip

	self._tBattleLayer = nil
    self._attack_multiple = 1

    local nMapId = 31014
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

function HeroSoulBattleScene:onSceneEnter()
	G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
end

function HeroSoulBattleScene:onSceneExit()
	
end

function HeroSoulBattleScene:_startWithBattleReport()
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

function HeroSoulBattleScene:play()
    self._tBattleLayer:play()
end

function HeroSoulBattleScene:_onHandleBattleEvent(event, ...)
    --战斗结束
    if event == BattleLayer.BATTLE_FINISH then
        local isWin = self._tMsg.report.is_win
        self:_onFinishBattleCallback(isWin)
    end
end

function HeroSoulBattleScene:_onFinishBattleCallback(isWin)
	self:_showFightEnd()
end

-- 显示战斗结果界面
function HeroSoulBattleScene:_showFightEnd()
    local tBattleResult = self._tMsg
    if tBattleResult then
        local result = G_GlobalFunc.getBattleResult(self._tBattleLayer)

        local nHeroSoulPoint = 0
        local tAwardSoul = {}
        for i=1, #self._tMsg.awards do
            local tAward = self._tMsg.awards[i]
            if tAward and tAward.type == G_Goods.TYPE_HERO_SOUL_POINT then
                nHeroSoulPoint = tAward.size
            end
            if tAward and tAward.type == G_Goods.TYPE_HERO_SOUL then
                tAwardSoul = tAward
            end
        end

        FightEnd.show(FightEnd.TYPE_HERO_SOUL, 
            self._isWin,
            {
                hero_soul_point = nHeroSoulPoint,
                tAward = tAwardSoul,
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

return HeroSoulBattleScene