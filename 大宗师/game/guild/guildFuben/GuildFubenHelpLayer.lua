--[[
 --
 -- add by vicky
 -- 2015.03.09 
 --
 --]]

local GuildFubenHelpLayer = class("GuildFubenHelpLayer", function ()
	return require("utility.ShadeLayer").new()
end)


function GuildFubenHelpLayer:ctor(param) 
    local closeFunc = param.closeFunc 
    local title = param.title 
    local msg = param.msg 

	local proxy = CCBProxy:create()
	local rootnode = {}

	local node = CCBuilderReaderLoad("guild/guild_fuben_help_layer.ccbi", proxy, rootnode) 
	node:setPosition(display.width/2, display.height/2)
	self:addChild(node)

	rootnode["titleLabel"]:setString(title or "提示") 
    rootnode["msg_lbl"]:setString(msg) 

    rootnode["tag_close"]:addHandleOfControlEvent(function(eventName,sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
            if closeFunc ~= nil then 
                closeFunc() 
            end 
            self:removeFromParentAndCleanup(true) 
        end, CCControlEventTouchUpInside) 
end


return GuildFubenHelpLayer 

