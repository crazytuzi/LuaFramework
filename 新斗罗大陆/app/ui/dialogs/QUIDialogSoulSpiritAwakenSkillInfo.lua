--
-- 
-- 魂靈觉醒技能展示
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritAwakenSkillInfo = class("QUIDialogSoulSpiritAwakenSkillInfo", QUIDialog)

local QListView = import("...views.QListView")
local QUIWidgetSoulSpiritSkillInfo = import("..widgets.QUIWidgetSoulSpiritSkillInfo")

function QUIDialogSoulSpiritAwakenSkillInfo:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_SkillInfo.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSoulSpiritAwakenSkillInfo.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._ccbOwner.frame_tf_title:setString("传承技能效果")
	self._grade = nil
	if options then
		self._id = options.id
		if options.isMockBattle then
			self._awakenLv = options.awakenLv 
		end
	end
    self._characterConfig = db:getCharacterByID(self._id)

    local quality = self._characterConfig.aptitude
	self._gradeConfigs = remote.soulSpirit:getSoulSpiritAwakenAllConfigValue(quality, 1)or {}
	self:initListView()
end

function QUIDialogSoulSpiritAwakenSkillInfo:initListView()
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

function QUIDialogSoulSpiritAwakenSkillInfo:renderFunHandler(list, index, info)
    local isCacheNode = true
    local gradeConfig = self._gradeConfigs[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetSoulSpiritSkillInfo.new()
        isCacheNode = false
    end
    info.item = item
	item:setAwakenInfo(self._id, gradeConfig ,self._awakenLv)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogSoulSpiritAwakenSkillInfo:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogSoulSpiritAwakenSkillInfo:_backClickHandler()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogSoulSpiritAwakenSkillInfo