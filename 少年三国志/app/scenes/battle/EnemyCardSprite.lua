-- EnemyCardSprite

local EnemyCardSprite = class("EnemyCardSprite", require "app.scenes.battle.CardSprite")

function EnemyCardSprite:ctor(card, name, ...)
    EnemyCardSprite.super.ctor(self, card, name, ...)
    
    -- 敌方需要翻转
    local cardSprite = nil 
    local baseSprite = nil

    if g_target == kTargetWP8 or g_target == kTargetWinRT then
        local spriteChild = self._body._card:getChildren() or {}
        cardSprite = spriteChild[#spriteChild]

        spriteChild = self._body._base:getChildren() or {}
        baseSprite = spriteChild[#spriteChild]
    else
        cardSprite = self._body._card:getChildren():lastObject()
        baseSprite = self._body._base:getChildren():lastObject()
    end

    cardSprite:setScaleX(-1)
    local x, y = cardSprite:getPosition()
    cardSprite:setPosition(ccp(-x, y))
    
    -- 名字
--    local nameLabel = ui.newTTFLabel{
--        text = card.type == 1 and (name or card.name) or card.name,
--        font = G_Path.getBattleLabelFont(),
--        size = 26,
--        align = ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
--    }
    local nameLabel = Label:create()
    nameLabel:setFontName(G_Path.getBattleLabelFont())
    nameLabel:setFontSize(26)

    self:addChild(nameLabel)
    nameLabel:setPosition(ccp(0, 240))
    nameLabel:setColor(Colors.qualityColors[card.quality])
    nameLabel:createStroke(Colors.strokeBlack, 1)
    nameLabel:setText(name)
    
    self._name = nameLabel

end

return EnemyCardSprite