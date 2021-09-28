local OperationLayer = class("OperationLayer",function() return cc.Layer:create() end )

function OperationLayer:ctor(parent,column,params,itemRes, bgRes)
	log("OperationLayer:ctor")
	self.column = column
    self.res = itemRes
    self.bgRes = bgRes or "res/common/scalable/3.png"
	self.row = math.ceil(#params/column)
	self.ceil_x = 180
	self.size = cc.size(column*self.ceil_x,self.row*60+35) 
	self.bg = createScale9Sprite(self,self.bgRes,cc.p(display.cx,display.cy),self.size,cc.p(0.5,0.5))
    self:addMenus(params)
    self:initTouch() 
    if parent then 
		parent:addChild(self,254)
	end
	self.bg:setScale(0.01)
    self.bg:runAction(cc.ScaleTo:create(0.15, 1))
end

function OperationLayer:addMenus(params)
	self.font_size = self.font_size or 20
	self.res = self.res or "res/component/button/49"
	local posx,posy = self.ceil_x/2+15*(self.column-1),self.size.height -self.size.height/(2*self.row)-15
	for i=1,#params do 
		local func = function() 
			if params[i][3] then
			 	params[i][3](params[i][2])
			end
		end
		local item
		if params[i][4] == true then
			item = createMenuItem(self.bg,self.res.."_sel.png",cc.p(posx,posy),func)
		else
			item = createMenuItem(self.bg,self.res..".png",cc.p(posx,posy),func)
		end
		local item_size = item:getContentSize()
		local label_item = createLabel(item,params[i][1],cc.p(item_size.width/2, item_size.height/2), nil, self.font_size,true)
		if label_item and params[i][4] == true then
			label_item:setColor(MColor.green)
		end
		if i%self.column == 0 then
			posy = posy - 60
			posx =  self.ceil_x/2+15*(self.column-1)
		else 
			posx = posx + item_size.width + 10
		end
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
    		self:runAction(cc.Sequence:create(cc.ScaleTo:create(0.08, 0.0), cc.CallFunc:create(function() removeFromParent(self) end)))	
    		eventDispatcher:removeEventListener(listenner)
        end,cc.Handler.EVENT_TOUCH_ENDED )
    
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self.bg)

end
return OperationLayer