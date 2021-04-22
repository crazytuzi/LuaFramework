local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionDragonWarResultAwards = class("QUIDialogUnionDragonWarResultAwards", QUIDialog)
local QListView = import("...views.QListView")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUnionAvatar = import("...utils.QUnionAvatar")

function QUIDialogUnionDragonWarResultAwards:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_gonghun.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
	}
	QUIDialogUnionDragonWarResultAwards.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	self._awards = {}
	if options then
		self._awardInfo = options.awardInfo
		self._callback = options.callback
	end
	self._ccbOwner.frame_tf_title:setString("武魂争霸获胜")
end

function QUIDialogUnionDragonWarResultAwards:viewDidAppear()
	QUIDialogUnionDragonWarResultAwards.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogUnionDragonWarResultAwards:viewWillDisappear()
	QUIDialogUnionDragonWarResultAwards.super.viewWillDisappear(self)
end

function QUIDialogUnionDragonWarResultAwards:setInfo()
	self:setBattleInfo()

	local date = (self._awardInfo.happenedAt or 0)/1000 
	local desc = string.format("%s全员获得以下奖励", q.timeToMonthDay(date))
	self._ccbOwner.tf_award_title:setString(desc)

	self._ccbOwner.tf_rank_1:setString(self._awardInfo.addScore)
	local config = db:getUnionDragonFloorInfoByFloor(self._awardInfo.newFloor)
	self._ccbOwner.tf_rank_3:setString(config.name)

	local envRank, allRank = remote.unionDragonWar:getDailyRankInfo()
	self._ccbOwner.tf_rank_2:setString(envRank)
	self._ccbOwner.tf_rank_4:setString(allRank)

	local totalWidth = 0
	local awards = string.split(self._awardInfo.dailyReward, ";") or {}
	for i, award in pairs(awards) do
		if award ~= "" then
			local itemInfo = string.split(award, "^")
			local itemType = ITEM_TYPE.ITEM
			if tonumber(itemInfo[1]) == nil then
				itemType = remote.items:getItemType(itemInfo[1])
			end

			local itemBox = QUIWidgetItemsBox.new()
			itemBox:setPromptIsOpen(true)
			itemBox:setGoodsInfo(tonumber(itemInfo[1]), itemType, tonumber(itemInfo[2]))
			itemBox:setScale(0.9)

			local width = itemBox:getContentSize().width+20
			itemBox:setPositionX(i*width-width/2)	
			self._ccbOwner.node_item:addChild(itemBox)

			totalWidth = totalWidth + width
			self._awards[#self._awards+1] = {id = tonumber(itemInfo[1]), typeName = itemType, count = tonumber(itemInfo[2])}
		end
	end

	local positionX = self._ccbOwner.node_item:getPositionX()
	self._ccbOwner.node_item:setPositionX(positionX - totalWidth/2 )
end

function QUIDialogUnionDragonWarResultAwards:setBattleInfo()
	local battleInfo = self._awardInfo.battleInfo
	if q.isEmpty(battleInfo) == false then

		local myBattleInfo = {}
		local enemyBattleInfo = {}
		--自己的放左边
		if battleInfo.consortiaBattle1.consortiaId == remote.user.userConsortia.consortiaId then
			myBattleInfo = battleInfo.consortiaBattle1 or {}
			enemyBattleInfo = battleInfo.consortiaBattle2 or {}
		else
			myBattleInfo = battleInfo.consortiaBattle2 or {}
			enemyBattleInfo = battleInfo.consortiaBattle1 or {}
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
	    myDragonAvatar:setScaleY(0.6)
	    myDragonAvatar:setScaleX(-0.6)
	    myDragonAvatar:setPositionY(-30)
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

		-- set icon
		local myAvatar = QUnionAvatar.new(myBattleInfo.icon)
		self._ccbOwner.node_my_union_icon:addChild(myAvatar)
		self._ccbOwner.node_my_union_icon:setScale(0.5)


		-- set enemy info 
		local enemyDragonConfig = db:getUnionDragonConfigById(enemyBattleInfo.dragonId)
		local enemyDragonAvatar = QUIWidgetFcaAnimation.new(enemyDragonConfig.fca, "actor")
	    enemyDragonAvatar:setScaleY(0.6)
	    enemyDragonAvatar:setScaleX(-0.6)
	    enemyDragonAvatar:setPositionY(-30)
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

		local enemyAvatar = QUnionAvatar.new(enemyBattleInfo.icon)
		self._ccbOwner.node_enemy_union_icon:addChild(enemyAvatar)
		self._ccbOwner.node_enemy_union_icon:setScale(0.5)
	end
end

function QUIDialogUnionDragonWarResultAwards:_onTriggerOK(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
    app.sound:playSound("common_small")

	local awards = self._awards
	local rewardId = self._awardInfo.rewardId
	remote.unionDragonWar:dragonWarGetDailyRewardRequest(rewardId, function(data)
			if self:safeCheck() then
				local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
					options = {awards = awards, callBack = handler(self, self.checkFloorUpgrade)}},{isPopCurrentDialog = false} )
				dialog:setTitle("恭喜您获得奖励")
			end
		end)
end

function QUIDialogUnionDragonWarResultAwards:checkFloorUpgrade()
	local callback = self._callback

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogUnionDragonWarResultAwards