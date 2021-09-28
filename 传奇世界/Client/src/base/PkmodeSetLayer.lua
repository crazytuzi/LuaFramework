local OperationLayer = class("OperationLayer",function() return cc.Layer:create() end )

function OperationLayer:ctor(parent,select_index,params)
	log("OperationLayer:ctor")
	self.column = 1
	self.select_index = require("src/layers/pkmode/PkModeLayer"):getCurMode()+1
	print("select_index"..select_index)
	self.row = math.ceil(#params)
	self.size = cc.size(250,self.row*60+30)
	self.bg = createScale9Sprite(self,"res/common/scalable/6.png",cc.p(display.cx,display.cy),cc.size(525,self.row*60+30),cc.p(0.0,0.5))
    self:addMenus(params)
    self:initTouch() 
    if parent then 
		parent:addChild(self,254)
	end
	self.bg:setScale(0.01)
    self.bg:runAction(cc.ScaleTo:create(0.15, 1))
end

function OperationLayer:addMenus(params)
	self.select_hander = nil
	local posx,posy = self.size.width/(2*self.column),self.size.height -self.size.height/(2*self.row)-10
	for i=1,#params do 
		local func = function(hander) 
			if params[i][3] then
			 	params[i][3](params[i][2])
			end

		end
		local item = createTouchItem(self.bg,"res/component/button/50.png",cc.p(posx-8,posy),func)
		local color = nil
		if i == self.select_index then
			item:setTexture("res/component/button/50_sel.png")
			createSprite(self.bg,"res/component/checkbox/1-1.png",cc.p(posx-100,posy))
			color = MColor.green
		end
		createLabel(item,params[i][1],cc.p(item:getContentSize().width/2, item:getContentSize().height/2), nil, 24,true)
		if params[i][4] then
			local dis = createLabel(item,params[i][4],cc.p(item:getContentSize().width+5, item:getContentSize().height/2), cc.p(0,0.5), 18,true)
			if color then
				dis:setColor(color)
			end
		end
		posy = posy - 60
	end
end
function OperationLayer:initTouch() 
	local eventDispatcher = self:getEventDispatcher()
	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
    		return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
        listenner:registerScriptHandler(function(touch, event) 	
        	AudioEnginer.playTouchPointEffect()	
    		self:runAction(cc.Sequence:create(cc.ScaleTo:create(0.08, 0.0), cc.CallFunc:create(function() removeFromParent(self) end)))	
    		eventDispatcher:removeEventListener(listenner)
        end,cc.Handler.EVENT_TOUCH_ENDED )
    
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self.bg)

end
return OperationLayer