--
-- zxs
-- 真身特技
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogArtifactSkill = class("QUIDialogArtifactSkill", QUIDialog)
local QListView = import("...views.QListView")
local QUIWidgetArtifactSkillCell = import("..widgets.artifact.QUIWidgetArtifactSkillCell")

function QUIDialogArtifactSkill:ctor(options)
	local ccbFile = "ccb/Dialog_mount_talent.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogArtifactSkill.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._ccbOwner.frame_tf_title:setString("真身天赋效果")
	
	local artifact = remote.herosUtil:getHeroByID(options.actorId).artifact or {}
	self._artifactSkills = {}
	for _, skillInfo in pairs(artifact.artifactSkillList or {}) do
		self._artifactSkills[skillInfo.skillId] = skillInfo
	end

	local artifactId = remote.artifact:getArtiactByActorId(options.actorId)
	self._skills = remote.artifact:getSkillByArtifactId(artifactId)

	self:initListView()
end

function QUIDialogArtifactSkill:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        totalNumber = #self._skills,
	        enableShadow = false,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = #self._skills})
	end
end

function QUIDialogArtifactSkill:renderFunHandler(list, index, info)
    local isCacheNode = true
    local skill = self._skills[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetArtifactSkillCell.new()
        isCacheNode = false
    end
    info.item = item
	item:setInfo(skill, self._artifactSkills, index)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogArtifactSkill:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogArtifactSkill:_backClickHandler()
	self:playEffectOut()
end

return QUIDialogArtifactSkill