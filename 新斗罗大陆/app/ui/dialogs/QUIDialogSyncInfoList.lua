


local QUIDialog = import(".QUIDialog")
local QUIDialogSyncInfoList = class("QUIDialogSyncInfoList", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetSyncInfoList = import("..widgets.QUIWidgetSyncInfoList")
local QReplayUtil = import("..utils.QReplayUtil")

function QUIDialogSyncInfoList:ctor(options)
	local ccbFile = "ccb/Dialog_SyncInfoList.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSyncInfoList.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    
 --    self._curTeamKey = options.teamKey
 --    self._teamType = options.teamType
 --    -- QPrintTable(options)
 	self._configList = options.configList
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)
    q.setButtonEnableShadow(self._ccbOwner.btn_close)
 	self._onlyAttack = options.onlyAttack or false
 	
    self._teams = options.teams

    self._teamType = options.teamType
	self._battleType = options.battleType
    self._battleFormationList = options.battleFormationList
    self._idx = 0
    self._data ={}
 	self._action =false
	self._ccbOwner.frame_tf_title:setString("阵容同步")
	self._ccbOwner.button_ok:setVisible(false)

end

function QUIDialogSyncInfoList:viewDidAppear()
	QUIDialogSyncInfoList.super.viewDidAppear(self)
	self:initListView()
	self:handlerSync()	
end

function QUIDialogSyncInfoList:viewWillDisappear()
	QUIDialogSyncInfoList.super.viewWillDisappear(self)
end

function QUIDialogSyncInfoList:handlerSyncCall(succeed)

	if self._configList[self._idx] then
		local info = {}
		info.name = self._configList[self._idx].name
		info.succeed = succeed
		table.insert(self._data,info)
	end
	self:initListView()
	self:handlerSync()
end

function QUIDialogSyncInfoList:handlerSync()
	self._idx = self._idx  + 1
	local config = self._configList[self._idx] 

	if config then
		QPrintTable(config)

		if config.isUnion  then
			if remote.union:checkHaveUnion() == false then
				self:handlerSyncCall(true)
				return 
		    end
		end

		for index,teamKey in ipairs(config.attack_keys or {}) do
			if self._teamType == 1 or self._teamType == 3 then	--	单队玩法只同步 第一个阵容
				remote.teamManager:updateTeamData(teamKey, self._teams[1])
			else
				remote.teamManager:updateTeamData(teamKey, self._teams[index])
			end
		end
		for index,teamKey in ipairs(config.defence_keys or {}) do
			if self._teamType == 1 or self._teamType == 3 then	--	单队玩法只同步 第一个阵容
				remote.teamManager:updateTeamData(teamKey, self._teams[1])
			else
				remote.teamManager:updateTeamData(teamKey, self._teams[index])
			end
		end

		if config.battleType and not self._onlyAttack then
			self._action = true
			self:requestForChangeDefenseTeamInfo(config.battleType)
			return
		else
			self:handlerSyncCall(true)
			return
		end
	else
		self._action = false
		self._ccbOwner.button_ok:setVisible(true)
		return
	end
	self._action = false
	self._ccbOwner.button_ok:setVisible(true)
end


function QUIDialogSyncInfoList:initListView()
	if self._listViewLayout then
		self._listViewLayout:setContentSize(self._ccbOwner.sheet_content:getContentSize())
		self._listViewLayout:resetTouchRect()
	end
	local totalNumber = #self._data
    if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = handler(self, self._renderCallBack),
	        curOriginOffset = 0,
	        contentOffsetX = 0,
	        curOffset = 0,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	spaceY = 0,
	      	spaceX = 0,
	      	isVertical = true,
	        totalNumber = #self._data,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_content,cfg)
	else
		self._listViewLayout:reload({totalNumber = totalNumber, tailIndex = totalNumber})
	end
end

function QUIDialogSyncInfoList:_renderCallBack(list, index, info )
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache()
    if not item then
		item = QUIWidgetSyncInfoList.new()
    	isCacheNode = false
    end
    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()
    return isCacheNode
end

function QUIDialogSyncInfoList:requestForChangeDefenseTeamInfo(battleType)
	if battleType == BattleTypeEnum.ARENA then
		self:changeArena()
	elseif battleType == BattleTypeEnum.KUAFU_MINE then
		self:changeKuafuMine()
	elseif battleType == BattleTypeEnum.SILVER_MINE then
		self:changeSilverMine()
	elseif battleType == BattleTypeEnum.GLORY_TOWER then
		self:changeGloryTower()
	elseif battleType == BattleTypeEnum.FIGHT_CLUB then
		self:changeFightClub()
	elseif battleType == BattleTypeEnum.SILVES_ARENA then
		self:changeSilvesArena()
	elseif battleType == BattleTypeEnum.CONSORTIA_WAR then
		self:changeConsortiaWar()
	elseif battleType == BattleTypeEnum.SANCTUARY_WAR then
		self:changeSanctuaryWar()
	elseif battleType == BattleTypeEnum.STORM then
		self:changeStorm()
	elseif battleType == BattleTypeEnum.MARITIME then
		self:changeMaritime()
	end
end


-- BattleTypeEnum.ARENA
function QUIDialogSyncInfoList:changeArena()
	local battleFormation = self._battleFormationList[1]
	remote.arena:requestSetDefenseHero(battleFormation, function()
			if self._battleType == BattleTypeEnum.ARENA then
				remote.arena:setNeedRefreshMark(true)
			end
			if self:safeCheck() then
				print("changeArena success")
				self._action = false
				self:handlerSyncCall(true)
			end

		end)
end
--BattleTypeEnum.KUAFU_MINE
function QUIDialogSyncInfoList:changeKuafuMine()
	remote.plunder:plunderChangeDefenseHerosRequest(self._teams[1], function()
			if self:safeCheck() then
				print("changeKuafuMine success")
				self._action = false
				self:handlerSyncCall(true)
			end
		end)
end

--BattleTypeEnum.SILVER_MINE
function QUIDialogSyncInfoList:changeSilverMine()
	remote.silverMine:requestSetDefenseHero(self._teams[1], function()
			if self:safeCheck() then
				print("changeSilverMine success")
				self._action = false
				self:handlerSyncCall(true)
			end
		end)
end

--BattleTypeEnum.GLORY_TOWER
function QUIDialogSyncInfoList:changeGloryTower()
	local battleFormation = self._battleFormationList[1]
	remote.tower:towerChangeDefenseHeroesRequest(battleFormation, function()
			if self:safeCheck() then
				print("changeGloryTower success")
				self._action = false
				self:handlerSyncCall(true)
			end
		end)
end

--BattleTypeEnum.FIGHT_CLUB
function QUIDialogSyncInfoList:changeFightClub()
	local battleFormation = self._battleFormationList[1]
	remote.fightClub:requestModifyFightClubDefenseTeam(battleFormation, function()
			remote.fightClub:requestFightClubInfo()
			if self:safeCheck() then
				print("changeFightClub success")
				self._action = false
				self:handlerSyncCall(true)
			end
		end)
end

--BattleTypeEnum.SILVES_ARENA
function QUIDialogSyncInfoList:changeSilvesArena()
	local battleFormation = self._battleFormationList[1]
	remote.silvesArena:silvesArenaChangeDefenseArmyRequest(battleFormation, function()
			remote.silvesArena:silvesArenaGetMainInfoRequest()
			if self:safeCheck() then
				print("changeFightClub success")
				self._action = false
				self:handlerSyncCall(true)
			end			
		end)
end

--BattleTypeEnum.CONSORTIA_WAR
function QUIDialogSyncInfoList:changeConsortiaWar()
	local battleFormation1 = self._battleFormationList[1]
	local battleFormation2 = self._battleFormationList[2]
	remote.consortiaWar:consortiaWarSetDefenseArmyRequest(battleFormation1, battleFormation2, function ()
		if self:safeCheck() then
			print("changeConsortiaWar success")
			self._action = false
			self:handlerSyncCall(true)
		end				
	end)
end

--BattleTypeEnum.SANCTUARY_WAR
function QUIDialogSyncInfoList:changeSanctuaryWar()
	local replayData = QReplayUtil:createReplayFighterBuffer(remote.teamManager.SANCTUARY_DEFEND_TEAM1, remote.teamManager.SANCTUARY_DEFEND_TEAM2)
	replayData = crypto.encodeBase64(replayData)
	local battleFormation1 = self._battleFormationList[1]
	local battleFormation2 = self._battleFormationList[2]
	local can ,isSign= remote.sanctuary:checkCanSaveFormation()
	if isSign then
		remote.sanctuary:sanctuaryWarSignUpRequest(battleFormation1, battleFormation2, replayData, function ()
					if self:safeCheck() then
						print("changeSanctuaryWar success")
						self._action = false
						self:handlerSyncCall(true)
					end		
				end,  function ()
					if self:safeCheck() then
						print("changeSanctuaryWar fail")
						self._action = false
						self:handlerSyncCall(false)
					end		
				end)
	else
		remote.sanctuary:sanctuaryWarModifyArmyRequest(battleFormation1, battleFormation2, replayData, function ()
				if self:safeCheck() then
					print("changeSanctuaryWar success")
					self._action = false
					self:handlerSyncCall(true)
				end		
			end,  function ()
				if self:safeCheck() then
					print("changeSanctuaryWar fail")
					self._action = false
					self:handlerSyncCall(false)
				end		
			end)
	end
end

--BattleTypeEnum.STORM
function QUIDialogSyncInfoList:changeStorm()
	local battleFormation1 = self._battleFormationList[1]
	local battleFormation2 = self._battleFormationList[2]	
	remote.stormArena:requestChangeStormDefendTeam(battleFormation1, battleFormation2, function ()
			if self:safeCheck() then
				print("changeStorm success")
				self._action = false
				self:handlerSyncCall(true)
			end		
		end)
end

--BattleTypeEnum.MARITIME
function QUIDialogSyncInfoList:changeMaritime()
	local battleFormation1 = self._battleFormationList[1]
	local battleFormation2 = self._battleFormationList[2]	
	remote.maritime:requestSetMaritimeDefenseTeam(battleFormation1, battleFormation2, function ()
			if self:safeCheck() then
				print("changeMaritime success")
				self._action = false
				self:handlerSyncCall(true)
			end		
		end)
end


function QUIDialogSyncInfoList:_onTriggerOK()
	print("QUIDialogSyncInfoList:_onTriggerOK()")
	self._action = false
	self:popSelf()
end

function QUIDialogSyncInfoList:_onTriggerClose()
	print("QUIDialogSyncInfoList:_onTriggerClose()")
	if self._action then 
		return 
	end

	app.sound:playSound("common_cancel")
	self:playEffectOut()
	if self._callback then
		self._callback()
	end

end

return QUIDialogSyncInfoList