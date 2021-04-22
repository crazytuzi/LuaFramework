--[[	
	文件名称：QUIDialogActivityDivination.lua
	创建时间：2016-10-25 16:48:08
	作者：nieming
	描述：QUIDialogActivityDivination
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogActivityDivination = class("QUIDialogActivityDivination", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIWidgetItemsBox= import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

local QLogFile = import("...utils.QLogFile")
--初始化
function QUIDialogActivityDivination:ctor(options)
	local ccbFile = "Dialog_Zhanbu.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerBuyOne", callback = handler(self, QUIDialogActivityDivination._onTriggerBuyOne)},
		{ccbCallbackName = "onTriggerReset", callback = handler(self, QUIDialogActivityDivination._onTriggerReset)},
		{ccbCallbackName = "onTriggerRank", callback = handler(self, QUIDialogActivityDivination._onTriggerRank)},
		{ccbCallbackName = "onTriggerRule", callback = handler(self, QUIDialogActivityDivination._onTriggerRule)},
		{ccbCallbackName = "onTriggerScorePanel", callback = handler(self, QUIDialogActivityDivination._onTriggerScorePanel)},
		{ccbCallbackName = "onTriggerAwards00", callback = handler(self, QUIDialogActivityDivination._onTriggerAwards00)},
		{ccbCallbackName = "onTriggerAwards01", callback = handler(self, QUIDialogActivityDivination._onTriggerAwards01)},
		{ccbCallbackName = "onTriggerAwards02", callback = handler(self, QUIDialogActivityDivination._onTriggerAwards02)},
		{ccbCallbackName = "onTriggerAwards03", callback = handler(self, QUIDialogActivityDivination._onTriggerAwards03)},
		{ccbCallbackName = "onTriggerAwards10", callback = handler(self, QUIDialogActivityDivination._onTriggerAwards10)},
		{ccbCallbackName = "onTriggerAwards20", callback = handler(self, QUIDialogActivityDivination._onTriggerAwards20)},
		{ccbCallbackName = "onTriggerAwards30", callback = handler(self, QUIDialogActivityDivination._onTriggerAwards30)},
	}
	QUIDialogActivityDivination.super.ctor(self,ccbFile,callBacks,options)
	--代码

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setAllUIVisible(false)
	page:setScalingVisible(false)
	page.topBar:showWithActivityTurntable()

	if not options then
		options = {}
	end
	self._data = options.data or {}
	self._time = 0
	self._rankAwardStr = ""
	self._itemBoxs = {}


	setShadow5(self._ccbOwner.rankAwardName)
	setShadow5(self._ccbOwner.activationLabel)
	setShadow5(self._ccbOwner.activationTimes)
	setShadow5(self._ccbOwner.curServerLabel)
	setShadow5(self._ccbOwner.curServerRank)
	setShadow5(self._ccbOwner.allServerLabel)
	setShadow5(self._ccbOwner.allServerRank)
	-- setShadow5(self._ccbOwner.describleLabel)

	
	self._schedulerID = scheduler.scheduleGlobal(handler(self, self._timeUpdate), 1)
	self:render()

	self._root:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, QUIDialogActivityDivination.onFrame))
    self._root:scheduleUpdate()

    self._isInAnimation = false

    self._ccbOwner.rankAwardParent:setCascadeOpacityEnabled(true)

end


function QUIDialogActivityDivination:onFrame(  )
	-- body
	if self._dataDirty  then
		self._dataDirty = nil
		if (self._curActiveNums ~= nil and #self._curActiveNums > 0) or (self._curActiveLines ~= nil and #self._curActiveLines > 0) then
			-- QLogFile:debug("QUIDialogActivityDivination  onFrame  show effect")
			self._isInAnimation = true
			self:showEffect()
		else
			self._isInAnimation = false
			-- QLogFile:debug("QUIDialogActivityDivination  onFrame  render")
			self:render()
		end
	end

end   

function QUIDialogActivityDivination:_timeUpdate(  )
	-- body
	
	self._time = self._time - 1
	if self._time < 0 then
		self._time  = 0
	end
	self._ccbOwner.activityTime:setString(q.timeToHourMinuteSecond(self._time))
	
end


function QUIDialogActivityDivination:render( ... )
	-- body
	local curTime = q.serverTime()
	local imp = remote.activityRounds:getDivination()
	if imp then
		if imp.isOpen then
			if imp.isActivityNotEnd then
				self._time = imp.endAt - curTime
				self._ccbOwner.activityTimeLabel:setString("活动结束时间：")
			else
				self._time = imp.showEndAt - curTime
				self._ccbOwner.activityTimeLabel:setString("领奖结束时间：")
			end
			self._ccbOwner.activityTime:setString(q.timeToHourMinuteSecond(self._time))
			self._ccbOwner.activationTimes:setString(self._data.divinationScore or 0)
			local rank = imp:getCurServerRank()
			if rank ~= 0 then
				self._ccbOwner.curServerRank:setString(rank )
			else
				self._ccbOwner.curServerRank:setString("未入榜" )
			end
			rank = imp:getAllServerRank()
			if rank ~= 0 then
				self._ccbOwner.allServerRank:setString(rank )
			else
				self._ccbOwner.allServerRank:setString("未入榜" )
			end
			-- QLogFile:debug("QUIDialogActivityDivination  render  showRankAwardAndPrice")
			self:showRankAwardAndPrice(imp.rowNum)
			-- QLogFile:debug("QUIDialogActivityDivination  render  showItem")
			self:showItem()
			-- QLogFile:debug("QUIDialogActivityDivination  render  showNums")
			self:showNums()
			-- QLogFile:debug("QUIDialogActivityDivination  render  end")

		else
			app:alert({content = "该活动下线了", title = "系统提示", callback = function (  )
                -- body
                app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
            end},false,true)
		end
	end

	

end

function QUIDialogActivityDivination:showEffect(  )
	-- body
	if self._curActiveNums and #self._curActiveNums > 0 then
		for k, v in pairs(self._curActiveNums or {}) do
			local effect = QUIWidgetAnimationPlayer.new()
			local num = v.num
			local parentNode = self._ccbOwner["numParent"..v.y..v.x]
			if parentNode then
				parentNode:removeAllChildren();
				effect:playAnimation("effects/Dialog_Zhanbu_shuzidh.ccbi", function( ccbOwner, ccbView )
					-- body
					local node1 = self:createNum(num, true)
					local node2 = self:createNum(num, true)
					node1:setCascadeOpacityEnabled(true)
					node2:setCascadeOpacityEnabled(true)
					node1:setPosition(ccp(40,40))
					node2:setPosition(ccp(40,40))
					ccbOwner.num1:addChild(node1)
					ccbOwner.num1:setCascadeOpacityEnabled(true)
					ccbOwner.num2:addChild(node2)
					ccbOwner.num2:setCascadeOpacityEnabled(true)
				end,function (  )
					-- body
					local effect1 = QUIWidgetAnimationPlayer.new()
					effect1:playAnimation("effects/Dialog_Zhanbu_shuaguang.ccbi", nil, function ()
						-- body
						self._isShowNum = true
						self._curActiveNums = nil
						self._dataDirty = true
					end)
					parentNode:addChild(effect1)
					effect1:setPosition(ccp(44,40.5))
				end, false)
				parentNode:addChild(effect)
				effect:setPosition(ccp(44,40.5))
			end
		end
		return
	end

	if self._isShowNum then
		self:showNums()
		self._ccbOwner.activationTimes:setString(self._data.divinationScore or 0)
		self._isShowNum = nil
		scheduler.performWithDelayGlobal(function (  )
			-- body
			if self._appear then
				self._dataDirty = true
			end
		end, 0.4)
		return 
	end

	if self._curActiveLines and #self._curActiveLines > 0 then
		local line = self._curActiveLines[1]
		table.remove(self._curActiveLines, 1)
		local effect = QUIWidgetAnimationPlayer.new()
		local parentNode
		local ccbName 
		if line.x == 0 then
			parentNode = self._ccbOwner["numParent"..line.y..1]
			ccbName = "effects/Dialog_zhanbu_huangkuang_h.ccbi" 
		else
			parentNode = self._ccbOwner["numParent1"..line.x]
			ccbName = "effects/Dialog_zhanbu_huangkuang_v.ccbi" 
		end

		if parentNode then
			effect:playAnimation(ccbName,nil,function (  )
				-- body
				self._dataDirty = true
				if self._ccbOwner["itemEffect"..line.y..line.x] then
					self._ccbOwner["itemEffect"..line.y..line.x]:setVisible(true)
				end
			end)
			parentNode:addChild(effect)
		end
		-- effect:setPosition(ccp(32,40))
		return
	end

	self._isInAnimation = nil
	self._curActiveNums = nil
	self._curActiveLines = nil
	self._dataDirty = true
end


function QUIDialogActivityDivination:runRankAwardAction(  )
	-- body
	local imp = remote.activityRounds:getDivination()
	if imp then
		if self._maxShowID and self._maxShowIndex and self._maxShowID > 1 then
			self._maxShowIndex = self._maxShowIndex + 1 
			if self._maxShowIndex > self._maxShowID then
				self._maxShowIndex = 1
			end
			local arr = CCArray:create()
			arr:addObject(CCCallFunc:create(
				self:safeHandler(function() 
					if self._rankAwardAvatar then
						self._rankAwardAvatar:avatarPlayAnimation("common_fadeout")
					end
			end)))

			arr:addObject(CCFadeOut:create(1))
		
			arr:addObject(CCCallFunc:create(
				self:safeHandler(function() 
					self:showRankAwardAndPrice(imp.rowNum)
			end)))

			arr:addObject(CCCallFunc:create(
				self:safeHandler(function() 
					if self._rankAwardAvatar then
						self._rankAwardAvatar:avatarPlayAnimation("common_fadein")
					end
			end)))
			
			arr:addObject(CCFadeIn:create(1))
			local action = CCSequence:create(arr)
		    self._ccbOwner.rankAwardParent:runAction(action)


		    scheduler.performWithDelayGlobal(self:safeHandler(function() 
				self:runRankAwardAction()
			end), 5)
		end
	end
end


function QUIDialogActivityDivination:showRankAwardAndPrice( rowNum )
	-- body
	local imp = remote.activityRounds:getDivination()
	local temp = QStaticDatabase:sharedDatabase():getDivinationShowInfo(rowNum)

	local itemNum = remote.items:getItemsNumByID(40)
	self._ccbOwner.tokenIcon1:setVisible(false)
	self._ccbOwner.itemIcon1:setVisible(true)
	self._ccbOwner.oneTimeToken:setString(itemNum)
	self._ccbOwner.itemRedTips:setVisible(itemNum>0)

	if imp then
		self._ccbOwner.scoreRedTips:setVisible(imp:checkScoreRedTips())
	else
		self._ccbOwner.scoreRedTips:setVisible(false)
	end

	self._ccbOwner.resetToken:setString(temp.reset_cost or 0)

	
	if not self._showIDs then
		self._showIDs = string.split(temp.show_id, ";")
		self._maxShowID = #self._showIDs
		self._maxShowIndex = 1
		scheduler.performWithDelayGlobal(self:safeHandler(function() 
			self:runRankAwardAction()
		end), 5)
	end

	local awardStr = self._showIDs[self._maxShowIndex]
	self._rankAwardAvatar = nil
	if awardStr and self._rankAwardStr ~= awardStr then
		self._rankAwardStr = awardStr
		self._ccbOwner.rankAwardNode:removeAllChildren()

		local tbl = string.split(awardStr, ",")
		local ty = remote.items:getItemType(tbl[1]) or ""
		local id = tbl[2]  or ""
		if ty == ITEM_TYPE.HERO or ty == ITEM_TYPE.ZUOQI then
			local avatar = QUIWidgetHeroInformation.new()
			if ty == ITEM_TYPE.ZUOQI then
				avatar:setAvatarByHeroInfo(nil, id, 0.7)
			else
				avatar:setAvatarByHeroInfo(nil, id, 1.3)
			end
			avatar:setBackgroundVisible(false)
			avatar:setNameVisible(false)
			avatar:setStarVisible(false)
			self._rankAwardAvatar = avatar
			self._ccbOwner.rankAwardNode:addChild(avatar)
			self._ccbOwner.rankAwardNode:setPositionY(64)
			self._ccbOwner.rankAwardName:setString(avatar:getActorName())
			self._ccbOwner.rankAwardName1:setString(avatar:getActorName())
			
		elseif ty == ITEM_TYPE.ITEM then
			local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(id)
			if itemInfo then
				local itemSprite = CCSprite:create(itemInfo.icon_1 or itemInfo.icon)
				self._ccbOwner.rankAwardNode:addChild(itemSprite)
				self._ccbOwner.rankAwardNode:setPositionY(-40)
				self._ccbOwner.rankAwardName:setString(itemInfo.name)
				self._ccbOwner.rankAwardName1:setString(itemInfo.name)
			end
		elseif ty == ITEM_TYPE.GEMSTONE  then
			local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(id) or {}
			local suitInfos = QStaticDatabase:sharedDatabase():getGemstoneSuitEffectBySuitId(itemInfo.gemstone_set_index)
			if suitInfos and suitInfos[1] and suitInfos[1].name then
				self._ccbOwner.rankAwardName:setString(suitInfos[1].name or "")
				self._ccbOwner.rankAwardName1:setString(suitInfos[1].name or "")
				
			else
				self._ccbOwner.rankAwardName:setString("")
				self._ccbOwner.rankAwardName1:setString("")
			end
			local nodeOwner = {}
			local effectNode = CCBuilderReaderLoad("effects/zhanbu_fazhen.ccbi", CCBProxy:create(), nodeOwner)
			self._ccbOwner.rankAwardNode:addChild(effectNode)
			effectNode:setPositionY(-173)
			local suits =  remote.gemstone:getSuitByItemId(id)
			for index,suitInfo in ipairs(suits) do
				local imageTexture =CCTextureCache:sharedTextureCache():addImage(suitInfo.icon_1 or suitInfo.icon)
				if imageTexture then
					if nodeOwner["sprite"..index] then
						nodeOwner["sprite"..index]:setTexture(imageTexture)
					end
				end
			end
		end
	end
end

function QUIDialogActivityDivination:showItem(  )
	-- body
	if self._data.divinationInfo then
		for k ,v in pairs(self._data.divinationInfo.awards or {}) do
			local itemBox = self._itemBoxs["nodeitem"..v.YAxis..v.XAxis]
			if not itemBox then
				itemBox = QUIWidgetItemsBox.new()
				-- itemBox:setPromptIsOpen(true)
				self._itemBoxs["nodeitem"..v.YAxis..v.XAxis] = itemBox
				if self._ccbOwner["nodeitem"..v.YAxis..v.XAxis] then
					self._ccbOwner["nodeitem"..v.YAxis..v.XAxis]:addChild(itemBox)
				end
			end
			itemBox:setGoodsInfo(v.award.id, remote.items:getItemType(v.award.type),v.award.count)
			if v.YAxis == 0 and v.XAxis == 0 then
				CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/zhanbu.plist")
				local frame  = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("z_touxiangkuang.png")
				if frame then
					local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(v.award.id)
					itemBox:replaceColorFrame(frame, itemInfo)
					-- itemBox:hideSabc()
				end
				self._ccbOwner.themeIcon:setVisible(not v.isTaken)
			end
			if self._ccbOwner["isGet"..v.YAxis..v.XAxis] then
				self._ccbOwner["isGet"..v.YAxis..v.XAxis]:setVisible(v.isTaken)
			end

			if self._ccbOwner["itemEffect"..v.YAxis..v.XAxis] then
				self._ccbOwner["itemEffect"..v.YAxis..v.XAxis]:setVisible(v.isActive and not v.isTaken)
			end
		end
	end
end

function QUIDialogActivityDivination:createNum( num, isActive )
	-- body
	
	local str 
	if not isActive then
		--str = "zn_"
		str = "zhanbu_zn_"

	else
		--str = "zl_"
		str = "zhanbu_zl_"
	end
	local node = CCNode:create()
	if num < 10 then
		local frame  = QSpriteFrameByPath(QResPath(str)[num+1])
		if frame then
			local sprite = CCSprite:createWithSpriteFrame(frame)
			if sprite then
				node:addChild(sprite)
			end
		end
	else
		local num1 = math.floor(num/10)
		local num2 = num%10

		local frame1  = QSpriteFrameByPath(QResPath(str)[num1+1])
		local frame2  = QSpriteFrameByPath(QResPath(str)[num2+1])

		if frame1 then
			local sprite1 = CCSprite:createWithSpriteFrame(frame1)
			if sprite1 then
				sprite1:setPositionX(-16)
				node:addChild(sprite1)
			end

		end
		if frame2 then
			local sprite2 = CCSprite:createWithSpriteFrame(frame2)	
			if sprite2 then
				sprite2:setPositionX(16)
				node:addChild(sprite2)
			end
		end
	end
	return node
end

function QUIDialogActivityDivination:showNums(  )
	-- body

	if self._data.divinationInfo then
		for k ,v in pairs(self._data.divinationInfo.numbers or {}) do
			local parent = self._ccbOwner["numParent"..v.YAxis..v.XAxis]
			if parent then
				parent:removeAllChildren();
				if v.isActive then
	                local spriteFrame =QSpriteFrameByPath(QResPath("zhanbu_zb_d_")[2])
	                if spriteFrame then
	                	parent:setDisplayFrame(spriteFrame)
	                end 
	            else
	                local spriteFrame =QSpriteFrameByPath(QResPath("zhanbu_zb_d_")[1])

	                if spriteFrame then
	                	parent:setDisplayFrame(spriteFrame)
	                end 
				end
				local node = self:createNum(v.num, v.isActive);
				node:setPosition(ccp(44,40.5))
				parent:addChild(node)
			end
		end
	end
end


--describe：
function QUIDialogActivityDivination:_onTriggerBuyOne()
	--代码
	app.sound:playSound("common_small")

	if self._isInAnimation then
		return
	end

	local isGet,isActive = self:getAwardsByXY(0,0)
	if isActive then
		app.tip:floatTip("当前所有数字已激活！")
		return
	end

	local imp = remote.activityRounds:getDivination()
	if imp then
		local temp = QStaticDatabase:sharedDatabase():getDivinationShowInfo(imp.rowNum)
		local itemNum = remote.items:getItemsNumByID(40)
		local canBuyNum = math.floor(remote.user.token/tonumber(temp.cost))
		local maxbuyNum = canBuyNum + itemNum > temp.count_max and temp.count_max or canBuyNum + itemNum

		if maxbuyNum == 0 then
			app:vipAlert({textType = VIPALERT_TYPE.NO_TOKEN}, false)
			return
		end
		if maxbuyNum > 100 then
			maxbuyNum = 100
		end

		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDivinationBuyMultiple", 
       		options = {itemID = 40, maxNum = maxbuyNum, price = tonumber(temp.cost), data = self._data}})
	end
end

--describe：
function QUIDialogActivityDivination:_onTriggerReset()
	--代码
	app.sound:playSound("common_small")
	if self._isInAnimation then
		return
	end
	local imp = remote.activityRounds:getDivination()
	if imp then
		if not imp.isOpen or not imp.isActivityNotEnd then
			app.tip:floatTip("当前活动已结束，下次请早！")
			return 
		end

		if self._data.divinationInfo then
			for k, v in pairs(self._data.divinationInfo.awards or {}) do 
				if v.isActive and not v.isTaken then
					app.tip:floatTip("还有奖励未领取")
					return 
				end
			end
		end

		app:alert({content="重置后您的所有数字都将变成未点亮状态，所有奖励内容将重新刷新。", title="系统提示", 
	        callback=function(state)
	            if state == ALERT_TYPE.CONFIRM then
	               	imp:requestDivinationReset(function (data)
						self._data.divinationInfo = data.divinationResetResponse.divinationInfo
						self._dataDirty = true
					end)
	            end
	        end, btnDesc = {"重置"}}, false, true)
	end
end

--describe：
function QUIDialogActivityDivination:_onTriggerRank()
	--代码
	app.sound:playSound("common_small")
	if self._isInAnimation then
		return
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityTurntableRank", 
        options = {rankType = "divination", rowNum = remote.activityRounds:getDivination().rowNum}})
end

--describe：
function QUIDialogActivityDivination:_onTriggerRule()
	--代码
	
 	app.sound:playSound("common_small")
 	if self._isInAnimation then
		return
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityDivinationHelp", 
        options = {}})
end

function QUIDialogActivityDivination:getRewards( ty , value ,awards)
	-- body
	remote.activityRounds:getDivination():requestDivinationGetReward(ty, value,function ( data )
		-- body
		local oldHeros = clone(remote.herosUtil:getHaveHero())
	
    	self._data.divinationInfo = data.divinationGetAwardResponse.divinationInfo

    	local isReset = true
    	if self._data.divinationInfo then
			for k, v in pairs(self._data.divinationInfo.awards or {}) do 
				if v.isActive  or v.isTaken then
					isReset = false
					break 
				end
			end
		end
		

    	if data.divinationGetAwardResponse.divinationScore then
			self._data.divinationScore = data.divinationGetAwardResponse.divinationScore
		end

		if data.divinationGetAwardResponse.normalRank then
			self._data.normalRank = data.divinationGetAwardResponse.normalRank
		end
		if data.divinationGetAwardResponse.centerRank then
			self._data.centerRank = data.divinationGetAwardResponse.centerRank
		end
		
		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards, oldHeros = oldHeros, callBack = function (  )
    			-- body
				self._dataDirty = true
				scheduler.performWithDelayGlobal(function (  )
					-- body
					if self._appear and isReset then
						app.tip:floatTip("奖励已重置~")
					end
				end, 0.5)
	

    		end}},{isPopCurrentDialog = false} )
    	dialog:setTitle("恭喜您获得占卜奖励")
	end)

end

function QUIDialogActivityDivination:getAwardsByXY(x, y )
	-- body
	local awards = {}
	local isGet = false
	local isActive = false
	if self._data.divinationInfo then
		for k, v in pairs(self._data.divinationInfo.awards or {}) do 
			if tonumber(v.YAxis) == y and tonumber(v.XAxis) == x then
				table.insert(awards, {typeName = remote.items:getItemType(v.award.type), id = v.award.id, count = v.award.count })
				isGet = v.isTaken
				isActive = v.isActive
				
			end
		end
	end
	return isGet, isActive , awards
end

function QUIDialogActivityDivination:_onTriggerAwards00(  )
	-- bod
	if self._isInAnimation then
		return
	end
	local imp = remote.activityRounds:getDivination()
	if imp.isOpen then
		local isGet,isActive ,awards= self:getAwardsByXY(0,0)
		if not isGet and isActive then
			self:getRewards("TYPE_FINAL", 0, awards)
		elseif not isActive then
			if awards and awards[1] then
				app.tip:itemTip(awards[1].typeName, awards[1].id)
			end
		elseif isGet then
			app.tip:floatTip("奖励已领取了哟~")
		end
	end
	
end
function QUIDialogActivityDivination:_onTriggerAwards01(  )
	-- body
	if self._isInAnimation then
		return
	end
	local imp = remote.activityRounds:getDivination()
	if imp.isOpen then
		local isGet,isActive ,awards= self:getAwardsByXY(1,0)
		if not isGet and isActive then
			self:getRewards("TYPE_X", 1, awards)
		elseif not isActive then
			if awards and awards[1] then
				app.tip:itemTip(awards[1].typeName, awards[1].id)
			end
			
			
		elseif isGet then
			app.tip:floatTip("奖励已领取了哟~")
		end
	end
end
function QUIDialogActivityDivination:_onTriggerAwards02(  )
	-- body
	if self._isInAnimation then
		return
	end
	local imp = remote.activityRounds:getDivination()
	if imp.isOpen then
		local isGet,isActive,awards = self:getAwardsByXY(2,0)
		if not isGet and isActive then
			self:getRewards("TYPE_X", 2, awards)
		elseif not isActive then
			if awards and awards[1] then
				app.tip:itemTip(awards[1].typeName, awards[1].id)
			end
		elseif isGet then
			app.tip:floatTip("奖励已领取了哟~")
		end
	end
end
function QUIDialogActivityDivination:_onTriggerAwards03(  )
	-- body
	if self._isInAnimation then
		return
	end
	local imp = remote.activityRounds:getDivination()
	if imp.isOpen then
		local isGet,isActive,awards = self:getAwardsByXY(3,0)
		if not isGet and isActive then
			self:getRewards("TYPE_X", 3, awards)
		elseif not isActive then
			if awards and awards[1] then
				app.tip:itemTip(awards[1].typeName, awards[1].id)
			end
		elseif isGet then
			app.tip:floatTip("奖励已领取了哟~")
		end
	end
end
-- function QUIDialogActivityDivination:_onTriggerAwards04(  )
-- 	-- body
-- 	if self._isInAnimation then
-- 		return
-- 	end
-- 	local imp = remote.activityRounds:getDivination()
-- 	if imp.isOpen then
-- 		local isGet,isActive,awards = self:getAwardsByXY(4,0)
-- 		if not isGet and isActive then
-- 			self:getRewards("TYPE_X", 4, awards)
-- 		elseif not isActive then
-- 			if awards and awards[1] then
-- 				app.tip:itemTip(awards[1].typeName, awards[1].id)
-- 			end
-- 		elseif isGet then
-- 			app.tip:floatTip("奖励已领取了哟~")
-- 		end
-- 	end
-- end
function QUIDialogActivityDivination:_onTriggerAwards10(  )
	-- body
	if self._isInAnimation then
		return
	end
	local imp = remote.activityRounds:getDivination()
	if imp.isOpen then
		local isGet,isActive,awards = self:getAwardsByXY(0,1)
		if not isGet and isActive then
			self:getRewards("TYPE_Y", 1, awards)
		elseif not isActive then
			if awards and awards[1] then
				app.tip:itemTip(awards[1].typeName, awards[1].id)
			end
		elseif isGet then
			app.tip:floatTip("奖励已领取了哟~")
		end
	end
end
function QUIDialogActivityDivination:_onTriggerAwards20(  )
	-- body
	if self._isInAnimation then
		return
	end
	local imp = remote.activityRounds:getDivination()
	if imp.isOpen then
		local isGet,isActive ,awards= self:getAwardsByXY(0,2)
		if not isGet and isActive then
			self:getRewards("TYPE_Y", 2, awards)
		elseif not isActive then
			if awards and awards[1] then
				app.tip:itemTip(awards[1].typeName, awards[1].id)
			end
		elseif isGet then
			app.tip:floatTip("奖励已领取了哟~")
		end
	end
end
function QUIDialogActivityDivination:_onTriggerAwards30(  )
	-- body
	if self._isInAnimation then
		return
	end
	local imp = remote.activityRounds:getDivination()
	if imp.isOpen then
		local isGet,isActive,awards = self:getAwardsByXY(0,3)
		if not isGet and isActive then
			self:getRewards("TYPE_Y", 3, awards)
		elseif not isActive then
			if awards and awards[1] then
				app.tip:itemTip(awards[1].typeName, awards[1].id)
			end
		elseif isGet then
			app.tip:floatTip("奖励已领取了哟~")
		end
	end
end
-- function QUIDialogActivityDivination:_onTriggerAwards40(  )
-- 	-- body
-- 	if self._isInAnimation then
-- 		return
-- 	end
-- 	local imp = remote.activityRounds:getDivination()
-- 	if imp.isOpen then
-- 		local isGet,isActive ,awards= self:getAwardsByXY(0,4)
-- 		if not isGet and isActive then
-- 			self:getRewards("TYPE_Y", 4, awards)
-- 		elseif not isActive then
-- 			if awards and awards[1] then
-- 				app.tip:itemTip(awards[1].typeName, awards[1].id)
-- 			end
-- 		elseif isGet then
-- 			app.tip:floatTip("奖励已领取了哟~")
-- 		end
-- 	end
-- end
--describe：关闭对话框
function QUIDialogActivityDivination:close( )
	self:playEffectOut()
end


function QUIDialogActivityDivination:getIsActiveNum( data, x, y )
	-- body
	if data.divinationInfo then
		for k ,v in pairs(data.divinationInfo.numbers or {}) do
			if v.XAxis == x and v.YAxis == y then
				return v.isActive, v.num
			end
		end
	end
	return false, 0
end

function QUIDialogActivityDivination:getIsAwardsIsActive( data, x, y )
	-- body
	if data.divinationInfo then
		for k, v in pairs(data.divinationInfo.awards or {}) do 
			if v.YAxis == y and v.XAxis == x then
				return  v.isActive
			end
		end
	end

	return false

end

function QUIDialogActivityDivination:getActiveNums(newData)
	-- body
	local activeNums = {}
	local activeLines = {}

	for i = 1, 3 do
		for j = 1, 3 do

			local isOldActive = self:getIsActiveNum(self._data, i, j)
			local isNewActive,num = self:getIsActiveNum(newData, i, j)

			if isOldActive ~= isNewActive and isNewActive then
				
				table.insert(activeNums, {x = i, y = j, num = num})
			end
		end
	end

	for j = 1, 3 do
		local isOldActive = self:getIsAwardsIsActive(self._data, 0, j)
		local isNewActive = self:getIsAwardsIsActive(newData, 0, j)
		if isOldActive ~= isNewActive and isNewActive then
			table.insert(activeLines, {x = 0, y = j})
		end
	end

	for i = 1, 3 do
		local isOldActive = self:getIsAwardsIsActive(self._data, i, 0)
		local isNewActive = self:getIsAwardsIsActive(newData, i, 0)
		if isOldActive ~= isNewActive then
			table.insert(activeLines, {x = i, y = 0})
		end
	end

	self._curActiveNums = activeNums
	self._curActiveLines = activeLines
end

function QUIDialogActivityDivination:_onTriggerScorePanel()
	--代码
	if self._isInAnimation then
		return
	end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogActivityDivinationBuyScore"})
end

function QUIDialogActivityDivination:viewDidAppear()
	QUIDialogActivityDivination.super.viewDidAppear(self)
	--代码
	self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)
	self._activityRoundsEventProxy:addEventListener(remote.activityRounds.DIVINATION_UPDATE, function ( event)
		-- body
		if event.data then
			--判断 激活数字
			if event.data.divinationInfo then
				self:getActiveNums(event.data)
				self._data.divinationInfo = event.data.divinationInfo
			end
			if event.data.divinationScore then
				self._data.divinationScore = event.data.divinationScore
			end
			if event.data.normalRank then
				self._data.normalRank = event.data.normalRank
			end
			if event.data.centerRank then
				self._data.centerRank = event.data.centerRank
			end
		end
		self._dataDirty = true
	end)

	self:addBackEvent(false)
end

function QUIDialogActivityDivination:viewWillDisappear()
	QUIDialogActivityDivination.super.viewWillDisappear(self)
	--代码
	if self._activityRoundsEventProxy then
		self._activityRoundsEventProxy:removeAllEventListeners()
		self._activityRoundsEventProxy = nil
	end
	if self._schedulerID then
		scheduler.unscheduleGlobal(self._schedulerID)
		self._schedulerID = nil
	end

end

function QUIDialogActivityDivination:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	--代码
end

--describe：viewAnimationInHandler 
--function QUIDialogActivityDivination:viewAnimationInHandler()
	----代码
--end

--describe：点击Dialog外  事件处理 
function QUIDialogActivityDivination:onTriggerBackHandler()
	--代码
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogActivityDivination
