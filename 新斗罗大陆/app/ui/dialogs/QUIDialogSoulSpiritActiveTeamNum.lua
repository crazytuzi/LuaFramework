-- @Author: liaoxianbo
-- @Date:   2020-03-01 18:48:56
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-12 14:23:48
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritActiveTeamNum = class("QUIDialogSoulSpiritActiveTeamNum", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QDungeonArrangement = import("...arrangement.QDungeonArrangement")
local QMetalCityArrangement = import("...arrangement.QMetalCityArrangement")

function QUIDialogSoulSpiritActiveTeamNum:ctor(options)
	local ccbFile = "ccb/Dialog_SoulFire_jihuo_teamNum.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
    }
    QUIDialogSoulSpiritActiveTeamNum.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	q.setButtonEnableShadow(self._ccbOwner.btn_go)

	self._soul_num_team = options.soul_num_team or 1
    self._callBack = options.callback
	self._successTip = options.successTip

    self._ccbOwner.tf_title:setString(self._soul_num_team.."小队玩法扩展魂灵位") 
    local str = string.format("在%d小队玩法中可以额外布置并上场\n一只魂灵，令你在战斗中所向披靡！",self._soul_num_team)
    self._ccbOwner.tf_txt:setString(str)   
end

function QUIDialogSoulSpiritActiveTeamNum:viewDidAppear()
	QUIDialogSoulSpiritActiveTeamNum.super.viewDidAppear(self)

	self:addBackEvent(false)
end

function QUIDialogSoulSpiritActiveTeamNum:viewWillDisappear()
  	QUIDialogSoulSpiritActiveTeamNum.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogSoulSpiritActiveTeamNum:_onTriggerGo()
	app.sound:playSound("common_small")
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	if self._soul_num_team == 2 then --2小队前往金属之城
	    -- remote.metalCity:openDialog()
  		local myInfoDict = remote.metalCity:getMetalCityMyInfo()
  		local lastChapter, lastFloor = remote.metalCity:getCurrentChapterNum()          		--当前通关的章节和层数
  		local chapterDataList = remote.metalCity:getMetalCityConfigByChapter(lastChapter)
		table.sort( chapterDataList, function(a, b)
				if a.num ~= b.num then
					return a.num < b.num
				else
					return false
				end
			end )
		local fightCount, canBuyCount = remote.metalCity:getMetalCityFightCount()
		if fightCount <= 0 then
			app.tip:floatTip("金属之城今日战斗次数已用完~")
			return false
		end
		if q.isEmpty(chapterDataList[lastFloor+1]) then
			app.tip:floatTip("金属之城已全部通关~")
			return
		end
		local config = remote.metalCity:getMetalCityConfigByFloor(chapterDataList[lastFloor+1].num)
		local metalCityArrangement1 = QMetalCityArrangement.new({info = chapterDataList[lastFloor+1], teamKey = remote.teamManager.METAL_CIRY_ATTACK_TEAM1})
		local metalCityArrangement2 = QMetalCityArrangement.new({info = chapterDataList[lastFloor+1], teamKey = remote.teamManager.METAL_CIRY_ATTACK_TEAM2})
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityTeamArrangement",
			options = {arrangement1 = metalCityArrangement1, arrangement2 = metalCityArrangement2, fighterInfo = config, widgetClass = "QUIWidgetMetalCityTeamBossInfo"}})	
	elseif self._soul_num_team == 3 then

		remote.metalAbyss:openDialog()
	else -- 前往副本
  		local dungeonInfo = remote.instance:getLastPassDungeon(DUNGEON_TYPE.NORMAL)
  		if dungeonInfo then
			local dungeonArrangement = QDungeonArrangement.new({dungeonId = dungeonInfo.dungeon_id})
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement", 
		     	options = {arrangement = dungeonArrangement}}) 
		end 

	end
end

function QUIDialogSoulSpiritActiveTeamNum:_backClickHandler()
	self:playEffectOut()
end
function QUIDialogSoulSpiritActiveTeamNum:viewAnimationOutHandler()
	local callback = self._callBack

	if self._isSelected then
        app.master:setMasterShowState(self._successTip)
    end

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogSoulSpiritActiveTeamNum
