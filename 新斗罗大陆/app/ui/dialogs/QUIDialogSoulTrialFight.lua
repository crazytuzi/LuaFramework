local QUIDialog = import(".QUIDialog")
local QUIDialogSoulTrialFight = class("QUIDialogSoulTrialFight", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QDungeonArrangement = import("...arrangement.QDungeonArrangement")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIViewController = import("..QUIViewController")

function QUIDialogSoulTrialFight:ctor(options)
	local ccbFile = "ccb/Dialog_SoulTrial_Fight.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogSoulTrialFight._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSoulTrialFight._onTriggerClose)},
	}
	QUIDialogSoulTrialFight.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(false)

    self._ccbOwner.frame_tf_title:setString("挑战试炼")
    self._ccbOwner.tf_bossName = setShadow5(self._ccbOwner.tf_bossName)

    self._config = options.config
    if self._config.condition_1 == 201 then
    	self._dungeonId = self._config.num_1
    elseif self._config.condition_2 == 201 then
    	self._dungeonId = self._config.num_2
   	end

    local dungeonConfig = QStaticDatabase.sharedDatabase():getDungeonConfigByID(self._dungeonId)
    local monsterConfig = QStaticDatabase.sharedDatabase():getMonstersById(dungeonConfig.monster_id)

    self._ccbOwner.node_avatar:removeAllChildren()
	local monsterData = {}
	if monsterConfig ~= nil and #monsterConfig > 0 then
		for i,value in ipairs(monsterConfig) do
			local value = q.cloneShrinkedObject(value)
			value.npc_index = i
			table.insert(monsterData, value)
		end
		table.sort(monsterData,function (a, b)
				if a.is_boss ~= b.is_boss then
					if a.is_boss == true or b.is_boss == true then
						return a.is_boss or false
					end
				end
				return a.wave > b.wave
			end)
		--过滤重复的怪物
		local tempData = {}
		local tempData2 = {}
		for _,value in pairs(monsterData) do
			local npc_id = app:getBattleRandomNpcID(dungeonConfig.monster_id, value.npc_index, value.npc_id)
			if tempData[npc_id] == nil then
				tempData[npc_id] = 1
				local clone_value = clone(value)
				clone_value.npc_id = npc_id
				table.insert(tempData2,clone_value)
			end
		end
		monsterData = tempData2
	end
	--找出第一个显示avatar的怪物
	local avatarValue = nil
	local appear = nil
	for _,value in pairs(monsterData) do
		if value.display == true then
			avatarValue = value
			break
		end
		if avatarValue == nil then
			avatarValue = value
		end
		if value.wave == 1 and (appear == nil or appear > value.appear) then
			avatarValue = value
			appear = value.appear
		end
	end

	local characterConfig = QStaticDatabase:sharedDatabase():getCharacterByID(avatarValue.npc_id)
	local characterData = QStaticDatabase:sharedDatabase():getCharacterData(avatarValue.npc_id, characterConfig.data_type, avatarValue.npc_difficulty, avatarValue.npc_level)
	local breakthroughLevel,color = remote.herosUtil:getBreakThrough(characterData.breakthrough)
	-- self._ccbOwner.tf_bossName:setString("LV."..characterData.npc_level.."  "..characterConfig.name)
	self._ccbOwner.tf_bossName:setString(characterConfig.name)
	self._ccbOwner.tf_bossName:setColor(BREAKTHROUGH_COLOR_LIGHT[color])

	self._ccbOwner.tf_desc:setString(self._config.description)

    self._avatar = QUIWidgetHeroInformation.new()
    local scale = dungeonConfig.boss_size or 1 
	self._avatar:setAvatar(avatarValue.npc_id, scale)
	self._avatar:setNameVisible(false)
    self._avatar:setBackgroundVisible(false)
    self._avatar:setStarVisible(false)
    self._avatar:showStar(0)
    self._ccbOwner.node_avatar:addChild(self._avatar)
    
    local num, unit = q.convertLargerNumber(self._config.recommend_force or 0)
    self._ccbOwner.tf_remmendForce:setString(num..unit)
end

function QUIDialogSoulTrialFight:viewDidAppear()
	QUIDialogSoulTrialFight.super.viewDidAppear(self)
end 

function QUIDialogSoulTrialFight:viewWillDisappear()
	QUIDialogSoulTrialFight.super.viewWillDisappear(self)
end 

function QUIDialogSoulTrialFight:_onTriggerConfirm(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_ok) == false then return end
	app.sound:playSound("common_small")
	local dungeonArrangement = QDungeonArrangement.new({dungeonId = self._dungeonId, battleType = BattleTypeEnum.SOUL_TRIAL})
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement", 
			options = {arrangement = dungeonArrangement}})
end

-- function QUIDialogSoulTrialFight:_backClickHandler()
-- 	self:_onTriggerClose()
-- end

function QUIDialogSoulTrialFight:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	if e then
		app.sound:playSound("common_cancel")
	end
   	self:playEffectOut()
end

function QUIDialogSoulTrialFight:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogSoulTrialFight
