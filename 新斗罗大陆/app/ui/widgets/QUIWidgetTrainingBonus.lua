--
-- Author: nzhang
-- Date: 2015-12-17 17:23:29
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTrainingBonus = class("QUIWidgetTrainingBonus", QUIWidget)

function QUIWidgetTrainingBonus:ctor(options)
	local ccbFile = "ccb/Widget_HeroDevelop_client3.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerClick", 				callback = handler(self, QUIWidgetTrainingBonus._onTriggerClick)},
	}
	QUIWidgetTrainingBonus.super.ctor(self,ccbFile,callBacks,options)
end

local dic = {
	atk = "攻击",
	hp = "生命",
	pd = "物防",
	md = "法防",
	hit = "命中",
	dodge = "闪避",
	block = "格挡",
	critical = "暴击",
	haste = "攻速",
}

function QUIWidgetTrainingBonus:setInfo(info)
	-- info = 
	-- {
	-- 	isComplete = true,
	--	battleForce = 1280,
	-- 	level = 5,
	-- 	atk = 120,
	-- 	hp = 120,
	-- 	pd = 25,
	-- 	md = 25,
	--	hit = 2,
	--	dodge = 2,
	--	block = 2,
	--	critical = 2,
	--	haste = 2,
	-- }
	local owner = self._ccbOwner
	owner.sprite_complete:setVisible(not not info.isComplete)
	owner.label_battleforce:setString(tostring(info.battleForce))
	owner.tf_icon_level:setString("LV " .. tostring(info.level))
	local count = 0
	for k,v in pairs(dic) do
		if info[k] > 0 then
			count = count + 1
			owner["label_prop_" .. tostring(count)]:setString(v)
			owner["label_prop_" .. tostring(count)]:setVisible(true)
			owner["label_value_" .. tostring(count)]:setString("+" .. tostring(info[k]))
			owner["label_value_" .. tostring(count)]:setVisible(true)
			if count == 4 then
				break
			end
		end
	end
	for i = count + 1, 4 do
		owner["label_prop_" .. tostring(i)]:setVisible(false)
		owner["label_value_" .. tostring(i)]:setVisible(false)
	end
	owner.normal_banner:setVisible(not info.isComplete)
	owner.done_banner:setVisible(not not info.isComplete)
end

function QUIWidgetTrainingBonus:getContentSize( ... )
	return self._ccbOwner.normal_banner:getContentSize()
end

return QUIWidgetTrainingBonus