local WushBattleScene = class("BattleScene", UFCCSBaseScene)
    
local BattleLayer = require "app.scenes.battle.BattleLayer"

function WushBattleScene:ctor(msg, ...) 
    self.super.ctor(self, ...)
    self._battleField = BattleLayer.create(
        {msg=msg.data.battle_report, battleBg= msg.bg,skip = BattleLayer.SkipConst.SKIP_YES}, handler(self, self._onBattleEvent))
    self._finishFunc = msg.func
    self._finishFunc2 = msg.func2
    -- self._battleField:play()
    self:addChild(self._battleField)
    self._buff = require("app.scenes.wush.WushBattleBuffLayer").create(self._battleField)
    self:addChild(self._buff)
    local winSize = CCDirector:sharedDirector():getWinSize()
    self._buff:setPosition(ccp(0, winSize.height/2+50))  
    self:initBuff(msg.floor)
end
    
function WushBattleScene:onSceneEnter(...)
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
end

function WushBattleScene:_onBattleEvent(event,param1,param2,param3)
    -- print(event)
    if event == BattleLayer.BATTLE_FINISH then
        self._buff:updateRound(self._battleField:getRound())
        self._buff:updateSelfHp(string.format("%.1f", self._battleField:getKnightCurrentHP(1)/self._selfHp*100).."%")
        self._buff:updateEnemyHp(string.format("%.1f", self._battleField:getKnightCurrentHP(2)/self._enemyHp*100).."%")
        self._buff:updateSelfDead(self._battleField:getHeroKnightUpAmount() - self._battleField:getLeftHeroKnightAmount())
        if self._finishFunc ~= nil then 
            uf_eventManager:removeListenerWithTarget(self)
            local result = G_GlobalFunc.getBattleResult(self._battleField)
            self._finishFunc(result,self._finishFunc2) 
        end
    elseif  event == BattleLayer.BATTLE_ROUND_UPDATE then
        -- print("BATTLE_ROUND_UPDATE "..param1)
        self._round = param1
        self._buff:updateRound(param1)
    elseif  event == BattleLayer.BATTLE_DAMAGE_UPDATE then
        -- print("BATTLE_DAMAGE_UPDATE "..param1.." "..param3)
        -- print("BATTLE_DAMAGE_UPDATE "..param1.." "..param3)
        -- print("self._curSelfHp "..self._battleField:getKnightCurrentHP(1))
        -- print("self._curEnemyHp "..self._battleField:getKnightCurrentHP(2))
        self._buff:updateSelfHp(string.format("%.1f", self._battleField:getKnightCurrentHP(1)/self._selfHp*100).."%")
        self._buff:updateEnemyHp(string.format("%.1f", self._battleField:getKnightCurrentHP(2)/self._enemyHp*100).."%")
    elseif  event == BattleLayer.BATTLE_SOMEONE_DEAD then   
        -- print("BATTLE_SOMEONE_DEAD "..param1)
        if param1 == 1 then
            self._selfDead = self._selfDead + 1
            self._buff:updateSelfDead(self._selfDead)
        end
    end
end
function WushBattleScene:play()
    self._battleField:play()
end

function WushBattleScene:initBuff(floor)
    self._round = 0
    self._selfDead = 0
    self._selfHp = self._battleField:getKnightTotalHP(1)
    self._enemyHp = self._battleField:getKnightTotalHP(2)
    -- print("self._selfHp: "..self._selfHp)
    -- print("self._enemyHp: "..self._enemyHp)
    -- self._curSelfHp = self._selfHp
    -- self._curEnemyHp = self._enemyHp
    self._buff:initData(floor)
    self._buff:updateSelfHp("100.0%")
    self._buff:updateEnemyHp("100.0%")
end
    
return WushBattleScene

