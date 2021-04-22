--
-- Author: xurui
-- Date: 2016-07-25 16:09:49
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetBackPackBar = class("QUIWidgetBackPackBar", QUIWidget)

QUIWidgetBackPackBar.EVENT_CLICK_BACKPACK_BAR = "EVENT_CLICK_BACKPACK_BAR"

function QUIWidgetBackPackBar:ctor(options)
	local ccbFile = "ccb/Widget_Baoshi_Packsack_info.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClickBackPack", callback = handler(self, self._onTriggerClickBackPack)}
	}
	QUIWidgetBackPackBar.super.ctor(self, ccbFile, callBacks, options)	
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._index = options.index
    end
    self:setInfo()
    self:checkRedTips()
end

function QUIWidgetBackPackBar:onEnter()
end

function QUIWidgetBackPackBar:onExit()
	if self._scheduler ~= nil then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
end

function QUIWidgetBackPackBar:checkRedTips()
	local isShowTips = false
	if self._index == 1 then
		isShowTips = remote.items:checkItemRedTipsByCategory(ITEM_CONFIG_CATEGORY.MATERIAL, ITEM_CONFIG_CATEGORY.SOUL, ITEM_CONFIG_CATEGORY.CONSUM)
		local overdue = remote.items:checkOverdueItems()
		self._ccbOwner.sp_expired:setVisible(overdue)
	elseif self._index == 2 then
		isShowTips = remote.gemstone:checkBackPackTips() or remote.spar:checkBackPackTips()
	elseif self._index == 3 then
		-- 魂灵
		isShowTips = false
	elseif self._index == 4 then
		-- 神器
		isShowTips = false
	elseif self._index == 5 then
		-- 仙品
		isShowTips = remote.magicHerb:checkBackPackTips()
	end
    self._ccbOwner.red_tips:setVisible(isShowTips)
end

function QUIWidgetBackPackBar:setInfo()
	self._ccbOwner.node_1:setVisible(self._index == 1)
	self._ccbOwner.node_2:setVisible(self._index == 2)
	self._ccbOwner.node_3:setVisible(self._index == 3)
	self._ccbOwner.node_4:setVisible(self._index == 4)
	self._ccbOwner.node_5:setVisible(self._index == 5)

	local content = ""
	if self._index == 1 then
		content = "存放消耗品、魂师碎片、突破材料"
	elseif self._index == 2 then
		content = "存放魂骨突破材料及魂骨碎片"
	elseif self._index == 3 then
		content = "存放魂灵升级材料和魂灵碎片"
	elseif self._index == 4 then
		content = "存放神器升级材料和神器碎片"
	elseif self._index == 5 then
		content = "存放仙品和转生道具"	
	end
	self._ccbOwner.content_dec:setString(content)
end

function QUIWidgetBackPackBar:onTouchListView( event )	
	if not event then
		return
	end
	if event.name == "began" then
		self._ccbOwner.node_box:setScale(1.05)
	elseif event.name == "moved" then
	elseif  event.name == "ended" then
		self._ccbOwner.node_box:setScale(1)
	end
end

function QUIWidgetBackPackBar:getIndex()
	return self._index
end

function QUIWidgetBackPackBar:_onTriggerClickBackPack(event)
	if tonumber(event) == CCControlEventTouchDown then
		self._ccbOwner.node_box:setScale(1.05)
	elseif tonumber(event) == CCControlEventTouchUpInside then
		self._ccbOwner.node_box:setScale(1)
		self._scheduler = scheduler.performWithDelayGlobal(function()
				if self.class ~= nil then
					self:dispatchEvent({name = QUIWidgetBackPackBar.EVENT_CLICK_BACKPACK_BAR, index = self._index})
				end
			end, 0)
	else
		self._ccbOwner.node_box:setScale(1)
	end
end

function QUIWidgetBackPackBar:getContentSize()
	return self._ccbOwner.bg_size:getContentSize()
end

return QUIWidgetBackPackBar