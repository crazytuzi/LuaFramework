-- @Author: liaoxianbo
-- @Date:   2019-11-21 16:05:35
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-02-11 12:02:47
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetCollegeTrainChapterInfo = class("QUIWidgetCollegeTrainChapterInfo", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
-- local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QCollegeTrainArrangement = import("...arrangement.QCollegeTrainArrangement")
local QUIWidgetFcaAnimation = import(".actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetActorActivityDisplay = import(".actorDisplay.QUIWidgetActorActivityDisplay")
local QUIDialogCollegeTrainBBS = import("..dialogs.QUIDialogCollegeTrainBBS")
local QRichText = import("...utils.QRichText")

function QUIWidgetCollegeTrainChapterInfo:ctor(options)
	local ccbFile = "ccb/Widget_CollegeTrain_Chapterinfo.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerBoss", callback = handler(self, self._onTriggerBoss)},
		{ccbCallbackName = "onTriggerHotBB", callback = handler(self, self._onTriggerHotBB)},
		{ccbCallbackName = "onTriggerCheck", callback = handler(self, self._onTriggerCheck)},
    }
    QUIWidgetCollegeTrainChapterInfo.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._characterDisplay = {}
	q.setButtonEnableShadow(self._ccbOwner.button)
	q.setButtonEnableShadow(self._ccbOwner.button_hotBB)
	q.setButtonEnableShadow(self._ccbOwner.button_data)
	q.setButtonEnableShadow(self._ccbOwner.btn_checkRank)

end

function QUIWidgetCollegeTrainChapterInfo:onEnter()
end

function QUIWidgetCollegeTrainChapterInfo:onExit()
end

function QUIWidgetCollegeTrainChapterInfo:showPassTime()
	
	local isAllEnv = self._contentInfo.isAllEnv or false
	self._ccbOwner.sp_pass_spcial:setVisible(not isAllEnv)
	self._ccbOwner.sp_pass_spcial_all:setVisible(isAllEnv)

	if self._contentInfo.firstUserPassTime then
		local severTime = tonumber(self._contentInfo.firstUserPassTime or 0) / 1000.0
		local passTime = string.format("%0.2f秒", severTime)
		-- self._ccbOwner.tf_fast_passTime:setString(q.timeToHourMinuteSecond(tonumber(self._contentInfo.firstUserPassTime or 0),true))

		self._ccbOwner.tf_fast_passTime:setString(passTime)
	else
		self._ccbOwner.tf_fast_passTime:setString("无")
	end

	if self._contentInfo.finsh then
		if self._contentInfo.myPassTime then
			local severTime = tonumber(self._contentInfo.myPassTime or 0) / 1000.0
			local myPassTime = string.format("%0.2f秒", severTime)
			-- self._ccbOwner.tf_my_passTime:setString(q.timeToHourMinuteSecond(tonumber(self._contentInfo.myPassTime or 0) ,true))
			self._ccbOwner.tf_my_passTime:setString(myPassTime)
		else
			self._ccbOwner.tf_my_passTime:setString("无")
		end
		self._ccbOwner.tf_my_passTime:setColor(COLORS.b)
	else
		self._ccbOwner.tf_my_passTime:setString("未通关")
		self._ccbOwner.tf_my_passTime:setColor(COLORS.N)
	end
end

function QUIWidgetCollegeTrainChapterInfo:updateInfo(info)
	if info == nil or next(info) == nil then return end

	self._contentInfo = info

	if self._contentInfo.type == 3 then
		self._ccbOwner.node_pass_time:setVisible(true)
		self._ccbOwner.sp_pass_spcial:setVisible(true)
		self._ccbOwner.sp_pass_normal:setVisible(false)		
		self:showPassTime()
	else
		self._ccbOwner.node_pass_time:setVisible(false)
		self._ccbOwner.sp_pass_spcial:setVisible(false)
		self._ccbOwner.sp_pass_normal:setVisible(true)
	end

	self._isUnlock = remote.collegetrain:checkChapterIdUnlock(self._contentInfo.id)

	if self._contentInfo.finsh then
		self._ccbOwner.sp_yilingqu:setVisible(true)
	else
		self._ccbOwner.sp_yilingqu:setVisible(false)
	end
	self._ccbOwner.tf_pass_desc:setString(self._contentInfo.condition or "")

	self._ccbOwner.tf_chapterName:setString(self._contentInfo.btnMapInfo.name or "")

	local dungeon = db:getMonstersById(info.btnMapInfo.monster_id)
	local displayId = nil
    if dungeon ~= nil then
        for i, monsterInfo in ipairs(dungeon or {}) do
            local character = db:getCharacterByID(app:getBattleRandomNpcID(info.btnMapInfo.monster_id, i, monsterInfo.npc_id))
            if character ~= nil then
            	displayId = character.display_id
            	break
            end
        end
    end

    self._characterDisplay = db:getCharacterDisplayByID(displayId)
    -- QPrintTable(self._characterDisplay)
    if self._characterDisplay ~= nil then
    	self._ccbOwner.node_avatar:removeAllChildren()
	    local animation = QUIWidgetActorActivityDisplay.new(displayId,{})
	    animation:setPositionY(-80)
	    animation:setScale(self._contentInfo.animationScale or 1)
	    self._ccbOwner.node_avatar:addChild(animation)

	    self._ccbOwner.tf_boss_name:setString(self._characterDisplay.name or "")
    end

    local awardsInfo = db:getluckyDrawById(info.reward)
    if awardsInfo then
    	self._ccbOwner.node_award:removeAllChildren()
    	local index = 1
    	for _,v in pairs(awardsInfo) do
    		local itemBox = QUIWidgetItemsBox.new()
    		itemBox:setPromptIsOpen(true)
			itemBox:setGoodsInfo(v.id , v.typeName, tonumber(v.count))
			self._ccbOwner.node_award:addChild(itemBox)
			itemBox:setPositionX(90*(index-1))
			index = index + 1
    	end
    	self._ccbOwner.sp_yilingqu:setPositionX(90*(index-2)+ 45 + self._ccbOwner.node_award:getPositionX())
    end


    if self._isUnlock then
    	makeNodeFromGrayToNormal(self._ccbOwner.activity1)
    	makeNodeFromGrayToNormal(self._ccbOwner.node_avatar)
    	self._ccbOwner.tf_btnoktext:enableOutline()
    	self._ccbOwner.node_showAward:setVisible(true)
    	self._ccbOwner.node_lock_tips:setVisible(false)
    else
    	makeNodeFromNormalToGray(self._ccbOwner.activity1)
    	makeNodeFromNormalToGray(self._ccbOwner.node_avatar)
    	self._ccbOwner.tf_btnoktext:disableOutline()
    	self._ccbOwner.node_showAward:setVisible(false)
    	self._ccbOwner.node_lock_tips:setVisible(true)
    	local unlockName = remote.collegetrain:getChapterNameById(self._contentInfo.id)
	    local unlockTips = string.format("##j通关##w%s##j后开启",unlockName)
	    self._unlockTipes = string.format("通关%s后开启",unlockName)
	    if not self._richText then
		    self._richText = QRichText.new(unlockTips, 400, {stringType = 1, defaultColor = COLORS.j})
		    self._richText:setAnchorPoint(ccp(0.5, 0.5))
		    self._ccbOwner.node_lock_tips:addChild(self._richText)  
		else
			self._richText:setString(unlockTips)
		end  	
    end
end

function QUIWidgetCollegeTrainChapterInfo:_onTriggerConfirm()
	local chapterId = self._contentInfo.id or 0
	if chapterId == nil or chapterId == 0 then
		app.tip:floatTip("魂师大人，请选择挑战关卡！")
		return
	end
	if not self._isUnlock then
		app.tip:floatTip(self._unlockTipes)
		return		
	end

	local allHeroList = remote.collegetrain:getHeroListInfoById(chapterId)
	local allSpritList = remote.collegetrain:getSpritListById(chapterId)
	remote.collegetrain:setChooseChapterId(chapterId)
    local dungeonArrangement = QCollegeTrainArrangement.new({chapterId = chapterId,heroList = allHeroList,chapterId = chapterId,spritList = allSpritList,teamKey = "colleget_team"})
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogCollegeTrainTeamArrangement",
        options = {arrangement = dungeonArrangement}})    

end

function QUIWidgetCollegeTrainChapterInfo:_onTriggerBoss()
	if not self._isUnlock then
		return
	end
	if next(self._characterDisplay) == nil then return end
	local chapterId = self._contentInfo.id or 0
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogCollegeTrainBossIntroduce",
        options = {chapterId = chapterId}})    
end

function QUIWidgetCollegeTrainChapterInfo:_onTriggerHotBB()
	if not self._isUnlock then
		return
	end
	local chapterId = self._contentInfo.id or 0
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogCollegeTrainBBS",
        options = {chapterId = chapterId,tab = QUIDialogCollegeTrainBBS.HOT_COMMENT}})	
end

function QUIWidgetCollegeTrainChapterInfo:_onTriggerCheck( )
	-- if not self._contentInfo.firstUserNickname then
	-- 	return
	-- end
	app:getNavigationManager():pushViewController(app.middleLayer,{uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogCollegeTrainPassTimeTop10",
		options = {selectInfo = self._contentInfo }})
end

function QUIWidgetCollegeTrainChapterInfo:getContentSize()
end

return QUIWidgetCollegeTrainChapterInfo
