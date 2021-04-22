--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂力试炼主场景
--
local QUIDialog = import(".QUIDialog")
local QUIDialogSoulTrialClient = class("QUIDialogSoulTrialClient", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetSoulTrialFirst = import("..widgets.QUIWidgetSoulTrialFirst")
local QUIWidgetSoulTrialFirstNew = import("..widgets.QUIWidgetSoulTrialFirstNew")
local QUIWidgetSoulTrialBubble = import("..widgets.QUIWidgetSoulTrialBubble")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")

function QUIDialogSoulTrialClient:ctor(options)
	local ccbFile = "ccb/Dialog_SoulTrial_Client.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogSoulTrialClient._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, QUIDialogSoulTrialClient._onTriggerHelp)},
	}

	QUIDialogSoulTrialClient.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
 	page:setScalingVisible(false)
    page.topBar:showWithSoulTrial()
    
    CalculateUIBgSize(self._ccbOwner.sp_bg)

    remote.flag:get({remote.flag.SOULTRIAL_FLAG}, handler(self, self._flagHandler))

    self:_init(true)
end

function QUIDialogSoulTrialClient:_flagHandler(value)
	-- QPrintTable(tbl)
	-- print(tbl)
	if type(value) == "table" then
		self._flag = tonumber(value[remote.flag.SOULTRIAL_FLAG])
	elseif type(value) == "number" then
		self._flag = value
	end
	-- print(self._flag)

	if self._flag and self._flag == 1 then
		self:_init()
	end
end

function QUIDialogSoulTrialClient:viewDidAppear()
	QUIDialogSoulTrialClient.super.viewDidAppear(self)
	self:addBackEvent()

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)
end

function QUIDialogSoulTrialClient:viewWillDisappear()
	QUIDialogSoulTrialClient.super.viewWillDisappear(self)

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)
end

-- 对话框退出
function QUIDialogSoulTrialClient:onTriggerBackHandler(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 对话框退出
function QUIDialogSoulTrialClient:onTriggerHomeHandler(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QUIDialogSoulTrialClient:_exitFromBattle()
	-- print("QUIDialogSoulTrialClient:_exitFromBattle()  ", remote.user.soulTrial)
	-- 抛出事件，刷新魂师
	remote.soulTrial:dispatchSoulTrialUpdateHerosEvent()

	local _,  curConfig = remote.soulTrial:getChapterById(remote.user.soulTrial)
	if curConfig and curConfig.boss == 1 then
		self:_showImprove()
	end
	self:_init( true )
end

function QUIDialogSoulTrialClient:_showBossInfo( curConfig )
	self._isImproving = false
	app:getNavigationManager():pushViewController(app.middleLayer, 
        {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulTrialFight", options = {config = curConfig}})
end

function QUIDialogSoulTrialClient:_onTriggerConfirm(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_confirm) == false then return end
	if self._isImproving then return end
	app.sound:playSound("common_small")
	self._isImproving = true
	local _, curConfig = remote.soulTrial:getChapterById( remote.user.soulTrial + 1 )
	if curConfig.boss == 1 then
		if curConfig.condition_1 == 201 or curConfig.condition_2 == 201 then
			self:_showBossInfo( curConfig )
		    return
		end
	else
		if curConfig.light_point then
		 	self._curAnimationPlayer:playAnimation(curConfig.light_point, function( ccb )
		 			ccb.fca_animtion:setVisible(true)
					local fca = tolua.cast(ccb.fca_animtion, "QFcaSkeletonView_cpp")
					fca:stopAnimation()
					fca:connectAnimationEventSignal(handler(self, self._fcaHandler))
	    			fca:playAnimation(string.split(fca:getAvailableAnimationNames(), ";")[1], false)
				end, nil, false)
		 	return
		end
	end
	
	self:_requestPass()
end

function QUIDialogSoulTrialClient:_fcaHandler(eventType)
	if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
		self:_requestPass()
	elseif eventType == SP_ANIMATION_START then
	end
end

function QUIDialogSoulTrialClient:_requestPass()
	remote.soulTrial:soulTrialImproveRequest(self:safeHandler(function()
			self:_showPass()
			self:_init()
		end))
end

function QUIDialogSoulTrialClient:_showPass()
	local _, preConfig = remote.soulTrial:getChapterById( remote.user.soulTrial )
	app:getNavigationManager():pushViewController(app.middleLayer, 
        {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulTrialPass", options = {config = preConfig}})
end

function QUIDialogSoulTrialClient:_showImprove()
	-- print(" QUIDialogSoulTrialClient:_showImprove() ", remote.user.soulTrial)
	local curChapter, preChapter = remote.soulTrial:getCurChapter( remote.user.soulTrial - 1, true )
	-- print(curChapter, preChapter)
	local preBossConfig = remote.soulTrial:getBossConfigByChapter( preChapter )
	-- QPrintTable(preBossConfig)
	local curBossConfig = remote.soulTrial:getBossConfigByChapter( curChapter )
	-- QPrintTable(curBossConfig)
	app:getNavigationManager():pushViewController(app.middleLayer, 
        {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulTrialImprove", options = {config = curBossConfig, preConfig = preBossConfig}})
end

function QUIDialogSoulTrialClient:_onTriggerHelp(event)
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, 
        {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulTrialHelp", options = {}})
end

function QUIDialogSoulTrialClient:_firstClickHandler()
	if not self._flag or self._flag == 0 then
		remote.flag:set(remote.flag.SOULTRIAL_FLAG, 1, handler(self, self._flagHandler))
	else
		self:_init()
	end
end

function QUIDialogSoulTrialClient:_init( isReset )
	-- print("QUIDialogSoulTrialClient:_init() soulTrial = ", remote.user.soulTrial, self._flag)
	self._ccbOwner.node_client:removeAllChildren()
	self._ccbOwner.node_info:setVisible(false)
	self._ccbOwner.node_condition:setVisible(false)
	self._isImproving = false -- 是否正在升级
	if not self._flag or self._flag == 0 then
		-- local firstWidget = QUIWidgetSoulTrialFirst.new()
		-- firstWidget:addEventListener(QUIWidgetSoulTrialFirst.SOULTRIAL_CLICK, handler(self, self._firstClickHandler))
		local firstWidget = QUIWidgetSoulTrialFirstNew.new()
		firstWidget:addEventListener(QUIWidgetSoulTrialFirstNew.SOULTRIAL_CLICK, handler(self, self._firstClickHandler))
		self._ccbOwner.node_client:addChild(firstWidget)
	else
		self:_initInfo( isReset )
		self:_initCondition()
		self:_initClient( isReset )
	end
end

function QUIDialogSoulTrialClient:_initInfo( isReset )
	-- print("QUIDialogSoulTrialClient:_initInfo() soulTrial = ", remote.user.soulTrial)
	local curChapter, preChapter = remote.soulTrial:getCurChapter(remote.user.soulTrial, isReset)
	local preBossConfig = remote.soulTrial:getBossConfigByChapter( preChapter )
	local curBossConfig = remote.soulTrial:getBossConfigByChapter( curChapter)

	-- 标题
	if not curBossConfig.title_name then
		self._ccbOwner.tf_info_title:setString("可获得全队属性加成：")
	else
		self._ccbOwner.tf_info_title:setString("进阶"..curBossConfig.title_name.."可获得全队属性加成：")
	end

	-- 头像
	self._ccbOwner.node_head:removeAllChildren()
	local avatar = QUIWidgetAvatar.new(remote.user.avatar)
	avatar:setSilvesArenaPeak(remote.user.championCount)
    self._ccbOwner.node_head:addChild(avatar)

	local url = preBossConfig.title_icon3
	if url then
		local sprite = CCSprite:create(url)
		sprite:setAnchorPoint(ccp(0, 0.5))
		self._ccbOwner.node_soulTrial:removeAllChildren()
		self._ccbOwner.node_soulTrial:addChild(sprite)
		local titleX = self._ccbOwner.node_soulTrial:getPositionX() + sprite:getContentSize().width + 10
		self._ccbOwner.tf_info_title:setPositionX(titleX)
	end

	-- 生命
	local preValue = preBossConfig and (preBossConfig.team_hp_value or 0) or 0
	self._ccbOwner.tf_value_1:setString(preValue)
	local curValue = curBossConfig and (curBossConfig.team_hp_value or 0) or 0
	if curValue - preValue > 0 then
		self._ccbOwner.tf_addValue_1:setString("+"..(curValue - preValue))
	else
		self._ccbOwner.tf_addValue_1:setString("+0")
	end



	-- 攻击
	preValue = preBossConfig and (preBossConfig.team_attack_value or 0) or 0
	self._ccbOwner.tf_value_2:setString(preValue)
	curValue = curBossConfig and (curBossConfig.team_attack_value or 0) or 0
	if curValue - preValue > 0 then
		self._ccbOwner.tf_addValue_2:setString("+"..(curValue - preValue))
	else
		self._ccbOwner.tf_addValue_2:setString("+0")
	end


	-- 物防
	preValue = preBossConfig and (preBossConfig.team_armor_physical or 0) or 0
	self._ccbOwner.tf_value_3:setString(preValue)
	curValue = curBossConfig and (curBossConfig.team_armor_physical or 0) or 0
	if curValue - preValue > 0 then
		self._ccbOwner.tf_addValue_3:setString("+"..(curValue - preValue))
	else
		self._ccbOwner.tf_addValue_3:setString("+0")
	end

	-- 魔防
	preValue = preBossConfig and (preBossConfig.team_armor_magic or 0) or 0
	self._ccbOwner.tf_value_4:setString(preValue)
	curValue = curBossConfig and (curBossConfig.team_armor_magic or 0) or 0
	if curValue - preValue > 0 then
		self._ccbOwner.tf_addValue_4:setString("+"..(curValue - preValue))
	else
		self._ccbOwner.tf_addValue_4:setString("+0")
	end

    local design_max_front_desc_width = 110
	local actual_front_desc_width = self._ccbOwner.tf_value_1:getContentSize().width + self._ccbOwner.tf_addValue_1:getContentSize().width
	actual_front_desc_width = math.max(design_max_front_desc_width ,actual_front_desc_width)
	local width = self._ccbOwner.tf_value_2:getContentSize().width + self._ccbOwner.tf_addValue_2:getContentSize().width
	actual_front_desc_width = math.max(width ,actual_front_desc_width)
	if actual_front_desc_width > design_max_front_desc_width then
		self._ccbOwner.node_value_3:setPositionX(actual_front_desc_width - design_max_front_desc_width)
		self._ccbOwner.node_value_4:setPositionX(actual_front_desc_width - design_max_front_desc_width)
	end

	self._ccbOwner.node_info:setVisible(true)
end

function QUIDialogSoulTrialClient:_initCondition()
	-- print("QUIDialogSoulTrialClient:_initCondition() soulTrial = ", remote.user.soulTrial)
	-- 根据条件完成情况标记颜色
	-- 修改按钮灰明状态
	local _, curConfig = remote.soulTrial:getChapterById( remote.user.soulTrial + 1 )

	if curConfig and #curConfig > 0 then
		local conditionNum = 0
		local completeNum = 0

		-- 当前节点的名字
		self._ccbOwner.tf_soulTrialName:setString(curConfig.name.."：" or "")

		-- 条件1
		if curConfig.condition_1 then
			conditionNum = conditionNum + 1
			local tbl = string.split(curConfig.num_1, ";")
			local isComplete, conditionStr, isShow = remote.soulTrial:checkCondition(curConfig.condition_1, tbl)
			if isShow then
				if isComplete then
					completeNum = completeNum + 1
					self._ccbOwner.tf_condition_1:setColor(COLORS.B)
				else
					self._ccbOwner.tf_condition_1:setColor(COLORS.a)
				end
				self._ccbOwner.tf_condition_1:setString(curConfig.describle_1.." "..conditionStr or "")
				self._ccbOwner.node_condition_1:setVisible(true)
			else
				if isComplete then
					completeNum = completeNum + 1
				end
				self._ccbOwner.node_condition_1:setVisible(false)
			end
		else
			self._ccbOwner.node_condition_1:setVisible(false)
		end
		
		-- 条件2
		if curConfig.condition_2 then
			conditionNum = conditionNum + 1
			local tbl = string.split(curConfig.num_2, ";")
			local isComplete, conditionStr, isShow = remote.soulTrial:checkCondition(curConfig.condition_2, tbl)
			if isShow then
				if isComplete then
					completeNum = completeNum + 1
					self._ccbOwner.tf_condition_2:setColor(COLORS.B)
				else
					self._ccbOwner.tf_condition_2:setColor(COLORS.a)
				end
				self._ccbOwner.tf_condition_2:setString(curConfig.describle_2.." "..conditionStr or "")
				self._ccbOwner.node_condition_2:setVisible(true)
			else
				if isComplete then
					completeNum = completeNum + 1
				end
				self._ccbOwner.node_condition_2:setVisible(false)
			end
		else
			self._ccbOwner.node_condition_2:setVisible(false)
		end

		if curConfig.boss == 1 then
			self._ccbOwner.tf_btn:setString("挑 战")
		else
			self._ccbOwner.tf_btn:setString("点 亮")
		end

		if conditionNum == completeNum then
			self._ccbOwner.btn_confirm:setEnabled(true)
			makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
			self._ccbOwner.tf_btn:enableOutline() 
		else
			self._ccbOwner.btn_confirm:setEnabled(false)
			makeNodeFromNormalToGray(self._ccbOwner.node_btn)
			self._ccbOwner.tf_btn:disableOutline() 
		end

		self._ccbOwner.node_condition:setVisible(true)
	else
		self._ccbOwner.node_condition:setVisible(false)
	end

	self._ccbOwner.soulTrial_tips:setVisible(remote.soulTrial:redTips())
end

function QUIDialogSoulTrialClient:_initTitle( isReset )
	-- print("QUIDialogSoulTrialClient:_initTitle() soulTrial = ", remote.user.soulTrial)
	local chapterList, bossDic = remote.soulTrial:getChapterListById(remote.user.soulTrial)
	local curChapter = remote.soulTrial:getCurChapter(remote.user.soulTrial, isReset)
	-- QPrintTable(chapterList)
	-- QPrintTable(bossDic)
	for index, chapter in ipairs(chapterList) do
		local node = self._ccbOwner["node_title_"..index]
		if node then
			node:removeAllChildren()
			local sprite = nil
			local bossConfig = bossDic[tostring(chapter)]
			if chapter == curChapter then
				sprite = CCSprite:create("ui/update_soulTrial/sp_title_bg1.png")
				if sprite then
					node:addChild(sprite)
				end
				if bossConfig and bossConfig.title_icon1 and bossConfig.title_icon2 then
					local kuang = CCSprite:create(bossConfig.title_icon2)
					if kuang then
						node:addChild(kuang)
					end
					sprite = CCSprite:create(bossConfig.title_icon1)
					if sprite then
						node:addChild(sprite)
					end
				else
					node:removeAllChildren()
				end
			else
				sprite = CCSprite:create("ui/update_soulTrial/sp_title_bg2.png")
				if sprite then
					node:addChild(sprite)
				end
				if bossConfig and bossConfig.title_icon1 then
					local sprite = CCSprite:create(bossConfig.title_icon1)
					if sprite then
						node:addChild(sprite)
					end
				else
					node:removeAllChildren()
				end
			end

			if index > 3 then
				makeNodeFromNormalToGray(node)
			end
		end
	end
end

function QUIDialogSoulTrialClient:_initClient( isReset )
	-- print("QUIDialogSoulTrialClient:_initClient() soulTrial = ", remote.user.soulTrial)
 	local curChapter = remote.soulTrial:getCurChapter(remote.user.soulTrial, isReset)
 	local chapterConfigList = q.cloneShrinkedObject(remote.soulTrial.soulTrialConfig[tonumber(curChapter)])
 	local preConfig = nil
 	-- print(curChapter)
 	-- QPrintTable(chapterConfigList)
 	self._pointNodeList = {}
 	self._curIndex = 0

 	if not chapterConfigList or #chapterConfigList == 0 then
 		-- 最后章节通关的情况
 		chapterConfigList = q.cloneShrinkedObject(remote.soulTrial.soulTrialConfig[tonumber(curChapter) - 1])
 	end

 	-- @@@@ jk的bug表现出来的这个时候，chapterConfigList 是魂师的列表
 	for index, config in ipairs(chapterConfigList) do
 		local node = CCNode:create()
 		self._pointNodeList[tonumber(index)] = node
 		self._ccbOwner.node_client:addChild(node)
 		if tonumber(config.id) == remote.user.soulTrial + 1 then
 			config.point_scale = config.point_scale + 0.05
 			self._curIndex = tonumber(index)
 		end

 		self:_createPoint(config, node)

 		if config.boss == 1 or tonumber(config.id) == remote.user.soulTrial + 1 then
 			self:_createBubble(config, self._ccbOwner.node_client)
 		end
 		if preConfig then
 			self:_createLine(config, preConfig, self._ccbOwner.node_client)
 		end
 		preConfig = config
 	end

 	self:_initTitle()
end

function QUIDialogSoulTrialClient:_createAnimation( ccbFile, x, y, scale, node )
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    node:addChild(aniPlayer)
    aniPlayer:setPosition(x, y)
    aniPlayer:playAnimation(ccbFile, nil, nil, false)

    return aniPlayer
end

function QUIDialogSoulTrialClient:_createPoint( config, node )
	-- @@@@ jk的bug表现出来的这个时候，config 是魂师的
	node:setPositionX(tonumber(config.point_x))
	node:setPositionY(tonumber(config.point_y))
	node:setScale(tonumber(config.point_scale))
 	local id = tonumber(config.id)

 	if id == remote.user.soulTrial + 1 then
 		-- 待激活
 		-- current_point
 		local sprite = CCSprite:create(config.point_icon)
 		if sprite then
 			node:addChild(sprite)
 		end
 		if config.current_point then
			self._curAnimationPlayer = self:_createAnimation( config.current_point, 0, 0, 1, node )
 		end
	elseif id < remote.user.soulTrial + 1 then
		-- 已激活
		-- finish_point
		if config.finish_point then
			self:_createAnimation( config.finish_point, 0, 0, 1, node )
 		end
	else
		-- 未激活
		local sprite = CCSprite:create(config.point_icon)
 		if sprite then
 			node:addChild(sprite)
 		end
	end
end

function QUIDialogSoulTrialClient:_createBubble( config, node )
	local widget = QUIWidgetSoulTrialBubble.new({config = config})
	widget:setPositionX(config.point_x)
	widget:setPositionY(config.point_y)
	node:addChild(widget, 100)
end

function QUIDialogSoulTrialClient:_createLine( config, preConfig, node )

	print("config.point_x, config.point_y",config.point_x, config.point_y)
	print("================")
	print("preConfig.point_x, preConfig.point_y",preConfig.point_x, preConfig.point_y)
	local line = CCSprite:create(QResPath("blue_light_line"))
    line:setAnchorPoint(ccp(0.0, 0.5))
	line:setPosition(ccp(preConfig.point_x, preConfig.point_y))

    local angleX, angleY = config.point_x - preConfig.point_x, config.point_y - preConfig.point_y
    local scaleX = math.sqrt(angleX * angleX + angleY * angleY)
	local rotate = math.deg(-1.0*math.atan2(angleY, angleX))
   	line:setScaleX(scaleX)
    line:setRotation(rotate)
 	node:addChild(line, -1)
end

return QUIDialogSoulTrialClient