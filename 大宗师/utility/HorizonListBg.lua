
local HorizonListBg = class("HorizonListBg", function ()	
    return  display.newNode()
	
end)

function HorizonListBg:ctor()
	display.addSpriteFramesWithFile("ui/ui_bigmap.plist", "ui/ui_bigmap.png")


	self.bg = display.newScale9Sprite("#bigmap_tab_bg.png", 0, 0, CCSize(display.width, 130))
    self:addChild(self.bg)

    self.bg:setTouchEnabled(true)

	-- self.upBgUpFrame = display.newSprite("#bigmap_bottom_frame.png")--display.newScale9Sprite("#bigmap_bottom_frame.png", self.bg:getContentSize().width/2, -2, CCSize(display.width, 10))
	-- self.upBgUpFrame:setScaleX(display.width/self.upBgUpFrame:getContentSize().width)
	-- self.upBgUpFrame:setPositionX(display.width/2)
 --    self.bg:addChild(self.upBgUpFrame)

	-- self.upBgDownFrame = display.newScale9Sprite("#bigmap_bottom_frame.png", self.bg:getContentSize().width/2, self.bg:getContentSize().height-20, CCSize(display.width*2, 50))
 --    self.bg:addChild(self.upBgDownFrame)

end

function HorizonListBg:getContentSize()
	return self.bg:getContentSize()
end

return HorizonListBg