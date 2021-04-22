-- @Author: liaoxianbo
-- @Date:   2020-08-05 16:42:08
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-18 16:44:20
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBustdialogue = class("QUIDialogBustdialogue", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")

function QUIDialogBustdialogue:ctor(options)
	-- local ccbFile = "ccb/QDialog.ccbi"
 --    local callBacks = {
	-- 	{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
 --    }
    QUIDialogBustdialogue.super.ctor(self, ccbFile, callBacks, options)
 --    self.isAnimation = true

	-- cc.GameObject.extend(self)
	-- self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._callBack = options.callBack
    self._gridInfo = options.gridInfo
    
	self._step = 0
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord(self._gridInfo.dungeon_dialog_id)
    self._distance = "left"
    self:createDialogue()    
end

function QUIDialogBustdialogue:viewDidAppear()
	QUIDialogBustdialogue.super.viewDidAppear(self)
    local color = ccc4(0, 0, 0, 128)

  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
    self._touchNode:setTouchEnabled(true)
  	self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouch))
end

function QUIDialogBustdialogue:viewWillDisappear()
  	QUIDialogBustdialogue.super.viewWillDisappear(self)

	if self._touchNode ~= nil then
		self._touchNode:setTouchEnabled( false )
		self._touchNode:removeFromParent()
		self._touchNode = nil
	end
end

function QUIDialogBustdialogue:createDialogue()
	if self._dialogueRight ~= nil then --and self._distance ~= self._tutorialInfo[1][3] then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
	
    local heroInfo = db:getCharacterByID(self._tutorialInfo[1][1])
	local name = heroInfo.name or "泰奶奶"
	self._word = self._tutorialInfo[1][4] or ""
	self._distance = self._tutorialInfo[1][3]
	self._avatarKey = self._tutorialInfo[1][2]
	self._isLeft = self._distance == "left" or false
	if self._dialogueRight == nil then
		self._dialogueRight = QUIWidgetTutorialDialogue.new({avatarKey = self._avatarKey, isLeftSide = self._isLeft, text = self._word, sound = self._sound[1], name = name, heroId = heroInfo.id, isSay = true, sayFun = function()
			self._CP = {x = 0, y = 0}
			self._size = {width = display.width*2, height = display.height*2}
		end})
		app.tutorialNode:addChild(self._dialogueRight)
	else
		if self._sound and self._sound[1] then
			self._dialogueRight:updateSound(self._sound[1])
		end
		self._dialogueRight:updateActorImage(heroInfo.id)
		self._dialogueRight:addWord(self._word)
	end
	table.remove(self._tutorialInfo, 1)
	table.remove(self._sound, 1)
end

function QUIDialogBustdialogue:_onTouch(event)
	if event.name == "began" then
		return true
	elseif event.name == "ended" then
		if self._dialogueRight ~= nil and self._dialogueRight._isSaying == true and self._dialogueRight:isVisible() then
			self._dialogueRight:printAllWord(self._word)
		elseif #self._tutorialInfo > 0 then
			self:createDialogue()
		elseif self._CP ~= nil and event.x >=  self._CP.x - self._size.width/2 and event.x <= self._CP.x + self._size.width/2 and
			event.y >=  self._CP.y - self._size.height/2 and event.y <= self._CP.y + self._size.height/2  then
			self._step = self._step + 1
			self._perCP = self._CP
			self._CP = nil
			self:clearDialgue()
			self:playEffectOut()
		else
			self:playEffectOut()
		end
	end
end

function QUIDialogBustdialogue:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

function QUIDialogBustdialogue:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogBustdialogue
