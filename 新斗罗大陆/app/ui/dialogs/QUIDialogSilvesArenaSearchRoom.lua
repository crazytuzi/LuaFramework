--
-- Kumo.Wang
-- 西尔维斯大斗魂场搜索队伍界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilvesArenaSearchRoom = class("QUIDialogSilvesArenaSearchRoom", QUIDialog)

function QUIDialogSilvesArenaSearchRoom:ctor(options)
	local ccbFile = "ccb/Dialog_SilvesArena_Search.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerSearch", callback = handler(self, self._onTriggerSearch)},
    }
    QUIDialogSilvesArenaSearchRoom.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.btn_search)

    if options then
    	self._callback = options.callback
    end
    
	-- add input text box
    self._editBox = ui.newEditBox({ image = "ui/none.png", listener = function () end, size = CCSize(420, 50), })
    -- self._editBox:setPlaceholderFontColor(COLORS.g)
    self._editBox:setPlaceHolder("请输入队伍号码")
    self._editBox:setFont(global.font_default, 26)
    self._editBox:setFontColor(COLORS.k)
    self._editBox:setMaxLength(20)
    self._editBox:setPlaceholderFontColor(UNITY_COLOR.brown)
    self._ccbOwner.node_editBox:addChild(self._editBox)
    self._editBox:registerScriptEditBoxHandler(function(returnType)
    		local text = self._editBox:getText()
    		self._editBox:setText(string.sub(text or "", 1, 6))    	
	end)

	self._ccbOwner.node_btn_search:setVisible(true)
	self._ccbOwner.btn_search:setTouchEnabled(true)
end

function QUIDialogSilvesArenaSearchRoom:viewDidAppear()
	QUIDialogSilvesArenaSearchRoom.super.viewDidAppear(self)
end

function QUIDialogSilvesArenaSearchRoom:viewWillDisappear()
  	QUIDialogSilvesArenaSearchRoom.super.viewWillDisappear(self)
end

function QUIDialogSilvesArenaSearchRoom:_onTriggerSearch(event)
	if self._editBox then
		self._teamSymbol = self._editBox:getText()

		if tonumber(self._teamSymbol) == nil then
			app.tip:floatTip("请输入有效号码")
			return
		end

		self:playEffectOut()
	end
end

function QUIDialogSilvesArenaSearchRoom:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSilvesArenaSearchRoom:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSilvesArenaSearchRoom:viewAnimationOutHandler()
	local callback = self._callback
	local teamSymbol = self._teamSymbol

	self:popSelf()
	
	if callback and tonumber(teamSymbol) then
		callback(teamSymbol)
	end
end

return QUIDialogSilvesArenaSearchRoom
