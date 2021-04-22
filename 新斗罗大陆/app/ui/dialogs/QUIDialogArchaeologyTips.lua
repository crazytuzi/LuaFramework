--
-- Author: Kumo
-- Date: Sat Mar  5 16:26:10 2016
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogArchaeologyTips = class("QUIDialogArchaeologyTips", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QColorLabel = import("...utils.QColorLabel")

function QUIDialogArchaeologyTips:ctor(options)
	local ccbFile = "ccb/Dialog_Archaeologyxiyou.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogArchaeologyTips._onTriggerClose)},
	}
	QUIDialogArchaeologyTips.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self.isAnimation = true --是否动画显示

	self._size = self._ccbOwner.buff_size:getContentSize()
	self._config = options.config
end

function QUIDialogArchaeologyTips:viewDidAppear()
	QUIDialogArchaeologyTips.super.viewDidAppear(self)
	self:addBackEvent()
	self:_getBuffs()
end

function QUIDialogArchaeologyTips:viewWillDisappear()
	QUIDialogArchaeologyTips.super.viewWillDisappear(self)
	self:removeBackEvent()
end

function QUIDialogArchaeologyTips:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogArchaeologyTips:_onTriggerClose()
	app.sound:playSound("common_cancel")
   	self:playEffectOut()
end

function QUIDialogArchaeologyTips:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogArchaeologyTips:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

function QUIDialogArchaeologyTips:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogArchaeologyTips:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QUIDialogArchaeologyTips:_getBuffs()
	local tbl = remote.archaeology:getFragmentBuffNameAndValueByID(self._config.id, self._config.map_id)
	local name = ""
	local value = 0

	for k, v in pairs(tbl) do
		name = k
		value = v
		break
	end
	local str 
	if string.find(name, "加伤") then
		str = "PVP的玩法内，伤害增加##g"..(value*100).."%"
	elseif string.find(name, "减伤") then
		str = "PVP的玩法内，伤害降低##g"..(value*100).."%"
	end

	self._buff = str

	self:_showBuffs()
end

function QUIDialogArchaeologyTips:_showBuffs()
	local w = self._size.width - 80
	local buffText = QColorLabel:create(self._buff, w, self._size.height, nil, nil, GAME_COLOR_LIGHT.normal)
	self._ccbOwner.node_buff:addChild(buffText)
	buffText:setPosition(ccp(0, 0))
	local h = buffText:getActualHeight() -- 文本实际高度
	local x, y = self._ccbOwner.node_buff:getPosition()
	self._ccbOwner.node_buff:setPosition(ccp(x + (self._size.width - w)/2, y - (self._size.height - h)/4))
end

----------------------------------------------------- System callbacks --------------------------------------------------

function QUIDialogArchaeologyTips:_backClickHandler()
	self:_onTriggerClose()
end

return QUIDialogArchaeologyTips
