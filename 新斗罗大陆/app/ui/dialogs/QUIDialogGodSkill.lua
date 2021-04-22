--
-- zxs
-- 真身特技
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGodSkill = class("QUIDialogGodSkill", QUIDialog)
local QListView = import("...views.QListView")
local QUIWidgetGodSkillCell = import("..widgets.QUIWidgetGodSkillCell")

function QUIDialogGodSkill:ctor(options)
	local ccbFile = "ccb/Dialog_mount_talent.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogGodSkill.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._ccbOwner.frame_tf_title:setString("神技效果")
	
	self._actorId = options.actorId
	
	local godSkillInfo = db:getGodSkillById(self._actorId)
	self._skills = {}
    if godSkillInfo ~= nil then
    	local hasGradeSkill = {} -- 同一个grade的技能，只记录一次（针对ss+）
		for index, skillConfig in pairs(godSkillInfo) do
			if not hasGradeSkill[skillConfig.grade] then
				hasGradeSkill[skillConfig.grade] = true
				local skillTbl = string.split(skillConfig.skill_id, ";")
				local skillId = tonumber(skillTbl[1])
				local skillInfo = db:getSkillByID(skillId)
				local skill = {}
				skill.skill_id = skillId
				skill.real_level = skillConfig.level
				skill.show_level = skillConfig.grade
				table.insert(self._skills, skill)
			end
		end
    end

	self:initListView()
end

function QUIDialogGodSkill:initListView()
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

function QUIDialogGodSkill:renderFunHandler(list, index, info)
    local isCacheNode = true
    local skill = self._skills[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetGodSkillCell.new()
        isCacheNode = false
    end
    info.item = item
	item:setInfo(skill, self._actorId)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogGodSkill:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogGodSkill:_backClickHandler()
	self:playEffectOut()
end

return QUIDialogGodSkill