-- @Author: xurui
-- @Date:   2017-04-10 10:33:59
-- @Last Modified by:   xurui
-- @Last Modified time: 2018-09-25 11:06:03
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetSparPromptSuitClient = class("QUIWidgetSparPromptSuitClient", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QColorLabel = import("....utils.QColorLabel")
local QRichText = import("....utils.QRichText")

function QUIWidgetSparPromptSuitClient:ctor(options)
	local ccbFile = "ccb/Widget_spar_tips.ccbi"
	local callBack = {
		-- {ccbCallbackName = "", callback = handler(self, self._)},
	}
	QUIWidgetSparPromptSuitClient.super.ctor(self, ccbFile, callBack, options)
	self._title2PosY =self._ccbOwner.tf_skill_name2:getPositionY()
	self._desc2PosY = self._ccbOwner.tf_skill_desc2:getPositionY()
	self._offside = 0
	self._offsideY = self._ccbOwner.tf_skill_desc1:getPositionY() - self._ccbOwner.tf_skill_desc2:getPositionY()
end

function QUIWidgetSparPromptSuitClient:onEnter()
end

function QUIWidgetSparPromptSuitClient:onExit()
end

function QUIWidgetSparPromptSuitClient:setSuitInfo(suitInfo)
	if suitInfo == nil then return end

	self._ccbOwner.tf_suit_name:setString(suitInfo.suit_name or "")

	local itemConfig1 = QStaticDatabase:sharedDatabase():getItemByID(suitInfo.colour_ls)
	local itemConfig2 = QStaticDatabase:sharedDatabase():getItemByID(suitInfo.colour_ys)

	local gardeName, level = remote.herosUtil:getGradeNameByGradeLevel(suitInfo.skill_level)
	local name1 = remote.spar:removeSparNameSpecialStr(itemConfig1.name)
	local name2 = remote.spar:removeSparNameSpecialStr(itemConfig2.name)
	name1 = string.gsub(name1, "海神八翼", "海神")
	name2 = string.gsub(name2, "海神八翼", "海神")
	self._ccbOwner.tf_suit_condition:setString(string.format("同时装备%s和%s，且星级均达到%s%s可激活", name1, name2, level, gardeName))


	local skillSzId , skillYzId = remote.spar:getSparSuitSkillShowIds(suitInfo)
	local skillConfig1 = QStaticDatabase:sharedDatabase():getSkillByID(skillSzId)
	local skillConfig2 = QStaticDatabase:sharedDatabase():getSkillByID(skillYzId)

    local skillDesc1 = QStaticDatabase:sharedDatabase():getSkillDataByIdAndLevel(skillSzId, suitInfo.skill_level)
	local skillDesc2 = QStaticDatabase:sharedDatabase():getSkillDataByIdAndLevel(skillYzId, suitInfo.skill_level)



	local level = remote.spar.SKILL_LEVEL[suitInfo.skill_level] or ""
	self._ccbOwner.tf_skill_name1:setString("【"..skillConfig1.name..level.."】")
	self._ccbOwner.tf_skill_name2:setString("【"..skillConfig2.name..level.."】")

	-- self._ccbOwner.tf_skill_desc1:setString(QColorLabel.removeColorSign(skillDesc1.description_1 or ""))
	-- self._ccbOwner.tf_skill_desc2:setString(QColorLabel.removeColorSign(skillDesc2.description_1 or ""))

	self._ccbOwner.tf_skill_desc1:setVisible(false)
	self._ccbOwner.tf_skill_desc2:setVisible(false)
	local descColor = ccc3(251, 212, 170)
	self._offside = 0
	if skillDesc1 then
		local width_s = self._ccbOwner.tf_skill_desc1:getContentSize().width
		local  str = QColorLabel.removeColorSign(skillDesc1.description_1 or "")
		str = q.getSkillDescByLimitNum(str or "" ,32)
		if self._richText1 == nil then
			self._richText1 = QRichText.new({},width_s)
			self._richText1:setAnchorPoint(ccp(0, 1))
			self._richText1:setPositionX( self._ccbOwner.tf_skill_desc1:getPositionX() )
			self._richText1:setPositionY(self._ccbOwner.tf_skill_desc1:getPositionY())
			self._ccbOwner.tf_skill_desc1:getParent():addChild(self._richText1)
		end
		self._richText1:setString({
                    {oType = "font", content = str, size = 20,color = descColor },
                },width_s)
    	local height1 = self._richText1:getContentSize().height
    	self._offside = height1 > self._offsideY and (height1 - self._offsideY) or 0
	end


	if skillDesc2 then

		local width_s = self._ccbOwner.tf_skill_desc2:getContentSize().width
		local  str = QColorLabel.removeColorSign(skillDesc2.description_1 or "")
		str = q.getSkillDescByLimitNum(str or "" ,32)
		if self._richText2 == nil then
			self._richText2 = QRichText.new({},width_s)
			self._richText2:setAnchorPoint(ccp(0, 1))
			self._richText2:setPositionX(self._ccbOwner.tf_skill_desc2:getPositionX() )
			self._ccbOwner.tf_skill_desc2:getParent():addChild(self._richText2)
		end
		self._richText2:setString({
                    {oType = "font", content = str, size = 20,color = descColor },
                })

		self._ccbOwner.tf_skill_name2:setPositionY(self._title2PosY - self._offside)
		self._richText2:setPositionY(self._desc2PosY - self._offside)
	end

end

function QUIWidgetSparPromptSuitClient:getContentSize()
    return cc.size(self._ccbOwner.ly_bg:getContentSize().width, self._ccbOwner.ly_bg:getContentSize().height + self._offside)
	-- return self._ccbOwner.ly_bg:getContentSize()
end


return QUIWidgetSparPromptSuitClient