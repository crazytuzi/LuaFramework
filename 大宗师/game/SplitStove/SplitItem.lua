--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 7/1/14
-- Time: 5:28 PM
-- To change this template use File | Settings | File Templates.
--

local SplitItem = class("SplitItem", function()
    return CCTableViewCell:new()
end)

function SplitItem:getContentSize()

    return CCSizeMake(display.width, 152)
end

function SplitItem:create(param)
    local _itemData = param.itemData
    local _viewSize = param.viewSize

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("lianhualu/choose_item.ccbi", proxy, self._rootnode)
    node:setPosition(_viewSize.width / 2, self._rootnode["itemBg"]:getContentSize().height / 2)
    self:addChild(node)

    for i = 1, 2 do
        self[string.format("nameLabel_%d", i)] = ui.newTTFLabelWithShadow({
            text = "",
            font = FONTS_NAME.font_fzcy,
            size = 30,
        })
        self._rootnode[string.format("itemNameLabel_%d", i)]:addChild(self[string.format("nameLabel_%d", i)])
    end

    self.hjLabel = ui.newTTFLabelWithShadow({
        text = "",
        font = FONTS_NAME.font_fzcy,
        size = 20,
        align = ui.TEXT_ALIGN_LEFT
    })
    self.hjLabel:setPosition(5, self._rootnode["hjSprite"]:getContentSize().height / 2)
    self._rootnode["hjSprite"]:addChild(self.hjLabel)
    self:refresh(param)
    return self
end

function SplitItem:refreshLabel(param)
    local _itemData = param.itemData

    local nameLabel = self[string.format("nameLabel_%d", param.itemType)]

    nameLabel:setString(_itemData.name)
    nameLabel:setColor(NAME_COLOR[_itemData.star])
    nameLabel:setPosition(nameLabel:getContentSize().width / 2, 0)

    self._rootnode["lvLabel"]:setString(tostring(string.format("LV.%d", _itemData.level)))
--    self._rootnode["lvLabel"]:setString(tostring(_itemData.id))

end

function SplitItem:selected()
    self._rootnode["selectedSprite"]:setDisplayFrame(display.newSpriteFrame("item_board_selected.png"))
end

function SplitItem:unselected()
    self._rootnode["selectedSprite"]:setDisplayFrame(display.newSpriteFrame("item_board_unselected.png"))
end

function SplitItem:touch()
    self:selected()
end

function SplitItem:changeState(sel)

    if sel then
        self:selected()
    else
        self:unselected()
    end
end

function SplitItem:refresh(param)
    local _itemData = param.itemData
    local _sel      = param.sel

    self:changeState(_sel)
    self:refreshLabel(param)

    for i = 1, 5 do
        if _itemData.star >= i then
            self._rootnode[string.format("star_%d_%d", param.itemType, i)]:setVisible(true)
        else
            self._rootnode[string.format("star_%d_%d", param.itemType, i)]:setVisible(false)
        end
    end

    for i = 1, 2 do
        if i == param.itemType then
            self._rootnode[string.format("typeNode_%d", i)]:setVisible(true)
        else
            self._rootnode[string.format("typeNode_%d", i)]:setVisible(false)
        end
    end

    if param.itemType == LIAN_HUA_TYEP.HERO then
        ResMgr.refreshIcon({
            itemBg = self._rootnode["headIcon"],
            id = _itemData.resId,
            resType = ResMgr.HERO
        })
        local card = ResMgr.getCardData(_itemData.resId)
        if _itemData.cls > 0 then
            self._rootnode["clsLabel"]:setString(string.format("+%d", _itemData.cls))
        else
            self._rootnode["clsLabel"]:setString("")
        end

        self.hjLabel:setString(string.format("资质:%d", card.arr_zizhi[_itemData.cls + 1]))
        self.hjLabel:setPositionX(10 + self.hjLabel:getContentSize().width / 2)
        self._rootnode["jobSprite"]:setDisplayFrame(display.newSpriteFrame(string.format("zhenrong_job_%d.png", card.job)))
        self._rootnode["lvLabel"]:setPosition(ccp(74, 17))
    elseif param.itemType == LIAN_HUA_TYEP.EQUIP then
        self._rootnode["lvLabel"]:setPosition(ccp(64, 17))
        ResMgr.refreshIcon({
            itemBg = self._rootnode["headIcon"],
            id = _itemData.resId,
            resType = ResMgr.EQUIP
        })
    end

end


return SplitItem

