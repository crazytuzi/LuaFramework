local TowerBattleScene = class("BattleScene", UFCCSBaseScene)

local BattleLayer = require "app.scenes.battle.BattleLayer"

function TowerBattleScene:ctor(msg, enemyData, ...) 
    print("ldx----------create TowerBattleScene-----------------------" .. tostring(self))
    self.super.ctor(self, ...)
    self._battleField = require("app.scenes.battle.BattleLayer").create(
        {   enemy = enemyData,
            msg = msg.data.battle_report,
            battleBg = msg.bg,
            skip = BattleLayer.SkipConst.SKIP_YES,
            battleType = BattleLayer.ARENA_BATTLE
        }, handler(self, self._onBattleEvent))
    self._finishFunc = msg.func
    self._finishFunc2 = msg.func2
    -- self._battleField:play()
    self:addChild(self._battleField)
end
    
function TowerBattleScene:onSceneEnter(...)
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
end

function TowerBattleScene:_onBattleEvent(event)
    if event == BattleLayer.BATTLE_FINISH then
        if self._finishFunc ~= nil then 
            uf_eventManager:removeListenerWithTarget(self)
            local result = G_GlobalFunc.getBattleResult(self._battleField)
            self._finishFunc(result,self._finishFunc2) 

        else
            -- uf_sceneManager:popScene()
            -- uf_sceneManager:replaceScene(require("app.scenes.tower.TowerScene").new())
        end
    end
end
function TowerBattleScene:play()
    self._battleField:play()
end
    
return TowerBattleScene

