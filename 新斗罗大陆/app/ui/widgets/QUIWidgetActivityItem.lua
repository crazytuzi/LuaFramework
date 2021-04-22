--
-- Author: wkwang
-- Date: 2015-03-20 17:07:03
-- 活动面板的活动内容条目
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityItem = class("QUIWidgetActivityItem", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("...ui.QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetQlistviewItem = import(".QUIWidgetQlistviewItem")
local QListView = import("...views.QListView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QQuickWay = import("...utils.QQuickWay")

function QUIWidgetActivityItem:ctor(options)
	local ccbFile = "Widget_Activity_client2.ccbi"
	if options and options.ccbFile then
		ccbFile = options.ccbFile
	end
	QUIWidgetActivityItem.super.ctor(self,ccbFile,callBacks,options)
    self._isSelectPreviewDay = false
end

function QUIWidgetActivityItem:getContentSize()
	return self._ccbOwner.cellSize:getContentSize()
end

function QUIWidgetActivityItem:setInfo(id, info, activityPanel, isPreviewActivity, startAt)
	self._isChooseOne = false
	self._activityPanel = activityPanel
	self.id = id
	self.info = info
	self.awards = {}
	self._itemBoxs = {}
	self._index = nil
	-- self._ccbOwner.node_item:removeAllChildren()
	self.haveNum = remote.activity:getTypeNum(info) or 0
	self._ccbOwner.tf_name:setString(self.info.description or "")
	if self.info.completeNum == 0 or self.info.completeNum == 3 or self.info.type == 513 or self.info.type == 549 then
		self._ccbOwner.tf_num:setString("")
	else
		if remote.activity:isActivitySupportMultiple(info.type, info.repeatCount) then
			local progressData = remote.activity:getActivityTargetProgressDataById(info.activityId, info.activityTargetId)
			if progressData then
				self._ccbOwner.tf_num:setString(string.format("剩余次数：%d/%d", info.repeatCount - progressData.awardCount,info.repeatCount))
			end
		elseif self.info.activityId == "a_dlmrt" then
			self.info.completeNum = -1
			local curRank = tonumber(remote.user.celebrityHallCurRank)
			if curRank and curRank ~= 999999 then
				-- 这999999是和后端约定的
				self._ccbOwner.tf_num:setString("排行："..curRank)
			else
				self._ccbOwner.tf_num:setString("未入榜")
			end
		else
			local haveNum = self.haveNum > self.info.value and self.info.value or self.haveNum
			if self.info.type == 100 then
				self._ccbOwner.tf_num:setString("进度: "..(haveNum == 1 and self.info.value2 or 0).."/"..self.info.value2)
			else
				self._ccbOwner.tf_num:setString("进度: "..haveNum.."/"..self.info.value)
			end
		end
	end

	self._ccbOwner.sp_time_out:setVisible(false)
	self._ccbOwner.node_btn:setVisible(false)
	self._ccbOwner.node_btn2:setVisible(false)
	self._ccbOwner.node_btn_go:setVisible(false)
	self._ccbOwner.notTouch:setVisible(false)
	self._ccbOwner.tf_btn:setString("领  取")
	if isPreviewActivity and q.serverTime() * 1000 < (startAt or 0) then
		self._ccbOwner.notTouch:setString("明日开启")
		self._ccbOwner.notTouch:setVisible(true)
	elseif self.info.completeNum == 2 then
		makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
		self._ccbOwner.node_btn:setVisible(true)
	elseif self.info.completeNum == 1 then 
		local isActive = remote.activity:checkIsActivity(self.info.activityId)
		if remote.activity:isRechargeActivity(self.info.type) then
			self._ccbOwner.node_btn2:setVisible(true)
			if isActive == true then
				makeNodeFromGrayToNormal(self._ccbOwner.node_btn2)
			else
				makeNodeFromNormalToGray(self._ccbOwner.node_btn2)
			end
		elseif remote.activity:getLinkActivity(self.info.type) ~= nil or self.info.link ~= nil then
			if isActive == true then
				makeNodeFromGrayToNormal(self._ccbOwner.node_btn_go)
			else
				makeNodeFromNormalToGray(self._ccbOwner.node_btn_go)
			end
			self._ccbOwner.node_btn_go:setVisible(true)
		else
			self._ccbOwner.notTouch:setVisible(true)
		end
	elseif self.info.activityId == "a_dlmrt" then
		self._ccbOwner.node_btn:setVisible(false)
		self._ccbOwner.node_btn2:setVisible(false)
		self._ccbOwner.node_btn_go:setVisible(false)
		local curRank = tonumber(remote.user.celebrityHallCurRank)
		if curRank >= self.info.value and curRank <= self.info.value2 then
			self._ccbOwner.alreadyTouch:setVisible(true)
			self._ccbOwner.notTouch:setVisible(false)
		else
			self._ccbOwner.alreadyTouch:setVisible(false)
			self._ccbOwner.notTouch:setVisible(true)
		end
	end
	self._ccbOwner.sp_ishave:setVisible(self.info.completeNum == 3)
	
	if self._ccbOwner.node_dazhe then
		self._ccbOwner.node_dazhe:removeAllChildren()
		if self.info.discount then
			local ccbProxy = CCBProxy:create()
	        local ccbOwner = {}
	        local dazheWidget = CCBuilderReaderLoad("Widget_dazhe.ccbi", ccbProxy, ccbOwner)
	        ccbOwner.chengDisCountBg:setVisible(false)
	        ccbOwner.lanDisCountBg:setVisible(false)
	        ccbOwner.ziDisCountBg:setVisible(false)
	        ccbOwner.hongDisCountBg:setVisible(true)
	        if self.info.discount >= 1 and self.info.discount < 10 then
	        	ccbOwner.discountStr:setString(self.info.discount.."折")
	    	elseif self.info.discount == 11 then
	        	ccbOwner.discountStr:setString("限时")
	        elseif self.info.discount == 12 then
	        	ccbOwner.discountStr:setString("火热")
	        elseif self.info.discount == 13 then
	        	ccbOwner.discountStr:setString("推荐")
	        end
	        self._ccbOwner.node_dazhe:addChild(dazheWidget)
		end
	end

	self._data = {}
	if self.info.awards ~= nil then
		local items = string.split(self.info.awards, ";") 
		local count = #items
		for i=1,count,1 do
			local  temp = string.split(items[i], "#")
			if #temp > 1 then
				self._isChooseOne = true
				self._awardStr = string.gsub(items[i], "#", ";")
				for k,v in pairs(temp) do
					local obj = string.split(v, "^")
		            if #obj == 2 then
		            	local typeName = remote.items:getItemType(obj[1]) or ITEM_TYPE.ITEM
	        			table.insert(self.awards, {id = obj[1], typeName = typeName, count = tonumber(obj[2])})
	        			if tonumber(obj[2]) > 0 then
		            		table.insert(self._data, {oType = "item", id = obj[1], count = obj[2]})
		            	end
		            	if k ~= #temp then
		        			table.insert(self._data, {oType = "separate", id = "ui/Activity_game/zi_huo.png", width = 30})
		        		end
		            end
				end
			else
				local obj = string.split(items[i], "^")
	            if #obj == 2 then
	            	local typeName = remote.items:getItemType(obj[1]) or ITEM_TYPE.ITEM
	        		table.insert(self.awards, {id = obj[1], typeName = typeName, count = tonumber(obj[2])})
	        		if tonumber(obj[2]) > 0 then
	            		table.insert(self._data, {oType = "item", id = obj[1], count = obj[2]})
	            	end
	            end
			end
		end
	end 

	self:initListView()
end

function QUIWidgetActivityItem:initListView()
	if not self._listView then

		local function showItemInfo(x, y, itemBox, listView)
			app.tip:itemTip(itemBox._itemType, itemBox._itemID, false)
		end

		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	          	local data = self._data[index]

	            local item = list:getItemFromCache(data.oType)
	            if not item then
	                item = QUIWidgetQlistviewItem.new()
	                isCacheNode = false
	            end
	            self:setItemInfo(item,data,index)

	            info.item = item
	            info.tag = data.oType
	            info.size = item._ccbOwner.parentNode:getContentSize()
	            --注册事件
	            if data.oType == "item" then
                	list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)
	           	end

	            return isCacheNode
	        end,
	        isChildOfListView = true,
	        isVertical = false,
	        enableShadow = false,
	        -- ignoreCanDrag = true,
	    	-- leftShadow = self._ccbOwner.leftShadow,
	    	-- rightShadow = self._ccbOwner.rightShadow,
	        totalNumber = #self._data,
	    }  
    	self._listView = QListView.new(self._ccbOwner.itemsListView,cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end 
end

function QUIWidgetActivityItem:setItemInfo( item, data ,index)
	-- item._ccbOwner.parentNode:removeAllChildren()
	if data.oType == "item" then
		if not item._itemBox then
			item._itemBox = QUIWidgetItemsBox.new()
			item._itemBox:setScale(0.75)
			item._itemBox:setPosition(ccp(45, 38))
			item._ccbOwner.parentNode:addChild(item._itemBox)
			item._ccbOwner.parentNode:setContentSize(CCSizeMake(75, 75))

		end
		local id = data.id 
		local count = tonumber(data.count)
		local itemType = remote.items:getItemType(id)

		item._itemBox:showLock(self.info.isShowLock or false)

		if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
			item._itemBox:setGoodsInfo(id, itemType, count)
		else
			item._itemBox:setGoodsInfo(id, ITEM_TYPE.ITEM, count)	
		end			
	elseif data.oType == "separate" then
		if not item._separate then
			local sprite = CCSprite:create(data.id)
			item._separate = sprite
			item._ccbOwner.parentNode:addChild(sprite)
		else
			local frame  = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(data.id)
			if frame then
				item._separate:setDisplayFrame(frame)
			end
		end
		local width = 50
		if data.width then
			width = data.width
		end 
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(width, 80))
		item._separate:setPosition(width/2+3, 50)
	end
end

function QUIWidgetActivityItem:onTouchListView( event )
	-- body
	if not event then
		return
	end
	if event.name == "moved" then
		local contentListView = self._activityPanel:getContentListView()
		if contentListView then
			local curGesture = contentListView:getCurGesture() 
			if curGesture then
				if curGesture == QListView.GESTURE_V then
					self._listView:setCanNotTouchMove(true)
				elseif curGesture == QListView.GESTURE_H then
					contentListView:setCanNotTouchMove(true)
				end
			end
		end
	elseif  event.name == "ended" then
		local contentListView = self._activityPanel:getContentListView()
		if contentListView then
			contentListView:setCanNotTouchMove(nil)
		end
		self._listView:setCanNotTouchMove(nil)
	end

	self._listView:onTouch(event)
end

--请求完成
function QUIWidgetActivityItem.getRewards( activityId, activityTargetId, awards, params )
	app:getClient():activityCompleteRequest(activityId, activityTargetId, params, nil, function ()
		if activityId == remote.activity.TYPE_ACTIVITY_FOR_SEVEN then
			app.taskEvent:updateTaskEventProgress(app.taskEvent.ACTIVITY_CARNIVAL_SCORE_EVENT, 1)
		end
  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards}},{isPopCurrentDialog = false} )
		dialog:setTitle("恭喜您获得活动奖励")
		remote.activity:setCompleteDataById(activityId, activityTargetId)
	end)

	return true
end

function QUIWidgetActivityItem:_onTriggerConfirm(x , y, touchNodeNode, list)
	print("QUIWidgetActivityItem:_onTriggerConfirm")
    app.sound:playSound("common_small")
    if self._isSelectPreviewDay then
		app.tip:floatTip("活动明日才开启哟！")
		return
   	end
	if self.info.completeNum == 3 then
		return
	end
	if self.info.completeNum ~= 2 then
		if not remote.activity:checkIsActivity(self.info.activityId) then
			app.tip:floatTip("不在活动时间段内!")
			return
		else
			local shortcutID = remote.activity:getLinkActivity(self.info.type)
			local linkId = self.info.link or shortcutID
			if linkId ~= nil then
				local params = nil
				if linkId == "89013" or linkId == "90022" then
					params = self.info.value2
				end
				QQuickWay:clickGoto(db:getShortcutByID(linkId), params)
			else
				app.tip:floatTip("活动目标未达成！")
			end
			return
		end
	end
	if remote.activity:checkIsActivityAward(self.info.activityId) == false then
		app.tip:floatTip("活动领奖时间已过！下次请早！")
		return
	end

	if self._activityPanel then
		self._activityPanel:getOptions().curActivityTargetId  = self.info.activityTargetId
		self._activityPanel:getOptions().curActivityTargetOffset  = list:getItemPosToTopDistance(list:getCurTouchIndex())
	end


	local activityTargetId = self.info.activityTargetId
	local activityId = self.id
	local awards = self.awards

	if self._isChooseOne then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogXuanzejiangli", 
                        options = {awards = awards,confirmText = "领  取", 
                            okCallback = function ( chooseIndexs )
								if not chooseIndexs then
									chooseIndexs = {}
								end
								local chooseIndex = chooseIndexs[1]
								
                            	if not chooseIndex or chooseIndex == 0 then
                            		app.tip:floatTip("请选择")
                            		return false
                            	end
                            
                            	local chooseAward = awards[chooseIndex]
                            	if type(chooseAward) == "table" then
	                            	local chooseAwardStr = chooseAward.id.."^"..chooseAward.count
	                            	local chooseAwards = {}
	                            	table.insert(chooseAwards, chooseAward)
	                            	return QUIWidgetActivityItem.getRewards(activityId, activityTargetId, chooseAwards,chooseAwardStr)
	                            end
	                            return true
                            end}}, {isPopCurrentDialog = false})
	else
		QUIWidgetActivityItem.getRewards(activityId, activityTargetId,awards)
	end
end

function QUIWidgetActivityItem:_onTriggerGo()
	print("QUIWidgetActivityItem:_onTriggerGo")
    app.sound:playSound("common_small")
   
	if not remote.activity:checkIsActivity(self.info.activityId) then
		app.tip:floatTip("不在活动时间段内!")
	else
		local shortcutID = remote.activity:getLinkActivity(self.info.type)
		local linkId = self.info.link or shortcutID
		if linkId ~= nil then
			local params = nil
			if linkId == "89013" or linkId == "90022" then
				params = self.info.value2
			end
			QQuickWay:clickGoto(db:getShortcutByID(linkId), params)
		end
	end
end

function QUIWidgetActivityItem:gotoRecharge( x , y, touchNodeNode, list )
	print("QUIWidgetActivityItem:gotoRecharge")
    app.sound:playSound("common_small")
	if self._activityPanel then
		self._activityPanel:getOptions().curActivityTargetId  = self.info.activityTargetId
		self._activityPanel:getOptions().curActivityTargetOffset  = list:getItemPosToTopDistance(list:getCurTouchIndex())
	end

	if not remote.activity:checkIsActivity(self.info.activityId) then
		app.tip:floatTip("不在活动时间段内!")
		return
	end
	
	if ENABLE_CHARGE() then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
	end
end

--describe：onEnter 
function QUIWidgetActivityItem:onEnter()
	--代码
	self._isExit = true
end

--describe：onExit 
function QUIWidgetActivityItem:onExit()
	--代码
	self._isExit = nil
end



return QUIWidgetActivityItem