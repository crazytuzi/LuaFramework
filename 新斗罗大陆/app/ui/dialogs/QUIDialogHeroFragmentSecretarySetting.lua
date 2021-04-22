-- @Author: xurui
-- @Date:   2020-01-19 10:46:39
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-02-21 18:28:32
local QUIDialogSecretarySetting = import("..dialogs.QUIDialogSecretarySetting")
local QUIDialogHeroFragmentSecretarySetting = class("QUIDialogHeroFragmentSecretarySetting", QUIDialogSecretarySetting)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIDialogHeroFragmentSecretarySetting:ctor(options)
    if options then
    	self._widgets = options.widgets
    	self._totalHeight = options.totalHeight or 0
    	self._tipStr = options.tipStr
    	self._callBack = options.callback
    end

    QUIDialogHeroFragmentSecretarySetting.super.ctor(self, options)
end

function QUIDialogHeroFragmentSecretarySetting:initSettingLayer()
	if q.isEmpty(self._widgets) then return end
	
	for _, widget in ipairs(self._widgets) do
		self._scrollView:addItemBox(widget)
	end
	self._scrollView:setRect(0, -self._totalHeight, 0, self._sheetSize.width)
end

function QUIDialogHeroFragmentSecretarySetting:initSettingTips()
	self._ccbOwner.tf_tips:setVisible(false)
	if self._tipStr then
		self._ccbOwner.tf_tips:setVisible(true)
		self._ccbOwner.tf_tips:setString(self._tipStr)
	end
end

function QUIDialogHeroFragmentSecretarySetting:_onTriggerOk()
    app.sound:playSound("common_switch")

    if self._callBack then
    	self._callBack()
    end

    self:playEffectOut()
end

return QUIDialogHeroFragmentSecretarySetting
