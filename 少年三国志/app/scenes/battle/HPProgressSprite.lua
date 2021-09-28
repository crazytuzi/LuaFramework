-- HPProgressSprite
-- 血量显示
local BattleConst = require("app.const.BattleConst")

local HPProgressSprite = class("HPProgressSprite", function (hp)
    return display.newNode()
end)

function HPProgressSprite:ctor(hp, hp_total)
    
    -- 血量, 默认100
    self._HPAmount = 100

    -- 绘制底色
    local background = display.newSprite(G_Path.getBattleImage("jingyantiao_red.png"))
    self:addChild(background)

    self:setAnchorPoint(ccp(0.5, 0.5))
    self:setContentSize(CCSizeMake(background:getContentSize().width, background:getContentSize().height))
    
    -- 修改背景图位置至居中
    background:setPosition(ccp(self:getContentSize().width / 2, self:getContentSize().height / 2))
    
    -- 前景色（血量条）
    local foreground = CCProgressTimer:create(display.newSprite(G_Path.getBattleImage("jingyantiao_green.png")))
    foreground:setType(kCCProgressTimerTypeBar)
    foreground:setMidpoint(ccp(0, 0))
    foreground:setBarChangeRate(ccp(1, 0));
    foreground:setAnchorPoint(ccp(0, 0.5))
    self:addChild(foreground)
    foreground:setPercentage(100)
    foreground:setPosition(ccp(0, self:getContentSize().height/2))
    self._foreground = foreground
    
    -- hp数字显示
if BattleConst.SHOW_HP_DETAIL == true then
    local label = ui.newTTFLabel({
        text = tostring(hp),
        font = "ui/font/FZYiHei-M20S.ttf",
        size = 32,
        align = ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
    })
    self:addChild(label)
    label:setColor(Colors.uiColors.YELLOW)
    label:setAnchorPoint(ccp(0, 0.5))
    label:setPosition(ccp(self:getContentSize().width + 10, 0))
    label:createStroke(Colors.strokeBrown, 2)
    self._hpLabel = label
end
    
    self._hpTotal = hp_total
    
    -- 设置总血量
    self._HPAmount = hp_total
    self._curHPCount = 0
    
    -- 最小血量显示(%)
    self._MIN_HP = 2
    
    self:changeProgress(hp - hp_total)
    
    -- 初始血量计数
    self._curHPCount = hp
    
    -- 透明度变化和颜色变化
    self:setCascadeOpacityEnabled(true)
    self:setCascadeColorEnabled(true)

if BattleConst.SHOW_HP_DETAIL == true then
    self._hpLabel:setString(hp_total)
end
end

function HPProgressSprite:changeProgress(value)
    local width = ((self._HPAmount * self._foreground:getPercentage() / 100 + value) / self._HPAmount) * 100
    if width <= self._MIN_HP and width > 0 then
        width = self._MIN_HP
    end
    self._foreground:setPercentage(width)
    self._curHPCount = math.max(0, math.min(self._curHPCount + value, self._hpTotal))

if BattleConst.SHOW_HP_DETAIL == true then
    self._hpLabel:setString(math.floor(self._curHPCount))
end
end

function HPProgressSprite:getHPAmount() return self._curHPCount end

return HPProgressSprite
