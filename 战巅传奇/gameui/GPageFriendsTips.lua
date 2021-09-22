GPageFriendsTips = class("GPageFriendsTips", function()
    return display.newScene("GPageFriendsTips")
end)

function GPageFriendsTips:ctor()

end

function GPageFriendsTips:onEnter()
	self.xmlScene = GUIAnalysis.load("ui/layout/GPageFriendsTips.uif")
	if self.xmlScene then
		self.xmlScene:size(cc.size(display.width, display.height))
			:align(display.CENTER, display.cx, display.cy)
		self:addChild(self.xmlScene)


		self.xmlScene:getWidgetByName("title"):pos(display.cx, display.cy+100):setOpacity(0)
		self.xmlScene:getWidgetByName("notice"):pos(display.cx, display.cy-20):setOpacity(0)
		-- self.xmlScene:setOpacity(0)
		-- print(self.xmlScene:getOpacity())
		self.xmlScene:getWidgetByName("notice"):runAction(cca.seq({
			cca.fadeIn(1),
			cca.fadeOut(1)
		}))
		self.xmlScene:getWidgetByName("title"):runAction(cca.seq({
			cca.fadeIn(0.8),
			cca.fadeOut(0.8),
			cca.cb(function( ... )
				if PLATFORM_TEST then
					display.replaceScene(GPageSignIn.new())
		        else
					display.replaceScene(GPageServerList.new())
		        end
			end)
		}))
	end

	-- GameMusic.music("music/43.mp3")
end

function GPageFriendsTips:onExit()
	print("GPageFriendsTips:onExit()")
	cc.CacheManager:getInstance():releaseUnused(false)
end


return GPageFriendsTips