local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogDragonTotemProp = class("QUIDialogDragonTotemProp", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")
local QScrollContain = import("...ui.QScrollContain")

function QUIDialogDragonTotemProp:ctor(options)
	local ccbFile = "ccb/Dialog_Weever_nature.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", 				callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogDragonTotemProp.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	--图腾的属性
	local level = remote.dragonTotem:getTotemLevelById(7)
	local config = remote.dragonTotem:getConfigByIdAndLevel(7, level)

	local offsetY = -50
	local offsetX = 0
	local titleColor = COLORS.b
	local nameColor = COLORS.a
	local valueColor = COLORS.c

	local tf = CCLabelTTF:create("武魂属性：", global.font_default, 20)
	tf:setAnchorPoint(0,0.5)
	tf:setColor(titleColor)
	tf:setPosition(ccp(20, offsetY))
	self._ccbOwner.node_prop:addChild(tf)
	offsetY = offsetY - 40

	--图腾技能
	local tf = CCLabelTTF:create(self:getSkillStr(config), global.font_default, 20)
	tf:setAnchorPoint(0,0.5)
	tf:setColor(valueColor)
	tf:setPosition(ccp(20, offsetY))
	self._ccbOwner.node_prop:addChild(tf)

	--图腾天赋属性
	local prop = remote.dragonTotem:countTotemTalentProp()
	if table.nums(prop) > 0 then
		offsetY = offsetY - 40
	end
	local index = 0
	offsetX = 20
	for _,v in ipairs(QActorProp._uiFields) do
		if prop[v.fieldName] ~= nil then
			if index > 0 and index%2 == 0 then
				offsetX = 20
				offsetY = offsetY - 35
			end
			local tf1 = CCLabelTTF:create(v.name.."：", global.font_default, 20)
			tf1:setAnchorPoint(0,0.5)
			tf1:setColor(nameColor)
			tf1:setPosition(ccp(offsetX, offsetY))
			self._ccbOwner.node_prop:addChild(tf1)
			offsetX = offsetX + 120

			local value = prop[v.fieldName]
			if prop.handlerFun then
				value = prop.handlerFun(value)
			end
			local tf2 = CCLabelTTF:create("+"..value, global.font_default, 20)
			tf2:setAnchorPoint(0,0.5)
			tf2:setColor(valueColor)
			tf2:setPosition(ccp(offsetX, offsetY))
			self._ccbOwner.node_prop:addChild(tf2)
			offsetX = offsetX + 245
			index = index + 1			
		end
	end
	offsetY = offsetY - 54

	-- 龙纹的属性
	local tf = CCLabelTTF:create("光环属性：", global.font_default, 20)
	tf:setAnchorPoint(0,0.5)
	tf:setColor(titleColor)
	tf:setPosition(ccp(20, offsetY))
	self._ccbOwner.node_prop:addChild(tf)
	offsetY = offsetY - 40


	local dragonProp = remote.dragonTotem:countAllDragonProp()
	local index = 0
	offsetX = 20
	for _,v in ipairs(QActorProp._uiFields) do
		if dragonProp[v.fieldName] ~= nil then
			if index > 0 and index%2 == 0 then
				offsetX = 20
				offsetY = offsetY - 35
			end
			local tf1 = CCLabelTTF:create(v.name.."：", global.font_default, 20)
			tf1:setAnchorPoint(0,0.5)
			tf1:setColor(nameColor)
			tf1:setPosition(ccp(offsetX, offsetY))
			self._ccbOwner.node_prop:addChild(tf1)
			offsetX = offsetX + 120

			local value = dragonProp[v.fieldName]
			if dragonProp.handlerFun then
				value = dragonProp.handlerFun(value)
			end
			local tf2 = CCLabelTTF:create("+"..value, global.font_default, 20)
			tf2:setAnchorPoint(0,0.5)
			tf2:setColor(valueColor)
			tf2:setPosition(ccp(offsetX, offsetY))
			self._ccbOwner.node_prop:addChild(tf2)
			offsetX = offsetX + 245
			index = index + 1			
		end
	end
	offsetY = offsetY - 54

	--规则
	-- local tf = CCLabelTTF:create("龙纹属性规则：", global.font_default, 20)
	-- tf:setAnchorPoint(0,0.5)
	-- tf:setColor(titleColor)
	-- tf:setPosition(ccp(20, offsetY))
	-- self._ccbOwner.node_prop:addChild(tf)
	-- offsetY = offsetY - 40
	self._ccbOwner.node_rule:setPositionY(offsetY)
	offsetY = offsetY - 50

	local tf = CCLabelTTF:create("1.武魂之力等级不能高于光环等级。所有光环等级强化到指定等级时，才可以进阶武魂之力。", global.font_default, 20)
	tf:setAnchorPoint(0,1)
	tf:setColor(nameColor)
	tf:setDimensions(CCSize(566, 0))
	tf:setHorizontalAlignment(kCCTextAlignmentLeft)
	tf:setPosition(ccp(20, offsetY))
	self._ccbOwner.node_prop:addChild(tf)
	local height = tf:getContentSize().height
	offsetY = offsetY - height - 15

	local tf = CCLabelTTF:create("2.全队属性对所有上阵魂师有效。", global.font_default, 20)
	tf:setAnchorPoint(0,0.5)
	tf:setColor(nameColor)
	-- tf:setDimensions(CCSize(620, 0))
	tf:setPosition(ccp(20, offsetY))
	self._ccbOwner.node_prop:addChild(tf)
	offsetY = offsetY - 30

    self._scroll = QScrollContain.new({sheet = self._ccbOwner.sheet, sheet_layout = self._ccbOwner.sheet_layout, direction = QScrollContain.directionY})
    self._scroll:setIsCheckAtMove(true)
    self._ccbOwner.node_prop:retain()
    self._ccbOwner.node_prop:setPosition(ccp(0,0))
    self._ccbOwner.node_prop:removeFromParent()
    self._scroll:addChild(self._ccbOwner.node_prop)
    self._ccbOwner.node_prop:release()
    self._scroll:setContentSize(0, math.abs(offsetY))
end

function QUIDialogDragonTotemProp:viewWillDisappear()
    QUIDialogDragonTotemProp.super.viewWillDisappear(self)
  
    if self._scroll ~= nil then
    	self._scroll:disappear()
    	self._scroll = nil
    end
end

function QUIDialogDragonTotemProp:getSkillStr(config)
	local skillId = config.skill_id
	if skillId ~= nil then
		local skillData = QStaticDatabase:sharedDatabase():getSkillDataByIdAndLevel(skillId, config.level)
		return skillData.description_1 or ""
	end
end

function QUIDialogDragonTotemProp:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogDragonTotemProp:_backClickHandler()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogDragonTotemProp