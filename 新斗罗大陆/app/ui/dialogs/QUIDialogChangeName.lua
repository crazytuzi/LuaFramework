--
-- Author: Qinyuanji
-- Date: 2014-11-19 
-- 
local QUIDialog = import(".QUIDialog")
local QUIDialogChangeName = class("QUIDialogChangeName", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QMaskWords = import("...utils.QMaskWords")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIViewController = import("..QUIViewController")

QUIDialogChangeName.NO_INPUT_ERROR = "名字不能为空"
QUIDialogChangeName.DEFAULT_PROMPT = "请输入战队名字"
QUIDialogChangeName.INVALID_WORD_ERROR = "无效的名字" -- 有敏感字符
QUIDialogChangeName.INVALID_LETTER_ERROR = "只允许中文、字母和数字"
QUIDialogChangeName.NAME_IS_TO_LARGE = "魂师，您取的名字太长了～"

local function onEdit(event, editbox)
    if event == "began" then

    elseif event == "changed" then

    elseif event == "ended" then
        -- 输入结束
    elseif event == "return" then
        -- 从输入框返回
    end
end

function QUIDialogChangeName:ctor(options)
	local ccbFile = "ccb/Dialog_MyInformation_ChangeName&Duihuan.ccbi";
	if options and options.isTutorial then
		ccbFile = "ccb/Dialog_MyInformation_ChangeName&Duihuan1.ccbi";
	end
	local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogChangeName._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerRandomName", callback = handler(self, QUIDialogChangeName._onTriggerRandomName)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogChangeName._onTriggerClose)},
	}
	QUIDialogChangeName.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true --是否动画显示

	-- update layout
	self._ccbOwner.tf_changeName:setVisible(true)
	self._ccbOwner.tf_exchangeNode:setVisible(false)

	-- add input box
    self.g_NickName = ui.newEditBox({image = "ui/none.png", listener = onEdit, size = CCSize(230, 48)})
    self.g_NickName:setFont(global.font_name, 26)
    self.g_NickName:setFontColor(UNITY_COLOR.brown)
    self.g_NickName:setPlaceholderFontColor(UNITY_COLOR.brown)
    self.g_NickName:setMaxLength(7)
    self.g_NickName:setPlaceHolder(QUIDialogChangeName.DEFAULT_PROMPT)
    self._ccbOwner.tf_nickName:addChild(self.g_NickName)
    self._ccbOwner.tf_nickName:setColor(UNITY_COLOR.brown)

    self._oldName = options.nickName or ""
	self._nameChangedCallBack = options.nameChangedCallBack
	self._cancelCallBack = options.cancelCallBack
	if options then
		self._isTutorial = options.isTutorial
	end

	-- This part is for Arena:
	-- If user has no name bound, force until he selects a name and no outbound click works
	self._arena = options.arena or false

	--xurui: set default random name
	if self._oldName == "" then
		local newName = self:_getRandomName()
	   	while QMaskWords:isFind(newName) do
	   		newName = self:_getRandomName()
	   	end
		self.g_NickName:setText(newName)
	end

	if self._ccbOwner.charge and self._ccbOwner.free and self._ccbOwner.cost then
		self._ccbOwner.free:setVisible((remote.user.changeNicknameCount or 0) <= 0)
		self._ccbOwner.charge:setVisible((remote.user.changeNicknameCount or 0) > 0)
		self._ccbOwner.cost:setString(self:_tokenConsumeNumber((remote.user.changeNicknameCount or 0)))
	end

	if self._ccbOwner.node_welcome then
		self._avatar = QSkeletonActor:create("jm_xiaowu")
    	self._avatar:playAnimation("animation", true)
    	self._avatar:setScale(0.6)
		self._ccbOwner.node_welcome:addChild(self._avatar)
	end
end

function QUIDialogChangeName:viewDidAppear()
	QUIDialogChangeName.super.viewDidAppear(self)
	self.g_NickName:setVisible(true)
	-- local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
 --    if page ~= nil and page.class.__cname == "QUIPageMainMenu" then 
 --        page:setTutorialModel(false)
 --    end
end 

function QUIDialogChangeName:viewWillDisappear()
	QUIDialogChangeName.super.viewWillDisappear(self)
	self.g_NickName:setVisible(false)
	-- local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	-- if page ~= nil and page.class.__cname == "QUIPageMainMenu" then 
 --        page:setTutorialModel(true)
 --    end
end 

-- If name is not changed, just close the dialog
-- If name was not changed before(empty), no token consume prompt poped up
-- If name was changed before(not empty), pop up prompt
function QUIDialogChangeName:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
	app.sound:playSound("common_confirm")
	local newName = self.g_NickName:getText()
	if self:_invalidNames(newName) then
		app.tip:floatTip(QUIDialogChangeName.NO_INPUT_ERROR)
		return
	end

	newName = QReplaceEmoji(newName,"")
	if self:_invalidNames(newName) then
		app.tip:floatTip(QUIDialogChangeName.INVALID_WORD_ERROR)
		return
	end
	
	if self:_sensitiveNames(newName) then
		app.tip:floatTip(QUIDialogChangeName.INVALID_WORD_ERROR)
		return
	end

	if newName == self._oldName then
		self:_onTriggerCancel()
		return
	end

	local replaced = string.gsub(newName, "[A-Za-z0-9]", "")
	-- UTF-8 规范中 中文字符都是三个字节的
	local _, count = string.gsub(replaced, "[^\128-\193]", "")
	for uchar in string.gmatch(replaced, "[%z\1-\127\194-\244][\128-\191]*") do
		if string.len(uchar) ~= 3 then
			app.tip:floatTip(QUIDialogChangeName.INVALID_LETTER_ERROR)
			return
		end
	end

	local nameLen = string.utf8len(newName)
	if nameLen > 7 then
		app.tip:floatTip(QUIDialogChangeName.NAME_IS_TO_LARGE)
		return 
	end

	-- self.g_NickName:setVisible(false)
	if self._oldName == self:_freeNameChanged() then
		app:getClient():changeNickName(newName, function (data)
				if self._nameChangedCallBack then
					self._nameChangedCallBack(newName)
				end
				self._oldName = newName
				self:_onTriggerClose()
			end)
		self.g_NickName:setVisible(true)
	else
		if remote.user.token >= self:_tokenConsumeNumber(remote.user.changeNicknameCount) then
			app:getClient():changeNickName(newName, function (data)
				if self._nameChangedCallBack then
					self._nameChangedCallBack(newName)
				end
				self._oldName = newName
				self:_onTriggerClose()
			end)
		else
			app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
			app:vipAlert({textType = VIPALERT_TYPE.NO_TOKEN}, false)
		end
	end
end 

function QUIDialogChangeName:_freeNameChanged()
	return ""
end

function QUIDialogChangeName:_invalidNames(newName)
	return newName == "" or newName == QUIDialogChangeName.DEFAULT_PROMPT
end

function QUIDialogChangeName:_sensitiveNames(newName)
	return QMaskWords:isFind(newName)
end

function QUIDialogChangeName:_tokenConsumeNumber(count)
	count = count or 0
	if count <= 0 then 
		return 0
	else
		local count = QStaticDatabase:sharedDatabase():getConfigurationValue("NAME_CHANGE") or -100
		return count
	end
end

function QUIDialogChangeName:_onTriggerRandomName()
	app.sound:playSound("common_item")
    self.g_NickName:setText("")
    -- self.g_NickName:setFontColor(display.COLOR_WHITE)

    local newName = self:_getRandomName()
   	while QMaskWords:isFind(newName) do
   		newName = self:_getRandomName()
   	end
    self.g_NickName:setText(newName)
end

function QUIDialogChangeName:_getRandomName()
	local namePlayers = QStaticDatabase:sharedDatabase():getNamePlayers()
	local firstPart = {}
	local secondPart = {}
	local thirdPart = {}
	for k, names in pairs(namePlayers) do
		table.insert(firstPart, names.part_1)
		table.insert(secondPart, names.part_2)
		table.insert(thirdPart, names.part_3)
	end

	local namePart1 = firstPart[math.random(#firstPart)]
	local namePart2 = secondPart[math.random(#secondPart)]
	local namePart3 = thirdPart[math.random(#thirdPart)]

	return namePart1 .. namePart2 .. namePart3
end

function QUIDialogChangeName:_backClickHandler()
	-- For Arena, no outbound click triggers dialog disappear
	if not self._arena then
    	self:_onTriggerClose()
    end
end

function QUIDialogChangeName:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	if event then
		app.sound:playSound("common_cancel")
	end
	self:playEffectOut()
end

function QUIDialogChangeName:_onTriggerCancel()
	-- Arena doesn't allow user to cancal naming
	if self._arena then
		if self._cancelCallBack ~= nil then
			self._cancelCallBack()
		end
	else
		
		self:_onTriggerClose()
	end
end

function QUIDialogChangeName:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogChangeName
