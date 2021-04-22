-- @Author: xurui
-- @Date:   2016-08-23 11:10:59
-- @Last Modified by:   xurui
-- @Last Modified time: 2018-08-17 19:47:54
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTipsSkillInfo = class("QUIDialogTipsSkillInfo", QUIDialog)

local QUIWidgetSkillPrompt = import("..widgets.QUIWidgetSkillPrompt")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIDialogTipsSkillInfo:ctor(options)
	local ccbFile = nil
	local callBacks = {}
	QUIDialogTipsSkillInfo.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
	
	local skillId = options.skillId
	local slotLevel = options.slotLevel
	self.prompt = QUIWidgetSkillPrompt.new({skillId = skillId, slotLevel = slotLevel, params = options.params})
	self:getView():addChild(self.prompt)
	if options.isShort then
		self.prompt:setShortBg()
	end
end

function QUIDialogTipsSkillInfo:viewDidAppear()
	QUIDialogTipsSkillInfo.super.viewDidAppear(self)
end

function QUIDialogTipsSkillInfo:viewWillDisappear()
	QUIDialogTipsSkillInfo.super.viewWillDisappear(self)
end

function QUIDialogTipsSkillInfo:_backClickHandler()
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_METAL_CITY_SKILL_CLOSE})
	self:popSelf()
end

return QUIDialogTipsSkillInfo