--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林事件
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilverMineOpportunity = class("QUIWidgetSilverMineOpportunity", QUIWidget)
local QColorLabel = import("...utils.QColorLabel")

function QUIWidgetSilverMineOpportunity:ctor(options)
	local ccbFile = "ccb/Widget_SilverMine_Opportunity.ccbi"
	local callBacks = {}
	QUIWidgetSilverMineOpportunity.super.ctor(self, ccbFile, callBacks, options)
    
    self._thing = options.thing
    self._wdith = options.width
    self._height = options.height

	self:_init()
end

function QUIWidgetSilverMineOpportunity:onEnter()

end

function QUIWidgetSilverMineOpportunity:onExit()

end

function QUIWidgetSilverMineOpportunity:getHeight()
	-- return self._actualHeight or 44
	return 44
end

function QUIWidgetSilverMineOpportunity:_init()
	if self._thing and table.nums(self._thing) > 0 then
		-- local h, m, s = remote.silverMine:formatSecTime( self._thing.miningSec )
		local thingConfig = remote.silverMine:getThingConfigById( self._thing.eventId )
		if not thingConfig then
			if self._thing.miningAward and self._thing.miningAward ~= "" then
				thingConfig = remote.silverMine:getThingConfigById( remote.silverMine:getRandomOpportunityId(true) )
			else
				thingConfig = remote.silverMine:getThingConfigById( remote.silverMine:getRandomOpportunityId(false) )
			end
		end
		local textStr = ""
		if thingConfig.group == 3 then
			local param = string.split(self._thing.miningAward, ";")
			textStr = "##n【"..param[1].."】##e"..thingConfig.things.."##n"..param[2]
		else
			local character = remote.silverMine:getActorById( self._thing.miningActorId )
			local name = "【"..character.name.."】"
			local thing = thingConfig.things
			local thingGroup = thingConfig.group
			local goodsName = ""
			local goodsCount = ""

			if self._thing.miningAward and self._thing.miningAward ~= "" then
				goodsName = "【"..remote.silverMine:getGoodsNameByAwardStr(self._thing.miningAward).."】"
				local _, _, count = remote.silverMine:getItemBoxParaMetet(self._thing.miningAward)
				goodsCount = count
			end
			-- local timeStr = string.format("%02d:%02d:%02d", h, m, s)
			if goodsCount == "" then
				-- 无物品
				textStr = "##n"..name.."##e"..thing
			else
				-- 有物品
				textStr = "##n"..name.."##e"..thing.."##n"..goodsName.."X"..goodsCount
			end
		end
		local timeStr = q.date("%H:%M:%S", self._thing.miningAt/1000)
		self._ccbOwner.tf_time:setString(timeStr)
		local timeWidth = self._ccbOwner.tf_time:getPositionX() + self._ccbOwner.tf_time:getContentSize().width
		print("textStr = "..textStr)
		local text = QColorLabel:create(textStr, self._wdith - timeWidth - 15, self._height, nil, 20)
		self._ccbOwner.node_text:addChild(text)
		text:setPosition(ccp( timeWidth, 0 ))
		self._actualHeight = text:getActualHeight() -- 文本实际高度
	end
end

return QUIWidgetSilverMineOpportunity