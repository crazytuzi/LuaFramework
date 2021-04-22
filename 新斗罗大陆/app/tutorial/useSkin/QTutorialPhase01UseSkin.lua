--
-- zxs
-- 使用皮肤
--
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01UseSkin = class("QTutorialPhase01UseSkin", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QTutorialPhase01UseSkin.ACHIEVE_SUCCESS = 1

function QTutorialPhase01UseSkin:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}
    self._callHeroId = nil

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()

   	if app.tutorial:checkCurrentDialog() == false then 
   		self:_jumpToEnd()
        return 
   	end

    app:getClient():guidanceRequest(6201)

	-- 设置不弹出
	remote.flag:set(remote.flag.ANIMATION_LINKAGE, 2)
	
    local stage = app.tutorial:getStage()
	stage.useSkin = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:stepManager()
	end, UNLOCK_DELAY_TIME)
end

--步骤管理
function QTutorialPhase01UseSkin:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:chooseNextStage()
	elseif self._step == 2 then
		self:_backMainPage()
	elseif self._step == 3 then
		self:_openScaling()
	elseif self._step == 4 then
		self:_openBag()
	elseif self._step == 5 then
		self:_showBagDialog()
	elseif self._step == 6 then
		self:_openItemSkin()
	elseif self._step == 7 then
		self:endTutorial()
	end
end

--引导开始
function QTutorialPhase01UseSkin:_guideStart()
	self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("6201")
	self._distance = "left"
	self:createDialogue()
end

function QTutorialPhase01UseSkin:chooseNextStage()
    self:clearDialgue()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page._scaling then
		self._step = 2
		self:_guideClickScaling()
	else
		self:_guideClickMainPage()
	end
end 

--引导玩家点击扩展标签
function QTutorialPhase01UseSkin:_guideClickMainPage()
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_home:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01UseSkin:_backMainPage()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickScaling()
	end,0.5)
end

--引导玩家点击扩展标签
function QTutorialPhase01UseSkin:_guideClickScaling()
    self:clearDialgue()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page._scaling._DisplaySideMenu then
		self._step = self._step + 1
		self:_guideClickBag()
		return 
	end

    self._CP = page._scaling._ccbOwner.button_scaling:convertToWorldSpaceAR(ccp(0,0))
    self._size = page._scaling._ccbOwner.button_scaling:getContentSize()
    self._perCP = ccp(display.width/2, display.height/2)
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._CP.y = self._CP.y - 10
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01UseSkin:_openScaling()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page._scaling:_onTriggerOffSideMenu()

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickBag()
    end,0.5)
end

--引导玩家点击道具
function QTutorialPhase01UseSkin:_guideClickBag()
    self:clearSchedule()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._CP = page._scaling._ccbOwner.btn_bag:convertToWorldSpaceAR(ccp(0,0))
    self._size = page._scaling._ccbOwner.btn_bag:getContentSize()
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01UseSkin:_openBag()
	self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._dialog = page._scaling:_onButtondownSideMenuBag()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
    	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    	if dialog.class.__cname == "QUIDialogBackpack" then
   			self:_openBagItem()
   			self._step = 5
   		else
   			self:_showOpenBag()
   			self._step = 4
   		end
    end,0.5)
end

function QTutorialPhase01UseSkin:_showOpenBag()
    self:clearSchedule()
    local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog._listView then
		local itemFrame= dialog._listView:getItemByIndex(1)
		if itemFrame then
			self._CP = itemFrame._ccbOwner.btn_click:convertToWorldSpaceAR(ccp(0,0))
			self._size = itemFrame._ccbOwner.btn_click:getContentSize()
			self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
			self._handTouch:setPosition(self._CP.x, self._CP.y)
			app.tutorialNode:addChild(self._handTouch)
		else
			self:_jumpToEnd()
			return
		end	
	else
		self:_jumpToEnd()
		return
	end	    
    -- self._CP = dialog._backPackBar[1]:convertToWorldSpaceAR(ccp(0,0))
    -- self._size = dialog._backPackBar[1]:getContentSize()
    -- self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    -- self._handTouch:setPosition(self._CP.x, self._CP.y)
    -- app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01UseSkin:_showBagDialog()
    self._handTouch:removeFromParent()
    -- local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog() 
    -- dialog:_onClickEvnet({index = 1})
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBackpack"})    
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_openBagItem()
    end,0.5)
end

function QTutorialPhase01UseSkin:_openBagItem()
    self:clearSchedule()
	local itemId = 16100007
	if remote.items:getItemsNumByID(itemId) == 0 then
		self:_jumpToEnd()
        return
	end
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._dialog:itemSelected(itemId)
	self._dialog:rollToSelectItem(itemId)
	self._dialog._infoPanel:setItemId(itemId)

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickOpen()
    end,0.5)
end

function QTutorialPhase01UseSkin:_guideClickOpen()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
 	self._CP = self._dialog._infoPanel._ccbOwner.btn_sell:convertToWorldSpaceAR(ccp(0,0))
    self._size = self._dialog._infoPanel._ccbOwner.btn_sell:getContentSize()
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01UseSkin:_openItemSkin()
    self._handTouch:removeFromParent()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._dialog._infoPanel:_onTriggerSell()

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:useSkinEnd()
    end,1.5)
end

function QTutorialPhase01UseSkin:useSkinEnd()
    self:clearSchedule()
	self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("6202")
	self._distance = "left"
	self:createDialogue()
end

function QTutorialPhase01UseSkin:endTutorial()
	self:clearDialgue()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01UseSkin:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01UseSkin:_nodeRunAction(posX,posY)
	self._isMove = true
	local actionArrayIn = CCArray:create()
	actionArrayIn:addObject(CCMoveBy:create(0.1, ccp(posX,posY)))
	actionArrayIn:addObject(CCCallFunc:create(function ()
		self._isMove = false
		self._actionHandler = nil
	end))
	local ccsequence = CCSequence:create(actionArrayIn)
	self._actionHandler = self._handTouch:runAction(ccsequence)
end

function QTutorialPhase01UseSkin:createDialogue()
	if self._dialogueRight ~= nil and self._distance ~= self._tutorialInfo[1][3] then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
    local heroInfo = QStaticDatabase:sharedDatabase():getCharacterByID(self._tutorialInfo[1][1])
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
		self._dialogueRight:setActorImage(self._tutorialInfo[1][2])
		app.tutorialNode:addChild(self._dialogueRight)
	else
		if self._sound and self._sound[1] then
			self._dialogueRight:updateSound(self._sound[1])
		end
		self._dialogueRight:addWord(self._word)
	end
	table.remove(self._tutorialInfo, 1)
	table.remove(self._sound, 1)
end

function QTutorialPhase01UseSkin:_onTouch(event)
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
			self:stepManager()
		else
			if self._handTouch and self._handTouch.showFocus then
				if self._CP then
					print(self._CP.x, self._CP.y)
				end
				self._handTouch:showFocus( self._CP )
			end
		end
	end
end

function QTutorialPhase01UseSkin:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01UseSkin:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01UseSkin
