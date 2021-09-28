--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-18
-- Time: 下午6:32
-- To change this template use File | Settings | File Templates.
--


local SpiritQuickSelectedLayer = class("SpiritQuickSelectedLayer", function()
    return require("utility.ShadeLayer").new()
end)

local function btn_effect(sender, callback)
    sender:runAction(transition.sequence({
        CCScaleTo:create(0.08, 0.8),
        CCScaleTo:create(0.1, 1.01),
        CCScaleTo:create(0.01, 1),
        CCCallFunc:create(function()
            if callback then
                callback()
            end
        end)
    }))
end

function SpiritQuickSelectedLayer:ctor(callback)
    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("spirit/spirit_quick_select.ccbi", proxy, self._rootnode)
    node:setPosition(display.width / 2, display.height / 2)
    self:addChild(node)

    self._rootnode["titleLabel"]:setString("选择真气星级")

    local selected = {
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false
    }

    local function onSelecteAllBtn()
        for i = 1, 4 do
            selected[i] = true
            self._rootnode["selectedFlag_" .. tostring(i)]:setVisible(true)
        end
    end

    local function onConfirmBtn()
        if callback then
            callback(selected)
        end
        self:removeSelf()

    end

    local function onSelectedStar(tag)
        if (selected[tag]) then
            selected[tag] = false
        else
            selected[tag] = true
        end
        self._rootnode["selectedFlag_" .. tostring(tag)]:setVisible(selected[tag])
    end

    self._rootnode["tag_close"]:addHandleOfControlEvent(function(eventName, sender)
        btn_effect(sender, function()
            self:removeSelf()
        end)
    end, CCControlEventTouchDown)

    self._rootnode["chooseAllBtn"]:addHandleOfControlEvent(function(eventName,sender)
        btn_effect(sender, onSelecteAllBtn)
    end,
    CCControlEventTouchDown)

    self._rootnode["confirmBtn"]:addHandleOfControlEvent(function(eventName,sender)
        btn_effect(sender, onConfirmBtn)
    end,
    CCControlEventTouchDown)

    for i = 1, 4 do
        self._rootnode["chooseStarBtn_" .. tostring(i)]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onSelectedStar)
    end
end

return SpiritQuickSelectedLayer