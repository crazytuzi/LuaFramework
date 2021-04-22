-- @Author: liaoxianbo
-- @Date:   2019-11-24 15:19:03
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-20 18:44:13

local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01SoulSpiritOccult = class("QTutorialPhase01SoulSpiritOccult", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01SoulSpiritOccult:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()

	if app.tutorial:checkCurrentDialog() == false then 
   		self:_jumpToEnd()
        return 
   	end
   	self._stageType = 1
   	local UnlockTips = UNLOCK_TUTORIAL_TIPS_TYPE.unlockSoulSpiritOccult
   	local delay_time =  UNLOCK_DELAY_TIME + 0.5
	local stage = app.tutorial:getStage()
	-- heroShop^1;eliteBox^1;jewelry^2;metal^1;gloryTower^1;intencify^1;invasion^1;monthSignIn^1;soulSpiritOccult^0;soulSpirit^1;night^0;weeklyMission^1;mockBattle2^0;thunder^1;addHero^1;unlockHelp^2;archaeology^1;training^1;artifact^1;secretary^1;monopoly^1;fightClub^1;heroYwd^0;storm^1;mockBattle^1;strengthen^1;eliteStar^1;addHeroYwd^0;gemstone^1;convey^1;collegeTrain^3;ssgemstone^1;blackRock^1;dragonTotem^0;sotoTeam^1;totemChallenge^0;mount^1;silver^1;activity^1;call^2;guideEnd^0;maritime^1;addMoney^1;spar^1;sanctuary^1;skill^1;breakth^1;sunWar^1;refine^0;useSkin^0;magicHerb^1;glyph^1;forced^6;enchant^1;godarm^1;arena^1
	if stage.soulSpiritOccult == 0 then
		app:getClient():guidanceRequest(15002)
		stage.soulSpiritOccult = 1
		self._step = 0
	else
		stage.soulSpiritOccult = 2
		self._step = 5
		delay_time = 0.1
	end
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._perCP = ccp(display.width/2, display.height/2)
	if self._step == 0 then
	    if app.tip.UNLOCK_TIP_ISTRUE == false then
	        app.tip:showUnlockTips(UnlockTips)
	    else
	        app.tip:addUnlockTips(UnlockTips)
	    end
	end

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:stepManager()
    end, delay_time)
end
--步骤管理
function QTutorialPhase01SoulSpiritOccult:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:_guideClickScaling()
	elseif self._step == 2 then
		self:_backMainPage()
	elseif self._step == 3 then
		self:_openSoulSpirit()
	elseif self._step == 4 then
		self:openSoulSpiritDialog()
	elseif self._step == 5 then
		self:SayWordsUpgrade()
	elseif self._step == 6 then
		self:_guideClickSoulSpiritOccultUpgradeBtn()	
	elseif self._step == 7 then
		self:upgradeCurSoulSpiritOccult()
	elseif self._step == 8 then
		self:_guideClickSoulSpiritOccultFireNo5Btn()
	elseif self._step == 9 then
		self:showAttrPlace5()
	elseif self._step == 10 then
		self:_guideClickSoulSpiritOccultFireNo6Btn()
	elseif self._step == 11 then
		self:showAttrPlace6()
		-- self:_guideClickSoulSpiritOccultFireNo15Btn()
	elseif self._step == 12 then
		self:endTutorial()	
	-- elseif self._step == 12 then
	-- 	self:showAttrPlace15()	
	-- elseif self._step == 13 then
	-- 	self:endTutorial()
	end
end

function QTutorialPhase01SoulSpiritOccult:_guideStart()
	self:clearSchedule()
  	self:clearDialgue()
	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()

	if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" or
			(self.firstDialog ~= nil and self.firstPage._scaling:isVisible()) then
		self._step = 2
		self:_guideClicSoulSpiritScaling()
	else
		self._step = 1
		self:_guideClickScaling()
	end
end

function QTutorialPhase01SoulSpiritOccult:_backMainPage()
	self:clearHandeTouch()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClicSoulSpiritScaling()
	end,0.5)
end


--引导玩家点击扩展标签
function QTutorialPhase01SoulSpiritOccult:_guideClicSoulSpiritScaling()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page._scaling._DisplaySideMenu then
		self._step = self._step + 1
		self:_guideClickSoulSpiritFrame()
		return 
	end
	self._CP = page._scaling._ccbOwner.button_scaling:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._scaling._ccbOwner.button_scaling:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击进入菜单", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 15001, attack = true})
	self._CP.y = self._CP.y - 10
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--引导玩家点击扩展标签
function QTutorialPhase01SoulSpiritOccult:_guideClickScaling()
	--  self:clearSchedule()
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_home:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击返回主界面", direction = "right"})
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--打开显示扩展标签
function QTutorialPhase01SoulSpiritOccult:_openSoulSpirit()

	self:clearHandeTouch()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:_onTriggerOffSideMenu()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickSoulSpiritFrame()
	end,0.5)
end

--引导点击魂灵按钮
function QTutorialPhase01SoulSpiritOccult:_guideClickSoulSpiritFrame()
 	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._scaling._ccbOwner.btn_soulSpirit:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._scaling._ccbOwner.btn_soulSpirit:getContentSize()
	self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击魂灵", direction = "left"})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--打开魂灵界面
function QTutorialPhase01SoulSpiritOccult:openSoulSpiritDialog()

	self:clearHandeTouch()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:_onButtondownSideMenuSoulSpirit()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:endTutorial()
	end,0.5)
end

--引导点击魂灵密术按钮
function QTutorialPhase01SoulSpiritOccult:_guideClickSoulSpiritOccultBtn()
 	self:clearSchedule()
 	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._ccbOwner.btn_soul_guide:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._ccbOwner.btn_soul_guide:getContentSize()
	self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击魂灵秘术", direction = "left"})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--打开魂灵密术界面
function QTutorialPhase01SoulSpiritOccult:openSoulSpiritOccultDialog()
	self:clearHandeTouch()

 	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._dialog:_onTriggerSoulSpiritGuide()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:SayWordsUpgrade()
	end,0.5)

end

--说话引导升级
function QTutorialPhase01SoulSpiritOccult:SayWordsUpgrade()
	self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("15002")
    self._distance = "left"
    self:createDialogue()
end

--引导点击魂灵密术按钮
function QTutorialPhase01SoulSpiritOccult:_guideClickSoulSpiritOccultUpgradeBtn()
    self:clearDialgue()
 	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
 	self._dialog:eventBigPoint({bigPoint = 4, name ="EVENT_POINT_CLICK"})
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
	 	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
		self._CP = self._dialog._ccbOwner.node_btn:convertToWorldSpaceAR(ccp(0,0))
		self._size = self._dialog._ccbOwner.btn_upgrade:getContentSize()
		self._perCP = ccp(display.width/2, display.height/2)
		self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	end,0.1)
end

function QTutorialPhase01SoulSpiritOccult:upgradeCurSoulSpiritOccult()

	self:clearHandeTouch()
 	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._dialog:_onTriggerUpgrade() 
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
		self:SayWordsClickNo5()
	end,2.5)

end

--说话引导点击5号点
function QTutorialPhase01SoulSpiritOccult:SayWordsClickNo5()
	self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("15003")
    self._distance = "left"
    self:createDialogue()
end

--引导点击5号点
function QTutorialPhase01SoulSpiritOccult:_guideClickSoulSpiritOccultFireNo5Btn()
    self:clearDialgue()
 	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local target_btn = self._dialog._pointWidgetList[5]._ccbOwner.btn_click
	self._CP = target_btn:convertToWorldSpaceAR(ccp(0,0))
	self._size = target_btn:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
	self._step = 8

end


--引导点击6号点
function QTutorialPhase01SoulSpiritOccult:_guideClickSoulSpiritOccultFireNo6Btn()
	self:clearHandeTouch()
	self:clearDialgue()
	self:clearSchedule()
 	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local target_btn = self._dialog._pointWidgetList[6]._ccbOwner.btn_click
	self._CP = target_btn:convertToWorldSpaceAR(ccp(0,0))
	self._size = target_btn:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
	self._step = 10
end


--说话引导点击15号点
function QTutorialPhase01SoulSpiritOccult:SayWordsClickNo15()
	self:clearHandeTouch()
	self:clearDialgue()
	self:clearSchedule()
	self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("15004")
    self._distance = "left"
    self:createDialogue()
end


--引导点击15号点
function QTutorialPhase01SoulSpiritOccult:_guideClickSoulSpiritOccultFireNo15Btn()
	self:clearHandeTouch()
	self:clearDialgue()
	self:clearSchedule()
 	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local target_btn = self._dialog._pointWidgetList[15]._ccbOwner.btn_click
	self._CP = target_btn:convertToWorldSpaceAR(ccp(0,0))
	self._size = target_btn:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)


end

function QTutorialPhase01SoulSpiritOccult:showAttrPlace5()
	self:clearHandeTouch()
 	self:clearSchedule()
 	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
 	self._dialog:eventBigPoint({bigPoint = 5, name ="EVENT_POINT_CLICK"})
	local target_btn = self._dialog._ccbOwner.node_guide_size
	self._CP = target_btn:convertToWorldSpaceAR(ccp(0,0))
	self._size = target_btn:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
	self._handTouch:showFocusAndDisappear( self._size.width , self._size.height,self._CP )
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickSoulSpiritOccultFireNo6Btn()
	end,3)
	
end

function QTutorialPhase01SoulSpiritOccult:showAttrPlace6()
	self:clearHandeTouch()
 	self:clearSchedule()
 	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
 	self._dialog:eventBigPoint({bigPoint = 6, name ="EVENT_POINT_CLICK"})
	local target_btn = self._dialog._ccbOwner.node_guide_size
	self._CP = target_btn:convertToWorldSpaceAR(ccp(0,0))
	self._size = target_btn:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
	self._handTouch:showFocusAndDisappear( self._size.width , self._size.height,self._CP )
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		-- self:SayWordsClickNo15()
		self:endTutorial()
	end,3)
end

function QTutorialPhase01SoulSpiritOccult:showAttrPlace15()

	self:clearHandeTouch()
    self:clearDialgue()

 	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
 	self._dialog:eventBigPoint({bigPoint = 15, name ="EVENT_POINT_CLICK"})

	local target_btn = self._dialog._ccbOwner.node_guide_size
	self._CP = target_btn:convertToWorldSpaceAR(ccp(0,0))
	self._size = target_btn:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
	self._handTouch:showFocusAndDisappear( self._size.width , self._size.height,self._CP )
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:endTutorial()
	end,3)
end



function QTutorialPhase01SoulSpiritOccult:endTutorial()
	--self._handTouch:removeFromParent()
	self:clearHandeTouch()
	self:clearSchedule()
    self:clearDialgue()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01SoulSpiritOccult:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01SoulSpiritOccult:_nodeRunAction(posX,posY)
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

function QTutorialPhase01SoulSpiritOccult:createDialogue()
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

function QTutorialPhase01SoulSpiritOccult:_onTouch(event)
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
				self._handTouch:showFocus( self._CP )
			end
		end
	end
end

function QTutorialPhase01SoulSpiritOccult:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01SoulSpiritOccult:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end


function QTutorialPhase01SoulSpiritOccult:clearHandeTouch()
	if self._handTouch ~= nil then
		self._handTouch:removeFromParent()
		self._handTouch = nil
	end
end

return QTutorialPhase01SoulSpiritOccult