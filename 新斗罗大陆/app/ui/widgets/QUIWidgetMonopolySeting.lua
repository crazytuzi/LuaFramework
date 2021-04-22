-- @Author: liaoxianbo
-- @Date:   2019-04-30 18:36:40
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-27 18:58:47
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMonopolySeting = class("QUIWidgetMonopolySeting", QUIWidget)

QUIWidgetMonopolySeting.EVENT_SELECT_CLICK = "EVENT_SELECT_CLICK"
QUIWidgetMonopolySeting.EVENT_SETTING_CLICK = "EVENT_SETTING_CLICK"

function QUIWidgetMonopolySeting:ctor(options)
	--这里使用的ccb应该是和小舞助手一样的 Widget_Secretary_client2，但是UI翻新的关系新增 Widget_Secretary_client3
	--等冰火翻新的时候可以直接换回 Widget_Secretary_client2
	local ccbFile = "ccb/Widget_Secretary_client3.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
		{ccbCallbackName = "onTriggerSet", callback = handler(self, self._onTriggerSet)},
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
    }
    QUIWidgetMonopolySeting.super.ctor(self, ccbFile, callBacks, options)
	q.setButtonEnableShadow(self._ccbOwner.btn_go)
  	q.setButtonEnableShadow(self._ccbOwner.btn_set)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetMonopolySeting:onEnter()
end

function QUIWidgetMonopolySeting:onExit()
end

function QUIWidgetMonopolySeting:resetAll()
	self._ccbOwner.tf_name:setString("")
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_select:setVisible(false)
	self._ccbOwner.node_ok:setVisible(false)
	self._ccbOwner.node_go:setVisible(false)
	self._ccbOwner.node_rank:setVisible(false)
	self._ccbOwner.btn_set:setVisible(false)
	self._ccbOwner.tf_set_desc:setVisible(false)
	self._ccbOwner.node_money:setVisible(false)
	self._ccbOwner.node_active_tips:setVisible(false)
end

function QUIWidgetMonopolySeting:setSelected(bSelected)
	self._ccbOwner.sp_select:setVisible(bSelected)
end

function QUIWidgetMonopolySeting:setInfo(info)
	self:resetAll()

	self._info = info
	self._ccbOwner.tf_name:setString(info.name or "")

	-- icon
	local icon = CCSprite:create(info.icon)
	icon:setScale(86/icon:getContentSize().width)
    self._ccbOwner.node_icon:addChild(icon)

    -- 设置开启
	local isOpen = self._info.havesetbtn or false
	self._ccbOwner.btn_set:setVisible(isOpen)

	self._ccbOwner.node_select:setVisible(true)
	self._ccbOwner.node_ok:setVisible(false)

	self._ccbOwner.tf_name:setPositionY(-66)

	local curSetting = remote.monopoly:getSelectByMonopolyId(self._info.tabId)  --self._ccbOwner.sp_select:isVisible()
	local isOpen = curSetting.isOpen or false
	self:setSelected(isOpen)

	-- 开箱次数
	if self._info.tabId == remote.monopoly.ZIDONG_OPEN then
		if curSetting.openNum and curSetting.openNum > 1 then
			self._ccbOwner.tf_set_desc:setVisible(true)
			self._ccbOwner.tf_set_desc:setString("开箱"..curSetting.openNum.."次")
		else
			-- if curSetting.openNum == 1 then
				self._ccbOwner.tf_set_desc:setVisible(true)
				self._ccbOwner.tf_set_desc:setString("免费一次")
			-- end
		end
	end
	-- 猜拳次数
	if self._info.tabId == remote.monopoly.ZIDONG_CAIQUAN then
		if curSetting.caiQuanNum then
			self._ccbOwner.tf_set_desc:setVisible(true)
			self._ccbOwner.tf_set_desc:setString("猜拳"..curSetting.caiQuanNum.."次")
		else
			self._ccbOwner.tf_set_desc:setVisible(true)
			self._ccbOwner.tf_set_desc:setString("猜拳1次")		
		end
	end

	if self._info.tabId ~= remote.monopoly.ZIDONG_OPEN and self._info.tabId ~= remote.monopoly.ZIDONG_CAIQUAN then
		self._ccbOwner.tf_set_desc:setVisible(false)
	end
end

function QUIWidgetMonopolySeting:_onTriggerSelect()
    app.sound:playSound("common_switch")
    local checkState = self._ccbOwner.sp_select:isVisible()
    self:setSelected(not checkState)
	self:dispatchEvent({name = QUIWidgetMonopolySeting.EVENT_SELECT_CLICK, id = self._info.tabId})
end

function QUIWidgetMonopolySeting:_onTriggerSet()
    app.sound:playSound("common_switch")
	self:dispatchEvent({name = QUIWidgetMonopolySeting.EVENT_SETTING_CLICK, id = self._info.tabId})
end

function QUIWidgetMonopolySeting:_onTriggerGo()
end

function QUIWidgetMonopolySeting:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	return size
end

return QUIWidgetMonopolySeting
