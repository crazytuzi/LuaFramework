 --[[
 --
 -- @authors shan 
 -- @date    2014-05-30 15:51:02
 -- @version 
 --
 --]]

local PopUpWindow = class("PopUpWindow", function ( params )
    display.addSpriteFramesWithFile("ui/ui_pop_window.plist", "ui/ui_pop_window.png")
	local bg = display.newScale9Sprite("#popwin_bg.png")
	bg:setPreferredSize(CCSize(display.width*0.9, display.width*0.6) )
	bg:setPosition(display.width/2, display.height/2)
	return bg
end)


function PopUpWindow:ctor( params )

	local params = params or {}
	local title = params.title or ""
	local text = params.text or "..敬请期待.."


	local titleLabel = ui.newTTFLabel({
		text = title,
		x = self:getContentSize().width/2,
		y = self:getContentSize().height,
		size = 40,
		align = ui.TEXT_ALIGN_CENTER
		})
	self:addChild(titleLabel)

	local textLabel = ui.newTTFLabel({
		text = text,
		x = self:getContentSize().width/2,
		y = self:getContentSize().height/2,
		size = 36,
		align = ui.TEXT_ALIGN_CENTER
		})
	self:addChild(textLabel)

	-- close
	local closeBtn = require("utility.CommonButton").new({
		img = "#popwin_close.png",
		listener = function ( ... )
			self:removeSelf()
		end
		})
	closeBtn:setPosition(self:getContentSize().width-closeBtn:getContentSize().width, self:getContentSize().height-closeBtn:getContentSize().height)
	self:addChild(closeBtn)

	self:setScale(0.2)
	self:runAction(transition.sequence({
		CCScaleTo:create(0.2,1.2),
		CCScaleTo:create(0.1,1.1),
		CCScaleTo:create(0.1,0.9),
		CCScaleTo:create(0.2,1),
		}))

end


return PopUpWindow