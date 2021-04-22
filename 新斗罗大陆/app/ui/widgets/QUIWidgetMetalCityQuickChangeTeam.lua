-- @Author: xurui
-- @Date:   2018-10-10 14:43:43
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-16 10:26:23
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMetalCityQuickChangeTeam = class("QUIWidgetMetalCityQuickChangeTeam", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetStormQuickChangeTeamHead = import("..widgets.QUIWidgetStormQuickChangeTeamHead")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QScrollView = import("...views.QScrollView")

QUIWidgetMetalCityQuickChangeTeam.EVENT_CLICK_DETAIL = "EVENT_CLICK_DETAIL"
QUIWidgetMetalCityQuickChangeTeam.EVENT_CLICK_TEAM_CHANGE = "EVENT_CLICK_TEAM_CHANGE"
QUIWidgetMetalCityQuickChangeTeam.EVENT_CLICK_HERO_HEAD = "EVENT_CLICK_HERO_HEAD"

function QUIWidgetMetalCityQuickChangeTeam:ctor(options)
	local ccbFile = "ccb/Widget_TeamArena_yijian.ccbi"
    local callBacks = { 
		{ccbCallbackName = "onTriggerDetail", callback = handler(self, self._onTriggerDetail)},
		{ccbCallbackName = "onTriggerChange", callback = handler(self, self._onTriggerChange)},
		{ccbCallbackName = "onTriggerDevelop", callback = handler(self, self._onTriggerDevelop)},
    }
    QUIWidgetMetalCityQuickChangeTeam.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._mainHeads = {}
	self._helpHeads = {}
	self._soulHeads = {}
	self._godarmHeads = {}
	self._mountHeads = {}
	self._selectEffect = {}
end

function QUIWidgetMetalCityQuickChangeTeam:onEnter()
	self._scrollView = QScrollView.new(self._ccbOwner.sheet, self._ccbOwner.sheet_layout:getContentSize(), {bufferMode = 1, nodeAR = ccp(0.5, 0.5), sensitiveDistance = 10})
    self._scrollView:setHorizontalBounce(true)

    self:updateHeroHead(self.isMockBattle)
end

function QUIWidgetMetalCityQuickChangeTeam:onExit()
end

function QUIWidgetMetalCityQuickChangeTeam:setInfo(teams, trialNum, helpTeamSlot, fighterInfo, isStromArena, isDefence, isPVP, isTotemChallenge,isMockBattle)
	self._ccbOwner.ndoe_pvp:setVisible(false)
	self._ccbOwner.btn_detail:setPositionX(0)
	self._ccbOwner.btn_detail:setVisible(not isDefence)
	self._fighterInfo = fighterInfo
	self.isMockBattle = isMockBattle or false
	self._isPVP = isPVP
	if self._isPVP == nil then
		self._isPVP = false
	end
	self._trialNum = trialNum or 1
	local title = "试炼"
	if isStromArena or isTotemChallenge or isMockBattle then
		title = "队伍"
	end
	if trialNum == 1 then
		title = title.."一"
 	elseif trialNum == 2 then
		title = title.."二"
	end
	if isStromArena and fighterInfo and not isDefence then
		self._ccbOwner.ndoe_pvp:setVisible(true)
		self._ccbOwner.btn_detail:setPositionX(144)
		self._ccbOwner.tf_team1:setString("敌方")

		local force = self:getEnemyForce(trialNum)
	    local num, unit = q.convertLargerNumber(force or 0)
		self._ccbOwner.tf_force1:setString(num..unit)
	elseif isMockBattle then
		self._ccbOwner.tf_force:setString("")
		self._ccbOwner.tf_force1:setString("")

	end
	self._ccbOwner.tf_team:setString(title)

	self._teams = teams
	self._trialNum = trialNum
	self._helpTeamSlot = helpTeamSlot

	self:updateHeroHead(self.isMockBattle)

	self:setChangeButton(false, false)
end

function QUIWidgetMetalCityQuickChangeTeam:getEnemyForce(trialNum)
	local force = 0
	local mainHeros = self._fighterInfo.heros or {}
	local helpHeros = self._fighterInfo.subheros or {}
	local soulSpirit = self._fighterInfo.soulSpirit or {}
	if trialNum == 2 then
		mainHeros = self._fighterInfo.main1Heros or {}
		helpHeros = self._fighterInfo.sub1heros or {}
		soulSpirit = self._fighterInfo.soulSpirit2 or {}
	end
    for index, value in ipairs(mainHeros) do
   	 	force = force + (value.force or 0)
    end
    for index, value in ipairs(helpHeros) do
   	 	force = force + (value.force or 0)
    end
    if soulSpirit then
    	force = force + (soulSpirit.force or 0)
    end
    return force
end

function QUIWidgetMetalCityQuickChangeTeam:updateHeroHead(isMockBattle)
	if not self._scrollView then
		return
	end
	
	self._scrollView:clear()
	self._mainHeads = {}
	self._helpHeads = {}
	self._soulHeads = {}
	self._godarmHeads = {}
	self._mountHeads = {}
	self._selectEffect = {}

    local totalWidth = 0
    local teamIndex = 0
    local scale = 0.6
    local offsetX = 0
	local force = 0

	--set main team
	local mainTeams = self._teams[1] or {}
	for i = 1, 4 do
		self._mainHeads[i] = QUIWidgetStormQuickChangeTeamHead.new()
 	 	self._mainHeads[i]:addEventListener(QUIWidgetStormQuickChangeTeamHead.EVENT_HERO_HEAD_CLICK, handler(self, self._clickHeroHead))
 	 	self._mainHeads[i]:setTeamIndexAndPos(1, i)
		self._mainHeads[i]:setScale(scale)

		self._scrollView:addItemBox(self._mainHeads[i])
 	 	local width = self._mainHeads[i]:getContentSize().width*scale+5
 	 	local height = self._mainHeads[i]:getContentSize().height*scale
        self._mainHeads[i]:setPosition(ccp(teamIndex*width+offsetX+width/2, -height/2-12))
        teamIndex = teamIndex + 1
        totalWidth = totalWidth + width

		local actorId = mainTeams[i]
		if actorId ~= nil then
			if isMockBattle then
				local data_ = remote.mockbattle:getCardInfoByIndex(actorId)
				self._mainHeads[i]:setHeroInfo(data_)
		        self._mainHeads[i]:setParam(actorId)
			else

				local heroInfo = remote.herosUtil:getHeroByID(actorId)
				force = force + remote.herosUtil:createHeroProp(heroInfo):getBattleForce()
				self._mainHeads[i]:setHeroSkinId(heroInfo.skinId)
				self._mainHeads[i]:setHero(actorId)
				self._mainHeads[i]:setLevel(heroInfo.level)
				self._mainHeads[i]:setBreakthrough(heroInfo.breakthrough)
				self._mainHeads[i]:setGodSkillShowLevel(heroInfo.godSkillGrade)
				self._mainHeads[i]:setStar(heroInfo.grade)
			end
			self._mainHeads[i]:showSabc()
			self._mainHeads[i]:setEmpty(false)
		else
			self._mainHeads[i]:setEmpty(nil, 1)
		end
		self._mainHeads[i]:showTeamLabel()
	end

	--set soul team
	local soulTeams = self._teams[3] or {}
	local unlock = remote.soulSpirit:checkSoulSpiritUnlock()
	local soulSpiritUnlockLevel = app.unlock:getConfigByKey("UNLOCK_SOUL_SPIRIT").team_level
	local soulSpirit_num = remote.soulSpirit:getTeamSpiritsMaxCount(true)
	if isMockBattle then
		soulSpirit_num = 1
	end

	for i = 1, soulSpirit_num do
		self._soulHeads[i] = QUIWidgetStormQuickChangeTeamHead.new()
 	 	self._soulHeads[i]:addEventListener(QUIWidgetStormQuickChangeTeamHead.EVENT_HERO_HEAD_CLICK, handler(self, self._clickHeroHead))
 	 	self._soulHeads[i]:setTeamIndexAndPos(3, i)
		self._soulHeads[i]:setScale(scale)

		self._scrollView:addItemBox(self._soulHeads[i])
 	 	local width = self._soulHeads[i]:getContentSize().width*scale+5
 	 	local height = self._soulHeads[i]:getContentSize().height*scale
        self._soulHeads[i]:setPosition(ccp(teamIndex*width+offsetX+width/2, -height/2-12))
        teamIndex = teamIndex + 1
        totalWidth = totalWidth + width

		local soulSpiritId = soulTeams[i]
		if not unlock and not isMockBattle then
			self._soulHeads[i]:setLockLevel(soulSpiritUnlockLevel)
		elseif soulSpiritId ~= nil then
			if isMockBattle then
				local data_ = remote.mockbattle:getCardInfoByIndex(soulSpiritId)
				self._soulHeads[i]:setHeroInfo(data_)
		        self._soulHeads[i]:setParam(soulSpiritId)
			else
				local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)
				force = force + remote.soulSpirit:countForceBySpirit(soulSpiritInfo)
				self._soulHeads[i]:setHero(soulSpiritId)
				self._soulHeads[i]:setLevel(soulSpiritInfo.level)
				self._soulHeads[i]:setStar(soulSpiritInfo.grade)
			end
			self._soulHeads[i]:showSabc()
			self._soulHeads[i]:setEmpty(false)
		else
			self._soulHeads[i]:setEmpty(nil, 1, true)
		end
		self._soulHeads[i]:showTeamSoulLabel()
	end

	local godarmTeams = self._teams[4] or {}
	local num_ = isMockBattle and 2 or 4
	for i = 1, num_ do
		self._godarmHeads[i] = QUIWidgetStormQuickChangeTeamHead.new()
 	 	self._godarmHeads[i]:addEventListener(QUIWidgetStormQuickChangeTeamHead.EVENT_HERO_HEAD_CLICK, handler(self, self._clickHeroHead))
 	 	self._godarmHeads[i]:setTeamIndexAndPos(4, i)
		self._godarmHeads[i]:setScale(scale)

		self._scrollView:addItemBox(self._godarmHeads[i])
 	 	local width = self._godarmHeads[i]:getContentSize().width*scale+5
 	 	local height = self._godarmHeads[i]:getContentSize().height*scale
 	 	if isMockBattle and i > 2 then
 	 		self._godarmHeads[i]:setVisible(false)
 	 	else
			self._godarmHeads[i]:setPosition(ccp(teamIndex*width+offsetX+width/2, -height/2-12))
	        teamIndex = teamIndex + 1
	        totalWidth = totalWidth + width	
 	 	end

		local godUnlock = app.unlock:checkLock("UNLOCK_GOD_ARM_"..self._trialNum.."_"..i)
		local godarmUnlock = app.unlock:getConfigByKey("UNLOCK_GOD_ARM_"..self._trialNum.."_"..i).team_level	
		print("godUnlock--godarmUnlock-",godUnlock,godarmUnlock)
		local godarmId = godarmTeams[i]
		if not godUnlock and not isMockBattle then
			self._godarmHeads[i]:setLockLevel(godarmUnlock)
		elseif godarmId ~= nil then

			if isMockBattle then
				local data_ = remote.mockbattle:getCardInfoByIndex(godarmId)
				self._godarmHeads[i]:setHeroInfo(data_)
		        self._godarmHeads[i]:setParam(godarmId)
			else
				local godarmInfo = remote.godarm:getGodarmById(godarmId)
				if godarmInfo then
					force = force + godarmInfo.main_force
					self._godarmHeads[i]:setHero(godarmId)
					self._godarmHeads[i]:setLevel(godarmInfo.level)
					self._godarmHeads[i]:setStar(godarmInfo.grade)
				end
				self._godarmHeads[i]:showSabc()
				self._godarmHeads[i]:setEmpty(false)
			end
		else
			self._godarmHeads[i]:setEmpty(nil, 1, false, true)
		end
		self._godarmHeads[i]:showTeamGodarmLabel()
	end	

	--set help team
	if not isMockBattle then
		local helpTeams = self._teams[2] or {}
		for i = 1, 4 do
			self._helpHeads[i] = QUIWidgetStormQuickChangeTeamHead.new()
	 	 	self._helpHeads[i]:addEventListener(QUIWidgetStormQuickChangeTeamHead.EVENT_HERO_HEAD_CLICK, handler(self, self._clickHeroHead))
	 	 	self._helpHeads[i]:setTeamIndexAndPos(2, i)
			self._helpHeads[i]:setScale(scale)

			self._scrollView:addItemBox(self._helpHeads[i])
	 	 	local width = self._helpHeads[i]:getContentSize().width*scale+5
	 	 	local height = self._helpHeads[i]:getContentSize().height*scale
	 	 	if isMockBattle then
		    	self._helpHeads[i]:setVisible(false)
		    else
		        self._helpHeads[i]:setPosition(ccp(teamIndex*width+offsetX+width/2, -height/2-12))
		        teamIndex = teamIndex + 1
		        totalWidth = totalWidth + width	    	
	    	end
			local unlock = self._helpTeamSlot[i][1]
			local unlockLevel = self._helpTeamSlot[i][2]
			if unlock == false and not isMockBattle then
				self._helpHeads[i]:setLockLevel(unlockLevel)
			else
				local actorId = helpTeams[i]
				if actorId ~= nil then
					if isMockBattle then
						local data_ = remote.mockbattle:getCardInfoByIndex(actorId)
						self._helpHeads[i]:setHeroInfo(data_)
				        self._helpHeads[i]:setParam(actorId)
						self._helpHeads[i]:showSabc()
						self._helpHeads[i]:setEmpty(false)
					else
						local heroInfo = remote.herosUtil:getHeroByID(actorId)
						force = force + remote.herosUtil:createHeroProp(heroInfo):getBattleForce()
						self._helpHeads[i]:setHeroSkinId(heroInfo.skinId)
						self._helpHeads[i]:setHero(actorId)
						self._helpHeads[i]:setLevel(heroInfo.level)
						self._helpHeads[i]:setBreakthrough(heroInfo.breakthrough)
						self._helpHeads[i]:setGodSkillShowLevel(heroInfo.godSkillGrade)
						self._helpHeads[i]:setStar(heroInfo.grade)
						self._helpHeads[i]:showSabc()
						self._helpHeads[i]:setEmpty(false)
						if i <= 2 then
				            self._helpHeads[i]:setSkillTeam(i)
				        else
				            self._helpHeads[i]:setTeam(2)
				        end
			    	end

				else
					self._helpHeads[i]:setEmpty(nil, 2)
				end
			end
			self._helpHeads[i]:showTeamLabel()
		end
	end

	if isMockBattle then

		local mountTeams = self._teams[5] or {}

		for i = 1, 4 do
			self._mountHeads[i] = QUIWidgetStormQuickChangeTeamHead.new()
	 	 	self._mountHeads[i]:addEventListener(QUIWidgetStormQuickChangeTeamHead.EVENT_HERO_HEAD_CLICK, handler(self, self._clickHeroHead))
	 	 	self._mountHeads[i]:setTeamIndexAndPos(5, i)
			self._mountHeads[i]:setScale(scale)
			self._scrollView:addItemBox(self._mountHeads[i])
			local width = self._mountHeads[i]:getContentSize().width*scale+5
 	 		local height = self._mountHeads[i]:getContentSize().height*scale
	        self._mountHeads[i]:setPosition(ccp(teamIndex*width+offsetX+width/2, -height/2-12))
	        teamIndex = teamIndex + 1
	        totalWidth = totalWidth + width	    

			local mountId = mountTeams[i]
			if  mountId ~= nil then
				local data_ = remote.mockbattle:getCardInfoByIndex(mountId)
				self._mountHeads[i]:setHeroInfo(data_)
				self._mountHeads[i]:setParam(mountId)
				self._mountHeads[i]:showSabc()
				self._mountHeads[i]:setEmpty(false)
			else
				self._mountHeads[i]:setEmpty(nil, 5,false,false,true)
			end
			self._mountHeads[i]:showTeamLabel()
		end
	end

    self._scrollView:setRect(0, -50, 0, totalWidth+5)
	if isMockBattle then
		self._ccbOwner.tf_force:setString("")
	else
	    local num, unit = q.convertLargerNumber(force)
		self._ccbOwner.tf_force:setString(num..unit)
	end
end

function QUIWidgetMetalCityQuickChangeTeam:setChangeButton(stated, isSelect)
	if stated then
		self._ccbOwner.node_btn_develop:setVisible(not stated)
		self._ccbOwner.node_btn_change:setVisible(not stated)
	else
		self._ccbOwner.node_btn_develop:setVisible(not isSelect)
		self._ccbOwner.node_btn_change:setVisible(isSelect)
	end
end

function QUIWidgetMetalCityQuickChangeTeam:showHeroHeadEffect(teamIndex, pos)
	local heads = self._mainHeads
	if teamIndex == 2 then
		heads = self._helpHeads
	elseif teamIndex == 3 then
		heads = self._soulHeads
	elseif teamIndex == 4 then
		heads = self._godarmHeads
	elseif teamIndex == 5 then
		heads = self._mountHeads
	end

	if q.isEmpty(heads) == false and heads[pos] then
		local effect = QUIWidgetAnimationPlayer.new()
		heads[pos]:addChild(effect)
		effect:setScale(1.5)
		effect:playAnimation("effects/jiaohuan_tx_yjhd.ccbi")
	end
end

function QUIWidgetMetalCityQuickChangeTeam:showSelectEffect(teamIndex, pos)
	local heads = self._mainHeads
	if teamIndex == 2 then
		heads = self._helpHeads
	elseif teamIndex == 3 then
		heads = self._soulHeads
	elseif teamIndex == 4 then
		heads = self._godarmHeads		
	elseif teamIndex == 5 then
		heads = self._mountHeads		
	end
	if self._selectEffect[teamIndex] == nil then
		self._selectEffect[teamIndex] = {}
	end

	if q.isEmpty(heads) == false and heads[pos] then
		self._selectEffect[teamIndex][pos] = QUIWidgetAnimationPlayer.new()
		heads[pos]:addChild(self._selectEffect[teamIndex][pos])
		self._selectEffect[teamIndex][pos]:setVisible(true)
		self._selectEffect[teamIndex][pos]:setScale(1.5)
		self._selectEffect[teamIndex][pos]:playAnimation("effects/xuanzhong_tx_yjhd.ccbi", nil, nil, false)
	end
end

function QUIWidgetMetalCityQuickChangeTeam:hideSelectEffect()
	if self._selectEffect then
		for i = 1, 2 do
			for j = 1, 4 do
				if self._selectEffect[i] and self._selectEffect[i][j] then
					self._selectEffect[i][j]:setVisible(false)
				end
			end
		end
	end
end

function QUIWidgetMetalCityQuickChangeTeam:_onTriggerDetail(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_detail) == false then return end
	app.sound:playSound("common_small")

	self:dispatchEvent({name = QUIWidgetMetalCityQuickChangeTeam.EVENT_CLICK_DETAIL, trialNum = self._trialNum})
end

function QUIWidgetMetalCityQuickChangeTeam:_clickHeroHead(event)
	if event == nil then return end

	local teamIndex, teamPos = event.target:getTeamIndexAndPos()
	self:dispatchEvent({name = QUIWidgetMetalCityQuickChangeTeam.EVENT_CLICK_HERO_HEAD, trialNum = self._trialNum, teamIndex = teamIndex, teamPos = teamPos, actorId = event.target:getHeroId()})
end

function QUIWidgetMetalCityQuickChangeTeam:_onTriggerChange(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_change) == false then return end
	app.sound:playSound("common_small")

	self:dispatchEvent({name = QUIWidgetMetalCityQuickChangeTeam.EVENT_CLICK_TEAM_CHANGE, trialNum = self._trialNum})
end

function QUIWidgetMetalCityQuickChangeTeam:_onTriggerDevelop(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_develop) == false then return end
	app.sound:playSound("common_small")

	self:dispatchEvent({name = QUIWidgetMetalCityQuickChangeTeam.EVENT_CLICK_TEAM_CHANGE, trialNum = self._trialNum})
end

function QUIWidgetMetalCityQuickChangeTeam:getContentSize()
	return self._ccbOwner.sp_bg:getContentSize()
end

return QUIWidgetMetalCityQuickChangeTeam
