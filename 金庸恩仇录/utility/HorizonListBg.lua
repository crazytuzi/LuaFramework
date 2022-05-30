local HorizonListBg = class("HorizonListBg", function ()
	return display.newNode()
end)

function HorizonListBg:ctor()
	--display.addSpriteFramesWithFile("ui/ui_bigmap.plist", "ui/ui_bigmap.png")	
	self.bg = display.newScale9Sprite("#bigmap_tab_bg.png", 0, 0, cc.size(display.width, 130))
	self:addChild(self.bg)
	self.bg:setTouchEnabled(true)
end

function HorizonListBg:getContentSize()
	--return cc.size(display.width, 130)
	return self.bg:getContentSize()
end

return HorizonListBg