--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-25
-- Time: 下午2:47
-- To change this template use File | Settings | File Templates.
--
local data_message_message = require("data.data_message_message")
local SplitDescLayer = class("SplitDescLayer", function()
    return require("utility.ShadeLayer").new()
end)

function SplitDescLayer:ctor(viewType)

    local proxy = CCBProxy:create()
    local rootnode = {}

    local node = CCBuilderReaderLoad("lianhualu/lianhualu_desc.ccbi", proxy, rootnode)
    self:addChild(node)
    node:setPosition(display.cx, display.cy)

    print(viewType)
    if viewType == 1 then
        rootnode["titleLabel"]:setString("炼化说明")
        rootnode["descLabel"]:setString(data_message_message[11].text)
    elseif viewType == 2 then
        rootnode["titleLabel"]:setString("重生说明")
        rootnode["descLabel"]:setString(data_message_message[12].text)
    elseif viewType == 3 then
    	rootnode["titleLabel"]:setString("活动说明")
        rootnode["descLabel"]:setString(data_message_message[21].text)
    elseif viewType == 4 then
        rootnode["titleLabel"]:setString("活动说明")
        rootnode["descLabel"]:setString(data_message_message[23].text)
    end
    rootnode["tag_close"]:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        self:removeSelf()
    end, CCControlEventTouchDown)
end

return SplitDescLayer

