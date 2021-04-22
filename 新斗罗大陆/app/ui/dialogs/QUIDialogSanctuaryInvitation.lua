-- 
-- zxs
-- 精英赛邀请
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSanctuaryInvitation = class("QUIDialogSanctuaryInvitation", QUIDialog)
local QRichText = import("...utils.QRichText")

function QUIDialogSanctuaryInvitation:ctor(options)
	local ccbFile = "ccb/Dialog_Sanctuary_open.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
		{ccbCallbackName = "onTriggerBack", callback = handler(self, self._onTriggerBack)},
		{ccbCallbackName = "onTriggerOk", callback = handler(self, self._onTriggerOk)},
	}
	QUIDialogSanctuaryInvitation.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	self._isGuide = options.isGuide
	self._callback = options.callback
end

function QUIDialogSanctuaryInvitation:viewDidAppear()
	QUIDialogSanctuaryInvitation.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogSanctuaryInvitation:viewWillDisappear()
	QUIDialogSanctuaryInvitation.super.viewWillDisappear(self)
end

function QUIDialogSanctuaryInvitation:setInfo()
	self._ccbOwner.btn_normal:setVisible(false)
	self._ccbOwner.btn_back:setVisible(false)
	self._ccbOwner.btn_ok:setVisible(false)
	self._ccbOwner.btn_changeTeam:setVisible(false)

	local richText = QRichText.new({}, 400)
	richText:setAnchorPoint(ccp(0, 0.5))
    self._ccbOwner.node_desc:addChild(richText)

	local state = remote.sanctuary:getState()
	local myInfo = remote.sanctuary:getSanctuaryMyInfo()
	if self._isGuide then
		richText:setString({
			{oType = "font", content = "小舞悄悄把自己存下的", size = 22, color = GAME_COLOR_SHADOW.normal},
	        {oType = "font", content = "1000精英币",size = 22, color = GAME_COLOR_SHADOW.stress},
	        {oType = "font", content = "送给魂师大人，精英币可以", size = 22, color = GAME_COLOR_SHADOW.normal},
	        {oType = "font", content = "兑换奖励",size = 22, color = GAME_COLOR_SHADOW.stress},
	        {oType = "font", content = "或者进行", size = 22, color = GAME_COLOR_SHADOW.normal},
	        {oType = "font", content = "押注",size = 22, color = GAME_COLOR_SHADOW.stress},
	        {oType = "font", content = "，魂师大人要好好利用哟~", size = 22, color = GAME_COLOR_SHADOW.normal},
	    })
		QSetDisplayFrameByPath(self._ccbOwner.sp_title, QResPath("sanctuary_show_title")[6])
	    self._ccbOwner.btn_ok:setVisible(true)
	    self._ccbOwner.tf_ok:setString("确定")

	elseif state == remote.sanctuary.STATE_REGISTER then
		richText:setString({
			{oType = "font", content = "魂师大人，每隔", size = 22, color = GAME_COLOR_SHADOW.normal},
	        {oType = "font", content = "2",size = 22, color = GAME_COLOR_SHADOW.stress},
	        {oType = "font", content = "周开启一次的全大陆精英赛今天开启报名哦~快来报名与所有的魂师高手同台竞技吧~", size = 22, color = GAME_COLOR_SHADOW.normal},
	    })
		QSetDisplayFrameByPath(self._ccbOwner.sp_title, QResPath("sanctuary_show_title")[1])
	    self._ccbOwner.btn_ok:setVisible(true)

	elseif state == remote.sanctuary.STATE_AUDITION_1 or state == remote.sanctuary.STATE_AUDITION_2 then
	    richText:setString({
			{oType = "font", content = "恭喜魂师大人，", size = 22, color = GAME_COLOR_SHADOW.normal},
	        {oType = "font", content = "海选赛",size = 22, color = GAME_COLOR_SHADOW.stress},
			{oType = "font", content = "开始了哟，快去战斗获取积分，不论胜负都有大量精英币奖励哦~", size = 22, color = GAME_COLOR_SHADOW.normal},
	    })
		QSetDisplayFrameByPath(self._ccbOwner.sp_title, QResPath("sanctuary_show_title")[4])
	    self._ccbOwner.btn_normal:setVisible(true)
	    self._ccbOwner.btn_back:setVisible(true)

	elseif state == remote.sanctuary.STATE_AUDITION_2_END then
		local callback = function()
			local currRound = myInfo.seasonUser.currRound
			local score = myInfo.seasonUser.seasonScore or 0
			local rankInfo = remote.sanctuary:getRankInfo() or {}
			local rank = rankInfo.myRank or 0
			if currRound >= remote.sanctuary.ROUND_64 then
				richText:setString({	
					{oType = "font", content = "恭喜魂师大人，您在海选赛以", size = 22, color = GAME_COLOR_SHADOW.normal},
			        {oType = "font", content = tostring(score), size = 22, color = GAME_COLOR_SHADOW.stress},
			        {oType = "font", content = "分，第", size = 22, color = GAME_COLOR_SHADOW.normal},
			        {oType = "font", content = tostring(rank), size = 22, color = GAME_COLOR_SHADOW.stress},
			        {oType = "font", content = "名优异的成绩成为了", size = 22, color = GAME_COLOR_SHADOW.normal},
			    	{oType = "font", content = "64", size = 22, color = GAME_COLOR_SHADOW.stress},
			        {oType = "font", content = "强，可以参加淘汰赛，快去看看吧。", size = 22, color = GAME_COLOR_SHADOW.normal},
			    })
			elseif rank > 0 and rank <= 64 then
				richText:setString({	
					{oType = "font", content = "恭喜魂师大人，您在海选赛以", size = 22, color = GAME_COLOR_SHADOW.normal},
			        {oType = "font", content = tostring(score), size = 22, color = GAME_COLOR_SHADOW.stress},
			        {oType = "font", content = "分，第", size = 22, color = GAME_COLOR_SHADOW.normal},
			        {oType = "font", content = tostring(rank), size = 22, color = GAME_COLOR_SHADOW.stress},
			        {oType = "font", content = "名优异的成绩成为了", size = 22, color = GAME_COLOR_SHADOW.normal},
			    	{oType = "font", content = "64", size = 22, color = GAME_COLOR_SHADOW.stress},
			        {oType = "font", content = "强，可以参加淘汰赛，快去看看吧。", size = 22, color = GAME_COLOR_SHADOW.normal},
			    })
			elseif rank > 64 then
				richText:setString({
					{oType = "font", content = "魂师大人，很遗憾您在海选赛的积分是", size = 22, color = GAME_COLOR_SHADOW.normal},
			        {oType = "font", content = tostring(score), size = 22, color = GAME_COLOR_SHADOW.stress},
			        {oType = "font", content = "分，排在第", size = 22, color = GAME_COLOR_SHADOW.normal},
			        {oType = "font", content = tostring(rank), size = 22, color = GAME_COLOR_SHADOW.stress},
			        {oType = "font", content = "名，无缘", size = 22, color = GAME_COLOR_SHADOW.normal},
			    	{oType = "font", content = "64", size = 22, color = GAME_COLOR_SHADOW.stress},
			        {oType = "font", content = "强，无法参加淘汰赛。小舞相信下次您一定可以进入淘汰赛的！", size = 22, color = GAME_COLOR_SHADOW.normal},
			    })
			else
				richText:setString({
					{oType = "font", content = "魂师大人，很遗憾您在海选赛的积分是", size = 22, color = GAME_COLOR_SHADOW.normal},
			        {oType = "font", content = tostring(score), size = 22, color = GAME_COLOR_SHADOW.stress},
			        {oType = "font", content = "分，没有名次，无缘", size = 22, color = GAME_COLOR_SHADOW.normal},
			    	{oType = "font", content = "64", size = 22, color = GAME_COLOR_SHADOW.stress},
			        {oType = "font", content = "强，无法参加淘汰赛。小舞相信下次您一定可以进入淘汰赛的！", size = 22, color = GAME_COLOR_SHADOW.normal},
			    })
			end
		end

		QSetDisplayFrameByPath(self._ccbOwner.sp_title, QResPath("sanctuary_show_title")[2])
	    self._ccbOwner.btn_normal:setVisible(true)
	    self._ccbOwner.btn_back:setVisible(true)

		remote.sanctuary:sanctuaryWarGetRankScoreRequest(function()
			if self:safeCheck() then
				callback()
			end
		end)

	elseif state >= remote.sanctuary.STATE_KNOCKOUT_8_OUT and state <= remote.sanctuary.STATE_BETS_8 and myInfo.seasonUser.currRound >= remote.sanctuary.ROUND_8 then
		richText:setString({
			{oType = "font", content = "恭喜魂师大人，您一路过关斩将，击败了无数对手，获得了", size = 22, color = GAME_COLOR_SHADOW.normal},
	        {oType = "font", content = "8",size = 22, color = GAME_COLOR_SHADOW.stress},
	        {oType = "font", content = "强赛的资格。快去看看自己的对手，并作出适当的阵容调整吧~", size = 22, color = GAME_COLOR_SHADOW.normal},
	    })

		QSetDisplayFrameByPath(self._ccbOwner.sp_title, QResPath("sanctuary_show_title")[3])
	    self._ccbOwner.btn_normal:setVisible(true)
	    self._ccbOwner.btn_back:setVisible(true)

	elseif state == remote.sanctuary.STATE_BETS_8 or state == remote.sanctuary.STATE_BETS_4 or state == remote.sanctuary.STATE_BETS_2 then
		local textTbl = {}
		local text1 = {oType = "font", content = "恭喜魂师大人，", size = 22, color = GAME_COLOR_SHADOW.normal}
		local text2 = {}
		if state == remote.sanctuary.STATE_BETS_8 then
			text2 = {oType = "font", content = "8强赛", size = 22, color = GAME_COLOR_SHADOW.stress}
		elseif state == remote.sanctuary.STATE_BETS_4 then
			text2 = {oType = "font", content = "4强赛", size = 22, color = GAME_COLOR_SHADOW.stress}
		elseif state == remote.sanctuary.STATE_BETS_2 then
			text2 = {oType = "font", content = "冠军和季军赛", size = 22, color = GAME_COLOR_SHADOW.stress}
		end
		local text3 = {oType = "font", content = "今日开启了哟，观战可以进行押注，押注可以获得大量精英币奖励哦~", size = 22, color = GAME_COLOR_SHADOW.normal}
		table.insert(textTbl, text1)
		table.insert(textTbl, text2)
		table.insert(textTbl, text3)
		richText:setString(textTbl)

		QSetDisplayFrameByPath(self._ccbOwner.sp_title, QResPath("sanctuary_show_title")[5])
	    self._ccbOwner.btn_normal:setVisible(true)
	    self._ccbOwner.btn_back:setVisible(true)
	end
end

function QUIDialogSanctuaryInvitation:_onTriggerOk( event )
	if q.buttonEventShadow(event, self._ccbOwner.button_ok) == false then return end
	self:viewAnimationOutHandler()

	if not self._isGuide then
		remote.sanctuary:openDialog()
	end
end

function QUIDialogSanctuaryInvitation:_onTriggerGo(event)
	if q.buttonEventShadow(event, self._ccbOwner.button_normal) == false then return end
	self:viewAnimationOutHandler()

	if not self._isGuide then
		remote.sanctuary:openDialog()
	end
end

function QUIDialogSanctuaryInvitation:_onTriggerBack(event)
	if q.buttonEventShadow(event, self._ccbOwner.button_back) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSanctuaryInvitation:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogSanctuaryInvitation:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSanctuaryInvitation:viewAnimationOutHandler()
    self:popSelf()
	if self._callback then
		self._callback()
	end
end

return QUIDialogSanctuaryInvitation