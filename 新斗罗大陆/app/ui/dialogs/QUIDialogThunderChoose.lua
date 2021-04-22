local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogThunderChoose = class("QUIDialogThunderChoose", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QThunderArrangement = import("...arrangement.QThunderArrangement")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIDialogThunderChoose:ctor(options)
	local ccbFile = "ccb/Dialog_ThunderKing_ChoosePass.ccbi";
	local callBacks = 
	{
		{ccbCallbackName = "onTriggerQuickFight1", callback = handler(self, self._onTriggerQuickFight1)},
		{ccbCallbackName = "onTriggerQuickFight2", callback = handler(self, self._onTriggerQuickFight2)},
		{ccbCallbackName = "onTriggerQuickFight3", callback = handler(self, self._onTriggerQuickFight3)},
		{ccbCallbackName = "onTriggerFight1", callback = handler(self, self._onTriggerFight1)},
		{ccbCallbackName = "onTriggerFight2", callback = handler(self, self._onTriggerFight2)},
		{ccbCallbackName = "onTriggerFight3", callback = handler(self, self._onTriggerFight3)},
		{ccbCallbackName = "onTriggerSmallFight1", callback = handler(self, self._onTriggerSmallFight1)},
		{ccbCallbackName = "onTriggerSmallFight2", callback = handler(self, self._onTriggerSmallFight2)},
		{ccbCallbackName = "onTriggerSmallFight3", callback = handler(self, self._onTriggerSmallFight3)},
	}
	QUIDialogThunderChoose.super.ctor(self,ccbFile,callBacks,options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
	page:setScalingVisible(false)
    page.topBar:showWithThunder()

    CalculateUIBgSize(self._ccbOwner.sp_bg)

    setShadow5(self._ccbOwner.tf_condition)
    setShadow5(self._ccbOwner.tf_shadow1)
    self._ccbOwner.tf_shadow1:setString("胜利条件：")

	self._index = options.index
	self._config = options.config
	self._passStar = options.passStar or 0
	if self._avatar == nil then
		self._avatar = QUIWidgetHeroInformation.new()
		self._ccbOwner.node_avatar:addChild(self._avatar)
		self._avatar:setBackgroundVisible(false)
		self._avatar:setNameVisible(false)
	end
	local dungeonConfig = QStaticDatabase:sharedDatabase():getDungeonConfigByID(self._config["dungeon"..self._index.."_easy"])
	local monsterConfig = QStaticDatabase:sharedDatabase():getMonstersById(dungeonConfig.monster_id)
	local actorId = nil
	if monsterConfig ~= nil and #monsterConfig > 0 then
		for i,value in pairs(monsterConfig) do
			-- TOFIX: SHRINK
			local value = q.cloneShrinkedObject(value)
			if actorId == nil or value.is_boss then
				actorId = value.npc_id
			end
		end
	end
	self._avatar:setAvatarByHeroInfo(nil, actorId, 1)
	for i=1,3 do
		self._ccbOwner["tf_star"..i]:setString(i)
	end

    local battleForce = remote.herosUtil:getMostHeroBattleForce()
	self._hards = {}
	self._skipBattle = {}
	self._hards[1] = self._config["dungeon"..self._index.."_easy"]
	local dungeonConfig = QStaticDatabase:sharedDatabase():getDungeonConfigByID(self._hards[1])
	-- self._ccbOwner.tf_title_name:setString(dungeonConfig.name)
	self._ccbOwner.tf_thunder1:setString(dungeonConfig.thunder_money)
	self._ccbOwner.tf_money1:setString(dungeonConfig.money)
	self._skipBattle[1] = self:checkSkipBattle(tonumber(dungeonConfig.thunder_force or 0))
	local num,unit = q.convertLargerNumber(tonumber(dungeonConfig.thunder_force or 0))
	unit = unit or ""
	self._ccbOwner.tf_force1:setString(num..unit)
	self._ccbOwner.node_no_fast1:setVisible(self._passStar < 1)
	self._ccbOwner.node_fast1:setVisible(self._passStar > 0)
	local forceEasy = tonumber(dungeonConfig.thunder_force or 0)

	self:chat(dungeonConfig.description or "")
	local targetConfig = QStaticDatabase:sharedDatabase():getThunderCompleteByDungeonId(self._hards[1])
	self._ccbOwner.tf_condition:setString(targetConfig.target_text)
	self._hards[2] = self._config["dungeon"..self._index.."_normal"]
	local dungeonConfig = QStaticDatabase:sharedDatabase():getDungeonConfigByID(self._hards[2])
	self._ccbOwner.tf_thunder2:setString(dungeonConfig.thunder_money)
	self._ccbOwner.tf_money2:setString(dungeonConfig.money)
	self._skipBattle[2] = self:checkSkipBattle(tonumber(dungeonConfig.thunder_force or 0))
	local num,unit = q.convertLargerNumber(tonumber(dungeonConfig.thunder_force or 0))
	unit = unit or ""
	self._ccbOwner.tf_force2:setString(num..unit)
	self._ccbOwner.node_no_fast2:setVisible(self._passStar < 2)
	self._ccbOwner.node_fast2:setVisible(self._passStar > 1)
	local forceNormal = tonumber(dungeonConfig.thunder_force or 0)

	self._hards[3] = self._config["dungeon"..self._index.."_hard"]
	local dungeonConfig = QStaticDatabase:sharedDatabase():getDungeonConfigByID(self._hards[3])
	self._ccbOwner.tf_thunder3:setString(dungeonConfig.thunder_money)
	self._ccbOwner.tf_money3:setString(dungeonConfig.money)
	self._skipBattle[3] = self:checkSkipBattle(tonumber(dungeonConfig.thunder_force or 0))
	local num,unit = q.convertLargerNumber(tonumber(dungeonConfig.thunder_force or 0))
	unit = unit or ""
	self._ccbOwner.tf_force3:setString(num..unit)
	self._ccbOwner.node_no_fast3:setVisible(self._passStar < 3)
	self._ccbOwner.node_fast3:setVisible(self._passStar > 2)
	local forceHard = tonumber(dungeonConfig.thunder_force or 0)

	self._ccbOwner.sp_recommend_1:setVisible(false)
	self._ccbOwner.sp_recommend_2:setVisible(false)
	self._ccbOwner.sp_recommend_3:setVisible(false)
	if battleForce >= forceHard then
		self._ccbOwner.sp_recommend_3:setVisible(self._passStar < 3)
	elseif battleForce >= forceNormal then
		self._ccbOwner.sp_recommend_2:setVisible(self._passStar < 2)
	elseif battleForce >= forceEasy then
		self._ccbOwner.sp_recommend_1:setVisible(self._passStar < 1)
	end
end

function QUIDialogThunderChoose:checkSkipBattle(force)
	--检查战力是否符合跳关要求
	local configForce = force or 0
	local topNForce = remote.herosUtil:getMostHeroBattleForce()
	if math.floor(topNForce / configForce) >= 3 then
		return true
	end
end

function QUIDialogThunderChoose:chat(str)
	if str == nil or str == "" then return end
	if self._speak == nil then
		self._speak = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_chat:addChild(self._speak)
	else
		self._speak.disappear()
	end
	self._speak:playAnimation("effects/chat_tips.ccbi", function (ccbOwner)
		ccbOwner.tf_chat:setString(str)
	end,nil,false,"one")
end

function QUIDialogThunderChoose:viewDidAppear()
    QUIDialogThunderChoose.super.viewDidAppear(self)
	self:addBackEvent(false)
end

function QUIDialogThunderChoose:viewWillDisappear()
    QUIDialogThunderChoose.super.viewWillDisappear(self)
	self:removeBackEvent()
end

function QUIDialogThunderChoose:_gotoTeam(hard) --todo
	local options = {}
	options.waveType = remote.thunder.LEVEL_WAVE
	options.hard = hard
	options.floor = self._config.thunder_floor
	options.wave = tonumber(self._index)
	options.dungeonId = self._hards[hard]
	-- options.NPCLevel = self._NPCLevel.npc_level[hard]
	local buffs = {}
	for _,id in pairs(remote.thunder:getAllBuff()) do
		local buffConfig = QStaticDatabase:sharedDatabase():getThunderBuffById(id)
		table.insert(buffs, buffConfig.buff_id)
	end
	options.buffs = buffs

	local fightFunc = function ( )
		local dungeonArrangement = QThunderArrangement.new(options)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement", 
	     	options = {arrangement = dungeonArrangement}})
	end

	local actorIds = remote.teamManager:getActorIdsByKey(remote.teamManager.THUNDER_TEAM)
  	if q.isEmpty(actorIds) then
		app:alert({content="还未设置战队，无法参加战斗！现在就去设置战队？",title="系统提示", callback = function (state)
					if state == ALERT_TYPE.CONFIRM then
						fightFunc()
					end
				end})
    	return 
  	end

    --检查是否可以跳过战斗
    if self._skipBattle[hard] then	
    	print("是否勾选---",remote.thunder:getShowSkipBattle())
    	if remote.thunder:getShowSkipBattle() == true then --本次登录不显示
    		if remote.thunder.battleType == 1 then
    			fightFunc()
    		elseif remote.thunder.battleType == 2 then
    			self:_quickFight(hard,true)
    		end
    	else
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDungeonSkipBattle", 
				options = {selectCallback = function(flag)
					remote.thunder:setShowSkipBattle(flag)
				end,battleCallback = function()
					if self:safeCheck() and fightFunc then
						remote.thunder.battleType = 1
						fightFunc()
					end
				end, 
				skipBattleCallback = function()
					if self:safeCheck() then
						remote.thunder.battleType = 2
						self:_quickFight(hard,true)
					end
				end}}, {isPopCurrentDialog = false})	
		end
    else
    	if remote.thunder.forceNoEnoughTip == 0 then
    		remote.thunder.forceNoEnoughTip = 1
    		app.tip:floatTip("当前战力不满足跳过需求，请自行攻打")
    	end
    	fightFunc()
	end


end

function QUIDialogThunderChoose:_quickFight(hard,skipflag)
	local oldUser = nil
	local dungeonConfig = nil
	local oldThunderInfo = nil
	if skipflag then
		oldUser = remote.user:clone()
		dungeonConfig = clone(db:getDungeonConfigByID(self._hards[hard]))
	    dungeonConfig.oldThunderInfo = {}
	    oldThunderInfo = remote.thunder:getThunderFighter()
	    table.insert(dungeonConfig.oldThunderInfo, oldThunderInfo)
		dungeonConfig.waveType = remote.thunder.LEVEL_WAVE
		dungeonConfig.hard = hard
		dungeonConfig.floor = self._config.thunder_floor
		dungeonConfig.wave = tonumber(self._index)
		dungeonConfig.dungeonId = self._hards[hard]	    
	end
	if not skipflag then
		remote.thunder.battleType = 1
		remote.thunder:setIsFast(false, true)		
	end
	remote.thunder:thunderFastFightRequest(hard, hard,skipflag,function(result)
		if not skipflag then
			return
		end   	
        
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunderFightSkipEnd", 
		options = {dungeonConfig = dungeonConfig, oldUser = oldUser, result = result, callBack = function()
				if self:safeCheck() then
					self:popSelf()
				end
				remote.thunder:setIsFast(false,true)
			end}}, {isPopCurrentDialog = false})	

	end)
	self:_onTriggerBack()
end

function QUIDialogThunderChoose:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogThunderChoose:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

function QUIDialogThunderChoose:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogThunderChoose:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QUIDialogThunderChoose:_onTriggerFight1(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_fight1) == false then return end
    app.sound:playSound("common_small")
	self:_gotoTeam(1)
end

function QUIDialogThunderChoose:_onTriggerFight2(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_fight2) == false then return end
    app.sound:playSound("common_small")
	self:_gotoTeam(2)
end

function QUIDialogThunderChoose:_onTriggerFight3(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_fight3) == false then return end
    app.sound:playSound("common_small")
	self:_gotoTeam(3)
end

function QUIDialogThunderChoose:_onTriggerSmallFight1(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_fight_small1) == false then return end
    app.sound:playSound("common_small")
	self:_gotoTeam(1)
end

function QUIDialogThunderChoose:_onTriggerSmallFight2(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_fight_small2) == false then return end
    app.sound:playSound("common_small")
	self:_gotoTeam(2)
end

function QUIDialogThunderChoose:_onTriggerSmallFight3(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_fight_small3) == false then return end
    app.sound:playSound("common_small")
	self:_gotoTeam(3)
end

function QUIDialogThunderChoose:_onTriggerQuickFight1(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_fast1) == false then return end
    app.sound:playSound("common_small")
	self:_quickFight(1)
end

function QUIDialogThunderChoose:_onTriggerQuickFight2(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_fast2) == false then return end
    app.sound:playSound("common_small")
	self:_quickFight(2)
end

function QUIDialogThunderChoose:_onTriggerQuickFight3(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_fast3) == false then return end
    app.sound:playSound("common_small")
	self:_quickFight(3)
end

return QUIDialogThunderChoose