--
-- Kumo.Wang
-- 時裝衣櫃皮肤头像外包装
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetFashionHeadBox = class("QUIWidgetFashionHeadBox", QUIWidget)

local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")

QUIWidgetFashionHeadBox.EVENT_CLICK = "QUIWIDGETFASHIONHEADBOX.EVENT_CLICK"

function QUIWidgetFashionHeadBox:ctor(options)
	local ccbFile = "Widget_Fashion_HeadBox.ccbi"
	local callBacks = {}
	QUIWidgetFashionHeadBox.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetFashionHeadBox:getInfo()
	return self._info
end

function QUIWidgetFashionHeadBox:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetFashionHeadBox:setInfo(info)
	self._info = info
	if not self._info then return end
	self:refreshInfo()
end

function QUIWidgetFashionHeadBox:refreshInfo()
	if not self._info then return end

	self._ccbOwner.node_headbox:removeAllChildren()
    local headBox = QUIWidgetHeroHead.new()
    headBox:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self.onTriggerClick))
    headBox:setHeroSkinId(self._info.skins_id)
    headBox:setHero(self._info.character_id)
    headBox:setBreakthrough()
    headBox:setGodSkillShowLevel()
    self._ccbOwner.node_headbox:addChild(headBox)

    self._ccbOwner.node_fashion_title:removeAllChildren()
    if self._info.quality then
    	local titlePath = remote.fashion:getHeadTitlePathByQuality( self._info.quality )
    	if titlePath then
	    	local sp = CCSprite:create(titlePath)
	    	if sp then
	    		self._ccbOwner.node_fashion_title:addChild(sp)
	    	end
	    end

	    local fontColor = remote.fashion:getHeadColorByQuality(self._info.quality)
	    if fontColor then
	    	self._ccbOwner.tf_fashion_name:setColor(fontColor)
	    	self._ccbOwner.tf_fashion_name = setShadowByFontColor(self._ccbOwner.tf_fashion_name, fontColor)
	    end
    end
    self._ccbOwner.tf_fashion_name:setString(self._info.skins_name)
    self._ccbOwner.tf_fashion_name:setVisible(false)
end

function QUIWidgetFashionHeadBox:setFashionNameVisible(boo)
    self._ccbOwner.tf_fashion_name:setVisible(boo)
    if boo then
    	self._ccbOwner.node_headbox:setPositionY(8)
    	self._ccbOwner.node_fashion_title:setPositionY(60)
    else
    	self._ccbOwner.node_headbox:setPositionY(0)
    	self._ccbOwner.node_fashion_title:setPositionY(52)
    end
end

function QUIWidgetFashionHeadBox:onTriggerClick()
	self:dispatchEvent({name = QUIWidgetFashionHeadBox.EVENT_CLICK, info = self._info})
end

return QUIWidgetFashionHeadBox
