-- 最大长度队列，超出后自动pop，如有重复则自动到最后面
-- Author: Stephen
-- Date: 2015-5-13
--

local TFLengthArray = class("TFLengthArray",TFArray)


function TFLengthArray:ctor(length)
	self.super.ctor(self)

	self.m_maxLength = length
end


function TFLengthArray:setMaxLength( length )
	self.m_maxLength = length
end
--[[--
	在数组插入元素
	@param key: 对应的关键元素
	@param obj: 元素
	@return nil
]]	
function TFLengthArray:push(key , obj)
	local nIndex = -1
	if key == nil then
		nIndex = self:indexOf( obj)
	else
		nIndex = self:indexByKey( key , obj)
	end
	if nIndex == -1 then
		self:AddToBack(obj)
	else
		self:pushToBack( nIndex , obj )
	end
end

function TFLengthArray:indexByKey(key , obj)
	for k,v in pairs(self.m_list) do
		if v[key] == obj[key] then
			return k - self.head + 1
		end
	end
	return -1

end

function TFLengthArray:pushToBack( nIndex , obj )
	local x = self.m_list[self.head + nIndex - 1]
	-- for i=1,(self.tail - self.head) - (self.head + nIndex - 1)  do
	-- 	self.m_list[self.head + nIndex - 1 + (i - 1)] = self.m_list[self.head + nIndex - 1 + i]
	-- end
	-- self.m_list[self.tail - self.head + 1] = x
	for i= self.head + nIndex - 1, self.tail - 1 -1 do
		self.m_list[i] = self.m_list[i+1]
	end
	self.m_list[self.tail - 1] = x
end

function TFLengthArray:AddToBack( obj )
	self:pushBack(obj)
	-- if self:length() > self.m_maxLength then
	-- 	self:pop()
	-- end
end


return TFLengthArray