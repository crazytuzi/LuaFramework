
require "functions"

local UICommon = require "ui/common/UICommon"

local function normalizeImageName(imgType, name, imgsetName)
	if imgType == 0 then --picture file
		local i = string.find(name, '%.', 1)
		if not i then
			name = name .. ".png"
		end
		return name
	elseif imgType == 1 then --imageset picture
		local i = string.find(name, '%.', 1)
		if i then
			name = string.sub(name, 1, i-1)
		end
		local px = imgsetName .. "_"
		i = string.find(name, px, 1)
		if not i or i ~= 1 then
			name = px .. name
		end
		return name
	end
end

i3k_checkPList = i3k_checkPList or function (img)
	if img == "" then
		return "", 0
	end
	local i = string.find(img, '#', 1)
	if i == nil then
		return normalizeImageName(0, img), 0
	end
	local plst = string.sub(img, 1, i -1)
	local rimg = string.sub(img, i +1, -1)
	--cc.SpriteFrameCache:getInstance():addSpriteFrames(plst .. ".plist")
	--cc.SpriteFrameCache:getInstance():addSpriteFrames(plst .. ".imgs")
	local imgname = normalizeImageName(1, rimg, plst)
	cc.SpriteFrameCache:getInstance():checkSpriteFrames(plst .. ".imgs", imgname)
	return imgname, 1
end

local UIBase = class("UIBase")

function UIBase:ctor(ccNode, propConfig)
    self.ccNode_ = ccNode
	self._property = nil
	self.child = {}
end

function UIBase:setVisible(isShow)
	self.ccNode_:setVisible(isShow)
end

function UIBase:show()
	self.ccNode_:setVisible(true)
	return self
end

function UIBase:setLocalZOrder(zOrder)
	self.ccNode_:setLocalZOrder(zOrder)
end

function UIBase:getLocalZOrder()
	return self.ccNode_:getLocalZOrder()
end

function UIBase:hide()
	self.ccNode_:setVisible(false)
	return self
end

function UIBase:isVisible()
	return self.ccNode_:isVisible()
end

function UIBase:enable()
	self.ccNode_:setEnabled(true)
	self.ccNode_:setEnableControl(true)
	return self
end

function UIBase:disable()
	self.ccNode_:setEnabled(false)
	self.ccNode_:setEnableControl(false)
	return self
end

function UIBase:setOpacity(opacity)
	self.ccNode_:setOpacity(opacity)
end

function UIBase:getOpacity()
	return self.ccNode_:getOpacity()
end

function UIBase:onClick(hoster, cb, arg)
	self._click = { hoster = hoster, cb = cb, arg = arg}
	local function touchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if cb then
				cb(hoster, self, arg);
			end
		end
	end
	self.ccNode_:setTouchEnabled(true);
	self.ccNode_:addTouchEventListener(touchEvent);
end

function UIBase:onClickWithChild(hoster, cb)
	local function touchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if cb then
				cb(hoster, sender);
			end
		end
	end
	--self.ccNode_:setTouchEnabled(true);
	--self.ccNode_:addTouchEventListener(touchEvent);

	local children = self:getChildren()
	table.insert(children, self.ccNode_)
	for i,v in pairs(children) do
		v:setTouchEnabled(true);
		v:addTouchEventListener(touchEvent);
	end
end

function UIBase:onTouchEvent(hoster, cb, arg)
	local function touchEvent(sender, eventType)
		if cb then
			cb(hoster, self, eventType, arg);
		end
	end
	self.ccNode_:setTouchEnabled(true);
	self.ccNode_:addTouchEventListener(touchEvent);
end

function UIBase:sendClick()
	local click = self._click;
	if click then
		if click.cb then
			click.cb(click.hoster, self, click.arg);
		end
	end
end

function UIBase:sendTouchClick()
	local click = self._click;
	if click then
		if click.cb then
			click.cb(click.hoster,self, ccui.TouchEventType.began, click.arg);
			click.cb(click.hoster,self, ccui.TouchEventType.ended, click.arg);
		end
	end
end

-- 仅当监听器方法中除了sender参数外还有其他参数时，调用此方法
-- etc : function wnd_battleBase:useCommonSkill(sender, needValue)
function UIBase:sendTouchClickWithArgs(arg)
	local click = self._click;
	if arg then
		click.arg = arg
	end
	if click then
		if click.cb then
			click.cb(click.hoster,self, click.arg);
		end
	end
end

function UIBase:setProperty(property)
	self._property = property
end

function UIBase:getProperty()
	if self._property then
		return self._property
	else
		return
	end
end

function UIBase:setAnchorPoint(x,y)
	local anchorPoint = y and cc.p(x, y) or x
    self.ccNode_:setAnchorPoint(anchorPoint)
end

function UIBase:setPosition(x,y)
	local size = self:getParent() and self:getParent():getContentSize() or cc.Director:getInstance():getWinSize()
	local pos = {}
	pos.x = y and x/size.width or x.x/size.width
	pos.y = y and y/size.height or x.y/size.height
	self:setPositionPercent(pos)
end

function UIBase:getPosition()
    local x, y = self.ccNode_:getPosition()
    return { x = x, y = y }
end

function UIBase:getPositionPercent()
	return self.ccNode_:getPositionPercent()
end

function UIBase:setPositionPercent(x, y)
	self.ccNode_:setPositionPercent(y and cc.p(x, y) or x)
	self.ccNode_:updateSizeAndPosition()
end

function UIBase:setPositionX(x)
	local size = self:getParentSize()
	local positionPercent = self:getPositionPercent()
	positionPercent.x = x/size.width
    self.ccNode_:setPositionPercent(positionPercent)
end

function UIBase:setPositionY(y)
	local size = self:getParentSize()
	local positionPercent = self:getPositionPercent()
	positionPercent.y = y/size.height
    self.ccNode_:setPositionPercent(positionPercent)
end

function UIBase:getPositionX()
    return self.ccNode_:getPositionX()
end

function UIBase:getPositionY()
    return self.ccNode_:getPositionY()
end

function UIBase:getSize()
	local sizePercent = self.ccNode_:getSizePercent()
	local parentSize = self:getParentSize()
	local width = parentSize.width*sizePercent.x
	local height = parentSize.height*sizePercent.y
    return cc.size(width, height)
end

function UIBase:setSizePercent(x, y)
	if y then
		self.ccNode_:setSizePercent(cc.p(x, y))
	else
		self.ccNode_:setSizePercent(x)
	end
end

function UIBase:getSizePercent()
	return self.ccNode_:getSizePercent()
end

function UIBase:getParent()
	return self.ccNode_:getParent()
end

function UIBase:getParentSize()
	return self:getParent() and self:getParent():getContentSize() or cc.Director:getInstance():getWinSize()
end

function UIBase:setContentSize(x, y)
	self.ccNode_:setContentSize(cc.size(x, y))
end

function UIBase:getContentSize()
    return self.ccNode_:getContentSize()
end

function UIBase:convertToWorldSpace(pos)
	return self.ccNode_:convertToWorldSpace(pos)
end

function UIBase:convertToNodeSpace(pos)
    return self.ccNode_:convertToNodeSpace(pos);
end

function UIBase:setTag(value)
	self.ccNode_:setTag(value)
end

function UIBase:getTag()
	return self.ccNode_:getTag()
end

function UIBase:setName(name)
	self.ccNode_:setName(name)
end

function UIBase:getName()
	return self.ccNode_:getName()
end

function UIBase:setScale(x)
	self.ccNode_:setScale(x)
end

function UIBase:setScaleX(x)
	self.ccNode_:setScaleX(x)
end

function UIBase:setScaleY(y)
	self.ccNode_:setScaleY(y)
end

function UIBase:getScale()
	return self.ccNode_:getScale()
end

function UIBase:getScaleX()
	return self.ccNode_:getScaleX()
end

function UIBase:getScaleY()
	return self.ccNode_:getScaleY()
end

function UIBase:setRotation(n)
	self.ccNode_:setRotation(n)
end

function UIBase:getRotation()
	return self.ccNode_:getRotation()
end

function UIBase:addChild(node, order)
	if order then
		self.ccNode_:addChild(node.root or node, order)
	else
		self.ccNode_:addChild(node.root or node)
	end
	if node.anis and node.anis.c_dakai then
		node.anis.c_dakai.play()
	end
	table.insert(self.child, node)
end

function UIBase:getAddChild()
	return self.child
end

function UIBase:removeChild(node)
	for i,v in pairs(self.child) do
		if v == node then
			table.remove(self.child, i)
			break;
		end
	end

	if node.anis then
		for i,v in pairs(node.anis) do
			if v.quit then
				v.quit()
			elseif v.stop then
				v.stop()
			end
		end
	end
	self.ccNode_:removeChild(node.root or node)
end

function UIBase:removeAllChild()
	local allChild = self:getAddChild()
	for i = #allChild, 1, -1 do
		self:removeChild(allChild[i])
	end
end
function UIBase:getChildren()
	return self.ccNode_:getChildren()
end

function UIBase:clone()
	return self.ccNode_:clone()
end

function UIBase:setSizeType(x)
	self.ccNode_:setSizeType(x)
end

function UIBase:setSizeInScroll(scroll, x, y)
	local nodeSize = scroll:getContainerSize()
	local containerHeight = nodeSize.height
	--i3k_log(nodeSize.width.."  "..nodeSize.height.."  "..containerHeight)
	self.ccNode_:setSizePercent(cc.p(x/nodeSize.width, y/containerHeight))
end

function UIBase:changeSizeInScroll(scroll, x, y, keepChildrenSize)
	local children = self.ccNode_:getChildren()
	local oldChildrenType = {}
	if keepChildrenSize ~= nil and keepChildrenSize == true then
		for i,v in ipairs(children) do
			if v.getSizeType ~= nil then
				oldChildrenType[i] = v:getSizeType()
				v:setSizeType(ccui.SizeType.absolute)
			end
		end
	end
	self:setSizeType(ccui.SizeType.absolute)
	self.ccNode_:setContentSize(x, y)
	scroll:update()
	if keepChildrenSize ~= nil and keepChildrenSize == true then
		for i,v in ipairs(children) do
			if v.getSizeType ~= nil then
				v:setSizeType(oldChildrenType[i])
			end
		end
	end
end

function UIBase:setPositionInScroll(scroll, x, y)
	local nodeSize = scroll:getContainerSize()
	self.ccNode_:setPositionPercent(cc.p(x/nodeSize.width, y/nodeSize.height))
end

-- 0: NORMAL 1: GRAY 2: DARK
UI_COLOR_STATE_NORMAL = 0
UI_COLOR_STATE_GRAY = 1
UI_COLOR_STATE_DARK = 2

function UIBase:setColorState(colorState)
	self.ccNode_:setColorState(colorState)
	return self
end

function UIBase:getSizeInScroll(scroll)
	local sizePercent = self:getSizePercent()
	local width = sizePercent.x*scroll:getContainerSize().width
	local height = sizePercent.y*scroll:getContainerSize().height
	return cc.size(width, height)
end

function UIBase:getPositionInScroll(scroll)
	local posPercent = self:getPositionPercent()
	local x = posPercent.x*scroll:getContainerSize().width
	local y = posPercent.y*scroll:getContainerSize().height
	return i3k_vec2(x, y)
end


function UIBase:setTouchEnabled(enable)
	self.ccNode_:setTouchEnabled(enable)
end

function UIBase:setSwallowTouches(swallow)
	self.ccNode_:setSwallowTouches(swallow)
end

function UIBase:opacityWithChild(node, opa)
	node:setOpacity(opa)
	local children = node:getChildren()
	for i,v in pairs(children) do
		self:opacityWithChild(v, opa)
	end
end

function UIBase:setOpacityWithChildren(opa)
	self:opacityWithChild(self.ccNode_, opa)
end

function UIBase.setEnableWithChild(node, enable)
	node:setEnableControl(enable)
	node:setEnabled(enable)
	if enable then
		node:setOpacity(255)
	end
	local children = node:getChildren()
	for i,v in pairs(children) do
		UIBase.setEnableWithChild(v, enable)
	end
end

function UIBase:disableWithChildren()
	self.setEnableWithChild(self.ccNode_, false)
end

function UIBase:enableWithChildren()
	self.setEnableWithChild(self.ccNode_, true)
end

function UIBase:SetIsableWithChildren(isAble)
	if isAble then
		self:enableWithChildren()
	else
		self:disableWithChildren()
	end
end

function UIBase:setNodeProperty(property)
	self.ccNode_:setPosition(property.pos)
	self.ccNode_:setOpacity(property.opacity)
	self.ccNode_:setLocalZOrder(property.zOrder)
	self.ccNode_:setContentSize(property.contentSize)
end














---------------------------------动画实现-----------------
function UIBase:nodePosToActionPos(x, y)--给moveTo用的
	local pos = cc.p(x, y)
	local fatherWidget = self:getParent()
	if fatherWidget then
		--local size = fatherWidget:getContentSize()
		pos = fatherWidget:convertToNodeSpace(cc.p(x, y))
	end
	return pos
end


------------------------move--------------------
function UIBase:createMoveTo(time, x, y, isConvert)
	local pos
	pos = cc.p(x, y)
	if isConvert then
		pos = self:nodePosToActionPos(x, y)
	end
	local move = cc.MoveTo:create(time, pos)
	return move
end

function UIBase:createMoveBy(time, x, y)
	local winSize = cc.Director:getInstance():getWinSize()
	local pos = cc.p(x, y)
	local move = cc.MoveBy:create(time, pos)
	return move
end

--------------------rotate------------------------
function UIBase:createRotateTo(time, angle)
	local rotate = cc.RotateTo:create(time, angle)
	return rotate
end

function UIBase:createRotateBy(time, angle)
	local rotate = cc.RotateBy:create(time, angle)
	return rotate
end

----------------------fade----------------------
function UIBase:createFadeIn(time)
	local fadein = cc.FadeIn:create(time)
	return fadein
end

function UIBase:createFadeOut(time)
	local fadeout = cc.FadeOut:create(time)
	return fadeout
end

------------------------scale---------------------
function UIBase:createScaleTo(time, scale)
	local scale = cc.ScaleTo:create(time, scale)
	return scale
end

function UIBase:createScaleBy(time, scale)
	local scale = cc.ScaleBy:create(time, scale)
	return scale
end

------------------------delayTime----------------------
function UIBase:createDelayTime(time)
	local delay = cc.DelayTime:create(time)
	return delay
end

------------------------sequence---------------------
function UIBase:createSequence(...)
	local sequence = cc.Sequence:create(...)
	return sequence
end

------------------------spawn-------------------------
function UIBase:createSpawn(...)
	local spawn = cc.Spawn:create(...)
	return spawn
end

function UIBase:createEaseInOut(anis, frequency)
	local easeInOut = cc.EaseInOut:create(anis, frequency)
	return easeInOut
end

-----------------------repeatForever-------------------
function UIBase:createRepeatForever(action)
	local rep = cc.RepeatForever:create(action)
	return rep
end

-----------------------runAction---------------------------
function UIBase:runAction(action)
	self.ccNode_:runAction(action)
end

function UIBase:stopActionByTag(tag)
	self.ccNode_:stopActionByTag(tag)
end

function UIBase:stopAllActions()
	self.ccNode_:stopAllActions()
end

--TODO

---------------------Node事件--------------------------------

local ScriptHandlerMap = {["enter"]=0, ["exit"]=1, ["enterTransitionFinish"]=2, ["exitTransitionStart"]=3, ["cleanup"]=4, }

function UIBase:enableScriptHandler()
	if self._enableScriptHandler then
		return
	end
	self._enableScriptHandler = 1
	if self.ccNode_._scriptHandlerBy ~= nil then
		error ("ccNode_ registerScriptHandler already at UIBase!")
	end
	self.ccNode_._scriptHandlerBy = "UIBase"
	self.ccNode_:registerScriptHandler(function(state)
		local scriptHandlerType = ScriptHandlerMap[state]
		if self._scriptCallbacks and self._scriptCallbacks[scriptHandlerType] then
			self.__isCallbacking = {}
			self.__isCallbacking[scriptHandlerType] = true
			for k, v in pairs(self._scriptCallbacks[scriptHandlerType]) do
				v()
			end
			self.__isCallbacking = nil
		end

    end)
end

--不允许在cb里面调用同类型的AddScriptCallback
function UIBase:AddScriptCallback(handleType, cb)
	scriptHandlerType = ScriptHandlerMap[handleType]
	if scriptHandlerType == nil or scriptHandlerType < 0 or scriptHandlerType > 4 then
		error("scriptHandlerType error in AddScriptCallback!")
		return
	end
	if self._scriptCallbacks == nil then
		self._scriptCallbacks = {}
	end
	if self._scriptCallbacks[scriptHandlerType] == nil then
		self._scriptCallbacks[scriptHandlerType] = {}
	end
	if self.__isCallbacking and self.__isCallbacking[scriptHandlerType] then
		error("isCallbacking")
		return
	end
	self:enableScriptHandler()
	self._scriptCallbackSeed = 1 + self._scriptCallbackSeed and self._scriptCallbackSeed or 0
	self._scriptCallbacks[scriptHandlerType][self._scriptCallbackSeed] = cb
	return self._scriptCallbackSeed
end

function UIBase:RemoveScriptCallback(handleType, id)
	scriptHandlerType = ScriptHandlerMap[handleType]
	if scriptHandlerType == nil or scriptHandlerType < 0 or scriptHandlerType > 4 then
		error("scriptHandlerType error in RemoveScriptCallback!")
		return
	end
	if self._scriptCallbacks and self._scriptCallbacks[scriptHandlerType] then
		self._scriptCallbacks[scriptHandlerType][id] = nil
	end
end

return UIBase
