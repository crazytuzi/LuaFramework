-- @Author: liaoxianbo
-- @Date:   2019-11-22 12:04:40
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-27 18:07:03
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogCollegeTrainBossIntroduce = class("QUIDialogCollegeTrainBossIntroduce", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetTimeMachineBossSkillInfo = import("..widgets.QUIWidgetTimeMachineBossSkillInfo")
local QListView = import("...views.QListView")
local QColorLabel = import("...utils.QColorLabel")

function QUIDialogCollegeTrainBossIntroduce:ctor(options)
	local ccbFile = "ccb/Dialog_Timemachine_skill.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogCollegeTrainBossIntroduce.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._chapterid = options.chapterId or {}
    self._introductionTable = {}
    self._ccbOwner.frame_tf_title:setString("Boss介绍")
    self._bossinfo = db:getCollegeTrainConfigById(self._chapterid)
    self:_init()
end

function QUIDialogCollegeTrainBossIntroduce:viewDidAppear()
	QUIDialogCollegeTrainBossIntroduce.super.viewDidAppear(self)

	self:addBackEvent(true)
end

function QUIDialogCollegeTrainBossIntroduce:viewWillDisappear()
  	QUIDialogCollegeTrainBossIntroduce.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogCollegeTrainBossIntroduce:_init()
	if next(self._bossinfo) == nil then return end

	self._skillIds = string.split(self._bossinfo.show_skill or "", ";") or {}
    self:_initPageSwipe()
end

function QUIDialogCollegeTrainBossIntroduce:_initPageSwipe()
    if not self._contentListView then
        local cfg = {
            renderItemCallBack = handler(self,self._reandFunHandler),
            ignoreCanDrag = true,
            isVertical = true,
            enableShadow = false,
            totalNumber = #self._skillIds,
        }  
        self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._contentListView:refreshData()
    end
end

function QUIDialogCollegeTrainBossIntroduce:_reandFunHandler( list, index, info )
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


function QUIDialogCollegeTrainBossIntroduce:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogCollegeTrainBossIntroduce:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogCollegeTrainBossIntroduce:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogCollegeTrainBossIntroduce
