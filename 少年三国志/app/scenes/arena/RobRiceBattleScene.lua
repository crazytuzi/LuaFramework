local RobRiceBattleScene = class("RobRiceBattleScene",UFCCSBaseScene)
function RobRiceBattleScene:ctor(_,report,enemyData,callback,...)
    self._enemyData = enemyData
    self._report = report
    self._callback = callback
    self.super.ctor(self,...)
    
    local BattleLayer = require("app.scenes.battle.BattleLayer")
    local pack = {
        enemy = self._enemyData,
        msg = report,
        skip = BattleLayer.SkipConst.SKIP_YES,
        battleBg=G_Path.getDungeonBattleMap(31003),
        battleType=BattleLayer.ROBRICE_BATTLE
    }

    self._battleLayer = BattleLayer.create(pack,handler(self,self._onBattleEvent))
    self:addChild(self._battleLayer)
    --
end

function RobRiceBattleScene:onSceneEnter(...)
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
end

function RobRiceBattleScene:_onBattleEvent(event)
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
function RobRiceBattleScene:play()
    self._battleLayer:play()
end

return RobRiceBattleScene