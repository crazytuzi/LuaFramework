

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetOfferRewardTask = class("QUIWidgetOfferRewardTask", QUIWidget)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QColorLabel = import("...utils.QColorLabel")
local QUIWidgetHeroProfessionalIcon = import("..widgets.QUIWidgetHeroProfessionalIcon")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import(".QUIWidgetQlistviewItem")


QUIWidgetOfferRewardTask.EVENT_GET_REWARD = "EVENT_GET_REWARD"
QUIWidgetOfferRewardTask.EVENT_CLICK = "EVENT_CLICK"

QUIWidgetOfferRewardTask.STATE_TYPE_DONE = "STATE_TYPE_DONE"
QUIWidgetOfferRewardTask.STATE_TYPE_GETREWARD = "STATE_TYPE_GETREWARD"
QUIWidgetOfferRewardTask.STATE_TYPE_TIMER = "STATE_TYPE_TIMER"


function QUIWidgetOfferRewardTask:ctor(options)
	local ccbFile = "ccb/Widget_OfferReward_Task.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerGet", callback = handler(self, self._onTriggerGet)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
	}
	QUIWidgetOfferRewardTask.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)
    q.setButtonEnableShadow(self._ccbOwner.btn_get)

end

function QUIWidgetOfferRewardTask:resetAll()

    self._ccbOwner.node_prize_1:removeAllChildren()
	self._ccbOwner.node_prize_2:removeAllChildren()
	self._ccbOwner.node_desc:removeAllChildren()

	self._ccbOwner.tf_name:setString("")

	self._ccbOwner.node_countdown:setVisible(false)
	self._ccbOwner.node_get:setVisible(false)
	self._ccbOwner.node_ok:setVisible(false)

	self._timeCd = 0
    if self._timerScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._timerScheduler)
    	self._timerScheduler = nil
    end

end

function QUIWidgetOfferRewardTask:setInfo(info)
	self._info =info
	local _id = self._info.taskId
	self._offerReward = remote.offerreward:getOfferRewardTaskById(_id)
	if self._offerReward == nil then
		return
	end

	self:resetAll()
    self._timeCd = tonumber(self._offerReward.time) * 60
	self:_refreshInfo()

  	local sabcInfo = db:getSABCByAptitude(tonumber(self._offerReward.aptitude) + 1)
    -- local color = string.upper(sabcInfo.color)
    -- local fontColor = QIDEA_QUALITY_COLOR[color]

   	local colorInfo = FONTCOLOR_TO_OUTLINECOLOR[self._offerReward.aptitude + 1]
	if colorInfo then
		self._ccbOwner.tf_name:setColor(colorInfo.fontColor)
		self._ccbOwner.tf_name:setOutlineColor(colorInfo.outlineColor)
		self._ccbOwner.tf_name:enableOutline()
	end
	self._ccbOwner.tf_name:setString(self._offerReward.name)

    self:setSABC(sabcInfo.lower)
    
    self._ccbOwner.tf_totaltime:setString(q.converFun(self._timeCd))

	local talentType = 1
	if self._offerReward.func == "health" then
		talentType = HERO_TALENT.HEALTH
	elseif self._offerReward.func == "t" then
		talentType = HERO_TALENT.TANK
	elseif self._offerReward.func == "dps_p" then
		talentType = HERO_TALENT.DPS_PHYSISC
	elseif self._offerReward.func == "dps_m" then
		talentType = HERO_TALENT.DPS_MAGIC
 	end

   	self._ccbOwner.node_talent:setVisible(true)
    if self._professionalIcon == nil then 
        self._professionalIcon = QUIWidgetHeroProfessionalIcon.new()
        self._ccbOwner.node_talent:addChild(self._professionalIcon)
    end
    self._professionalIcon:setType(talentType,false,1)


    local rewards1 = string.split(self._offerReward.rewards_1, "^")
    local rewards2 = string.split(self._offerReward.rewards_2, "^")

    self._data = {}


	if #rewards1 > 1 then
		-- local itemBox = QUIWidgetItemsBox.new()
	 --    itemBox:setPromptIsOpen(true)
	 --    itemBox:setGoodsInfo(tonumber(rewards1[1]), ITEM_TYPE.ITEM,tonumber(rewards1[2]))
	 --    itemBox:setScale(0.7)
	 --    self._ccbOwner.node_prize_1:addChild(itemBox)
		local eliteAwards = {}
		remote.items:analysisServerItem(self._offerReward.rewards_1, eliteAwards)
	    table.insert(self._data, {id = eliteAwards[1].id, type = eliteAwards[1].typeName, count = eliteAwards[1].count})
	
	    -- table.insert(self._data, {id = tonumber(rewards1[1]), type = ITEM_TYPE.ITEM, count = tonumber(rewards1[2])})

	end
	if #rewards2 > 1 then
		-- local itemBox = QUIWidgetItemsBox.new()
	 --    itemBox:setPromptIsOpen(true)
	 --    itemBox:setGoodsInfo(0, rewards2[1],tonumber(rewards2[2]))
	 --    itemBox:setScale(0.7)
	 --    self._ccbOwner.node_prize_2:addChild(itemBox)
		local eliteAwards = {}
		remote.items:analysisServerItem(self._offerReward.rewards_2, eliteAwards)
	    table.insert(self._data, {id = eliteAwards[1].id, type = eliteAwards[1].typeName, count = eliteAwards[1].count})

	    -- table.insert(self._data, {id = 0, type = rewards2[1], count = tonumber(rewards2[2])})
	end

	local buffText = QColorLabel:create(self._offerReward.describe, 200, 80, nil, nil, GAME_COLOR_LIGHT.normal)
	self._ccbOwner.node_desc:addChild(buffText)
	buffText:setPosition(ccp(0, 0))
	self:_initListView()

end 

-- QUIWidgetOfferRewardTask.STATE_TYPE_DONE = "STATE_TYPE_DONE"
-- QUIWidgetOfferRewardTask.STATE_TYPE_GETREWARD = "STATE_TYPE_GETREWARD"
-- QUIWidgetOfferRewardTask.STATE_TYPE_TIMER = "STATE_TYPE_TIMER"
function QUIWidgetOfferRewardTask:_refreshInfo()

	self._ccbOwner.node_countdown:setVisible(false)
	self._ccbOwner.node_get:setVisible(false)
	self._ccbOwner.node_ok:setVisible(false)

	self._state = QUIWidgetOfferRewardTask.STATE_TYPE_DONE 
	local _startAt = self._info.startAt or 0
	local isStart = self._info.isStart or false

	if _startAt > 0 and isStart then
		local currTime = q.serverTime()
		local endTime = _startAt / 1000
		endTime = endTime + self._timeCd
		print("QUIWidgetOfferRewardTask:_refreshInfo  "..(endTime - currTime ))
		if endTime > currTime then
			self._state = QUIWidgetOfferRewardTask.STATE_TYPE_TIMER 
		else
			self._state = QUIWidgetOfferRewardTask.STATE_TYPE_GETREWARD 
		end
	end

	if self._state == QUIWidgetOfferRewardTask.STATE_TYPE_TIMER then
	    self._ccbOwner.node_countdown:setVisible(true)
		self:_handlerTimer()
	elseif self._state == QUIWidgetOfferRewardTask.STATE_TYPE_GETREWARD then
	    self._ccbOwner.node_get:setVisible(true)
	else
	    self._ccbOwner.node_ok:setVisible(true)
	end
end

function QUIWidgetOfferRewardTask:_handlerTimer()
	if self._timerScheduler == nil then
			self._timerScheduler = scheduler.scheduleGlobal(function ()
				self:_updateCountDown()
			end, 1)
		self:_updateCountDown()
	end
end


function QUIWidgetOfferRewardTask:_updateCountDown()
	local _startAt = self._info.startAt or 0
	local isStart = self._info.isStart or false
	local currTime = q.serverTime()
	local endTime = _startAt / 1000
	endTime = endTime + self._timeCd
	if endTime > currTime and isStart then
		self._ccbOwner.tf_countdown:setString(q.converFun(endTime - currTime))
	else
   		if self._timerScheduler then
			scheduler.unscheduleGlobal(self._timerScheduler)
			self._timerScheduler = nil
		end
		self:_refreshInfo()
	end
end

function QUIWidgetOfferRewardTask:onTouchListView( event )
	if not event then
		return
	end

	if self._listView then
		self._listView:onTouch(event)
	end
end

function QUIWidgetOfferRewardTask:_initListView()
	if self._listView == nil then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemCallBack),
			isVertical = false,
	        enableShadow = false,
	        spaceX = -15,
	        totalNumber = #self._data
		}
		self._listView = QListView.new(self._ccbOwner.itemsListView, cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIWidgetOfferRewardTask:_renderItemCallBack(list, index, info)
	local function showItemInfo(x, y, itemBox, listView)
		app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
	end

    local isCacheNode = true
  	local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then	       	
    	item = QUIWidgetQlistviewItem.new()
        isCacheNode = false
    end

    if not item._itemBox then
		item._itemBox = QUIWidgetItemsBox.new()
		item._itemBox:setScale(0.7)
		item._itemBox:setPosition(ccp(35,70))
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(100,100))
	end
	item._itemBox:setGoodsInfo(data.id, data.type, data.count)
    info.item = item
    info.size = item._ccbOwner.parentNode:getContentSize()
    list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)

    return isCacheNode
end

function QUIWidgetOfferRewardTask:setSABC(lower)
	lower = lower 
    q.setAptitudeShow(self._ccbOwner,lower)
end

function QUIWidgetOfferRewardTask:_onTriggerGet(event)
	if self._offerReward and self._state == QUIWidgetOfferRewardTask.STATE_TYPE_GETREWARD then
		self:dispatchEvent({name = QUIWidgetOfferRewardTask.EVENT_GET_REWARD, info = self._info})
	end
end

function QUIWidgetOfferRewardTask:_onTriggerOK(event)
	if self._offerReward and self._state == QUIWidgetOfferRewardTask.STATE_TYPE_DONE then
		self:dispatchEvent({name = QUIWidgetOfferRewardTask.EVENT_CLICK, info = self._info})
	end
end

function QUIWidgetOfferRewardTask:getContentSize( ... )
	return cc.size(self._ccbOwner.node_size:getContentSize().width + 2 ,self._ccbOwner.node_size:getContentSize().height + 10)
end

function QUIWidgetOfferRewardTask:onEnter()
	--代码
	self._isExit = true
end

--describe：onExit 
function QUIWidgetOfferRewardTask:onExit()
	--代码
	self._isExit = nil
    if self._timerScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._timerScheduler)
    	self._timerScheduler = nil
    end
end

return QUIWidgetOfferRewardTask