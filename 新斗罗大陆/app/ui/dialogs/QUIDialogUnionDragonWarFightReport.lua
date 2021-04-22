-- 
-- zxs
-- 武魂战战报
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionDragonWarFightReport = class("QUIDialogUnionDragonWarFightReport", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView") 
local QUnionAvatar = import("...utils.QUnionAvatar")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

function QUIDialogUnionDragonWarFightReport:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_xiangqiang.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogUnionDragonWarFightReport.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options then
		self._fighterInfo = options.fighterInfo or {}
		self._eventsInfo = options.eventsInfo or {}
	end

	self:initScrollView()
end

function QUIDialogUnionDragonWarFightReport:viewDidAppear()
	QUIDialogUnionDragonWarFightReport.super.viewDidAppear(self)

	self:setDragonInfo()

	self:setLogInfo()
end

function QUIDialogUnionDragonWarFightReport:viewWillDisappear()
	QUIDialogUnionDragonWarFightReport.super.viewWillDisappear(self)
end

function QUIDialogUnionDragonWarFightReport:initScrollView()
	local itemContentSize = self._ccbOwner.sheet_layout:getContentSize()

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, itemContentSize, {bufferMode = 2, sensitiveDistance = 10})
	self._scrollView:setVerticalBounce(true)
	self._scrollView:setGradient(false)
end

function QUIDialogUnionDragonWarFightReport:setDragonInfo()
	local myBattleInfo = {}
	local enemyBattleInfo = {}

	--自己的放左边
	if self._fighterInfo.consortiaBattle1.consortiaId == remote.user.userConsortia.consortiaId then
		myBattleInfo = self._fighterInfo.consortiaBattle1 or {}
		enemyBattleInfo = self._fighterInfo.consortiaBattle2 or {}
	else
		myBattleInfo = self._fighterInfo.consortiaBattle2 or {}
		enemyBattleInfo = self._fighterInfo.consortiaBattle1 or {}
	end

	local isWin = remote.unionDragonWar:getFightResult(myBattleInfo, enemyBattleInfo)
	if isWin == false then
		local winPositionX = self._ccbOwner.sp_win_word:getPositionX()
		local losePositionX = self._ccbOwner.sp_lose_word:getPositionX()
		self._ccbOwner.sp_win_word:setPositionX(losePositionX)
		self._ccbOwner.sp_lose_word:setPositionX(winPositionX)
	end

	local stringFormat = "(%s%%)%s/%s"
	-- set my info
	local myDragonConfig = db:getUnionDragonConfigById(myBattleInfo.dragonId)
	local myDragonAvatar = QUIWidgetFcaAnimation.new(myDragonConfig.fca, "actor")
    myDragonAvatar:setScale(0.43)
    self._ccbOwner.node_my_dragon:addChild(myDragonAvatar)
    local color = remote.dragon:getDragonColor(myBattleInfo.dragonId, myBattleInfo.dragonLevel)
	self._ccbOwner.tf_my_dragon_name:setColor(color)
    setShadowByFontColor(self._ccbOwner.tf_my_dragon_name, color)
	self._ccbOwner.tf_my_dragon_name:setString("LV."..myBattleInfo.dragonLevel.." "..myDragonConfig.dragon_name or "")
	self._ccbOwner.tf_my_union_name:setString(myBattleInfo.consortiaName or "")

	local myDragonHp = myBattleInfo.dragonCurrHp or 0
	local myDragonFullHp = myBattleInfo.dragonFullHp or 0
	local myDragonFullHurt = myBattleInfo.dragonHurtHp or 0
	local myHp, myUint = q.convertLargerNumber(myDragonHp)
	local myFullHp, myFullUint = q.convertLargerNumber(myDragonFullHp)
	local myHpPercent = string.format("%.3f", (myDragonFullHurt/myDragonFullHp or 0))
	if myDragonHp ~= myDragonFullHp and tonumber(myHpPercent) < 0.0001 then
		myHpPercent = 0.0001
	end

	local scaleX = self._ccbOwner.sp_my_blood_bar:getScaleX()
	if myDragonHp <= 0 then
		self._ccbOwner.tf_my_dragon_blood:setString(string.format("%s%%武魂破损", tonumber(myHpPercent)*100))
		self._ccbOwner.sp_my_blood_bar:setScaleX(0)
	else
		self._ccbOwner.tf_my_dragon_blood:setString(string.format(stringFormat, myHpPercent*100, myHp..myUint, myFullHp..myFullUint))
		self._ccbOwner.sp_my_blood_bar:setScaleX(myDragonHp/myDragonFullHp*scaleX)
	end

	-- set enemy info 
	local enemyDragonConfig = db:getUnionDragonConfigById(enemyBattleInfo.dragonId)
	local enemyDragonAvatar = QUIWidgetFcaAnimation.new(enemyDragonConfig.fca, "actor")
    enemyDragonAvatar:setScale(0.43)
    self._ccbOwner.node_enemy_dragon:addChild(enemyDragonAvatar)
    local color = remote.dragon:getDragonColor(enemyBattleInfo.dragonId, enemyBattleInfo.dragonLevel)
	self._ccbOwner.tf_enemy_dragon_name:setColor(color)
    setShadowByFontColor(self._ccbOwner.tf_enemy_dragon_name, color)
	self._ccbOwner.tf_enemy_dragon_name:setString("LV."..enemyBattleInfo.dragonLevel.." "..enemyDragonConfig.dragon_name or "")
	self._ccbOwner.tf_enemy_union_name:setString(enemyBattleInfo.consortiaName or "")

	local enemyDragonHp = enemyBattleInfo.dragonCurrHp or 0
	local enemyDragonFullHp = enemyBattleInfo.dragonFullHp or 0
	local enemyDragonFullHurt = enemyBattleInfo.dragonHurtHp or 0
	local enemyHp, enemyUint = q.convertLargerNumber(enemyDragonHp)
	local enemyFullHp, enemyFullUint = q.convertLargerNumber(enemyDragonFullHp)
	local enemyHpPercent = string.format("%.3f", (enemyDragonFullHurt/enemyDragonFullHp or 0 or 0))
	if enemyDragonHp ~= enemyDragonFullHp and tonumber(enemyHpPercent) < 0.0001 then
		enemyHpPercent = 0.0001
	end

	local scaleX = self._ccbOwner.sp_enemy_blood_bar:getScaleX()
	if enemyDragonHp <= 0 then
		self._ccbOwner.tf_enemy_dragon_blood:setString(string.format("%s%%武魂破损", tonumber(enemyHpPercent)*100))
		self._ccbOwner.sp_enemy_blood_bar:setScaleX(0)
	else
		self._ccbOwner.tf_enemy_dragon_blood:setString(string.format(stringFormat, enemyHpPercent*100, enemyHp..enemyUint, enemyFullHp..enemyFullUint))
		self._ccbOwner.sp_enemy_blood_bar:setScaleX(enemyDragonHp/enemyDragonFullHp*scaleX)
	end

	-- set icon
	local myAvatar = QUnionAvatar.new(myBattleInfo.icon)
	self._ccbOwner.node_my_union_icon:addChild(myAvatar)
	self._ccbOwner.node_my_union_icon:setScale(0.5)

	local enemyAvatar = QUnionAvatar.new(enemyBattleInfo.icon)
	self._ccbOwner.node_enemy_union_icon:addChild(enemyAvatar)
	self._ccbOwner.node_enemy_union_icon:setScale(0.5)
end

function QUIDialogUnionDragonWarFightReport:setLogInfo()
	local itemContentSize, buffer = self._scrollView:setCacheNumber(10, "widgets.dragon.QUIWidgetUnionDragonWarFightReportLogCell")
		
	table.sort( self._eventsInfo, function (a, b)
		return a.eventId > b.eventId
	end )

	local row = 0
	local line = 0
	local lineDistance = 2
	local offsetX = 0
	local offsetY = 0
	for i = 1, #self._eventsInfo do
		local positionX = offsetX
		local positionY = -(itemContentSize.height+lineDistance) * line + offsetY
		self._scrollView:addItemBox(positionX, positionY, {index = i, info = self._eventsInfo[i]})

		line = line + 1
	end
	local totalWidth = itemContentSize.width
	local totalHeight = (itemContentSize.height+lineDistance) * line
	self._scrollView:setRect(0, -totalHeight, 0, totalWidth)
end

function QUIDialogUnionDragonWarFightReport:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogUnionDragonWarFightReport:_onTriggerClose()
    app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogUnionDragonWarFightReport:viewAnimationOutHandler()
	self:popSelf()
end


return QUIDialogUnionDragonWarFightReport