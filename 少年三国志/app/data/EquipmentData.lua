-- EquipmentData.lua

local EquipmentData = class ("EquipmentData")


function EquipmentData:ctor()

	self._data = nil
end

function EquipmentData:resetLuckData()
	self._data = G_ServerTime:getDate()
end

function EquipmentData:updateLuck()

	if self._data == nil then
		self._data = G_ServerTime:getDate()
		return
	end

	local nowData = G_ServerTime:getDate()
	if self._data ~= nowData then
		self:_clearAllEquipmentLuck()
		self._data = nowData
	end
end

function EquipmentData:_clearAllEquipmentLuck()

	local list = G_Me.bagData:getSortedEquipmentList(false)

	for i,v in ipairs (list) do
		if v.luck_value then
			v.luck_value = 0
		end
	end
end

return EquipmentData