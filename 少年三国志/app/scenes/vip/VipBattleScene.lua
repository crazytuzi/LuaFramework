local VipBattleScene = class("VipBattleScene", UFCCSBaseScene)
    
function VipBattleScene:ctor(msg, ...) 
    self.super.ctor(self, ...)
    self._battleField = require("app.scenes.battle.BattleLayer").create(
        {msg=msg.data.info, battleBg= msg.bg,skip = require("app.scenes.battle.BattleLayer").SkipConst.SKIP_NO}, handler(self, self._onBattleEvent))
    self._finishFunc = msg.func
    self:addChild(self._battleField)
    -- self._buff = require("app.scenes.vip.VipBattleBuffLayer").create()
    -- self:addChild(self._buff)
    local winSize = CCDirector:sharedDirector():getWinSize()
    -- self._buff:setPosition(ccp(0, winSize.height/2))  
    -- self:initBuff(msg.fightId)
end
    
function VipBattleScene:onSceneEnter(...)
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
end

-- function VipBattleScene:initBuff(mapId)
--     self._round = 0
--     self._damage = 0
--     self._totalHp = self._battleField:getKnightTotalHP(2)
--     self._buff:initData(mapId)
-- end

function VipBattleScene:_onBattleEvent(event,param1,param2,param3)
    local BattleLayer = require "app.scenes.battle.BattleLayer"
    -- print(event)
    if event == BattleLayer.BATTLE_FINISH then
        -- self._buff:updateRound(self._battleField:getRound())
        -- self._buff:updateDamage(self._totalHp - self._battleField:getKnightCurrentHP(2))
        if self._finishFunc ~= nil then 
            
            uf_eventManager:removeListenerWithTarget(self)
            
            self._finishFunc() 
        else
            uf_sceneManager:popScene()
        end
    elseif  event == BattleLayer.BATTLE_ROUND_UPDATE then
        -- self._round = param1
        -- self._buff:updateRound(param1)
    elseif  event == BattleLayer.BATTLE_DAMAGE_UPDATE then
        if param1 == 2 then
            -- self._damage = self._damage - param3
            -- self._buff:updateDamage(self._damage)
        end
    end
end
function VipBattleScene:play()
    self._battleField:play()
end
    
return VipBattleScene

