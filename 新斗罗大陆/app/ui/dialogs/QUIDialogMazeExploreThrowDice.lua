-- @Author: liaoxianbo
-- @Date:   2020-08-05 18:15:04
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-21 17:07:52
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMazeExploreThrowDice = class("QUIDialogMazeExploreThrowDice", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

function QUIDialogMazeExploreThrowDice:ctor(options)
	local ccbFile = "ccb/Dialog_MazeExplore_Event_Dice.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerChooseLeft", callback = handler(self, self._onTriggerChooseLeft)},
        {ccbCallbackName = "onTriggerChooseRight", callback = handler(self, self._onTriggerChooseRight)},        
    }
    QUIDialogMazeExploreThrowDice.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.btn_left)
    q.setButtonEnableShadow(self._ccbOwner.btn_right)

    self._callBack = options.callBack
    self._gridInfo = options.gridInfo
    self._power = options.power or 0

    self._facEffect = tolua.cast(self._ccbOwner.fca_effect, "QFcaSkeletonView_cpp")
    self._facEffect:stopAnimation()
    self._facEffect:setVisible(false)
    self._ccbOwner.tf_text_content:setVisible(false)
    self._dicePoints = db:getConfigurationValue("maze_dice_points") or 8
    self._numSumValue = 0
    
    self:refreshView(self._gridInfo.des)	
    self._loseTimes = 0
    self._maxWintimes = db:getConfigurationValue("max_win_times_2") or 6        
end

function QUIDialogMazeExploreThrowDice:viewDidAppear()
	QUIDialogMazeExploreThrowDice.super.viewDidAppear(self)

  --   self._showDiceScheduler = scheduler.performWithDelayGlobal(self:safeHandler(function ()

		-- self:_showDiceAnimation()
  --       end), 0.5)
end

function QUIDialogMazeExploreThrowDice:viewWillDisappear()
  	QUIDialogMazeExploreThrowDice.super.viewWillDisappear(self)

    if self._showDiceScheduler then
        scheduler.unscheduleGlobal(self._showDiceScheduler)
        self._showDiceScheduler = nil
    end

end

function QUIDialogMazeExploreThrowDice:refreshView( textContent, btnName )
    local des = {
        {oType = "font", content = textContent, size = 22,color = ccc3(255,215,172)},
    }
    if not self._richTextContent then 
        self._richTextContent = QRichText.new(nil,480)
        self._richTextContent:setAnchorPoint(ccp(0, 1))
        self._ccbOwner.node_text:addChild(self._richTextContent)
    end

    self._richTextContent:setString(des)
    if btnName then
        self._ccbOwner.tf_right:setString(btnName)
    end
    self._ccbOwner.node_parent:setVisible(true)
    self._facEffect:stopAnimation()
    self._facEffect:setVisible(false)
end

function QUIDialogMazeExploreThrowDice:_showDiceAnimation()
    self._numSumValue = 0
    self._ccbOwner.node_parent:setVisible(false)
    self._ccbOwner.node_showGoNumber_1:removeAllChildren()
    self._ccbOwner.node_showGoNumber_2:removeAllChildren()

    if self._showDiceScheduler then
        scheduler.unscheduleGlobal(self._showDiceScheduler)
        self._showDiceScheduler = nil
    end

    local diceFunc = function(node)
        local num = math.random(1,6)
        if self._loseTimes > self._maxWintimes then
           num = math.random(5,6)
        end        
    	self._numSumValue = self._numSumValue + num
     	local path = QResPath("shaizi")[num]
    	local img = CCSprite:create(path)  
    	node:addChild(img)  	
    end

    diceFunc(self._ccbOwner.node_showGoNumber_1)
    self._ccbOwner.node_showGoNumber_1:setVisible(false)
    diceFunc(self._ccbOwner.node_showGoNumber_2)
    self._ccbOwner.node_showGoNumber_2:setVisible(false)

    self._facEffect:setVisible(true)
    self._facEffect:resumeAnimation()
    self._facEffect:connectAnimationEventSignal(handler(self, self._fcaHandler))
    self._facEffect:playAnimation("animation", false)
end

function QUIDialogMazeExploreThrowDice:_fcaHandler(eventType)
	if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then	
	    self._ccbOwner.node_showGoNumber_1:setVisible(true)
	    self._ccbOwner.node_showGoNumber_2:setVisible(true)
	    self._facEffect:stopAnimation()
	    self._facEffect:setVisible(false)

	    if self._showDiceScheduler then
	        scheduler.unscheduleGlobal(self._showDiceScheduler)
	        self._showDiceScheduler = nil
	    end
	    self._showDiceScheduler = scheduler.performWithDelayGlobal(self:safeHandler(function ()
	            self._ccbOwner.node_showGoNumber_1:removeAllChildren()
	            self._ccbOwner.node_showGoNumber_2:removeAllChildren()

                if self._callBack then
                    self._callBack(self._numSumValue)
                end
                if self._numSumValue > self._dicePoints then
                    local str = string.format("你成功掷出了%d以上的点数，可以继续前进了",self._dicePoints)
                    app.tip:floatTip(str)
	                self:_onTriggerClose()
                else
                    self._loseTimes = self._loseTimes+1
                    self:refreshView(self._gridInfo.answer_des,"再掷一次")
                end
	        end),1.5)
	  end
end

function QUIDialogMazeExploreThrowDice:_onTriggerChooseRight()
    if self._gridInfo.energy and self._power < self._gridInfo.energy then
        app.tip:floatTip("精神力不足。")
        self:_onTriggerClose()
        return
    end
    self:_showDiceAnimation()
end

function QUIDialogMazeExploreThrowDice:_onTriggerChooseLeft()
    self:_onTriggerClose()
end

function QUIDialogMazeExploreThrowDice:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMazeExploreThrowDice:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	-- if callback then
	-- 	callback(self._numSumValue)
	-- end
end

return QUIDialogMazeExploreThrowDice
