-- Filename: CheckBox.lua
-- Author: zhangqiang
-- Date: 20141104
-- Purpose: 复选框

CheckBox = class("CheckBox", function ( ... )
	local rect = CCSprite:create("images/common/checkbg.png")
	local size = rect:getContentSize()
	
	local normalSp = CCSprite:create()
	normalSp:setContentSize(size)
	local selectSp = CCSprite:create()
	selectSp:setContentSize(size)
	local checkBox = CCMenuItemSprite:create(normalSp, selectSp)
	checkBox:setPosition(size.width*0.5, size.height*0.5)
	checkBox:setAnchorPoint(ccp(0.5,0.5))

	local checkSp = CCSprite:create("images/common/checked.png")
	checkSp:setVisible(false)
	checkSp:setAnchorPoint(ccp(0.5,0.5))
	checkSp:setPosition(size.width*0.5+8, size.height*0.5+8)
	checkBox:addChild(checkSp)
	checkBox.checkSp = checkSp

	rect:setAnchorPoint(ccp(0,0))
	rect:setPosition(0,0)
	checkBox:addChild(rect,-1)

	return checkBox
end)

CheckBox.checkSp = nil
CheckBox.label = nil
CheckBox.bCheck = false


function CheckBox:create( ... )
	local checkBox = self:new()
	return checkBox
end

function CheckBox:setLabel( pStr, pFont, pFontSize, pColor, ptype)
	local label = ptype == nil and CCLabelTTF:create(pStr, pFont, pFontSize)
	                           or  CCRenderLabel:create(pStr, pFont, pFontSize, 1, ccc3(0x00,0x00,0x00), ptype)
	label:setColor(pColor)
	label:setAnchorPoint(ccp(0,0.5))
	label:setPosition(self:getContentSize().width+10, self:getContentSize().height*0.5)
	self:addChild(label)
	self.label = label
end

function CheckBox:setRight( ... )
	if self.label == nil then return end
	self.label:setAnchorPoint(ccp(0,0.5))
	self.label:setPosition(self:getContentSize().width+10, self:getContentSize().height*0.5)
end

function CheckBox:setLeft( ... )
	if self.label == nil then return end
	self.label:setAnchorPoint(ccp(1,0.5))
	self.label:setPosition(-10, self:getContentSize().height*0.5)
end

function CheckBox:registerScriptCheckHandler( pHandler )
	self:registerScriptTapHandler(pHandler)
end

function CheckBox:checked( ... )
	--self:selected()
	self.checkSp:setVisible(true)
	self.bCheck = true
end

function CheckBox:unchecked( ... )
	--self:unselected()
	self.checkSp:setVisible(false)
	self.bCheck = false
end

function CheckBox:isChecked( ... )
	return self.bCheck
end

function CheckBox:writeChecked( pKey )
	CCUserDefault:sharedUserDefault():setBoolForKey(tostring(pKey), self.bCheck)
	CCUserDefault:sharedUserDefault():flush()
end

function CheckBox:readChecked( pKey )
	self.bCheck = CCUserDefault:sharedUserDefault():getBoolForKey(tostring(pKey))

	if self.bCheck == true then
		self:checked()
	else
		self:unchecked()
	end
end