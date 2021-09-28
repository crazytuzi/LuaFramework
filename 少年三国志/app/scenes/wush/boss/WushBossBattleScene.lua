-- 三国无双精英boss战斗场景

local WushBossBattleScene = class("WushBossBattleScene", UFCCSBaseScene)

local BattleLayer = require("app.scenes.battle.BattleLayer")

function WushBossBattleScene:ctor( report, enemyData, callback, isFirstChallenge, ... )
	self.super.ctor(self, ...)

	self._callback = callback
    local mapId = 31003

    local pack = {
        enemy = enemyData,
        msg = report,
        skip = isFirstChallenge and BattleLayer.SkipConst.SKIP_NO or BattleLayer.SkipConst.SKIP_YES,
        battleBg=G_Path.getDungeonBattleMap(mapId),
        battleType=BattleLayer.WUSH_BOSS_BATTLE
    }

    self._battleLayer = BattleLayer.create(pack, handler(self, self._onBattleEvent))
    self:addChild(self._battleLayer)
end


function WushBossBattleScene:_onBattleEvent( event )

    if event == BattleLayer.BATTLE_FINISH then
        if self._battleLayer ~= nil then
            local result = G_GlobalFunc.getBattleResult(self._battleLayer)
            if self._callback ~= nil then
            	self._callback(result)
            end
        end
    elseif event == "someone_dead" then
    end 
end

function WushBossBattleScene:play(  )
    self._battleLayer:play()
end

function WushBossBattleScene:onSceneEnter( ... )
	-- body
end


function WushBossBattleScene:onSceneExit( ... )
	-- body
end









return WushBossBattleScene