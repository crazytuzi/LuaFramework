--[[
 --
 -- add by vicky
 -- 2014.09.04
 --
 --]]

 local LianzhanMsgBox = class("LianzhanMsgBox", function()
 	return require("utility.ShadeLayer").new()
 end)

 
 function LianzhanMsgBox:ctor(param)
 	local gold = param.gold
 	local listener = param.listener

 	local proxy = CCBProxy:create()
    local rootnode = {}

	local node = CCBuilderReaderLoad("battle/liangzhan_msgbox.ccbi", proxy, rootnode)
	node:setPosition(display.width/2, display.height/2)
	self:addChild(node)

	rootnode["goldNumLbl"]:setString(gold)

	-- 确认
	rootnode["confirmBtn"]:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
			if listener ~= nil then
				listener()
			end
            self:removeFromParentAndCleanup(true)
        end, CCControlEventTouchUpInside)

	-- 关闭
    rootnode["closeBtn"]:addHandleOfControlEvent(function(eventName, sender)
    	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
            self:removeFromParentAndCleanup(true)
        end, CCControlEventTouchUpInside)

    -- 关闭
    rootnode["cancelBtn"]:addHandleOfControlEvent(function(eventName, sender)
    	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
            self:removeFromParentAndCleanup(true)
        end, CCControlEventTouchUpInside)

 end



 return LianzhanMsgBox