-- @Author: zhouxiaoshu
-- @Date:   2019-04-29 10:52:47
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-13 19:14:27

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogConsortiaWarResultAwards = class("QUIDialogConsortiaWarResultAwards", QUIDialog)
local QScrollView = import("...views.QScrollView")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("...ui.QUIViewController")
local QUnionAvatar = import("...utils.QUnionAvatar")

function QUIDialogConsortiaWarResultAwards:ctor(options)
	local ccbFile = "ccb/Dialog_UnionWar_end.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
	}
	QUIDialogConsortiaWarResultAwards.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	self._awards = {}
	if options then
		self._awardInfo = options.awardInfo
		self._callback = options.callback
	end
	q.setButtonEnableShadow(self._ccbOwner.btn_ok)
	self._ccbOwner.frame_btn_close:setVisible(false)
end

function QUIDialogConsortiaWarResultAwards:viewDidAppear()
	QUIDialogConsortiaWarResultAwards.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogConsortiaWarResultAwards:viewWillDisappear()
	QUIDialogConsortiaWarResultAwards.super.viewWillDisappear(self)
end

function QUIDialogConsortiaWarResultAwards:setInfo()
	local date = (self._awardInfo.generateAt or 0)/1000 
	local desc = string.format("%s全员获得以下奖励", q.timeToMonthDay(date))
	self._ccbOwner.tf_award_title:setString(desc)

	self._ccbOwner.tf_rank_1:setString(self._awardInfo.addScore)
	local config = remote.consortiaWar:getRankInfo(self._awardInfo.newFloor)
	self._ccbOwner.tf_rank_3:setString(config.name)

	local envRank, allRank = remote.consortiaWar:getDailyRankInfo()
	self._ccbOwner.tf_rank_2:setString(envRank)
	self._ccbOwner.tf_rank_4:setString(allRank)

	self:setAwardInfo()
	self:setBattleInfo()
end

function QUIDialogConsortiaWarResultAwards:setAwardInfo()
    local scrollSize = self._ccbOwner.sheet_layout:getContentSize()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, scrollSize, {bufferMode = 1, sensitiveDistance = 10})
    self._scrollView:setHorizontalBounce(true)

    local awards = {}
    local rewards = string.split(self._awardInfo.dailyReward, ";")
    for i, v in pairs(rewards) do
        if v ~= "" then
            local reward = string.split(v, "^")
            local itemType = ITEM_TYPE.ITEM
            if tonumber(reward[1]) == nil then
                itemType = remote.items:getItemType(reward[1])
            end
            table.insert(awards, {id = tonumber(reward[1]), typeName = itemType, count = tonumber(reward[2])})
        end
    end
    local rewards = string.split(self._awardInfo.leaderRewards, ";")
    for i, v in pairs(rewards) do
        if v ~= "" then
            local reward = string.split(v, "^")
            local itemType = ITEM_TYPE.ITEM
            if tonumber(reward[1]) == nil then
                itemType = remote.items:getItemType(reward[1])
            end
            table.insert(awards, {id = tonumber(reward[1]), typeName = itemType, count = tonumber(reward[2]), isLeader = true})
        end
    end
    local itemCount = #awards
	for i = 1, itemCount do
        local itemBox = QUIWidgetItemsBox.new()
        itemBox:setPromptIsOpen(true)
        itemBox:setGoodsInfo(awards[i].id, awards[i].typeName, awards[i].count)
        itemBox:setPosition(ccp(60+(i-1)*130, -55))
        if awards[i].isLeader then
         	itemBox:setAwardName("堂主奖励")
        end
        self._scrollView:addItemBox(itemBox)
	end
    self._scrollView:setRect(0, scrollSize.height, 0, 130*itemCount-10)
    self._scrollView:moveTo(0, 0, false)

    self._awards = awards
end

function QUIDialogConsortiaWarResultAwards:setBattleInfo()
	local battleInfo = self._awardInfo.battleInfo
	if q.isEmpty(battleInfo) then
		return
	end

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

	local flag1 = nil
	local flag2 = nil
	local flagPath = QResPath("score_result_flag")
	if myBattleInfo.flagCount > enemyBattleInfo.flagCount then
		self._ccbOwner.frame_tf_title:setString("宗门战获胜")
		flag1 = flagPath[1]
		flag2 = flagPath[2]
	elseif myBattleInfo.flagCount < enemyBattleInfo.flagCount then
		self._ccbOwner.frame_tf_title:setString("宗门战失败")
		flag1 = flagPath[2]
		flag2 = flagPath[1]
	else
		self._ccbOwner.frame_tf_title:setString("宗门战平局")
		flag1 = flagPath[3]
		flag2 = flagPath[3]
	end
	local texture1 = CCTextureCache:sharedTextureCache():addImage(flag1)
	local texture2 = CCTextureCache:sharedTextureCache():addImage(flag2)
	self._ccbOwner.sp_flag_win:setTexture(texture1)
	self._ccbOwner.sp_flag_lose:setTexture(texture2)

	self._ccbOwner.tf_my_union_name:setString(myBattleInfo.consortiaName or "")
	local myAvatar = QUnionAvatar.new(myBattleInfo.icon)
	myAvatar:setScale(0.7)
	myAvatar:setConsortiaWarFloor(myBattleInfo.floor)
	self._ccbOwner.node_my:addChild(myAvatar)

	self._ccbOwner.tf_enemy_union_name:setString(enemyBattleInfo.consortiaName or "")
	local enemyAvatar = QUnionAvatar.new(enemyBattleInfo.icon)
	enemyAvatar:setScale(0.7)
	enemyAvatar:setConsortiaWarFloor(enemyBattleInfo.floor)
	self._ccbOwner.node_enemy:addChild(enemyAvatar)

	self._ccbOwner.tf_num1:setString(myBattleInfo.flagCount)
	self._ccbOwner.tf_num2:setString(enemyBattleInfo.flagCount)
end

function QUIDialogConsortiaWarResultAwards:_onTriggerOK()
    app.sound:playSound("common_small")

	local awards = self._awards
	local rewardId = self._awardInfo.rewardId
	remote.consortiaWar:consortiaWarGetDailyRewardRequest(rewardId, function(data)
		if self:safeCheck() then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
				options = {awards = awards, callBack = handler(self, self.checkFloorUpgrade)}},{isPopCurrentDialog = false} )
		end
	end)
end

function QUIDialogConsortiaWarResultAwards:_onTriggerClose( event )
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	self:_onTriggerOK()
end

function QUIDialogConsortiaWarResultAwards:checkFloorUpgrade()
	self:popSelf()
	if self._callback then
		self._callback()
	end
end

return QUIDialogConsortiaWarResultAwards
