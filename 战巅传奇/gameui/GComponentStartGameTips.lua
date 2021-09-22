local GComponentStartGameTips = {}

function GComponentStartGameTips:initView( extend )
	if self.xmlTips then
		self.xmlTips:setContentSize(display.width, display.height):setTouchEnabled(true):setSwallowTouches(true)
		self.xmlTips:getWidgetByName("box_start_game"):align(display.CENTER, display.cx, display.height * 0.55)
		local imgStartGame = self.xmlTips:getWidgetByName("img_start_game")
		--imgStartGame:loadTexture("ui/image/enter_game_tips_noshow.png")
		
		local path = "ui/image/enter_game_tips_noshow.png"
		asyncload_callback(path, imgStartGame, function(path, texture)
			imgStartGame:loadTexture(path)
		end)
		
		self.xmlTips:getWidgetByName("btn_start_game"):addClickEventListener(function ()
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CONTINUE_TASK})
			GameSocket:PushLuaTable("task.task1000.reqTaskTips", "")
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = extend.str})
		end)
		local awardItem = self.xmlTips:getWidgetByName("btn_start_game")
		local effectSprite = cc.Sprite:create()
			:setAnchorPoint(cc.p(0.5,0.5))
			:setPosition(cc.p(120,32.5))
			:addTo(awardItem);
		--cc.AnimManager:getInstance():getPlistAnimateAsync(effectSprite,4, 50017, 4, 0, 5)
		--GameUtilSenior.addEffect(effectSprite,"spriteEffect",GROUP_TYPE.EFFECT,50017,false,false,true)
	end
	
	--GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CONTINUE_TASK})
	--GameSocket:PushLuaTable("task.task1000.reqTaskTips", "")
	--GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = extend.str})
end
function GComponentStartGameTips:closeCall()

end
-- GameSocket:dispatchEvent({
-- 	name = GameMessageCode.EVENT_SHOW_TIPS, str = "useItem", typeId = netItem.mTypeID,num = netItem.num,pos = netItem.pos
-- })
return GComponentStartGameTips