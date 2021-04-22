-- 
-- zxs
-- 武魂当前技能
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionDragonWarCurSkill = class("QUIDialogUnionDragonWarCurSkill", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetUnionDragonTrainSkillCell = import("..widgets.dragon.QUIWidgetUnionDragonTrainSkillCell")

function QUIDialogUnionDragonWarCurSkill:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_jinhua.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogUnionDragonWarCurSkill.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._dragonId = options.dragonId 		
	self._dragonLevel = options.dragonLevel or 1		
	if options.fighter then
		self._fighter = options.fighter
		self._dragonId = self._fighter.dragonId or 1
		self._dragonLevel = self._fighter.dragonLevel or 1
	end

	self:setTitleInfo()
	self:setSkillInfo()
end

function QUIDialogUnionDragonWarCurSkill:setTitleInfo()
	local dragonCofig = db:getUnionDragonConfigById(self._dragonId)
	local title = dragonCofig.dragon_name--.."LV."..self._dragonLevel
	self._ccbOwner.frame_tf_title:setString(title)
end

function QUIDialogUnionDragonWarCurSkill:setSkillInfo()
	local skillInfo = db:getUnionDragonSkillByIdAndLevel(self._dragonId, self._dragonLevel)
	local skillIds = string.split(tostring(skillInfo.dragon_skill), ";")

	self._skills = {}
	for i, skillId in pairs(skillIds) do
		if skillId then
			local info = {}
			info.skill_id = skillId
			table.insert(self._skills, info)
		end
	end

	self:initListView()
end

function QUIDialogUnionDragonWarCurSkill:initListView()
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

function QUIDialogUnionDragonWarCurSkill:renderFunHandler(list, index, info)
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

function QUIDialogUnionDragonWarCurSkill:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogUnionDragonWarCurSkill:_onTriggerClose()
	app.sound:playSound("common_close")
	self:playEffectOut()
end

return QUIDialogUnionDragonWarCurSkill