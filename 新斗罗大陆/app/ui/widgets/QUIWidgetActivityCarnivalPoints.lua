-- @Author: liaoxianbo
-- @Date:   2020-05-06 18:24:13
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-05-16 15:40:23
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityCarnivalPoints = class("QUIWidgetActivityCarnivalPoints", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QActivity = import("...utils.QActivity")

QUIWidgetActivityCarnivalPoints.GETAWARDS_EVENT_SUCESS = "GETAWARDS_EVENT_SUCESS"

function QUIWidgetActivityCarnivalPoints:ctor(options)
	local ccbFile = "ccb/Widget_Activity_Carnival_Points.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetActivityCarnivalPoints.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetActivityCarnivalPoints:onEnter()
    self._activityProxy = cc.EventProxy.new(remote.activity)
   	self._activityProxy:addEventListener(QActivity.EVENT_128RECHARGE_UPDATE, handler(self, self.updateDialog))	
end

function QUIWidgetActivityCarnivalPoints:onExit()
	self._activityProxy:removeAllEventListeners()
end

function QUIWidgetActivityCarnivalPoints:resetAll( )
	self._ccbOwner.sp_unlock:setVisible(false)
	self._ccbOwner.node_btn:setVisible(false)
	self._ccbOwner.sp_ishave:setVisible(false)
	self._ccbOwner.notTouch:setVisible(false)
	self._ccbOwner.sp_yilingqu:setVisible(false)

	self._ccbOwner.node_special_item:removeAllChildren()
	self._ccbOwner.node_item:removeAllChildren()

	self._ccbOwner.tf_name:setString("")
end
function QUIWidgetActivityCarnivalPoints:setInfo(index,curType,info)
	self:resetAll()
	if q.isEmpty(info) then return end
	self._curActivityType = curType

	self._isShowLock = remote.user.calnivalPrizeIsActive or false
	self._curtentPoints = remote.user.calnivalPoints or 0
	if self._curActivityType == 2 then
		self._curtentPoints = remote.user.celebration_points or 0
		self._isShowLock = remote.user.celebrationPrizeIsActive or false
	end
	self._index = index
	self._info = info
	self._ccbOwner.tf_name:setString(string.format("积分达到%d分",self._info.condition))
	local showPoints = self._curtentPoints > self._info.condition and self._info.condition or self._curtentPoints
	self._ccbOwner.tf_num:setString(string.format("进度%d/%d",showPoints,self._info.condition))

	self._ccbOwner.sp_unlock:setVisible(not self._isShowLock)

	if self._info.isFinash then
		self._ccbOwner.sp_ishave:setVisible(true)
	elseif self._curtentPoints >= self._info.condition then
		self._ccbOwner.node_btn:setVisible(true)
		self._ccbOwner.sp_yilingqu:setVisible(self._info.isNormRecived or false)
		if self._info.isNormRecived then
			self._ccbOwner.tf_btn:setString("特权领取")
		else
			self._ccbOwner.tf_btn:setString("领 取")
		end

	else
		self._ccbOwner.notTouch:setVisible(true)
	end
	if self._info.common_reward then
		self:addItemBox(self._ccbOwner.node_item,self._info.common_reward,1)
	end

	if self._info.special_reward then
		self:addItemBox(self._ccbOwner.node_special_item,self._info.special_reward,2)
	end

	
end

function QUIWidgetActivityCarnivalPoints:addItemBox(node,rewardStr,index)
	if node and rewardStr then
		local rewardTbl = string.split(rewardStr, "^")
		local itemBox = QUIWidgetItemsBox.new()
		node:addChild(itemBox)
		local id = rewardTbl[1] 
		local count = tonumber(rewardTbl[2])
		local itemType = remote.items:getItemType(rewardTbl[1]) or ITEM_TYPE.ITEM

		itemBox:setGoodsInfo(id, itemType, count)
		itemBox:showSpecial(index == 2)
		-- self._curtentPoints
		-- itemBox:showBoxEffect("ccb/effects/heji_kuang_2.ccbi",true)
		if self._curtentPoints >= self._info.condition then
			if index == 1 and not self._info.isNormRecived then
				itemBox:showBoxEffect("effects/leiji_light.ccbi",true, 0, 0, 0.6)
			end
			if index == 2 and self._isShowLock and not self._info.isFinash then
				itemBox:showBoxEffect("effects/leiji_light.ccbi",true, 0, 0, 0.6)
			end
		end
	end
end

function QUIWidgetActivityCarnivalPoints:showItemInfo(itemID,itemType)
	-- body
	local itemConfig = db:getItemByID(itemID)
	if itemConfig and itemConfig.type == ITEM_CONFIG_TYPE.SOUL then
		local actorId = db:getActorIdBySoulId( itemID )
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroDetailInfoNew", options = {actorId = actorId}}, {isPopCurrentDialog = false})
	else
		app.tip:itemTip(itemType, itemID)
	end
end

function QUIWidgetActivityCarnivalPoints:switchAwards(awardStr)
	local award = string.split(awardStr, "^")
	local id = award[1]
	local num = tonumber(award[2])
    local itemType = remote.items:getItemType(id) or ITEM_TYPE.ITEM
	return {id = id, typeName = itemType, count = num}
end

function QUIWidgetActivityCarnivalPoints:updateDialog( )
	if self._topTipsDialog then
		self._topTipsDialog:popSelf()
		self._topTipsDialog = nil
	end
end

function QUIWidgetActivityCarnivalPoints:showSpecialDialog()

	if self._topTipsDialog then
		self._topTipsDialog:popSelf()
		self._topTipsDialog = nil
	end

	local activityType = self._curActivityType

	local curtentPoints = self._curtentPoints
	local allSpecialItems = {}
	local availableItems = {}
	local scoreInfo = db:getStaticByName("activity_carnival_new_reward") or {}
	for _,value in pairs(scoreInfo) do
		if value.type == activityType then
			if value.special_reward then
				local rewardTbl = string.split(value.special_reward, "^")
				table.insert(allSpecialItems,{id=rewardTbl[1],typeName = remote.items:getItemType(rewardTbl[1]) or ITEM_TYPE.ITEM, count= tonumber(rewardTbl[2])})
				if curtentPoints >= value.condition then
					table.insert(availableItems,{id=rewardTbl[1],typeName = remote.items:getItemType(rewardTbl[1]) or ITEM_TYPE.ITEM, count= tonumber(rewardTbl[2])})
				end
			end			
		end
	end

	self._topTipsDialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSpecialAwards",
		options = {bigTitle = "特权购买", curActivityType = activityType,allSpecialItems = allSpecialItems,availableItems = availableItems,
		title1 = "购买128后获得以下额外奖励",title2 = "现在购买立即获得以下奖励",closeCallback = function()
			self._topTipsDialog = nil
		end}})

end
function QUIWidgetActivityCarnivalPoints:_onTriggerConfirm(x , y, touchNodeNode, list)
	local awards = {}
	if self._info.common_reward and not self._info.isNormRecived then
		local awdrdTbl = self:switchAwards(self._info.common_reward)
    	table.insert(awards,awdrdTbl) 
	end
	if self._info.special_reward and self._isShowLock then
		local awdrdTbl = self:switchAwards(self._info.special_reward)
    	table.insert(awards,awdrdTbl) 
	end

	if self._info.isNormRecived and not self._isShowLock then
		-- app.tip:floatTip("特权未解锁，请先前往解锁!")
		self:showSpecialDialog()
		return
	end
	app:getClient():getSevenActivityIntegralReward(self._curActivityType, self._info.id, function()
	  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
	    		options = {awards = awards}},{isPopCurrentDialog = false} )
	    	dialog:setTitle("恭喜您获得活动奖励")

	    	if self:safeCheck() then
	    		if self._curActivityType == 1 then
			        app.taskEvent:updateTaskEventProgress(app.taskEvent.ACTIVITY_CARNIVAL_PRIZE_EVENT, 1)
			    end
	    	end
	    	
	    	self:dispatchEvent({name = QUIWidgetActivityCarnivalPoints.GETAWARDS_EVENT_SUCESS,index = self._index})

		end)
end


function QUIWidgetActivityCarnivalPoints:_onTriggerClickNormal(x , y, touchNodeNode, list)
	if self._info and self._info.common_reward then
		local rewardTbl = string.split(self._info.common_reward, "^")

		local id = rewardTbl[1] 
		local itemType = remote.items:getItemType(rewardTbl[1]) or ITEM_TYPE.ITEM		
		self:showItemInfo(id,itemType)
	end
end


function QUIWidgetActivityCarnivalPoints:_onTriggerClickSpecial(x , y, touchNodeNode, list)
	if self._info and self._info.special_reward then
		local rewardTbl = string.split(self._info.special_reward, "^")

		local id = rewardTbl[1] 
		local itemType = remote.items:getItemType(rewardTbl[1]) or ITEM_TYPE.ITEM		
		self:showItemInfo(id,itemType)
	end
end

function QUIWidgetActivityCarnivalPoints:getContentSize()
	return self._ccbOwner.cellSize:getContentSize()
end

return QUIWidgetActivityCarnivalPoints
