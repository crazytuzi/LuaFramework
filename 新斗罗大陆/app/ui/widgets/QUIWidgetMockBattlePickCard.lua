
local QUIWidget = import(".QUIWidget")
local QUIWidgetMockBattlePickCard = class("QUIWidgetMockBattlePickCard", QUIWidget)
local QUIWidgetMockBattleCard = import("..widgets.QUIWidgetMockBattleCard")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")


QUIWidgetMockBattlePickCard.SHOW_FLASH_EFFECT = "SHOW_FLASH_EFFECT"


function QUIWidgetMockBattlePickCard:ctor(options)
	local ccbFile = "ccb/Widget_MockBattle_PickCard.ccbi"
	local callBacks = {
		
	}
	QUIWidgetMockBattlePickCard.super.ctor(self, ccbFile, callBacks, options)

	self._type = options.type_ or 0
	self._chosen_idx = 2
	self._cards= {}
	self.nodes_pos = {}
	self.front_nodes = {}
    self._isAction = false
    self._bezierConfig = nil
end

function QUIWidgetMockBattlePickCard:onEnter()
	QUIWidgetMockBattlePickCard.super.onEnter(self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetMockBattleCard.EVENT_CLICK_CARD, self.onClickCard, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetMockBattleCard.EVENT_CLICK_HELP, self.onClickCardHelp, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetMockBattleCard.EVENT_CLICK_BIND_CARD, self.onClickCardBind, self)
	self:initCards()

end

function QUIWidgetMockBattlePickCard:onExit()
	QUIWidgetMockBattlePickCard.super.onExit(self)
	if  self._bezierConfig then
	    self._bezierConfig:delete()
		self._bezierConfig = nil
	end
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetMockBattleCard.EVENT_CLICK_CARD, self.onClickCard, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetMockBattleCard.EVENT_CLICK_HELP, self.onClickCardHelp, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetMockBattleCard.EVENT_CLICK_BIND_CARD, self.onClickCardBind, self)
end

function QUIWidgetMockBattlePickCard:initCards()
	if not next(self.front_nodes) then
		for i=1,3 do
			local item = QUIWidgetMockBattleCard.new()
			self._ccbOwner["node_card_"..i]:addChild(item)
			table.insert(self.front_nodes, item)
			table.insert(self.nodes_pos, self._ccbOwner["node_card_"..i]:getPosition())
		end
	end
end


function QUIWidgetMockBattlePickCard:getChosenIdx( )
	return self._chosen_idx 
end

function QUIWidgetMockBattlePickCard:setInfo(cards ,_isfirst)
	local isfirst = _isfirst 
	if not next(self._cards) then
		isfirst =true
	end

	self._cards = cards
	if isfirst then
		self:displayMockBattleCard()
	end
end

function QUIWidgetMockBattlePickCard:displayMockBattleCard()
	local index_ = 1
	for _,value in pairs(self._cards) do
		if index_ > 3 then break end
		local item = self.front_nodes[index_] 
		if item ~= nil then
			item:setInfo(value ,self._chosen_idx == index_)
		end
		index_ = index_ + 1
	end
end

function  QUIWidgetMockBattlePickCard:onClickCard(event)
    if self._isAction then return end
	if not event.name then
		return
	end

	local info = event.info
	local index_ = info.index

	if self._chosen_idx == index_ then
		return 
	else
		self:playChooseAction(index_)
	end
end

function  QUIWidgetMockBattlePickCard:playChooseAction(new_index)
	local div  = self._chosen_idx  - new_index
    local arr = CCArray:create()
    local dur_totle = q.flashFrameTransferDur(11)
    local width_pos = 290
    local long_pos = ccp(290, 0)
    local last_num = 1
    for i=1,3 do
    	if i ~= self._chosen_idx and i ~= new_index then
    		last_num = i
    		break
    	end
    end

	if div == -1 or div == 2 then
		self._ccbOwner["node_card_"..self._chosen_idx]:runAction(CCMoveTo:create(dur_totle, ccp(-width_pos, 0)))
		self._ccbOwner["node_card_"..new_index]:runAction(CCMoveTo:create(dur_totle, ccp(0, 0)))
	else
		self._ccbOwner["node_card_"..self._chosen_idx]:runAction(CCMoveTo:create(dur_totle,  ccp( width_pos, 0)))
		self._ccbOwner["node_card_"..new_index]:runAction(CCMoveTo:create(dur_totle, ccp(0, 0)))
		long_pos = ccp(-290, 0)
	end

	self._ccbOwner["node_card_"..self._chosen_idx]:setZOrder(20)
	self._ccbOwner["node_card_"..new_index]:setZOrder(20)
	self._ccbOwner["node_card_"..last_num]:setZOrder(15)

	self.front_nodes[self._chosen_idx]:cardBeChosen(false)
	self.front_nodes[new_index]:cardBeChosen(true)
	self.front_nodes[last_num]:cardMoveLonger()

    local dur = q.flashFrameTransferDur(5)
    local dur2 = q.flashFrameTransferDur(6)

	local array2 = CCArray:create()
    array2:addObject(CCScaleTo:create(dur, 0.1, 1))
    array2:addObject(CCScaleTo:create(dur2, 1, 1))
	local array1 = CCArray:create()
    array1:addObject(CCMoveTo:create(dur_totle, long_pos))
    array1:addObject(CCSequence:create(array2))
	self._ccbOwner["node_card_"..last_num]:runAction(CCSpawn:create(array1))

	self._chosen_idx = new_index

end


function  QUIWidgetMockBattlePickCard:playChooseCardFlyAction(move_end_pos)

    self._isAction = true
    local dur = q.flashFrameTransferDur(17)

	local targetpos = self._ccbOwner["node_card_"..self._chosen_idx]:convertToNodeSpace(move_end_pos)

	local array2 = CCArray:create()
    array2:addObject(CCMoveTo:create(dur, targetpos))
    array2:addObject(CCScaleTo:create(dur, 0.1))
    local arr = CCArray:create()
    arr:addObject(CCSpawn:create(array2))
    arr:addObject(CCCallFunc:create(function()
      	self:playChooseEndAction()
      	self:isShowEffect(targetpos)
    	self._isAction = false
    end))

	self.front_nodes[self._chosen_idx]:runAction(CCSequence:create(arr))
	self.front_nodes[self._chosen_idx]:cardFlyAction()
	self.front_nodes[self._chosen_idx]:setIconVisible(false)
	local icon = self.front_nodes[self._chosen_idx]:getBindCard()
	if icon then
    	self._ccbOwner.node_card_bind:addChild(icon)
		self._ccbOwner.node_card_bind:setZOrder(99)

		if not self._bezierConfig  then
			local targetpos2 = icon:convertToNodeSpace(move_end_pos)
			local currentPos = ccp(0,0)
		    self._bezierConfig = ccBezierConfig:new()
		    self._bezierConfig.endPosition = targetpos2
		    self._bezierConfig.controlPoint_1 = ccp(currentPos.x + (targetpos2.x - currentPos.x) * 0.333, -150)
		    self._bezierConfig.controlPoint_2 = ccp(currentPos.x + (targetpos2.x - currentPos.x) * 0.667, 100)
		end
	    local bezierTo = CCBezierTo:create(dur , self._bezierConfig)
	    local array_bind = CCArray:create()
	    array_bind:addObject(CCEaseIn:create(bezierTo, 4))
	    array_bind:addObject(CCScaleTo:create(dur, 0.1))
    	icon:stopAllActions()
		icon:runAction(CCSequence:create(array_bind))
	end
end


function QUIWidgetMockBattlePickCard:isShowEffect( targetpos)

	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetMockBattlePickCard.SHOW_FLASH_EFFECT})

end

function QUIWidgetMockBattlePickCard:getIsAction( )
    return	self._isAction
	 
end

function  QUIWidgetMockBattlePickCard:playChooseEndAction()
    local dur = q.flashFrameTransferDur(15)

    for i=1,3 do
    	if i ~= self._chosen_idx then
    		self.front_nodes[i]:playCardDisappear(dur,0)
    	end
    end
    self.front_nodes[self._chosen_idx]:setScale(1)
	self.front_nodes[self._chosen_idx]:setPosition(ccp(0, 0))
	self.front_nodes[self._chosen_idx]:playCardDisappearHalf(dur,0)
	self.front_nodes[self._chosen_idx]:setIconVisible(true)
    self._ccbOwner.node_card_bind:stopAllActions()
    self._ccbOwner.node_card_bind:setScale(1)
    self._ccbOwner.node_card_bind:removeAllChildren()

    local dur2 = q.flashFrameTransferDur(20)
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(dur2))
    arr:addObject(CCCallFunc:create(function()
		self:displayMockBattleCard()
    end))

    self:stopAllActions()
    self:runAction(CCSequence:create(arr))
end


function  QUIWidgetMockBattlePickCard:onClickCardHelp(event)
	if not event.name then
		return
	end
	local info = event.info
	QPrintTable(info)
	if info.oType ==QUIWidgetMockBattleCard.CARD_TYPE_HERO then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleHeroCardInfo",
			options = {actorId = info.id , id = info.card_id}})
	elseif	info.oType == QUIWidgetMockBattleCard.CARD_TYPE_SOUL then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleSoulCardInfo",
			options = {actorId = info.id, id = info.card_id}})
	elseif	info.oType == QUIWidgetMockBattleCard.CARD_TYPE_MOUNT then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleMountCardInfo",
			options = {actorId = info.id, id = info.card_id}})
	elseif	info.oType == QUIWidgetMockBattleCard.CARD_TYPE_GODARM then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleGodarmCardInfo",
			options = {actorId = info.id, id = info.card_id}})
	end
end

function  QUIWidgetMockBattlePickCard:onClickCardBind(event)
	if not event.name then
		return
	end
	local info = event.info
	local data_ = remote.mockbattle:getCardInfoByIndex(info.bind_card_id)

	if data_.cType ==QUIWidgetMockBattleCard.CARD_TYPE_HERO then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleHeroCardInfo",
			options = {actorId = info.bind_id , id = info.bind_card_id}})
	elseif	data_.cType == QUIWidgetMockBattleCard.CARD_TYPE_SOUL then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleSoulCardInfo",
			options = {actorId = info.bind_id, id = info.bind_card_id}})
	elseif	data_.cType == QUIWidgetMockBattleCard.CARD_TYPE_MOUNT then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleMountCardInfo",
			options = {actorId = info.bind_id, id = info.bind_card_id}})
	elseif	data_.cType == QUIWidgetMockBattleCard.CARD_TYPE_GODARM then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleGodarmCardInfo",
			options = {actorId = info.bind_id, id = info.bind_card_id}})
	end
end


return QUIWidgetMockBattlePickCard