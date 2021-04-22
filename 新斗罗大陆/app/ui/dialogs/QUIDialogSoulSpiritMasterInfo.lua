--
-- Kumo.Wang
-- 魂靈天赋展示
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritMasterInfo = class("QUIDialogSoulSpiritMasterInfo", QUIDialog)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QListView = import("...views.QListView")
local QUIWidgetSoulSpiritSkillInfo = import("..widgets.QUIWidgetSoulSpiritSkillInfo")

function QUIDialogSoulSpiritMasterInfo:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_SkillInfo.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSoulSpiritMasterInfo.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._ccbOwner.frame_tf_title:setString("天赋技能")

	if options then
		self._id = options.id
	end

    characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(self._id)
	if characterConfig then
		self._masterConfigs = {}
		local masterConfigs = remote.soulSpirit:getMasterConfigListByAptitude(characterConfig.aptitude)
		for _, config in ipairs(masterConfigs) do
			if config.condition > 0 then
				table.insert(self._masterConfigs, config)
			end
		end
		table.sort(self._masterConfigs, function(a, b)
				return a.condition < b.condition
			end)
		self:initListView()
	end
end

function QUIDialogSoulSpiritMasterInfo:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        enableShadow = false,
	        totalNumber = #self._masterConfigs,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:refreshData()
	end
end

function QUIDialogSoulSpiritMasterInfo:renderFunHandler(list, index, info)
    local isCacheNode = true
    local masterConfig = self._masterConfigs[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetSoulSpiritSkillInfo.new()
        isCacheNode = false
    end
    info.item = item
	item:setMasterInfo(self._id, masterConfig)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogSoulSpiritMasterInfo:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogSoulSpiritMasterInfo:_backClickHandler()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogSoulSpiritMasterInfo