--
-- Kumo.Wang
-- zhangbichen主题曲活动——全服音浪
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetZhangbichenActivity = class("QUIWidgetZhangbichenActivity", QUIWidget)

local QUIViewController = import("..QUIViewController")

local QUIWidgetZhangbichenReward = import("..widgets.QUIWidgetZhangbichenReward")

function QUIWidgetZhangbichenActivity:ctor(options)
	local ccbFile = "ccb/Widget_Activity_Zhangbichen.ccbi"
	local callBacks = {
	    -- {ccbCallbackName = "onTriggerGoto", callback = handler(self, self._onTriggerGoto)},
	    {ccbCallbackName = "onTriggerSelectTab", callback = handler(self, self._onTriggerSelectTab)},
	    {ccbCallbackName = "onTriggerPlayVideo", callback = handler(self, self._onTriggerPlayVideo)},
	}
	QUIWidgetZhangbichenActivity.super.ctor(self, ccbFile, callBacks, options)

	if options then
		self._parent = options.parent
	end
    q.setButtonEnableShadow(self._ccbOwner.btn_goto)

    self._rewardBox = {}
    self._ccbOwner.tf_num:setString("0 （音浪值整点刷新）")
end

function QUIWidgetZhangbichenActivity:onEnter()
	self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)
    self._activityRoundsEventProxy:addEventListener(remote.activityRounds.ZHANGBICHEN_UPDATE, handler(self, self.refreshInfo))
end

function QUIWidgetZhangbichenActivity:onExit()
    self._activityRoundsEventProxy:removeAllEventListeners()
end

function QUIWidgetZhangbichenActivity:setInfo(info, parent)
	self._zhangbichenModel = remote.activityRounds:getZhangbichen()
	if not self._zhangbichenModel then return end

	self._parent = parent

	-- 初始化进度条
	if not self._percentBarClippingNode then
		self._totalStencilPosition = self._ccbOwner.sp_progress_bar:getPositionX() -- 这个坐标必须sp_progress_bar节点的锚点为(0, 0.5)
		self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_progress_bar)
		self._totalStencilWidth = self._ccbOwner.sp_progress_bar:getContentSize().width * self._ccbOwner.sp_progress_bar:getScaleX()
	end

	self._ccbOwner.node_reward:removeAllChildren()
    local rewardDataList = self._zhangbichenModel:getRewardDataList()
    self._maxExpectation = tonumber(rewardDataList[#rewardDataList].expectation)
	for index, data in ipairs(rewardDataList) do
		local box = QUIWidgetZhangbichenReward.new()
		box:setInfo(data)
		local posX = (self._totalStencilPosition + self._totalStencilWidth) * tonumber(data.expectation) / self._maxExpectation
		box:setPosition(ccp(posX, 0))
		box:addEventListener(QUIWidgetZhangbichenReward.EVENT_CLICK, handler(self, self._onBoxClicked))
		self._ccbOwner.node_reward:addChild(box)
		self._rewardBox[tostring(data.id)] = box
	end

	local timeStr = ""
    if info.permanent == true then
        timeStr = "永久有效"
    else
        local startTimeTbl = q.date("*t", (info.start_at or 0)/1000)
        local endTimeTbl = q.date("*t", (info.end_at or 0)/1000)
        timeStr = string.format("%d月%d日%02d:%02d～%d月%d日%02d:%02d", 
            startTimeTbl.month, startTimeTbl.day, startTimeTbl.hour, startTimeTbl.min, 
            endTimeTbl.month, endTimeTbl.day, endTimeTbl.hour, endTimeTbl.min)
    end
    self._ccbOwner.tf_time:setString(timeStr)

    self._ccbOwner.tf_desc:setString(info.description or "")

	self:refreshInfo()
end

function QUIWidgetZhangbichenActivity:refreshInfo()
	if self._ccbView then
		local serverInfo = self._zhangbichenModel:getServerInfo()
		if not serverInfo then return end

		self._ccbOwner.tf_num:setString((serverInfo.currNum or 0).." （音浪值整点刷新）")

		local stencil = self._percentBarClippingNode:getStencil()
	    local curProportion = (tonumber(serverInfo.currNum) or 0) / self._maxExpectation
	    if curProportion > 1 then curProportion = 1 end
	    stencil:setPositionX(-self._totalStencilWidth + curProportion * self._totalStencilWidth)

	    local tbl = {}
		for _, id in ipairs(serverInfo.rewardIds or {}) do
			tbl[tostring(id)] = true
		end
	    for id, box in pairs(self._rewardBox) do
	    	box:isGet(tbl[tostring(id)])
	    	box:refreshInfo()
	    end
   	end
end


function QUIWidgetZhangbichenActivity:_onBoxClicked(e)
	if self._ccbView then
		if not self._zhangbichenModel then return end

		local serverInfo = self._zhangbichenModel:getServerInfo()
	    local rewardIdDic = {}
		for _, id in ipairs(serverInfo.rewardIds or {}) do
			rewardIdDic[tostring(id)] = true
		end

		local box = e.box
		local info = e.info
		if not rewardIdDic[tostring(info.id)] then
			local awards = {}
			local tbl = string.split(info.rewards, "^")
			if tbl and #tbl > 0 then
				local itemId = tonumber(tbl[1])
				local itemCount = tonumber(tbl[2])
				local itemType = ITEM_TYPE.ITEM
				if not itemId then
					itemType = tbl[1]
				end
				table.insert(awards, {id = itemId, typeName = itemType, count = itemCount})
			end

			self._zhangbichenModel:zhangbichenFormalScoreRewardRequest(info.id, function(data)
					if data and data.prizes then
						awards = {}
						for _, value in ipairs(data.prizes) do 
							table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
						end
					end
			        app:alertAwards({awards = awards, title = "恭喜您获得音浪奖励"})
				end)
		end
	end
end

function QUIWidgetZhangbichenActivity:_onTriggerGoto()
    app.sound:playSound("common_small")
    local url = ""
    if url ~= "" then
		if app:isNativeLargerEqualThan(1, 4, 5) then
			app:openURLIngame(url)
		else
	        device.openURL(url)
		end
	end
end

function QUIWidgetZhangbichenActivity:_onTriggerPlayVideo()
    app.sound:playSound("common_small")
    local path = "res/video/musicvideo.mp4"
    if QCheckFileIsExist(path) then
    	local cfg = {src = path}
    	if self._parent then
    		self._parent:enableTouchSwallowTop()
    	end
    	app.sound:stopMusic()
    	app:playMp4(cfg, function()
    		if self._ccbView then
    			if self._parent then
		    		self._parent:disableTouchSwallowTop()
		    	end
		    	app.sound:playMusic("main_interface")
    		end
		end)
    else
        device.openURL("https://v.qq.com/x/page/t0959mstvcj.html")
    	-- app.tip:floatTip("请前往应用商店，下载最新版本")
    end 
end

function QUIWidgetZhangbichenActivity:_onTriggerSelectTab()
	if not self._zhangbichenModel or not self._parent then return end

	app.sound:playSound("common_small")
	if self._parent then
		self._parent.jumpTo(self._parent, self._zhangbichenModel.yuyinniaoniaoActivityId)
	end
end

return QUIWidgetZhangbichenActivity