
local UIBase = require "ui/common/UIBase"

local UILoadingBar = class("UILoadingBar", UIBase)

function UILoadingBar:ctor(ccNode, propConfig)
    UILoadingBar.super.ctor(self, ccNode, propConfig)
	
	if propConfig.imageHead and propConfig.imageHead ~= "" then
		local percent = propConfig.percent or 100
		self._topImage = ccui.ImageView:create(propConfig.imageHead)
		self._topImage:setScale9Enabled(true)
		local size = self._topImage:getContentSize()
		self._topImage:setContentSize(size.width,size.height+4)
		self._topImage:setAnchorPoint(0.5, 0.5)
		
		local contentSize = self.ccNode_:getContentSize()
		local nodePosX = propConfig.posX*contentSize.width
		local nodePosY = propConfig.posY*contentSize.height
		local posXMin = nodePosX-contentSize.width/2
		self._topImage:setPosition(posXMin+contentSize.width*percent/100, nodePosY)
		--self._topImage:setOpacity(150)
		self.ccNode_:addChild(self._topImage)
	end
end


function UILoadingBar:setDirection(direction)
	self.ccNode_:setDirection(direction)
end

function UILoadingBar:setHeadAnis(node)
	self._child = node
end

function UILoadingBar:setPercent(percent)
	local direct = self.ccNode_:getDirection()
	local needDis = 0
	local pos
	if direct==0 then
		needDis = self:getContentSize().width
		pos = {x = needDis*percent/100, y = self:getContentSize().height/2}
	elseif direct==3 then
		needDis = self:getContentSize().height
		local poss = self:getPosition()
		pos = {x = self:getContentSize().width/2, y = needDis*percent/100}
	end
	self.ccNode_:setPercent(percent)
	if self._child then
		local needPos = self._child:getParent():convertToNodeSpace(self:convertToWorldSpace(pos))
		self._child:setPosition(needPos)
	end
	if self._topImage then
		local nodePosX = self:getPosition().x
		local nodePosY = self:getPosition().y
		local posXMin = nodePosX-needDis/2
		self._topImage:setPosition(posXMin+needDis*percent/100, nodePosY)
	end
end

function UILoadingBar:getPercent()
	return self.ccNode_:getPercent()
end

function UILoadingBar:setImage(image)
	self.ccNode_:loadTexture(i3k_checkPList(image))
end

return UILoadingBar