-- BossCardSprite

local BossCardSprite = class("BossCardSprite", require "app.scenes.battle.CardSprite")

function BossCardSprite:ctor(card, name, hp, hp_total, identity, position, anger, battleField)
    
    -- 卡牌信息，指的是根据服务器发来的卡牌id所对应的配置表里此武将的信息
    self._card = card
    -- identity and position
    self._identity = identity
    self._position = position
    
    self._anger = anger
    
    self.isBoss = true
    
    -- 战场容器
    self._battleField = battleField

    -- buff容器，用来存储buff，以唯一的id做键保存
    self._buffs = {}
    
    -- 呼吸动作开关
    self._breathEnabled = false
    
    -- Boss主体
    self._body = display.newNode()
    self._body:setCascadeOpacityEnabled(true)
    self._body:setCascadeColorEnabled(true)
    self:addChild(self._body)
    
    local SkeletonEntry = require "app.scenes.battle.entry.SkeletonEntry"
    local skeleton = SkeletonEntry.new({spId=card.is_boss}, nil, battleField)
    self._body:addChild(skeleton:getObject())
    skeleton:retainEntry()
    self._body._skeleton = skeleton
    
    -- 血条
    local HPProgressSprite = require "app.scenes.battle.HPProgressSprite"
    local hpSprite = HPProgressSprite.new(hp, hp_total)
    self:addChild(hpSprite)
    hpSprite:setPosition(ccp(0, 320))
    self._hpSprite = hpSprite
    
    -- 怒气
    local anger = display.newNode()
    self:addChild(anger)
    anger:setPositionX(anger:getParent():convertToNodeSpace(hpSprite:convertToWorldSpace(ccp(0, 0))).x - 4)   -- 跟血条左对齐
    anger:setPositionY(295)
    self._angerSprite = anger
    
    -- 名字
    local nameLabel = Label:create()
    nameLabel:setText(name)
    nameLabel:setFontName(G_Path.getBattleLabelFont())
    nameLabel:setFontSize(26)
    
    self:addChild(nameLabel)
    nameLabel:setPosition(ccp(0, 340))
    nameLabel:setColor(Colors.qualityColors[card.quality])
    nameLabel:createStroke(Colors.strokeBlack, 1)
    self._name = nameLabel
    
    -- 透明度变化和颜色变化
    self:setCascadeOpacityEnabled(true)
    self:setCascadeColorEnabled(true)
    
end

function BossCardSprite:getCardSprite() return self._body end

function BossCardSprite:destroy()
    self:clearAllAnger()
    self:delAllBuffs()
    
    self._body._skeleton:releaseEntry()
    
end

-- 重置位置等信息
function BossCardSprite:reset()
    self._body._skeleton:initEntry()
    self._body._skeleton:jumpToReady(true)
end

function BossCardSprite:getIdentity() return self._identity end
function BossCardSprite:getLocation() return self._position end

function BossCardSprite:setBreathAniEnabled(enabled)
    if enabled then
        self._body._skeleton:jumpToReady()
    end
end

function BossCardSprite:updateBreathAnimation() end

function BossCardSprite:update()
    
    BossCardSprite.super.update(self)
    
    if not self._stop then
        self._body._skeleton:updateEntry()
    end
end

function BossCardSprite:playAppear(eventHandler)
    self._body._skeleton:setEventHandler(eventHandler)
    return self._body._skeleton:jumpToAppear(false)
end

function BossCardSprite:playAttack(eventHandler)
    self._body._skeleton:setEventHandler(eventHandler)
    return self._body._skeleton:jumpToAttack(false)
end

function BossCardSprite:playCont(eventHandler)
    self._body._skeleton:setEventHandler(eventHandler)
    return self._body._skeleton:jumpToCont(false)
end

function BossCardSprite:playHit(eventHandler)
    self._body._skeleton:setEventHandler(eventHandler)
    return self._body._skeleton:jumpToHit(false)
end

function BossCardSprite:playDead(eventHandler)
    self._body._skeleton:setEventHandler(eventHandler)
    return self._body._skeleton:jumpToDead(false)
end

function BossCardSprite:stop() self._stop = true end

return BossCardSprite
