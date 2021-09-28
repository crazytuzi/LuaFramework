--Filename:BTNumerLabel.lua
--Author：lichenyang
--Date：2015-04-21
--Purpose:图片数字类

BTNumerLabel = class("BTNumerLabel", function ()
	return CCSprite:create()
end)

function BTNumerLabel:ctor()
	self._imgDir = nil
	self._str = "0"
	self._bitWidth = nil
	self._bitNum = nil
	self._margin = nil
	self._numSprites = {}
end

function BTNumerLabel:createWithPath(p_path,p_num)
	local num = p_num or 0
	local labelNum = BTNumerLabel:new()
	labelNum._imgDir = p_path
	labelNum:setString(p_num)
	labelNum:setCascadeOpacityEnabled(true)
	labelNum:setCascadeColorEnabled(true)
	return labelNum
end

function BTNumerLabel:setString(p_str)
	self:removeAllChildrenWithCleanup(true)
	local numStr = tostring(p_str)
	self._str = numStr
	self._numSprites = {}
	self._bitNum = string.len(numStr)
	for i=self._bitNum, 1, -1 do
		local singleChar = string.char(string.byte(numStr,i))
		local numSprite = CCSprite:create(self._imgDir .. "/".. singleChar .. ".png")
		numSprite:setAnchorPoint(ccp(0, 0.5))
		self:addChild(numSprite)
		table.insert(self._numSprites, numSprite )
	end
	self:updateBitPosition()
end

function BTNumerLabel:updateBitPosition( ... )
	local bitCount = #self._numSprites
	local width = self:getWidth()
	local height = self:getHeiht()
	self:setContentSize(CCSizeMake(width, height))
	local x = width
	for i = 1, bitCount do
		local numSprite = self._numSprites[i]
		if i > self._bitNum then
			numSprite:setVisible(false)
		else
			numSprite:setVisible(true)
		end
		if self._bitWidth ~= nil then
			numSprite:setAnchorPoint(ccp(0.5, 0.5))
			if i == 1 then
				x = x - self._bitWidth * 0.5
			else
				x = x - self._bitWidth
			end
		else
			x = x - numSprite:getContentSize().width
		end

		numSprite:setPosition(ccp(x, height * 0.5))
		if self._margin ~= nil then
			x = x - self._margin
		end
	end
end

function BTNumerLabel:getWidth( ... )
	local width = 0
	if self._bitWidth ~= nil then
		width = width + self._bitWidth * self._bitNum
	else
		for i = 1, self._bitNum do
			local numSprite = self._numSprites[i]
			width = width + numSprite:getContentSize().width
		end
	end
	if self._margin ~= nil then
		width = width + self._margin * (self._bitNum - 1)
	end
	return width
end

function BTNumerLabel:getHeiht( ... )
	local height = 0
	for i = 1, self._bitNum do
		local numSprite = self._numSprites[i]
		if height < numSprite:getContentSize().height then
			height = numSprite:getContentSize().height
		end
	end
	return height
end

function BTNumerLabel:setBitWidth( pWidth )
	self._bitWidth = pWidth
	self:updateBitPosition()
end

function BTNumerLabel:setBitNum( pNum )
	local bitNum = #self._numSprites
	for i = 1, pNum - bitNum do
		local numSprite = CCSprite:create(self._imgDir .. "/0.png")
		numSprite:setAnchorPoint(ccp(0, 0.5))
		self:addChild(numSprite)
		table.insert(self._numSprites, numSprite )
	end
	self._bitNum = pNum
	self:updateBitPosition()
end

function BTNumerLabel:setMargin( pNum )
	self._margin = pNum
	self:updateBitPosition()
end

function BTNumerLabel:getNumSprite(p_bit)
	return self._numSprites[p_bit]
end
