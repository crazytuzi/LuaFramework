--
-- Kumo.Wang
-- 魂靈出戰技能展示
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritSkillInfo = class("QUIDialogSoulSpiritSkillInfo", QUIDialog)

local QListView = import("...views.QListView")
local QUIWidgetSoulSpiritSkillInfo = import("..widgets.QUIWidgetSoulSpiritSkillInfo")

function QUIDialogSoulSpiritSkillInfo:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_SkillInfo.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSoulSpiritSkillInfo.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._ccbOwner.frame_tf_title:setString("魂灵技能效果")
	self._grade = nil
	if options then
		self._id = options.id
		if options.isMockBattle then
			self._grade = options.grade 
		end
	end

	self._gradeConfigs = db:getGradeByHeroId(self._id) or {}
	self:initListView()
end

function QUIDialogSoulSpiritSkillInfo:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        enableShadow = false,
	        totalNumber = #self._gradeConfigs,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:refreshData()
	end
end

function QUIDialogSoulSpiritSkillInfo:renderFunHandler(list, index, info)
    local isCacheNode = true
    local gradeConfig = self._gradeConfigs[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetSoulSpiritSkillInfo.new()
        isCacheNode = false
    end
    info.item = item
	item:setGradeInfo(self._id, gradeConfig ,self._grade)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogSoulSpiritSkillInfo:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogSoulSpiritSkillInfo:_backClickHandler()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogSoulSpiritSkillInfo