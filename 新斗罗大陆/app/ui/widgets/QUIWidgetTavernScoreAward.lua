-- 
-- zxs
-- 抽将积分奖励
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetTavernScoreAward = class("QUIWidgetTavernScoreAward", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")

function QUIWidgetTavernScoreAward:ctor(options)
	local ccbFile = "ccb/Widget_tavern_zhaomujifen.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
		{ccbCallbackName = "onTriggerFirst", callback = handler(self, self._onTriggerFirst)},
		{ccbCallbackName = "onTriggerSecond", callback = handler(self, self._onTriggerSecond)},
		{ccbCallbackName = "onTriggerThird", callback = handler(self, self._onTriggerThird)},
	}
	QUIWidgetTavernScoreAward.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	
	self._textUpdate = QTextFiledScrollUtils.new()

    self:init()
end

function QUIWidgetTavernScoreAward:onEnter()
	QUIWidgetTavernScoreAward.super.onEnter(self)

    self:updateInfo()

	self._remoteProxy = cc.EventProxy.new(remote)
 	self._remoteProxy:addEventListener(remote.USER_UPDATE_EVENT, handler(self, self._onUpdate)) 
end

function QUIWidgetTavernScoreAward:onExit()
	QUIWidgetTavernScoreAward.super.onExit(self)

	if self._remoteProxy then
    	self._remoteProxy:removeAllEventListeners()
    	self._remoteProxy = nil
    end

    if self._textUpdate ~= nil then
		self._textUpdate:stopUpdate()
		self._textUpdate = nil
	end
end

function QUIWidgetTavernScoreAward:_onUpdate(event)
	self:updateInfo()
end

function QUIWidgetTavernScoreAward:init()
	local scoreConfig = db:getConfigurationValue("WUHUNDIAN_JIFEN_DANGWEI")
	local awardConfig = db:getConfigurationValue("WUHUNDIAN_JIFEN_JIANGLI")

	self._scoreConfig = {}
	self._awardConfig = {}
	local scores = string.split(scoreConfig, ";")
	local awards = string.split(awardConfig, ";")
	local actorIds = {1007, 1020, 1044}
	local actorConfig = db:getConfigurationValue("WUHUNDIAN_JIFEN_PREVIEW")

	if actorConfig then
		local ids = string.split(actorConfig, ";")
		if #ids >= #scores then
			actorIds = ids
		end
	end

	self._maxScore = 0
	self._awardCount = #scores
	self._awardBox = {}
	self._canGet = {}	

	-- 三档位信息
	for i = 1, self._awardCount do
		self._awardConfig[i] = awards[i]
		self._scoreConfig[i] = tonumber(scores[i])
		if self._maxScore < self._scoreConfig[i] then
			self._maxScore = self._scoreConfig[i]
		end

		local itemBox = QUIWidgetItemsBox.new()
        itemBox:setGoodsInfo(actorIds[i], ITEM_TYPE.HERO)
        self._ccbOwner["node_head"..i]:addChild(itemBox)
        self._awardBox[i] = itemBox
        self._ccbOwner["tf_score"..i]:setString(self._scoreConfig[i])
        self._ccbOwner["sp_done"..i]:setVisible(false)
	end
end

function QUIWidgetTavernScoreAward:updateScore(score)
    self._ccbOwner.tf_cur_score:setString(math.floor(score))
end

function QUIWidgetTavernScoreAward:updateInfo()
	local curScore = remote.user.luckydrawAdvanceTotalScore or 0
	local curTurn = remote.user.luckydrawAdvanceRewardRow or 0
	local getBoxStr = remote.user.luckydrawAdvanceRewardGotBoxs or ""
	local getBoxList = string.split(getBoxStr, ";") or {}

	-- 当前轮次积分
	curScore = curScore - curTurn*self._maxScore
	if curScore > self._maxScore then
		curScore = self._maxScore
	end
	self._oldScore = self._oldScore or curScore
    self._ccbOwner.tf_cur_score:setString(self._oldScore)

    if self._textUpdate then
		self._textUpdate:addUpdate(self._oldScore, curScore, handler(self, self.updateScore))
	end
	self._oldScore = curScore

    -- 是否没被领取
    local hasNotAwardGot = function(luckyId)
		for i, v in pairs(getBoxList) do
			if luckyId == v then
				return false
			end
		end
		return true
	end

	-- 刷新box
	for i = 1, self._awardCount do
		local luckyId = "wuhundianjifen_"..i
		self._canGet[luckyId] = false
		self._awardBox[i]:removeEffect()
		self._ccbOwner["node_head"..i]:setScale(0.8)
		self._ccbOwner["sp_done"..i]:setVisible(false)
		if curScore >= self._scoreConfig[i] then
			if hasNotAwardGot(luckyId) then
				self._canGet[luckyId] = true
				self._awardBox[i]:showBoxEffect("effects/award_light.ccbi", true)
			else
				self._ccbOwner["sp_done"..i]:setVisible(true)
			end
			self._ccbOwner["node_head"..i]:setScale(0.9)
			makeNodeFromGrayToNormal(self._ccbOwner["node_head"..i])
		else
			makeNodeFromNormalToGray(self._ccbOwner["node_head"..i])
		end
	end 
end

-- 预览
function QUIWidgetTavernScoreAward:previewAward(luckyId, isGet)
	-- 领取奖励
	local function getAward(luckyId, itemId)
		local getLuckyDrawScorePrizeRequest = {boxId = luckyId, itemId = itemId}
	    local request = {api = "GET_LUCKY_DRAW_SCORE_REWARD", getLuckyDrawScorePrizeRequest = getLuckyDrawScorePrizeRequest}
		app:getClient():requestPackageHandler("GET_LUCKY_DRAW_SCORE_REWARD", request, function (response)
			local luckyDraw = response.getLuckyDrawScorePrizeResponse.luckyDraw
			
			-- 刷新道具
			if luckyDraw.items then
				remote.items:setItems(luckyDraw.items)
			end

			local awards = {}
			if luckyDraw.prizes then
				for i, prize in pairs(luckyDraw.prizes) do 
					table.insert(awards, prize)
				end
			end
			if not next(awards) then
				return
			end

			local callback = function()
				remote:dispatchUpdateEvent()
			end
	      	local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
	    		options = {awards = awards, callback = callback}}, {isPopCurrentDialog = false} )
			dialog:setTitle("恭喜您获得积分奖励")
	    end)
	end

	local luckyConfig = db:getLuckyDraw( luckyId )
	local isGet = self._canGet[luckyId]
	local chooseType = isGet and 1 or 2 
	local awards = {}
	local index = 1
	if luckyConfig then
		while luckyConfig["id_"..index] do 
			awards[index] = {id = luckyConfig["id_"..index], count = luckyConfig["num_"..index], typeName = luckyConfig["type_"..index]}
			index = index + 1
		end

		local callback = function(chooseTable)
			if not chooseTable[1] then
				return
			end
			local award = awards[chooseTable[1]]
			getAward(luckyId, award.id)
		end
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogXuanzejiangli", 
			options = {awards = awards, chooseType = chooseType, showOkBtn = true, okCallback = callback}}, {isPopCurrentDialog = false} )
	else
		app.tip:floatTip("该奖励不存在！")
	end
end

function QUIWidgetTavernScoreAward:_onTriggerFirst(event)
	local luckyId = self._awardConfig[1]
	self:previewAward(luckyId)
end

function QUIWidgetTavernScoreAward:_onTriggerSecond(event)
	local luckyId = self._awardConfig[2]
	self:previewAward(luckyId)
end

function QUIWidgetTavernScoreAward:_onTriggerThird(event)
	local luckyId = self._awardConfig[3]
	self:previewAward(luckyId)
end

function QUIWidgetTavernScoreAward:_onTriggerRule(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_rule) == false then return end
	app.tip:floatTip("购买1次增加10积分，购买10次增加100积分。积分达标时可以领取对应魂师。")
end

return QUIWidgetTavernScoreAward
