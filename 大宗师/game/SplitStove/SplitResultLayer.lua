--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-26
-- Time: 下午3:31
-- To change this template use File | Settings | File Templates.
--
local SplitResultLayer = class("SplitResultLayer", function()
    return require("utility.ShadeLayer").new()
end)

function SplitResultLayer:ctor(data, callback)

    local proxy = CCBProxy:create()
    local rootnode = {}

    local node = CCBuilderReaderLoad("lianhualu/lianhualu_result_layer.ccbi", proxy, rootnode)
    self:addChild(node)
    node:setPosition(display.cx, display.cy)

    rootnode["titleLabel"]:setString("炼化成功")

    rootnode["tag_close"]:addHandleOfControlEvent(function()
        self:removeSelf()
    end, CCControlEventTouchDown)

    rootnode["closeBtn"]:addHandleOfControlEvent(function()
        self:removeSelf()
    end, CCControlEventTouchDown)



--    for k, v in ipairs(data) do
--
--        local icon = require("game.Icon.IconSprite").new({
--            id  = v.id,
--            num = v.n,
--            bShowName = true
--        })
----      icon:setPosition(self._rootnode["splitItemsBg"]:getContentSize().width * ((i * 2 - 1) / 8), self._rootnode["splitItemsBg"]:getContentSize().height / 2)
--        rootnode["iconPos_" .. tostring(k)]:addChild(icon)
--        if 2 == v.id then
--            game.player:addSilver(v.n)
--            if callback then
--                callback(v.n)
--            end
--        end
--    end
end

return SplitResultLayer

