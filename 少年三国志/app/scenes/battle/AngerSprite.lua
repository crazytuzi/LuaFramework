-- AngerSprite

local MAX_ANGER = 12        -- 最大怒气值
local MAX_ANGER_DISPLAY = 4 -- 最大怒气显示数

local BattleFieldConst = require "app.scenes.battle.BattleFieldConst"


local AngerSprite = class("AngerSprite", function(...)
    return display.newNode()
end)

function AngerSprite:ctor(anger, battleField)
    
    self._battleField = battleField
    
    self:setAnchorPoint(ccp(0.5, 0.5))
    
    -- 用来存放anger怒气显示的数组
    self._angerSprite = {}
    
    -- 用来显示怒气动画的数组
    self._angerEntry = {}
    
    -- 初始化空心的怒气图标，返回创建完怒气后的尺寸
    local size = self:_initEmptyAnger()
    
    self:setContentSize(size)

    self:addAnger(anger)
    
end

function AngerSprite:_initEmptyAnger()

    -- 默认怒气数
    self._angerAmount = 0
    
    local size = CCSizeMake(0, 0)
    local img = G_Path.getBattleImage('nuqi_black.png')
    
    -- 初始化显示(空怒气图标)
    for i=1, MAX_ANGER_DISPLAY do
        
        local sprite = display.newSprite(img)
        self:addChild(sprite)
        local spriteSize = sprite:getContentSize()

        sprite:setPosition(ccp((i-1) * (spriteSize.width+3) + spriteSize.width/2, spriteSize.height/2))
        size.width = i * (spriteSize.width+3)
        size.height = math.max(size.height, spriteSize.height)
        
        self._angerSprite[i] = sprite 
    end
    
    return size
    
end

function AngerSprite:getAngerAmount() return self._angerAmount end

function AngerSprite:addAnger(anger)
    
    local total = math.max(anger + self._angerAmount, 0)
--    assert(total <= MAX_ANGER, "anger could not be "..total)
    
    self._angerAmount = math.min(total, MAX_ANGER)
    
    for i=1, math.min(#self._angerSprite, self._angerAmount) do
        local sprite = self._angerSprite[i]
        
        sprite:setVisible(true)
        sprite:setDisplayFrame(display.newSprite(G_Path.getBattleImage(i <= self._angerAmount and "nuqi_blue.png" or "nuqi_black.png")):getDisplayFrame())
        
        if self._angerAmount >= MAX_ANGER_DISPLAY then
            
            if not self._angerEntry[self._angerSprite[i]] then
                local spName = BattleFieldConst.sp.ANGER

                -- sp特效
                local SpEntry = require "app.scenes.battle.entry.SpEntry"
                local positionX, positionY = sprite:getPosition()
                local spJson = {
                    spId = spName,
                    x = positionX,
                    y = positionY,
                    scaleX = 1,
                    scaleY = 1
                }
                local spEntry = SpEntry.new(spJson, self, self._battleField)
                self:addChild(spEntry:getObject())
                spEntry:retainEntry()

                sprite:setVisible(false)
                self._angerEntry[self._angerSprite[i]] = spEntry
            end
        else
            if self._angerEntry[self._angerSprite[i]] then
                self._angerEntry[self._angerSprite[i]]:releaseEntry()
                self._angerEntry[self._angerSprite[i]] = nil
            end
        end
    end
    
    if self._angerAmount > MAX_ANGER_DISPLAY then
        
        if not self._angerCount then

            -- 如果怒气值多余最大显示数目，则后面用xX这样来表示
    --        local label = ui.newTTFLabel{
    --            text = "x"..total,
    --            font = G_Path.getBattleLabelFont(),
    --            size = 24,
    --            align = ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
    --        }
            local label = Label:create()
            label:setFontName(G_Path.getBattleLabelFont())
            label:setFontSize(24)
            label:setColor(Colors.uiColors.YELLOW)
            label:createStroke(Colors.strokeBlack, 1)
            label:setText("x"..self._angerAmount)

            self:addChild(label)
            label:setPosition(ccp(label:getContentSize().width/2 + self:getContentSize().width, self:getContentSize().height/2))

            self._angerCount = label
        else
            self._angerCount:setText("x"..self._angerAmount)
        end
    end
    
end

function AngerSprite:updateAnger()
    for i=1, MAX_ANGER_DISPLAY do
        if self._angerEntry[self._angerSprite[i]] then
            self._angerEntry[self._angerSprite[i]]:updateEntry()
        end
    end
end

function AngerSprite:clearAllAnger()
    
    self:unscheduleUpdate()
    
    -- 清理sp集
    for i=1, #self._angerSprite do
        if self._angerEntry[self._angerSprite[i]] then
            self._angerEntry[self._angerSprite[i]]:releaseEntry()
            self._angerEntry[self._angerSprite[i]] = nil
        end
        self._angerSprite[i]:removeFromParent()
        self._angerSprite[i] = nil
    end
    
    self._angerAmount = 0
    
    if self._angerCount then
        self._angerCount:removeFromParent()
        self._angerCount = nil
    end

end

function AngerSprite:resetAnger(anger)
    
    self:clearAllAnger()
    self:_initEmptyAnger()
    self:addAnger(anger)
    
end

return AngerSprite
