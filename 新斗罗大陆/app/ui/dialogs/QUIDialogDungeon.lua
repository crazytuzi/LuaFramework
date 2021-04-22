--
-- Author: wkwang
-- Date: 2014-08-18 14:14:49
--
local QUIDialog = import(".QUIDialog")
local QUIDialogDungeon = class("QUIDialogDungeon", QUIDialog)
local QUIWidgetEliteInfoStar = import("..widgets.QUIWidgetEliteInfoStar")
local QUIWidgetMonsterHead = import("..widgets.QUIWidgetMonsterHead")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QPromptTips = import("...utils.QPromptTips")
local QUIDialogMystoryStoreAppear = import("..dialogs.QUIDialogMystoryStoreAppear")
local QShop = import("...utils.QShop")
local QVIPUtil = import("...utils.QVIPUtil")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QDungeonArrangement = import("...arrangement.QDungeonArrangement")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIDialogBuyCount = import("..dialogs.QUIDialogBuyCount")

function QUIDialogDungeon:ctor(options)
	local ccbFile = "ccb/Dialog_EliteInfo001.ccbi";
	local callBacks = 
	{
		{ccbCallbackName = "onTriggerBuyCount", callback = handler(self, QUIDialogDungeon._onTriggerBuyCount)},
		{ccbCallbackName = "onTriggerStarInfo", callback = handler(self, QUIDialogDungeon._onTriggerStarInfo)},
		{ccbCallbackName = "onTriggerTeam", callback = handler(self, QUIDialogDungeon._onTriggerTeam)},
		{ccbCallbackName = "onTriggerQuickFightOne", callback = handler(self, QUIDialogDungeon._onTriggerQuickFightOne)},
		{ccbCallbackName = "onTriggerQuickFightOneW", callback = handler(self, QUIDialogDungeon._onTriggerQuickFightOneW)},
		{ccbCallbackName = "onTriggerQuickFightTen", callback = handler(self, QUIDialogDungeon._onTriggerQuickFightTen)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, QUIDialogDungeon._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, QUIDialogDungeon._onTriggerRight)},
		{ccbCallbackName = "onTriggerBossIntroduce", callback = handler(self, QUIDialogDungeon._onTriggerBossIntroduce)},
	}
	QUIDialogDungeon.super.ctor(self,ccbFile,callBacks,options)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page and page.__cname == "QUIPageMainMenu" then
		page:setManyUIVisible()
		page.topBar:showWithDungeon()
	end
    q.setButtonEnableShadow(self._ccbOwner.btn_boss_introduce)
	
	self.parentOptions = options.parentOptions
	self._perIndex = options.currentIndex
	self.info = options.info
	self.config = QStaticDatabase:sharedDatabase():getDungeonConfigByID(self.info.dungeon_id)
	self.targetId = options.targetId
	self.targetNum = options.targetNum
	self.isfromHeroInfo = self.parentOptions.isfromHeroInfo
	self._star = QUIWidgetEliteInfoStar.new()
	self._ccbOwner.node_star:addChild(self._star)

	self._ccbOwner.node_arrowLeft:setVisible(false)
	self._ccbOwner.node_arrowRight:setVisible(false)
	self._ccbOwner.node_word:setVisible(false)
	--记录章节的信息
	if self.info.dungeon_type == DUNGEON_TYPE.ELITE then
		self._instanceData = remote.instance:getInstancesWithUnlockAndType(DUNGEON_TYPE.ELITE)
	end

    self:checkSkipBattle()
    if remote.instance.skipBattleCount >= 2 and remote.instance.isIsBattle ~= true then
    	if self._isSpecialDungeon and remote.instance.specialDungeonTip == 0 then
    		remote.instance.specialDungeonTip = 1
    		app.tip:floatTip("当前关卡存在重要剧情，请自行体验")
    	elseif self._isSpecialDungeon == false and self._battleForceNoEnough and remote.instance.forceNoEnoughTip == 0 then
    		remote.instance.forceNoEnoughTip = 1
    		app.tip:floatTip("当前战力不满足跳过需求，请自行攻打")
    	end
    end

	self:showInfo()
	self:_setMapBg(options.ccbFile, options.pos)
	remote.nightmare:addPropToTeam()
end

function QUIDialogDungeon:_getBackPagePath(index)
	return QSpriteFrameByKey("dungeon_bg", index)
end

function QUIDialogDungeon:_getBackPagePath2(index)
	return QSpriteFrameByKey("dungeon_bg_2", index)
end

function QUIDialogDungeon:_setMapBg( ccbFile, pos )
	print("[QUIDialogDungeon] ccbFile = ", ccbFile)
	print("[QUIDialogDungeon] pos = ", pos.x, pos.y)
	if ccbFile then
		local size = self._ccbOwner.sp_map_bg:getContentSize()
		local scaleX = self._ccbOwner.sp_map_bg:getScaleX()
	    local scaleY = self._ccbOwner.sp_map_bg:getScaleY()
	    local clippingNode = CCClippingNode:create()
	    local stencil = CCLayerColor:create(ccc4(0,0,0,150), size.width, size.height)
	    stencil:setScaleX(scaleX)
	    stencil:setScaleY(scaleY)
	    stencil:ignoreAnchorPointForPosition(false)
	    stencil:setAnchorPoint(self._ccbOwner.sp_map_bg:getAnchorPoint())
	    stencil:setPosition(ccp(self._ccbOwner.sp_map_bg:getPosition()))
	    clippingNode:setStencil(stencil)

		local s, e = string.find(ccbFile, "%d+")
		local index = string.sub(ccbFile, s, e)
		print("[Kumo] QUIDialogDungeon: index = ", index)
		self._ccbOwner.sp_map_bg:setSpriteFrame(self:_getBackPagePath(tonumber(index)))
		self._ccbOwner.sp_map_bg:setAnchorPoint(0, 0.5)
		self._ccbOwner.sp_map_bg:setPosition(- size.width/2*scaleX + pos.x, pos.y)	

	    local sp_map_bg_2 = CCSprite:createWithSpriteFrame(self:_getBackPagePath2(tonumber(index)))
	    local map1Size = self._ccbOwner.sp_map_bg:getContentSize()
	    local map1ScaleX = self._ccbOwner.sp_map_bg:getScaleX()
	    sp_map_bg_2:setAnchorPoint(0, 0.5)
		sp_map_bg_2:setPosition(- size.width/2 + pos.x + map1Size.width*map1ScaleX, pos.y)	
		clippingNode:setScaleX(0.99)
		clippingNode:setScaleY(0.98)

	    local parent = self._ccbOwner.sp_map_bg:getParent()
	    self._ccbOwner.sp_map_bg:retain()
	    self._ccbOwner.sp_map_bg:removeFromParent()
	    clippingNode:addChild(self._ccbOwner.sp_map_bg)
	    clippingNode:addChild(sp_map_bg_2)

	    -- clipping monster avatar
	    if self.info.dungeon_id == "wailing_caverns_1" or self.info.dungeon_id == "yazz_1" or self.info.dungeon_id == "mh_1" then
		    clippingNode:addChild(self._avatar)
		    self._avatar:release()
		    local posX = 0
		    local posY = 0
			if self.config.position ~= nil then
				local pos = string.split(self.config.position, ",")
				posX = pos[1] or 0
				posY = pos[2] or 0
			end
			local avatarPos = self._ccbOwner.node_avatar:convertToNodeSpace(ccp(display.cx, display.cy))
			self._avatar:setPositionX(-avatarPos.x + posX)
			self._avatar:setPositionY(-avatarPos.y + posY + 43)

			if self.info.dungeon_id == "wailing_caverns_1" then
				self._eventProxy = cc.EventProxy.new(self._avatar:getAvatar():getActor())
    			self._eventProxy:addEventListener(self._avatar:getAvatar():getActor().ANIMATION_FINISHED_EVENT, function()
    					if self._eventProxy then
    						self._eventProxy:removeAllEventListeners()
							self._eventProxy = nil
						end
			            self._ccbOwner.node_word:setVisible(true)
    				end)
				-- self._avatar:getAvatar():getActor():getSkeletonView():connectAnimationEventSignal(function(eventType)
				--         if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
				            
				--         end
				--     end)
				self._avatar:getAvatar():getActor():playAnimation("attack21", false)
			else
				self._ccbOwner.node_word:setVisible(true)
			end
		else
			self._ccbOwner.node_word:setVisible(true)
			self._ccbOwner.node_avatar:addChild(self._avatar)
		    self._avatar:release()
		end

	    parent:addChild(clippingNode)
	    self._ccbOwner.sp_map_bg:release()
	end
end

function QUIDialogDungeon:viewDidAppear()
	QUIDialogDungeon.super.viewDidAppear(self)
	self.prompt = app:promptTips()
	self.prompt:addItemEventListener(self)
	self.prompt:addMonsterEventListener()
	self:addBackEvent()

    self._remoteEventProxy = cc.EventProxy.new(remote.user)
    self._remoteEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self._setQuickButtonInfo))

    self._itemsEventProxy = cc.EventProxy.new(remote.items)
    self._itemsEventProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self._itemUpdateHandler))

    local isAgain = self:getOptions().isAgain
    self:getOptions().isAgain = false
    if isAgain == true then
		self:enableTouchSwallowTop()
    	scheduler.performWithDelayGlobal(function ()
    		self:disableTouchSwallowTop()
	    	self:_onTriggerTeam()
    	end, 0)
    end
end

function QUIDialogDungeon:viewWillDisappear()
  	QUIDialogDungeon.super.viewWillDisappear(self)
 	self.prompt:removeItemEventListener()
    self.prompt:removeMonsterEventListener()
	self:removeBackEvent()

    if self._actionHandler ~= nil then
    	self._ccbOwner.node_rule:stopAction(self._actionHandler)
    end

    if self._remoteEventProxy ~= nil then
        self._remoteEventProxy:removeAllEventListeners()
    end

    if self._itemsEventProxy ~= nil then
    	self._itemsEventProxy:removeAllEventListeners()
    	self._itemsEventProxy = nil
    end
	remote.nightmare:removePropToTeam()
end

function QUIDialogDungeon:showInfo()
	self._perData = nil
	self._nextData = nil
	self._nextIndex = nil
	if self.info.dungeon_type == DUNGEON_TYPE.ELITE and self._instanceData ~= nil then
		local findSelf = false
		for index,instance in ipairs(self._instanceData) do
			for _,data in ipairs(instance.data) do
				if findSelf == true and self.info.info ~= nil and (self.info.info.lastPassAt or 0) > 0 and self._nextData == nil then
					self._nextData = data
					self._nextIndex = index
				end
				if data.dungeon_id == self.info.dungeon_id then
					findSelf = true
				end
				if findSelf == false then
					self._perData = data
					self._perIndex = index
				end
			end
		end
		self._ccbOwner.node_arrowLeft:setVisible(self._perData ~= nil)
		self._ccbOwner.node_arrowRight:setVisible(self._nextData ~= nil)
	end

	local indexNum = (self.info.number or "").." "
	self._ccbOwner.tf_title_name:setString(indexNum..self.config.name)
	local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
	
	--难度信息
	self._ccbOwner.node_difficulty:setVisible(false)
	self._recommendPower = tonumber(self.config.thunder_force or 0)
	local minPower = tonumber(self.config.commonly_lower_limit or 0)
	local maxPower = tonumber(self.config.commonly_upper_limit or 0)
	local value,unitStr = q.convertLargerNumber(self._recommendPower)
	unitStr = unitStr or ""
	self._ccbOwner.tf_pass_force:setString(value..unitStr)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/Elite_normol.plist")
	local herosInfos, count, force = remote.herosUtil:getMaxForceHeros()
	self._isEasy = false
	self._isRecommend = (not not self.config.thunder_force) and force >= self._recommendPower
	self._force = force
	if force > maxPower then
		if self.config.thunder_force then
			self._isEasy = true
		end
		self._ccbOwner.sp_difficulty:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("time_jiandan_zi.png"))
	elseif force > minPower then
		self._ccbOwner.sp_difficulty:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("time_putong_zi.png"))
	else
		self._ccbOwner.sp_difficulty:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("time_kunnan_zi.png"))
	end

	if self.info.dungeon_type == DUNGEON_TYPE.WELFARE then
		self._ccbOwner.tf_consume:setString(self.config.energy)
		self._ccbOwner.node_count:setVisible(false)
		self._ccbOwner.node_condition:setVisible(false)
		self._ccbOwner.btn_buy:setVisible(false)
		self._ccbOwner.node_star:setVisible(false)
		self._ccbOwner.node_star_info:setVisible(false)
		self._ccbOwner.node_saodang:setVisible(false)
		if self.info.dungeonState == remote.welfareInstance.YI_TONG_GUAN then
			self._ccbOwner.node_firstWinAwards:setVisible(false)
			self._ccbOwner.node_saodang_welfare:setVisible(true)

			if self.info.dungeon_type == DUNGEON_TYPE.WELFARE then
				self._ccbOwner.node_firstWinAwards:setVisible(true)
				self._ccbOwner.tf_token_num_title:setString("扫荡奖励：")

				local awardIndex = QStaticDatabase.sharedDatabase():getDungeonConfigByID(self.info.dungeon_id).drop_index
				local tokenNum = 0
				if awardIndex then
					local awards = QStaticDatabase:sharedDatabase():getLuckyDraw(awardIndex)
					tokenNum = awards.num_4 or 0
				end
					
				self._ccbOwner.tf_token_num:setString(tokenNum)
			end
		else
			self._ccbOwner.node_firstWinAwards:setVisible(true)
			self._ccbOwner.node_saodang_welfare:setVisible(false)
			if self._recommendPower > 0 then
				self._ccbOwner.node_difficulty:setVisible(true)
			end

			local fdItem = QStaticDatabase.sharedDatabase():getDungeonConfigByID(self.info.dungeon_id).fd_item
			local rewards = string.split(fdItem, ";")
			local tokenNum = 0

			for _, value in pairs(rewards) do
				local info = string.split(value, "^")
				if info[1] == "token" then
					tokenNum = info[2]
				end
			end

			self._ccbOwner.tf_token_num:setString(tokenNum)
		end
		self._ccbOwner.node_star:setVisible(false)

	else
		local isPassed = self.info.info and (self.info.info.lastPassAt or 0) or 0 -- 0 means this dungeon has not passed
		if self.info.dungeon_type == DUNGEON_TYPE.NORMAL then
			self._ccbOwner.node_count:setVisible(false)
		elseif self.info.dungeon_type == DUNGEON_TYPE.ELITE then
			self._ccbOwner.node_count:setVisible(isPassed ~= 0)
		end
		self._ccbOwner.node_firstWinAwards:setVisible(false)
		self._ccbOwner.node_saodang:setVisible(true)
		self._ccbOwner.node_saodang_welfare:setVisible(false)
		self._fightCount = remote.instance:getFightCountBydungeonId(self.info.dungeon_id)
		self._fightCount = self._fightCount > 0 and self._fightCount or 0
		self._ccbOwner.tf_consume:setString(self.config.energy)
		self._ccbOwner.tf_count:setString(self._fightCount.."/"..self.info.attack_num)
		if self._fightCount == 0 and self.info.dungeon_type == DUNGEON_TYPE.ELITE then
			self._ccbOwner.btn_buy:setVisible(true)
		else
			self._ccbOwner.btn_buy:setVisible(false)
		end

		self._ccbOwner.node_rule:setVisible(false)
		self._ccbOwner.tf_rule:setString(globalConfig.DUNGEON_STAR_README.value)

		self._isAllStar = false
		local star = 0
		if self.info.info ~= nil and tonumber(self.info.info.star) == 3 then
			self._isAllStar = true
		end 
		if isPassed > 0 then
			star = self.info.info.star or 0
		    makeNodeFromNormalToGray(self._ccbOwner["star_done1"])
		    makeNodeFromNormalToGray(self._ccbOwner["star_done2"])
		    makeNodeFromNormalToGray(self._ccbOwner["star_done3"])	

		    for i = 1,star do
		    	makeNodeFromGrayToNormal(self._ccbOwner["star_done"..i])
		    end
		else
		    makeNodeFromNormalToGray(self._ccbOwner["star_done1"])
		    makeNodeFromNormalToGray(self._ccbOwner["star_done2"])
		    makeNodeFromNormalToGray(self._ccbOwner["star_done3"])	
		end
		if isPassed ~= 0 and self._isAllStar and app.unlock:checkLock("UNLOCK_RUSH_INSTANCE") then --and self._fightCount > 0
			self._ccbOwner.node_saodang:setVisible(true)
		else
			self._ccbOwner.node_saodang:setVisible(false)
			if self._recommendPower > 0 then
				self._ccbOwner.node_difficulty:setVisible(true)
			end
		end

		self._ccbOwner.node_star_info:setVisible(false)
		self._ccbOwner.node_star:setVisible(false)

		local isShowStarInfo = remote.instance:checkDungeonIsShowStar(self.info.dungeon_id)
		if isShowStarInfo == false then
			self._ccbOwner.node_star:setVisible(true)
			self._star:showStar(star)
			self._star:stop()
		else
			self._ccbOwner.node_star_info:setVisible(true)
			local dungeonTargetConfig = QStaticDatabase:sharedDatabase():getDungeonTargetByID(self.info.dungeon_id)
			assert(dungeonTargetConfig ~= nil, string.format("dungeon_id : %s can't find in dungeon_target !", self.info.dungeon_id))
			self._ccbOwner.tf_condition:setString(dungeonTargetConfig[1].target_text or "")
		end
		self:_setQuickButtonInfo()
	end

	self:getMonsterConfig()
	self:getItemConfig()
	
	self._ccbOwner.node_reduce_effect:setVisible(false)
	if self.info.dungeon_type == DUNGEON_TYPE.NORMAL then
		--xurui:检查扫荡功能解锁提示
		self._ccbOwner.node_reduce_effect:setVisible(app.tip:checkReduceUnlokState("eliteFastBattle10"))
	end
end

function QUIDialogDungeon:_setQuickButtonInfo()
	if self.info.dungeon_type == DUNGEON_TYPE.WELFARE then
		return
	end
	local perNum = 10
	if self.info.attack_num < perNum then
		perNum = self.info.attack_num
	end
	local minimum = self._itemCount
	if self._fightCount < perNum then
		perNum = self._fightCount
	end
	local num = math.floor(remote.user.energy/self.config.energy)
	if num < perNum then
		perNum = num
	end
	if perNum == 0 then 
		perNum = 10
		if self.info.attack_num < 10 then
			perNum = 3
		end
	end
	local tenBtnTF = "扫荡"..perNum.."次"
	self._ccbOwner.tf_ten:setString(tenBtnTF)
end

function QUIDialogDungeon:_itemUpdateHandler()
	self._heroBreakNeedItems = remote.herosUtil:getAllHeroBreakNeedItem(true)
	for _,box in ipairs(self._items) do
		local itemID = box:getItemId()
	    if self._heroBreakNeedItems[tonumber(itemID)] ~= nil and self._heroBreakNeedItems[tonumber(itemID)] > 0 then
	    	box:showGreenTips(true)
	    else
	    	box:showGreenTips(false)
	    end
	end
end

--获取关卡掉落信息
function QUIDialogDungeon:getItemConfig()
	if self._items ~= nil then return end
	local index = 1
	while self._ccbOwner["node_items"..index] ~= nil do
		self._ccbOwner["node_items"..index]:removeAllChildren()
		index = index + 1
	end
	self._items = {}
	local dropItems = self.config.drop_item
	local dropItems = string.split(dropItems, ";")
	self._heroBreakNeedItems = remote.herosUtil:getAllHeroBreakNeedItem(true)
	for _,id in pairs(dropItems) do
		if db:checkItemShields(id) then
			print("屏蔽英雄ID："..id)
		elseif remote.items:getItemType(id) then
			self:_setBoxWalletInfo(id,0)
    	else
	        self:_setBoxInfo(id,ITEM_TYPE.ITEM,0)
	    end
	end
end

function QUIDialogDungeon:_setBoxWalletInfo( itemID, num )
	local walletConfig = remote.items:getWalletByType( itemID )
	if not walletConfig then return end
	local contain = self._ccbOwner["node_items"..(#self._items+1)]
	if contain == nil then return end
	local box = QUIWidgetItemsBox.new()
    -- box:setGoodsInfo(nil,ITEM_TYPE.SOULMONEY,num)
    box:setGoodsInfo(nil,walletConfig.name,num)
    box:setPromptIsOpen(true)
    if self._heroBreakNeedItems[tonumber(itemID)] ~= nil and self._heroBreakNeedItems[tonumber(itemID)] > 0 then
    	box:showGreenTips(true)
    end
    contain:addChild(box)
	table.insert(self._items, box)

end

function QUIDialogDungeon:_setBoxInfo(itemID,itemType,num)
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(itemID)
	local contain = self._ccbOwner["node_items"..(#self._items+1)]
	if contain == nil then return end
	if itemConfig == nil then return end
	local box = QUIWidgetItemsBox.new()
    box:setGoodsInfo(itemID,itemType,num)
    box:setPromptIsOpen(true)
    if self._heroBreakNeedItems[tonumber(itemID)] ~= nil and self._heroBreakNeedItems[tonumber(itemID)] > 0 then
    	box:showGreenTips(true)
    end
    contain:addChild(box)
	table.insert(self._items, box)
end

--获取怪物配置生成怪物信息
function QUIDialogDungeon:getMonsterConfig()
	if self._monster ~= nil then return end
	local index = 1
	while self._ccbOwner["node_monster"..index] ~= nil do
		self._ccbOwner["node_monster"..index]:removeAllChildren()
		index = index + 1
	end

	self._ccbOwner.node_monster:setVisible(false)
	local monsterConfig = QStaticDatabase:sharedDatabase():getMonstersById(self.config.monster_id)

	local monsterData = {}
	if monsterConfig ~= nil and #monsterConfig > 0 then
		for i,value in ipairs(monsterConfig) do
			-- TOFIX: SHRINK
			local value = q.cloneShrinkedObject(value)
			value.npc_index = i
			table.insert(monsterData, value)
		end
		table.sort(monsterData,function (a, b)
				if a.is_boss ~= b.is_boss then
					if a.is_boss == true or b.is_boss == true then
						return a.is_boss or false
					end
				end
				return a.wave > b.wave
			end)
		--过滤重复的怪物
		local tempData = {}
		local tempData2 = {}
		for _,value in pairs(monsterData) do
			local npc_id = app:getBattleRandomNpcID(self.config.monster_id, value.npc_index, value.npc_id)
			if tempData[npc_id] == nil then
				tempData[npc_id] = 1
				local clone_value = clone(value)
				clone_value.npc_id = npc_id
				table.insert(tempData2,clone_value)
			end
		end
		monsterData = tempData2
	end

	--找出第一个显示avatar的怪物
	local avatarValue = nil
	local appear = nil
	-- QPrintTable(monsterData)
	for _,value in pairs(monsterData) do
		if value.display == true then
			avatarValue = value
			break
		end
		if avatarValue == nil then
			avatarValue = value
		end
		if value.wave == 1 and (appear == nil or appear > value.appear) then
			avatarValue = value
			appear = value.appear
		end
	end
	self._monster = {}
	local count = 1
	for _,value in pairs(monsterData) do
		if count < 5 and value ~= avatarValue then
			self:generateMonster(value, self._ccbOwner["node_monster"..count], count)
			count = count + 1
		end
	end

	-- QPrintTable(avatarValue)
	local monstersConfig = QStaticDatabase.sharedDatabase():getMonstersById(avatarValue.id)
	-- QPrintTable(monstersConfig)
	for _, config in ipairs(monstersConfig) do
		if config.boss_show then
			self._bossId = avatarValue.npc_id
			self._enemyTips = config.boss_show
			self._ccbOwner.node_boss_introduce:setVisible(true)
			break
		else
			self._bossId = nil
			self._enemyTips = nil
			self._ccbOwner.node_boss_introduce:setVisible(false)
		end
	end
	print(self._bossId, self._enemyTips)

	self._ccbOwner.node_monster:setVisible(true)
	local character = QStaticDatabase:sharedDatabase():getCharacterByID(avatarValue.npc_id)
	local characterData = QStaticDatabase:sharedDatabase():getCharacterData(avatarValue.npc_id, character.data_type, avatarValue.npc_difficulty, avatarValue.npc_level)
	self._ccbOwner.sp_boss:setVisible(avatarValue.is_boss == true)
	local breakthroughLevel,color = remote.herosUtil:getBreakThrough(characterData.breakthrough)
	self._ccbOwner.tf_name:setString("LV."..characterData.npc_level.."  "..character.name)

	local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	self._ccbOwner.tf_name:setColor(fontColor)
	self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
	
	if self._avatar == nil then
		self._avatar = QUIWidgetHeroInformation.new()
		self._avatar:setInfotype("QUIDialogTeamArrangement")
    	self._avatar:retain()
	end
	local scale = self.config.boss_size or 1 
	self._avatar:setAvatar(avatarValue.npc_id, scale)
	if self.config.stars_high ~= nil then
		self._avatar:setStarPositionOffset(0, tonumber(self.config.stars_high) + 5)
	end
    self._avatar:setNameVisible(false)
    self._avatar:setBackgroundVisible(false)
    self._avatar:setStarVisible(false)
    self._avatar:setStarScale(1)
    if characterData.grade == nil then
    	self._avatar:showStar(0)
    else
    	self._avatar:showStar(characterData.grade + 1)
    end

	self._ccbOwner.tf_word:setString(self.config.description or "")
end

--生成怪物头像
function QUIDialogDungeon:generateMonster(value, contain, index)
	if contain == nil then return end
	local index = #self._monster
	local character = QStaticDatabase:sharedDatabase():getCharacterByID(value.npc_id)
	local characterData = QStaticDatabase:sharedDatabase():getCharacterData(value.npc_id, character.data_type, value.npc_difficulty, value.npc_level)
	self._monster[index] = QUIWidgetMonsterHead.new(value)
	self._monster[index]:setHero(value.npc_id)
	self._monster[index]:setStar(characterData.grade or 0)
	self._monster[index]:setBreakthrough(characterData.breakthrough or 0)
	self._monster[index]:setIsBoss(false)
	contain:addChild(self._monster[index])
end

function QUIDialogDungeon:_teamIsNil()
	app:alert({content="还未设置战队，无法参加战斗！现在就去设置战队？",title="系统提示", callback = function (state)
				if state == ALERT_TYPE.CONFIRM then
					self:_gotoTeam()
				end
			end})
end

function QUIDialogDungeon:_handleAvailableNumberNotEnough()
	app:alert({content="本关卡战斗次数已达本日上限！",title="系统提示"})
end

function QUIDialogDungeon:checkFightCountHandler()
	local result = remote.instance:checkCount(self.info.dungeon_id, self.info.dungeon_type)
	if result == 1 then return true end
	if result == 2 then
    	self:_showVipAlert(1)
	elseif result == 3 then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCount",
			options = {typeName = QUIDialogBuyCount["BUY_TYPE_6"], buyCount = self.info.info.todayReset, dungeonId = self.info.dungeon_id, buyCallback = function () 
				if self:safeCheck() then
					self:showInfo()
				end
			end}})
	end
	return false
end

-- @deprecated
function QUIDialogDungeon:_gotoTeam()
	local dungeonArrangement = QDungeonArrangement.new({dungeonId = self.info.dungeon_id})
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement", 
     	options = {arrangement = dungeonArrangement}})
end

--扫荡
function QUIDialogDungeon:_quickBattle(count)
	if self._isAllStar ~= true and self.info.dungeon_type ~= DUNGEON_TYPE.WELFARE then
		app.tip:floatTip("三星通关才可以扫荡本关卡")
		return
	end

	local actorIds = remote.teamManager:getActorIdsByKey(remote.teamManager.INSTANCE_TEAM)
  	if q.isEmpty(actorIds) then
    	self:_teamIsNil()
    	return 
  	end
	-- TOFIX: SHRINK
	local config = q.cloneShrinkedObject(self.config)

	if self:checkFightCountHandler() == false then
		return
	end

	if self.info.dungeon_type ~= DUNGEON_TYPE.WELFARE then
		local inPackCount = remote.items:getItemsNumByID(self.targetId)
	  	local oldLevel = remote.user.level
	  	local itemId = nil
	  	local itemCount = nil
	  	if self.targetNum and inPackCount and self.targetNum > inPackCount then
	  		-- 有目标收集材料，并且没有收集完成
	  		itemId = self.targetId
	  		itemCount = self.targetNum - inPackCount
	  	end
	  	local  battleType = BattleTypeEnum.DUNGEON_NORMAL
	  	if self.info.dungeon_type == DUNGEON_TYPE.ELITE then
	  		battleType = BattleTypeEnum.DUNGEON_ELITE
	  	end
		app:getClient():dungeonFightQuick(battleType,self.info.dungeon_id, count, itemId, itemCount, false, nil,
			function(data)
				local dungeonInfo = remote.instance:getDungeonById(self.info.dungeon_id)

				local fightCount = 0
				if data.batchAwards then
					fightCount = #data.batchAwards
				end
        		local energy = 6
				if dungeonInfo.dungeon_type == DUNGEON_TYPE.NORMAL then
                    remote.activity:updateLocalDataByType(540, fightCount)
				elseif dungeonInfo.dungeon_type == DUNGEON_TYPE.ELITE then
                    remote.activity:updateLocalDataByType(541, fightCount)
                    energy = 12
				end

		        --xurui: 更新每日宗门副本活跃任务
		        remote.union.unionActive:updateActiveTaskProgress(20004, energy*fightCount)
				
	    		local unlockVlaue = QStaticDatabase:sharedDatabase():getConfiguration()
				if data.shops ~= nil and data.userIntrusionResponse == nil then
				  	for _, value in pairs(data.shops) do 
			            if value.id == tonumber(SHOP_ID.goblinShop) and oldLevel >= app.unlock:getConfigByKey("UNLOCK_SHOP_1").team_level then
			                app.tip:addUnlockTips(QUIDialogMystoryStoreAppear.FIND_GOBLIN_SHOP)
			            elseif value.id == tonumber(SHOP_ID.blackShop) and oldLevel >= app.unlock:getConfigByKey("UNLOCK_SHOP_2").team_level then
			                app.tip:addUnlockTips(QUIDialogMystoryStoreAppear.FIND_BLACK_MARKET_SHOP)
			            end
		          	end
				end

				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnityFastBattle", 
					options = {fast_type = FAST_FIGHT_TYPE.DUNGEON_FAST, dungeon = config, awards = data.batchAwards, extraExpItem = data.extraExpItem, prizeWheelMoneyGot = data.prizeWheelMoneyGot, info = self.info, config = self.config, invasion = data.userIntrusionResponse,
					labelName = self.info.number.." "..self.config.name,targetItem = {id = self.targetId, count = self.targetNum, inPackCount = inPackCount}, isFromHeroInfo = self.isfromHeroInfo, callback = function(data)
							if data and data.isCloseDialog then
								self:_onTriggerBack()
							end
						end}},{isPopCurrentDialog = false})
				if self:safeCheck() then
					self:showInfo()
				end
			end,nil)
	else
		local  battleType = BattleTypeEnum.DUNGEON_WELFARE
		remote.welfareInstance:welfareQuickFightRequest(battleType, self.info.dungeon_id, count, false, nil, function(data)
				app.taskEvent:updateTaskEventProgress(app.taskEvent.WELFARE_DUNGEON_TASK_EVENT, 1)
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnityFastBattle", 
					options = {fast_type = FAST_FIGHT_TYPE.DUNGEON_FAST, dungeon = config, awards = data.batchAwards, extraExpItem = data.extraExpItem, prizeWheelMoneyGot = data.prizeWheelMoneyGot, info = self.info, config = self.config, invasion = data.userIntrusionResponse,
					labelName = self.info.number.." "..self.config.name,targetItem = {id = nil, count = nil, inPackCount = 0}}},{isPopCurrentDialog = false})
				if self:safeCheck() then
					self:showInfo()
				end
			end,nil)
	end
end

function QUIDialogDungeon:checkSkipBattle()
	self._skipBattle = true
	self._battleForceNoEnough = false
	self._isSpecialDungeon = false
	local isPass = (self.info.info and self.info.info.lastPassAt and self.info.info.lastPassAt > 0)
	if app.unlock:checkLock("UNLOCK_DUNGEON_SKIP") == false
		or isPass --检查是否通关
		or self.config.int_id <= 1010112  --检查是否通关
		or app.tutorial and app.tutorial:isInTutorial() then --检查是否有引导

		self._skipBattle = false
	end

	--检查是否是剧情关卡
	local dungeonDialogs = QStaticDatabase:sharedDatabase():getDungeonDialogs()
	if dungeonDialogs and isPass ~= true then
		local config = dungeonDialogs[tostring(self.info.dungeon_id)] or {}
		if config[1] and config[1].important_talk == 1 then
			self._skipBattle = false
			self._isSpecialDungeon = true
		end
	end

	--检查战力是否符合跳关要求
	local configForce = self.config.thunder_force or 0
	local topNForce = remote.herosUtil:getMostHeroBattleForce()
	if math.floor(topNForce / configForce) < 3 and isPass ~= true then
		self._skipBattle = false
		self._battleForceNoEnough = true
	end
end

function QUIDialogDungeon:skipBattlePassDungeon()
	local oldUser = remote.user:clone()

	local teamInfo = {{actorIds = {}}}
	local heroInfos, count = remote.herosUtil:getMaxForceHeros()
	if count > 4 then count = 4 end
	for i = 1, count, 1 do
	  	table.insert(teamInfo[1].actorIds, heroInfos[i].id)
	end
	
	local battleFormation = remote.teamManager:encodeBattleFormation(teamInfo)
	local successFunc = function(result)
		remote.instance.skipBattleCount = remote.instance.skipBattleCount + 1

		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDungeonFightEnd", 
			options = {dungeonConfig = self.config, oldUser = oldUser, result = result, callBack = function()
					if self:safeCheck() then
						self:popSelf()
					end
				end}}, {isPopCurrentDialog = false})	
	end

	local dungeonType = self.info.dungeon_type
	if dungeonType == DUNGEON_TYPE.WELFARE then
		remote.welfareInstance:welfareQuickFightRequest(BattleTypeEnum.DUNGEON_WELFARE, self.info.dungeon_id, 1, true, battleFormation, function(result)
			remote.welfareInstance:setIsFirstWin(true) 
			remote.welfareInstance:setBattleWin(true)

			app.taskEvent:updateTaskEventProgress(app.taskEvent.WELFARE_DUNGEON_TASK_EVENT, 1)

			successFunc(result)
		end)
	else
		local battleType = BattleTypeEnum.DUNGEON_NORMAL
		if dungeonType == DUNGEON_TYPE.ELITE then
			battleType = BattleTypeEnum.DUNGEON_ELITE
		end
		app:getClient():dungeonFightQuick(battleType, self.info.dungeon_id, 1, nil, nil, true, battleFormation, function(result)
			local energy = 6
			if dungeonType == DUNGEON_TYPE.NORMAL then
	            remote.activity:updateLocalDataByType(540, 1)
			elseif dungeonType == DUNGEON_TYPE.ELITE then
	            remote.activity:updateLocalDataByType(541, 1)
	            energy = 12
			end
	        --xurui: 更新每日宗门副本活跃任务
	        remote.union.unionActive:updateActiveTaskProgress(20004, energy)
			
			successFunc(result)
		end)
	end
end

function QUIDialogDungeon:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogDungeon:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

function QUIDialogDungeon:_onTriggerBack(tag)
	if self.targetId ~= nil then
    	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER, false)
    	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
    else
    	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end
end

function QUIDialogDungeon:_onTriggerHome(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QUIDialogDungeon:_onTriggerTeam(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_battle) == false then return end
	app.sound:playSound("common_item")
	if self:checkFightCountHandler() == false then
		return
	end

	local fightFunc = function ( ... )
		local options = self:getOptions()
		local dungeonArrangement = QDungeonArrangement.new({dungeonId = self.info.dungeon_id, dungeonType = self.info.dungeon_type, isEasy = self._isEasy, isRecommend = self._isRecommend, force = self._force})
	    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
	     	options = {arrangement = dungeonArrangement, isQuickWay = self.isQuickWay}})
	end

    --检查是否可以跳过战斗
    if self._skipBattle then	
    	if remote.instance.showSkipBattle == false then --本次登录不显示
    		if remote.instance.battleType == 1 then
    			fightFunc()
    		elseif remote.instance.battleType == 2 then
    			self:skipBattlePassDungeon()
    		end
    	else
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDungeonSkipBattle", 
				options = {selectCallback = function(flag)
					remote.instance.showSkipBattle = not flag
				end,battleCallback = function()
					if self:safeCheck() and fightFunc then
					    if remote.instance.showSkipBattle == false then
					        remote.instance.battleType = 1
					    end						
						fightFunc()
					end
				end, 
				skipBattleCallback = function()
					if self:safeCheck() then
					    if remote.instance.showSkipBattle == false then
					        remote.instance.battleType = 2
					    end						
						self:skipBattlePassDungeon()
					end
				end}}, {isPopCurrentDialog = false})	
		end
    else
    	fightFunc()
	end
end

function QUIDialogDungeon:_onTriggerQuickFightOne(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_one) == false then return end
    app.sound:playSound("common_small")
	if self:checkFightCountHandler() == false then
		return
	end
	self:_quickBattle(1)
end

function QUIDialogDungeon:_onTriggerQuickFightOneW(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_one_w) == false then return end
    app.sound:playSound("common_small")
	if self:checkFightCountHandler() == false then
		return
	end
	self:_quickBattle(1)
end

function QUIDialogDungeon:_onTriggerQuickFightTen(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_ten) == false then return end
    app.sound:playSound("common_small")
	if app.unlock:checkLock("COPY_AND_BRUSH") == false then
		app.unlock:tipsLock("COPY_AND_BRUSH", nil, true)
		return
	end

	if self.info.dungeon_type == DUNGEON_TYPE.NORMAL then
		--xurui:设置扫荡功能解锁提示
		if app.tip:checkReduceUnlokState("eliteFastBattle10") then
			app.tip:setReduceUnlockState("eliteFastBattle10", 2)
			self._ccbOwner.node_reduce_effect:setVisible(false)
		end
	end

	if self:checkFightCountHandler() == false then
		return
	end
	local count = 10
	if count > self._fightCount then
		count = self._fightCount
	end
    local num = math.floor(remote.user.energy/self.config.energy)
    if count > num then
        count = num
    end
	if count == 0 then 
		count = 10
		if self.info.attack_num < 10 then
			count = 3
		end
	end
	self:_quickBattle(count)
end

function QUIDialogDungeon:_onTriggerLeft(e)
	if e ~= nil then
        app.sound:playSound("common_menu")
    end
	self.info = self._perData
	self:getOptions().currentIndex = self._perIndex
	self:getOptions().info = self.info
	self:getOptions().targetId = self.targetId
	self:getOptions().targetNum = self.targetNum
	self:getOptions().isfromHeroInfo = self.isfromHeroInfo
	self.config = QStaticDatabase:sharedDatabase():getDungeonConfigByID(self.info.dungeon_id)
	self._monster = nil
	self._items = nil
	self:showInfo()
end

function QUIDialogDungeon:_onTriggerRight(e)
	if e ~= nil then
        app.sound:playSound("common_menu")
    end
	self.info = self._nextData
	self:getOptions().currentIndex = self._perIndex
	self:getOptions().info = self.info
	self:getOptions().targetId = self.targetId
	self:getOptions().targetNum = self.targetNum
	self:getOptions().isfromHeroInfo = self.isfromHeroInfo
	self.config = QStaticDatabase:sharedDatabase():getDungeonConfigByID(self.info.dungeon_id)
	self._monster = nil
	self._items = nil
	self:showInfo()
end

function QUIDialogDungeon:_onTriggerBossIntroduce()
	app.sound:playSound("common_small")
	if self._bossId and self._enemyTips then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBossIntroducePic",
				options = {bossId = self._bossId, enemyTips = self._enemyTips}})
	end
end

function QUIDialogDungeon:_onTriggerBuyCount(event)
	if q.buttonEventShadow(event,self._ccbOwner.node_btn_plus) == false then return end
    app.sound:playSound("common_small")
	local dungeonCountConfig = QStaticDatabase:sharedDatabase():getTokenConsumeByType("dungeon_elite")
	local dungeonConfig = dungeonCountConfig[self.info.info.todayReset + 1]
	if dungeonConfig == nil then
		dungeonConfig = dungeonCountConfig[#dungeonCountConfig]
	end

    if self.info.info.todayReset >= QVIPUtil:getResetEliteDungeonCount() then
    	self:_showVipAlert(1)
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCount",
			options = {typeName = QUIDialogBuyCount["BUY_TYPE_6"], buyCount = self.info.info.todayReset, dungeonId = self.info.dungeon_id, buyCallback = function () 
				if self:safeCheck() then
					self:showInfo()
				end
			end}})
	end
end

function QUIDialogDungeon:_onTriggerStarInfo(  )
	-- body
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogEliteStarInfoTips",options = {dungeonId = self.info.dungeon_id}})

	
end

function QUIDialogDungeon:_showVipAlert( model )
	if model == 1 then
		-- 重置精英副本的次数
		app:vipAlert({title = "精英关卡可重置次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.RESET_ELITE_COUNT}, false)
	elseif model == 2 then
		-- 解锁扫荡多次
		local level = QVIPUtil:getcanSweepTenTimesUnlockLevel()
   		local text = "扫荡多次功能，VIP达到"..level.."级后可开启，是否前往充值提升VIP等级？"
		app:vipAlert({content=text}, false)
	end
end

return QUIDialogDungeon