-- @Author: liaoxianbo
-- @Date:   2019-12-24 14:56:38
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-24 15:58:16
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGodarmSkillView = class("QUIDialogGodarmSkillView", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetGodarmSkillView = import("..widgets.QUIWidgetGodarmSkillView")

function QUIDialogGodarmSkillView:ctor(options)
	local ccbFile = "ccb/Dialog_Godarm_skill.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogGodarmSkillView.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._godarmId = options.godarmId
	self._isMockBattle = options.isMockbattle or false

	local godarmInfo = remote.godarm:getGodarmById(self._godarmId)
	if godarmInfo == nil or next(godarmInfo) == nil then
		godarmInfo = {godarmId = self._godarmId, grade = -1}
	end

	if self._isMockBattle then
		godarmInfo = remote.mockbattle:getCardInfoByIndex(options.id or 0)
    	if not godarmInfo then
        	godarmInfo = remote.godarm:getGodarmById(self._godarmId)
    	end
	end

	self._curGrade = godarmInfo.grade
	
	self._ccbOwner.frame_tf_title:setString("神器效果")
	self._grades = db:getGradeByHeroId(self._godarmId) or {}
	self:initListView()
end

function QUIDialogGodarmSkillView:viewDidAppear()
	QUIDialogGodarmSkillView.super.viewDidAppear(self)

	self:addBackEvent(true)
end

function QUIDialogGodarmSkillView:viewWillDisappear()
  	QUIDialogGodarmSkillView.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogGodarmSkillView:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        totalNumber = #self._grades,
	        enableShadow = false,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = #self._grades})
	end
end

function QUIDialogGodarmSkillView:renderFunHandler(list, index, info)
    local isCacheNode = true
    local grade = self._grades[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetGodarmSkillView.new()
        isCacheNode = false
    end
    info.item = item
	item:setGradeInfo(grade, grade.grade_level <= self._curGrade)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogGodarmSkillView:_backClickHandler()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogGodarmSkillView:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end	
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogGodarmSkillView:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogGodarmSkillView
