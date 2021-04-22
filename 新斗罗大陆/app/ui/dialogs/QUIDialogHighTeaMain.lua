local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHighTeaMain = class("QUIDialogHighTeaMain", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QColorLabel = import("...utils.QColorLabel")
local QListView = import("...views.QListView")
local QRichText = import("...utils.QRichText")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNotificationCenter = import("...controllers.QNotificationCenter")

local ACTIONS = {"eat01","eat02","happy","unhappy"}


QUIDialogHighTeaMain.CHAT_TYPE = {
	STAND= 1,
	CLICK= 2,
	EAT= 3,
	CHANGE= 4,
}



function QUIDialogHighTeaMain:ctor(options)
    local ccbFile = "ccb/Dialog_HighTea_Main.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerTouch", callback = handler(self, self._onTriggerTouch)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
        {ccbCallbackName = "onTriggerFood", callback = handler(self, self._onTriggerFood)},
        {ccbCallbackName = "onTriggerRoleClick", callback = handler(self, self._onTriggerRoleClick)},
        {ccbCallbackName = "onTriggerShop", callback = handler(self, self._onTriggerShop)},
        {ccbCallbackName = "onTriggerGetaward", callback = handler(self, self._onTriggerGetaward)},
    }

    QUIDialogHighTeaMain.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setManyUIVisible then page:setManyUIVisible() end
	if page.setScalingVisible then page:setScalingVisible(false) end
	if page.topBar then page.topBar:showWithMainPage() end

	q.setButtonEnableShadow(self._ccbOwner.btn_rule)
	q.setButtonEnableShadow(self._ccbOwner.btn_store)
	q.setButtonEnableShadow(self._ccbOwner.btn_food)
	q.setButtonEnableShadow(self._ccbOwner.btn_shop)
	q.setButtonEnableShadow(self._ccbOwner.btn_foodget)

	self._phaseCount = 0

	self._showPrizesVec = {}
	self._showPrizesIndex = 0

	self._highTeaDataHandle = remote.activityRounds:getHighTea()
	self._highTeaDataHandle:setActivityClickedToday()
	self._showExpVec = {}
	self._showExpIndex = 0
	self._isLikeFood = false
	self._isAtyEnd = false


	self._showLvPrizes = nil


	self._sayWords = ""
	self._moodAction = ""
    self:handleData() 
    self:_initSpineAction()
    self:setInfo() 
    self:_initListView() 
    self._isLockAction = false
	self._endPos = self._ccbOwner.node_bottom:convertToNodeSpace( self._ccbOwner.node_spine:convertToWorldSpace(ccp(0,0)))
	self._endPos.y = self._endPos.y + 20
	self._expLength = self._ccbOwner.sp_bar_bg:getContentSize().width

	self._ccbOwner.node_desc:setVisible(false)

	self._awardPos = self._ccbOwner.node_prize_pos:convertToWorldSpace(ccp(0,0))
end

function QUIDialogHighTeaMain:viewDidAppear()
	QUIDialogHighTeaMain.super.viewDidAppear(self)

	QNotificationCenter.sharedNotificationCenter():addEventListener(self._highTeaDataHandle.GET_FREE_AWARD , self.checkFreeAwardBtn, self)

	self:addBackEvent(false)
	self:getLoginPrize()
    self:_initListView() 
end
function QUIDialogHighTeaMain:viewWillDisappear()
    QUIDialogHighTeaMain.super.viewWillDisappear(self)
	self:removeBackEvent()
	self:closeRoleActionSchedule()
	 QNotificationCenter.sharedNotificationCenter():removeEventListener(self._highTeaDataHandle.GET_FREE_AWARD, self.checkFreeAwardBtn, self)
    if self._timerScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._timerScheduler)
    	self._timerScheduler = nil
    end

end


function QUIDialogHighTeaMain:checkTutorial()
    if app.tutorial then
         if app.tutorial:getStage().highTea == app.tutorial.Guide_Second_Start then
			app.tutorial:startTutorial(app.tutorial.Statge_HighTea)
		else
			self:getLoginPrize()
		end
    end
end


function QUIDialogHighTeaMain:handleData()
	self._data = {}	-- itemid - index
	self._items = {}

	local foodConfigs = remote.activity:getHighTeaFoodConfig()
	local index = 1

	for k,v in pairs(foodConfigs or {}) do
		local itemId = v.item_id
		local id = v.id
		local kind = v.kind
		local itemType = ITEM_TYPE.ITEM
		if tonumber(itemId) == nil then
		    itemType = remote.items:getItemType(itemId)
		end
		table.insert(self._items , {id = id , itemId = itemId ,typeName = itemType , count = 0, kind = kind})
	end

	self:refreshData()

end

--做单资源使用时刷新的优化考虑
function QUIDialogHighTeaMain:refreshData(itemId)
	if itemId == nil then
		for i,v in pairs(self._items or {}) do
			local num = remote.items:getItemsNumByID(v.itemId) or 0
			v.count = num
		end
	else
		for i,v in pairs(self._items or {}) do
			if v.itemId == itemId then
				local num = remote.items:getItemsNumByID(itemId) or 0
				v.count = num
			end
		end
	end

	table.sort(self._items, function (target1, target2)
		local  have1 = target1.count > 0 and 1 or 0
		local  have2 = target2.count > 0 and 1 or 0
		if have2 ~= have1 then
			return have1 > have2
		else
			return target1.id > target2.id
		end

	end)	

end

function QUIDialogHighTeaMain:getProgressScaleXAndNextExp(exp ,level)
	local nextLvConfig = remote.activity:getHighTeaRewardConfigByLevel(level + 1)
	if nextLvConfig == nil then
		return 1 , 1
	end
	local curMaxLevelValue = nextLvConfig.exp 
	curMaxLevelValue = curMaxLevelValue > 0 and curMaxLevelValue or 1
	local scaleX = exp / curMaxLevelValue
	scaleX = scaleX <= 1 and scaleX or 1

	return scaleX , curMaxLevelValue
end


function QUIDialogHighTeaMain:setInfo()
	self._exp = self._highTeaDataHandle:getHighTeaCurExp()
	self._totalExp = self._highTeaDataHandle:getHighTeaTotalExp()
	self._mood = self._highTeaDataHandle:getHighTeaMood()
	self._curLevel = self._highTeaDataHandle:getHighTeaLevel()

	local scaleX , curMaxLevelValue = self:getProgressScaleXAndNextExp(self._exp , self._curLevel)
	self._ccbOwner.sp_bar_bg:setScaleX(scaleX)
	if curMaxLevelValue == 1 then
		self._ccbOwner.tf_max_progress:setString("好感度已满")
	else
		self._ccbOwner.tf_max_progress:setString(self._exp.."/"..curMaxLevelValue)
	end

	self._ccbOwner.tf_level:setString(self._curLevel)

	

	self:showRedTips()
	self:handlerTimer()
	self:showCookRedTips()
	self:checkFreeAwardBtn()
end


function QUIDialogHighTeaMain:handlerTimer()
	if self._fun == nil then
	    self._fun = function ()
	    	local endTime = self._highTeaDataHandle:getHighTeaLastTime()
			if endTime > 0 then
	    		self._ccbOwner.tf_season_timer:setString(q.converFun(endTime))
	    	else
	    		if self._timerScheduler then
	    			scheduler.unscheduleGlobal(self._timerScheduler)
	    			self._timerScheduler = nil
	    		end
	    		self._ccbOwner.tf_season_timer:setString("活动结束")
	    		--赛季结束 推出大师模拟战
	    		app.tip:floatTip("活动已经结束")
	    		
				local arr = CCArray:create()
				arr:addObject(CCDelayTime:create(0.1))
				arr:addObject(CCCallFunc:create(function()
	    			self._isAtyEnd = true
				end))
				self._ccbOwner.tf_season_timer:stopAllActions()
	        	self._ccbOwner.tf_season_timer:runAction(CCSequence:create(arr))
	    	end
	    	-- local posX = self._ccbOwner.tf_season_timer:getPositionX() - self._ccbOwner.tf_season_timer:getContentSize().width - 5
	    	-- self._ccbOwner.tf_season_time_desc:setPositionX(posX)	
	    	-- posX = posX -  self._ccbOwner.tf_season_time_desc:getContentSize().width - 20
	    	-- self._ccbOwner.sp_season_time:setPositionX(posX)	
	    end
	end
	
	if self._timerScheduler == nil then
    	self._timerScheduler = scheduler.scheduleGlobal(self._fun, 1)
	end
    self._fun()
end



function QUIDialogHighTeaMain:_initSpineAction()
	if self._avatar == nil then
		self._avatar = QUIWidgetFcaAnimation.new("ningrongrong_xiawucha", "actor")
	    self._avatar:setScaleX(1.9)
	    self._avatar:setScaleY(1.9)
	    self._ccbOwner.node_spine:addChild(self._avatar)
	    self:openRoleActionSchedule()	
	end
end

function QUIDialogHighTeaMain:onTouchListView( event )
	if not event then
		return
	end

	if self._listView then
		self._listView:onTouch(event)
	end
end

function QUIDialogHighTeaMain:_initListView()

	if self._listView then
		self._listView:setContentSize(self._ccbOwner.sheet_layout:getContentSize())
		self._listView:resetTouchRect()
	end

	if self._listView == nil then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemCallBack),
			isVertical = false,
	        enableShadow = false,
	        spaceX = 10,
	        totalNumber = #self._items
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:refreshData() 
		-- self._listView:reload({totalNumber = #self._items})
	end
end

function QUIDialogHighTeaMain:_renderItemCallBack(list, index, info)
	local function showItemInfo(x, y, itemBox, listView)
		if self:safeCheck() then
			self:_onClickItemHandler(x, y, itemBox, listView)
		end
	end

    local isCacheNode = true
  	local data = self._items[index]
    local item = list:getItemFromCache()
    if not item then	       	
    	item = QUIWidgetQlistviewItem.new()
        isCacheNode = false
    end

    if not item._itemBox then
		item._itemBox = QUIWidgetItemsBox.new()
		item._itemBox:setScale(1.0)
		item._itemBox:setPosition(ccp(44,22))
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(88,80))

		item._sprite = CCSprite:create(QResPath("sp_love"))
		item._sprite:setScale(0.8)
		item._sprite:setPosition(ccp(15,58))
		item._ccbOwner.parentNode:addChild(item._sprite)

	end
	item._sprite:setVisible(data.kind == self._mood)
	item._itemBox:setGoodsInfo(data.itemId, data.typeName, data.count)
	if data.count > 0 then
		makeNodeFromGrayToNormal(item._itemBox)
		makeNodeFromGrayToNormal(item._sprite)
	else
		makeNodeFromNormalToGray(item._itemBox)
		makeNodeFromNormalToGray(item._sprite)
	end
	
    info.item = item
    info.size = item._ccbOwner.parentNode:getContentSize()
    list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)

    return isCacheNode
end

function QUIDialogHighTeaMain:_onClickItemHandler(x, y, itemBox, listView)

	if self._isLockAction then 
		self:_playChangeMoodAction()
		return 
	end
	if self._isAtyEnd then
		app.tip:floatTip("活动已经结束，无法继续互动")
		return
	end

	local num = remote.items:getItemsNumByID(itemBox._itemID) or 0
	if num <= 0 then
		app.tip:floatTip("菜品数量不足，无法互动")
		return
	end

	self._startpos = self._ccbOwner.node_bottom:convertToNodeSpace(ccp(x,y))
	self._itemId = itemBox._itemID
	-- app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
	self._highTeaDataHandle:weeklyGameHighTeaEatRequest(self._itemId, 1, function (data)
 		if self:safeCheck() then
			self:updateData()

		end
	end,function (data)
 		if self:safeCheck() then
		end
	end)

end

function QUIDialogHighTeaMain:updateData()
	--更新奖励展示数据
	local prizes = self._highTeaDataHandle:getHighTeaEatPrizes()
	if not  q.isEmpty(prizes) then
		self._highTeaDataHandle:setHighTeaEatPrizes()
		for k,v in pairs(prizes) do
			table.insert(self._showPrizesVec,v)
		end
	end

	prizes = self._highTeaDataHandle:getHighTeaLevelPrizes()
	if not q.isEmpty(prizes) then
		self._highTeaDataHandle:setHighTeaLevelPrizes()
		-- for k,v in pairs(prizes) do
		-- 	table.insert(self._showPrizesVec,v)
		-- end
		self._showLvPrizes = prizes
	end
	local oldMood = self._mood
	self._mood = self._highTeaDataHandle:getHighTeaMood()
	if self._mood ~= oldMood then
		self._isLockAction = true
	end
	--更新食物展示
	self:refreshData(self._itemId)
	self:_initListView()


	--更新满意度、等级等数值
	local oldExp = self._totalExp
	local oldLv = self._curLevel
	local oldScaleX = self._ccbOwner.sp_bar_bg:getScaleX()

	self._totalExp = self._highTeaDataHandle:getHighTeaTotalExp()
	self._exp = self._highTeaDataHandle:getHighTeaCurExp()
	self._curLevel = self._highTeaDataHandle:getHighTeaLevel()

	local divExp = self._totalExp  - oldExp
	local divLv = self._curLevel  - oldLv

	local config = remote.activity:getHighTeaFoodConfigByItemId(self._itemId)
	self._isLikeFood = oldMood == config.kind
	if divExp > 0 then
		table.insert(self._showExpVec,{curLevel = self._curLevel , exp = self._exp , divLv = divLv , divExp = divExp ,isLike = self._isLikeFood })
	end
	local expression = self._isLikeFood and "happy" or "unhappy"

	self._sayWords , self._moodAction = self:getChatWordsByType(QUIDialogHighTeaMain.CHAT_TYPE.EAT,nil,oldLv ,expression )
	self:playRoleShowAction()
	self:playShowPrizesAction()
	self:playShowExpChangeAction()
	self:showRedTips()

end


function QUIDialogHighTeaMain:showRedTips()

	if self._highTeaDataHandle:checkRewardCanGet()  then
	    self._ccbOwner.node_gold_close:stopAllActions()
	    self._ccbOwner.node_gold_close:setRotation(0)
	    self._ccbOwner.node_box:stopAllActions()
	    self._ccbOwner.node_box:setRotation(0)
		local dur = 0.15
		local arrBox = CCArray:create()
	    arrBox:addObject(CCDelayTime:create(dur * 2))
	    arrBox:addObject(CCRotateTo:create(dur, 10.4))
	    arrBox:addObject(CCDelayTime:create(dur * 2))
	    arrBox:addObject(CCRotateTo:create(dur, 0))
	    local actionArrayIn = CCArray:create()
	    actionArrayIn:addObject(CCSequence:create(arrBox))
	    actionArrayIn:addObject(CCDelayTime:create(1))
	    local ccsequence = CCRepeatForever:create(CCSequence:create(actionArrayIn))
	    self._ccbOwner.node_gold_close:runAction(ccsequence)

		local arrBoxNode = CCArray:create()
	    arrBoxNode:addObject(CCDelayTime:create(dur * 3))
	    arrBoxNode:addObject(CCRotateTo:create(dur, -26))
	    arrBoxNode:addObject(CCRotateTo:create(dur, 0))
	    arrBoxNode:addObject(CCDelayTime:create(dur))
	    local actionArrayIn2 = CCArray:create()
	    actionArrayIn2:addObject(CCSequence:create(arrBoxNode))
	    actionArrayIn2:addObject(CCDelayTime:create(1))
	    local ccsequence2 = CCRepeatForever:create(CCSequence:create(actionArrayIn2))
	    self._ccbOwner.node_box:runAction(ccsequence2)
	else
	    self._ccbOwner.node_gold_close:stopAllActions()
	    self._ccbOwner.node_gold_close:setRotation(0)
	    self._ccbOwner.node_box:stopAllActions()
	    self._ccbOwner.node_box:setRotation(0)

	end

end

function QUIDialogHighTeaMain:showCookRedTips()
    self._ccbOwner.sp_cook_tips:setVisible(self._highTeaDataHandle:checkCanCookFoodRedTips())
end

function QUIDialogHighTeaMain:checkFreeAwardBtn( )
	self._ccbOwner.node_foodget:setVisible(not self._highTeaDataHandle:getHighTeaFreeAward())
end

function QUIDialogHighTeaMain:playRoleShowAction()
	print("playRoleShowAction()")
	self:playFlyFood()
end

function QUIDialogHighTeaMain:playShowPrizesAction()
	-- print("playShowPrizesAction()	"..self._showPrizesIndex)
	-- QPrintTable(self._showPrizesVec)	
	if( self._showPrizesIndex == 0 and #self._showPrizesVec > 0) or self._showLvPrizes ~= nil then
		self:_showSinglePrizes()
	end
end

function QUIDialogHighTeaMain:playShowExpChangeAction()
	print("playShowExpChangeAction()	"..self._showExpIndex)
	if self._showExpIndex == 0 and #self._showExpVec > 0 then
		self:_playExpAddAction()
	end
end


function QUIDialogHighTeaMain:_showSinglePrizes()

	if self._showLvPrizes ~= nil then
		app.tip:awardsTip(self._showLvPrizes, "恭喜您获得好感度升级奖励" ,handler(self, self._showSinglePrizes) , true)
		self._showLvPrizes = nil
		return
	end

	-- print("_showSinglePrizes()	"..self._showPrizesIndex)
	self._showPrizesIndex = self._showPrizesIndex + 1
	if self._showPrizesIndex > #self._showPrizesVec then
		-- print("_showSinglePrizes()	"..self._showPrizesIndex)
		self._showPrizesIndex = 0
		self._showPrizesVec = {}
		return
	end

	local prize = self._showPrizesVec[self._showPrizesIndex]
	-- QPrintTable(self._awardPos)	
	app.tip:flyAwardTips(prize , -300, 50, 1.1 , handler(self, self._showSinglePrizes))	


end

--食物飞入动画
function QUIDialogHighTeaMain:playFlyFood()
	local itemId = self._itemId
	local startpos = self._startpos
	local flyItemBox = QUIWidgetItemsBox.new()
	local itemType = ITEM_TYPE.ITEM
	if tonumber(itemId) == nil then
	    itemType = remote.items:getItemType(itemId)
	end
	flyItemBox:setGoodsInfo(itemId, itemType, 1)
	self._ccbOwner.node_bottom:addChild(flyItemBox)
	flyItemBox:setPosition(startpos)
	local dur = 0.5
	local array2 = CCArray:create()
    array2:addObject(CCMoveTo:create(dur , self._endPos))
    array2:addObject(CCScaleTo:create(dur, 0.4))
    local arr = CCArray:create()
    arr:addObject(CCSpawn:create(array2))
    arr:addObject(CCCallFunc:create(function()
 		if self:safeCheck() then
			self:_playSpineEatAction()
		end		
		flyItemBox:removeFromParent()
    end))
	flyItemBox:runAction(CCSequence:create(arr))
end

--经验增长
function QUIDialogHighTeaMain:_playExpAddAction()
	--经验与等级相关动画
	--table.insert(self._showExpVec,{curLevel = self._curLevel , exp = self._exp , divLv = divLv })
	self._showExpIndex = self._showExpIndex + 1
	if self._showExpIndex > #self._showExpVec then
		self._showExpIndex = 0
		self._showExpVec = {}
		return
	end
	local expMod = self._showExpVec[self._showExpIndex]
	local curLevel = expMod.curLevel
	local exp = expMod.exp
	local divLv = expMod.divLv
	local divExp = expMod.divExp
	local isLike = expMod.isLike


	local scaleX , curMaxLevelValue = self:getProgressScaleXAndNextExp(exp , curLevel)


	local durBar = 0.2
	local arrayBar = CCArray:create()
	if divLv > 0 then
		for i=1,divLv do
			arrayBar:addObject(CCScaleTo:create(durBar, 1))
			arrayBar:addObject(CCCallFunc:create(function()
	 			if self:safeCheck() then
					self._ccbOwner.sp_bar_bg:setScaleX(0)
					self._ccbOwner.tf_level:setString(curLevel - divLv + i)
				end		
    		end))
		end
	end
	arrayBar:addObject(CCScaleTo:create(durBar, scaleX , 1))
	arrayBar:addObject(CCCallFunc:create(function()
		if self:safeCheck() then
			self._ccbOwner.tf_level:setString(curLevel)
			if curMaxLevelValue == 1 then
				self._ccbOwner.tf_max_progress:setString("好感度已满")
			else
					self._ccbOwner.tf_max_progress:setString(exp.."/"..curMaxLevelValue)
			end
			self:_playExpAddAction()
		end		
	end))
	self._ccbOwner.sp_bar_bg:stopAllActions()
	self._ccbOwner.sp_bar_bg:runAction(CCSequence:create(arrayBar))

	if divExp > 0 then
		self:_showEatNum(divExp , isLike)
	end

end


function QUIDialogHighTeaMain:_showEatNum(exp , isLike)
	if self._numEffect == nil then
		self._numEffect = QUIWidgetAnimationPlayer.new()
 		self._numEffect:setScale(0.7)

		self._ccbOwner.node_exp:addChild(self._numEffect)
	end
	local str_add = ""
	if isLike then
		str_add = "(爱心加成)"
	end

	self._numEffect:playAnimation("effects/Tips_add.ccbi", function(ccbOwner)
			ccbOwner.content:setString(" ＋"..exp..str_add)
		end)

 	local effect = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.node_effect:addChild(effect)
	effect:playAnimation("ccb/effects/UseItem2.ccbi", nil, function()
			effect:disappear()
			effect = nil
		end)
end


--吃动画
function QUIDialogHighTeaMain:_playSpineEatAction()
	print("QUIDialogHighTeaMain:_playSpineEatAction()")
	self:_playChangeMoodAction()
	local config = remote.activity:getHighTeaFoodConfigByItemId(self._itemId)
	local index = 2
	if config and config.kind > 1 then
		index = 1
	end
	self:closeRoleActionSchedule()
	self._avatar:playAnimation(ACTIONS[index])
	self._avatar:setEndCallback(function( )
 		if self:safeCheck() then
			self:_playSpineMoodAction()
		end			
	end)
end

--心情动画
function QUIDialogHighTeaMain:_playSpineMoodAction()
	print("QUIDialogHighTeaMain:_playSpineMoodAction()")
	self._avatar:playAnimation(self._moodAction)
	self:_playSayWordsAction()

	local array = CCArray:create()
	array:addObject(CCDelayTime:create(0.1))
	array:addObject(CCCallFunc:create(function()
 		if self:safeCheck() then
			self._avatar:setEndCallback(function( )
				self._avatar:playAnimation("stand",true)
		 	-- 	if self:safeCheck() then
				-- 	self:_playChangeMoodAction()
				-- end			
			end)
		end
	end))
	self._ccbOwner.node_spine:stopAllActions()
	self._ccbOwner.node_spine:runAction(CCSequence:create(array))

end

function QUIDialogHighTeaMain:_playSayWordsAction()
	self._ccbOwner.node_desc:setVisible(true)
	if self._richText == nil then
		self._richText = QRichText.new(nil, 220)
   		self._richText:setAnchorPoint(ccp(0, 1))
		self._ccbOwner.node_words:addChild(self._richText)
	end
	self._richText:setString({
		{oType = "font", content = self._sayWords ,size = 18,color = COLORS.j},
	})

	local array = CCArray:create()
	array:addObject(CCCallFunc:create(function()
		makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_desc ,0.3, 255)
	end))
	array:addObject(CCDelayTime:create(3.3))
	array:addObject(CCCallFunc:create(function()
		makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_desc ,0.3, 0)
	end))
	array:addObject(CCDelayTime:create(0.3))
	array:addObject(CCCallFunc:create(function()
		if self:safeCheck() then
			self._ccbOwner.node_desc:setVisible(false)
		end		
	end))
	self._ccbOwner.node_desc:stopAllActions()
	self._ccbOwner.node_desc:runAction(CCSequence:create(array))
end

function QUIDialogHighTeaMain:_playChangeMoodAction()
	if self._isLockAction then
		local word = self:getChatWordsByType(QUIDialogHighTeaMain.CHAT_TYPE.CHANGE,self._mood,self._curLevel)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHighTeaChangeMood",
				options = {word = word ,callback = self:safeHandler(function () 
						self._isLockAction =false
					end)}})
	end

	self:openRoleActionSchedule()
end


-- stand click eat
function QUIDialogHighTeaMain:getChatWordsByType(chatType , mood , curLevel , expression)
	local result = ""
	local resultMood = "stand"
	local chatConfigs = remote.activity:getHighTeaChatConfigByTypeAndMood(chatType , mood , expression)
	if not q.isEmpty(chatConfigs) then
		local chat = chatConfigs[1]
		local num = tonumber(#chatConfigs)
		if num > 1 then
			local index = math.random(1,num)
			chat = chatConfigs[index]
		end
		local reNum = curLevel > 10 and 10 or curLevel
		result = chat["text"..reNum] or ""
		resultMood = chat.expression
	end
	print(result)
	print(resultMood)
	return result , resultMood
end

function QUIDialogHighTeaMain:openRoleActionSchedule()
	self:closeRoleActionSchedule()
	local delay = math.random(7,14)
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
 		if self:safeCheck() then
 			self:_showStandRoleAction()
		end			
	end, delay)
end

function QUIDialogHighTeaMain:closeRoleActionSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end


function QUIDialogHighTeaMain:_onTriggerTouch()
    app.sound:playSound("common_small")

    self:_onTriggerReward()

	-- local lv = self._highTeaDataHandle:getHighTeaLevel() 
	-- lv = lv + 1
 --    local award = {}

	-- local rewardConfig = remote.activity:getHighTeaRewardConfigByLevel(lv)
	-- if rewardConfig == nil then
	-- 	app.tip:floatTip("好感度等级已满，无法获得更多奖励")
	-- 	return	
	-- end
	-- local awards = db:getluckyDrawById(rewardConfig.lvup_reward)
	-- for index,value in pairs(awards) do
	-- 	table.insert(award, {id = value.id, typeName = value.typeName, count = value.count})
	-- end

 --    local tips = "好感度达到"..lv.."级".."，随机获得上述奖励之一"
 --    app:luckyDrawAlert(nil, tips, award)
end

function QUIDialogHighTeaMain:_showStandRoleAction()
	if self._isLockAction then return end 
	self._sayWords , self._moodAction = self:getChatWordsByType(QUIDialogHighTeaMain.CHAT_TYPE.STAND , self._mood , self._curLevel)

	self._avatar:playAnimation(self._moodAction)
	self._avatar:setEndCallback(function( )
		self._avatar:playAnimation("stand",true)
 		if self:safeCheck() then
			self:openRoleActionSchedule()
		end			
	end)
	self:_playSayWordsAction()
end

function QUIDialogHighTeaMain:showFirstTips()
    local strMark = "First_Tips_HighTea"..tostring(remote.user.userId)
    local isMark = app:getUserData():getUserValueForKey(strMark) 
    if not isMark or isMark =="" then
        app:getUserData():setUserValueForKey(strMark, 1)
		local word = self:getChatWordsByType(QUIDialogHighTeaMain.CHAT_TYPE.CHANGE,self._mood,self._curLevel)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHighTeaChangeMood",
				options = {word = word ,callback = self:safeHandler(function () end)}})
    end
end


function QUIDialogHighTeaMain:getLoginPrize()

	local isGetten = self._highTeaDataHandle:checkIsGetHighTeaLoginReward() 
	if not isGetten then
		self._highTeaDataHandle:weeklyGameHighTeaLoginRewardRequest( function (data)
			if data.items then remote.items:setItems(data.items) end
			if data.wallet then remote.user:update(data.wallet) end
	        local awards = data.prizes or {}
 			if self:safeCheck() then
	        	self:showCookRedTips()
	    	end
	        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG , uiClass = "QUIDialogAwardsAlert" ,
	            options = {awards = awards ,title = "每日赠送食材" , callBack = self:safeHandler(function () 
	            		self:showFirstTips()
					end)
	            }}, {isPopCurrentDialog = false} )
		end)
	end

end

function QUIDialogHighTeaMain:_onTriggerRoleClick()
	if self._isLockAction then return end 
	self:closeRoleActionSchedule()
	self._sayWords , self._moodAction = self:getChatWordsByType(QUIDialogHighTeaMain.CHAT_TYPE.CLICK,self._mood,self._curLevel)

	self._avatar:playAnimation(self._moodAction)
	self._avatar:setEndCallback(function( )
		self._avatar:playAnimation("stand",true)
 		if self:safeCheck() then
			self:openRoleActionSchedule()
		end			
	end)
	self:_playSayWordsAction()

end

function QUIDialogHighTeaMain:_onTriggerReward()
    app.sound:playSound("common_small")
 	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHighTeaReward",
    	options = {callBack = self:safeHandler(function () 
    		print("showRedTips")
    		self:showRedTips()
	end)}}) 
end

function QUIDialogHighTeaMain:_onTriggerFood()

	if self._isAtyEnd then
		app.tip:floatTip("活动已经结束，无法进行食物合成")
		return
	end

    app.sound:playSound("common_small")
 	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHighTeaMenu",
    	options = {callBack = self:safeHandler(function () 
			self:refreshData()
			self:_initListView()
			self:showCookRedTips()
	end)}}) 
end

function QUIDialogHighTeaMain:_onTriggerRule()
    app.sound:playSound("common_small")
  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHighTeaHelp",
    	options = {}}, {isPopCurrentDialog = false})
end

function QUIDialogHighTeaMain:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogHighTeaMain:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

function QUIDialogHighTeaMain:_onTriggerShop( )
	remote.stores:openShopDialog(SHOP_ID.highTeaShop)
end

function QUIDialogHighTeaMain:_onTriggerGetaward( )

	local content = db:getConfigurationValue("week_play_reward_mail") or ""
	local awardStr = db:getConfigurationValue("week_play_tea_random_reward") or ""
	local tokenStr = db:getConfigurationValue("week_play_tea_constant_reward")
	local awardTbl = db:getluckyDrawById(tokenStr)
	local awardStrTbl = string.split(awardStr, ";")
	if awardStrTbl[1] and tonumber(awardStrTbl[2]) then
		local itemId = remote.items:getItemIdByLuckyDrawId(awardStrTbl[1])
		if itemId then
			table.insert(awardTbl, {id = itemId, typeName = ITEM_TYPE.ITEM, count = tonumber(awardStrTbl[2])})
		end
	end

	QPrintTable(awardTbl)
	local mail = {
		readed = false,
		title= "奥斯卡的礼物",
		awards = awardTbl,
		content = content,
		from = "奥斯卡",
	}
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHighTeaFreeAwards", 
		options = {isRead = false, mail = mail}}, {isPopCurrentDialog = false})
end

function QUIDialogHighTeaMain:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogHighTeaMain:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end


return	QUIDialogHighTeaMain