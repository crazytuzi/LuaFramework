--
--	zxs
--	搏击俱乐部战斗形象
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetFightClubBattleHero = class("QUIWidgetFightClubBattleHero", QUIWidget)

local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")

function QUIWidgetFightClubBattleHero:ctor(options)
	local ccbFile = "ccb/Widget_fight_club_battlerecordinfo_hero.ccbi"
	QUIWidgetFightClubBattleHero.super.ctor(self,ccbFile,callBacks,options)

	self._avatar = QUIWidgetHeroInformation.new({isAutoPlay = false})
	self._avatar:setBackgroundVisible(false)
	self._avatar:setNameVisible(false)
	self._ccbOwner.node_avatar:addChild(self._avatar)

	local maxHero = remote.herosUtil:getMaxAttackForceByHeros(options)
	if maxHero then
		self._avatar:setAvatarByHeroInfo(maxHero, maxHero.actorId, 1.3)
		self._avatar:setStarVisible(false)
	end

	local force, unit = q.convertLargerNumber(options.force or 0)
	self._ccbOwner.tf_force_value:setString(force..(unit or ""))
	self._ccbOwner.tf_user_name:setString(options.name)
    self._ccbOwner.sp_win:setVisible(false)
    self._ccbOwner.sp_lose:setVisible(false)
    self._ccbOwner.team1Sp:setVisible(false)
    self._ccbOwner.team2Sp:setVisible(true)
end

function QUIWidgetFightClubBattleHero:setIsMyHero( )
    self._ccbOwner.team1Sp:setVisible(true)
    self._ccbOwner.team2Sp:setVisible(false)

    local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.FIGHT_CLUB_ATTACK_TEAM)
	local heroIdList = teamVO:getAllTeam()
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	local maxHero = remote.herosUtil:getMaxAttackForceByHeros(battleFormation)
	if maxHero then
		self._avatar:setAvatar(maxHero.actorId, 1.3)
		self._avatar:setStarVisible(false)
	end

    local teamForce = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.FIGHT_CLUB_ATTACK_TEAM)
    local force, unit = q.convertLargerNumber(teamForce)
    self._ccbOwner.tf_force_value:setString(force..(unit or ""))
end

function QUIWidgetFightClubBattleHero:setFlipX(bFlip)
	local scaleX = self._avatar:getScaleX()
	if bFlip then
    	self._avatar:setScaleX(-scaleX)
    else
    	self._avatar:setScaleX(scaleX)
    end
end

function QUIWidgetFightClubBattleHero:playAttackAni( callBack )
	self._avatar:avatarPlayAnimation(ANIMATION_EFFECT.COMMON_FIGHT, true, callBack)
end

function QUIWidgetFightClubBattleHero:playDeathAni( callBack )
	self:showWinOrLose(false)

	local callBackFun = function()
		self:reset()
		if callBack then
			callBack()
		end
	end
	self._avatar:avatarPlayAnimation(ANIMATION_EFFECT.DEAD, true, callBackFun)
	self._avatar:setAutoStand(false)
end

function QUIWidgetFightClubBattleHero:playVictoryAni( callBack )
	self:showWinOrLose(true)
	
	local callBackFun = function()
		self:reset()
		if callBack then
			callBack()
		end
	end
	self._avatar:avatarPlayAnimation(ANIMATION_EFFECT.VICTORY, true, callBackFun)
end

function QUIWidgetFightClubBattleHero:showWinOrLose( bWin )
	self._ccbOwner.sp_win:setVisible(bWin)
    self._ccbOwner.sp_lose:setVisible(not bWin)
end

function QUIWidgetFightClubBattleHero:reset()
	self._ccbOwner.sp_win:setVisible(false)
    self._ccbOwner.sp_lose:setVisible(false)
end

return QUIWidgetFightClubBattleHero