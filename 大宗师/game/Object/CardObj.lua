--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-23
-- Time: 下午2:23
-- To change this template use File | Settings | File Templates.
--
local data_config_config = require("data.data_config_config")

local CardObj = class("CardObj", function()
    local proxy = CCBProxy:create()
    local rootnode = {}
    local bg = CCBuilderReaderLoad("formation/formation_cardobj.ccbi", proxy, rootnode)
    bg._rootnode = rootnode
    return bg
end)

function CardObj:ctor(param)
    local _id = param.id
    local _cls = param.cls
    local _lv  = param.lv
    local _star = param.star or 1

    self.getLv = function()
        return _lv
    end

    self:setDisplayFrame(display.newSpriteFrame(string.format("zhenxing_card_%d.png", tostring(ResMgr.getCardData(_id)["star"][_cls + 1]))))
    for i = 1, 5 do
        if i <= _star then
            self._rootnode[string.format("star%d", i)]:setVisible(true)
        else
            self._rootnode[string.format("star%d", i)]:setVisible(false)
        end
    end

    local card = ResMgr.getCardData(_id)
    local heroImg = card["arr_image"][_cls + 1]
    local heroPath = CCFileUtils:sharedFileUtils():fullPathForFilename(ResMgr.getMidImage(heroImg, ResMgr.HERO))

    if io.exists(heroPath) then
        local sprite = display.newSprite(heroPath)
        sprite:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + data_config_config[1].zhenxingoffy)
        self:addChild(sprite)
--        sprite:setScale(self:getContentSize().height / sprite:getContentSize().height + 0.02)
    else
        local label = ui.newTTFLabel({
            text = ResMgr.getMidImage(heroImg, ResMgr.HERO),
            size = 18,
            color = ccc3(255, 0, 0)
        })
        label:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self:addChild(label)
    end

    self.getResId = function(_)
        return _id
    end

    self.getName = function(_)
        return card.name
    end

    self.getCls = function(_)
        return _cls
    end

    self.getStar = function(_)
        return _star
    end

end
--
return CardObj

