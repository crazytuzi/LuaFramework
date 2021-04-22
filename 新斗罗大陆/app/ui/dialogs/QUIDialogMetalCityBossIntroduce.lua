-- @Author: xurui
-- @Date:   2018-08-14 20:21:52
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-24 18:58:17
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMetalCityBossIntroduce = class("QUIDialogMetalCityBossIntroduce", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetTimeMachineBossSkillInfo = import("..widgets.QUIWidgetTimeMachineBossSkillInfo")
local QListView = import("...views.QListView")

function QUIDialogMetalCityBossIntroduce:ctor(options)
	local ccbFile = "ccb/Dialog_tower_gonglue.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerClick1", callback = handler(self, self._onTriggerClick1)},
		{ccbCallbackName = "onTriggerClick2", callback = handler(self, self._onTriggerClick2)},
    }
    QUIDialogMetalCityBossIntroduce.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.tf_title:setString("BOSS玩法")

    if options then
    	self._info = options.info
    	self._callBack = options.callBack
		self._trialNum = options.trialNum
    end
    if self._trialNum == nil then
		self._trialNum = 1
	end
	self._skillIds = {}

    self:initListView()

end

function QUIDialogMetalCityBossIntroduce:viewDidAppear()
	QUIDialogMetalCityBossIntroduce.super.viewDidAppear(self)

	self:setSkillInfo()
end

function QUIDialogMetalCityBossIntroduce:viewWillDisappear()
  	QUIDialogMetalCityBossIntroduce.super.viewWillDisappear(self)
end

function QUIDialogMetalCityBossIntroduce:setSkillInfo()
	QPrintTable(self._info)
	local trailInfo = remote.metalCity:getMetalCityMapConfigById(self._info["dungeon_id_"..self._trialNum])

    self._skillIds = string.split(trailInfo.show_skill or "", ";")
    self:setButtonStated()

    if q.isEmpty(self._skillIds) == false then
    	self:initListView()
	end
end

function QUIDialogMetalCityBossIntroduce:setButtonStated()
	local trailTab1 = self._trialNum == 1
	self._ccbOwner.btn_1:setHighlighted(trailTab1)
	self._ccbOwner.btn_1:setEnabled(not trailTab1)

	local trailTab2 = self._trialNum == 2
	self._ccbOwner.btn_2:setHighlighted(trailTab2)
	self._ccbOwner.btn_2:setEnabled(not trailTab2)
end

function QUIDialogMetalCityBossIntroduce:initListView()
    if not self._contentListView then
	    local cfg = {
            renderItemCallBack = handler(self, self._reandFunHandler),
            ignoreCanDrag = true,
            isVertical = true,
            enableShadow = false,
            totalNumber = #self._skillIds,
            contentOffsetX = -10,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = #self._skillIds})
	end
end

function QUIDialogMetalCityBossIntroduce:_reandFunHandler(list, index, info)
    local isCacheNode = true
    local skillId = self._skillIds[index]
    local item = list:getItemFromCache()
    if not item then
    	item = QUIWidgetTimeMachineBossSkillInfo.new()
        isCacheNode = false
    end

    item:init( skillId ) 
    info.item = item
    info.size = item:getContentSize()

	return isCacheNode
end

function QUIDialogMetalCityBossIntroduce:_onTriggerClick1()
	app.sound:playSound("common_small")
	if self._trialNum == 1 then return end

	self._trialNum = 1
	self:setSkillInfo()
end

function QUIDialogMetalCityBossIntroduce:_onTriggerClick2()
	app.sound:playSound("common_small")
	if self._trialNum == 2 then return end

	self._trialNum = 2
	self:setSkillInfo()
end

function QUIDialogMetalCityBossIntroduce:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMetalCityBossIntroduce:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMetalCityBossIntroduce:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogMetalCityBossIntroduce
