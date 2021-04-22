local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMountTalent = class("QUIDialogMountTalent", QUIDialog)
local QListView = import("...views.QListView")
local QUIWidgetMountSkillAndTalent = import("..widgets.mount.QUIWidgetMountSkillAndTalent")

function QUIDialogMountTalent:ctor(options) 
	local ccbFile = "ccb/Dialog_mount_talent.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogMountTalent.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true
	-- if options.actorId then
	-- 	self._actorId = options.actorId
	-- 	self._mountInfo = remote.herosUtil:getHeroByID(self._actorId).zuoqi
	-- elseif options.mountInfo then
	-- 	self._mountInfo = options.mountInfo
	-- end

 --    local mountConfig = db:getCharacterByID(self._mountInfo.zuoqiId)
    

	-- local dbTalents = db:getMountMasterInfo(mountConfig.aptitude) or {}
	-- for i,v in ipairs(dbTalents) do
	-- 	if v.level > 0 then
	-- 		table.insert(self._talents,v)
	-- 	end
	-- end
	self._talents = options.talents or {}
	self._compareLevel = options.compareLevel or 0
	self._titile = options.title or "暗器秘技"
	self._ccbOwner.frame_tf_title:setString(self._titile)
	
	self:initListView()
end

function QUIDialogMountTalent:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        totalNumber = #self._talents,
	        enableShadow = false,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = #self._talents})
	end
end

function QUIDialogMountTalent:renderFunHandler(list, index, info)
    local isCacheNode = true
    local talent = self._talents[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetMountSkillAndTalent.new()
        isCacheNode = false
    end

    info.item = item
	item:setTalentInfo(talent, talent.condition <= self._compareLevel)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogMountTalent:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMountTalent:_backClickHandler()
	self:playEffectOut()
end

return QUIDialogMountTalent