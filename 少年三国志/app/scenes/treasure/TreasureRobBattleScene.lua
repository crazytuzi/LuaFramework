local TreasureRobBattleScene = class("TreasureRobBattleScene",UFCCSBaseScene)
function TreasureRobBattleScene:ctor(_,report,callback,...)
    self._report = report
    self._callback = callback
    self.super.ctor(self,...)
    local BattleLayer = require("app.scenes.battle.BattleLayer")
    local pack = {
        msg = report,
        skip = BattleLayer.SkipConst.SKIP_YES,
        battleBg=G_Path.getDungeonBattleMap(31001)
    }
    self._battleLayer = BattleLayer.create(pack,handler(self,self._onBattleEvent))
    self:addChild(self._battleLayer)
end

function TreasureRobBattleScene:onSceneEnter(...)
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
end

function TreasureRobBattleScene:play()
    self._battleLayer:play()
end


function TreasureRobBattleScene:_onBattleEvent(event)
    local BattleLayer = require "app.scenes.battle.BattleLayer"
    if event == BattleLayer.BATTLE_FINISH then
        if self._battleLayer ~= nil then
            local result = G_GlobalFunc.getBattleResult(self._battleLayer)
            if self._callback ~= nil then
            	self._callback(result)
            end
        end
    end 
end

return TreasureRobBattleScene