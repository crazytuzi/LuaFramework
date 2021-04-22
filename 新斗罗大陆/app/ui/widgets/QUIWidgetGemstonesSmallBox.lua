-- 
-- Author: Your Name
-- Date: 2014-06-11 17:55:02
--
local QUIWidgetGemstonesBaseBox = import("..widgets.QUIWidgetGemstonesBaseBox")
local QUIWidgetGemstonesSmallBox = class("QUIWidgetGemstonesSmallBox", QUIWidgetGemstonesBaseBox)
local QFullCircleUiMask = import("..battle.QFullCircleUiMask")

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetQualitySmall = import("..widgets.QUIWidgetQualitySmall")

function QUIWidgetGemstonesSmallBox:ctor(options)
	local ccbFile = "ccb/Widget_EquipmentGrid_baoshi.ccbi"
	QUIWidgetGemstonesSmallBox.super.ctor(self, ccbFile, callBacks, options)

end

--设置宝石信息
function QUIWidgetGemstonesSmallBox:setGemstoneInfo(gemstone)
	if gemstone == nil then return end
	local godLevel = gemstone.godLevel or 0
	local mixLevel = gemstone.mix_level or 0

	local itemId , quality , iconPath = remote.gemstone:getGemstoneTransferInfoByData(gemstone)
	self._itemId = itemId
	self._quality = quality
	self:setItemIcon(iconPath)
end

function QUIWidgetGemstonesSmallBox:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_icon_bg, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_frame_1, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_frame_2, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_icon, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_icon, self._glLayerIndex)
    if self._itemIcon then
    	self._glLayerIndex = q.nodeAddGLLayer(self._itemIcon, self._glLayerIndex)
	end
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sprite_greenplus, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_lock, self._glLayerIndex)

    return self._glLayerIndex
end

--设置图标
function QUIWidgetGemstonesSmallBox:setItemId(itemId)
	self._itemId = itemId
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(itemId)
	self:setItemIcon(itemConfig.icon_1 or itemConfig.icon)

end

function QUIWidgetGemstonesSmallBox:setItemIcon(iconPath)
	local scale = self._ccbOwner.sp_icon:getScale()
	self._ccbOwner.sprite_greenplus:setVisible(false)

	if self._itemIcon == nil  then
		self._itemIcon = CCSprite:create()
		self._itemIcon:scale(scale)
		self._ccbOwner.node_icon:addChild(self._itemIcon)
	end	
	self._itemIcon:setVisible(true)
	QSetDisplayFrameByPath(self._itemIcon , iconPath)
	self._itemIcon:setShaderProgram(qShader.Q_ProgramPositionTextureColorCircle)
end


function QUIWidgetGemstonesSmallBox:setIsSpar()
	self._ccbOwner.sp_frame_1:setVisible(false)
	self._ccbOwner.sp_frame_2:setVisible(true)
end

function QUIWidgetGemstonesSmallBox:setState(state)
	if state == remote.gemstone.GEMSTONE_LOCK or state == remote.spar.SPAR_LOCK then
		--self:getParent():setVisible(false)
		self:resetAll()
		self._ccbOwner.sprite_greenplus:setVisible(false)
	else
		self:getParent():setVisible(true)
		self._ccbOwner.sp_lock:setVisible(false)
	end
end

function QUIWidgetGemstonesSmallBox:resetAll()
	self._ccbOwner.sp_lock:setVisible(true)
	self._ccbOwner.sprite_greenplus:setVisible(true)
	self._iconContent = nil
	if self._itemIcon then
		self._itemIcon:setVisible(false)
	end
end

return QUIWidgetGemstonesSmallBox