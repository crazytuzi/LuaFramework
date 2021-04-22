--
-- Kumo.Wang
-- 西尔维斯大斗魂场创建队伍界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilvesArenaCreateRoom = class("QUIDialogSilvesArenaCreateRoom", QUIDialog)

local QMaskWords = import("...utils.QMaskWords")

function QUIDialogSilvesArenaCreateRoom:ctor(options)
	local ccbFile = "ccb/Dialog_SilvesArena_Create.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogSilvesArenaCreateRoom.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._ccbOwner.frame_tf_title:setString("创建队伍")

    q.setButtonEnableShadow(self._ccbOwner.btn_ok)

    if options then
    	self._callback = options.callback
    end
    
	-- add input text box
    self._editBoxName = ui.newEditBox({ image = "ui/none.png", listener = function () end, size = CCSize(320, 50), })
    -- self._editBox:setPlaceholderFontColor(COLORS.g)
    self._editBoxName:setPlaceHolder("请输入战队名字")
    self._editBoxName:setFont(global.font_default, 26)
    self._editBoxName:setFontColor(COLORS.k)
    self._editBoxName:setMaxLength(7)
    self._ccbOwner.node_editBox_name:addChild(self._editBoxName)
 --    self._editBoxName:registerScriptEditBoxHandler(function(returnType)
 --    		local text = self._editBoxName:getText()
 --    		self._editBoxName:setText(string.sub(text or "", 1, 6))    	
	-- end)

	self._editBoxForceLimit = ui.newEditBox({ image = "ui/none.png", listener = function(eventname,sender)
	 		self:editboxHandle(eventname,sender) 
	 	end, size = CCSize(320, 50), })
    -- self._editBox:setPlaceholderFontColor(COLORS.g)
    self._editBoxForceLimit:setPlaceHolder("输入最低战力（单位为万）")
    self._editBoxForceLimit:setFont(global.font_default, 26)
    self._editBoxForceLimit:setFontColor(COLORS.k)
    self._editBoxForceLimit:setMaxLength(8)
    self._ccbOwner.node_editBox_forceLimit:addChild(self._editBoxForceLimit)
    
	self._ccbOwner.node_btn_ok:setVisible(true)
	self._ccbOwner.btn_ok:setTouchEnabled(true)
end

function QUIDialogSilvesArenaCreateRoom:editboxHandle(strEventName,sender)
	self._num = 0
	local text = self._editBoxForceLimit:getText()
	local numText = string.gsub(text, "万", "")
	local numStr = tonumber(numText)

	if numStr then
		if numText == text and self._num ~= 0 then
			self._num = math.floor(self._num / 10)
		else
			self._num = numStr
		end
	else
		
	end

	self:changeEditBox()
end

function QUIDialogSilvesArenaCreateRoom:changeEditBox()
	if self._num > 0 then
		self._editBoxForceLimit:setText(self._num.."万")
	else
		self._editBoxForceLimit:setText(0)
	end      --输入内容改变时调用 
end


function QUIDialogSilvesArenaCreateRoom:viewDidAppear()
	QUIDialogSilvesArenaCreateRoom.super.viewDidAppear(self)
end

function QUIDialogSilvesArenaCreateRoom:viewWillDisappear()
  	QUIDialogSilvesArenaCreateRoom.super.viewWillDisappear(self)
end

function QUIDialogSilvesArenaCreateRoom:_onTriggerOK(event)
	local isNameOK = false
	local isForceLimitOK = false

	if self._editBoxName then
		self._teamName = self._editBoxName:getText()

		if self:_invalidNames(self._teamName) then
			app.tip:floatTip("名字不能为空")
			return
		end
		if self:_sensitiveNames(self._teamName) then
			app.tip:floatTip("无效的名字")
			return
		end

		local replaced = string.gsub(self._teamName, "[A-Za-z0-9]", "")
		-- UTF-8 规范中 中文字符都是三个字节的
		local _, count = string.gsub(replaced, "[^\128-\193]", "")
		for uchar in string.gmatch(replaced, "[%z\1-\127\194-\244][\128-\191]*") do
			if string.len(uchar) ~= 3 then
				app.tip:floatTip("只允许中文、字母和数字")
				return
			end
		end

		local nameLen = string.utf8len(self._teamName)
		if nameLen > 7 then
			app.tip:floatTip("战队名字太长了～")
			return 
		end

		isNameOK = true
	end

	if self._editBoxForceLimit then
		self._teamForceLimit = self._editBoxForceLimit:getText()
		self._teamForceLimit = string.gsub(self._teamForceLimit, "万", "")
		self._teamForceLimit = tonumber( self._teamForceLimit )

		if self._teamForceLimit then
			isForceLimitOK = true
		end
	end

	if not isForceLimitOK then
		self._teamForceLimit = 0
	end

	self._teamForceLimit = self._teamForceLimit * 10000

	if self._teamForceLimit > remote.silvesArena.FORCE_LIMIT then
		self._teamName = nil
		self._teamForceLimit = nil
		app.tip:floatTip("战力限制太高了～")
		return 
	end
	
	if isNameOK then
		self:playEffectOut()
	end
end

function QUIDialogSilvesArenaCreateRoom:_invalidNames(name)
	return name == "" or name == "请输入战队名字"
end

function QUIDialogSilvesArenaCreateRoom:_sensitiveNames(name)
	return QMaskWords:isFind(name)
end

function QUIDialogSilvesArenaCreateRoom:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSilvesArenaCreateRoom:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSilvesArenaCreateRoom:viewAnimationOutHandler()
	local callback = self._callback
	local teamName = self._teamName
	local teamForceLimit = self._teamForceLimit

	self:popSelf()
	
	if callback and teamName and teamForceLimit then
		callback(teamName, teamForceLimit)
	end
end

return QUIDialogSilvesArenaCreateRoom
