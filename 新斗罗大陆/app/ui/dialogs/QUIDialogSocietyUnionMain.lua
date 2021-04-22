--[[	
	文件名称：QUIDialogSocietyUnionMain.lua
	创建时间：2016-03-25 21:19:03
	作者：nieming
	描述：QUIDialogSocietyUnionMain
]]

local QUIDialogBaseUnion = import(".QUIDialogBaseUnion")
local QNavigationController = import("...controllers.QNavigationController")
local QUIDialogSocietyUnionMain = class("QUIDialogSocietyUnionMain", QUIDialogBaseUnion)
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAvatarWalk = import("..widgets.QUIWidgetAvatarWalk")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIDialogSocietyAnnouncement = import(".QUIDialogSocietyAnnouncement")
local QUIWidgetTutorialHandTouch = import("..widgets.QUIWidgetTutorialHandTouch")
local QUIWidgetLevelGuide = import("..widgets.QUIWidgetLevelGuide")
local QUIWidgetIconAniTips = import("..widgets.QUIWidgetIconAniTips")
local QUIWidgetQuestionAvatar = import("..widgets.question.QUIWidgetQuestionAvatar")
local QUIDialogSocietyUnionQuestion = import(".QUIDialogSocietyUnionQuestion")
local QUIWidgetUnionDragonTrainAvatar = import("..widgets.dragon.QUIWidgetUnionDragonTrainAvatar")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")

local unlockVisibleLevelGap = 5
local unlockTable = {
 	dragon = {config = "SOCIATY_DRAGON", reviewLevel = 2, enable = "unionDragonEnable", disable = "unionDragonDisable", tip = "unionDragonTips"},
	totem = {config = "TUTENG_DRAGON", reviewLevel = 2, button = "btn_totemBtn_expand", enable = "totemEnable", disable = "totemDisable", tip = "totemTips"},
	dragonWar = {config = "SOCIATY_DRAGON_FIGHT", reviewLevel = 0, button = "unionDragonWarBtn", enable = "unionDragonWarEnable", disable = "unionDragonWarDisable", tip = "unionDragonWarTips"},
	consortiaWar = {config = "UNLOCK_CONSORTIA_WAR", reviewLevel = 2, button = "consortiaWarBtn", enable = "consortiaWarEnable", disable = "consortiaWarDisable", tip = "consortiaWarTips"},
}

--初始化
function QUIDialogSocietyUnionMain:ctor(options)
	local ccbFile = "Dialog_society_union_main.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerTotem", callback = handler(self, self._onTriggerTotem)},
		{ccbCallbackName = "onTriggerConsortiaWar", callback = handler(self, self._onTriggerConsortiaWar)},
		{ccbCallbackName = "onTriggerUnionPlunder", callback = handler(self, self._onTriggerUnionPlunder)},
		{ccbCallbackName = "onTriggerUnionSkill", callback = handler(self, self._onTriggerUnionSkill)},
		{ccbCallbackName = "onTriggerUnionFuBen", callback = handler(self, self._onTriggerUnionFuBen)},
		{ccbCallbackName = "onTriggerUnionBuilding", callback = handler(self, self._onTriggerUnionBuilding)},
		{ccbCallbackName = "onTriggerUnionNotify", callback = handler(self, self._onTriggerUnionNotify)},
		{ccbCallbackName = "onTriggerUnionDragonWar", callback = handler(self, self._onTriggerUnionDragonWar)},
		{ccbCallbackName = "onTriggerUnionConsortia", callback = handler(self, self._onTriggerUnionConsortia)},
		{ccbCallbackName = "onTriggerUnionChest", callback = handler(self, self._onTriggerUnionChest)},
		{ccbCallbackName = "onTriggerDragonTask", callback = handler(self, self._onTriggerDragonTask)},
		{ccbCallbackName = "onTriggerUnionShop", callback = handler(self, self._onTriggerUnionShop)},
		{ccbCallbackName = "onTriggerUnionManage", callback = handler(self, self._onTriggerUnionManage)},
		{ccbCallbackName = "onTriggerDragonWarShop", callback = handler(self, self._onTriggerDragonWarShop)},
		{ccbCallbackName = "onTriggerUnionQuestion", callback = handler(self, self._onTriggerUnionQuestion)},
		{ccbCallbackName = "onTriggerUnionRedPacket", callback = handler(self, self._onTriggerUnionRedPacket)},
		{ccbCallbackName = "onTriggerOfferReward", callback = handler(self, self._onTriggerOfferReward)},
	}
	QUIDialogSocietyUnionMain.super.ctor(self,ccbFile,callBacks,options)
	--代码
	self._closeRangeLayerPosX = 0
	self._farLayerPosX = self._ccbOwner.farLayer:getPositionX()

	self._callFunc = options.callFunc
		
	self:checkBackground()
	self:checksnow()
	remote.offerreward:checkOfferRewardInfo()-- 判定魂师派遣玩法数据
	local endCallback = function()
	end
	-- 副宗主特权
	self:checkDeputyLimitRight(function()
		-- 免费钻石红包
		self:checkFreeTokenRedPacketTips(endCallback)
	end)
end

--显示宗门公告
function QUIDialogSocietyUnionMain:showGongGaoDialog( )
	if remote.user.userConsortia then
		local openConsortiaType = remote.user.userConsortia.openConsortiaType or 0
		if openConsortiaType == 1 or openConsortiaType == 2 then
			remote.user.userConsortia.openConsortiaType = 0
	  		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyGonggao", 
	  			options = {}}, {isPopCurrentDialog = false})
	  	else
	  		if remote.user.userConsortia.rank == 9 and remote.union.consortia.lastPresidentName then
	  			-- 会长，并且有前任会长的名字
	  			-- 这里不需要存记录了，后端有lastPresidentName就弹。
	  			
	  			-- local isShowEnd = app:getUserOperateRecord():getRecordByType("UNION_CHANGE_PRESIDENT"..remote.union.consortia.sid..remote.union.consortia.lastPresidentName)
	  			-- if not isShowEnd then
		  			local content = {}
		  			table.insert(content, {oType = "font", content = "魂师大人，", size = 24, color = COLORS.a})
		        	table.insert(content, {oType = "font", content = remote.union.consortia.lastPresidentName, size = 24, color = COLORS.b})
		        	table.insert(content, {oType = "font", content = "将宗主之位转让给您。希望您带领宗门发扬光大～", size = 24, color = COLORS.a})
		        	table.insert(content, {oType = "wrap"})
		        	table.insert(content, {oType = "font", content = "宗主的权限和注意事项可以在管理大厅的帮助里查看", size = 24, color = COLORS.a})
			        local titlePath = QResPath("union_poster_title")
					local spAvatarPath = QResPath("silves_arena_poster_avatar")
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPrompt", 
						options = {content = content, titlePath = titlePath, spAvatarPath = spAvatarPath, uorType = false}})
					-- app:getUserOperateRecord():setRecordByType("UNION_CHANGE_PRESIDENT"..remote.union.consortia.sid..remote.union.consortia.lastPresidentName, true)
			  	-- end
		  	end
		end
	end
end

-- 检查宝箱
function QUIDialogSocietyUnionMain:shwoChest()
	-- 宗门周活跃宝箱
	local unionChestUnlock = remote.union.unionActive:checkUnionWeekChestIsOpen()
	self._ccbOwner.node_union_chest:setVisible(false)
	if unionChestUnlock then
		remote.union.unionActive:requestGetUnionActiveWeekInfo(function(data)
				if self:safeCheck() then
					if data.consortiaGetWeekRewardInfoResponse and data.consortiaGetWeekRewardInfoResponse.totalDrawMemberCount 
						and data.consortiaGetWeekRewardInfoResponse.totalDrawMemberCount then

						self._ccbOwner.node_union_chest:setVisible(true)
						
					    if remote.union.unionActive:checkChestRedTip() then
					    	self._ccbOwner.unionChestTips:setVisible(true)
					    else
					    	self._ccbOwner.unionChestTips:setVisible(false)
					    end
					end
				end
			end)
	end
end

function QUIDialogSocietyUnionMain:_init( options )
	self:getOptions().distance = self:getOptions().distance or 0

	self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")

	self:initScrollLayer()
	self:initIcon()
	self:initActor()
	--self:shwoChest()

	-- by Kumo 进入宗门主界面的时候，没有拉去宗门副本的信息，所以宗门副本的小红点无法显示。
	local needLevel = remote.union:getSocietyNeedLevel()
	if ENABLE_UNION_DUNGEON and needLevel and remote.union.consortia.level >= needLevel then
		-- by Kumo 这里延迟一帧去服务器申请BOSS信息，目的为了防止从宗门主界面进入商店之后，切换商店会有短暂的一瞬间初始化宗门主界面并申请BOSS信息的不必要动作。
		self._unionGetBossListRequestScheduler = scheduler.performWithDelayGlobal(function ()
			remote.union:unionGetBossListRequest(self:safeHandler(function()
					if app.tutorial:getStage().dragonTotem == app.tutorial.Guide_Start and app.unlock:checkLock("TUTENG_DRAGON") then
				    	self:backDialogMain() 
					elseif options.isTutorialPlunder then
						self:tutorialPlunder()
					end
					self:showGongGaoDialog()
				end))
			end, 0)
	else
		self:showGongGaoDialog()
	end

	-- 和时间有关的数据
	self:_updateTime()
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	self._scheduler = scheduler.scheduleGlobal(function ()
		self:_updateTime()
	end, 1)

    self:levelGuide()

    -- 初始化宗门目标
	local unionActive = remote.union.unionActive:getActiveAwards()
	if unionActive == nil or next(unionActive) == nil then
		remote.union.unionActive:updateActiveInfo()
	end

	-- 初始化龙战信息
	local dragonWarInfo = remote.unionDragonWar:getMyInfo()
	if dragonWarInfo == nil or next(dragonWarInfo) == nil then
		remote.unionDragonWar:loginEnd(function()
				if self:safeCheck() then
					self:showRedTips()
				end
			end, false)
	end

	remote.question:initQuestion(true)
end

function QUIDialogSocietyUnionMain:initActor(  )
	-- body
	 remote.union:unionMemberListRequest(function (data)
	 	if self:safeCheck() then
	        local memberList =  data.consortiaFighters or {}
	        table.sort(memberList, function(a, b)
	        	if a.lastLeaveTime ~= b.lastLeaveTime then
	        		return a.lastLeaveTime < b.lastLeaveTime
	        	else
	        		return false
	        	end
	    	end)

	        if self._avatarLayer == nil then
	        	self._avatarLayer = QUIWidgetAvatarWalk.new()
				self._ccbOwner.actorsNode:addChild(self._avatarLayer)
				self._avatarLayer:setPositionX(-550)
	        end

	        local heroRange = {width = 1100, height = 20}
	        local index = 0
	        local heroInfo = {}
	        for _, value in pairs(memberList) do
	        	if index < 3 and value.userId ~= remote.user.userId then
        			table.insert(heroInfo, {actorId = value.defaultActorId or 1005, skinId = value.defaultSkinId or 0, userName = value.name, officialPosition = value.rank or SOCIETY_OFFICIAL_POSITION.MEMBER})
	        		index = index + 1
	        	end
	        end
        	table.insert(heroInfo, {actorId = remote.user.defaultActorId or 1005, skinId = remote.user.defaultSkinId or 0, userName = remote.user.nickname, officialPosition = remote.user.userConsortia.rank or SOCIETY_OFFICIAL_POSITION.MEMBER})
	        self._avatarLayer:setInfo(heroInfo, heroRange, 3)
	    end
    end) 
end

function QUIDialogSocietyUnionMain:initIcon(  )
	--宗门战
	if ENABLE_PLUNDER and remote.plunder:checkPlunderUnlock() then
		self._ccbOwner.unionPlunderEnable:setVisible(true)
		self._ccbOwner.unionPlunderDisable:setVisible(false)

		if not self._plunderFightTips then
			self._plunderFightTips = QUIWidgetIconAniTips.new()
			self._plunderFightTips:setInfo(1, 6, "", "down")
			self._ccbOwner.node_plunder_ccb:removeAllChildren()
			self._ccbOwner.node_plunder_ccb:addChild(self._plunderFightTips)
		end
		local _, _, isActive = remote.plunder:updateTime()
		self._plunderFightTips:setVisible(isActive)
		self._ccbOwner.node_plunder_ccb:setVisible(true)
	else
		self._ccbOwner.unionPlunderEnable:setVisible(false)
		self._ccbOwner.node_plunder_ccb:setVisible(false)
	end
	self._ccbOwner.plunder_tips:setVisible(false)

	--宗门技能
	local openLevel = QStaticDatabase.sharedDatabase():getConfigurationValue("SOCIATY_SKILL") or 0
	if openLevel <= remote.union.consortia.level then
		self._ccbOwner.unionSkillEnable:setVisible(true)
		self._ccbOwner.unionSkillDisable:setVisible(false)
	else
		self._ccbOwner.unionSkillEnable:setVisible(false)
		self._ccbOwner.unionSkillDisable:setVisible(true)
	end

	self._ccbOwner.unionSkillTips:setVisible(false)
	-- 
	--宗门副本
	if not ENABLE_UNION_DUNGEON then
		self._ccbOwner.unionFuBenEnable:setVisible(false)
		-- self._ccbOwner.unionFuBenDisable:setVisible(true)
		self._ccbOwner.unionFuBenTips:setVisible(false)
		self._ccbOwner.unionFuBenBtn:setEnabled(false)
	else
		local needLevel = remote.union:getSocietyNeedLevel()
		if remote.union.consortia.level >= needLevel then
			self._ccbOwner.unionFuBenEnable:setVisible(true)
			self._ccbOwner.unionFuBenDisable:setVisible(false)
			self._ccbOwner.unionFuBenTips:setVisible(false)
			-- self._ccbOwner.unionFuBenBtn:setEnabled(false)
		else
			self._ccbOwner.unionFuBenEnable:setVisible(false)
			-- self._ccbOwner.unionFuBenDisable:setVisible(true)
			self._ccbOwner.unionFuBenTips:setVisible(false)
			self._ccbOwner.unionFuBenBtn:setEnabled(false)
		end
	end

	--建设
	self._ccbOwner.unionBuildingEnable:setVisible(true)
	self._ccbOwner.unionBuildingDisable:setVisible(false)
	self._ccbOwner.unionBuildingTips:setVisible(false)

	-- self._ccbOwner.unionBuildingBtn:setEnabled(false)
	--公告板
	self._ccbOwner.unionNotifyEnable:setVisible(true)
	self._ccbOwner.unionNotifyDisable:setVisible(false)
	self._ccbOwner.unionNotifyTips:setVisible(false)
	-- self._ccbOwner.unionNotifyBtn:setEnabled(false)

	--宗门巨龙
	self._ccbOwner.unionDragonEnable:setVisible(true)
	self._ccbOwner.unionDragonDisable:setVisible(false)
	self._ccbOwner.unionDragonTips:setVisible(false)

	-- --宗门贡献
	-- self._ccbOwner.unionConsortiaEnable:setVisible(false)
	-- -- self._ccbOwner.unionConsortiaDisable:setVisible(true)
	-- self._ccbOwner.unionConsortiaTips:setVisible(false)
	-- self._ccbOwner.unionConsortiaBtn:setEnabled(false)

	--宗门商店
	self._ccbOwner.sp_shop_tip:setVisible(false)

	--宗门管理
	self._ccbOwner.sp_manage_tip:setVisible(false)

	--悬赏任务
	if remote.offerreward:getUnlockOfferReward() then
		self._ccbOwner.offerRewardEnable:setVisible(true)
		self._ccbOwner.offerRewardDisable:setVisible(false)
	else
		self._ccbOwner.offerRewardEnable:setVisible(false)
		self._ccbOwner.offerRewardDisable:setVisible(true)
	end


  	self:checkBuildingUnlock()

	self:checkDragonIsOpen()

  	self:showRedTips()
end

function QUIDialogSocietyUnionMain:checkBuildingUnlock()
	for k, v in pairs(unlockTable) do
		self._ccbOwner[v.tip]:setVisible(false)

		local unlock = app.unlock:checkLock(v.config)
		if unlock then
			self._ccbOwner[v.enable]:setVisible(true)
			self._ccbOwner[v.disable]:setVisible(false)
			if v.button then
				self._ccbOwner[v.button]:setEnabled(true)
			end
			if v.button2 then
				self._ccbOwner[v.button2]:setEnabled(true)
			end
			if v.config == "TUTENG_DRAGON" then
				self._ccbOwner.sp_totem_lock:setVisible(false)
				remote.dragonTotem:requestTotemInfo()
			end
		else
			self._ccbOwner[v.enable]:setVisible(false)
			self._ccbOwner[v.disable]:setVisible(true)
			if v.button then
				self._ccbOwner[v.button]:setEnabled(true)
			end
			if v.button2 then
				self._ccbOwner[v.button2]:setEnabled(true)
			end
			self._ccbOwner[v.tip]:setVisible(false)
			local config = app.unlock:getConfigByKey(v.config)
			if v.reviewLevel and (remote.union.consortia.level + v.reviewLevel) < (config.sociaty_level or 0) then
				self._ccbOwner[v.disable]:setVisible(false)
				if v.button then
					self._ccbOwner[v.button]:setEnabled(false)
				end
				if v.button2 then
					self._ccbOwner[v.button2]:setEnabled(false)
				end
			end
		end
	end
end

--显示小红点
function QUIDialogSocietyUnionMain:showRedTips()
	-- body
	if remote.union:checkUnionShopRedTips() then
        self._ccbOwner.sp_shop_tip:setVisible(true)
    else
    	self._ccbOwner.sp_shop_tip:setVisible(false)
    end
    
    if remote.union:checkBuildingRedTips() then
        self._ccbOwner.unionBuildingTips:setVisible(true)
    else
    	self._ccbOwner.unionBuildingTips:setVisible(false)
    end

    if remote.union:checkUnionManageRedTips() then
    	self._ccbOwner.sp_manage_tip:setVisible(true)
    else
    	self._ccbOwner.sp_manage_tip:setVisible(false)
    end

    if remote.union:checkAllSocietyDungeonRedTips() or remote.union:checkSocietyDungeonRedTips() then
        self._ccbOwner.unionFuBenTips:setVisible(true)
    else
    	self._ccbOwner.unionFuBenTips:setVisible(false)
    end

    if remote.union:checkUnionSkillRedTips() then
    	self._ccbOwner.unionSkillTips:setVisible(true)
    else
    	self._ccbOwner.unionSkillTips:setVisible(false)
    end

    if remote.plunder:checkPlunderRedTip() then
    	self._ccbOwner.plunder_tips:setVisible(true)
    else
    	self._ccbOwner.plunder_tips:setVisible(false)
    end

    if remote.dragon:checkDragonRedTip() then
    	self._ccbOwner.unionDragonTips:setVisible(true)
    else
    	self._ccbOwner.unionDragonTips:setVisible(false)
    end

    if remote.consortiaWar:checkRedTips() then
    	self._ccbOwner.consortiaWarTips:setVisible(true)
    else
    	self._ccbOwner.consortiaWarTips:setVisible(false)
    end

	self._ccbOwner.offerRewardTips:setVisible(remote.offerreward:checkRedTips())

    self._ccbOwner.sp_redpacket_tip:setVisible(remote.redpacket:checkRedpacketRedTip())
    
	self._ccbOwner.totemTips:setVisible(remote.dragonTotem:checkAllTotemTips())

	self._ccbOwner.unionDragonWarTips:setVisible(remote.unionDragonWar:checkDragonWarRedTip())

	self._ccbOwner.sp_dragon_war_shop:setVisible(remote.unionDragonWar:checkDragonWarShopTip())

	self:showQuestionRedTips()

	if not self._dragonFightTips then
		self._dragonFightTips = QUIWidgetIconAniTips.new()
		self._dragonFightTips:setInfo(1, 4, "", "down")
		self._ccbOwner.node_dragon_fight_tips:removeAllChildren()
		self._ccbOwner.node_dragon_fight_tips:addChild(self._dragonFightTips)
	end
	self._dragonFightTips:setVisible(remote.unionDragonWar:checkHaveFightCount())

	if not self._consortiaWarTips then
		self._consortiaWarTips = QUIWidgetIconAniTips.new()
		self._consortiaWarTips:setInfo(1, 4, "", "down")
		self._ccbOwner.node_consortiaWar_tips:removeAllChildren()
		self._ccbOwner.node_consortiaWar_tips:addChild(self._consortiaWarTips)
	end
	self._consortiaWarTips:setVisible(remote.consortiaWar:checkFightRedTips())
end

function QUIDialogSocietyUnionMain:_updateRedpacketRedTips()
	self._ccbOwner.sp_redpacket_tip:setVisible(remote.redpacket:checkRedpacketRedTip())
end

function QUIDialogSocietyUnionMain:_updateOfferRewardRedTips()
	self._ccbOwner.offerRewardTips:setVisible(remote.offerreward:checkRedTips())
end

function QUIDialogSocietyUnionMain:showQuestionRedTips()
	if not app.unlock:checkLock("UNION_ANSWER") then
		self._ccbOwner.unionQuestionTips:setVisible(false)
		self._ccbOwner.unionQuestionEnable:setVisible(false)
		self._ccbOwner.unionQuestionDisable:setVisible(true)
		return false
	end
	if remote.question:checkQuestionRedTip() then
		self._ccbOwner.unionQuestionTips:setVisible(true)
		self._ccbOwner.unionQuestionEnable:setVisible(true)
		self._ccbOwner.unionQuestionDisable:setVisible(false)
		if self._fca== nil then
			local skeletonViewController = QSkeletonViewController.sharedSkeletonViewController()
    		local fca_ani = YUXIAOGANG_QUESTION_ANI
    		self._fca = skeletonViewController:createSkeletonActorWithFile(fca_ani.name, nil, false)
   			self._fca:setScale(fca_ani.scale or 1)
    		self._fca:playAnimation("stand", true)
    		self._ccbOwner.dt:addChild(self._fca)
    		self._fca:setPositionX(-33)
    		self._fca:setPositionY(-75)
    		
   			self._fca:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
    		self._fca:scheduleUpdate_()
		end
	else
		self._ccbOwner.unionQuestionTips:setVisible(false)
		self._ccbOwner.unionQuestionEnable:setVisible(true)
		self._ccbOwner.unionQuestionDisable:setVisible(false)
		if self._questionActor ~= nil then
			self._questionActor:removeFromParent()
			self._questionActor = nil
		end
	end
end

function QUIDialogSocietyUnionMain:checkDragonIsOpen()
	self._ccbOwner.node_dragonwar_shop:setVisible(false)
	self._ccbOwner.sp_dragon_war_shop:setVisible(false)
	self._ccbOwner.unionDragonWarEnable:setVisible(false)
	self._ccbOwner.unionDragonWarDisable:setVisible(false)
	self._ccbOwner.unionDragonWarBtn:setEnabled(false)
	self._ccbOwner.sp_weapon_yz:setVisible(false)
	self._ccbOwner.sp_warror_yz:setVisible(false)
	self._ccbOwner.node_whzbeffect:setVisible(false)
	self._ccbOwner.node_whzbeffect1:setVisible(false)
    self._animationManager:stopAnimation()

	-- set dragon avatar
	if self._dragonAvatar == nil then
		self._dragonAvatar = QUIWidgetUnionDragonTrainAvatar.new()
		self._dragonAvatar:addEventListener(QUIWidgetUnionDragonTrainAvatar.EVENT_CLICK, handler(self, self._onDragonClickEvent))
		self._ccbOwner.node_dragon:removeAllChildren()
		local scaleX = self._ccbOwner.node_dragon:getScaleX()
		self._ccbOwner.node_dragon:setScaleX(-scaleX)
		self._ccbOwner.node_dragon:addChild(self._dragonAvatar)
		self._dragonAvatar:setInUnion(true)
		self._dragonAvatar:showDefault()
	end
	if app.unlock:checkLock("SOCIATY_DRAGON") == false then
		self._ccbOwner.unionDragonDisable:setVisible(true)
		self._ccbOwner.unionDragonEnable:setVisible(false)
		return
	end
	self._ccbOwner.unionDragonDisable:setVisible(false)
	self._ccbOwner.unionDragonEnable:setVisible(true)

	--宗门武魂任务
	local dragonInfo = remote.dragon:getDragonInfo()
	if dragonInfo == nil or not dragonInfo.dragonId or dragonInfo.dragonId == 0 then
		self._ccbOwner.sp_weapon_yz:setVisible(true)
		self._ccbOwner.unionDragonWarEnable:setVisible(false)
		self._ccbOwner.unionDragonWarDisable:setVisible(true)
		self._ccbOwner.unionDragonWarBtn:setEnabled(true)
		return 
	end
	self._dragonAvatar:setInfo(dragonInfo)

	local dragonConfig = db:getUnionDragonConfigById(dragonInfo.dragonId)
	if dragonConfig.type == remote.dragon.TYPE_WEAPON then
        self._ccbOwner.sp_weapon_yz:setVisible(true)
    else
		self._ccbOwner.sp_warror_yz:setVisible(true)
    end

	-- 宗门武魂战
	local openDragonLevel = db:getConfiguration()["sociaty_dragon_fight_open_dragon_level"].value or 5
	self._ccbOwner.unionDragonWarTips:setVisible(false)
	if dragonInfo.level >= 1 and dragonInfo.level < openDragonLevel then
		self._ccbOwner.unionDragonWarEnable:setVisible(false)
		self._ccbOwner.unionDragonWarDisable:setVisible(true)
		self._ccbOwner.unionDragonWarBtn:setEnabled(true)
	elseif dragonInfo.level >= openDragonLevel then
		self._ccbOwner.unionDragonWarEnable:setVisible(true)
		self._ccbOwner.unionDragonWarDisable:setVisible(false)
		self._ccbOwner.unionDragonWarBtn:setEnabled(true)
		self._ccbOwner.node_whzbeffect:setVisible(true)
		self._ccbOwner.node_whzbeffect1:setVisible(true)

    	self._animationManager:runAnimationsForSequenceNamed("Default Timeline")
	else
		self._ccbOwner.unionDragonWarEnable:setVisible(false)
		self._ccbOwner.unionDragonWarDisable:setVisible(false)
		self._ccbOwner.unionDragonWarBtn:setEnabled(false)
	end

	-- 宗门武魂战商店
	if remote.unionDragonWar:checkDragonWarUnlock() then
		self._ccbOwner.node_dragonwar_shop:setVisible(true)
	end
end

function QUIDialogSocietyUnionMain:handleRedTipsUpdate(  )
	-- body
	self:showRedTips()
end

function QUIDialogSocietyUnionMain:backDialogMain()
	local middleLayerController = app:getNavigationManager():getController(app.middleLayer)
	if middleLayerController:getTopDialog() == nil then
		-- self:checkDragonTotemTutorial()
	end
end

function QUIDialogSocietyUnionMain:checkDragonLevel()
	if app.unlock:checkLock("SOCIATY_DRAGON") == false then return end
	local callback
	callback = function()
		remote.dragon:checkDragonLevelUp(callback)
	end
	callback()
end

function QUIDialogSocietyUnionMain:_updateDragon()
	--宗门武魂
	local dragonInfo = remote.dragon:getDragonInfo()
	if dragonInfo == nil or next(dragonInfo) == nil or dragonInfo.dragonId == 0 then
		return 
	end
	if self._dragonAvatar then
		self._dragonAvatar:setInfo(dragonInfo)
	end

	self._ccbOwner.sp_weapon_yz:setVisible(false)
	self._ccbOwner.sp_warror_yz:setVisible(false)
	
	local dragonConfig = db:getUnionDragonConfigById(dragonInfo.dragonId)
	if dragonConfig.type == remote.dragon.TYPE_WEAPON then
        self._ccbOwner.sp_weapon_yz:setVisible(true)
    else
		self._ccbOwner.sp_warror_yz:setVisible(true)
    end
end

function QUIDialogSocietyUnionMain:_updateTime()
	if (not remote.user.userConsortia.consortiaId or remote.user.userConsortia.consortiaId == "") then return end
	
	local curTimeTbl = q.date("*t", q.serverTime())
	local startTime = remote.union:getSocietyDungeonStartTime()
	local endTime = remote.union:getSocietyDungeonEndTime()
	local cd = remote.union:getSocietyCD()
	if (curTimeTbl.hour == startTime and curTimeTbl.min == 0 and curTimeTbl.sec == 0) or
	(curTimeTbl.hour == endTime and curTimeTbl.min == 0 and curTimeTbl.sec == 0) then
		self:showRedTips()
	end

	if (curTimeTbl.hour == startTime and curTimeTbl.min == 0 and curTimeTbl.sec == 0) or
	(curTimeTbl.hour == startTime + cd and curTimeTbl.min == 0 and curTimeTbl.sec == 0) or
	(curTimeTbl.hour == startTime + cd * 2 and curTimeTbl.min == 0 and curTimeTbl.sec == 0) or
	(curTimeTbl.hour == startTime + cd * 3 and curTimeTbl.min == 0 and curTimeTbl.sec == 0) or
	(curTimeTbl.hour == startTime + cd * 4 and curTimeTbl.min == 0 and curTimeTbl.sec == 0) then
		self._ccbOwner.unionFuBenTips:setVisible(true)
	end
end

function QUIDialogSocietyUnionMain:initScrollLayer(  )
	-- body
	self._touchLayer = QUIGestureRecognizer.new()
	self._touchLayer.parentName = "QUIDialogSocietyUnionMain"
	-- self._touchLayer._isColor = true
	self._touchLayer._mainMenu = true
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:setAttachSlide(true)
	self._touchLayer:attachToNode(self:getView(), display.width, display.height, 0, 0, handler(self, QUIDialogSocietyUnionMain._onTouch))
	self._touchLayer:enable()

	self._totalWidth = 2000
	self._maxDistance = self._totalWidth - display.width


	self._farLayerOffset = self._totalWidth/2 - display.width/2
	self._closeRangeLayerOffset = self._totalWidth/2 - display.width/2

	local historyDistance = self:getOptions().distance or 0
	self._ccbOwner.farLayer:setPositionX(historyDistance * 0.5 )
	self._ccbOwner.closeRangeLayer:setPositionX(historyDistance)

end


function QUIDialogSocietyUnionMain:_onTouch(event)
	if event.name == "began" then
		
		self._lastSlidePositionX = event.x

		self._farLayerPosX = self._ccbOwner.farLayer:getPositionX()
		self._closeRangeLayerPosX = self._ccbOwner.closeRangeLayer:getPositionX()
		self:_removeAction()
		return true
	elseif event.name == "moved" then
		self:screenMove(event.x - self._lastSlidePositionX, false)
		if self._isMoveing ~= true and math.abs(event.x - self._lastSlidePositionX) > 10 then
			self._isMoveing = true
		end
	elseif event.name == "ended" or event.name == "cancelled" then
		scheduler.performWithDelayGlobal(function ()
			self._isMoveing = false
		end, 0)
	elseif event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
		self._farLayerPosX = self._ccbOwner.farLayer:getPositionX()
		self._closeRangeLayerPosX = self._ccbOwner.closeRangeLayer:getPositionX()
		self:screenMove(event.distance.x, true)
	end
end

--滑动距离，是否有惯性
function QUIDialogSocietyUnionMain:screenMove(distance, isSlider)
	local isOffset = false
	if (self._closeRangeLayerPosX + distance) > self._closeRangeLayerOffset then
		distance =  self._closeRangeLayerOffset - self._closeRangeLayerPosX
		isOffset = true
	end
	if (self._closeRangeLayerPosX + distance) < -self._closeRangeLayerOffset then
		distance = -self._closeRangeLayerOffset - self._closeRangeLayerPosX
		isOffset = true
	end

	--远景移动
	-- local farDistance = distance*(self._farTotalWidth - UI_DESIGN_WIDTH)/(self._midTotalWidth - UI_DESIGN_WIDTH)
	local farDistance = distance * 0.65
	local midDistance = distance * 0.8
	local closeRangeDistance = distance 

	if isSlider == false then
		self._ccbOwner.farLayer:setPositionX(self._farLayerPosX + farDistance)
		self._ccbOwner.closeRangeLayer:setPositionX(self._closeRangeLayerPosX + closeRangeDistance)
	else
		self._farActionHandler = self:_contentRunAction(self._ccbOwner.farLayer, self._farLayerPosX + farDistance, self._ccbOwner.farLayer:getPositionY())
		self._closeRangeActionHandler = self:_contentRunAction(self._ccbOwner.closeRangeLayer, self._closeRangeLayerPosX + closeRangeDistance, self._ccbOwner.closeRangeLayer:getPositionY())
	end
end

function QUIDialogSocietyUnionMain:_contentRunAction(node, posX, posY)
	local actionArrayIn = CCArray:create()
	local curveMove = CCMoveTo:create(1.3, ccp(posX,posY))
	local speed = CCEaseExponentialOut:create(curveMove)
	actionArrayIn:addObject(speed)
	actionArrayIn:addObject(CCCallFunc:create(function ()
		self:_removeAction()
	end))
	local ccsequence = CCSequence:create(actionArrayIn)
	return node:runAction(ccsequence)
		-- self:startEnter()
end

function QUIDialogSocietyUnionMain:_removeAction()
	if self._farActionHandler ~= nil then
		self._ccbOwner.farLayer:stopAction(self._farActionHandler)
		self._farActionHandler = nil
	end

	if self._closeRangeActionHandler ~= nil then
		self._ccbOwner.closeRangeLayer:stopAction(self._closeRangeActionHandler)
		self._closeRangeActionHandler = nil
	end
	
end

function QUIDialogSocietyUnionMain:tutorialPlunder()
	self._farLayerPosX = self._ccbOwner.farLayer:getPositionX()

	self._closeRangeLayerPosX = self._ccbOwner.closeRangeLayer:getPositionX()
	self:screenMove(800, true)

	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击开始宗门狩猎", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._ccbOwner.node_tutorial:addChild(self._handTouch)
end

function QUIDialogSocietyUnionMain:checkDragonTotemTutorial()
	-- print(1, app.tutorial, app.tutorial:isTutorialFinished())
	if app.tutorial and app.tutorial:isTutorialFinished() == false then
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		if page.buildLayer then
			page:buildLayer()
		end
		local haveTutorial = false
		-- print("2", app.tutorial:getStage().dragonTotem == app.tutorial.Guide_Start, app.unlock:checkLock("TUTENG_DRAGON"))
		if app.tutorial:getStage().dragonTotem == app.tutorial.Guide_Start and app.unlock:checkLock("TUTENG_DRAGON") then
			haveTutorial = true
     	    app.tutorial:startTutorial(app.tutorial.Stage_DragonTotem)
		end
		if haveTutorial == false and page.cleanBuildLayer then
			page:cleanBuildLayer()
		end
	end
end

--等级引导
function QUIDialogSocietyUnionMain:levelGuide()
	if self._levelGuideWidget == nil then
		self._levelGuideWidget = QUIWidgetLevelGuide.new()
		self._levelGuideWidget:setPosition(ccp(display.width/2 + 80, 237-display.height/2))
		self:getView():addChild(self._levelGuideWidget)
		self._levelGuideWidget:setLevelIconScale(0.4)
	end
	self._levelGuideWidget:setLevel(remote.union.consortia.level, LEVEL_GOAL.UNION)
end

--当界面关闭的时候
function QUIDialogSocietyUnionMain:_onDialogClosed()
	self._dialogCloseSchedulerHander = scheduler.performWithDelayGlobal(function()
		self._dialogCloseSchedulerHander = nil
		self:backDialogMain()
	end, 0)
end

function QUIDialogSocietyUnionMain:_onTriggerTotem(event)
	if q.buttonEvent(event, self._ccbOwner.sp_totemBtn, self._ccbOwner.sp_totem_chui) == false then return end
	if self._isMoveing then
		return
	end
    app.sound:playSound("common_small")
	
	if remote.dragonTotem:checkTotemUnlock(true) then
		remote.dragonTotem:consortiaDragonDesignGetInfoRequest(self:safeHandler(function()
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDragonTotem"}, {isPopCurrentDialog = true})
			end))
	end
end

--describe：宗门答题
function QUIDialogSocietyUnionMain:_onTriggerUnionQuestion(event)
	if q.buttonEvent(event, self._ccbOwner.unionQuestionBtn) == false then return end
	if self._isMoveing then
		return
	end
    app.sound:playSound("common_small")

    if not app.unlock:getUnlockUnionQuestion(true) or remote.question:getQuestion() == nil then
		return false
	end
	-- app.tip:floatTip("暂未开启，敬请期待")
	local answerCount = remote.question:getQuestion().answerCount
	local maxCount = QStaticDatabase:sharedDatabase():getConfiguration().everyday_answer_num.value
	if answerCount == maxCount then
		app.tip:floatTip("宗门答题已结束，请改日再来~")
	else
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyUnionQuestion"}, {isPopCurrentDialog = true})
	end
	--app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyUnionQuestionFinalAward",options = {correctCount = 1,awards = {},doubleCount = 2}}, {isPopCurrentDialog = true})
end

function QUIDialogSocietyUnionMain:_onTriggerUnionRedPacket(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_redpacket) == false then return end
	if self._isMoveing then
		return
	end
	remote.redpacket:openDialog()
end

--describe：宗门战
function QUIDialogSocietyUnionMain:_onTriggerConsortiaWar(event)
	if q.buttonEvent(event, self._ccbOwner.consortiaWarBtn) == false then return end
	if self._isMoveing then
		return
	end
	remote.consortiaWar:openDialog()
end

-- 极北之地
function QUIDialogSocietyUnionMain:_onTriggerUnionPlunder(event)
	if q.buttonEvent(event, self._ccbOwner.unionPlunderBtn) == false then return end
	if self._isMoveing then
		return
	end

	self:getOptions().isTutorialPlunder = false
	if self._handTouch ~= nil then
		self._handTouch:removeFromParent()
		self._handTouch = nil
	end

    app.sound:playSound("common_small")
	if ENABLE_PLUNDER and remote.plunder:checkPlunderUnlock(true) then
		local timeStr, color, isActive, isOpen = remote.plunder:updateTime()
		if isOpen == false then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderOpen"})
		else
			remote.plunder:setCurCavePage( PAGE_NUMBER.ONE )
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderMap"})
		end
	end
end

--describe：宗门技能
function QUIDialogSocietyUnionMain:_onTriggerUnionSkill(event)
	if q.buttonEvent(event, self._ccbOwner.unionSkillBtn) == false then return end
	if self._isMoveing then
		return
	end
    app.sound:playSound("common_small")

    if not ENABLE_UNIONSKILL then return end
    
	local openLevel = QStaticDatabase.sharedDatabase():getConfigurationValue("SOCIATY_SKILL") or 0
	if openLevel > remote.union.consortia.level then
		app.tip:floatTip("宗门"..openLevel.."级开启宗门魂技")
		return
	end
	
	self:getOptions().distance = self._ccbOwner.closeRangeLayer:getPositionX()
	
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyUnionSkill", 
        options = {}}, {isPopCurrentDialog = true})
end

--describe：宗门副本
function QUIDialogSocietyUnionMain:_onTriggerUnionFuBen(event)
	if q.buttonEvent(event, self._ccbOwner.unionFuBenBtn) == false then return end
	if self._isMoveing then
		return
	end
    app.sound:playSound("common_small")
    self:getOptions().distance = self._ccbOwner.closeRangeLayer:getPositionX()

    if not ENABLE_UNION_DUNGEON then
		app.tip:floatTip("暂未开启，敬请期待")
		return
	end
	
	local needLevel = remote.union:getSocietyNeedLevel()
	if remote.union.consortia.level >= needLevel then
		remote.union:unionGetBossListRequest(function ( response )
			-- remote.union:setShowChapter(remote.union:getFightChapter())
			-- app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyDungeon", 
			-- 	options = {}}, {isPopCurrentDialog = true})
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyMap", 
				options = {}}, {isPopCurrentDialog = true})
		end, function ( response )
			app.tip:floatTip("无法获取实时BOSS信息，请检查下当前网络是否稳定。")
		end)
	else
		app.tip:floatTip("宗门"..needLevel.."级开启宗门副本")
	end
end

--describe：建设
function QUIDialogSocietyUnionMain:_onTriggerUnionBuilding(event)
	if q.buttonEvent(event, self._ccbOwner.unionBuildingBtn) == false then return end
	if self._isMoveing then
		return
	end
    app.sound:playSound("common_small")
	
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionBuilding", 
        options = {}}, {isPopCurrentDialog = true})
end

--describe：公告板
function QUIDialogSocietyUnionMain:_onTriggerUnionNotify(event)
	if q.buttonEvent(event, self._ccbOwner.unionNotifyBtn) == false then return end
	if self._isMoveing then
		return
	end
    app.sound:playSound("common_small")
	
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyAnnouncement", 
        options = {}}, {isPopCurrentDialog = true})
	
end

function QUIDialogSocietyUnionMain:_onDragonClickEvent(event)
	if self._isMoveing then
		return
	end
    app.sound:playSound("common_small")

	local isShowTips = false
    local config = app.unlock:getConfigByKey("SOCIATY_DRAGON")
    if remote.union.consortia.level + 2 >= (config.sociaty_level or 0) then
        isShowTips = true
    end
    if app.unlock:checkLock("SOCIATY_DRAGON", isShowTips) == false then
        return
    end
	remote.dragon:openDialog()
end

--describe：巨龙之战
function QUIDialogSocietyUnionMain:_onTriggerUnionDragonWar(event)
    if tonumber(event) == CCControlEventTouchDown then
    	self._animationManager:pauseAnimation()
    else
    	self._animationManager:resumeAnimation()
    end
	if q.buttonEvent(event, self._ccbOwner.unionDragonWarBtn) == false then
		return 
	end
	if self._isMoveing then
		return
	end
    app.sound:playSound("common_small")
	self:getOptions().distance = self._ccbOwner.closeRangeLayer:getPositionX()

	remote.unionDragonWar:openDragonWarDialog()
end

--describe：宗门活跃宝箱
function QUIDialogSocietyUnionMain:_onTriggerUnionChest()
	--代码
	if self._isMoveing then
		return
	end
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionActiveChest", 
        options = {}}, {isPopCurrentDialog = true})
end

--describe：宗门贡献
function QUIDialogSocietyUnionMain:_onTriggerUnionConsortia()
	--代码
	if self._isMoveing then
		return
	end
    app.sound:playSound("common_small")
	app.tip:floatTip("暂未开启，敬请期待")
end

function QUIDialogSocietyUnionMain:_onTriggerDragonTask()
	if self._isMoveing then
		return
	end
    app.sound:playSound("common_small")

    remote.dragon:openDragonTask()
end

function QUIDialogSocietyUnionMain:_onTriggerUnionShop(event)
	if self._isMoveing then
		return
	end
    app.sound:playSound("common_small")
    
	remote.stores:openShopDialog(SHOP_ID.consortiaShop)
end

function QUIDialogSocietyUnionMain:_onTriggerUnionManage()
	if self._isMoveing then
		return
	end
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyUnionManage", 
        options = {}}, {isPopCurrentDialog = true})
end

function QUIDialogSocietyUnionMain:_onTriggerDragonWarShop(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_dragon_war_shop) == false then return end
	if self._isMoveing then
		return
	end
    app.sound:playSound("common_small")

	remote.stores:openShopDialog(SHOP_ID.dragonWarShop)
end

function QUIDialogSocietyUnionMain:_onTriggerOfferReward(event)
	if q.buttonEvent(event, self._ccbOwner.offerRewardBtn) == false then return end
	if self._isMoveing then
		return
	end
    app.sound:playSound("common_small")

	remote.offerreward:openDialog()
end


--describe：关闭对话框
function QUIDialogSocietyUnionMain:close( )
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

--describe：viewAnimationOutHandler 
function QUIDialogSocietyUnionMain:viewAnimationOutHandler()
	--代码
end

--describe：viewDidAppear 
function QUIDialogSocietyUnionMain:viewDidAppear()
	--代码
	QUIDialogSocietyUnionMain.super.viewDidAppear(self)
	if self._touchLayer then
		self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onTouch))
	end
	if self._actorLayer then
		self._actorLayer:_updateActors()
		self._actorLayer:init()
	end

	self._dragonProxy = cc.EventProxy.new(remote.dragon)
    self._dragonProxy:addEventListener(remote.dragon.CHANGE_UPDATE, handler(self, self._updateDragon))
	
	self._redpacketProxy = cc.EventProxy.new(remote.redpacket)
    self._redpacketProxy:addEventListener(remote.redpacket.UPDATE_REDPACKET, handler(self, self._updateRedpacketRedTips))

	self._offerRewardProxy = cc.EventProxy.new(remote.offerreward)
    self._offerRewardProxy:addEventListener(remote.offerreward.EVENT_REFRESH, handler(self, self._updateOfferRewardRedTips))

    self._unionProxy = cc.EventProxy.new(remote.union)
    self._unionProxy:addEventListener(remote.union.UPDATE_DRAGON_TRAIN_BUFF, handler(self, self._checkDragonTrainBuffPrompt))

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_DIALOG_WILL_DISAPPEAR, self._onDialogClosed, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)

	if self._callFunc then
		self._callFunc()
	end

	self:_checkDragonTrainBuffPrompt()
end

--describe：viewWillDisappear 
function QUIDialogSocietyUnionMain:viewWillDisappear()
	--代码
	QUIDialogSocietyUnionMain.super.viewWillDisappear(self)
	if self._touchLayer then
		self._touchLayer:removeEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onTouch))
	end

	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end

	if self._unionGetBossListRequestScheduler then
		scheduler.unscheduleGlobal(self._unionGetBossListRequestScheduler)
		self._unionGetBossListRequestScheduler = nil
	end
	if self._dialogCloseSchedulerHander then
		scheduler.unscheduleGlobal(self._dialogCloseSchedulerHander)
		self._dialogCloseSchedulerHander = nil
	end

	self._dragonProxy:removeAllEventListeners()
	self._redpacketProxy:removeAllEventListeners()
	if self._offerRewardProxy then
		self._offerRewardProxy:removeAllEventListeners()
	end

	if self._unionProxy then
		self._unionProxy:removeAllEventListeners()
	end

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_DIALOG_WILL_DISAPPEAR, self._onDialogClosed, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)
end

function QUIDialogSocietyUnionMain:_exitFromBattle()
	self:initActor()
end

function QUIDialogSocietyUnionMain:checkBackground()
	local isDay = app:checkDayNightTime()

	local color = {119, 125, 255}
	local mountainColor = {172, 144, 200}

	-- 建筑
	local alphaData = { --1,变色的节点；2,变色的透明度 
		{ {"consortiaWarBtn", "unionPlunderBtn", "unionSkillBtn", "unionTa", "unionDragonBtn"}, 0.2 },

		{ {"unionBuildingBtn", "unionNotifyBtn", "unionHallBtn"}, 0.15 }, 

		{ {"totemBtn", "unionQuestionBtn", "unionFuBenBtn"}, 0.1 },
	 }
	for _, value in ipairs(alphaData) do
		if q.isEmpty(value[1]) == false then
			local realColor = ccc3(255, 255, 255)
			if not isDay then
				local alpha = value[2]
				alpha = alpha > 1 and 1 or alpha
				local brightness = 5
				realColor = ccc3(255 - color[1] * alpha - brightness, 255 - color[2] * alpha - brightness, color[3] - brightness)
			end

			for _, sprite in ipairs(value[1]) do
				if self._ccbOwner[sprite] then
					self._ccbOwner[sprite]:setColor(realColor)
				end
			end
		end
	end

	-- 大地
	local middleLands = {"sp_foreground_1", "sp_foreground_2", "sp_foreground_3"}
	for _, sprite in ipairs(middleLands) do
		local realColor = ccc3(255, 255, 255)
		if not isDay then
			local brightness = 35
			local saturation = 10
			local alpha = 0.5
			realColor = ccc3(255 - color[1] * alpha - brightness + saturation, 255 - color[2] * alpha - brightness + saturation, color[3] - brightness)
		end
		if self._ccbOwner[sprite] then
			self._ccbOwner[sprite]:setColor(realColor)
		end
	end

	-- 山脉
	local mountains = {"sp_mountain_1", "sp_mountain_2", "sp_mountain_3"}
	for _, sprite in ipairs(mountains) do
		local realColor = ccc3(255, 255, 255)
		if not isDay then
			local brightness = 15
			realColor = ccc3(mountainColor[1] - brightness, mountainColor[2] - brightness, mountainColor[3] - brightness)
		end
		if self._ccbOwner[sprite] then
			self._ccbOwner[sprite]:setColor(realColor)
		end
	end

	-- 天空
	self._ccbOwner.node_day_sky:setVisible(isDay)
	self._ccbOwner.node_night_sky:setVisible(not isDay)

	return isDay
end

function QUIDialogSocietyUnionMain:isShowSnow()
	local date = q.date("%Y/%m/%d",q.serverTime())
	local snow = false
	local snowStartTime = QStaticDatabase:sharedDatabase():getConfigurationValue("main_scene_winter_start")
	local snowEndTime = QStaticDatabase:sharedDatabase():getConfigurationValue("main_scene_winter_end")
	if date >= snowStartTime and date <= snowEndTime then
		snow = true
	end

	return snow
end

function QUIDialogSocietyUnionMain:checksnow()
	local snow = self:isShowSnow()
	return snow
end

function QUIDialogSocietyUnionMain:checkDeputyLimitRight(callback)
	local showTips, hasRight = remote.union:checkDeputyLimitRightTips()
	if showTips then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionDeputyLimitRightTip",
			options = {hasRight = hasRight, callback = callback}})
	else
		callback()
	end
end

function QUIDialogSocietyUnionMain:checkFreeTokenRedPacketTips(callback)
	local showTips = remote.union:checkFreeTokenRedPacketTips()
	if showTips then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionRedpacketFreeTimeAlert",
			options = {callback = callback}})
	else
		callback()
	end
end

function QUIDialogSocietyUnionMain:_checkDragonTrainBuffPrompt()
	if self._isDragonTrainBuffPromptPlaying then return end

	self._isDragonTrainBuffPromptPlaying = true
	local buffIcon = nil
	if self._societyDragonTrainBuffIcon then
		buffIcon = self._societyDragonTrainBuffIcon:getIcon()
		buffIcon:setVisible(false)
	else
		return
	end

	if buffIcon and remote.user.userConsortia and remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" then
		local isDragonTrainBuff = remote.union:isDragonTrainBuff()
		if isDragonTrainBuff then
			local consortiaId = remote.user.userConsortia.consortiaId
			local userId = remote.user.userId
			local key = "DT_BUFF_"..userId.."_"..consortiaId
			local isNotFirstEnter = app:getUserOperateRecord():getRecordByType(key)
			if not isNotFirstEnter then
        		local dragonLevel = db:getConfigurationValue("sociaty_dragon_buff_dragon_level") or 5
        		local continueDay = db:getConfigurationValue("sociaty_dragon_buff_time") or 14

				local content = {}
		        table.insert(content, {oType = "font", content = "魂师大人，因为您所在的宗门武魂达到了", size = 24, color = ccc3(255,215,172)})
		        table.insert(content, {oType = "font", content = dragonLevel, size = 24, color = ccc3(255,255,255)})
		        table.insert(content, {oType = "font", content = "级，触发了斗罗大陆的武魂神赐，在升"..dragonLevel.."级之后的", size = 24, color = ccc3(255,215,172)})
		        table.insert(content, {oType = "font", content = continueDay, size = 24, color = ccc3(255,255,255)})
		        table.insert(content, {oType = "font", content = "天内，完成武魂任务及领取宝箱均会获得", size = 24, color = ccc3(255,215,172)})
		        table.insert(content, {oType = "font", content = "额外100%", size = 24, color = ccc3(255,255,255)})
		        table.insert(content, {oType = "font", content = "的武魂经验奖励哦～", size = 24, color = ccc3(255,215,172)})
				local titlePath = QResPath("dragonTrainBuffPromptTitle")
				local iconPath = QResPath("dragonTrainBuffIcon")

				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDragonTrainBuffPrompt", 
					options = {content = content, titlePath = titlePath, iconPath = iconPath, buffIcon = buffIcon, callback = callback}})
				app:getUserOperateRecord():setRecordByType(key, true)
				return
			end
		end
	end

	if buffIcon then
		buffIcon:setVisible(true)
	end
	self._isDragonTrainBuffPromptPlaying = false
end

return QUIDialogSocietyUnionMain
