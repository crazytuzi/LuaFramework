--[[--
	数组

	--By: yun.bo
	--2013/7/8
]]
TFArray = class('TFArray')

function TFArray:ctor()
	self.m_list = {}
	self.tail = 1
	self.head = 1
end

--[[--
	取得数组的长度
	@return 数组长度
]]	
function TFArray:length()
	return self.tail - self.head
end
TFArray.size = TFArray.length
TFArray.count = TFArray.length

--[[--
	获取数组元素的迭代, 用在 for 语句
	@return 迭代函数
]]	
function TFArray:iterator()
	local s, e = self.head - 1, self.tail
	return function ()
		s = s + 1
		if s >= e then return nil end
		return self.m_list[s]
	end
end

--[[--
	在数组中检索指定对象,返回其下标,不存在返回-1
	@param obj: 检索的对象
	@return 对象的下标
]]	
function TFArray:indexOf(obj)
	if self:length() == 0 then return -1 end
	for k, v in pairs(self.m_list) do
		if v == obj then return k - self.head + 1 end		
	end
	return -1
end

--[[--
	在数组中的指定下标位置(从1开始)删除指定长度的元素,可选参数为在被删除的位置添加新的元素
	@param nStart: 开始下标
	@param nCount: 长度
	@param ...: 添加的新元素
	@return nil
]]	
function TFArray:splice(nStart, nCount, ...)
	local tb, ins = {}, {...}
	local nLen = self:length()
	if nLen == 0 then
		for k, v in pairs(ins) do
			self:push(v)
		end
		return nil
	end
	local s, e = self.head, self.head + nStart - 1
	e = e > self.head + nLen and self.head + nLen or e
	while s < e do
		tb[s] = self.m_list[s]
		s = s + 1
	end

	for k, v in pairs(ins) do
		tb[s] = v
		s = s + 1
	end

	e = e + nCount
	while e < self.head + nLen do
		tb[s] = self.m_list[e]
		s = s + 1
		e = e + 1
	end
	self.m_list = tb
	self.tail = self.tail + #ins - nCount
end

--[[--
	在指定位置插入新的元素
	@param nIndex: 插入元素的下标
	@param obj: 元素
	@return nil
]]	
function TFArray:insertAt(nIndex, obj)
	self:splice(nIndex, 0, obj)
end

--[[--
	在数组末尾插入新的元素
	@param obj: 元素
	@return nil
]]	
function TFArray:push(obj)
	return self:pushBack(obj)
end

--[[--
	在数组前端插入新的元素
	@param obj: 元素
	@return nil
]]	
function TFArray:pushFront(obj)
	if not obj then return end
	if instanceOf(obj) == 'TFArray' then
		local nLen = obj:length()
		for v in obj:iterator() do
			self.head = self.head - 1
			self.m_list[self.head] = v
		end	
	else
		self.head = self.head - 1
		self.m_list[self.head] = obj
	end
	return obj
end

--[[--
	在数组末尾插入新的元素
	@param obj: 元素
	@return nil
]]	
function TFArray:pushBack(obj)
	if not obj then return end
	if instanceOf(obj) == 'TFArray' then
		for v in obj:iterator() do
			self.m_list[self.tail] = v
			self.tail = self.tail + 1
		end	
	else
		self.m_list[self.tail] = obj
		self.tail = self.tail + 1
	end
	return obj
end

--[[--
	以给定参数初始化数组
	@param obj: TFArray 或 其他值
	@return obj
]]	
function TFArray:assign(obj)
	self:clear()
	if instanceOf(obj) == 'TFArray' then
		for v in obj:iterator() do
			self.m_list[self.tail] = v
			self.tail = self.tail + 1
		end	
	else
		self.m_list[self.tail] = obj
		self.tail = self.tail + 1
	end
	return obj
end

--[[--
	删除数组首元素,并返回其值
	@return 首元素值
]]	
function TFArray:pop()
	return self:popFront()
end

--[[--
	删除数组首元素,并返回其值
	@return 首元素值
]]	
function TFArray:popFront()
	if self.head >= self.tail then return nil end
	local obj = self.m_list[self.head]
	self.m_list[self.head] = nil
	self.head = self.head + 1
	return obj
end

--[[--
	删除数组末元素,并返回其值
	@return 首元素值
]]	
function TFArray:popBack()
	if self.head >= self.tail then return nil end
	local obj = self.m_list[self.tail - 1]
	self.m_list[self.tail - 1] = nil
	self.tail = self.tail - 1
	return obj
end

--[[--
	返回数组首元素
]]	
function TFArray:front()
	return self.m_list[self.head]
end

--[[--
	返回数组末尾元素
]]	
function TFArray:back()
	return self.m_list[self.tail - 1]
end

--[[--
	返回指定位置索引的元素
	@param nIndex: 索引
	@return 指定位置的元素
]]	
function TFArray:getObjectAt(nIndex)
	return self.m_list[self.head + nIndex - 1]
end

--[[--
	返回指定位置索引的元素
	@param nIndex: 索引
	@return 指定位置的元素
]]	
function TFArray:objectAt(nIndex)
	return self.m_list[self.head + nIndex - 1]
end

--[[--
	删除指定位置索引的元素
	@param nIndex: 索引
]]	
function TFArray:removeObjectAt(nIndex)
	self:splice(nIndex, 1)
end

--[[--
	删除指定元素
	@param obj: 元素
]]	
function TFArray:removeObject(obj)
	local nIndex = self:indexOf(obj)
	if nIndex ~= -1 then
		self:splice(nIndex, 1)
	end
end

--[[--
	清空数组
]]
function TFArray:clear()
	--self:splice(1, self:length())
	self.m_list = {}
	self.tail = 1
	self.head = 1
end

function TFArray:swap(i, j)
	local x = self.m_list[self.head + i - 1]
	local y = self.m_list[self.head + j - 1]
	self.m_list[self.head + i - 1], self.m_list[self.head + j - 1] = y, x
end


--[[--
	快速排序
]]
function TFArray:qsort(p, r, cmp)
	local function partition(arr, p, r, cmp)
		local x = arr:getObjectAt(r)
		local i = p - 1
		if cmp then
			for j = p, r - 1 do
				if cmp(arr:getObjectAt(j), x) then
					i = i + 1
					arr:swap(i, j)
				end
			end
		elseif not cmp then
			for j = p, r - 1 do
				if arr:getObjectAt(j) <= x then
					i = i + 1
					arr:swap(i, j)
				end
			end
		end
		arr:swap(i + 1, r)
		return i + 1
	end
	if p < r then
		local q = partition(self, p, r, cmp)
		self:qsort(p, q - 1, cmp)
		self:qsort(q + 1, r, cmp)
	end
end

--[[--
	快速排序
]]
function TFArray:sort(cmp)
	self:qsort(self.head, self.tail - 1, cmp)
end

--[[--
	洗牌算法	
]]
function TFArray:shuffle()
	local size = self:size()
	if size < 2 then return end

	local nRandomIdx = 1
	local endIdx = self.tail - 1
	for i = self.head, endIdx do 
		if i ~= endIdx then
			nRandomIdx = math.random(i + 1, endIdx) 
			self:swap(i, nRandomIdx)
		end
	end
end
return TFArray