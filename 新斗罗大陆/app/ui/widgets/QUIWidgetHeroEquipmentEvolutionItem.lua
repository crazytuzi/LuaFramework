--
-- Author: wkwang
-- Date: 2015-03-05 16:48:06
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroEquipmentEvolutionItem = class("QUIWidgetHeroEquipmentEvolutionItem", QUIWidget)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetHeroEquipmentEvolutionItem.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetHeroEquipmentEvolutionItem:ctor(options)
	local ccbFile = "ccb/Widget_HeroEquipment_Evolution_box.ccbi"
	local callBacks = {
			{ccbCallbackName = "onTriggerEvolution", callback = handler(self, QUIWidgetHeroEquipmentEvolutionItem._onTriggerEvolution)},
		}
	QUIWidgetHeroEquipmentEvolutionItem.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetHeroEquipmentEvolutionItem:onExit()
	self:removeAllEventListeners()
end

function QUIWidgetHeroEquipmentEvolutionItem:setBgDark(isDark)
	self._isDark = isDark
end

function QUIWidgetHeroEquipmentEvolutionItem:setTextOffsideY(value_)
	if self._ccbOwner.tf_left then
		self._ccbOwner.tf_left:setPositionY(self._ccbOwner.tf_left:getPositionY() + value_)
	end
end

function QUIWidgetHeroEquipmentEvolutionItem:setInfo(itemId, needNum, itemType)
	self._needNum = needNum
	self._itemId = itemId
	if self._itemBox == nil then
		self._itemBox = QUIWidgetItemsBox.new()
		self._ccbOwner.node_icon:addChild(self._itemBox)
	end
	if itemType == nil then itemType = ITEM_TYPE.ITEM end
	self._itemBox:setGoodsInfo(itemId, itemType, 0)
	self._itemType = itemType
	self._haveNum = 0
	self._compositeNum = 0
	self._ccbOwner.tf_red:setString("")
	if itemType == ITEM_TYPE.ITEM then
		self._haveNum = remote.items:getItemsNumByID(itemId)
		self._compositeNum = remote.items:getItemsComposeNumByID(itemId)
	else
		self._haveNum = remote.user[itemType] or 0
	end
	if self._needNum ~= nil then
		if self._haveNum < self._needNum then
			self._ccbOwner.tf_left:setString(self._haveNum.."/"..(self._needNum or 0))
			-- dldl-2050
			if self._isDark then
				self._ccbOwner.tf_left:setColor(COLORS.e)
			else
				self._ccbOwner.tf_left:setColor(COLORS.m)
			end
			if itemType == ITEM_TYPE.ITEM then
				if (self._haveNum + self._compositeNum) >= self._needNum then
					self:showCanComposite(true)
				else
					local isCanDrop,isPass = remote.items:getComposeItemIsCanDrop(itemId)
					if isPass == false and isCanDrop == true then
						self:showCanChallenge(true)
					else
						self:showCanDrop(isCanDrop)
					end
				end
			end
		else
			self._ccbOwner.tf_left:setString(self._haveNum.."/"..(self._needNum or 0))
			if self._isDark then
				self._ccbOwner.tf_left:setColor(COLORS.c)
			else
				self._ccbOwner.tf_left:setColor(COLORS.l)
			end
			self:showCanDrop(false)
		end
	else
		self._ccbOwner.tf_left:setString("")
	end
end

function QUIWidgetHeroEquipmentEvolutionItem:getItemId()
	return self._itemId 
end

--设置是否可以收集 就是掉落
function QUIWidgetHeroEquipmentEvolutionItem:showCanDrop(b)
	if self._animationDrop == nil and b == true then
		self._animationDrop = QUIWidget.new("ccb/effects/keshouji.ccbi")
		self._ccbOwner.node_effect:addChild(self._animationDrop)
	end
	if self._animationDrop ~= nil then
		self._animationDrop:setVisible(b)
	end
end

--设置是否可以挑战 可以收集 但是为通关
function QUIWidgetHeroEquipmentEvolutionItem:showCanChallenge(b)
	if self._animationChallenge == nil and b == true then
		-- self._animationChallenge = QUIWidget.new("ccb/effects/ketiaozhan.ccbi")
		-- 所有的可挑战全部改成可收集——by张明的界面优化
		self._animationChallenge = QUIWidget.new("ccb/effects/keshouji.ccbi")
		self._ccbOwner.node_effect:addChild(self._animationChallenge)
	end
	if self._animationChallenge ~= nil then
		self._animationChallenge:setVisible(b)
	end
end 

--设置是否可以合成
function QUIWidgetHeroEquipmentEvolutionItem:showCanComposite(b)
	if self._animationComposite == nil and b == true then
		self._animationComposite = QUIWidget.new("ccb/effects/kehecheng.ccbi")
		self._ccbOwner.node_effect:addChild(self._animationComposite)
	end
	if self._animationComposite ~= nil then
		self._animationComposite:setVisible(b)
	end
end

function QUIWidgetHeroEquipmentEvolutionItem:isEnough()
	return self._haveNum >= self._needNum
end

function QUIWidgetHeroEquipmentEvolutionItem:_onTriggerEvolution()
	self:dispatchEvent({name = QUIWidgetHeroEquipmentEvolutionItem.EVENT_CLICK, itemID = self._itemId, needNum = self._needNum, itemType = self._itemType})
end

return QUIWidgetHeroEquipmentEvolutionItem