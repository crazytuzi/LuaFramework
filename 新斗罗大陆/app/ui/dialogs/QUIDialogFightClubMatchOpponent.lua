-- 
--  zxs
--	搏击俱乐部匹配对手
--

local QUIDialog = import(".QUIDialog")
local QUIDialogFightClubMatchOpponent = class("QUIDialogFightClubMatchOpponent", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

function QUIDialogFightClubMatchOpponent:ctor(options)
	local ccbFile = "ccb/Dialog_fight_club_match.ccbi"
	QUIDialogFightClubMatchOpponent.super.ctor(self, ccbFile, nil, options)
    CalculateUIBgSize(self._ccbOwner.ly_bg)

	self._quickFightInfo = {}
	if options then
		self._quickFightInfo = options.quickFightInfo or {} 
		self._callBack = options.callback
		self._fightType = options.fightType
	end
	self._virtualFrame = {}
	self:addFrames()
	self:playersShowAni()

end

function QUIDialogFightClubMatchOpponent:addFrames()
	local opponentList = self._quickFightInfo.fighter or {}
	local cellWidth = 280
	local cellHeight = 100
	for i, v in pairs(opponentList) do
		local frame = {}
		frame.widget = self:getFightClubHeadNode(v)
		frame.posX = cellWidth*((i-1)%4)
		frame.posY = -cellHeight*(math.floor((i-1)/4))
		frame.widget:setPosition(ccp(-cellWidth, -display.height/2))
		self._ccbOwner.node_player:addChild(frame.widget)
		table.insert(self._virtualFrame, frame)
	end

	local myInfo = remote.fightClub:getMyInfo()
	local myHead = self:getFightClubHeadNode(myInfo, true)
	self._ccbOwner.node_mine:addChild(myHead)

	if self._fightType == remote.fightClub.FAST_FIGHT then
		self._ccbOwner.node_quick_fight:setVisible(false)
		self._ccbOwner.node_fast_fight:setVisible(true)
	end
end

function QUIDialogFightClubMatchOpponent:getFightClubHeadNode(headInfo, isSelf)
	local ccbOwner = {}
	local ccbFile = "ccb/Widget_fight_club_head.ccbi"
	local headNode = CCBuilderReaderLoad(ccbFile, CCBProxy:create(), ccbOwner)

   	ccbOwner.tf_nickname:setString(headInfo.name)
   	local force, unit = q.convertLargerNumber(headInfo.force)
    ccbOwner.tf_power:setString(force..(unit or ""))
    local avatar = QUIWidgetAvatar.new(headInfo.avatar)
    avatar:setSilvesArenaPeak(headInfo.championCount)
    ccbOwner.node_head:addChild(avatar)

    if isSelf then
	    local teamForce = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.FIGHT_CLUB_ATTACK_TEAM)
	    local force, unit = q.convertLargerNumber(teamForce)
	    ccbOwner.tf_power:setString(force..(unit or ""))
	    ccbOwner.node_mine_bg:setVisible(true)
	    ccbOwner.node_player_bg:setVisible(false)
	else
		ccbOwner.node_mine_bg:setVisible(false)
	    ccbOwner.node_player_bg:setVisible(true)
	end

    return headNode
end

function QUIDialogFightClubMatchOpponent:playersShowAni()
	local aniCallBack = function ( )
		self:viewAnimationOutHandler()
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFightClubBattle",
			options = {quickFightInfo = self._quickFightInfo, fightType = self._fightType, callback = self._callBack}})
	end

	for i, frame in pairs(self._virtualFrame) do 
		local time = 0.1*i 
		local actionIn = CCArray:create()
	    local delayTime = CCDelayTime:create(time)
	    local moveTo = CCMoveTo:create(0.2, ccp(frame.posX,frame.posY))
		local moveAni = CCEaseExponentialOut:create(moveTo)
		actionIn:addObject(delayTime)
		actionIn:addObject(moveAni)

	    if i == #self._virtualFrame then
	    	local delayTime2 = CCDelayTime:create(0.5)
	    	actionIn:addObject(delayTime2)
	    	actionIn:addObject(CCCallFunc:create(aniCallBack))
	    end
		frame.widget:runAction(CCSequence:create(actionIn))
	end
end

return QUIDialogFightClubMatchOpponent
