-- @Author: liaoxianbo
-- @Date:   2020-06-30 15:58:40
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-15 17:28:32
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulTowerMonsterIntroduce = class("QUIDialogSoulTowerMonsterIntroduce", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")
local QUIWidgetActorActivityDisplay = import("..widgets.actorDisplay.QUIWidgetActorActivityDisplay")

function QUIDialogSoulTowerMonsterIntroduce:ctor(options)
	local ccbFile = "ccb/Dialog_SoulTower_Monster_Introduce.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onSkillIntroduce1",callback = handler(self,self._onSkillIntroduce1)},
		{ccbCallbackName = "onSkillIntroduce2",callback = handler(self,self._onSkillIntroduce2)},
		{ccbCallbackName = "onSkillIntroduce3",callback = handler(self,self._onSkillIntroduce3)},
		{ccbCallbackName = "onSkillIntroduce4",callback = handler(self,self._onSkillIntroduce4)},
        {ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
        {ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},   		
    }
    QUIDialogSoulTowerMonsterIntroduce.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	q.setButtonEnableShadow(self._ccbOwner.btn_close)

    self._ccbOwner.node_right:setVisible(false)
    self._ccbOwner.node_left:setVisible(false)
    self._ccbOwner.node_tab_num:setVisible(false)

	self._soulTowerFloorInfo = options.floorInfo
	if q.isEmpty(self._soulTowerFloorInfo) == false then
		local waveTbl = string.split(self._soulTowerFloorInfo.wave,"^")
		if q.isEmpty(waveTbl) == false then
			self._waveDungenId = waveTbl[1]
			self._waveLevel = waveTbl[2]
			self._waveMonsterInfo = remote.soultower:getMonsterInfoByWave(self._waveDungenId)
		end
	end
	self._allTabDungens = {}
	self:initData()
	self:initDataView()
end

function QUIDialogSoulTowerMonsterIntroduce:viewDidAppear()
	QUIDialogSoulTowerMonsterIntroduce.super.viewDidAppear(self)
end

function QUIDialogSoulTowerMonsterIntroduce:viewWillDisappear()
  	QUIDialogSoulTowerMonsterIntroduce.super.viewWillDisappear(self)
end

function QUIDialogSoulTowerMonsterIntroduce:initData()
	if q.isEmpty(self._waveMonsterInfo) then return end
	for ii=1,4 do
		if self._waveMonsterInfo["tab"..ii] then
			if not self._allTabDungens[ii] then
				self._allTabDungens[ii] = {}
			end
			local dungenIdTbl = string.split(self._waveMonsterInfo["tab"..ii],";")
			for _,v in pairs(dungenIdTbl) do
				if v then
					local tipsInfo = db:getNewEnemyTips(v)
					table.insert(self._allTabDungens[ii],tipsInfo)
				end
			end
		end
	end
end

function QUIDialogSoulTowerMonsterIntroduce:initDataView()
	if q.isEmpty(self._allTabDungens) then 
		for ii=1,4 do
			local node = self._ccbOwner["node_table_"..ii]
			if node then
				node:setVisible(false)
			end
		end		
		return 
	end
    local tabs = {}
	local index = 1
	for _, tabDungens in pairs(self._allTabDungens) do
		local node = self._ccbOwner["node_table_"..index]
		local btn = self._ccbOwner["tab_skill_"..index]
		if tabDungens[1] and btn then
			ui.tabButton(btn, tabDungens[1].tab_name)
			table.insert(tabs, btn)
			index = index + 1
		end
	end
	self._tabManager = ui.tabManager(tabs)
	for ii=index,4 do
		local node = self._ccbOwner["node_table_"..ii]
		if node then
			node:setVisible(false)
		end
	end
	self:setTable(1)
end

function QUIDialogSoulTowerMonsterIntroduce:setTable(index,cellIndex)
	self._tableIndex = index
	self._tableCellIndex = cellIndex or 1
	

	local btn = self._ccbOwner["tab_skill_"..index]
	if btn == nil then return end
	if q.isEmpty(self._tabManager) then return end
	self._tabManager:selected(btn)

	self._tableCellInfo = {}
	for _,v in pairs(self._allTabDungens[index]) do
		table.insert(self._tableCellInfo,v)
	end
	-- QPrintTable(self._tableCellInfo)
	self._allIntroduceNum = table.nums(self._tableCellInfo)
	self:showHideDirection()

	if self._allIntroduceNum > 1 then
		self._ccbOwner.node_tab_num:setVisible(true)
		self._ccbOwner.node_direc:setVisible(true)	
		self._ccbOwner.tf_curNum:setString(self._tableCellIndex)
		self._ccbOwner.tf_allNum:setString("/"..self._allIntroduceNum)
	else
		self._ccbOwner.node_tab_num:setVisible(false)
		self._ccbOwner.node_direc:setVisible(false)
	end
	self._newEnemyTipsConfig = self._tableCellInfo[self._tableCellIndex]
	-- QPrintTable(self._newEnemyTipsConfig)
	self._ccbOwner.sp_skillShow:setPositionX(7)
	
	self:_setBossInfo()
	self:_showSkill()
	self:_setBossAvart()
end

function QUIDialogSoulTowerMonsterIntroduce:showHideDirection()
	print("self._tableCellIndex,self._allIntroduceNum",self._tableCellIndex,self._allIntroduceNum)
    if self._tableCellIndex == 1 then
        self._ccbOwner.node_left:setVisible(false)
        self._ccbOwner.node_right:setVisible(true)
    elseif self._tableCellIndex == self._allIntroduceNum then
        self._ccbOwner.node_left:setVisible(true)
        self._ccbOwner.node_right:setVisible(false)
    else
        self._ccbOwner.node_left:setVisible(true)
        self._ccbOwner.node_right:setVisible(true)
    end
end
function QUIDialogSoulTowerMonsterIntroduce:_setBossInfo()
    self._ccbOwner.tf_title_name:setString("")
    self._ccbOwner.node_skill_desc:removeAllChildren()
    if not self._newEnemyTipsConfig then return end

    self._ccbOwner.tf_title_name:setString(self._newEnemyTipsConfig.enemy_name or "")

    local skillDescList = string.split(self._newEnemyTipsConfig.description, ";")

    local totalHeight = 0
    for index, str in ipairs(skillDescList) do
        local richText = QRichText.new(str, 800, {autoCenter = false, stringType = 1})
        richText:setAnchorPoint(ccp(0,1))
        richText:setPosition(ccp(0,-totalHeight))
        self._ccbOwner.node_skill_desc:addChild(richText)
        totalHeight = totalHeight + richText:getContentSize().height
    end
end

function QUIDialogSoulTowerMonsterIntroduce:_setBossAvart( ... )
	if not self._newEnemyTipsConfig then return end
	self._ccbOwner.node_avart:removeAllChildren()

	if self._newEnemyTipsConfig.enemy_id then
	    local enemyList = {}
	    local enemyLocation = self._newEnemyTipsConfig.enemy_location or "0, 0"
	    local enemyScale = self._newEnemyTipsConfig.enemy_scale or 1
	    local enemyDirection = self._newEnemyTipsConfig.enemy_direction or 1
	    enemyList = {posStr = enemyLocation, scale = tonumber(enemyScale), direction = tonumber(enemyDirection)}

	    local enemyAvatar = QUIWidgetActorActivityDisplay.new(self._newEnemyTipsConfig.enemy_id, {})
	    local actor = enemyAvatar:getActor()
	    if actor then
	        actor:getSkeletonView():setSkeletonScaleX(-enemyList.scale * enemyList.direction)
	        actor:getSkeletonView():setSkeletonScaleY(enemyList.scale)
	    end
	    local posList = string.split(enemyList, ",")
	    enemyAvatar:setPosition(tonumber(posList[1]) or 0, tonumber(posList[2]) or 0)
	    self._ccbOwner.node_avart:addChild(enemyAvatar)

		self._ccbOwner.sp_skillShow:setPositionX(117)
	end
end

function QUIDialogSoulTowerMonsterIntroduce:_showSkill()
    if not self._newEnemyTipsConfig or not self._newEnemyTipsConfig.skill_desc then return end
    self._spPathList = string.split(self._newEnemyTipsConfig.skill_desc, ";")
    self:_updateSkillSpShow()
end

function QUIDialogSoulTowerMonsterIntroduce:_updateSkillSpShow()
    if not self._spPathList or #self._spPathList == 0 then return end
    local frame = QSpriteFrameByPath(self._spPathList[1])
    if frame then
        self._ccbOwner.sp_skillShow:setDisplayFrame(frame)
    end
    
end
function QUIDialogSoulTowerMonsterIntroduce:_onTriggerLeft()
    app.sound:playSound("common_close")

    if self._tableCellIndex <= 1 then return end
    self._tableCellIndex = self._tableCellIndex - 1

    self:setTable(self._tableIndex,self._tableCellIndex)
end

function QUIDialogSoulTowerMonsterIntroduce:_onTriggerRight()
    app.sound:playSound("common_close")
    
    if self._tableCellIndex >= self._allIntroduceNum then return end
    self._tableCellIndex = self._tableCellIndex + 1
    self:setTable(self._tableIndex,self._tableCellIndex)
end

function QUIDialogSoulTowerMonsterIntroduce:_onSkillIntroduce1( )
	self:setTable(1)
end

function QUIDialogSoulTowerMonsterIntroduce:_onSkillIntroduce2( )
	self:setTable(2)
end

function QUIDialogSoulTowerMonsterIntroduce:_onSkillIntroduce3( )
	self:setTable(3)
end

function QUIDialogSoulTowerMonsterIntroduce:_onSkillIntroduce4( )
	self:setTable(4)
end

function QUIDialogSoulTowerMonsterIntroduce:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSoulTowerMonsterIntroduce:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSoulTowerMonsterIntroduce:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogSoulTowerMonsterIntroduce
