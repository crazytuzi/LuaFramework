-- @Author: zhouxiaoshu
-- @Date:   2019-06-18 10:42:49
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-06 12:15:06

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulSpiritCombinationClient = class("QUIWidgetSoulSpiritCombinationClient", QUIWidget)

local QUIWidgetSoulSpiritSmallCard = import(".QUIWidgetSoulSpiritSmallCard")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

 QUIWidgetSoulSpiritCombinationClient.EVENT_CLICK_CARD = "EVENT_CLICK_CARD"
 QUIWidgetSoulSpiritCombinationClient.EVENT_CLICK_VISIT = "EVENT_CLICK_VISIT"
 QUIWidgetSoulSpiritCombinationClient.EVENT_CLICK_UPGRADE = "EVENT_CLICK_UPGRADE"

function QUIWidgetSoulSpiritCombinationClient:ctor(options)
	local ccbFile = "ccb/Widget_SoulSpirit_tujian_11.ccbi"
	local callBacks = {
	}
	QUIWidgetSoulSpiritCombinationClient.super.ctor(self, ccbFile, callBacks, options)
	
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

  	self._cardClient = {}
end

function QUIWidgetSoulSpiritCombinationClient:setInfo(conditionInfo)
	local grade = conditionInfo.grade
	if grade == 0 then
		grade = 1
	end
	self._maxgrade = #conditionInfo.combinationInfo or 5
	local combination = conditionInfo.combinationInfo[grade]
	local isActive = conditionInfo.grade > 0
	self._soulSpiritIds = conditionInfo.soulSpiritIds
	self._combinationId = conditionInfo.id
	self._grade = conditionInfo.grade

	--set condition card
	for i = 1, 2 do
		if self._cardClient[i] == nil then
			self._cardClient[i] = QUIWidgetSoulSpiritSmallCard.new()
			self._ccbOwner["node_card"..i]:addChild(self._cardClient[i])
		end
		local soulSpiritId = self._soulSpiritIds[i]
		if db:checkHeroShields(soulSpiritId,SHIELDS_TYPE.SOUL_SPIRIT) then
			soulSpiritId = nil
		end
		self._cardClient[i]:setCardInfo(soulSpiritId, self._soulSpiritIds[1])
	end
	self:_updateCardPosition(#self._soulSpiritIds , combination.condition_num)
	--set name and prop
	local nameStr = combination.name
	if self._grade > 0 then
		nameStr = string.format("%sLV.%d", combination.name, self._grade)
	end
	self._ccbOwner.frame_tf_title:setString(nameStr)
	local prop = conditionInfo.prop
	table.sort( prop, function(a, b)
		if a.isPercent ~= b.isPercent then
			return a.isPercent == true
		else
			return false
		end
	end )
	for i = 1, 4 do
		if prop[i] ~= nil then
			local buffName = string.gsub(prop[i].name, "玩家对战", "PVP")
			local  str = ""
			if prop[i].isPercent then
				str = buffName.."+"..(prop[i].value * 100).."%"
			else
				str = buffName.."+"..prop[i].value
			end
			self._ccbOwner["tf_prop_"..i]:setString(str)
			if self._ccbOwner["tf_prop_"..i]:getContentSize().width > 215 then
				self._ccbOwner["tf_prop_"..i]:setFontSize(20)
			else
				self._ccbOwner["tf_prop_"..i]:setFontSize(20)
			end
		else
			self._ccbOwner["tf_prop_"..i]:setString("")
		end
		if isActive then
			self._ccbOwner["tf_prop_"..i]:setColor(GAME_COLOR_LIGHT.normal)
		else
			self._ccbOwner["tf_prop_"..i]:setColor(GAME_COLOR_LIGHT.notactive)
		end
	end

	if isActive then
		self._ccbOwner.node_upgrade:setVisible(true)
		self._ccbOwner.node_active:setVisible(false)
		self._ccbOwner.btn_upgrade:setVisible(self._grade ~= self._maxgrade)
		self._ccbOwner.btn_top:setVisible(self._grade == self._maxgrade)
	else
		self._ccbOwner.node_upgrade:setVisible(false)
		self._ccbOwner.node_active:setVisible(true)
	end

	self._canUpgrade = false
	if isActive then
		self._canUpgrade = remote.soulSpirit:checkCombinationCanUpgrade(combination.id, self._grade+1)
	else
		self._canUpgrade = remote.soulSpirit:checkCombinationCanUpgrade(combination.id, 1)
	end
	self._ccbOwner.sp_red_tips:setVisible(self._canUpgrade)
	self._ccbOwner.node_effect:setVisible(self._canUpgrade)
end

function QUIWidgetSoulSpiritCombinationClient:_updateCardPosition(num_ , totalNum)

	if num_ == 1 and totalNum == 1 then
		self._ccbOwner.node_card2:setVisible(false)
		self._ccbOwner.btn_right:setVisible(false)
		self._ccbOwner.node_card1:setPositionX(255)
		self._ccbOwner.btn_left:setPositionX(255)
	else
		self._ccbOwner.node_card2:setVisible(true)
		self._ccbOwner.btn_right:setVisible(true)
		self._ccbOwner.node_card1:setPositionX(142)
		self._ccbOwner.btn_left:setPositionX(135)		
	end
end


function QUIWidgetSoulSpiritCombinationClient:_onTriggerClickLeft()
	if not self._soulSpiritIds[1] then return end
	local soulSpiritId = self._soulSpiritIds[1]
	if db:checkHeroShields(soulSpiritId,SHIELDS_TYPE.SOUL_SPIRIT) then return end

	self:dispatchEvent({name = QUIWidgetSoulSpiritCombinationClient.EVENT_CLICK_CARD, soulSpiritId = self._soulSpiritIds[1]})
end

function QUIWidgetSoulSpiritCombinationClient:_onTriggerClickRight()
	if not self._soulSpiritIds[2] then return end
	local soulSpiritId = self._soulSpiritIds[2]
	if db:checkHeroShields(soulSpiritId,SHIELDS_TYPE.SOUL_SPIRIT) then return end	
	self:dispatchEvent({name = QUIWidgetSoulSpiritCombinationClient.EVENT_CLICK_CARD, soulSpiritId = self._soulSpiritIds[2]})
end

function QUIWidgetSoulSpiritCombinationClient:_onTriggerClickVisit()
	self:dispatchEvent({name = QUIWidgetSoulSpiritCombinationClient.EVENT_CLICK_VISIT, combinationId = self._combinationId, grade = self._grade})
end

function QUIWidgetSoulSpiritCombinationClient:_onTriggerClickTop()
end

function QUIWidgetSoulSpiritCombinationClient:_onTriggerClickActive()
	if not self._canUpgrade then
    	app.tip:floatTip("魂灵未获得，无法激活该图鉴")
		return
	end
	self:dispatchEvent({name = QUIWidgetSoulSpiritCombinationClient.EVENT_CLICK_UPGRADE, combinationId = self._combinationId, grade = self._grade})
end

function QUIWidgetSoulSpiritCombinationClient:_onTriggerClickUpgrade()
	if self._grade == self._maxgrade then
		app.tip:floatTip("图鉴等级已达上限")
		return
	end	
	if not self._canUpgrade then
    	app.tip:floatTip("魂灵星级不足")
		return
	end
	self:dispatchEvent({name = QUIWidgetSoulSpiritCombinationClient.EVENT_CLICK_UPGRADE, combinationId = self._combinationId, grade = self._grade})
end

function QUIWidgetSoulSpiritCombinationClient:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	return CCSize(size.width, size.height)
end

return QUIWidgetSoulSpiritCombinationClient