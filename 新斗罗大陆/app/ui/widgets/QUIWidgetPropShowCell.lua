--
-- Kumo.Wang
-- 属性表现
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetPropShowCell = class("QUIWidgetPropShowCell", QUIWidget)

function QUIWidgetPropShowCell:ctor(options)
	local ccbFile = "ccb/Widget_Prop_Show.ccbi"
	local callBacks = {}
	QUIWidgetPropShowCell.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._maxPropCount = self:hideAllProp()
	self._showCount = 0
end

function QUIWidgetPropShowCell:onEnter()
end

function QUIWidgetPropShowCell:onExit()
end

function QUIWidgetPropShowCell:getMaxPropCount()
	if self._maxPropCount then
		return self._maxPropCount
	end

	local index = 1
	while true do
		local node = self._ccbOwner["node_prop_"..index]
		if node then
			index = index + 1
		else
			index = index - 1
			break
		end
	end
	self._maxPropCount = index

	return self._maxPropCount
end

function QUIWidgetPropShowCell:getShowCount()
	return self._showCount
end

function QUIWidgetPropShowCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetPropShowCell:setProp(prop)
	self._showCount = self._showCount + 1
	local node = self._ccbOwner["node_prop_"..self._showCount]
	if node then
		node:setVisible(true)
		self._ccbOwner["name_"..self._showCount]:setString(prop.name)
		self._ccbOwner["old_prop_"..self._showCount]:setString(prop.old)
		self._ccbOwner["new_prop_"..self._showCount]:setString(prop.new)
	else
		self._showCount = self._showCount - 1
	end
end

function QUIWidgetPropShowCell:hideAllProp()
	local index = 1
	while true do
		local node = self._ccbOwner["node_prop_"..index]
		if node then
			node:setVisible(false)
			index = index + 1
		else
			index = index - 1
			break
		end
	end

	return index
end

function QUIWidgetPropShowCell:FadeIn(time)
	local index = 1
	while true do
		local isFind = false
		local nodeName = self._ccbOwner["name_"..index]
		if nodeName then
			nodeName:runAction(CCFadeIn:create(time))
			isFind = true
		end
		local nodeOld = self._ccbOwner["old_prop_"..index]
		if nodeOld then
			nodeOld:runAction(CCFadeIn:create(time))
			isFind = true
		end
		local nodeNew = self._ccbOwner["new_prop_"..index]
		if nodeNew then
			nodeNew:runAction(CCFadeIn:create(time))
			isFind = true
		end
		local nodeSp = self._ccbOwner["sp_"..index]
		if nodeSp then
			nodeSp:runAction(CCFadeIn:create(time))
			isFind = true
		end

		if not isFind then
			break
		else
			index = index + 1
		end
	end
end

function QUIWidgetPropShowCell:FadeOut(time)
	local index = 1
	while true do
		local isFind = false
		local nodeName = self._ccbOwner["name_"..index]
		if nodeName then
			nodeName:runAction(CCFadeOut:create(time))
			isFind = true
		end
		local nodeOld = self._ccbOwner["old_prop_"..index]
		if nodeOld then
			nodeOld:runAction(CCFadeOut:create(time))
			isFind = true
		end
		local nodeNew = self._ccbOwner["new_prop_"..index]
		if nodeNew then
			nodeNew:runAction(CCFadeOut:create(time))
			isFind = true
		end
		local nodeSp = self._ccbOwner["sp_"..index]
		if nodeSp then
			nodeSp:runAction(CCFadeOut:create(time))
			isFind = true
		end

		if not isFind then
			break
		else
			index = index + 1
		end
	end
end

return QUIWidgetPropShowCell