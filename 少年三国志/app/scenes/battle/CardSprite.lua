-- CardSprite

require "app.cfg.knight_info"
require "app.cfg.buff_info"
require "app.cfg.dress_info"
require "app.cfg.item_cloth_info"
require "app.cfg.ksoul_fight_base_info"

local BattleFieldConst = require "app.scenes.battle.BattleFieldConst"


local CardSprite = class("CardSprite", function(...)
    return display.newNode()
end)

-- #param description
-- clid:        clothes id（主角换装id）
-- battleBase:  battle-base id（战斗底座id）
function CardSprite:ctor(card, name, hp, hp_total, identity, position, anger, battleField, dress_id, awakenLevel , clid, battleBase)
    
    -- 卡牌信息，指的是根据服务器发来的卡牌id所对应的配置表里此武将的信息
    self._card = clone(card)
    -- 默认时装
    self._card.dress_id = 0
    -- 名字用传进来的
    self._card.name = name
    
    -- 如果有包含dress_id则播放组需要更换
    if dress_id and dress_id ~= 0 then
        self._card.dress_id = dress_id
        local dressInfo = dress_info.get(dress_id)
        assert(dressInfo, "Could not find the dress info with id: "..dress_id)
        self._card.play_group_id = dressInfo.play_group_id
    end
    
    -- identity and position
    self._identity = identity
    self._position = position
    
    self._anger = anger
    self._angerChangeDelay = 0 -- 战斗中怒气变化显示会延迟，用此变量记录将要变化的怒气
    
    -- 战场容器
    self._battleField = battleField
    
    -- 武将主容器
    self._body = display.newNode()
    self._body:setCascadeOpacityEnabled(true)
    self._body:setCascadeColorEnabled(true)
    self:addChild(self._body)
    
    -- buff容器，用来存储buff，以唯一的id做键保存
    self._buffs = {}
    
    -- 这里直接按照添加顺序来排定层级关系
    
    -- 底座
    self._body._base = display.newNode()
    self._body._base:setCascadeOpacityEnabled(true)
    self._body._base:setCascadeColorEnabled(true)
    self._body:addChild(self._body._base, 0)
    
    -- 牌面
    self._body._card = display.newNode()
    self._body._card:setCascadeOpacityEnabled(true)
    self._body._card:setCascadeColorEnabled(true)
    self._body:addChild(self._body._card, 3)
    
    -- 呼吸动作开关
    self._breathEnabled = false

    -- 武将底座部分
    battleBase     = battleBase or 1
    local baseInfo = ksoul_fight_base_info.get(battleBase)
    local baseImg  = "base_" .. (identity == 1 and baseInfo.own_image or baseInfo.enemy_image) .. ".png"
    local cardBase = CCSpriteLighten:create(G_Path.getBattleConfigImage('base', baseImg))
    local baseJson = decodeJsonFile(G_Path.getBattleConfig('base', "base_1"))

    cardBase:setPosition(ccp(baseJson.x, baseJson.y))
    self._body._base:addChild(cardBase)
    self._body._base.setColorOffsetRGBA = function(_, r, g, b, a)
        cardBase:setColorOffsetRGBA(r, g, b, a)
--        cardBase:setShaderProgram(CCShaderCache:sharedShaderCache():programForKey(G_ColorShaderManager:getShaderKey(colorOffset.r, colorOffset.g, colorOffset.b)))
    end
    self._body._base.getColorRGBA = function()
        return cardBase:getColorRGBA()
    end
    
    -- 武将牌面
    -- 时装资源
    if clid and clid ~= 0 then 
        self._card.res_id = item_cloth_info.get(clid).res_id
    else 
        self._card.res_id = (dress_id and dress_id ~= 0) and G_Me.dressData:getDressedResidWithDress(card.id, dress_id) or card.res_id
    end 
    local cardJson = decodeJsonFile(G_Path.getBattleConfig("knight", self._card.res_id.."_fight"))
    local cardSprite = CCSpriteLighten:create(G_Path.getBattleConfigImage("knight", self._card.res_id..'.png'))
--    local cardSprite = display.newSprite(G_Path.getBattleConfigImage("knight", cardResId))
    cardSprite:setScaleX(cardJson.scaleX)
    cardSprite:setScaleY(cardJson.scaleY)
    cardSprite:setPosition(ccp(cardJson.x, cardJson.y))
    self._body._card:addChild(cardSprite)
    self._body._card.setColorOffsetRGBA = function(_, r, g, b, a)
        cardSprite:setColorOffsetRGBA(r, g, b, a)
--        cardSprite:setShaderProgram(CCShaderCache:sharedShaderCache():programForKey(G_ColorShaderManager:getShaderKey(colorOffset.r, colorOffset.g, colorOffset.b)))
    end
    self._body._card.getColorRGBA = function()
        return cardSprite:getColorRGBA()
    end
    self._body._card.getCardSpriteHeightInWorldSpace = function()
        return cardSprite:convertToWorldSpaceAR(ccp(0, cardSprite:getContentSize().height/2)).y
    end
    
    -- 血条
    local HPProgressSprite = require "app.scenes.battle.HPProgressSprite"
    local hpSprite = HPProgressSprite.new(hp, hp_total)
    self:addChild(hpSprite)
    hpSprite:setPosition(ccp(0, 220))
    self._hpSprite = hpSprite

    -- 怒气
    local anger = display.newNode()
    self:addChild(anger)
    anger:setPositionXY(-55, 195)
    self._angerSprite = anger
    
    local _awakenStar = math.floor(awakenLevel / 10)
    if _awakenStar > 0 then
        -- 觉醒星数
        self._awakenStar = display.newNode()
        self._awakenStar:setPositionXY(-72, 208)
        self:addChild(self._awakenStar)
        
        local awakenStar = display.newSprite(G_Path.getUIImage("yangcheng", "star_juexing.png"))
        self._awakenStar:addChild(awakenStar)
        awakenStar:setScale(1.3)

        local awakenLabel = Label:create()
        awakenLabel:setFontName(G_Path.getBattleLabelFont())
        awakenLabel:createStroke(Colors.strokeBrown, 2)
        awakenLabel:setFontSize(26)
        awakenLabel:setText(_awakenStar)
        awakenLabel:setColor(Colors.lightColors.TITLE_01)
        awakenLabel:setPositionXY(-1, -2)
        self._awakenStar:addChild(awakenLabel)
    end
    
    -- 透明度变化和颜色变化
    self:setCascadeOpacityEnabled(true)
    self:setCascadeColorEnabled(true)
    
end

function CardSprite:destroy()
    self:clearAllAnger()
    self:delAllBuffs()
    
    if self._breathEntry then
        self._breathEntry:releaseEntry()
        self._breathEntry = nil
    end
end

-- 重置位置等信息
function CardSprite:reset()

    self._body._card:setPosition(ccp(0, 0))
    self._body._card:setRotation(0)
    self._body._card:setOpacity(255)
    self._body._card:setScale(1)
    self._body._card:setColorRGB(255, 255, 255)
    self._body._card:setColorOffsetRGBA(0, 0, 0, 0)
    
    self._body._base:setPosition(ccp(0, 0))
    self._body._base:setRotation(0)
    self._body._base:setOpacity(255)
    self._body._base:setScale(1)
    self._body._base:setColorRGB(255, 255, 255)
    self._body._base:setColorOffsetRGBA(0, 0, 0, 0)
    
end

function CardSprite:getCardBody() return self._body end
function CardSprite:getCardConfig() return self._card end
function CardSprite:getCardSprite() return self._body._card end
function CardSprite:getCardBase() return self._body._base end

function CardSprite:getIdentity() return self._identity end
function CardSprite:getLocation() return self._position end

function CardSprite:changeHp(damage) self._hpSprite:changeProgress(damage) end
function CardSprite:getHPAmount() return self._hpSprite:getHPAmount() end
function CardSprite:isDead() return self._isDead end
function CardSprite:setIsDead() self._isDead = true return true end

function CardSprite:setHPVisible(visible) self._hpSprite:setVisible(visible) end
function CardSprite:isHPVisible() return self._hpSprite:isVisible() end

function CardSprite:setNameVisible(visible) self._name:setVisible(visible) end
function CardSprite:isNameVisible() return self._name:isVisible() end

function CardSprite:setAngerVisible(visible) self._angerSprite:setVisible(visible) end
function CardSprite:isAngerVisible() return self._angerSprite:isVisible() end

function CardSprite:setAwakenStarVisible(visible) if self._awakenStar then self._awakenStar:setVisible(visible) end end
function CardSprite:isAwakenStarVisible() return self._awakenStar and self._awakenStar:setVisible(visible) or false end

function CardSprite:getCardName() return self._card.name end

function CardSprite:setBreathAniEnabled(enabled)
    if self._breathEnabled ~= enabled then
        self._body._card:setScale(1)
        self._breathEnabled = enabled
    end
end

function CardSprite:update()
    
    -- 更新buff
    self:updateBuff()
    
    -- 更新怒气
    self:updateAnger()
    
end

function CardSprite:updateBreathAnimation()
    -- 更新呼吸动作
    if self._breathEnabled then
        if not self._breathEntry then
            local ActionEntry = require "app.scenes.battle.entry.ActionEntry"
            self._breathEntry = ActionEntry.new(BattleFieldConst.action.IDLE, self, self._battleField)
            self._breathEntry:retainEntry()
        end
        
        local finish = self._breathEntry:updateEntry()
        if finish then
            self._breathEntry:initEntry()
        end
    end
end

-- buff

function CardSprite:updateBuff()

    -- 更新buff显示, 不同组同步显示
    for i=1, #self._buffs do
        -- 同组切换显示
        local buff = self._buffs[i][1]
        -- 更新buff
        
        if buff.display then
            local finish = buff.display:updateEntry()
            if finish then
                buff.display:initEntry()
                buff.display:getObject():removeFromParent()
                table.remove(self._buffs[i], 1)
                table.insert(self._buffs[i], #self._buffs[i]+1, buff)
                local newBuff = self._buffs[i][1]
                if newBuff.display and not newBuff.display:getObject():isRunning() then
--                    self._battleField:addToBuffSpNode(newBuff.display:getObject())
                    self:addChild(newBuff.display:getObject())
                    newBuff.display:updateEntry()
                end
            end
        else
            table.remove(self._buffs[i], 1)
            table.insert(self._buffs[i], #self._buffs[i]+1, buff)
            local newBuff = self._buffs[i][1]
            if newBuff.display then
                if not newBuff.display:getObject():isRunning() then
--                    self._battleField:addToBuffSpNode(newBuff.display:getObject())
                    self:addChild(newBuff.display:getObject())
                    newBuff.display:updateEntry()
                end
            end
        end
    end    
end

function CardSprite:addBuff(buff)

    for i=1, #self._buffs do
        for j=1, #self._buffs[i] do
            if buff.id == self._buffs[i][j].id then
                return
            end
        end
    end
    
    -- 保存buff
    local buffConfig = buff_info.get(buff.buff_id)
    if not buffConfig then 
        return 
    end

    local buffs = nil
    for i=1, #self._buffs do
        if self._buffs[i]._resGroup == buffConfig.res_group then
            buffs = self._buffs[i]
        end
    end
    
    if not buffs then
        buffs = {_resGroup = buffConfig.res_group}
        self._buffs[#self._buffs+1] = buffs
    end
        
    local _buff = {}
    buffs[#buffs+1] = _buff
    _buff.id = buff.id
    _buff.buff_id = buff.buff_id
    
    if buffConfig.res_id ~= "" then
--        local CardSpEntry = require "app.scenes.battle.entry.CardSpEntry"
--        local buffEntry = CardSpEntry.new({spId = buffConfig.res_id, x=0, y=0, scaleX=1, scaleY=1}, self, self._battleField)
--        self._battleField:addToBuffSpNode(buffEntry:getObject())
        
        local SpEntry = require "app.scenes.battle.entry.SpEntry"
        local buffEntry = SpEntry.new({spId = buffConfig.res_id, x=0, y=0, scaleX=1, scaleY=1}, self, self._battleField)
        self:addChild(buffEntry:getObject())
        buffEntry:setPositionXY(0, 0)

        buffEntry:retainEntry()
        _buff.display = buffEntry
    end
    
    -- buff表现文字
    local BuffDescEntry = require "app.scenes.battle.entry.BuffDescEntry"
    local buffDescEntry = BuffDescEntry.new(buff, nil, self, self._battleField)
    self._battleField:addEntryToQueue(buffDescEntry, buffDescEntry.updateEntry, nil, "buff"..self._identity..self._position)
    
    _buff.desc = buffDescEntry
    
end

function CardSprite:delBuff(id)
    
    local removeBuffPos1 = nil
    local removeBuffPos2 = nil
    for i=1, #self._buffs do
        for j=1, #self._buffs[i] do
            if id == self._buffs[i][j].id then
                removeBuffPos1 = i
                removeBuffPos2 = j
                if self._buffs[i][j].display then
                    self._buffs[i][j].display:releaseEntry()
                    self._buffs[i][j].display = nil
                end
                if self._buffs[i][j].desc and not self._buffs[i][j].desc:isDone() then
                    self._buffs[i][j].desc:stop()
                    self._buffs[i][j].desc = nil
                end
                break
            end
        end
    end
    
    assert(removeBuffPos1 and removeBuffPos2, "Could not find some buff with id: "..id.." from myself: "..tostring(self))
    
    if removeBuffPos1 and removeBuffPos2 then
        table.remove(self._buffs[removeBuffPos1], removeBuffPos2)
    end
    
    if removeBuffPos1 and #self._buffs[removeBuffPos1] == 0 then
        table.remove(self._buffs, removeBuffPos1)
    end
    
end

function CardSprite:delAllBuffs()
    for i=1, #self._buffs do
        for j=1, #self._buffs[i] do
            if self._buffs[i][j].display then
                self._buffs[i][j].display:releaseEntry()
                self._buffs[i][j].display = nil
            end
            if self._buffs[i][j].desc and not self._buffs[i][j].desc:isDone() then
                self._buffs[i][j].desc:stop()
                self._buffs[i][j].desc = nil
            end
        end
    end
    self._buffs = {}
    return true
end

function CardSprite:getBuff(id)
    for i=1, #self._buffs do
        for j=1, #self._buffs[i] do
            if id == self._buffs[i][j].id then
                return self._buffs[i][j]
            end
        end
    end
end

--function CardSprite:_updateBuffPosition()
--    for i=1, #self._buffs do
--        for j=1, #self._buffs[i] do
--            -- 更新buff显示位置
----            self._buffs[i][j].display:getObject():setPosition(ccp(self:convertToWorldSpaceAR(ccp(0, 0))))
--            if self._buffs[i][j].display then
--                self._buffs[i][j].display:setPosition(ccp(0, 0))
--            end
--            
--            -- 更新buff描述显示位置
--            if self._buffs[i][j].desc and self._buffs[i][j].desc:getObject() then
--                local object = self._buffs[i][j].desc:getObject()
--                local position = ccpSub(ccp(self:getPosition()), ccp(object:getPosition()))
--                object:setPosition(ccpAdd(ccp(object:getPosition()), position))
--            end
--        end
--    end
--end

-- anger

function CardSprite:updateAnger()
        
    if not self._angerSprite._display then
        -- 怒气
        local AngerSprite = require "app.scenes.battle.AngerSprite"
        local anger = AngerSprite.new(self._anger, self._battleField)
        anger:setAnchorPoint(ccp(0, 0.5))
        self._angerSprite:addChild(anger)
        self._angerSprite._display = anger
    end

    self._angerSprite._display:updateAnger()
end

function CardSprite:resetAnger(anger)
    if self._angerSprite._display then
        self._angerSprite._display:resetAnger(anger)

        -- 一旦更新过怒气，那么记录过的延迟怒气变化就失效
        self._angerChangeDelay = 0
    end
end

function CardSprite:clearAllAnger()
    if self._angerSprite._display then
        self._angerSprite._display:clearAllAnger()
    end
end

function CardSprite:addAnger(anger)
    local angerAmount = self._angerSprite._display:getAngerAmount()
    self._angerSprite._display:resetAnger(angerAmount + anger)
end

-- 记录下将要变化的怒气值
function CardSprite:setAngerChangeDelay(anger)
    self._angerChangeDelay = anger
end

-- 使用记录过的延迟怒气值作计算，如果为0，则什么也不做
function CardSprite:addAngerChangeDelay()
    if self._angerChangeDelay ~= 0 then
        self:addAnger(self._angerChangeDelay)
    end
end

function CardSprite:setPositionXY(positionX, positionY)
    if positionX ~= self:getPositionX() or positionY ~= self:getPositionY() then
        -- 设置父类的方法
        local child = nil
        local parent = nil
        repeat
            child = parent or self
            parent = getmetatable(child)
        until not parent or parent.setPositionXY
        
        assert(parent, "could not invoke the method: setPosition")
        
        parent.setPositionXY(self, positionX, positionY)
        -- 更新buff，这里主要是更新buff的位置
--        self:_updateBuffPosition()
    end
end

return CardSprite
