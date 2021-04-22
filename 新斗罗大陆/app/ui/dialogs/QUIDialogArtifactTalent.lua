--
-- zxs
-- 武魂真身天赋大师
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogArtifactTalent = class("QUIDialogArtifactTalent", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QListView = import("...views.QListView")
local QUIWidgetArtifactTalent = import("..widgets.artifact.QUIWidgetArtifactTalent")

function QUIDialogArtifactTalent:ctor(options)
	local ccbFile = "ccb/Dialog_mount_talent.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogArtifactTalent.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._ccbOwner.frame_tf_title:setString("武魂真身大师")

	self._actorId = options.actorId
	self._artifactInfo = remote.herosUtil:getHeroByID(self._actorId).artifact
	self._talents = {}
	
    local character = db:getCharacterByID(self._actorId)
    local masterConfig = db:getArtifactMasterInfo(character.aptitude) or {}
    for i, v in pairs(masterConfig) do
    	if v.level > 0 then
    		table.insert(self._talents, v)
    	end
    end
	self:initListView()
end

function QUIDialogArtifactTalent:initListView()
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

function QUIDialogArtifactTalent:renderFunHandler(list, index, info)
    local isCacheNode = true
    local talent = self._talents[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetArtifactTalent.new()
        isCacheNode = false
    end

    info.item = item
	item:setTalentInfo(talent, talent.condition <= self._artifactInfo.artifactLevel)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogArtifactTalent:_onTriggerClose()
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogArtifactTalent:_backClickHandler()
	self:playEffectOut()
end

return QUIDialogArtifactTalent