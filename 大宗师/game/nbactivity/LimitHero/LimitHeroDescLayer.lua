--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-25
-- Time: 下午2:47
-- To change this template use File | Settings | File Templates.
--
local data_message_message = require("data.data_message_message")
local LimitHeroDescLayer = class("LimitHeroDescLayer", function()
    return require("utility.ShadeLayer").new()
end)

function LimitHeroDescLayer:ctor()

    local proxy = CCBProxy:create()
    local rootnode = {}

    local node = CCBuilderReaderLoad("friend/friend_desc.ccbi", proxy, rootnode)
    self:addChild(node)
    node:setPosition(display.cx, display.cy)


    rootnode["titleLabel"]:setString("活动说明")
    rootnode["descLabel"]:setString(data_message_message[17].text)
    local preferSize = CCSize(rootnode["content_node"]:getContentSize().width, rootnode["content_node"]:getContentSize().height)
    -- rootnode["content_node"]:setContentSize(CCSize(preferSize.width,preferSize.height*1.5))


    rootnode["tag_bg"]:setContentSize(preferSize)




    rootnode["tag_close"]:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        self:removeSelf()
    end, CCControlEventTouchDown)
end

return LimitHeroDescLayer

