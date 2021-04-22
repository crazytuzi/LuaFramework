--
-- 版更登录活动专用的widget
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityVerChangeLoginClient = class("QUIWidgetActivityVerChangeLoginClient", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetQlistviewItem = import(".QUIWidgetQlistviewItem")
local QListView = import("...views.QListView")

function QUIWidgetActivityVerChangeLoginClient:ctor(options)
	local ccbFile = "Widget_Activity_Ver_Change_Login_Client.ccbi"
	QUIWidgetActivityVerChangeLoginClient.super.ctor(self,ccbFile,nil,options)
end

----------------------------------------
---接口部分

-- 设置信息
function QUIWidgetActivityVerChangeLoginClient:setInfo(info, activityPanel, startAt)
	self._isChooseOne = false
	self._activityPanel = activityPanel
	self.info = info
	self.awards = {}
	self.haveNum = remote.activity:getTypeNum(info) or 0

	self._ccbOwner.tf_name:setString(self.info.description or "")
	local haveNum = self.haveNum > self.info.value and self.info.value or self.haveNum
	self._ccbOwner.tf_num:setString("进度: "..haveNum.."/"..self.info.value)


	self._ccbOwner.node_btn:setVisible(false)
	self._ccbOwner.notTouch:setVisible(false)
	self._ccbOwner.tf_btn:setString("领  取")
	if q.serverTime() * 1000 < (startAt or 0) then
		self._ccbOwner.notTouch:setString("明日开启")
		self._ccbOwner.notTouch:setVisible(true)
	elseif self.info.completeNum == 2 then
		makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
		self._ccbOwner.node_btn:setVisible(true)
	elseif self.info.completeNum == 1 then 
		self._ccbOwner.notTouch:setVisible(true)
	end
	self._ccbOwner.sp_ishave:setVisible(self.info.completeNum == 3)

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

	self:_initListView()
end

-- 获取内容尺寸
function QUIWidgetActivityVerChangeLoginClient:getContentSize()
	return self._ccbOwner.cellSize:getContentSize()
end

-- 给父级容器的listview注册使用，垂直和水平滑动分开
function QUIWidgetActivityVerChangeLoginClient:onTouchListView( event )
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

-- 给父级容器的listview注册使用，当点击领取按钮时触发
function QUIWidgetActivityVerChangeLoginClient:_onTriggerConfirm(x , y, touchNodeNode, list)
    app.sound:playSound("common_small")
	if self.info.completeNum == 3 then
		return
	end
	if self.info.completeNum ~= 2 then
		if not remote.activity:checkIsActivity(self.info.activityId) then
			app.tip:floatTip("不在活动时间段内!")
			return
		else
			app.tip:floatTip("活动目标未达成！")
			return
		end
	end
	if remote.activity:checkIsActivityAward(self.info.activityId) == false then
		app.tip:floatTip("活动领奖时间已过！下次请早！")
		return
	end

	local doGetRewards = function(activityId, activityTargetId, awards, params)
		app:getClient():activityCompleteRequest(activityId, activityTargetId, params, nil, function ()
			local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
			  options = {awards = awards}},{isPopCurrentDialog = false} )
		  dialog:setTitle("恭喜您获得活动奖励")
		  remote.activity:setCompleteDataById(activityId, activityTargetId)
	  end)
	  return true
	end

	local activityTargetId = self.info.activityTargetId
	local activityId = self.info.activityId
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
	                            	return doGetRewards(activityId, activityTargetId, chooseAwards,chooseAwardStr)
	                            end
	                            return true
                            end}}, {isPopCurrentDialog = false})
	else
		doGetRewards(activityId, activityTargetId,awards)
	end
end




----------------------------------------
---私有部分

-- 设置道具的列表
function QUIWidgetActivityVerChangeLoginClient:_initListView()
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
	            self:_setItemInfo(item,data,index)

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
			spaceX = 20,
	        totalNumber = #self._data,
	    }  
    	self._listView = QListView.new(self._ccbOwner.itemsListView,cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end 
end

-- 设置列表中的itemBox
function QUIWidgetActivityVerChangeLoginClient:_setItemInfo( item, data ,index)
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


return QUIWidgetActivityVerChangeLoginClient