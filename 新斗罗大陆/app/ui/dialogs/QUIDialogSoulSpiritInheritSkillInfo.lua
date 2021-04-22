--
-- 
-- 魂靈继承技能展示
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritInheritSkillInfo = class("QUIDialogSoulSpiritInheritSkillInfo", QUIDialog)

local QListView = import("...views.QListView")
local QUIWidgetSoulSpiritSkillInfo = import("..widgets.QUIWidgetSoulSpiritSkillInfo")

function QUIDialogSoulSpiritInheritSkillInfo:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_SkillInfo.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSoulSpiritInheritSkillInfo.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._ccbOwner.frame_tf_title:setString("传承技能效果")
	self._inheritLv = nil
	if options then
		self._id = options.id
		if options.isMockBattle then
			self._inheritLv = options.inheritLv 
		end
	end

	self._inheritConfigs = remote.soulSpirit:getSoulSpiritInheritAllConfigValue(self._id , 1)or {}
	self:initListView()
end

function QUIDialogSoulSpiritInheritSkillInfo:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        enableShadow = false,
	        totalNumber = #self._inheritConfigs,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:refreshData()
	end
end

function QUIDialogSoulSpiritInheritSkillInfo:renderFunHandler(list, index, info)
    local isCacheNode = true
    local inheritConfig = self._inheritConfigs[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetSoulSpiritSkillInfo.new()
        isCacheNode = false
    end
    info.item = item
	item:setInheritInfo(self._id, inheritConfig ,self._inheritLv)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogSoulSpiritInheritSkillInfo:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogSoulSpiritInheritSkillInfo:_backClickHandler()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogSoulSpiritInheritSkillInfo