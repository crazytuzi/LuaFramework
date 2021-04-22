-- @Author: xurui
-- @Date:   2017-04-06 16:47:01
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-29 10:54:22
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetHeroSparDetailSuitClient = class("QUIWidgetHeroSparDetailSuitClient", QUIWidget)

local QUIWidgetSparBox = import(".QUIWidgetSparBox")
local QColorLabel = import("....utils.QColorLabel")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIViewController = import("...QUIViewController")
local QRichText = import("....utils.QRichText")

QUIWidgetHeroSparDetailSuitClient.EVENT_CLICK_BOX = "EVENT_CLICK_BOX"
QUIWidgetHeroSparDetailSuitClient.EVENT_SKILL = "EVENT_SKILL"

function QUIWidgetHeroSparDetailSuitClient:ctor(options)
	local ccbFile = "ccb/Widget_spar_info3.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerSkill", callback = handler(self, self._onTriggerSkill)},
	}
	QUIWidgetHeroSparDetailSuitClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._richText1 = nil
	self._richText2 = nil

	self._title2PosY =self._ccbOwner.tf_skill_name2:getPositionY()
	self._desc2PosY = self._ccbOwner.tf_skill_content2:getPositionY()
	self._offside = 0
	self._offsideY = self._ccbOwner.tf_skill_content1:getPositionY() - self._ccbOwner.tf_skill_content2:getPositionY()
end

function QUIWidgetHeroSparDetailSuitClient:onEnter()
end

function QUIWidgetHeroSparDetailSuitClient:onExit()
end


function QUIWidgetHeroSparDetailSuitClient:setSuitInfo(suit, minGrade, currentItemId1, currentItemId2)
	if self._sparItem1 == nil then
		self._sparItem1 = QUIWidgetSparBox.new()
		self._ccbOwner.node_spar_1:addChild(self._sparItem1)
		self._sparItem1:addEventListener(QUIWidgetSparBox.EVENT_CLICK, handler(self, self.onClickBox))
	end
	self._sparItem1:setGemstoneInfo({itemId = suit.colour_ls, grade = -1}, 1)


	if self._sparItem2 == nil then
		self._sparItem2 = QUIWidgetSparBox.new()
		self._ccbOwner.node_spar_2:addChild(self._sparItem2)
		self._sparItem2:addEventListener(QUIWidgetSparBox.EVENT_CLICK, handler(self, self.onClickBox))
	end
	self._sparItem2:setGemstoneInfo({itemId = suit.colour_ys, grade = -1}, 2)

	local titleColor = COLORS.k
	local descColor = ccc3(134, 85, 55)
	if suit.isActive == false or suit.isActive == nil then
		titleColor = COLORS.n
		descColor = COLORS.n
		if currentItemId1 ~= suit.colour_ls then
			self._sparItem1:setGrayState(true)
		end
		if currentItemId2 ~= suit.colour_ys then
			self._sparItem2:setGrayState(true)
		end
	end
	self._sparItem1:setNameColor(descColor)
	self._sparItem2:setNameColor(descColor)
	
	local skillSzId , skillYzId = remote.spar:getSparSuitSkillShowIds(suit)
	local skillConfig1 = QStaticDatabase:sharedDatabase():getSkillByID(skillSzId)
	local skillConfig2 = QStaticDatabase:sharedDatabase():getSkillByID(skillYzId)
    local skillDesc1 = QStaticDatabase:sharedDatabase():getSkillDataByIdAndLevel(skillSzId, suit.skill_level)
	local skillDesc2 = QStaticDatabase:sharedDatabase():getSkillDataByIdAndLevel(skillYzId, suit.skill_level)

	local level = remote.spar.SKILL_LEVEL[suit.skill_level] or ""
	self._ccbOwner.tf_skill_content1:setVisible(false)
	self._ccbOwner.tf_skill_content2:setVisible(false)

	self._offside = 0
	if skillDesc1 then
		self._ccbOwner.tf_skill_name1:setString("【"..skillConfig1.name..level.."】")
		local width_s = self._ccbOwner.tf_skill_content1:getContentSize().width
		local  str = QColorLabel.removeColorSign(skillDesc1.description_1 or "")
		if self._richText1 == nil then
			self._richText1 = QRichText.new({},width_s)
			self._richText1:setAnchorPoint(ccp(0, 1))
			self._richText1:setPositionX(-115)
			self._richText1:setPositionY(self._ccbOwner.tf_skill_content1:getPositionY())
			self._ccbOwner.tf_skill_content1:getParent():addChild(self._richText1)
		end
		self._richText1:setString({
                    {oType = "font", content = str, size = 20,color = descColor },
                },width_s)
    	-- self._ccbOwner.tf_skill_content1:setString(QColorLabel.removeColorSign(skillDesc1.description_1 or ""))
    	local height1 = self._richText1:getContentSize().height
    	self._offside = height1 > self._offsideY and (height1 - self._offsideY) or 0
    	print("self._offside 	:"..self._offside)
    	self._offside = self._offside + 20
	end



	if skillDesc2 then
		self._ccbOwner.tf_skill_name2:setString("【"..skillConfig2.name..level.."】")
    	-- self._ccbOwner.tf_skill_content2:setString(QColorLabel.removeColorSign(skillDesc2.description_1 or ""))

		local width_s = self._ccbOwner.tf_skill_content2:getContentSize().width
		local  str = QColorLabel.removeColorSign(skillDesc2.description_1 or "")

		if self._richText2 == nil then
			self._richText2 = QRichText.new({},width_s)
			self._richText2:setAnchorPoint(ccp(0, 1))
			self._richText2:setPositionX(-115)
			self._ccbOwner.tf_skill_content2:getParent():addChild(self._richText2)
		end
		self._richText2:setString({
                    {oType = "font", content = str, size = 20,color = descColor },
                })

		self._ccbOwner.tf_skill_name2:setPositionY(self._title2PosY - self._offside)
		self._richText2:setPositionY(self._desc2PosY - self._offside)
	end
	
   	self._ccbOwner.tf_skill_name1:setColor(titleColor)
   	self._ccbOwner.tf_skill_name2:setColor(titleColor)
   	-- self._ccbOwner.tf_skill_content1:setColor(descColor)
   	-- self._ccbOwner.tf_skill_content2:setColor(descColor)

	local gardeName, level = remote.herosUtil:getGradeNameByGradeLevel(suit.star_num)
	local itemConfig1 = QStaticDatabase:sharedDatabase():getItemByID(suit.colour_ls)
	local itemConfig2 = QStaticDatabase:sharedDatabase():getItemByID(suit.colour_ys)
	local name1 = remote.spar:removeSparNameSpecialStr(itemConfig1.name)
	local name2 = remote.spar:removeSparNameSpecialStr(itemConfig2.name)
	self._ccbOwner.tf_suit_condition:setString("同时装备"..name1.."和"..name2.."且均达到"..level..gardeName.."时激活")
	self._ccbOwner.tf_suit_condition:setColor(descColor)

	self._ccbOwner.tf_suit_title:setString(suit.suit_name)
	self._ccbOwner.tf_suit_title:setColor(titleColor)

	self._suitInfo = suit
	self._minGrade = minGrade
end

function QUIWidgetHeroSparDetailSuitClient:_onTriggerSkill(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_info) == false then return end
	app.sound:playSound("common_common")
	
	self:dispatchEvent({name = QUIWidgetHeroSparDetailSuitClient.EVENT_SKILL, suitInfo = self._suitInfo, minGrade = self._minGrade})
end

function QUIWidgetHeroSparDetailSuitClient:getContentSize()
    -- return self._ccbOwner.ly_bg:getContentSize()

    return cc.size(self._ccbOwner.ly_bg:getContentSize().width, self._ccbOwner.ly_bg:getContentSize().height + self._offside)
end

function QUIWidgetHeroSparDetailSuitClient:onClickBox(event)
	if event.itemID == nil then return end
	local pieceInfo = QStaticDatabase:sharedDatabase():getItemCraftByItemId(event.itemID)

	self:dispatchEvent({name = QUIWidgetHeroSparDetailSuitClient.EVENT_CLICK_BOX, itemId = pieceInfo.component_id_1})
end

return QUIWidgetHeroSparDetailSuitClient