--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-10
-- Time: 下午5:52
-- To change this template use File | Settings | File Templates.
--
local data_item_item = require("data.data_item_item")
local SpiritIcon = class("SpiritIcon", function()
    return display.newNode()
end)



function SpiritIcon:ctor(param)

--    id, name, quality, lv, exp, listener
--    dump(param)
    display.addSpriteFramesWithFile("ui/ui_spirit.plist", "ui/ui_spirit.png")

    local _id      = param.id
    local _resId   = param.resId
    local _lv      = param.lv or 0
    local _exp     = param.exp or 0

    local _bShowName = param.bShowName
    local _bShowNameBg = param.bShowNameBg
    local _bShowLv   = param.bShowLv
    local _nameOffsetY = param.offsetY or 0
    local _baseInfo = data_item_item[_resId]
    local bNum = param.bNum

    self.getResID = function()
        return _resId
    end

    self.getID = function()
        return _id
    end

    self.getQuality = function()
        return _baseInfo.quality
    end

    self.getLV = function()
        return _lv
    end

    self.getCurExp = function()
        return _exp
    end

    local sprite = display.newSprite("#spirit_jy_icon_board.png")
    self:addChild(sprite)

    local _sz = sprite:getContentSize()

    if _bShowLv then
        local lvBoard = display.newSprite("#spirit_jy_icon_num.png")
        lvBoard:setPosition(sprite:getContentSize().width - lvBoard:getContentSize().width / 2, lvBoard:getContentSize().height / 2)
        sprite:addChild(lvBoard, 2)


        local lvLabel = ui.newTTFLabelWithOutline({
            text = tostring(_lv),
            font = FONTS_NAME.font_fzcy,
            size =20,
            align = ui.TEXT_ALIGN_CENTER
        })
        lvLabel:setPosition(lvBoard:getContentSize().width * 0.4, lvLabel:getContentSize().height * 0.86)
        lvBoard:addChild(lvLabel)
    end

    local animSprite = ResMgr.createArma({
        resType = ResMgr.SPIRIT,
        armaName = _baseInfo.icon,
        isRetain = true
    })
    sprite:addChild(animSprite)

    local name = _baseInfo.name
    if _bShowName then
        name = _baseInfo.name
    else
        name = ""
    end

    if bNum then
    	name = name.."x"..bNum
    end

    if _bShowNameBg then
        local nameBg = display.newSprite("#spirit_name_bg.png")
        nameBg:setPosition(_sz.width / 2, nameBg:getContentSize().height / 2 + _nameOffsetY - 3.5)
        self:addChild(nameBg)
    end



    local nameLabel = ui.newTTFLabelWithOutline({
        text = name,
        font = FONTS_NAME.font_fzcy,
        size =20,
        color = QUALITY_COLOR[_baseInfo.quality or 1],
        align = ui.TEXT_ALIGN_CENTER,
    })
    self:addChild(nameLabel)
    local szH = _sz.height + nameLabel:getContentSize().height
    self:setContentSize(CCSizeMake(_sz.width, szH))
    self:setAnchorPoint(0.5, 0.5)

    nameLabel:setPosition(_sz.width / 2, nameLabel:getContentSize().height / 2 + _nameOffsetY)
    sprite:setPosition(_sz.width / 2, szH - sprite:getContentSize().height / 2)
    animSprite:setPosition(_sz.width / 2, _sz.height / 2)

--    sprite:setTouchEnabled(true)
--    sprite:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
--        printf("Helo")
--        if listener then
--            listener()
--        end
--    end)

--
--    self:setAnchorPoint(0.5, (_sz.height / 2) / szH)
--    local l = display.newColorLayer(ccc4(255, 0, 0, 120))
--    l:setContentSize(self:getContentSize())
--    self:addChild(l)
end

return SpiritIcon