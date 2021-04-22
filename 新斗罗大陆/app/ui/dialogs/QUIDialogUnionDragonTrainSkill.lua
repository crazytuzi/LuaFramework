-- 
-- zxs
-- 武魂进化
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionDragonTrainSkill = class("QUIDialogUnionDragonTrainSkill", QUIDialog)
local QListView = import("...views.QListView")
local QUIWidgetUnionDragonTrainSkillCell = import("..widgets.dragon.QUIWidgetUnionDragonTrainSkillCell")

function QUIDialogUnionDragonTrainSkill:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_jinhua.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogUnionDragonTrainSkill.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true
	self._ccbOwner.frame_tf_title:setString("宗门武魂进阶")
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._skills = {}
	self:setSkillInfo()
	self:initListView()
end

function QUIDialogUnionDragonTrainSkill:setSkillInfo()
	local dragonInfo = remote.dragon:getDragonInfo()
	local dragonLevel = dragonInfo.level or 1

	local dragonSkills = db:getUnionDragonSkillById(dragonInfo.dragonId)
	local newSkill
	for _, dragonSkill in pairs(dragonSkills) do
		local level = dragonSkill.dragon_level
		local lock = level > dragonLevel
		if dragonSkill.new_skill then
			newSkill = tostring(dragonSkill.new_skill)
		else
			newSkill = tostring(dragonSkill.dragon_skill)
		end
		local info = {}
		info.name = "【"..level.."级可进阶】"
		info.type = 2
		info.lock = lock
		table.insert(self._skills, info)

		local skillIds = string.split(newSkill, ";")
		for i, skillId in pairs(skillIds) do
			local info = {}
			info.skill_id = skillId
			info.type = 1
			info.lock = lock
			table.insert(self._skills, info)
		end
	end
end

function QUIDialogUnionDragonTrainSkill:initListView()
    if not self._listView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        totalNumber = #self._skills,
	        enableShadow = false,
	    }  
	    self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self._skills})
	end
end

function QUIDialogUnionDragonTrainSkill:renderFunHandler(list, index, info)
    local isCacheNode = true
    local skill = self._skills[index]
    local item = list:getItemFromCache()
    if not item then
    	item = QUIWidgetUnionDragonTrainSkillCell.new()
        isCacheNode = false
    end
    info.item = item
	item:setInfo(skill)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogUnionDragonTrainSkill:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogUnionDragonTrainSkill:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_close")
	self:playEffectOut()
end

return QUIDialogUnionDragonTrainSkill