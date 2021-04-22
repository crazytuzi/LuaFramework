--
-- Author: Your Name
-- Date: 2014-06-11 17:55:02
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetEquipmentBaseBox = import("..widgets.QUIWidgetEquipmentBaseBox")
local QUIWidgetHeroEquipmentSmallBox = class("QUIWidgetHeroEquipmentSmallBox", QUIWidgetEquipmentBaseBox)
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIWidgetHeroEquipmentSmallBox:ctor(options)
	local ccbFile = "ccb/Widget_EquipmentGrid.ccbi"
	local callBacks = {}
	QUIWidgetHeroEquipmentSmallBox.super.ctor(self, ccbFile, callBacks, options)

	self:resetAll()
	-- self:getView():setScale(0.3)

    self._equIcon = CCSprite:create()
	self._ccbOwner.node_icon:addChild(self._equIcon)
end

--设置装备类型
function QUIWidgetHeroEquipmentSmallBox:setType(type)
	self._type = type
end

function QUIWidgetHeroEquipmentSmallBox:onExit()
	QUIWidgetHeroEquipmentSmallBox.super.onExit(self)
	if self._animationChallenge ~= nil then
		self._animationChallenge:disappear()
	end
	if self._animationEvolution ~= nil then
		self._animationEvolution:disappear()
	end
	if self._animationDrop ~= nil then
		self._animationDrop:disappear()
	end
end

function QUIWidgetHeroEquipmentSmallBox:initGLLayer(glLayerIndex)
	-- self._ccbOwner.node_icon_bg:setVisible(false)

	self._glLayerIndex = glLayerIndex or 1
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_icon_bg, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_icon_bg, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_icon_frame, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_icon, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._equIcon, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sprite_greenplus, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sprite_yellowplus, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sprite_buleplus, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_yellow, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_green, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_blue, self._glLayerIndex)

    return self._glLayerIndex
end

--获取装备类型
function QUIWidgetHeroEquipmentSmallBox:getType()
	return self._type
end

function QUIWidgetHeroEquipmentSmallBox:setEquipmentInfo(itemInfo)
	if itemInfo ~= nil then
		self._itemInfo = itemInfo

    	if self._itemInfo.icon and self._equIcon then
			self._equIcon:setVisible(true)
	    	local frame = QSpriteFrameByPath(self._itemInfo.icon)
	    	if frame then
	    		self._equIcon:setDisplayFrame(frame)
    		end
			local size = self._equIcon:getContentSize()
			local scale = self._ccbOwner.node_icon_bg:getContentSize().width/size.width
			self._equIcon:setScale(scale)
    	end
	end
end

function QUIWidgetHeroEquipmentSmallBox:showState(isGreen, isComposite)
	if self._equIcon then
		self._equIcon:setVisible(false)
	end
	if isGreen == true then
		self._ccbOwner.sprite_greenplus:setVisible(true)
	else
		self._ccbOwner.sprite_yellowplus:setVisible(true)
	end
end

function QUIWidgetHeroEquipmentSmallBox:showDrop(isCanDrop)
	if isCanDrop == true then
		self._ccbOwner.sprite_buleplus:setVisible(true)
	end
end

--设置是否可以突破
function QUIWidgetHeroEquipmentSmallBox:showCanEvolution(b, isLevel)
	if isLevel == nil then isLevel = true end

	if b == true and self._itemInfo ~= nil then
		if isLevel == false then
			self._ccbOwner.sp_yellow:setVisible(b)
		end
	end
end

--设置是否可以收集 就是掉落
function QUIWidgetHeroEquipmentSmallBox:showCanDrop(b)
	self._ccbOwner.sp_blue:setVisible(b)
end

function QUIWidgetHeroEquipmentSmallBox:showCanChallenge(b)
	self._ccbOwner.sp_blue:setVisible(b)
end

--全部置空
function QUIWidgetHeroEquipmentSmallBox:resetAll()
	self._ccbOwner.sprite_yellowplus:setVisible(false)
	self._ccbOwner.sprite_greenplus:setVisible(false)
	self._ccbOwner.sprite_buleplus:setVisible(false)
	self._ccbOwner.sp_green:setVisible(false)
	self._ccbOwner.sp_blue:setVisible(false)
	self._ccbOwner.sp_yellow:setVisible(false)
	self:showCanEvolution(false)
	self:showCanDrop(false)
	self:showCanChallenge(false)

	if self._equIcon then
		self._equIcon:setVisible(false)	
	end
end

--设置是否解锁
function QUIWidgetHeroEquipmentSmallBox:setIsLock(b)
	self:setVisible(not b)
end

return QUIWidgetHeroEquipmentSmallBox