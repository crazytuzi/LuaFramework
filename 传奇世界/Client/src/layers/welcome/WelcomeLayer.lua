local WelcomeLayer = class("WelcomeLayer", function() return cc.LayerColor:create(cc.c4b(10,10,10, 200)) end)

function WelcomeLayer:ctor(parent)
	local bg = createSprite(self,"res/layers/welcome/1.png",g_scrCenter)
	if parent then
		parent:addChild(self,300)
	end
	local func = function() 
		removeFromParent(self)
		--G_MAINSCENE:theVipUpdateTip()
	end
	local menuitem = createMenuItem(bg,"res/layers/welcome/2.png",cc.p(615,185),func)
	--createLabel(menuitem,game.getStrByKey("start_tral"),getCenterPos(menuitem),nil,24,true):setColor(MColor.yellow_gray)
	self:initTouch() 
	--menuitem:blink()

	if DATA_Notice then DATA_Notice:setFlag()  end
	
end

function WelcomeLayer:initTouch() 
	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
    	removeFromParent(self)
		--G_MAINSCENE:theVipUpdateTip()
       	return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self)
end

return WelcomeLayer