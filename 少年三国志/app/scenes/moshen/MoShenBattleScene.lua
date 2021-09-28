local MoShenBattleScene = class("MoShenBattleScene", UFCCSBaseScene)
local BattleLayer = require "app.scenes.battle.BattleLayer"
local FunctionLevelConst = require("app.const.FunctionLevelConst")
function MoShenBattleScene:ctor(level,report,mode,attack_multiple,finishFunc, harm, exploit, ...)
    self.super.ctor(self,...)
    --叛军等级
    self._level = level
    self._mode = mode
    self._attack_multiple = attack_multiple
    self._finishFunc = finishFunc
    self._harm = harm
    self._exploit = exploit
    local nSkipState = G_moduleUnlock:canPreviewModule(FunctionLevelConst.MOSHENG_BATTLE_SKIP) and BattleLayer.SkipConst.SKIP_YES or BattleLayer.SkipConst.SKIP_NO
    local pack = {
        battleType = BattleLayer.MOSHEN_BATTLE,
        attack_type=self._mode,
        attack_multiple=self._attack_multiple,
        msg = report,
        skip = nSkipState,
        battleBg=G_Path.getDungeonBattleMap(31012),
        knightLevel = level
    }
    
    self._battleField = BattleLayer.create(pack,handler(self,self._onBattleEvent))
    self:addChild(self._battleField)
    
    self._damage = 0
    
    -- 魔神（叛军）战斗中显示回合数，伤害，功勋等
    self._buff = require("app.scenes.moshen.MoShenBattleBuffLayer").create()
    self:addChild(self._buff)
    local winSize = CCDirector:sharedDirector():getWinSize()
    self._buff:setPosition(ccp(0, winSize.height/2))  
    
end


function MoShenBattleScene:onSceneEnter(...)
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
end

function MoShenBattleScene:_onBattleEvent(event, ...)
    -- 表示开场动画结束
    if event == BattleLayer.BATTLE_OPENING_FINISH then
        --self._battleField:pause()
        -- 魔神动画示例
        
        -- 魔神战斗显示
        local entrySets = require("app.scenes.battle.entry.Entry").new()
        
        local knights = self._battleField:getHeroKnight()
        
        -- 入口集
        local entrySet = require("app.scenes.battle.entry.Entry").new()
        
        local MoshenOpeningEntry = require "app.scenes.moshen.MoShenOpeningEntry"
        local moshenOpeningEntry = MoshenOpeningEntry.create(self._battleField)
        entrySet:addEntryToQueue(moshenOpeningEntry, moshenOpeningEntry.updateEntry)
        
        local MoshenAdditionEntry = require "app.scenes.moshen.MoShenAdditionEntry"
        for k, knight in pairs(knights) do
            local cardConfig = knight:getCardConfig()
            local additionEntry = MoshenAdditionEntry.create(cardConfig.advanced_level+1, knight, self._battleField)
            entrySet:addEntryToNewQueue(additionEntry, additionEntry.updateEntry)
        end
        
        entrySets:addEntryToQueue(entrySet, entrySet.updateEntry)
        
        entrySet = require("app.scenes.battle.entry.Entry").new()
        moshenOpeningEntry = MoshenOpeningEntry.create(self._battleField, self._mode)
        entrySet:addEntryToQueue(moshenOpeningEntry, moshenOpeningEntry.updateEntry)
        
        local MoshenAdditionEntry = require "app.scenes.moshen.MoShenAdditionEntry"
        for k, knight in pairs(knights) do
            local cardConfig = knight:getCardConfig()
            local additionEntry = MoshenAdditionEntry.create((cardConfig.advanced_level+1)*self._attack_multiple, knight, self._battleField)
            entrySet:addEntryToNewQueue(additionEntry, additionEntry.updateEntry)
        end
        
        entrySets:addEntryToQueue(entrySet, entrySet.updateEntry)
        
        -- 添加至当前队列的顶层，表示马上需要播放
        self._battleField:insertEntryToQueueAtTop(entrySets, entrySets.updateEntry)
        
        --战斗结束
    elseif event == BattleLayer.BATTLE_FINISH then
        self._buff:updateDamage(self._harm)

        if self._finishFunc ~= nil then 
            self._finishFunc() 
        else
            uf_sceneManager:popScene()
        end
        
    elseif event == BattleLayer.BATTLE_ROUND_UPDATE then
        local params = {...}
        self._round = params[1]
        self._buff:updateRound(params[1])
    elseif event == BattleLayer.BATTLE_DAMAGE_UPDATE then
        local params = {...}
        if params[1] == 2 then  -- 2表示是敌方
            self._damage = self._battleField:getKnightTotalHP(2) - self._battleField:getKnightCurrentHP(2)
            self._buff:updateDamage(self._damage)
        end
    end
    
end

function MoShenBattleScene:play()
    if self._battleField ~= nil  then
        self._battleField:play()
    end
end

return MoShenBattleScene
