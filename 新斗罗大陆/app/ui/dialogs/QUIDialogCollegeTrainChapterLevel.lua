-- @Author: liaoxianbo
-- @Date:   2019-11-20 20:07:20
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-23 18:28:23
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogCollegeTrainChapterLevel = class("QUIDialogCollegeTrainChapterLevel", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetCollegeTrainLevel = import("..widgets.QUIWidgetCollegeTrainLevel")

function QUIDialogCollegeTrainChapterLevel:ctor(options)
	local ccbFile = "ccb/Dialog_CollegeTrain_ChapterLevel.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogCollegeTrainChapterLevel.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = false
    
    CalculateUIBgSize(self._ccbOwner.sp_bg)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self:setChapterInfo()
end

function QUIDialogCollegeTrainChapterLevel:viewDidAppear()
	QUIDialogCollegeTrainChapterLevel.super.viewDidAppear(self)

	self:addBackEvent(true)
end

function QUIDialogCollegeTrainChapterLevel:viewWillDisappear()
  	QUIDialogCollegeTrainChapterLevel.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogCollegeTrainChapterLevel:setChapterInfo()
	self._chapterInfo = {}
	for i = 1, 3 do
		self._ccbOwner["chapter"..i]:removeAllChildren()
		self._chapterInfo[i] = QUIWidgetCollegeTrainLevel.new({chapterType = i})
		self._ccbOwner["chapter"..i]:addChild(self._chapterInfo[i])
		self._chapterInfo[i]:addEventListener(QUIWidgetCollegeTrainLevel.EVENT_CLICK_CHAPTER, handler(self, self._onClickEvnet))
	end
end

function QUIDialogCollegeTrainChapterLevel:_onClickEvnet(event)
	-- nzhang: http://jira.joybest.com.cn/browse/WOW-8990
	if event == nil then return end
	if self._shopClicked then
		return
	else
		self._shopClicked = true
	end
	remote.collegetrain:setSelectBtnIndex(nil)
    app.sound:playSound("common_small")
    local chapterType = event.chapterType
 	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogCollegeTrainChapterChoose",
 		options = {chapterType = chapterType}})
end

function QUIDialogCollegeTrainChapterLevel:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogCollegeTrainChapterLevel:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogCollegeTrainChapterLevel
