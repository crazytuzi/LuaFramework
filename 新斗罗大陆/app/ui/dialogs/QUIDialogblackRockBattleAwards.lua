local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogblackRockBattleAwards = class("QUIDialogblackRockBattleAwards", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

function QUIDialogblackRockBattleAwards:ctor(options)
	local ccbFile = "ccb/Dialog_Black_mountain_jssl.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerNext", callback = handler(self, self._onTriggerNext)},
        {ccbCallbackName = "onTriggerDouble", callback = handler(self, self._onTriggerDouble)},
        {ccbCallbackName = "onTriggerNotGet", callback = handler(self,self._onTriggerNotGet)},
	}
	QUIDialogblackRockBattleAwards.super.ctor(self,ccbFile,callBacks,options)

    CalculateUIBgSize(self._ccbOwner.ly_bg)

	self._callBack = options.callBack
	self._awards = options.awards
	self._endScore = options.endScore
	self._info = options.info
	self._awardsId = options.sendId
	self._giveAward = options.giveAward
	self._allProgress = options.allProgress
	self._isPlayerRecall = options.isPlayerRecall
	local totalCount = 0
	if options.giveAward == true then
		for index,award in ipairs(self._awards) do
			local item = QUIWidgetItemsBox.new()
	        item:setPromptIsOpen(true)
			item:setGoodsInfo(award.id, award.typeName, award.count)
			if self._ccbOwner["item"..index] ~= nil then
				self._ccbOwner["item"..index]:addChild(item)
			end
		end
		totalCount = #self._awards
		if self._endScore > 0 then
			totalCount = totalCount + 1
			local item = QUIWidgetItemsBox.new()
			if self._ccbOwner["item"..totalCount] ~= nil then
				self._ccbOwner["item"..totalCount]:addChild(item)
			end
			item:setColor("orange")
	        item:setPromptIsOpen(true)
			item:setGoodsInfo(nil, ITEM_TYPE.BLACKROCK_INTEGRAL, self._endScore)
		end
	    totalCount = math.min(5, totalCount)
	    local gap = 71
	    self._ccbOwner.node_awards_item:setPositionX(self._ccbOwner.node_awards_item:getPositionX() - (totalCount - 1) * gap / 2)
	end

	if self._isPlayerRecall then
		local node = self._ccbOwner["item"..totalCount]
		if node then
	        local sp = CCSprite:create("ui/dl_wow_pic/sp_comeback.png")
	        sp:setAnchorPoint(ccp(0.5, 0.5))
	        sp:setPositionX(100)
	        sp:setPositionY(0)
	        node:addChild(sp)
       	end
    end

    self._ccbOwner.node_no:setVisible(not (totalCount > 0))
    if totalCount <= 0 then
    	self._ccbOwner.node_btn_next:setPositionX(0)
    	self._ccbOwner.tf_next:setString("确 定")
		self._ccbOwner.node_btn_double:setVisible(false)
		self._ccbOwner.node_btn_notget:setVisible(false)
    end
    self._costToken = QStaticDatabase:sharedDatabase():getConfigurationValue("blackrock_buy_double_rewards") or "免费"
    self._ccbOwner.tf_costToken:setString(self._costToken)
	--计算星星的个数
	local passInfo = {}
	local starCount = 0 
	for _,progress in ipairs(self._allProgress) do
		if progress.isWin == true then
			starCount = starCount + 1
		end
		passInfo[progress.memberId] = {isWin = progress.isWin, pos = progress.memberPos}
	end
	for i=1,3 do
		self._ccbOwner["sp_star_done_"..i]:setVisible(i <= starCount)
	end

    if self._info.leader ~= nil then
    	local passInfo = passInfo[self._info.leader.userId]
    	local fighterWidget = self:generateFighter(self._info.leader, passInfo.isWin)
		self._ccbOwner["hero_node"..passInfo.pos]:addChild(fighterWidget)
    end

    if self._info.member1 ~= nil then
    	local passInfo = passInfo[self._info.member1.userId]
    	local fighterWidget = self:generateFighter(self._info.member1, passInfo.isWin)
		self._ccbOwner["hero_node"..passInfo.pos]:addChild(fighterWidget)
    end  

    if self._info.member2 ~= nil then
    	local passInfo = passInfo[self._info.member2.userId]
    	local fighterWidget = self:generateFighter(self._info.member2, passInfo.isWin)
		self._ccbOwner["hero_node"..passInfo.pos]:addChild(fighterWidget)
    end 
	
  	self._audioHandler = app.sound:playSound("battle_complete")
    audio.pauseBackgroundMusic()
    self:getScheduler().performWithDelayGlobal(function()
    	audio.resumeBackgroundMusic()
    	end, 6)
	audio.preloadSound("common_star")
	local common_star_hdl = nil
	local additional_latency = (device.platform == "android") and 0.23 or 0
	for i=1,3,1 do
		if i <= starCount then
			if i == 1 then
				common_star_hdl = app.sound:playSound("common_star")
			else
				local timeHandler = self:getScheduler().performWithDelayGlobal(function ()
					if common_star_hdl then
						app.sound:stopSound(common_star_hdl)
					end
					common_star_hdl = app.sound:playSound("common_star")
				end, additional_latency + 0.30*(i-1))
			end
		end
	end

	if starCount == 3 then
		self:getScheduler().performWithDelayGlobal(function()
			q.shakeScreen(8, 0.1)
		end, 7/30)
		self:getScheduler().performWithDelayGlobal(function()
			q.shakeScreen(8, 0.1)
		end, 14/30)
		self:getScheduler().performWithDelayGlobal(function()
			q.shakeScreen(8, 0.1)
		end, 21/30)
	elseif starCount == 2 then
		self:getScheduler().performWithDelayGlobal(function()
			q.shakeScreen(8, 0.1)
		end, 7/30)
		self:getScheduler().performWithDelayGlobal(function()
			q.shakeScreen(8, 0.1)
		end, 14/30)
	elseif starCount == 1 then
		self:getScheduler().performWithDelayGlobal(function()
			q.shakeScreen(8, 0.1)
		end, 7/30)
	end

	self._isEnd = false
	self:getScheduler().performWithDelayGlobal(function ()
		self._isEnd = true
	end, 2)
end

function QUIDialogblackRockBattleAwards:generateFighter(fighter, isWin)
	local widget = QUIWidget.new("Widget_Black_mountain_jssl.ccbi")

	widget._ccbOwner.node_pass:setVisible(isWin)
	widget._ccbOwner.node_fail:setVisible(not isWin)

	local num,uint = q.convertLargerNumber(fighter.topnForce or 0)
	widget._ccbOwner.tf_force:setString(num..(uint or ""))
	
    local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(tonumber(fighter.topnForce),true)
	local color = string.split(fontInfo.force_color, ";")
	widget._ccbOwner.tf_force:setColor(ccc3(color[1], color[2], color[3]))	

	widget._ccbOwner.tf_name:setString("LV."..fighter.level.." "..fighter.name)

	local avatar = QUIWidgetAvatar.new(fighter.avatar)
	avatar:setSilvesArenaPeak(fighter.championCount)
	widget._ccbOwner.node_head:addChild(avatar)

	if not isWin then
		makeNodeFromNormalToGray(widget._ccbOwner.hero_node)
	end

	return widget
end

-- function QUIDialogblackRockBattleAwards:_backClickHandler()
-- 	self:viewAnimationOutHandler()
-- end

function QUIDialogblackRockBattleAwards:_onTriggerNext(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_next) == false then return end
	if self._isEnd then
        local awards = {}
        for index,value in ipairs(self._awards) do
            table.insert(awards, {id = value.id or value.typeName, typeName = value.typeName, count = value.count})
        end
        if self._endScore > 0 then
            table.insert(awards, {id = nil, typeName = ITEM_TYPE.BLACKROCK_INTEGRAL, count = self._endScore})
        end
        --像后端请求
        remote.blackrock:blackRockDoTeamFightEndRequest(self._awardsId,false,false,function(sucessData)
        	if self:safeCheck() then
				if self._giveAward == true then
		            local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
		            options = {awards = awards,callBack = function()
		                self:viewAnimationOutHandler()
		            end}},{isPopCurrentDialog = false} )
		            dialog:setTitle("恭喜你获得通关奖励")
		        else
		        	self:viewAnimationOutHandler()
		        end
	    	end
        end,function(failData)
            -- body
        end)

		-- remote.blackrock:blackRockDoTeamFightEndRequest(self._awardsId,false)
		-- self:viewAnimationOutHandler()
	end
end

function QUIDialogblackRockBattleAwards:_onTriggerDouble(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_double) == false then return end
	if self._isEnd then
        if remote.user.token < tonumber(self._costToken) then
            app:vipAlert({textType = VIPALERT_TYPE.NO_TOKEN}, false)
            return
        end		
        local awards = {}
        for index,value in ipairs(self._awards) do
            table.insert(awards, {id = value.id or value.typeName, typeName = value.typeName, count = value.count*2})
        end
        if self._endScore > 0 then
            table.insert(awards, {id = nil, typeName = ITEM_TYPE.BLACKROCK_INTEGRAL, count = self._endScore*2})
        end
        --像后端请求
        remote.blackrock:blackRockDoTeamFightEndRequest(self._awardsId,true,false,function(sucessData)
            local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
            options = {awards = awards,callBack = function()
                self:viewAnimationOutHandler()
            end}},{isPopCurrentDialog = false} )
            dialog:setTitle("恭喜你获得通关奖励")
        end,function(failData)
        end)
	end
end

function QUIDialogblackRockBattleAwards:_onTriggerNotGet(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_notget) == false then return end
	if self._isEnd then
		remote.blackrock:blackRockDoTeamFightEndRequest(self._awardsId,false,true,function(sucessData)
            self:viewAnimationOutHandler()
        end,function(failData)
        end)

	end
end

function QUIDialogblackRockBattleAwards:viewAnimationOutHandler()
	local callBack = self._callBack
	self:popSelf()
	if callBack ~= nil then
		callBack()
	end
end

return QUIDialogblackRockBattleAwards