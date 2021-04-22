local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogArifactSkillProp = class("QUIDialogArifactSkillProp", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QActorProp = import("...models.QActorProp")
local QScrollContain = import("..QScrollContain")

function QUIDialogArifactSkillProp:ctor(options)
	local ccbFile = "ccb/Dialog_artifact_buff.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", 				callback = handler(self, self._onTriggerClose)},
		-- {ccbCallbackName = "onTriggerLearn", 				callback = handler(self, self._onTriggerLearn)},
		-- {ccbCallbackName = "onTriggerClick2", 				callback = handler(self, self._onTriggerClickWear)},
		-- {ccbCallbackName = "onTriggerClickShop", 			callback = handler(self, self._onTriggerLink)},
	}
	QUIDialogArifactSkillProp.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._skillList = options.skillList
	self._actorId = options.actorId
end

function QUIDialogArifactSkillProp:viewDidAppear()
    QUIDialogArifactSkillProp.super.viewDidAppear(self)
    self:initScrollView()
    self:showProp()
end

function QUIDialogArifactSkillProp:viewWillDisappear()
    QUIDialogArifactSkillProp.super.viewWillDisappear(self)
    if self._scrollContain ~= nil then
    	self._scrollContain:disappear()
    	self._scrollContain = nil
    end
end

function QUIDialogArifactSkillProp:initScrollView()
	self._scrollContain = QScrollContain.new({sheet = self._ccbOwner.sheet, sheet_layout = self._ccbOwner.sheet_layout, direction = QScrollContain.directionY , endRate = 0.1})
	self._ccbOwner.node_prop:retain()
	self._ccbOwner.node_prop:removeFromParent()
	self._scrollContain:addChild(self._ccbOwner.node_prop)
	self._ccbOwner.node_prop:release()
	local size = self._scrollContain:getContentSize()
	size.height = 0
    self._scrollContain:setContentSize(size.width, size.height)
end

function QUIDialogArifactSkillProp:showProp()
	if #self._skillList > 0 then
		self._ccbOwner.node_no:setVisible(false)
		self._ccbOwner.node_prop:setVisible(true)
    	local skillsProp = {}
	    for _,artifactSkill in ipairs(self._skillList) do
	    	local skillData = QStaticDatabase:sharedDatabase():getSkillDataByIdAndLevel(artifactSkill.skillId, artifactSkill.skillLevel)
    		local count = 1
    		while true do
    			local key = skillData["addition_type_"..count]
    			local value = skillData["addition_value_"..count]
    			if key == nil then
    				break
    			end
    			if skillsProp[key] == nil then
    				skillsProp[key] = value
    			else
    				skillsProp[key] = skillsProp[key] + value
    			end
    			count = count + 1
    		end
	    end
	    local propContent = self._ccbOwner.node_prop
	    propContent:removeAllChildren()
	    local posX = {-179, -87, 9.0, 102.0}
	    local posY = -30
	    local gapY = -35
	    local index = 1
		for _,v in ipairs(QActorProp._uiFields) do
			if skillsProp[v.fieldName] ~= nil and skillsProp[v.fieldName] > 0 then
				local value = skillsProp[v.fieldName]
				if v.handlerFun ~= nil then
					value = v.handlerFun(value)
				end
			    local tf1 = CCLabelTTF:create(v.name, global.font_default, 22)
			    tf1:setAnchorPoint(ccp(0, 0.5))
			    tf1:setColor(ccc3(243, 222, 191))
			    tf1:setPositionY(posY + (math.ceil(index/2) - 1) * gapY)
		    	propContent:addChild(tf1)
			    local tf2 = CCLabelTTF:create("+"..value, global.font_default, 22)
			    tf2:setAnchorPoint(ccp(0, 0.5))
			    tf2:setColor(ccc3(254, 251, 0))
			    tf2:setPositionY(posY + (math.ceil(index/2) - 1) * gapY)
		    	propContent:addChild(tf2)
				if index%2 == 1 then
			    	tf1:setPositionX(posX[1])
			    	tf2:setPositionX(posX[2])
				else
			    	tf1:setPositionX(posX[3])
			    	tf2:setPositionX(posX[4])
				end
			    index = index + 1
			end
		end
		local size = self._scrollContain:getContentSize()
		size.height = math.abs(math.ceil(index/2) * gapY) + 10
	    self._scrollContain:setContentSize(size.width, size.height)
	else
		self._ccbOwner.node_no:setVisible(true)
		self._ccbOwner.node_prop:setVisible(false)
	end
end

function QUIDialogArifactSkillProp:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogArifactSkillProp:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:enableTouchSwallowTop()
	self:playEffectOut()
end

return QUIDialogArifactSkillProp