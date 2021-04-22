--
-- Kumo.Wang
-- 新功能預告主界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTrailer = class("QUIDialogTrailer", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetTrailer = import("..widgets.QUIWidgetTrailer")
local QUIWidgetTrailerCell = import("..widgets.QUIWidgetTrailerCell")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QRichText = import("...utils.QRichText")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QQuickWay = import("...utils.QQuickWay")

function QUIDialogTrailer:ctor(options)
	local ccbFile = "ccb/Dialog_Trailer.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
		{ccbCallbackName = "onTriggerGradePakge", callback = handler(self, self._onTriggerGradePakge)},
	}
	QUIDialogTrailer.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page then
		page:setManyUIVisible()
		page.topBar:showWithArchaeology()
	end
	
    CalculateUIBgSize(self._ccbOwner.node_bg, 1280)

	if options then
		self._guideType = options.guideType
		self._curTaskIconIndex = options.curTaskIconIndex or 0
	end

	self._isTaskUnlock = false -- 任務是否開啟
	self._isTaskComplete = false -- 任務是否完成
	self._isTaskDone = false -- 任務獎勵是否領取

	self._taskIconData = {}
	self._taskDetailData = {}
	self._taskRewardData = {}
	self._taskOutputData = {}

	self:_init()
end

function QUIDialogTrailer:viewDidAppear()
	QUIDialogTrailer.super.viewDidAppear(self)
	self:addBackEvent()

    self._trailerProxy = cc.EventProxy.new(remote.trailer)
    self._trailerProxy:addEventListener(remote.trailer.EVENT_UPDATE, handler(self, self._eventHandler))
    self._trailerProxy:addEventListener(remote.trailer.EVENT_TASK_UPDATE, handler(self, self._eventHandler))
    self._trailerProxy:addEventListener(remote.trailer.EVENT_TASK_UPDATE_BY_DIALOG, handler(self, self._eventHandlerToRequest))

	remote.trailer:userLevelGoalGetInfoRequest(false, function()
		if self:safeCheck() then
			self:_init()
		end
	end)

end

function QUIDialogTrailer:_eventHandlerToRequest(event)
	print("QUIDialogTrailer:_eventHandlerToRequest")
	remote.trailer:userLevelGoalGetInfoRequest(false, function()
	end)
end

function QUIDialogTrailer:viewWillDisappear()
	QUIDialogTrailer.super.viewWillDisappear(self)
	self:removeBackEvent()

	self._trailerProxy:removeAllEventListeners()
	print("QUIDialogTrailer:viewWillDisappear")
	if self._leftScheduler ~= nil then
        scheduler.unscheduleGlobal(self._leftScheduler)
        self._leftScheduler = nil
    end
    if self._rightScheduler ~= nil then
        scheduler.unscheduleGlobal(self._rightScheduler)
        self._rightScheduler = nil
    end
end

function QUIDialogTrailer:_eventHandler(event)
	print("QUIDialogTrailer:_eventHandler() ", event.name)
	if event.name == remote.trailer.EVENT_UPDATE or event.name == remote.trailer.EVENT_TASK_UPDATE then
		if self._curTaskIconIndex ~= 0 then
	    	local curItem = self._taskIconListView:getItemByIndex(self._curTaskIconIndex)
	    	if curItem then
	    		curItem:updateInfo()
		    end
	    end
	    self:_updateTaskDetail()
		self:_updateRewardBtn()
	end
end

function QUIDialogTrailer:_init()
	if self._guideType == LEVEL_GOAL.MAIN_MENU then
	    -- QSetDisplayFrameByPath(self._ccbOwner.guide_icon, "ui/"..guideInfo.icon)
	    self:_initTaskIcon()
	end
end

function QUIDialogTrailer:_initTaskIcon()
	local showLevel = remote.user.level + 6
	if showLevel < 19 then
		self._noLeftAndRight = true
		self._ccbOwner.node_btn_right:setVisible(false)
		self._ccbOwner.node_btn_left:setVisible(false)
		showLevel = 19
	end
	self._taskIconData = {}
	self._taskIconData = remote.trailer:getConfigListByLevel(showLevel, self._guideType)
	table.sort(self._taskIconData, function(a, b)
			if a.closing_condition ~= b.closing_condition then
				return a.closing_condition < b.closing_condition
			else
				return a.id < b.id
			end
		end)

	if self._curTaskIconIndex == 0 then
		local firstLockIndex = 0
		for index, config in ipairs(self._taskIconData) do
			local isTaskUnlock = false -- 任務是否開啟
			local isTaskComplete = false -- 任務是否完成
			local isTaskDone = false -- 任務獎勵是否領取

			isTaskUnlock = remote.user.level >= config.closing_condition
			if not isTaskUnlock and firstLockIndex == 0 then
				firstLockIndex = index
			end
			if config and config.unlock_task then
				-- 解鎖型任務
				if app.unlock:checkLock(config.unlock_task) then
					isTaskComplete = true
					isTaskDone = remote.trailer:isDoneByConfigId(config.id)
				end
			elseif config and config.tasks then
				-- 多任務列表
				local taskDetailData = string.split(config.tasks, ";")
				isTaskComplete = true
				for _, taskId in ipairs(taskDetailData) do
					local progress = remote.trailer:getTaskProgressByTaskId(taskId)
					local config = remote.trailer:getTaskConfigByTaskId(taskId)
					-- print(index, taskId, progress, config.num)
					if progress < tonumber(config.num) then
						isTaskComplete = false
					end
				end
				if isTaskComplete then
					isTaskDone = remote.trailer:isDoneByConfigId(config.id)
				end
			end

			if isTaskComplete and not isTaskDone and self._curTaskIconIndex == 0 then
				-- 首先，自动指向第一个可领取奖励的活动
				self._curTaskIconIndex = index
				break
			end
		end
		if self._curTaskIconIndex == 0 and firstLockIndex ~= 0 then
			-- 其次，自动指向第一个未开启的活动
			self._curTaskIconIndex = firstLockIndex
		elseif self._curTaskIconIndex == 0 then
			-- 最后，自动指向最后一个活动
			self._curTaskIconIndex = #self._taskIconData
		end
	end
	-- QPrintTable(self._taskIconData)
	self:_initTaskIconListView()
end

function QUIDialogTrailer:_initTaskIconListView()
	local _scrollEndCallBack
    local _scrollBeginCallBack
    if not self._noLeftAndRight then
	    _scrollEndCallBack = function ()
	        if self._ccbView then
	            self._ccbOwner.node_btn_right:setVisible(false)
	            self._ccbOwner.node_btn_left:setVisible(true)
	        end
	    end

	    _scrollBeginCallBack = function ()
	        if self._ccbView then
	            self._ccbOwner.node_btn_right:setVisible(true)
	            self._ccbOwner.node_btn_left:setVisible(false)
	        end
	    end
	    self._ccbOwner.node_btn_right:setVisible(true)
    	self._ccbOwner.node_btn_left:setVisible(false)
    else
    	self._ccbOwner.node_btn_right:setVisible(false)
    	self._ccbOwner.node_btn_left:setVisible(false)
   	end
    
    if self._taskIconListView == nil then
        local cfg = {
            renderItemCallBack = handler(self, self._renderTaskIconItemCallBack),
            isVertical = false,
            enableShadow = false,
            spaceX = 0,
            autoCenter = true,
            ignoreCanDrag = false,
            scrollEndCallBack = _scrollEndCallBack,
            scrollBeginCallBack = _scrollBeginCallBack,
            totalNumber = #self._taskIconData
        }
        self._taskIconListView = QListView.new(self._ccbOwner.sheet_layout_task_icon, cfg)
    else
        self._taskIconListView:reload({totalNumber = #self._taskIconData})
    end

    if self._curTaskIconIndex ~= 0 then
    	self._taskIconListView:startScrollToIndex(self._curTaskIconIndex, false, 100)
    	local info = self._taskIconData[self._curTaskIconIndex]
    	if info and info.closing_condition then
			self._isTaskUnlock = remote.user.level >= info.closing_condition
    	else
    		self._isTaskUnlock = false
    	end
		self:_updateTask(self._taskIconData[self._curTaskIconIndex])
    end
end

function QUIDialogTrailer:_renderTaskIconItemCallBack(list, index, info)
	if self:safeCheck() then
        if self._leftScheduler ~= nil then
            scheduler.unscheduleGlobal(self._leftScheduler)
            self._leftScheduler = nil
        end
        if self._rightScheduler ~= nil then
            scheduler.unscheduleGlobal(self._rightScheduler)
            self._rightScheduler = nil
        end
        if not self._noLeftAndRight then
	        self._ccbOwner.node_btn_left:setVisible(list:getCurStartIndex() > 1)
	        self._ccbOwner.node_btn_right:setVisible(list:getCurEndIndex() < #self._taskIconData)
		else
			self._ccbOwner.node_btn_left:setVisible(false)
			self._ccbOwner.node_btn_right:setVisible(false)
		end
    end

    local isCacheNode = true
    local data = self._taskIconData[index]
    local item = list:getItemFromCache()
    if not item then            
        item = QUIWidgetTrailer.new()
        isCacheNode = false
    end

	item:setInfo(data)
	item:isShowEffect(self._curTaskIconIndex == index)
    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_click", handler(self, self._taskIconClickHandler))

    return isCacheNode
end

function QUIDialogTrailer:_taskIconClickHandler( x, y, touchNode, listView )
	app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()
    if self._curTaskIconIndex == touchIndex then return end

    local preItem = listView:getItemByIndex(self._curTaskIconIndex)
    if preItem then
    	preItem:isShowEffect(false)
    end
    self._curTaskIconIndex = touchIndex
    self:getOptions().curTaskIconIndex = self._curTaskIconIndex
    local curItem = listView:getItemByIndex(touchIndex)
    if curItem then
    	curItem:isShowEffect(true)
    	self._isTaskUnlock = curItem:isUnlock()
    end
	self:_updateTask(self._taskIconData[touchIndex])
end

function QUIDialogTrailer:_updateTask(info)
	self._config = info

	self:_checkGradePackage()
	self:_updateTaskInfo()
    self:_updateTaskDetail()
    self:_updateReward()

    -- if self._isTaskUnlock then
		local trailerConfigIdList = app:getUserOperateRecord():getRecordByType("TRAILER_LEVEL_GOAL_ID") or {}
		local isRecord = false
		for _, id in ipairs(trailerConfigIdList) do
			if id == self._config.id then
				isRecord = true
			end
		end
		if not isRecord then
			table.insert(trailerConfigIdList, self._config.id)
			app:getUserOperateRecord():setRecordByType("TRAILER_LEVEL_GOAL_ID", trailerConfigIdList)
			QPrintTable(trailerConfigIdList)
		end
	-- end
end

function QUIDialogTrailer:_checkGradePackage()
	self._ccbOwner.node_gradePackage:setVisible(false)
	if not app.unlock:checkLock("UNLOCK_LEVEL_REWARD") then return end
	if self._isTaskUnlock then return end
	local tbl = remote.gradePackage:getGradePackageInfo()
	if #tbl == 0 then return end

	self._ccbOwner.node_gradePackage:setVisible(true)
	self._ccbOwner.gradePackage_tips:setVisible(remote.gradePackage:checkGradePakgePageMainRedTips())
end

function QUIDialogTrailer:_updateTaskInfo()
	self._ccbOwner.ly_img_mask:setVisible(false)
	-- img
	if self._config and self._config.pic then
		QSetDisplaySpriteByPath(self._ccbOwner.sp_img, self._config.pic)
		self._ccbOwner.sp_img:setVisible(true)
	else
		self._ccbOwner.sp_img:setVisible(false)
	end

	-- name
	if self._config and self._config.name then
		local nameStr = ""
		if self._config.name == "全大陆精英赛" then
			nameStr = "全大陆\n精英赛"
		else
			nameStr = self._config.name
		end
		self._ccbOwner.tf_name:setString(nameStr)
		self._ccbOwner.tf_name:setVisible(true)
		self._ccbOwner.tf_name:setColor(COLORS.k)
	else
		self._ccbOwner.tf_name:setVisible(false)
	end

	-- level
	if self._config and self._config.closing_condition then
		self._ccbOwner.tf_unlock_level:setString(self._config.closing_condition.."级开启")
		self._ccbOwner.tf_unlock_level:setVisible(true)
		self._ccbOwner.tf_unlock_level:setColor(COLORS.k)
	else
		self._ccbOwner.tf_unlock_level:setVisible(false)
	end

	-- shortcut_approach_new
	if self._config and self._config.shortcut_approach_new then
		self._ccbOwner.node_btn_go:setVisible(true)
		self._ccbOwner.ly_img_mask:setVisible(true)
	else
		self._ccbOwner.node_btn_go:setVisible(false)
	end

	-- desc
	if self._config and self._config.desc then
        local richText = QRichText.new(self._config.desc, 310, {stringType = 1, defaultColor = COLORS.j, defaultSize = 20, fontName = global.font_default})
        richText:setAnchorPoint(ccp(0, 0.5))
        self._ccbOwner.node_desc:removeAllChildren()
		self._ccbOwner.node_desc:addChild(richText)
		self._ccbOwner.node_desc:setVisible(true)
	else
		self._ccbOwner.node_desc:setVisible(false)
	end

	-- resource
	if self._config and self._config.resource then
		self._ccbOwner.node_output:setVisible(true)
		self:_updateOutput()
	else
		self._ccbOwner.node_output:setVisible(false)
	end
end

function QUIDialogTrailer:_updateOutput()
	self._taskOutputData = {}
	if not self._config or not self._config.resource then return end

	local resourceStrList = string.split(self._config.resource, ";")
	for _, str in ipairs(resourceStrList) do
		local itemType = ITEM_TYPE.ITEM
        if tonumber(str) == nil then
            itemType = remote.items:getItemType(str)
        end
        table.insert(self._taskOutputData, {id = tonumber(str), itemType = itemType, count = 0})
	end
	self:_initOutputListView()
end

function QUIDialogTrailer:_initOutputListView()
	if self._taskOutputListView == nil then
        local cfg = {
            renderItemCallBack = handler(self, self._renderOutputItemCallBack),
            isVertical = false,
            enableShadow = false,
            spaceX = 0,
            autoCenter = false,
            ignoreCanDrag = false,
            totalNumber = #self._taskOutputData
        }
        self._taskOutputListView = QListView.new(self._ccbOwner.sheet_layout_output_icon, cfg)
    else
        self._taskOutputListView:reload({totalNumber = #self._taskOutputData})
    end
end

function QUIDialogTrailer:_renderOutputItemCallBack(list, index, info)
	local function showItemInfo(x, y, itemBox, listView)
        app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
    end

    local isCacheNode = true
    local data = self._taskOutputData[index]
    local item = list:getItemFromCache()
    if not item then            
        item = QUIWidgetQlistviewItem.new()
        isCacheNode = false
    end
    
	local itemX = 15	
    local itemY = 15
    -- if not item._itemEffect then
    --     item._itemEffect = QUIWidget.new("ccb/effects/leiji_light.ccbi")
    --     item._itemEffect:setScale(0.6)
    --     item._itemEffect:setPosition(ccp(itemX, itemY))
    --     item._ccbOwner.parentNode:addChild(item._itemEffect)
    -- end
    -- item._itemEffect:setVisible(data.isEffect)

    if not item._itemBox then
        item._itemBox = QUIWidgetItemsBox.new()
        item._itemBox:setScale(0.3)
        item._itemBox:setPosition(ccp(itemX, itemY))
        item._ccbOwner.parentNode:addChild(item._itemBox)
        item._ccbOwner.parentNode:setContentSize(CCSizeMake(30,30))
    end
    item._itemBox:setGoodsInfo(data.id, data.itemType, data.count)
    info.item = item
    info.size = item._ccbOwner.parentNode:getContentSize()
    list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)

    return isCacheNode
end
function QUIDialogTrailer:_updateTaskDetail()
	if self._config and self._config.unlock_task then
		-- 解鎖型任務
		self._ccbOwner.node_normal_task:setVisible(false)
		self._ccbOwner.node_unlock_task:setVisible(true)
		self._ccbOwner.tf_reward_title:setString("功能开启即可领取奖励")
		self._ccbOwner.tf_reward_title:setColor(COLORS.j)

		local isRichText = false
		if isRichText then
			local richText = QRichText.new(self._config.task_desc, 360, {stringType = 1, defaultColor = COLORS.j, defaultSize = 20, fontName = global.font_default})
	        richText:setAnchorPoint(ccp(0.5, 0.5))
        	self._ccbOwner.node_unlock_task:removeAllChildren()
			self._ccbOwner.node_unlock_task:addChild(richText)
			self._ccbOwner.tf_unlock_task:setVisible(false)
		else
			self._ccbOwner.tf_unlock_task:setString(self._config.task_desc)
			self._ccbOwner.tf_unlock_task:setVisible(true)
		end
		if app.unlock:checkLock(self._config.unlock_task) then
			self._isTaskComplete = true
			self._isTaskDone = remote.trailer:isDoneByConfigId(self._config.id)
		else
			self._isTaskComplete = false
		end
	elseif self._config and self._config.tasks then
		-- 多任務列表
		self._ccbOwner.node_normal_task:setVisible(true)
		self._ccbOwner.node_unlock_task:setVisible(false)
		self._ccbOwner.tf_reward_title:setString("完成功能任务可领取奖励")
		self._ccbOwner.tf_reward_title:setColor(COLORS.j)

		self._taskDetailData = {}
		self._taskDetailData = string.split(self._config.tasks, ";")
		for _, taskId in ipairs(self._taskDetailData) do
			local progress = remote.trailer:getTaskProgressByTaskId(taskId)
			local config = remote.trailer:getTaskConfigByTaskId(taskId)
			if progress >= tonumber(config.num) then
				self._isTaskComplete = true
			else
				self._isTaskComplete = false
				break
			end
		end
		if self._isTaskComplete then
			self._isTaskDone = remote.trailer:isDoneByConfigId(self._config.id)
		end
		self:_initTaskDetailListView()
	else
		self._ccbOwner.node_normal_task:setVisible(false)
		self._ccbOwner.node_unlock_task:setVisible(false)
	end
end

function QUIDialogTrailer:_initTaskDetailListView()
	local item = QUIWidgetTrailerCell.new()
	local size = item:getContentSize() 
	local _curOriginOffset = 0
	if #self._taskDetailData == 1 then
		_curOriginOffset = size.height
	elseif #self._taskDetailData == 2 then
		_curOriginOffset = size.height/2
	end
	-- print(#self._taskDetailData, _curOriginOffset, self._taskDetailListView)
    if self._taskDetailListView == nil then
        local cfg = {
            renderItemCallBack = handler(self, self._renderTaskDetailItemCallBack),
            isVertical = true,
            enableShadow = false,
            spaceY = 0,
            curOriginOffset = _curOriginOffset,
            totalNumber = #self._taskDetailData
        }
        self._taskDetailListView = QListView.new(self._ccbOwner.sheet_layout_normal_task, cfg)
    else
        self._taskDetailListView:reload({totalNumber = #self._taskDetailData, curOriginOffset = _curOriginOffset})
    end
end

function QUIDialogTrailer:_renderTaskDetailItemCallBack(list, index, info)
    local isCacheNode = true
    local data = self._taskDetailData[index]
    local item = list:getItemFromCache()
    if not item then            
        item = QUIWidgetTrailerCell.new()
        isCacheNode = false
    end

	item:setInfo(data)
    info.item = item
    info.size = item:getContentSize()

    return isCacheNode
end

function QUIDialogTrailer:_updateReward()
	if self._config and self._config.rewards then
		self._taskRewardData = {}
		local rewardStrList = string.split(self._config.rewards, ";")
		for _, str in ipairs(rewardStrList) do
			local tbl = string.split(str, "^")
			local itemType = ITEM_TYPE.ITEM
            if tonumber(tbl[1]) == nil then
                itemType = remote.items:getItemType(tbl[1])
            end
            table.insert(self._taskRewardData, {id = tonumber(tbl[1]), itemType = itemType, count = tonumber(tbl[2])})
		end
		self:_updateRewardBtn()
		self:_initTaskRewardListView()
		self._ccbOwner.node_reward:setVisible(true)
	else
		self._ccbOwner.node_reward:setVisible(false)
	end
end

function QUIDialogTrailer:_initTaskRewardListView()
    if self._taskRewardListView == nil then
        local cfg = {
            renderItemCallBack = handler(self, self._renderTaskRewardItemCallBack),
            isVertical = false,
            enableShadow = false,
            spaceX = 0,
            autoCenter = true,
            ignoreCanDrag = false,
            totalNumber = #self._taskRewardData
        }
        self._taskRewardListView = QListView.new(self._ccbOwner.sheet_layout_reward, cfg)
    else
        self._taskRewardListView:reload({totalNumber = #self._taskRewardData})
    end
end

function QUIDialogTrailer:_renderTaskRewardItemCallBack(list, index, info)
	local function showItemInfo(x, y, itemBox, listView)
        app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
    end

    local isCacheNode = true
    local data = self._taskRewardData[index]
    local item = list:getItemFromCache()
    if not item then            
        item = QUIWidgetQlistviewItem.new()
        isCacheNode = false
    end

	local itemX = 45
    local itemY = 45
    -- if not item._itemEffect then
    --     item._itemEffect = QUIWidget.new("ccb/effects/leiji_light.ccbi")
    --     item._itemEffect:setScale(0.6)
    --     item._itemEffect:setPosition(ccp(itemX, itemY))
    --     item._ccbOwner.parentNode:addChild(item._itemEffect)
    -- end
    -- item._itemEffect:setVisible(data.isEffect)

    if not item._itemBox then
        item._itemBox = QUIWidgetItemsBox.new()
        item._itemBox:setScale(1)
        item._itemBox:setPosition(ccp(itemX, itemY))
        item._ccbOwner.parentNode:addChild(item._itemBox)
        item._ccbOwner.parentNode:setContentSize(CCSizeMake(100,100))
    end
    item._itemBox:setGoodsInfo(data.id, data.itemType, data.count)
    info.item = item
    info.size = item._ccbOwner.parentNode:getContentSize()
    list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)

    return isCacheNode
end

function QUIDialogTrailer:_updateRewardBtn()
	self._isTaskDone = remote.trailer:isDoneByConfigId(self._config.id)
	if self._isTaskDone then
		self._ccbOwner.sp_done:setVisible(true)
		self._ccbOwner.node_btn_ok:setVisible(false)
		self._ccbOwner.node_btn_go:setVisible(false)
	elseif self._isTaskComplete then
		self._ccbOwner.sp_done:setVisible(false)
		self._ccbOwner.node_btn_ok:setVisible(true)
		makeNodeFromGrayToNormal(self._ccbOwner.node_btn_ok)
		self._ccbOwner.node_btn_go:setVisible(false)
	else
		self._ccbOwner.sp_done:setVisible(false)
		-- shortcut_approach_new
		if self._config and self._config.shortcut_approach_new then
			self._ccbOwner.node_btn_ok:setVisible(false)
			self._ccbOwner.node_btn_go:setVisible(true)
		else
			self._ccbOwner.node_btn_ok:setVisible(true)
			makeNodeFromNormalToGray(self._ccbOwner.node_btn_ok)
			self._ccbOwner.node_btn_go:setVisible(false)
		end
	end

	print("QUIDialogTrailer:_updateRewardBtn()  ", self._isTaskDone, self._isTaskComplete)
end

function QUIDialogTrailer:_onTriggerOK(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_ok) == false then return end
	if e then
		app.sound:playSound("common_small")
	end
	if self._isTaskDone then
		return
	elseif self._isTaskComplete then
		remote.trailer:userLevelGoalComleteRequest(self._config.id, function(data)
				if self:safeCheck() then
					local dialog = app:alertAwards({awards = self._taskRewardData})
	            	dialog:setTitle("")
	            end
			end)
	elseif self._isTaskUnlock then
		app.tip:floatTip("当前任务未完成")
	else
		app.tip:floatTip("当前功能尚未开启，快去提升等级吧")
	end
end

function QUIDialogTrailer:_onTriggerLeft(e)
	if e then
		app.sound:playSound("common_small")
	end
	if self._taskIconListView then
        if self._leftScheduler == nil then
            self._leftScheduler = scheduler.performWithDelayGlobal(function()
                self._ccbOwner.node_btn_left:setVisible(false)
            end, 0.5)
        end
        local width = self._ccbOwner.sheet_layout_task_icon:getContentSize().width * 0.9
        self._taskIconListView:startScrollToPosScheduler(width, 0.8, false, function ()
                if self:safeCheck() then
                    if self._leftScheduler ~= nil then
                        scheduler.unscheduleGlobal(self._leftScheduler)
                        self._leftScheduler = nil
                    end
                    self._ccbOwner.node_btn_right:setVisible(true)
                end
            end, true)
    end
end

function QUIDialogTrailer:_onTriggerRight(e)
	if e then
		app.sound:playSound("common_small")
	end
	if self._taskIconListView then
        if self._rightScheduler == nil then
            self._rightScheduler = scheduler.performWithDelayGlobal(function()
                self._ccbOwner.node_btn_right:setVisible(false)
            end, 0.5)
        end
        local width = self._ccbOwner.sheet_layout_task_icon:getContentSize().width * 0.9
        self._taskIconListView:startScrollToPosScheduler(-width, 0.8, false, function ()
                if self:safeCheck() then
                    if self._rightScheduler ~= nil then
                        scheduler.unscheduleGlobal(self._rightScheduler)
                        self._rightScheduler = nil
                    end
                    self._ccbOwner.node_btn_left:setVisible(true)
                end
            end, true)
    end
end

function QUIDialogTrailer:_onTriggerGo(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_go) == false then return end
	if e then
		app.sound:playSound("common_small")
	end

	if self._config.shortcut_approach_new then
		local shortcut = remote.trailer:getShortcutById(self._config.shortcut_approach_new)
		QQuickWay:clickGoto(shortcut)
	end
end


function QUIDialogTrailer:_onTriggerGradePakge(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_gradePakge) == false then return end
	if e then
		app.sound:playSound("common_small")
	end
	local tbl = remote.gradePackage:getGradePackageInfo()
	if #tbl == 0 then
		self._ccbOwner.node_gradePackage:setVisible(false)
		return
	end
	remote.gradePackage:openDialog()
end

return QUIDialogTrailer