local SanguozhiData = class("SanguozhiData")

function SanguozhiData:ctor()
	self._usedList = {}
	self._usedListIndex = {}
	self._hasEnter = false
end

function SanguozhiData:setUsedInfo(data)
	self._hasEnter = true
	self._usedList = {}
	self._usedListIndex = {}
	if data == nil or #data == 0 then
		return
	end
	for i,v in ipairs(data)do
		table.insert(self._usedList,v)
		self._usedListIndex[v] = v
	end
	self:_sortUsedList()
end


function SanguozhiData:getLastUsedId()
	if self._usedList == nil or #self._usedList == 0 then
		return 0
	end
	return self._usedList[#self._usedList]
end

function SanguozhiData:setLastUsedId(_id)
	table.insert(self._usedList,_id)
	self._usedListIndex[_id] = _id
	self:_sortUsedList()
end

function SanguozhiData:_sortUsedList()
	local sortFunc = function(a,b)
		return a < b
	end
	table.sort(self._usedList,sortFunc)
end


function SanguozhiData:checkEnterSanguozhi()
	return self._hasEnter
end

function SanguozhiData:getAttrList()
	require("app.cfg.main_growth_info")
	if self._usedList == nil or #self._usedList == 0 then
		return nil
	end
	local list = {}
	for i,v in ipairs(self._usedList) do
		local data = main_growth_info.get(v)
		if data and data.attribute_type ~= 0 then
			if list[data.attribute_type] == nil then
				list[data.attribute_type] = data.attribute_value
			else
				list[data.attribute_type] = list[data.attribute_type] + data.attribute_value
			end
		end
	end
	return list
end

return SanguozhiData

