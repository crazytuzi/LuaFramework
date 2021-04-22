-- @Author: zhouxiaoshu
-- @Date:   2019-06-18 15:05:48
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-07-03 20:29:44

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulSpiritCombinationProp = class("QUIWidgetSoulSpiritCombinationProp", QUIWidget)
local QActorProp = import("...models.QActorProp")
local QRichText = import("...utils.QRichText") 
local QColorLabel = import("...utils.QColorLabel")

function QUIWidgetSoulSpiritCombinationProp:ctor(options)
	local ccbFile = "ccb/Widget_SoulSpirit_HandBookProp_Cell.ccbi"
	local callBacks = {
		}
	QUIWidgetSoulSpiritCombinationProp.super.ctor(self,ccbFile,callBacks,options)

	self._size = self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSoulSpiritCombinationProp:getContentSize()
	return self._size
end

function QUIWidgetSoulSpiritCombinationProp:setInfo(info, grade)
	local size = self._ccbOwner.node_size:getContentSize()
	size.height = 140
	self._ccbOwner.node_size:setContentSize(size.width, size.height)
	self._ccbOwner.node_talent:setVisible(true)

	if info ~= nil then
		local nameStr = string.format("【%s LV.%d】", info.name, info.grade)
		self._ccbOwner.tf_talent_title:setString(nameStr)
		local propStrList = self:getCombinationProp(info)
		for i, propStr in ipairs(propStrList) do
			local tf = self._ccbOwner["tf_talent_desc"..i]
			if tf then
				tf:setString(propStr)
			else
				break
			end
		end

		if grade >= info.grade then
			self._ccbOwner.tf_talent_title:setColor(COLORS.k)
			local index = 1
			while true do
				local tf = self._ccbOwner["tf_talent_desc"..index]
				if tf then
					tf:setColor(COLORS.j)
					index = index + 1
				else
					break
				end
			end
		else
			self._ccbOwner.tf_talent_title:setColor(COLORS.n)
			local index = 1
			while true do
				local tf = self._ccbOwner["tf_talent_desc"..index]
				if tf then
					tf:setColor(COLORS.n)
					index = index + 1
				else
					break
				end
			end
		end
	end
end

function QUIWidgetSoulSpiritCombinationProp:getCombinationProp(combination)
	local tbl = {}
	for key, value in pairs(combination) do
		if QActorProp._field[key] then
			local str = ""
			local isPercent = QActorProp._field[key].isPercent
			local name = QActorProp._field[key].uiName or QActorProp._field[key].name
            local numStr = q.getFilteredNumberToString(tonumber(value), isPercent, 2) 
            table.insert(tbl, name.."+"..numStr)
		end
	end
	
	return tbl
end


return QUIWidgetSoulSpiritCombinationProp