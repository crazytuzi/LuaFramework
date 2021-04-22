-- @Author: liaoxianbo
-- @Date:   2020-08-03 16:28:39
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-20 16:36:26
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMazeExploreFirstPlot = class("QUIDialogMazeExploreFirstPlot", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIDialogMazeExploreFirstPlot:ctor(options)
	local ccbFile = "ccb/Dialog_MazeExplore_FirstPlot.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
    }
    QUIDialogMazeExploreFirstPlot.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setAllUIVisible(false)
    page:setScalingVisible(false)

    q.setButtonEnableShadow(self._ccbOwner.btn_go)

    self._dungenonInfo = options.dungenonInfo
    self._callBack = options.callBack
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.node_go:setVisible(false)
	self._ccbOwner.node_close_tips:setVisible(false)
end

function QUIDialogMazeExploreFirstPlot:viewDidAppear()
	QUIDialogMazeExploreFirstPlot.super.viewDidAppear(self)

	self:addBackEvent(false)
	local plotTextDefaut = "唐昊成为位面之主后陷入沉睡，但当年未能保护阿银的心结，让他的神识迷失在了自己无意中创造的“破碎位面”之中，能否唤醒唐昊，就取决于各位魂师大人了…"
	local plotText = self._dungenonInfo.intro_des or plotTextDefaut
	self._isEnd = false
	self:wordTypewriterEffect(self._ccbOwner.tf_text_content, plotText, function ()
		self._isEnd = true
		-- self._ccbOwner.node_go:setVisible(true)
		self._ccbOwner.node_close_tips:setVisible(true)
	end)
end

function QUIDialogMazeExploreFirstPlot:viewWillDisappear()
  	QUIDialogMazeExploreFirstPlot.super.viewWillDisappear(self)

	self:removeBackEvent()
    if self._typewriterTimeHandler ~= nil then
    	scheduler.unscheduleGlobal(self._typewriterTimeHandler)
    	self._typewriterTimeHandler = nil
    end

end

function QUIDialogMazeExploreFirstPlot:wordTypewriterEffect(tf, word, callback)
	if tf == nil or word == nil then
		if callback ~= nil then callback() end
		return false
	end
	if self._typewriterCallback ~= nil then
		if callback ~= nil then callback() end
		return false
	end
	self._typewriterTF = tf
	self._typewriterWord = word
	self._typewriterCallback = callback

	self._sayPosition = 1
	self._typewriterSayWord = ""
	self._typewriterTF:setString(self._typewriterSayWord)
	self._delayTime = TUTORIAL_ONEWORD_TIME * 0.5
	self._isExist = true

	if self._typewriterHandler == nil then
		self._typewriterHandler = function ()
			if self._isExist ~= true then return end
			local c = string.sub(self._typewriterWord,self._sayPosition,self._sayPosition)
	        local b = string.byte(c)
	        local str = c
	        if b > 128 then
	           str = string.sub(self._typewriterWord,self._sayPosition,self._sayPosition + 2)
	           self._sayPosition = self._sayPosition + 2
	        end
            self._typewriterSayWord =  self._typewriterSayWord .. str
			self._typewriterTF:setString(self._typewriterSayWord)
        	self._sayPosition = self._sayPosition + 1

        	if self._sayPosition <= #self._typewriterWord then
		        self._typewriterTimeHandler = scheduler.performWithDelayGlobal(self._typewriterHandler,self._delayTime)
		    else
		        if self._typewriterCallback ~= nil then
		        	local callBack = self._typewriterCallback
		            self._typewriterCallback = nil
		            callBack()
		        end
			    if self._typewriterTimeHandler ~= nil then
			    	scheduler.unscheduleGlobal(self._typewriterTimeHandler)
			    end
			    self._typewriterTimeHandler = nil
		    end
		end
	end
	self._typewriterHandler()
end

function QUIDialogMazeExploreFirstPlot:_onTriggerGo()
  	app.sound:playSound("common_small")
  	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER, nil)
	-- app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreMain"})
	if self._callBack then
		self._callBack()
	end
end

function QUIDialogMazeExploreFirstPlot:_backClickHandler()
    if not self._isEnd then return end
    self:_onTriggerGo()
end

function QUIDialogMazeExploreFirstPlot:onTriggerBackHandler()
   if not self._isEnd then return end
   QUIDialogMazeExploreFirstPlot.super.onTriggerBackHandler(self)
end

function QUIDialogMazeExploreFirstPlot:onTriggerHomeHandler()
	if not self._isEnd then return end
	QUIDialogMazeExploreFirstPlot.super.onTriggerHomeHandler(self)
end
return QUIDialogMazeExploreFirstPlot
