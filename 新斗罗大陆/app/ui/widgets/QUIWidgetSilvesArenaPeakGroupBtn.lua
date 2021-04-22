--
-- Kumo.Wang
-- 西尔维斯大斗魂场巅峰赛小组赛小组按钮
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaPeakGroupBtn = class("QUIWidgetSilvesArenaPeakGroupBtn", QUIWidget)

QUIWidgetSilvesArenaPeakGroupBtn.EVENT_CLICK = "QUIWIDGETSILVESARENAPEAKGROUPBTN.EVENT_CLICK"

function QUIWidgetSilvesArenaPeakGroupBtn:ctor(options)
	local ccbFile = "ccb/Widget_Group_Btn.ccbi"
  	local callBacks = {
  		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
  	}
	QUIWidgetSilvesArenaPeakGroupBtn.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

  	if options then
  		self._index = options.index
  		self._myGroupIndex = options.myGroupIndex
  	end

	self:_init()
end

function QUIWidgetSilvesArenaPeakGroupBtn:onEnter()
	QUIWidgetSilvesArenaPeakGroupBtn.super.onEnter(self)
end

function QUIWidgetSilvesArenaPeakGroupBtn:onExit()
	QUIWidgetSilvesArenaPeakGroupBtn.super.onExit(self)
end

function QUIWidgetSilvesArenaPeakGroupBtn:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSilvesArenaPeakGroupBtn:update(curIndex)
	if not curIndex then return end
	
	self._ccbOwner.btn_group:setHighlighted(self._index == curIndex)
end

function QUIWidgetSilvesArenaPeakGroupBtn:_init()
	if not self._index then return end
	self._ccbOwner.tf_group:setString("第"..self._index.."组")
	self._ccbOwner.sp_self:setVisible(self._index == self._myGroupIndex)
end

function QUIWidgetSilvesArenaPeakGroupBtn:setBtnName( name )
	self._ccbOwner.tf_group:setString(name)
end

function QUIWidgetSilvesArenaPeakGroupBtn:_onTriggerClick(event)
	app.sound:playSound("common_small")

	self:dispatchEvent({name = QUIWidgetSilvesArenaPeakGroupBtn.EVENT_CLICK, index = self._index})
end

return QUIWidgetSilvesArenaPeakGroupBtn