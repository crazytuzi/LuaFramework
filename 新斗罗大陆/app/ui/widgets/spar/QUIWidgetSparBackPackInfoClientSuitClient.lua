-- @Author: xurui
-- @Date:   2017-04-05 18:51:43
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-01 16:16:47
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetSparBackPackInfoClientSuitClient = class("QUIWidgetSparBackPackInfoClientSuitClient", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetSparBox = import(".QUIWidgetSparBox")
local QColorLabel = import("....utils.QColorLabel")
local QQuickWay = import("....utils.QQuickWay")
local QRichText = import("....utils.QRichText")

QUIWidgetSparBackPackInfoClientSuitClient.EVENT_CLICK_BOX = "EVENT_CLICK_BOX"
QUIWidgetSparBackPackInfoClientSuitClient.EVENT_SKILL = "EVENT_SKILL"

function QUIWidgetSparBackPackInfoClientSuitClient:ctor(options)
	local ccbFile = "ccb/Widget_spar_packsack2.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerSkill", callback = handler(self, self._onTriggerSkill)},
	}
	QUIWidgetSparBackPackInfoClientSuitClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetSparBackPackInfoClientSuitClient:onEnter()
end

function QUIWidgetSparBackPackInfoClientSuitClient:onExit()
end

function QUIWidgetSparBackPackInfoClientSuitClient:setSuitInfo(suit)
	self._height = 230
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
	local skillSzId , skillYzId = remote.spar:getSparSuitSkillShowIds(suit)
	local skillConfig1 = QStaticDatabase:sharedDatabase():getSkillByID(skillSzId)
	local skillConfig2 = QStaticDatabase:sharedDatabase():getSkillByID(skillYzId)

    local skillDesc1 = QStaticDatabase:sharedDatabase():getSkillDataByIdAndLevel(skillSzId, suit.skill_level)
	local skillDesc2 = QStaticDatabase:sharedDatabase():getSkillDataByIdAndLevel(skillYzId, suit.skill_level)

	local level = remote.spar.SKILL_LEVEL[suit.skill_level] or ""
	local height = 0
	if skillDesc1 then
		if self._colorfulText1 == nil then
		    self._colorfulText1 = QRichText.new(nil, 320, {})
		    self._colorfulText1:setAnchorPoint(0, 1)
		    self._ccbOwner.node_skill_text:addChild(self._colorfulText1)
		end
		self._colorfulText1:setString({
	            	{oType = "font", content = "【"..(skillConfig1.name or "")..level.."】",size = 18,color = ccc3(87,47,0)},
	            	{oType = "font", content = QColorLabel.removeColorSign(skillDesc1.description_1 or ""), size = 18,color = ccc3(131, 88, 50)},
		    	})
	    height = self._colorfulText1:getCascadeBoundingBox().size.height + 20
	    -- self._colorfulText1:setPositionY(-height/2)
	end
	if skillDesc2 then
		if self._colorfulText2 == nil then
		    self._colorfulText2 = QRichText.new(nil, 320, {})
		    self._colorfulText2:setAnchorPoint(0, 1)
		    self._ccbOwner.node_skill_text:addChild(self._colorfulText2)
		end
		self._colorfulText2:setString({
	            	{oType = "font", content = "【"..(skillConfig2.name or "")..level.."】",size = 18,color = ccc3(87,47,0)},
	            	{oType = "font", content = QColorLabel.removeColorSign(skillDesc2.description_1 or ""), size = 18,color = ccc3(131, 88, 50)},
		    	})
	    self._colorfulText2:setPositionY(-height)
	    height = height + self._colorfulText2:getCascadeBoundingBox().size.height
	end

	self._ccbOwner.tf_suit_name:setString(suit.suit_name or "")

	local gardeName, level = remote.herosUtil:getGradeNameByGradeLevel(suit.star_num)
	self._ccbOwner.tf_active_condition:setString("两块外附魂骨均达到"..level..gardeName.."时激活")

	self._height = self._height + height

	self._suitInfo = suit
	self._minGrade = 0
end

function QUIWidgetSparBackPackInfoClientSuitClient:_onTriggerSkill(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_skill) == false then return end
	app.sound:playSound("common_common")

	self:dispatchEvent({name = QUIWidgetSparBackPackInfoClientSuitClient.EVENT_SKILL, suitInfo = self._suitInfo, minGrade = self._minGrade})
end

function QUIWidgetSparBackPackInfoClientSuitClient:getContentSize()
    return CCSize(400, self._height)
end

function QUIWidgetSparBackPackInfoClientSuitClient:onClickBox(event)
	if event.itemID == nil then return end
	local pieceInfo = QStaticDatabase:sharedDatabase():getItemCraftByItemId(event.itemID)

	self:dispatchEvent({name = QUIWidgetSparBackPackInfoClientSuitClient.EVENT_CLICK_BOX, itemId = pieceInfo.component_id_1})
end

return QUIWidgetSparBackPackInfoClientSuitClient