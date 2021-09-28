local HPProgressSprite = require "app.scenes.battle.HPProgressSprite"

local DailyPvpHpSprite = class("DailyPvpHpSprite", function (hp,totalHp)
    return display.newNode()
end)

function DailyPvpHpSprite:resetHp( totalHp )
	self._HPAmount = totalHp
	self._curHPCount = totalHp
	self._hpTotal = totalHp
	
	self._foreground:setPercentage(100)
end

function DailyPvpHpSprite:ctor(hp, hp_total)
    
    -- 血量, 默认100
    self._HPAmount = 100

    -- 绘制底色
    local background = ImageView:create()
    background:loadTexture("ui/moshen/pj_jindutiao_hong.png")
    self:addChild(background)

    self:setAnchorPoint(ccp(0.5, 0.5))
    self:setContentSize(CCSizeMake(background:getContentSize().width, background:getContentSize().height))
    
    -- 修改背景图位置至居中
    background:setPosition(ccp(self:getContentSize().width / 2, self:getContentSize().height / 2))
    
    -- 前景色（血量条）
    local foreground = CCProgressTimer:create(display.newSprite("ui/moshen/pj_jindutiao_lv.png"))
    foreground:setType(kCCProgressTimerTypeBar)
    foreground:setMidpoint(ccp(0, 0))
    foreground:setBarChangeRate(ccp(1, 0));
    foreground:setAnchorPoint(ccp(0.5, 0.5))
    background:addNode(foreground)
    foreground:setPercentage(100)
    foreground:setPosition(ccp(0, 0))
    self._foreground = foreground
    
    self._hpTotal = hp_total
    
    -- 设置总血量
    self._HPAmount = hp_total
    self._curHPCount = 0
    
    -- 最小血量显示(%)
    self._MIN_HP = 0
    
    self:changeProgress(hp - hp_total)
    
    -- 初始血量计数
    self._curHPCount = hp
    
    -- 透明度变化和颜色变化
    self:setCascadeOpacityEnabled(true)
    self:setCascadeColorEnabled(true)

end

function DailyPvpHpSprite:changeProgress(value)
    local width = ((self._HPAmount * self._foreground:getPercentage() / 100 + value) / self._HPAmount) * 100
    if width <= self._MIN_HP and width > 0 then
        width = self._MIN_HP
    end
    self._foreground:setPercentage(width)
    self._curHPCount = math.max(0, math.min(self._curHPCount + value, self._hpTotal))
    -- print("changeHp",self._curHPCount,self._HPAmount)
end

return DailyPvpHpSprite
