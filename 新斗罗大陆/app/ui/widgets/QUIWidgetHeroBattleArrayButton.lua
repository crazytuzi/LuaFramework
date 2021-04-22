

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroBattleArrayButton = class("QUIWidgetHeroBattleArrayButton", QUIWidget)


function QUIWidgetHeroBattleArrayButton:ctor(options)
	local ccbFile = "ccb/Widget_HeroArray_Button.ccbi"
    local callBacks = {
    	{ccbCallbackName = "onTriggerClickBtn", callback = handler(self, self._onTriggerClickBtn)},
	}
    QUIWidgetHeroBattleArrayButton.super.ctor(self, ccbFile, callBacks, options)

	q.setButtonEnableShadow(self._ccbOwner.btn_cell)

	self._btnType = options.btnType or 1
	self._btnStr = options.btnStr or ""
	self._visibleIndex = options.visibleIndex or nil

	self._clickCallBack = options.clickCallBack
	self:_initInfo()
end

function QUIWidgetHeroBattleArrayButton:onEnter()
end

function QUIWidgetHeroBattleArrayButton:onExit()
end

function QUIWidgetHeroBattleArrayButton:_initInfo()
	self:setInfo()
end

function QUIWidgetHeroBattleArrayButton:setInfo()

	local path = QResPath("array_button_res")[self._btnType]

	self._ccbOwner.btn_cell:setBackgroundSpriteFrameForState(QSpriteFrameByPath(path), CCControlStateNormal)
	self._ccbOwner.btn_cell:setBackgroundSpriteFrameForState(QSpriteFrameByPath(path), CCControlStateHighlighted)
	self._ccbOwner.btn_cell:setBackgroundSpriteFrameForState(QSpriteFrameByPath(path), CCControlStateDisabled)
	local sprite = CCSprite:create(path)

	self._ccbOwner.btn_cell:setContentSize(sprite:getContentSize())
	self._ccbOwner.tf_button_bottom:setString(self._btnStr)

end

function QUIWidgetHeroBattleArrayButton:setVisibleByIndex(index)
	print("setVisibleByIndex "..index)
	if self._visibleIndex then
	print("setVisibleByIndex 	_visibleIndex "..self._visibleIndex)
		self:setVisible(self._visibleIndex == index)
	end
end

function QUIWidgetHeroBattleArrayButton:_onTriggerClickBtn()
	print("_onTriggerClickBtn")
	if self._clickCallBack then
		self._clickCallBack()
		return
	end
end

return QUIWidgetHeroBattleArrayButton