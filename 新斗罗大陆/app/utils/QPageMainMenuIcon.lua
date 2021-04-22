--
-- Kumo.wang
-- 主界面icon管理類
--
local QPageMainMenuIcon = class("QPageMainMenuIcon")

local QUIViewController = import("..ui.QUIViewController")
local QVIPUtil = import(".QVIPUtil")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..ui.widgets.QUIWidgetAnimationPlayer")
local QUIWidgetIconAniTips = import("..ui.widgets.QUIWidgetIconAniTips")
local QQuickWay = import("..utils.QQuickWay")
local QUIWidgetNormalTheme = import("..ui.widgets.QUIWidgetNormalTheme")
local QUIWidgetActivityTheme = import("..ui.widgets.QUIWidgetActivityTheme")
local QTutorialDirector = import("..tutorial.QTutorialDirector")
local QUIDialogHeroReborn = import("..ui.dialogs.QUIDialogHeroReborn")
 
----------------------icon顺序说明-------------------------------------
--- orderIndex 位置显示
	--- 充值=1
	--- 新服活动（2～99）
		--7日登录-2
		--半月登录-3
		--首充类-4
		--嘉年华-7
		--半月庆典-8
	--- 主题活动（100）
		--周年狂欢-100
	--- 限时活动（101）
	--- 日常活动（102）
	--- 配置类轮次活动（103～199）
		--打铁-103
		--团购-104
		--夺宝-105
		--手札-106
	--- 触发类活动（200～299）
		--问卷调查-200
		--福利追回-201
		--等级礼包-202
		--老玩家回归-203
		--魂师召回-204
	--- 周期类活动（300～399）
		--极北之地-300
		--魔鲸来袭-300
		--活跃转盘-301
		--天降红包-302
	--- 常驻类活动（400～499）
		--每日签到-400 
		--月度签到-401
		--商城-402
		--重生-403
		--成就-404
		--任务-405
		--小舞助手-406
		--邮件-407
		--好友-408
		--大师课堂-409
		--玩法日历-410
	--- 特殊渠道类活动 （500～）
		--vivo特权-500
--- haveScanning true or false 是否有扫光
----------------------------------------------------------------------
function QPageMainMenuIcon:ctor(mainMenuPage)
	if not mainMenuPage then
		return nil
	end

	self._mainMenuPage = mainMenuPage
	self._iconWidgets = {}
	self._tmpWidgetsCache = {}
	self._spaceX = 86
	self._spaceY = 80
	self._indexForNode = 1
	self._typeForKeysList = 1

	-- self._allRowKeysList = {"node_sign", "node_mall", "node_mail", "node_friend", "node_reborn", "node_recharge", "node_master", "node_task",
	-- 	"node_activity", "node_active_limit", "node_month_signin", "node_firstRecharge", "node_active_qiri", "node_active_banyue", 
	-- 	"node_sevenday", "node_fourteenday", "node_calendar", "node_active_turntable", "node_active_groupbuy", "node_fuli", "node_active_rushBuy", 
	-- 	"node_carnival", "node_prompt", "node_comeback", "node_gradePackage", "node_player_recall","node_secretary","node_activite_skyfall","node_game_center",
	-- 	"node_questionnaire","node_achieve"
	-- }
	-- 界面icon的布局设定
	self._rowOneKeysList = {"node_sign", "node_mall", "node_mail", "node_friend", "node_reborn", "node_recharge", "node_master", "node_task"}
	self._rowTwoKeysList = {"node_activity", "node_active_limit", "node_month_signin", "node_firstRecharge", "node_active_qiri", "node_active_banyue", 
		"node_sevenday", "node_fourteenday", "node_calendar", "node_active_turntable", "node_active_groupbuy", "node_fuli", "node_active_rushBuy", 
		"node_carnival", "node_prompt", "node_comeback", "node_gradePackage", "node_player_recall","node_secretary","node_activite_skyfall","node_game_center"
		,"node_yingyongbao"
		}
	self._rowTwoEndKeysList = {"node_questionnaire"}

	-- 配置icon的一些屬性，比如回調函數
	self._iconConfigs = {
		node_sign = {
			info = {
				{name = "每日签到", path = "ui/Activity_game/activity_icon/meiriqiandao.png",haveScanning = false},
			},
			orderIndex = 400,
			callback = handler(self, self._onTriggerDialy),
		},
		node_mall = {
			info = {
				{name = "商城", path = "ui/Activity_game/activity_icon/shangcheng.png",haveScanning = false},
			},
			orderIndex = 402,
			callback = handler(self, self._onTriggerMall),
		},
		node_mail = {
			info = {
				{name = "邮件", path = "ui/Activity_game/activity_icon/youjian.png",haveScanning = false},
			},
			orderIndex = 407,
			callback = handler(self, self._onMail),
		},
		node_friend = {
			info = {
				{name = "好友", path = "ui/Activity_game/activity_icon/haoyou.png",haveScanning = false},
			},
			orderIndex = 408,
			callback = handler(self, self._onTriggerFriend),
		},
		node_reborn = {
			info = {
				{name = "重生", path = "ui/Activity_game/activity_icon/chongsheng.png",haveScanning = false},
			},
			orderIndex = 403,
			callback = handler(self, self._onHeroReborn),
		},
		node_recharge = {
			info = {
				{name = "充值", path = "ui/Activity_game/activity_icon/chongzhi.png",haveScanning = true},
			},
			orderIndex = 1,
			callback = handler(self, self._onTriggerRecharge),
		},
		node_achieve = {
			info = {
				{name = "成就", path = "ui/Activity_game/activity_icon/chengjiu.png",haveScanning = false},
			},
			orderIndex = 404,
			callback = handler(self, self._onTriggerAchieve),
		},
		node_task = {
			info = {
				{name = "任务", path = "ui/Activity_game/activity_icon/btn_paper.png",haveScanning = false},
			},
			orderIndex = 405,
			callback = handler(self, self._onTriggerTask),
		},		
		node_master = {
			info = {
				{name = "大师课堂", path = "ui/Activity_game/activity_icon/dashiketang.png",haveScanning = false},
			},
			orderIndex = 409,
			callback = handler(self, self._onTriggerMasterClass),
		},
		node_secretary = {
			info = {
				{name = "小舞助手", path = "ui/Activity_game/activity_icon/xiaowuzhushou.png",haveScanning = false},
			},
			orderIndex = 406,
			callback = handler(self, self._onTriggerSecretary),
		},		
		node_activity = {
			info = {
				{name = "日常活动", path = "ui/Activity_game/activity_icon/richanghuodong.png",haveScanning = true},
			},
			orderIndex = 102,
			callback = handler(self, self._onTriggerActivity),
		},
		node_active_limit = {
			info = {
				{name = "限时活动", path = "ui/Activity_game/activity_icon/xianshihuodong.png",haveScanning = true},
			},
			orderIndex = 101,
			callback = handler(self, self._onTriggerActivityLimit),
		},
		node_month_signin = {
			info = {
				{name = "月度签到", path = "ui/Activity_game/activity_icon/yueduqiandao.png",haveScanning = false},
			},
			orderIndex = 401,
			callback = handler(self, self._onTriggerMonthSignIn),
		},
		node_firstRecharge = {
			info = {
				{name = "首充奖励", path = "ui/Activity_game/activity_icon/shouchongjiangli.png", index = 1,haveScanning = true},
				{name = "首充豪礼", path = "ui/Activity_game/activity_icon/denglufulitangsan.png", index = 2,haveScanning = true},
				{name = "开服基金", path = "ui/Activity_game/activity_icon/richanghuodong.png", index = 3,haveScanning = true},
			},
			orderIndex = 4,
			callback = handler(self, self._onTriggerFirstRecharge),
		},
		node_active_qiri = {
			info = {
				{name = "嘉年华", path = "ui/Activity_game/activity_icon/jianianhua.png",haveScanning = true},
			},
			orderIndex = 7,
			callback = handler(self, self._onTriggerActivitySeven),
		},
		node_active_banyue = {
			info = {
				{name = "半月庆典", path = "ui/Activity_game/activity_icon/banyueqingdian.png",haveScanning = true},
			},
			orderIndex = 8,
			callback = handler(self, self._onTriggerActivityBanyue),
		},
		node_sevenday = {
			info = {
				{name = "登录福利", path = "ui/Activity_game/activity_icon/shouchonghaoli.png", index = 1, isCountdown = true,haveScanning = true},
				{name = "登录福利", path = "ui/Activity_game/activity_icon/wuridenglu.png", index = 2, isCountdown = true,haveScanning = true},
				{name = "登录福利", path = "ui/Activity_game/activity_icon/yijianzhongqing.png", index = 3, isCountdown = true,haveScanning = true},
			},
			orderIndex = 2,
			callback = handler(self, self._onTriggerActivitySevenDay),
		},
		node_fourteenday = {
			info = {
				{name = "半月登录", path = "ui/Activity_game/activity_icon/shisiridenglu.png",haveScanning = true},
			},
			orderIndex = 3,
			callback = handler(self, self._onTriggerActivityFourteenDay),
		},
		node_calendar = {
			info = {
				{name = "玩法日历", path = "ui/Activity_game/activity_icon/wanfarili.png",haveScanning = false},
			},
			orderIndex = 410,
			callback = handler(self, self._onTriggerCalendar),
		},
		node_active_turntable = {
			info = {
				{name = "活跃转盘", path = "ui/Activity_game/activity_icon/huoyuezhuanpan.png",haveScanning = true},
			},
			orderIndex = 301,
			callback = handler(self, self._onTriggerActivityTurntable),
		},
		node_active_groupbuy = {
			info = {
				{name = "限时团购", path = "ui/Activity_game/activity_icon/xianshituangou.png",haveScanning = true},
			},
			orderIndex = 104,
			callback = handler(self, self._onTriggerActivityGroupBuy),
		},
		node_fuli = {
			info = {
				{name = "福利追回", path = "ui/Activity_game/activity_icon/fulizhuihui.png", isCountdown = true,haveScanning = true},
			},
			orderIndex = 201,
			callback = handler(self, self._onTriggerFuli),
		},
		node_active_rushBuy = {
			info = {
				{name = "幸运夺宝", path = "ui/Activity_game/activity_icon/xingyunduobao.png",haveScanning = true},
			},
			orderIndex = 105,
			callback = handler(self, self._onTriggerActivityRushBuy),
		},
		node_carnival = {
			info = {
				{name = "周年狂欢", path = "ui/Activity_game/activity_icon/zhouniankuanghuan.png",haveScanning = true},
			},
			orderIndex = 100,
			callback = handler(self, self._onTriggerActivityCarnival),
		},
		node_prompt = {
			info = {
				{name = "魔鲸来袭", path = "ui/Activity_game/activity_icon/mojinglaixi.png", index = 1, isCountdown = true,haveScanning = true},
				{name = "极北之地", path = "ui/Activity_game/activity_icon/jibeizhidi.png", index = 2, isCountdown = true,haveScanning = true},
			},
			orderIndex = 300,
			callback = handler(self, self._onTriggerPrompt),
		},
		node_comeback = {
			info = {
				{name = "魂师召回", path = "ui/Activity_game/activity_icon/hunshizhaohui.png",haveScanning = true},
			},
			orderIndex = 204,
			callback = handler(self, self._onTriggerComeBack),
		},
		node_gradePackage = {
			info = {
				{name = "等级礼包", path = "ui/Activity_game/activity_icon/dengjilibao.png", isCountdown = true,haveScanning = true},
			},
			orderIndex = 202,
			callback = handler(self, self._onTriggerGradePakge),
		},
		node_player_recall = {
			info = {
				{name = "老玩家回归", path = "ui/Activity_game/activity_icon/laowanjiahuigui.png",haveScanning = true},
			},
			orderIndex = 203,
			callback = handler(self, self._onTriggerPlayerRecall),
		},
		node_activite_skyfall = {
			info = {
				{name = "天降红包", path = "ui/Activity_game/activity_icon/tianjiangfudai.png",haveScanning = true},
			},
			orderIndex = 302,
			callback = handler(self, self._onTriggerOpenSkyFall),
		},

		node_game_center = {
			info = {
				{name = remote.activity:getChannelGameCenterAtyName(), path = "ui/Activity_game/activity_icon/vivo.png",haveScanning = false},
			},
			orderIndex = 500,
			callback = handler(self, self._onTriggerGameCenter),
		},
		node_yingyongbao = {
			info = {
				{name = "霸服特权", path = "ui/Activity_game/activity_icon/yingyongbao_privilege.png",haveScanning = false},
			},
			orderIndex = 501,
			callback = handler(self, self._onTriggerYingyongbaoBafu),
		},

		node_questionnaire = {
			info = {
				{name = "问卷调查", path = "ui/Activity_game/activity_icon/wenjuandiaocha.png",haveScanning = true},
			},
			orderIndex = 200,
			callback = handler(self, self._onTriggerQuestionnaire),
		},

	

	}
	self:_initData()
	-- self:initNode()
end

-- function QPageMainMenuIcon:initNode( )
-- 	local parentNode = self._mainMenuPage._ccbOwner.node_first_menuIcon
-- 	for _,key in pairs(self._allRowKeysList) do
-- 		if not self._mainMenuPage._ccbOwner[key] then
-- 			print("Create Node : ", key)
-- 			self._mainMenuPage._ccbOwner[key] = CCNode:create()
-- 			parentNode:addChild(self._mainMenuPage._ccbOwner[key])
-- 		end
-- 	end

-- 	self._iconWidgets[1] = {}
-- 	self._iconWidgets[2] = {}

-- 	self:refreshIcon()
-- end
function QPageMainMenuIcon:viewDidAppear()
end

function QPageMainMenuIcon:viewWillDisappear()
end

function QPageMainMenuIcon:setTutorialModel(boo)
	if self._iconWidgets and self._iconWidgets[1] then
		for _, widget in pairs(self._iconWidgets[1]) do
			if widget._ccbView then
				widget:isScreenRedTips(boo)
			end
		end
	end
	self._haveTutorialModel = boo
	self._mainMenuPage._ccbOwner.node_second_menuIcon:setVisible(boo)
end

-- 刷新、切换icon
function QPageMainMenuIcon:updateIconWidget(key, index)
	if self._iconWidgets then
		for _, rowIconWidgets in ipairs(self._iconWidgets) do
			if rowIconWidgets[key] then
				if rowIconWidgets[key]._ccbView then
					rowIconWidgets[key]:setInfo(key, self._iconConfigs[key].info, index)
				end
			end
		end
	end
end

function QPageMainMenuIcon:setIconNodeVisible(key, boo)
	-- print("按钮显示-[NODE_VISIBLE] ", key, boo)
	local isChange = false
	if self._mainMenuPage._ccbOwner[key] then
		if self._mainMenuPage._ccbOwner[key]:isVisible() ~= boo then
			isChange = true
		end
		self._mainMenuPage._ccbOwner[key]:setVisible(boo)
	end
	if isChange then
		self:refreshIcon(true)
	end
	return isChange
end

-- 设置小红点
function QPageMainMenuIcon:setIconWidgetRedTips(key, boo)
	-- print("设置小红点 [RED_TIPS] ", key, boo)
	if self._iconWidgets then
		for _, rowIconWidgets in ipairs(self._iconWidgets) do
			if rowIconWidgets[key] then
				if rowIconWidgets[key]._ccbView then
					rowIconWidgets[key]:isShowRedTips(boo)
				end
			end
		end
	end
end

-- 设置名字
function QPageMainMenuIcon:setIconWidgetName(key, name)
	if self._iconWidgets then
		for _, rowIconWidgets in ipairs(self._iconWidgets) do
			if rowIconWidgets[key] then
				if rowIconWidgets[key]._ccbView then
					rowIconWidgets[key]:setName(name)
				end
			end
		end
	end
end

-- 设置icon图片
function QPageMainMenuIcon:setIconWidgetIcon(key, path)
	if self._iconWidgets then
		for _, rowIconWidgets in ipairs(self._iconWidgets) do
			if rowIconWidgets[key] then
				if rowIconWidgets[key]._ccbView then
					rowIconWidgets[key]:setIcon(path)
				end
			end
		end
	end
end

-- 設置icon倒計時
function QPageMainMenuIcon:setIconWidgetCountDown(key, str, color)
	if self._tmpWidgetsCache[key] then
		if self._tmpWidgetsCache[key]._ccbView then
			self._tmpWidgetsCache[key]:setCountdown(str, color)
		end
	else
		if self._iconWidgets then
			for _, rowIconWidgets in ipairs(self._iconWidgets) do
				if rowIconWidgets[key] then
					if rowIconWidgets[key]._ccbView then
						rowIconWidgets[key]:setCountdown(str, color)
						self._tmpWidgetsCache[key] = rowIconWidgets[key]
					end
				end
			end
		end
	end
end

function QPageMainMenuIcon:isIconWidgetShowCountDown(key, boo)
	if self._tmpWidgetsCache[key] then
		if self._tmpWidgetsCache[key]._ccbView then
			self._tmpWidgetsCache[key]:isShowCountdown(boo)
		end
	else
		if self._iconWidgets then
			for _, rowIconWidgets in ipairs(self._iconWidgets) do
				if rowIconWidgets[key] then
					if rowIconWidgets[key]._ccbView then
						rowIconWidgets[key]:isShowCountdown(boo)
						self._tmpWidgetsCache[key] = rowIconWidgets[key]
					end
				end
			end
		end
	end
end

-- function QPageMainMenuIcon:sortIcon()
-- 	table.sort(self._showMianIconList,function(a,b)
-- 		return a.orderIndex < b.orderIndex
-- 	end)
-- 	self._rowOneKeysList = {}
-- 	self._rowTwoKeysList = {}
-- 	if self._haveTutorialModel then 
-- 		local index = 1
-- 		for _,iconInfo in pairs(self._showMianIconList) do
-- 			if index <= 8 then
-- 				table.insert(self._rowOneKeysList,iconInfo)
-- 			else
-- 				table.insert(self._rowTwoKeysList,iconInfo)
-- 			end
-- 			index = index+1
-- 		end
-- 	else
-- 		local getNodeFunc = function(key)
-- 			for _,iconInfo in pairs(self._showMianIconList) do
-- 				if iconInfo.widget == key then
-- 					table.insert(self._rowOneKeysList,iconInfo)
-- 				end
-- 			end
-- 		end
-- 		getNodeFunc("node_recharge")
-- 		getNodeFunc("node_sign")
-- 		getNodeFunc("node_mall")
-- 		getNodeFunc("node_reborn")
-- 		getNodeFunc("node_mail")	
-- 		getNodeFunc("node_master")
-- 	end
-- end

-- function QPageMainMenuIcon:refreshIcon(isSkipActivityTheme)
-- 	local isChange = self:_updateData()
-- 	if not self._activityThemeList or not isSkipActivityTheme then
-- 		self._activityThemeList = self:_getActivityThemeList()
-- 	end
-- 	self._showMianIconList = {}
-- 	for _, icon in pairs(self._allRowKeysList) do
-- 		if self._mainMenuPage._ccbOwner[icon] and self._mainMenuPage._ccbOwner[icon]:isVisible() == true and self._iconConfigs[icon] then
-- 			local iconInfo = {}
-- 			iconInfo.widget = icon
-- 			iconInfo.orderIndex = self._iconConfigs[icon].orderIndex

-- 			table.insert(self._showMianIconList,iconInfo)
-- 		end
-- 	end
-- 	for _, icon in ipairs(self._activityThemeList) do
-- 			local iconInfo = {}
-- 			iconInfo.widget = icon
-- 			local themId = icon:getThemeId()
-- 			if themId == remote.activity.THEME_ACTIVITY_SOUL_LETTER then --魂师手札
-- 				iconInfo.orderIndex = 106
-- 			elseif themId == remote.activity.THEME_ACTIVITY_FORGE then --打铁
-- 				iconInfo.orderIndex = 103
-- 			else
-- 				iconInfo.orderIndex = 100
-- 			end
-- 			iconInfo.dynamicCreat = true
-- 			table.insert(self._showMianIconList,iconInfo)		
-- 	end

-- 	self:sortIcon()
-- 	-- 第一排的icon
-- 	self:_renderNormalTheme(self._rowOneKeysList, self._rowOneStartX, self._rowOneStartY, self._iconWidgets[1], self._mainMenuPage._ccbOwner.node_first_menuIcon)
-- 	-- 第二排的icon
-- 	self._normalIconCount, self._normalIconEndX, self._normalIconEndY = self:_renderNormalTheme(self._rowTwoKeysList, self._rowTwoStartX, self._rowTwoStartY, self._iconWidgets[1], self._mainMenuPage._ccbOwner.node_second_menuIcon)

-- end

function QPageMainMenuIcon:refreshIcon(isSkipActivityTheme)
	local isChange = self:_updateData()
	-- 第一排的icon
	self:_renderNormalTheme(self._rowOneKeysList, self._rowOneStartX, self._rowOneStartY, self._iconWidgets[1], self._mainMenuPage._ccbOwner.node_first_menuIcon)
	-- 第二排的icon
	self._normalIconCount, self._normalIconEndX, self._normalIconEndY = self:_renderNormalTheme(self._rowTwoKeysList, self._rowTwoStartX, self._rowTwoStartY, self._iconWidgets[2], self._mainMenuPage._ccbOwner.node_second_menuIcon)

	-- 是否有主题活动
	local count = self._normalIconCount
	local activityThemeStartX = self._normalIconEndX + 54
	local activityThemeStartY = 0
	if not self._activityThemeList or not isSkipActivityTheme then
		self._activityThemeList = self:_getActivityThemeList()
	end
	for _, icon in ipairs(self._activityThemeList) do
		if icon._ccbView then
			icon:setPositionX(activityThemeStartX)
			icon:setPositionY(activityThemeStartY)
			activityThemeStartX = activityThemeStartX + self._spaceX
			count = count + 1
			if count * self._spaceX < display.ui_width and (count + 1) * self._spaceX >= display.ui_width then
				activityThemeStartX = 0
				activityThemeStartY = activityThemeStartY - self._spaceY
			end
		end
	end

	--接著第二排后面icon
	local x = activityThemeStartX - 54
	local y = self._normalIconEndY + activityThemeStartY
	self:_renderNormalTheme(self._rowTwoEndKeysList, x, y, self._iconWidgets[2], self._mainMenuPage._ccbOwner.node_second_menuIcon)

	-- QPrintTable(self._iconWidgets)
end
function QPageMainMenuIcon:_cleanAllIconWidget()
	self._tmpWidgetsCache = {}
	if self._iconWidgets then
		for _, rowIconWidgets in ipairs(self._iconWidgets) do
			for _, iconWidget in pairs(rowIconWidgets) do
				iconWidget:removeFromParent()
				iconWidget = nil
			end
		end
	end
end

function QPageMainMenuIcon:_initData()
	if not self._mainMenuPage._ccbOwner.node_sign then
		return nil
	end
	self._rowOneStartX = self._mainMenuPage._ccbOwner.node_sign:getPositionX()
	self._rowOneStartY = self._mainMenuPage._ccbOwner.node_sign:getPositionY()

	if not self._mainMenuPage._ccbOwner.node_activity then
		self._rowTwoStartX = self._rowOneStartX - 320
		self._rowTwoStartY = self._rowOneStartY - self._spaceY
	else
		self._rowTwoStartX = self._mainMenuPage._ccbOwner.node_activity:getPositionX()
		self._rowTwoStartY = self._mainMenuPage._ccbOwner.node_activity:getPositionY()
	end

	if self._mainMenuPage._ccbOwner.node_active then
		self._iconParentNode = self._mainMenuPage._ccbOwner.node_active
	else
		self._iconParentNode = self._mainMenuPage._ccbOwner.node_sign:getParent()
	end

	if not self._mainMenuPage._ccbOwner.node_first_menuIcon then
		self._mainMenuPage._ccbOwner.node_first_menuIcon = CCNode:create()
		self._iconParentNode:addChild(self._mainMenuPage._ccbOwner.node_first_menuIcon)
	end
	self._mainMenuPage._ccbOwner.node_first_menuIcon:setPosition(ccp(0, 0))

	if not self._mainMenuPage._ccbOwner.node_second_menuIcon then
		self._mainMenuPage._ccbOwner.node_second_menuIcon = CCNode:create()
		self._iconParentNode:addChild(self._mainMenuPage._ccbOwner.node_second_menuIcon)
	end
	self._mainMenuPage._ccbOwner.node_second_menuIcon:setPosition(ccp(0, 0))

	if not self._mainMenuPage._ccbOwner.node_activity_list then
		self._mainMenuPage._ccbOwner.node_activity_list = CCNode:create()
		self._mainMenuPage._ccbOwner.node_second_menuIcon:addChild(self._mainMenuPage._ccbOwner.node_activity_list)
	end
	self._mainMenuPage._ccbOwner.node_activity_list:setPosition(ccp(self._rowTwoStartX, self._rowTwoStartY))
	-- self._mainMenuPage._ccbOwner.node_activity_list:setPosition(ccp(0,0))


	self._iconWidgets[1] = {}
	self._iconWidgets[2] = {}

	self:refreshIcon()
end

function QPageMainMenuIcon:_updateData()
	local isChange = false
	local soulSpiritUnlock = remote.soulSpirit:checkSoulSpiritUnlock()
	local isShowSoulSpiritUnlockAni = app:getUserOperateRecord():getRecordByType("soul_spirit_guide_ani") or 0
	if isShowSoulSpiritUnlockAni == 0 and app.tutorial and app.tutorial:isTutorialFinished() == false and app.tutorial:getRuningStageId() == QTutorialDirector.Stage_SoulSpirit then
		local achievePosX, achievePosY = self._mainMenuPage._ccbOwner.node_achieve:getPosition()
		self._mainMenuPage._ccbOwner.node_master:setPosition(ccp(achievePosX, achievePosY))
		self._mainMenuPage._ccbOwner.node_achieve:setVisible(false)
	else
		isShowSoulSpiritUnlockAni = 1
	end

	-- 做完动画才修改位置
	if soulSpiritUnlock and isShowSoulSpiritUnlockAni == 1 then
		if self._typeForKeysList == 1 then
			self._typeForKeysList = self._typeForKeysList + 1
			isChange = true
		end
		-- self._mainMenuPage._ccbOwner.node_achieve:setVisible(true)
		self._rowOneKeysList = {"node_sign", "node_mall", "node_mail", "node_friend", "node_reborn", "node_recharge", "node_achieve","node_secretary"}
		self._rowTwoKeysList = {"node_activity", "node_active_limit", "node_month_signin", "node_firstRecharge", "node_active_qiri", "node_active_banyue", 
			"node_sevenday", "node_fourteenday", "node_calendar", "node_active_turntable", "node_active_groupbuy", "node_fuli", "node_active_rushBuy", 
			"node_carnival", "node_prompt", "node_comeback", "node_master", "node_gradePackage", "node_player_recall","node_activite_skyfall","node_game_center"
			,"node_yingyongbao"
			}		
	end

	if remote.godarm:checkGodArmUnlock() then
		if self._typeForKeysList == 1 then
			self._typeForKeysList = self._typeForKeysList + 1
			isChange = true
		end
		-- self._mainMenuPage._ccbOwner.node_task:setVisible(true)
		self._rowOneKeysList = {"node_sign", "node_mall", "node_mail", "node_friend", "node_reborn", "node_recharge", "node_achieve","node_task"}
		self._rowTwoKeysList = {"node_activity", "node_active_limit", "node_month_signin", "node_firstRecharge", "node_active_qiri", "node_active_banyue", 
			"node_sevenday", "node_fourteenday", "node_calendar", "node_active_turntable", "node_active_groupbuy", "node_fuli", "node_active_rushBuy", 
			"node_carnival", "node_prompt", "node_comeback", "node_master", "node_gradePackage", "node_player_recall", "node_secretary","node_activite_skyfall","node_game_center"
			,"node_yingyongbao"
			}				
	end

	return isChange
end

-- function QPageMainMenuIcon:_renderNormalTheme(list, x, y, widgetTbl, parentNode)
-- 	if not list or #list == 0 or not widgetTbl then return end

-- 	local count = 0
-- 	local startX = x or 0
-- 	local startY = y or 0
-- 	for _, key in ipairs(list) do
-- 		if key.dynamicCreat then
-- 			if key.widget._ccbView then
-- 				key.widget:setVisible(true)
-- 				key.widget:setPositionX(startX)
-- 				key.widget:setPositionY(startY)
-- 				startX = startX + self._spaceX
-- 				count = count + 1
-- 			end
-- 		else
-- 			if not self._mainMenuPage._ccbOwner[key.widget] then
-- 				print("Create Node : ", key.widget)
-- 				self._mainMenuPage._ccbOwner[key.widget] = CCNode:create()
-- 				parentNode:addChild(self._mainMenuPage._ccbOwner[key.widget])
-- 			else
-- 				if self._mainMenuPage._ccbOwner[key.widget]:getParent() ~= parentNode then
-- 					self._mainMenuPage._ccbOwner[key.widget]:retain()
-- 					self._mainMenuPage._ccbOwner[key.widget]:removeFromParent()
-- 					parentNode:addChild(self._mainMenuPage._ccbOwner[key.widget])
-- 					self._mainMenuPage._ccbOwner[key.widget]:release()
-- 				end
-- 			end
-- 			if self._mainMenuPage._ccbOwner[key.widget]:isVisible() == true and self._iconConfigs[key.widget] then
-- 				if not widgetTbl[key.widget] then
-- 					local widget = QUIWidgetNormalTheme.new()
-- 					widget:setInfo(key.widget, self._iconConfigs[key.widget].info)
-- 					local callback = self._iconConfigs[key.widget].callback or handler(self, self._onDefaultCallback)
-- 					widget:addEventListener(QUIWidgetNormalTheme.EVENT_CLICK, callback)
-- 					widget:isShowRedTips(false)
-- 					-- print("Add Child Node : ", key)
-- 					self._mainMenuPage._ccbOwner[key.widget]:removeAllChildren()
-- 					self._mainMenuPage._ccbOwner[key.widget]:addChild(widget)
-- 					widgetTbl[key.widget] = widget
-- 				end
-- 				self._mainMenuPage._ccbOwner[key.widget]:setPositionX(startX)
-- 				self._mainMenuPage._ccbOwner[key.widget]:setPositionY(startY)
-- 				startX = startX + self._spaceX
-- 				count = count + 1
-- 			end
-- 		end
-- 		if count * self._spaceX < display.ui_width and (count + 1) * self._spaceX >= display.ui_width then
-- 			startX = x or 0
-- 			startY = startY - self._spaceY
-- 		end		
-- 	end

-- 	local endX = startX
-- 	local endY = startY
-- 	return count, endX, endY
-- end

function QPageMainMenuIcon:_renderNormalTheme(list, x, y, widgetTbl, parentNode)
	if not list or #list == 0 or not widgetTbl then return end

	local count = 0
	local startX = x or 0
	local startY = y or 0
	for _, key in ipairs(list) do
		if not self._mainMenuPage._ccbOwner[key] then
			print("Create Node : ", key)
			self._mainMenuPage._ccbOwner[key] = CCNode:create()
			parentNode:addChild(self._mainMenuPage._ccbOwner[key])
		else
			if self._mainMenuPage._ccbOwner[key]:getParent() ~= parentNode then
				print("Change Parent Node : ", key)
				self._mainMenuPage._ccbOwner[key]:retain()
				self._mainMenuPage._ccbOwner[key]:removeFromParent()
				parentNode:addChild(self._mainMenuPage._ccbOwner[key])
				self._mainMenuPage._ccbOwner[key]:release()
			end
		end
		if self._mainMenuPage._ccbOwner[key]:isVisible() == true and self._iconConfigs[key] then
			if not widgetTbl[key] then
				local widget = QUIWidgetNormalTheme.new()
				widget:setInfo(key, self._iconConfigs[key].info)
				local callback = self._iconConfigs[key].callback or handler(self, self._onDefaultCallback)
				widget:addEventListener(QUIWidgetNormalTheme.EVENT_CLICK, callback)
				widget:isShowRedTips(false)
				-- print("Add Child Node : ", key)
				self._mainMenuPage._ccbOwner[key]:removeAllChildren()
				self._mainMenuPage._ccbOwner[key]:addChild(widget)
				widgetTbl[key] = widget
			end
			self._mainMenuPage._ccbOwner[key]:setPositionX(startX)
			self._mainMenuPage._ccbOwner[key]:setPositionY(startY)
			startX = startX + self._spaceX
			count = count + 1
		end
	end

	local endX = startX
	local endY = startY
	return count, endX, endY
end
function QPageMainMenuIcon:_getActivityThemeList()
	local nodeList = {}
	if not self._mainMenuPage._ccbOwner.node_activity_list then
		return nodeList
	end
	self._mainMenuPage._ccbOwner.node_activity_list:removeAllChildren()
	local themeList = remote.activity:getActivityThemeListValid()
	table.sort(themeList, function (theme1, theme2)
		if theme1.order and theme2.order then
			return theme1.order < theme2.order
		elseif theme1.order or theme2.order then
			return theme1.order == nil
		else
			return theme1.id < theme2.id
		end
	end)

	for _, theme in pairs(themeList) do
		local widget = QUIWidgetActivityTheme.new()
		widget:setInfo(theme)
		widget:addEventListener(QUIWidgetActivityTheme.EVENT_CLICK, handler(self, self._activityThemeClickHandler))
		if theme.id == remote.activity.THEME_ACTIVITY_SKIN_SHOP then
			widget:isShowRedTips(false)
		else
			local b = remote.activity:checkIsThemeComplete(theme.id)
			widget:isShowRedTips(b)
		end
		self._mainMenuPage._ccbOwner.node_activity_list:addChild(widget)
		table.insert(nodeList, widget)
	end
	return nodeList
end

function QPageMainMenuIcon:_activityThemeClickHandler(event)
	local themeId = event.themeId
	if themeId == remote.activity.THEME_ACTIVITY_SOUL_LETTER then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivitySoulLetter", 
			options = {}})
	elseif themeId == remote.activity.THEME_ACTIVITY_RAT_FESTIVAL_2 then
		local ratFestivalModel = remote.activityRounds:getRatFestival()
		if ratFestivalModel and ratFestivalModel.isOpen then
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRatFestival", options = {}})
		end
	elseif themeId == remote.activity.THEME_ACTIVITY_RAT_FESTIVAL_1 then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPanel", options = {themeId = themeId}})
	elseif themeId == remote.activity.THEME_ACTIVITY_ZHANGBICHEN_PREHEAT then
		-- 主題曲活動預熱版
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogZhangbichenPreheatMain", options = {themeId = themeId}})
	elseif themeId == remote.activity.THEME_ACTIVITY_ZHANGBICHEN_FORMAL then
		-- 主題曲活動正式版
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogZhangbichenMusicGame", options = {themeId = themeId}})
	elseif themeId == remote.activity.THEME_ACTIVITY_QIANSHITANGSAN then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMysteryStoreActivity", 
			options = {}})		

	elseif themeId == remote.activity.THEME_ACTIVITY_HIGHTEA then
		self:_onTriggerWeeklyGame()
	elseif themeId == remote.activity.THEME_ACTIVITY_MAZE_EXPLORE then
		self:openMazeExplore()
	elseif themeId == remote.activity.THEME_ACTIVITY_SKIN_SHOP then
		if remote.stores:checkSkinShopUnlock() then
			app.sound:playSound("common_small")
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMall", options = {tab = "SKINSHOP_TYPE"}})		
		else
			app.tip:floatTip("不在活动时间段内!")
		end
	elseif themeId == remote.activity.THEME_ACTIVITY_NEW_SERVER_RECHARGE or themeId == remote.activity.THEME_ACTIVITY_NEW_SERVER_RECHARGE_SKINS  then
		app.sound:playSound("common_small")
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityNewServerRecharge"
			, options = {themeId = themeId }})		
	elseif themeId == remote.activity.THEME_ACTIVITY_RESOURCE_TREASURES then
		local resourceTreasuresModule = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.RESOURCE_TREASURES)
	    if resourceTreasuresModule then
			resourceTreasuresModule:treasureMainInfoRequest(function()
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTreasures", 
					options = {}})
			end)
		end
	elseif themeId == remote.activity.THEME_ACTIVITY_CUSTOM_SHOP then
		self:openCustomShop()
	else
		if not remote.activity:checkIsAllThemeComplete(themeId) then
			self._mainMenuPage:quickButtonAutoLayout()
			app.tip:floatTip("不在活动时间段内!")
			return
		end
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPanel", options = {themeId = themeId}})
	end
end

----------------點擊回調函數----------------

function QPageMainMenuIcon:_onDefaultCallback()
	app.tip:floatTip("无法响应")
end

--每日签到
function QPageMainMenuIcon:_onTriggerDialy()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDailySignIn"})
end

--邮箱
function QPageMainMenuIcon:_onMail()
	if self._mainMenuPage._pageSilder:getIsMoveing() then return end
	remote.mails:requestMailList()	
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMail"})
end

--商城
function QPageMainMenuIcon:_onTriggerMall()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMall"})
end

--好友
function QPageMainMenuIcon:_onTriggerFriend()
    if app.unlock:getUnlockFriend(true) == true then
		self._mainMenuPage:hideScaling()
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogFriend"})
    end
end

--充值
function QPageMainMenuIcon:_onTriggerRecharge()
	if not ENABLE_CHARGE() then
		return
	end
	if self._mainMenuPage._pageSilder:getIsMoveing() then return end
	self._mainMenuPage:hideScaling()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
end

--重生
function QPageMainMenuIcon:_onHeroReborn()
	if self._mainMenuPage._pageSilder:getIsMoveing() then return end
	if app.unlock:checkLock("UNLOCK_REBIRTH", true) then
		self._mainMenuPage:hideScaling()
		QUIDialogHeroReborn.selectedHeroId = nil
		if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.REBORN) then
			app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.REBORN)
		end
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroReborn"})
		-- remote.recycle:openDialog()
	end
end

--大师课堂
function QPageMainMenuIcon:_onTriggerMasterClass()
	local channelId = FinalSDK.getChannelID()
	local roleId = remote.user.userId
	local roleName = string.urlencode(remote.user.nickname)
	local serverId = remote.selectServerInfo.serverId
	local serverName = string.urlencode(remote.selectServerInfo.name)
	local platformId = CHANNEL_RES.gameOpId

	if app:isNativeLargerEqualThan(1, 6, 2) then
    	app.sound:pauseMusic()
    	remote.user.pauseMusicFlag = true
    end
    
	if app:isNativeLargerEqualThan(1, 4, 5) then
		local url = string.format("https://zmgame.xxx.com/#/mgame/index/1/%s/%s/%s/%s/%s/%s", channelId, platformId, serverId, serverName, roleId, roleName)
		-- local url = "https://zmgame.xxx.com/#/master/index/1/101/2002/20020001/%E6%B0%B8%E4%B9%85%E6%B5%8B%E8%AF%95%E6%9C%8D/f7fbe307-d932-47eb-b0a0-a9adeb4f53a1/%E5%93%88%E5%93%88%E5%93%88"
		app:openURLIngame(url)
	else
		local url = string.format("https://zmgame.xxx.com/#/mgame/index/2/%s/%s/%s/%s/%s/%s", channelId, platformId, serverId, serverName, roleId, roleName)

        device.openURL(url)
	end
end

--小舞助手
function QPageMainMenuIcon:_onTriggerSecretary()
	remote.secretary:openDialog()
end

--日常活动
function QPageMainMenuIcon:_onTriggerActivity()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPanel"})
end

--限时活动
function QPageMainMenuIcon:_onTriggerActivityLimit()
	if not remote.activity:checkIsAllThemeComplete(remote.activity.THEME_ACTIVITY_LIMIT) then
		self._mainMenuPage._ccbOwner.node_active_limit:setVisible(false)
		self._mainMenuPage:quickButtonAutoLayout()
		app.tip:floatTip("不在活动时间段内!")
		return
	end
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPanel", options = {themeId = remote.activity.THEME_ACTIVITY_LIMIT}})
end

--月度签到
function QPageMainMenuIcon:_onTriggerMonthSignIn()
	remote.monthSignIn:openDialog()
end

--首充
function QPageMainMenuIcon:_onTriggerFirstRecharge()
	if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_FIRST_RECHARGE) then
		app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.ACTIVITY_FIRST_RECHARGE)
	end
	self:setIconWidgetRedTips("node_firstRecharge", false)
	self._mainMenuPage._pageMainMenuUtil:openFirstRechargeDialog(self._mainMenuPage._firstRechargeType)
end

function QPageMainMenuIcon:_onTriggerActivitySeven()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityForSeven", 
		options = {curActivityType = 1}})
end

function QPageMainMenuIcon:_onTriggerActivityBanyue()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityForSeven", 
		options = {curActivityType = 2}})
end

-- 七日登录
function QPageMainMenuIcon:_onTriggerActivitySevenDay()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivitySevenDay"})
end

--8-14日登录活动
function QPageMainMenuIcon:_onTriggerActivityFourteenDay()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivitySevenDay", options = {loginType = 2}})
end

-- 豪华转盘
function QPageMainMenuIcon:_onTriggerActivityTurntable()
	local prizeWheelRound = remote.activityRounds:getPrizaWheel()
	prizeWheelRound:requestPrizeWheelInfo(function()
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPrizeWheel"})
	end)
end

-- 限时团购
function QPageMainMenuIcon:_onTriggerActivityGroupBuy()
	remote.activityRounds:getGroupBuy():requestGoodsDiscountInfo(function()
		remote.activityRounds:getGroupBuy():requestUserBuyInfo(function()
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityGroupBuy", options = {}})
		end)
	end)
end

-- 6元夺宝
function QPageMainMenuIcon:_onTriggerActivityRushBuy()
	remote.activityRounds:getRushBuy():requestGoodsInfo(function()
		remote.activityRounds:getRushBuy():requestBuyInfos(function()
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityRushBuy", options = {} })
		end)
	end)
end

function QPageMainMenuIcon:_onTriggerActivityCarnival()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityCarnival"})
end

-- 玩法日历
function QPageMainMenuIcon:_onTriggerCalendar()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGameCalendar"})
end

-- 成就
function QPageMainMenuIcon:_onTriggerAchieve()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAchievement"})
end

-- 任务
function QPageMainMenuIcon:_onTriggerTask()
	remote.task:setCurTaskType(remote.task.TASK_TYPE_NONE)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogDailyTask"})
end

-- 福利追回
function QPageMainMenuIcon:_onTriggerFuli()
	remote.rewardRecover:setIsShowRedTips(false)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRewardRecover"})
end


function QPageMainMenuIcon:_onTriggerPrompt()
	if self._mainMenuPage._pageSilder:getIsMoveing() then return end
	self._mainMenuPage._pageMainMenuUtil:gotoPrompt()
end

function QPageMainMenuIcon:_onTriggerGradePakge()
	if self._mainMenuPage._pageSilder:getIsMoveing() then return end
	remote.gradePackage:openDialog()
end

--英雄回归
function QPageMainMenuIcon:_onTriggerComeBack()
	if self._mainMenuPage._isMoveing == true then return end
	if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.USERCOMEBACK) then
        app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.USERCOMEBACK)
    end

	remote.userComeBack:openDialog()
end

function QPageMainMenuIcon:_onTriggerPlayerRecall()
	if not remote.playerRecall:isOpen() then
		self._mainMenuPage._ccbOwner.node_player_recall:setVisible(false)
		self._mainMenuPage:quickButtonAutoLayout()
	end
	remote.playerRecall:openDialog()
end

function QPageMainMenuIcon:_onTriggerOpenSkyFall( )
	local skyFallActivityProxy = remote.activityRounds:getSkyFall()
	if not skyFallActivityProxy:checkSkyFallIsOpen() then
		self._mainMenuPage._ccbOwner.node_activite_skyfall:setVisible(false)
		self._mainMenuPage:quickButtonAutoLayout()
	end

	skyFallActivityProxy:openDialog()
end

function QPageMainMenuIcon:_onTriggerGameCenter( )
	
	if FinalSDK.getChannelID() == "7" then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVivoGameCenter", 
				options = {platformId = 7}})
	elseif FinalSDK.getChannelID() == "8"  then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogOPPOGameCenter", 
				options = {platformId = 8}})
	end

end

function QPageMainMenuIcon:_onTriggerYingyongbaoBafu( )
	local isShow , config = remote.activity:checkHaveYingyongbaoBafu()
	if isShow then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAdvertisingInfo",
				options = {data = config}})
	end
end


function QPageMainMenuIcon:_onTriggerWeeklyGame( )

	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHighTeaMain", 
			options = {}})

end

function QPageMainMenuIcon:openMazeExplore( )
	local mazeExploreModel = remote.activityRounds:getMazeExplore()
	local isFirst = false
	if mazeExploreModel then
		local roundInfo = mazeExploreModel:getMazeExploreRoundInfo()
		isFirst = mazeExploreModel:checkIsFirstOpen("MAZE_EXPLORE_CLICK_"..(mazeExploreModel.activityId or "activityId")..roundInfo[1].chapter_id)
	end

	if not isFirst then
		local roundInfo = mazeExploreModel:getMazeExploreRoundInfo()
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreFirstPlot",options = {dungenonInfo = roundInfo[1],callBack=function()
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreMain"})
		end }})
	else
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreMain"})
	end
end

function QPageMainMenuIcon:openCustomShop( )
	local customShopModule = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.CUSTOM_SHOP)
	if customShopModule and customShopModule:checkCustomIsOpen() then
		customShopModule:openDialog()
	else
		app.tip:floatTip("不在活动时间段内!")
	end
end

function QPageMainMenuIcon:_onTriggerQuestionnaire()
	self._mainMenuPage._pageMainMenuUtil:openQuestionnaire()
end

return QPageMainMenuIcon
