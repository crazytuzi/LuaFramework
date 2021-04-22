


local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMysteryStorePerview = class("QUIDialogMysteryStorePerview", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
function QUIDialogMysteryStorePerview:ctor(options)
	local ccbFile = "ccb/Dialog_MysteryStore_Perview.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
    }
    
    QUIDialogMysteryStorePerview.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	q.setButtonEnableShadow(self._ccbOwner.btn_go)
	self.isAnimation = true --是否动画显示
	self._themeId = remote.activity.THEME_ACTIVITY_QIANSHITANGSAN
	self._activityId = options.activityId or 0
	self._callBack = options.callback
    self._isEnd = false
    self._timeScheduler = scheduler.performWithDelayGlobal(function()
            self._isEnd = true
        end, 1.5)
	self._fun = nil

end

function QUIDialogMysteryStorePerview:viewDidAppear()
	QUIDialogMysteryStorePerview.super.viewDidAppear(self)
	self:handleData()
	self:initListView()
	self:setInfo()
end

function QUIDialogMysteryStorePerview:viewWillDisappear()
  	QUIDialogMysteryStorePerview.super.viewWillDisappear(self)
    if self._timerScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._timerScheduler)
    	self._timerScheduler = nil
    end
end

function QUIDialogMysteryStorePerview:viewAnimationInHandler()
	--代码
	self:initListView()
end

function QUIDialogMysteryStorePerview:handleData()
	self._items= {}

	local activities = remote.activity:getActivityByTheme(self._themeId)
	self._activity = activities[1] or {}
	for k,v in pairs(activities or {}) do
		if v.activityId == self._activityId then
			self._activity = v
			break
		end
	end
	if q.isEmpty(self._activity) then return end 
	self._activityId = self._activity.activityId

	remote.activity:resetMysteryStoreActivityPromptTime(self._activityId)

	for i,target in ipairs(self._activity.targets or {} ) do
		if tonumber(target.type) == tonumber(remote.activity.ACTIVITY_TARGET_TYPE.USE_TO_SHOW_AWARD) then
			local awardsVec = {}
			remote.items:analysisServerItemBySperate(target.awards ,awardsVec,"#")
			for k,v in pairs(awardsVec) do
				if target.effectItemIdList then
					for i,effectId in ipairs(target.effectItemIdList or {}) do
						if effectId == v.id then
							v.effect = true
							break
						end
					end
					table.insert(self._items,v)
				else
					table.insert(self._items,v)
				end
			end
		end
	end

	-- QPrintTable(self._items)
end

function QUIDialogMysteryStorePerview:setInfo()
	self._ccbOwner.tf_during_time:setString("")
	self._ccbOwner.tf_endTime:setString("")

	if q.isEmpty(self._activity) then return end 

	local startTimeTbl = q.date("*t", (self._activity.start_at or 0)/1000)
    local endTimeTbl = q.date("*t", (self._activity.end_at or 0)/1000)
    local timeStr = string.format("%d月%d日%02d:%02d～%d月%d日%02d:%02d", 
        startTimeTbl.month, startTimeTbl.day, startTimeTbl.hour, startTimeTbl.min, 
        endTimeTbl.month, endTimeTbl.day, endTimeTbl.hour, endTimeTbl.min)
	self._ccbOwner.tf_during_time:setString(timeStr)
	self._ccbOwner.tf_desc_behind:setPositionX(self._ccbOwner.tf_during_time:getPositionX() + self._ccbOwner.tf_during_time:getContentSize().width)



	self:handlerTimer()

end

function QUIDialogMysteryStorePerview:handlerTimer()
	if self._fun == nil then
	    self._fun = function ()
	    	local currTime = q.serverTime()
	    	local endTime =  (self._activity.end_at or 0) / 1000
	    
			endTime = endTime - currTime
			if endTime > 0 then
	    		self._ccbOwner.tf_endTime:setString(q.converFun(endTime))
	    	else
	    		if self._timerScheduler then
	    			scheduler.unscheduleGlobal(self._timerScheduler)
	    			self._timerScheduler = nil
	    		end
	    		self._ccbOwner.tf_endTime:setString("活动结束")
				app.tip:floatTip("当前活动时间已经结束")
				local arr = CCArray:create()
				arr:addObject(CCDelayTime:create(0.1))
				arr:addObject(CCCallFunc:create(function()
					self:_onTriggerClose()
				end))
				self._ccbOwner.tf_endTime:stopAllActions()
	        	self._ccbOwner.tf_endTime:runAction(CCSequence:create(arr))
	    	end
	    end
	end
	
	if self._timerScheduler == nil then
    	self._timerScheduler = scheduler.scheduleGlobal(self._fun, 1)
	end
    self._fun()
end


function QUIDialogMysteryStorePerview:initListView()
	if self._listViewLayout then
		self._listViewLayout:setContentSize(self._ccbOwner.sheet_layout:getContentSize())
		self._listViewLayout:resetTouchRect()
	end
	local num = #self._items
	local  offside = 7
	if num < 4 then 
		offside = offside + 60 * (4 - num)
	end

	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemCallBack),
	        curOriginOffset = offside,
	        contentOffsetX = 0,
	        curOffset = 0,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	spaceY = 0,
	      	spaceX = 10,
	      	isVertical = false,
	        totalNumber = #self._items,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listViewLayout:reload({totalNumber = #self._items , curOriginOffset = offside})
	end
end


function QUIDialogMysteryStorePerview:_renderItemCallBack(list, index, info )
	local function showItemInfo(x, y, itemBox, listView)
		app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
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
		item._itemBox:setScale(0.7)
		item._itemBox:setPosition(ccp(50,52.5))
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(100,105))
	end
	item._itemBox:setGoodsInfo(data.id, data.typeName, data.count)
	if data.effect then
		item._itemBox:showBoxEffect("effects/leiji_light.ccbi",true, 0, 0, 0.6)
	end
    info.item = item
    info.size = item._ccbOwner.parentNode:getContentSize()
    list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)
    return isCacheNode

end

function QUIDialogMysteryStorePerview:_onTriggerGo(event)
    app.sound:playSound("common_small")
    print("_onTriggerGo")
    self:popSelf()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMysteryStoreActivity", 
        options = { activityId = self._activityId , callback = self._callBack  }})
end

function QUIDialogMysteryStorePerview:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMysteryStorePerview:_onTriggerClose()
  	app.sound:playSound("common_close")
    if self._isEnd == false then 
        return 
    end
	self:playEffectOut()
end

function QUIDialogMysteryStorePerview:viewAnimationOutHandler()
	local callback = self._callBack
	
	self:popSelf()
	if callback then
		callback()
	end

end


return QUIDialogMysteryStorePerview