local CrusadeBattleScene = class("CrusadeBattleScene",UFCCSBaseScene)
function CrusadeBattleScene:ctor(report,enemyData,callback,...)

    self._callback = callback
    self.super.ctor(self,...)
    
    local BattleLayer = require("app.scenes.battle.BattleLayer")
    local pack = {
        enemy = enemyData,
        msg = report,
        skip = BattleLayer.SkipConst.SKIP_YES,
        battleBg=G_Path.getDungeonBattleMap(31001),
        battleType=BattleLayer.CRUSADE_BATTLE
    }

    self._battleLayer = BattleLayer.create(pack,handler(self,self._onBattleEvent))
    self:addChild(self._battleLayer)

end

function CrusadeBattleScene:onSceneEnter(...)
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
end

function CrusadeBattleScene:_onBattleEvent(event)
    local BattleLayer = require "app.scenes.battle.BattleLayer"
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
function CrusadeBattleScene:play()
    self._battleLayer:play()
end

return CrusadeBattleScene