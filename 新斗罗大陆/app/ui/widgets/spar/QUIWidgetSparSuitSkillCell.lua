-- @Author: xurui
-- @Date:   2017-04-08 11:47:56
-- @Last Modified by:   xurui
-- @Last Modified time: 2018-09-18 10:48:31
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetSparSuitSkillCell = class("QUIWidgetSparSuitSkillCell", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QColorLabel = import("....utils.QColorLabel")
local QRichText = import("....utils.QRichText")

function QUIWidgetSparSuitSkillCell:ctor(options)
	local ccbFile = "ccb/Widget_spar_xiaoguo.ccbi"
	local callBack = {
		{ccbCallbackName = "", callback = handler(self, self._)},
	}
	QUIWidgetSparSuitSkillCell.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._offside = 0
	self._offsideY = self._ccbOwner.tf_skill_desc1:getPositionY() - self._ccbOwner.tf_skill_desc2:getPositionY()
end

function QUIWidgetSparSuitSkillCell:onEnter()
end

function QUIWidgetSparSuitSkillCell:onExit()
end

function QUIWidgetSparSuitSkillCell:setInfo(skillInfo, minGrade)
	local skillInfo = skillInfo
	local skillSzId , skillYzId = remote.spar:getSparSuitSkillShowIds(skillInfo)
	local skillConfig1 = QStaticDatabase:sharedDatabase():getSkillByID(skillSzId)
	local skillConfig2 = QStaticDatabase:sharedDatabase():getSkillByID(skillYzId)

    local skillDesc1 = QStaticDatabase:sharedDatabase():getSkillDataByIdAndLevel(skillSzId, skillInfo.skill_level)
	local skillDesc2 = QStaticDatabase:sharedDatabase():getSkillDataByIdAndLevel(skillYzId, skillInfo.skill_level)

	-- local desc1 = skillDesc1.description_1 or ""
	-- local desc2 = skillDesc2.description_1 or ""
	-- self._ccbOwner.tf_skill_desc1:setString(desc1)
	-- self._ccbOwner.tf_skill_desc2:setString(desc2)
	local gardeName, level = remote.herosUtil:getGradeNameByGradeLevel(skillInfo.star_num)
	self._ccbOwner.tf_skill_title:setString("【"..level..gardeName.."效果】")
	self._ccbOwner.tf_active_condition:setString(skillInfo.title or "")
	
	local titleColor = COLORS.k
	local descColor = ccc3(134, 85, 55)
	if skillInfo.unlock then
		self._ccbOwner.sp_mask1:setVisible(false)
		self._ccbOwner.sp_mask2:setVisible(false)
	else
		self._ccbOwner.sp_mask1:setVisible(true)
		self._ccbOwner.sp_mask2:setVisible(true)
		titleColor = COLORS.n
		descColor = COLORS.n
	end
	-- self._ccbOwner.tf_skill_desc1:setColor(descColor)
	-- self._ccbOwner.tf_skill_desc2:setColor(descColor)
	self._ccbOwner.tf_skill_title:setColor(titleColor)
	self._ccbOwner.tf_active_condition:setColor(descColor)


	self:setSkillIcon(self._ccbOwner.node_icon_1, skillConfig1.icon)
	self:setSkillIcon(self._ccbOwner.node_icon_2, skillConfig2.icon)

	self._ccbOwner.tf_skill_desc1:setVisible(false)
	self._ccbOwner.tf_skill_desc2:setVisible(false)

	self._offside = 0
	if skillDesc1 then
		local width_s = self._ccbOwner.tf_skill_desc1:getContentSize().width
		local  str = QColorLabel.removeColorSign(skillDesc1.description_1 or "")
		if self._richText1 == nil then
			self._richText1 = QRichText.new({},width_s)
			self._richText1:setAnchorPoint(ccp(0, 1))
			self._richText1:setPositionX(self._ccbOwner.tf_skill_desc1:getPositionX())
			self._richText1:setPositionY(self._ccbOwner.tf_skill_desc1:getPositionY())
			self._ccbOwner.tf_skill_desc1:getParent():addChild(self._richText1)
		end
		self._richText1:setString({
                    {oType = "font", content = str, size = 20,color = descColor },
                },width_s)
    	local height1 = self._richText1:getContentSize().height
    	self._offside = height1 > self._offsideY and (height1 - self._offsideY) or 0
    	self._offside = self._offside + 20
	end


	if skillDesc2 then

		local width_s = self._ccbOwner.tf_skill_desc2:getContentSize().width
		local  str = QColorLabel.removeColorSign(skillDesc2.description_1 or "")

		if self._richText2 == nil then
			self._richText2 = QRichText.new({},width_s)
			self._richText2:setAnchorPoint(ccp(0, 1))
			self._richText2:setPositionX(self._ccbOwner.tf_skill_desc2:getPositionX() )
			self._richText2:setPositionY(self._ccbOwner.tf_skill_desc2:getPositionY() )
			self._ccbOwner.tf_skill_desc2:getParent():addChild(self._richText2)
		end
		self._richText2:setString({
                    {oType = "font", content = str, size = 20,color = descColor },
                })

	end
	self._ccbOwner.tf_skill_desc2:getParent():setPositionY( - self._offside)
end

function QUIWidgetSparSuitSkillCell:setSkillIcon(node, iconPath)
	if iconPath == nil then return end

	node:removeAllChildren()
	local icon = CCSprite:create(iconPath)
	node:addChild(icon)
end

function QUIWidgetSparSuitSkillCell:getContentSize()
	return cc.size(self._ccbOwner.node_size:getContentSize().width, self._ccbOwner.node_size:getContentSize().height + self._offside)
	-- return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetSparSuitSkillCell