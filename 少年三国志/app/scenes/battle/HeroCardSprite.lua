-- HeroCardSprite

require "app.cfg.play_info"

local HeroCardSprite = class("HeroCardSprite", require "app.scenes.battle.CardSprite")

function HeroCardSprite:ctor(card, name, ...)
    
    HeroCardSprite.super.ctor(self, card, name, ...)
    
    -- 名字
--    local nameLabel = ui.newTTFLabel{
--        text = card.type == 1 and (name or G_Me.userData.name) or card.name,
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

return HeroCardSprite