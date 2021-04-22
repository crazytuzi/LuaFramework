
local QUIWidget = import(".QUIWidget")
local QUIWidgetHeroSmallFrame = class("QUIWidgetHeroSmallFrame", QUIWidget)

local QUIWidgetHeroHead = import(".QUIWidgetHeroHead")
local QHeroModel = import("...models.QHeroModel")
local QUIWidgetHeroProfessionalIcon = import(".QUIWidgetHeroProfessionalIcon")
local QUIWidgetHeroEquipmentSmallBox = import(".QUIWidgetHeroEquipmentSmallBox")
local QUIWidgetHeroEquipment = import(".QUIWidgetHeroEquipment")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")


QUIWidgetHeroSmallFrame.EVENT_HERO_FRAMES_CLICK = "EVENT_HERO_FRAMES_CLICK"
QUIWidgetHeroSmallFrame.EVENT_SOUL_FRAMES_CLICK = "EVENT_SOUL_FRAMES_CLICK"
QUIWidgetHeroSmallFrame.EVENT_MOUNT_FRAMES_CLICK = "EVENT_MOUNT_FRAMES_CLICK"
QUIWidgetHeroSmallFrame.EVENT_GODARM_FRAMES_CLICK = "EVENT_GODARM_FRAMES_CLICK"


QUIWidgetHeroSmallFrame.EVENT_FORMATION_CLICK = "EVENT_FORMATION_CLICK"

local force_color = {{10000, UNITY_COLOR_LIGHT.white}, {100000, UNITY_COLOR_LIGHT.green}, {500000, UNITY_COLOR_LIGHT.blue}, 
					{1000000, UNITY_COLOR_LIGHT.purple}, {5000000, UNITY_COLOR_LIGHT.orange}}

function QUIWidgetHeroSmallFrame:ctor(options)
	local ccbFile = "ccb/Widget_TeamArangement.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerHeroOverview", callback = handler(self, self._onTriggerHeroOverview)}
	}
	QUIWidgetHeroSmallFrame.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._heroHead = QUIWidgetHeroHead.new({})
	self._heroHead:setTouchEnabled(false)
	self._ccbOwner.node_hero_head:addChild(self._heroHead:getView())

	self._ccbOwner.node_hp:setVisible(false)
	self._ccbOwner.node_dead:setVisible(false)
  	self._ccbOwner.node_mp:setVisible(false)
	self._ccbOwner.node_star:setVisible(false)
	self._ccbOwner.node_team:setVisible(false)
	self._ccbOwner.node_junheng_force:setVisible(false)
	self._ccbOwner.node_metalcity_flag:setVisible(false)

	self._teamIsUnlock = app.unlock:getUnlockHelperDisplay()
end

function QUIWidgetHeroSmallFrame:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_chosen_bg, self._glLayerIndex)
	if self._heroHead then
		self._glLayerIndex = self._heroHead:initGLLayer(self._glLayerIndex)
	end
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_hp_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_hp, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_mp_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_mp, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_dead_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_dead, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_force, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_force, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_godarm_name, self._glLayerIndex)	
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_fight_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_fight, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_star, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_head_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_select, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team5, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team4, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team3, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team0, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_alternate3, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_alternate2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_alternate1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_godarm_team4, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_godarm_team3, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_godarm_team2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_godarm_team1, self._glLayerIndex)	
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_trail_1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_trail_2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team_flag_1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team_flag_2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team_flag_3, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_name, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_ccjh_force, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_dispatch_flag, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_society, self._glLayerIndex)

	return self._glLayerIndex
end

function QUIWidgetHeroSmallFrame:getName()
	return "QUIWidgetHeroSmallFrame"
end

function QUIWidgetHeroSmallFrame:getHero()
	return self._actorId
end

--悬赏任务派遣使用
function QUIWidgetHeroSmallFrame:setDispatchHeroInfo(info,_isFind)
	self._hero = info.heroInfo
	self._actorId = self._hero.actorId

	self._heroHead:setHeroSkinId(self._hero.skinId)
	self._heroHead:setHero(self._hero.actorId, self._hero.level)
	self._heroHead:setStar(self._hero.grade)
	self._heroHead:showSabc()


	self:unselected()
	local isFind = _isFind or false
	if isFind == true then
		self:selectedBgSp()
	else
		self:unselectedBgSp()
	end
	self._ccbOwner.sp_head_bg:setScale(0.85)
	self._ccbOwner.node_society:setVisible(not info.isMine)

	self:removeFight()
	self:setForceColorAndOutline(self._hero.force)
	self:showOfferRewardUsed(info.isUsed)
	local profession = db:getCharacterByID(self._actorId).func or "t"
	self._heroHead:setProfession(profession)
end


function QUIWidgetHeroSmallFrame:setHero(actorId, selectTable,chapterId,isMockBattle)
	self._actorId = actorId
	self._selectTable = selectTable or {}
	if isMockBattle then
		self._hero = remote.mockbattle:getCardInfoById(self._actorId )
		self._heroModel = remote.mockbattle:getCardUiInfoById(self._actorId )
	else
		if chapterId ~= 0 and chapterId ~= nil then
			self._hero = remote.collegetrain:getHeroInfoById(chapterId,actorId)
		else
			self._hero = remote.herosUtil:getHeroByID(self._actorId)
		end
		self._heroModel = remote.herosUtil:createHeroProp(self._hero)
	end



	-- 设置头像显示
	self._heroHead:setHeroSkinId(self._hero.skinId)
	self._heroHead:setHero(self._hero.actorId, self._hero.level)
	self._heroHead:setStar(self._hero.grade)
	self._heroHead:showSabc()

	local show_ = chapterId ~= 0 and chapterId ~= nil 
	show_ = show_ or isMockBattle
	if  show_  then
		self._heroHead:setBreakthrough(self._hero.breakthrough)
		self._heroHead:setGodSkillShowLevel(self._hero.godSkillGrade)
	end

	local isFind = false
	for _,value in pairs(self._selectTable) do
		if value == self._hero.actorId then
			isFind = true
			break
		end
	end
	if isFind == true then
		self:selected()
	else
		self:unselected()
	end
	self:removeFight()

	-- Show profession
	local profession = db:getCharacterByID(self._actorId).func or "t"
	self._heroHead:setProfession(profession)
end

function QUIWidgetHeroSmallFrame:setSoulSpirit(soulSpirit, selectTable,chapterId,isMockBattle)
	self._soulSpiritId = soulSpirit
	self._selectTable = selectTable or {}

	if isMockBattle then
		self._soulSpirit = remote.mockbattle:getCardUiInfoById(self._soulSpiritId)
	else
		print("soulSpirit=",soulSpirit)
		print("chapterId=",chapterId)
		if chapterId ~= 0 and chapterId ~= nil then
			self._soulSpirit = remote.collegetrain:getSpritInfoById(chapterId,soulSpirit)
			--QPrintTable(self._soulSpirit)
		else
			self._soulSpirit = remote.soulSpirit:getMySoulSpiritInfoById(self._soulSpiritId)
		end
	end
	-- 设置头像显示
	self._heroHead:setHero(self._soulSpirit.id, self._soulSpirit.level)
	self._heroHead:setStar(self._soulSpirit.grade)
	self._heroHead:showSabc()
	self._heroHead:setSoulSpiritFrame()

	local isFind = false
	for _,value in pairs(self._selectTable) do
		if value == self._soulSpirit.id then
			isFind = true
			break
		end
	end
	if isFind == true then
		self:selected()
	else
		self:unselected()
	end
	self:removeFight()
end

function QUIWidgetHeroSmallFrame:setMount(mount, selectTable,chapterId,isMockBattle)
	self._mountId = mount
	self._selectTable = selectTable or {}

	if isMockBattle then
		self._mount = remote.mockbattle:getCardUiInfoById(self._mountId)
	else	
		--没有实现
		self._mount = nil
	end
	-- 设置头像显示
	--QPrintTable(self._mount)
	self._heroHead:setHero(self._mount.id, self._mount.level)
	self._heroHead:setStar(self._mount.grade)
	self._heroHead:showSabc()

	local isFind = false
	for _,value in pairs(self._selectTable) do
		if value == self._mount.id then
			isFind = true
			break
		end
	end
	if isFind == true then
		self:selected()
	else
		self:unselected()
	end
	self:removeFight()
end

function QUIWidgetHeroSmallFrame:setGodarmView(godarmInfo, selectTable)
	self._selectTable = selectTable or {}

	self._godarmInfo = godarmInfo
	-- 设置头像显示
	self._heroHead:setHero(godarmInfo.godarmId, godarmInfo.level)
	self._heroHead:setStar(godarmInfo.grade)
	self._heroHead:showSabc()
	self:showGodarmName(godarmInfo.godarmId)
	-- self._heroHead:setSoulSpiritFrame()

	local isFind = false
	for _,value in pairs(self._selectTable) do
		if value == godarmInfo.id then
			isFind = true
			break
		end
	end
	if isFind == true then
		self:selected()
	else
		self:unselected()
	end
	self:removeFight()
end

--用于阵型中使用
------------------------------------------------------------------------------------
function QUIWidgetHeroSmallFrame:setFormationInfo(config)
	self._isFormation = true
	-- QPrintTable(config)
	self._info = config
	self._chapterId = config.chapterId or 0
	self._isMockBattle = config.isMockBattle or false
	local index = nil 
	if self._info.index ~= 0 then
		index = self._info.index
	end
	if config.oType == 2 then
		self:setSoulSpiritByInfoForFormation(config,nil)
		self:setTeam(index, true)
		self:removeBattleForce()
	-- elseif config.oType == "mount" then
	-- 	-- self:setMount(self._info.mountId,nil,self._chapterId,self._isMockBattle)
	-- 	-- self:setTeam(self._info.index, true)
	-- 	-- self:removeBattleForce()
	elseif config.oType == 3 then
		self:setGodArmByInfoForFormation(self._info)
		print("第几个位置-----self._info.pos",self._info.pos)
		self:setTeam(index, true,config.oType,self._info.pos)
		self:removeBattleForce()
	else
		self:setHeroByInfoForFormation(self._info)
		self:setTeam(index)
		self:setForceColor(self._info.force)
	end
	self:showMetalCityStated(self._info.trialNum, index, true, false)
	if self._info.index ~= 0 then
		self:selected()
	else
		self:unselected()
	end

	self._ccbOwner.node_junheng_force:setVisible(false)
	
	if self._info.junhengforce and self._info.junhengforce > 0 then
		self:showJunhengForce(2)
	end

	if self._info.inheritforce and self._info.inheritforce > 0 then
		self:showJunhengForce(1)
	end
end

function QUIWidgetHeroSmallFrame:setHeroByInfoForFormation(info)
	self._heroHead:setHeroSkinId(info.skinId)
	self._heroHead:setHero(info.actorId, info.level)
	self._heroHead:setStar(info.grade)
	self._heroHead:showSabc()
	self:removeFight()
end

function QUIWidgetHeroSmallFrame:setSoulSpiritByInfoForFormation(info)
	self._heroHead:setHero(info.id, info.level)
	self._heroHead:setStar(info.grade)
	self._heroHead:showSabc()
	self._heroHead:setSoulSpiritFrame()
	self:removeFight()
end

function QUIWidgetHeroSmallFrame:setGodArmByInfoForFormation(info)
	self._heroHead:setHero(info.id, info.level)
	self._heroHead:setStar(info.grade)
	self._heroHead:showSabc()
	self:showGodarmName(info.id)
	self:removeFight()
end


------------------------------------------------------------------------------------



function QUIWidgetHeroSmallFrame:setForceColor(force)
	local color = UNITY_COLOR_LIGHT.red
	for k, v in ipairs(force_color) do
		if force < v[1] then
			color = v[2]
			break
		end
	end

	self._ccbOwner.tf_force:setColor(color)
	self._ccbOwner.tf_force:setString(force)
end

function QUIWidgetHeroSmallFrame:setForceColorAndOutline(force)
	local colorInfo =remote.herosUtil:calculateForceColorAndOutline(force)

	if colorInfo then
		self._ccbOwner.tf_force:setColor(colorInfo.fontColor)
		self._ccbOwner.tf_force:setOutlineColor(colorInfo.outlineColor)
		self._ccbOwner.tf_force:enableOutline()
	else
		self._ccbOwner.tf_force:setColor(color)
		self._ccbOwner.tf_force:disableOutline()
	end
   	local num,unit = q.convertLargerNumber(force)
	self._ccbOwner.tf_force:setString(num..(unit or ""))
	-- self._ccbOwner.tf_force:setString(force)
end


--显示战队
function QUIWidgetHeroSmallFrame:setTeam(index,flag,teamType,pos)
	-- if index == nil then return end
	self._ccbOwner.node_team:setVisible(false)
	self._ccbOwner.node_alternate:setVisible(false)

	local count = 1
	while self._ccbOwner["sp_team"..count] ~= nil do
		self._ccbOwner["sp_team"..count]:setVisible(false)
		count = count + 1
	end
	count = 1
	while self._ccbOwner["st_team"..count] ~= nil do
		self._ccbOwner["st_team"..count]:setVisible(false)
		count = count + 1
	end
	count = 1
	while self._ccbOwner["sp_alternate"..count] ~= nil do
		self._ccbOwner["sp_alternate"..count]:setVisible(false)
		count = count + 1
	end
	if self._info.isAlternate then
		local orders = remote.teamManager:getHeroUpOrder(1)
		local num = 1
		for i, actorId in pairs(orders) do
			if self._info.actorId == actorId then
				num = i
				break
			end
		end
		self._ccbOwner.node_alternate:setVisible(true)
		self._ccbOwner["sp_alternate"..num]:setVisible(true)
	elseif self._info.metalCity then
		self._ccbOwner.node_team:setVisible(true)
		self._ccbOwner.sp_team1:setVisible(index == 1)
		self._ccbOwner.sp_team0:setVisible(index == 2)
	else
		if teamType == "godarm" then
			self._ccbOwner.node_team:setVisible(false)
			self._ccbOwner.node_godarm_team:setVisible(true)
			self._ccbOwner.sp_godarm_team1:setVisible(pos == 1)
			self._ccbOwner.sp_godarm_team2:setVisible(pos == 2)
			self._ccbOwner.sp_godarm_team3:setVisible(pos == 3)
			self._ccbOwner.sp_godarm_team4:setVisible(pos == 4)					
		else
			self._ccbOwner.node_team:setVisible(self._teamIsUnlock)
			self._ccbOwner.node_godarm_team:setVisible(false)
			if index then
				self._ccbOwner.sp_team0:setVisible(false)
				self._ccbOwner.sp_team1:setVisible(index == 1)
				self._ccbOwner.sp_team2:setVisible(index == 2)
				self._ccbOwner.sp_team3:setVisible(index == 3)
				self._ccbOwner.sp_team4:setVisible(index == 4)
				self._ccbOwner.sp_team5:setVisible(index == 5)
			end
		end
	end
end

function QUIWidgetHeroSmallFrame:getHeroHpMp(actorId)
end

function QUIWidgetHeroSmallFrame:setStarVisibility(visible)
	self._ccbOwner.node_star:setVisible(visible)
end

--刷新当前信息显示
function QUIWidgetHeroSmallFrame:refreshInfo()
	self:setHero(self._actorId, self._selectTable,self._chapterId,self._isMockBattle)
end

function QUIWidgetHeroSmallFrame:selected()
	self._ccbOwner.node_hero_select:setVisible(true)
end

function QUIWidgetHeroSmallFrame:unselected()
	self._ccbOwner.node_hero_select:setVisible(false)
end


function QUIWidgetHeroSmallFrame:selectedBgSp()
	self._ccbOwner.node_chosen_bg:setVisible(true)
end

function QUIWidgetHeroSmallFrame:unselectedBgSp()
	self._ccbOwner.node_chosen_bg:setVisible(false)
end

function QUIWidgetHeroSmallFrame:setFramePos(pos)
	self._pos = pos
end

function QUIWidgetHeroSmallFrame:getHead()
	return self._heroHead
end

function QUIWidgetHeroSmallFrame:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetHeroSmallFrame:showEquipment()
end

function QUIWidgetHeroSmallFrame:showBattleForce()
	self._ccbOwner.node_hero_battleForce:setVisible(true)
end

function QUIWidgetHeroSmallFrame:showGodarmName( godarmId )
	self._ccbOwner.node_godarm_name:setVisible(true)

	local godarmConfig = db:getCharacterByID(godarmId)
    local aptitudeInfo = db:getActorSABC(godarmId)
    self._ccbOwner.tf_godarm_name:setString(godarmConfig.name or "") 

    local fontColor = UNITY_COLOR_LIGHT[aptitudeInfo.color]
	self._ccbOwner.tf_godarm_name:setColor(fontColor)
    self._ccbOwner.tf_godarm_name = setShadowByFontColor(self._ccbOwner.tf_godarm_name, fontColor)
end
function QUIWidgetHeroSmallFrame:showMetalCityStated(trialNum, teamIndex, isStormArena,isMockBattle)
	if teamIndex == nil or teamIndex == 0 then
		self._ccbOwner.node_metalcity_flag:setVisible(false)
		self._ccbOwner.node_storm_flag:setVisible(false)
		return 
	end

	if isStormArena or isMockBattle then
		self._ccbOwner.node_metalcity_flag:setVisible(false)
		self._ccbOwner.node_storm_flag:setVisible(trialNum ~= nil)
		self._ccbOwner.sp_team_flag_1:setVisible(trialNum == 1)
		self._ccbOwner.sp_team_flag_2:setVisible(trialNum == 2)
		self._ccbOwner.sp_team_flag_3:setVisible(trialNum == 3)
	else
		self._ccbOwner.node_storm_flag:setVisible(false)
		self._ccbOwner.node_metalcity_flag:setVisible(trialNum ~= nil)
		self._ccbOwner.sp_trail_1:setVisible(trialNum == 1)
		self._ccbOwner.sp_trail_2:setVisible(trialNum == 2)
	end
end

function QUIWidgetHeroSmallFrame:showOfferRewardUsed(isUsed)
		self._ccbOwner.node_metalcity_flag:setVisible(false)
		self._ccbOwner.node_storm_flag:setVisible(false)
		self._ccbOwner.sp_team_flag_1:setVisible(false)
		self._ccbOwner.sp_team_flag_2:setVisible(false)
		self._ccbOwner.sp_team_flag_3:setVisible(false)
		self._ccbOwner.node_dispatch_flag:setVisible(isUsed)
end


function QUIWidgetHeroSmallFrame:removeBattleForce()
	self._ccbOwner.node_hero_battleForce:setVisible(false)
end

function QUIWidgetHeroSmallFrame:showFight()
	self._isFight = true
	self._ccbOwner.node_hero_fight:setVisible(true)
end

function QUIWidgetHeroSmallFrame:removeFight()
	self._isFight = false
	self._ccbOwner.node_hero_fight:setVisible(false)
end

function QUIWidgetHeroSmallFrame:setButtonEnabled(b)
	self._ccbOwner.btn_team:setEnabled(b)
end

function QUIWidgetHeroSmallFrame:setInfo(config)
	self._info = config.data
	self._chapterId = config.chapterId or 0
	self._isMockBattle = config.isMockBattle or false
	if config.oType == "soul" then
		self:setSoulSpirit(self._info.soulSpiritId,nil,self._chapterId,self._isMockBattle)
		self:setTeam(self._info.index, true)
		self:removeBattleForce()
	elseif config.oType == "mount" then
		self:setMount(self._info.mountId,nil,self._chapterId,self._isMockBattle)
		self:setTeam(self._info.index, true)
		self:removeBattleForce()
	elseif config.oType == "godarm" then
		self:setGodarmView(self._info)
		print("第几个位置-----self._info.pos",self._info.pos)
		self:setTeam(self._info.index, true,config.oType,self._info.pos)
		self:removeBattleForce()
	else
		self:setHero(self._info.actorId,nil,self._chapterId,self._isMockBattle)
		self:setTeam(self._info.index)
		self:setForceColor(self._info.force)
	end
	self:showMetalCityStated(self._info.trialNum, self._info.index, self._info.isStormArena, self._isMockBattle)
	if self._info.index ~= 0 then
		self:selected()
	end

	self._ccbOwner.node_junheng_force:setVisible(false)
	
	if self._info.junhengforce and self._info.junhengforce > 0 then
		self:showJunhengForce(2)
	end

	if self._info.inheritforce and self._info.inheritforce > 0 then
		self:showJunhengForce(1)
	end
end

function QUIWidgetHeroSmallFrame:showJunhengForce(forceType)
	self._ccbOwner.node_junheng_force:setVisible(true)

	if forceType == 1 then
		QSetDisplaySpriteByPath(self._ccbOwner.sp_name,QResPath("soto_FoceImag")[1])
	    local num, word = q.convertLargerNumber(self._info.inheritforce)
    	self._ccbOwner.tf_ccjh_force:setString(num..word)
		local fontColor = EQUIPMENT_COLOR[2]
	    self._ccbOwner.tf_ccjh_force:setColor(fontColor)
	    self._ccbOwner.tf_ccjh_force = setShadowByFontColor(self._ccbOwner.tf_ccjh_force, fontColor) 	

	elseif forceType == 2 then
		QSetDisplaySpriteByPath(self._ccbOwner.sp_name,QResPath("soto_FoceImag")[2])
	    local num, word = q.convertLargerNumber(self._info.junhengforce)
    	self._ccbOwner.tf_ccjh_force:setString(num..word)
		local fontColor = EQUIPMENT_COLOR[3]
	    self._ccbOwner.tf_ccjh_force:setColor(fontColor)
	    self._ccbOwner.tf_ccjh_force = setShadowByFontColor(self._ccbOwner.tf_ccjh_force, fontColor) 	

	end
end
--event callback area--
function QUIWidgetHeroSmallFrame:_onTriggerHeroOverview(tag, menuItem)
	local position = self:convertToWorldSpaceAR(ccp(0,0))
	local position_head = self._ccbOwner.node_hero_head:convertToWorldSpaceAR(ccp(0,0))
	if self._isFormation then
		self:dispatchEvent({name = QUIWidgetHeroSmallFrame.EVENT_FORMATION_CLICK, info = self._info})
		-- QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetHeroSmallFrame.EVENT_FORMATION_CLICK, info = self._info})
		return
	end



	if self._soulSpirit then
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetHeroSmallFrame.EVENT_SOUL_FRAMES_CLICK, soulSpiritId = self._soulSpirit.id, pos = self._pos, position = position})
	elseif self._mount then
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetHeroSmallFrame.EVENT_MOUNT_FRAMES_CLICK, mountId = self._mount.id, pos = self._pos, position = position ,position_head = position_head})
	elseif self._godarmInfo then
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetHeroSmallFrame.EVENT_GODARM_FRAMES_CLICK, godarmId = self._godarmInfo.godarmId, pos = self._pos, position = position})
	else
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetHeroSmallFrame.EVENT_HERO_FRAMES_CLICK, actorId = self._hero.actorId, pos = self._pos, position = position})
	end
end

return QUIWidgetHeroSmallFrame
