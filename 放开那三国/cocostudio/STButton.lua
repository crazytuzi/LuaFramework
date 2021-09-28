-- Filename: STButton.lua
-- Author: bzx
-- Date: 2015-04-24
-- Purpose: 按钮

STButton = class("STButton", function ( ... )
	local ret = STLayer:create()
	return ret
end)

function STButton:ctor()
	STLayer.ctor(self)
	self._normalNode = nil
	self._selectedNode = nil
	self._disabledNode = nil
	self._scale9Enabled = false
	self._status = STButtonStatus.UNSELECTED
	self._touchBeganPosition = nil
	self._touchEndPosition = nil
	self._touchBeganWorldPosition = nil
	self._clickCallback = nil
	self._clickCallbackArgs = nil
	self._isSwallowTouch = true
	self._type = STButtonType.NORMAL
	self._capInsets = nil
	self._radioInfo = nil
	self._normalLabel = nil
	self._selectedLabel = nil
	self._disabledLabel = nil
	self._polygon = nil
	self._scrollView = nil
	self._selectedScale = 1
end

function STButton:createWithImage( normalImage, selectedImage, disabledImage, scale9Enabled)
	local ret = STButton.new()
	ret:initWithImage(normalImage, selectedImage, disabledImage, scale9Enabled)
	return ret
end

function STButton:createWithNode( normal, selected, disabled)
	local ret = STButton.new()
	ret:initWithNode(normal, selected, disabled)
	return ret
end

function STButton:setScale9Eabled( enable )
	self._scale9Enabled = enable
end

function STButton:isScale9Eabled( ... )
	return self._scale9Enabled
end

function STButton:clone( ... )
	local ret = STButton:createCloneNode(self)
	ret:copyProperties(self)
	ret:copyNodes(self)
	return ret
end

function STButton:createCloneNode( node )
	local normalNode = node:getNormalNode():clone()
	local selectedNode = node:getSelectedNode()
	if selectedNode then
		selectedNode = selectedNode:clone()
	end
	local disabledNode = node:getSelectedNode()
	if disabledNode then
		disabledNode = disabledNode:clone()
	end
	return STButton:createWithNode(normalNode, selectedNode, disabledNode)
end

function STButton:copySpecialProperties( node )
	self:setScale9Eabled(node:isScale9Eabled())
end

function STButton:getType( )
	return self._type
end

function STButton:setRadioInfo( radioInfo )
	self._radioInfo = radioInfo
	self._type = STButtonType.RADIO
end

function STButton:addRadioPartner(button)
	self._radioInfo = self._radioInfo or {}
	self._radioInfo.curButton = self._radioInfo.curButton or self
	self._radioInfo.buttons = self._radioInfo.buttons or {}
	self._radioInfo.buttons[tostring(button)] = button
	self._radioInfo.buttons[tostring(self)] = self
	button:setRadioInfo(self._radioInfo)
	self._type = STButtonType.RADIO
	button._type = STButtonType.RADIO
end

function STButton:initWithImage( normalImage, selectedImage, disabledImage, scale9Enabled )
	self._scale9Enabled = scale9Enabled or false
	local normalNode = nil
	local selectedNode = nil
	local disabledNode = nil
	if scale9Enabled then
		normalNode = STScale9Sprite:create(normalImage)
		if selectedImage then
			selectedNode = STScale9Sprite:create(selectedImage)
		end
		if disabledImage then
			disabledNode = STScale9Sprite:create(disabledImage)
		end
	else
		normalNode = STSprite:create(normalImage)
		if selectedImage then
			selectedNode = STSprite:create(selectedImage)
		end
		if disabledImage then
			disabledNode = STSprite:create(disabledImage)
		end
	end
	self:initWithNode(normalNode, selectedNode, disabledNode)
end

function STButton:setNormalImage( normalImage )
	local normalNode = nil
	if self._scale9Enabled then
		normalNode = STScale9Sprite:create(normalImage)
	else
		normalNode  = STSprite:create(normalImage)
	end
	self:setNormalNode(normalNode)
end

function STButton:setDisabledImage( disabledImage )
	local disabledNode = nil
	if self._scale9Enabled then
		disabledNode = STScale9Sprite:create(disabledImage)
	else
		disabledNode = STSprite:create(disabledImage)
	end
	self:setDisabledNode(disabledNode)
end

function STButton:setSelectedImage( selectedImage )
	local selectedNode = nil
	if self._scale9Enabled then
		selectedNode = STScale9Sprite:create(selectedImage)
	else
		selectedNode = STSprite:create(selectedImage)
	end
	self:setSelectedNode(selectedNode)
end

function STButton:initWithNode( normalNode, selectedNode, disabledNode )
	self._normalNode = normalNode
	self._selectedNode = selectedNode
	self._disabledNode = disabledNode
	self:setNormalNode(normalNode)
	self:setSelectedNode(selectedNode)
	self:setDisabledNode(disabledNode)
	self:updateVisibility()
	self:setTouchPriority(-180)
	self:setTouchEnabled(true)
end

function STButton:setNormalNode( normalNode )
	if not normalNode then
		return
	end
	if self._normalNode then
		self._normalNode:removeFromParent()
	end
	self._normalNode = normalNode
	normalNode:setAnchorPoint(ccp(0.5, 0.5))
	normalNode:setPercentPosition(0.5, 0.5)
	self:addChild(normalNode)
	self:updateVisibility()
	self:updateContentSize()
end

function STButton:getNormalNode( ... )
	return self._normalNode
end

function STButton:setCapInsets( capInsets )
	self._capInsets = capInsets
	if self._scale9Enabled then
		self._normalNode:setCapInsets(capInsets)
		if self._selectedNode then
			self._selectedNode:setCapInsets(capInsets)
		end
		if self._disabledNode then
			self._disabledNode:setCapInsets(capInsets)
		end
	end
end

function STButton:setSelectedScale( selectedScale )
	self._selectedScale = selectedScale
	if self._status == STButtonStatus.SELECTED then
		self._subnode:setScaleX(self._selectedScale * self:getScaleX())
		self._subnode:setScaleY(self._selectedScale * self:getScaleY())
	end
end

function STButton:setSelectedNode( selectedNode )
	if self._selectedNode then
		self._selectedNode:removeFromParent()
	end
	self._selectedNode = selectedNode
	if not selectedNode then
		return
	end
	selectedNode:setAnchorPoint(ccp(0.5, 0.5))
	selectedNode:setPercentPosition(0.5, 0.5)
	self:addChild(selectedNode)
	self:updateVisibility()
end

function STButton:getSelectedNode( ... )
	return self._selectedNode
end

function STButton:setDisabledNode( disabledNode )
	if self._disabledNode then
		self._disabledNode:removeFromParent()
	end
	if not disabledNode then
		return
	end
	self._disabledNode = disabledNode
	disabledNode:setAnchorPoint(ccp(0.5, 0.5))
	disabledNode:setPercentPosition(0.5, 0.5)
	self:addChild(disabledNode)
	self:updateVisibility()
end

function STButton:updateContentSize( ... )
	self:setContentSize(self._normalNode:getContentSize())
end

function STButton:setContentSize( nodeSize )
	self._nodeSize = nodeSize
	STNode.setContentSize(self, nodeSize)
	if self._scale9Enabled then
		self._normalNode:setContentSize(nodeSize)
		if self._selectedNode then
			self._selectedNode:setContentSize(nodeSize)
		end
		if self._disabledNode then
			self._disabledNode:setContentSize(nodeSize)
		end
	end
end

function STButton:setEnabled( enabled )
	if enabled then
		self:setStatus(STButtonStatus.UNSELECTED)
	else
		self:setStatus(STButtonStatus.DISABLED)
	end
end

function STButton:setStatus( status )
	if self._status ~= status then
		self._status = status
		if status ==STButtonStatus.SELECTED then
			self:setSelectedScale(self._selectedScale)
		else
			self:setScaleX(self:getScaleX())
			self:setScaleY(self:getScaleY())
		end
		self:updateVisibility()
	end
end

function STButton:setNormalLabel( normalLabel )
	if self._normalLabel then
		self._normalLabel:removeFromParent()
	end
	self._normalLabel = normalLabel
	self._normalNode:addChild(normalLabel)
	normalLabel:setAnchorPoint(ccp(0.5, 0.5))
	normalLabel:setPercentPosition(0.5, 0.5)
end

function STButton:getNormalLabel( ... )
	return self._normalLabel
end

function STButton:setLabel( text,  fontName, fontSize, color, renderSize, renderColor, renderType )
	local normalLabel = STLabel:create(text,  fontName, fontSize, renderSize, renderColor, renderType)
	normalLabel:setColor(color)
	self:setNormalLabel(normalLabel)
	local selectedLabel = STLabel:create(text,  fontName, fontSize, renderSize, renderColor, renderType)
	selectedLabel:setColor(color)
	self:setSelectedLabel(selectedLabel)
	local disabledLabel = STLabel:create(text,  fontName, fontSize, renderSize, renderColor, renderType)
	disabledLabel:setColor(color)
	self:setDisabledLabel(disabledLabel)
end

function STButton:setString( text )
	if self._normalLabel then
		self._normalLabel:setString(text)
	end
	if self._selectedLabel then
		self._selectedLabel:setString(text)
	end
	if self._disabledLabel then
		self._disabledLabel:setString(text)
	end
end

function STButton:setRichInfo( richInfo )
	if self._normalLabel then
		self._normalLabel:setRichInfo(richInfo)
	end
	if self._selectedLabel then
		self._selectedLabel:setRichInfo(richInfo)
	end
	if self._disabledLabel then
		self._disabledLabel:setRichInfo(richInfo)
	end
end

function STButton:getRichInfo( ... )
	if self._normalLabel then
		return self._normalLabel:getRichInfo()
	end
end

function STButton:setSelectedLabel( selectedLabel )
	if self._selectedNode then
		self._selectedLabel = selectedLabel
		self._selectedNode:addChild(selectedLabel)
		selectedLabel:setAnchorPoint(ccp(0.5, 0.5))
		selectedLabel:setPercentPosition(0.5, 0.5)
	end
end

function STButton:getSelectedLabel( ... )
	return self._selectedLabel
end


function STButton:setDisabledLabel( disabledLabel )
	if self._disabledNode then
		self._disabledLabel = disabledLabel
		self._disabledNode:addChild(disabledLabel)
		disabledLabel:setAnchorPoint(ccp(0.5, 0.5))
		disabledLabel:setPercentPosition(0.5, 0.5)
	end
end

function STButton:getDisabledLabel( ... )
	return self._disabledLabel
end


function STButton:getStatus(  )
	return self._status
end

function STButton:isEnabled( ... )
	return self._status ~= STButtonStatus.DISABLED
end

function STButton:updateVisibility( ... )
	local normalVisible = true
	local selectedVisible = false
	local disabledVisible = false
	if self._status == STButtonStatus.DISABLED then
		if self._type == STButtonStatus.RADIO then
			if self._selectedNode then
				normalVisible = false
				selectedVisible = true
			end
		else
			if self._disabledNode then
				normalVisible = false
				disabledVisible = true
			elseif self._selectedNode then
				normalVisible = false
				selectedVisible = true
			end
		end
	elseif self._status == STButtonStatus.SELECTED then
		if self._selectedNode then
			normalVisible = false
			selectedVisible = true
		end
	end
	if self._normalNode then
		self._normalNode:setVisible(normalVisible)
	end
	if self._selectedNode then
		self._selectedNode:setVisible(selectedVisible)
	end
	if self._disabledNode then
		self._disabledNode:setVisible(disabledVisible)
	end
end

function STButton:setPolygon( polygon )
	self._polygon = polygon
end

function STButton:setClickCallback( callback, args)
	self._clickCallback = callback
	self._clickCallbackArgs = args
end

function STButton:containsWorldPoint( point )
	if not self._polygon then
		return STNode.containsWorldPoint(self, point)
	end
	local nodeSpace = self:convertToNodeSpace(point)
	return ccs.isInPolygon(self._polygon, nodeSpace)
end

function STButton:pushEvent( event )
	if event == STButtonEvent.CLICKED then
		if self._type == STButtonType.RADIO then
			self._radioInfo.curButton:setStatus(STButtonStatus.UNSELECTED)
			self:setStatus(STButtonStatus.DISABLED)
			self._radioInfo.curButton = self
		end
		if self._clickCallback ~= nil then
			self._clickCallback(self:getTag(), self, self._clickCallbackArgs)
		end
	end
end

function STButton:setScrollView(scrollView)
	self._scrollView = scrollView
end

function STButton:onTouchEvent( event, x, y )
	if not self:isVisible() then
		return
	end
	if type(x) == "table" then
		if x[3] == 0 then
			y = x[2]
			x = x[1]
		end
	end
	local position = ccp(x, y)
	if event == "began" then
		if self._scrollView ~= nil then
			if not self._scrollView:containsWorldPoint(position) then
				return false
			end
		end
		if not self:containsWorldPoint(position) then
			return false
		end
		if not self:isAbsoluteVisible() then
			return false
		end
		if self._status == STButtonStatus.DISABLED then
			return false
		end
		self._touchBeganPosition = ccp(x, y)
		self._touchBeganWorldPosition = self:getWorldPosition()
		self:setStatus(STButtonStatus.SELECTED)
		return true
	elseif event == "moved" then
		if not self:containsWorldPoint(position) then
			self:setStatus(STButtonStatus.UNSELECTED)
			return
		end
		local worldPosition = self:getWorldPosition()
		-- 距离判断
		if not worldPosition:equals(self._touchBeganWorldPosition) then
			self:setStatus(STButtonStatus.UNSELECTED)
			return
		end
	elseif event == "cancelled" then
		if self:getStatus() ~= STButtonStatus.SELECTED then
			return
		end
		self:setStatus(STButtonStatus.UNSELECTED)
	elseif event == "ended" then
		if self:getStatus() ~= STButtonStatus.SELECTED then
			return
		end
		local worldPosition = self:getWorldPosition()
		if self._type == STButtonType.NORMAL then
			self:setStatus(STButtonStatus.UNSELECTED)
		elseif self._type == STButtonType.RADIO then
			self._radioInfo.curButton:setStatus(STButtonStatus.UNSELECTED)
			self:setStatus(STButtonStatus.DISABLED)
			self._radioInfo.curButton = self
		end
		local touchDistance = math.pow(math.abs(worldPosition.x - self._touchBeganWorldPosition.x), 2) + math.pow(math.abs(worldPosition.y - self._touchBeganWorldPosition.y), 2)
		if touchDistance <= 100 * g_fScaleX then
			if self._clickCallback ~= nil then
				self._clickCallback(self:getTag(), self, self._clickCallbackArgs)
			end
		end
	end
end
