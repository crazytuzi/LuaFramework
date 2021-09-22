GUISpinMenu = class("GUISpinMenu", function()
    return cc.Layer:create()
end)

function GUISpinMenu:ctor(params)
	params = params or {}
	local hasMoved

	local function onTouchBegan(touch, event)
		hasMoved = false
		-- for i = 1,#self._items do
			-- self._items[i]:setTouchEnabled(false,true)
		-- end
		-- if self._selectedItem then
		-- 	self._selectedItem:setBrightStyle(0)
		-- end
		local position = self:convertToNodeSpace(touch:getLocation())
		local size = self:getContentSize()
		local rect = cc.rect(0, 0, size.width, size.height)
		self.touchIdx = self:getCurrentItemIndex()
		return true
	end

	local function onTouchMoved(touch, event)
		if not hasMoved then
			hasMoved = true
			for i = 1,#self._items do
				self._items[i]:stopAllActions()
			end
		end
		local angle = self:disToAngle(touch:getDelta().x)
		self._angle = self._angle + angle
		self:updatePosition()
	end

	local function onTouchEnded(touch, event)
		if hasMoved then
			local xDelta = touch:getLocation().x - touch:getStartLocation().x
			self:rectify(xDelta>0)
			-- if self:disToAngle(math.abs(xDelta))<self._unitAngle / 6 and self._selectedItem then
				-- self._selectedItem:setTouchEnabled(false,true)
			-- end
			self:updatePositionWithAnimation()
		end
		self.touchIdx = nil
	end

	self:ignoreAnchorPointForPosition(false)
	self.animationDuration = 0.3
	self._angle = 0.0
	self._selectedItem = nil
	self._items = {}
	self._offset_x = params.offset_x or 0
	self._offset_y = params.offset_y or 0
	self.PI = math.acos(-1)
	self:size(display.width, display.height)

	self._disXFactor = params.disXFactor or 1/5
	self._disYFactor = params.disYFactor or -1/8

	self._hideScale = params.hideScale or 0.75

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
	listener:setSwallowTouches(false)
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function GUISpinMenu:addActionEndAnime(func)
	self._actionEndAnime = func
end

function GUISpinMenu:addMenuItem(item, amount, noAnimation)
	-- self:addChild(item)
	item:setPosition(cc.p(self:getContentSize().width / 2+self._offset_x,self:getContentSize().height / 2+self._offset_y))
	table.insert(self._items,item)
	self._unitAngle = 2 * self.PI / #self._items--每一个item对应区域的角度
	self._angle = 0
	if #self._items == amount and not noAnimation then--达到预设的个数以后才开始动画，否则浪费
		self:updatePositionWithAnimation()
	end
end

function GUISpinMenu:updatePosition()
	local menuSize = self:getContentSize()
	local disX = menuSize.width*self._disXFactor
	local disY = menuSize.height*self._disYFactor
	local curItemIndex = self:getCurrentItemIndex()
	for i = 1,#self._items do
		local angle = i*self._unitAngle + self._angle
		local x = menuSize.width / 2 + disX*math.sin(angle)
		local y = menuSize.height / 2 + disY*math.cos(angle)
		self._items[i]:setPosition(cc.p(x+self._offset_x, y+self._offset_y))
		self._items[i]:setOpacity(192 + 63 * math.cos(angle))--Opacity  129~255
		self._items[i]:setScale(self._hideScale + (1-self._hideScale)*math.cos(angle))
		local zOrder
		if i == self.touchIdx then
			zOrder = #self._items--保证选中的那个永远在最前面
		else
			zOrder = #self._items-math.abs(i-curItemIndex)
		end
		self._items[i]:setLocalZOrder(zOrder)
	end
end

function GUISpinMenu:updatePositionWithAnimation()
	--先停止所有可能存在的动作
	for i = 1,#self._items do
		self._items[i]:stopAllActions()
	end
	local menuSize = self:getContentSize()
	local disX = menuSize.width*self._disXFactor
	local disY = menuSize.height*self._disYFactor
	local curItemIndex = self:getCurrentItemIndex()
	for i = 1,#self._items do
		local x = menuSize.width / 2 + disX*math.sin(i*self._unitAngle + self._angle)
		local y = menuSize.height / 2 + disY*math.cos(i*self._unitAngle + self._angle)

		local moveTo = cc.MoveTo:create(self.animationDuration, cc.p(x+self._offset_x, y+self._offset_y))
		local fadeTo = cc.FadeTo:create(self.animationDuration, (192 + 63 * math.cos(i*self._unitAngle + self._angle)))--透明度  129~255
		local scaleTo = cc.ScaleTo:create(self.animationDuration, self._hideScale + (1-self._hideScale)*math.cos(i*self._unitAngle + self._angle))--缩放比例  0.5~1
		local spawnAction = cc.Spawn:create(moveTo,fadeTo,scaleTo)
		spawnAction:setTag(1)
		self._items[i]:runAction(spawnAction)
		local zOrder
		if i == self.touchIdx then
			zOrder = #self._items--保证选中的那个永远在最前面
		else
			zOrder = #self._items-math.abs(i-curItemIndex)
		end
		self._items[i]:setLocalZOrder(zOrder)
	end

	local cur_item = self:getCurrentItem()
	if cur_item then
		local function actionEndCallBack(dx)
			if self._actionEndAnime then
				self._actionEndAnime(self._items, self:getCurrentItemIndex())
			end
		end
		cur_item:runAction(cc.Sequence:create(cc.DelayTime:create(self.animationDuration),cc.CallFunc:create(actionEndCallBack)))
	end

end

function GUISpinMenu:disToAngle(dis)
	local width = self:getContentSize().width / 2
	return dis / width*self._unitAngle
end

function GUISpinMenu:getCurrentItemIndex()
	--这里实际加上了0.1self._angle,用来防止精度丢失
	local index = math.floor(((2 * self.PI - self._angle) / self._unitAngle+0.1*self._unitAngle))
	index = (index - 1) % #self._items + 1
	return index
end

function GUISpinMenu:getCurrentItem()
	if #self._items == 0 then
		return nil
	end
	
	return self._items[self:getCurrentItemIndex()]
end

function GUISpinMenu:rectify(forward)
	local angle = self._angle
	while angle<0 do
		angle = angle + self.PI * 2
	end
	while angle>self.PI * 2 do
		angle = angle - self.PI * 2
	end
	if forward then
		angle = math.floor((angle + self._unitAngle / 3*2) / self._unitAngle) *self._unitAngle
	else
		angle = math.floor((angle + self._unitAngle / 3 ) / self._unitAngle) *self._unitAngle
	end
	self._angle = angle
end

function GUISpinMenu:changeCurItem(forward, noAnimation)--外部调用更改当前最前的item
	self._angle = forward * self._unitAngle + self._angle
	if noAnimation then
		self:updatePosition()
	else
		self:updatePositionWithAnimation()
	end
end

return GUISpinMenu