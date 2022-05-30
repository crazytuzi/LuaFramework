--[[
数组索引由下标0到下标n-1
--]]
Array = Array or BaseClass()

function Array:__init()
	self.size = 0
	self.items = {}
end

function Array:IsEmpty()
	return self.size <= 0
end

--[[
在数组尾部插入一项
@para1 val in 插入数组的项
@author deadline
@create 5/16/2012
--]]
function Array:PushBack( val )
	self.size = self.size + 1
	self.items[self.size] = val
end


--[[
从数组尾部移除一项并返回
@return 返回移除的项
@author deadline
@create 5/16/2012
--]]
function Array:PopBack()
	if self.size > 0 then
		local val =self.items[self.size]
		self.items[self.size] = nil
		self.size = self.size - 1
		return val
	end
	return nil
end

--[[
从数组头部添加一项
@para1 val in 一个数组项
@author deadline
@create 5/18/2012
--]]
function Array:PushFront( val )
	table.insert(self.items, 1, val)
	self.size = self.size + 1
end


--[[
从数组头部移除一项并返回
@return 返回移除的项
@author deadline
@create 5/18/2012
--]]
function Array:PopFront()
	if self.size > 0 then
		local val = self.items[1]
		table.remove(self.items, 1)
		self.size = self.size - 1
		return val
	end
	return nil
end

--[[
逐项对数组每一项执行某操作
@para1 func in 每项执行的函数,类型为 func(item)
@author deadline
@create 5/16/2012
--]]
function Array:ForEach(func)
	for i = 1, self.size do
		func(self.items[i])
	end
end

--[[
按索引获取数组中的某项
@para1 index in 数组索引
@return 返回对应索引的项的项
@author deadline
@create 5/18/2012
--]]
function Array:Get(index, warnning)
	if index < self.size then
		return self.items[index + 1]
	elseif warnning ~= false then
		print("Array:Get() out of index!")
	end
end

--[[
按索引设置数组中的某项
@para1 index in 数组索引
@para2 val in 设置的值
@author deadline
@create 5/18/2012
--]]
function Array:Set(index, val)
	if index < self.size then
		self.items[index + 1] = val
	else
		print("Array:Set() out of index!")
	end
end

--[[
逐项对数组每一项执行某操作
@return 数组大小
@author deadline
@create 5/16/2012
--]]
function Array:GetSize()
	return self.size
end

--[[
对数组执行升序排序操作
@para1 key_name in 用来排序的数组项Key(可选参数)
@author deadline
@create 5/18/2012
--]]
function Array:LowerSort(key_name)
	local sort_func
	if key_name then
		sort_func = SortTools.KeyLowerSorter(key_name)
	else
		sort_func = SortTools.ItemLowerSorter()
	end
	table.sort(self.items, sort_func)
end

-- [[多参数的对数组进行排序,对数组执行升序排序操作
-- @para1 ... 用来排序的数组项Key(可选参数)
-- -- ]]
function Array:LowerSortByParams(...)
    local temp_tab = {...}
    local sort_func
    if table.getn(temp_tab) == 0 then
        sort_func = SortTools.ItemLowerSorter()
    else
        sort_func = SortTools.tableLowerSorter(temp_tab)
    end
    if self:GetSize() > 1 then
        table.sort(self.items, sort_func)
    end
end


--[[
对数组执行降序排序操作
@para1 key_name in 用来排序的数组项Key(可选参数)
@author deadline
@create 5/18/2012
--]]
function Array:UpperSort(key_name)
	local sort_func
	if key_name then
		sort_func = SortTools.KeyUpperSorter(key_name)
	else
		sort_func = SortTools.ItemUpperSorter()
	end
	table.sort(self.items, sort_func)
end

-- [[多参数的对数组进行排序,对数组执行降序排序操作
-- @para1 ... 用来排序的数组项Key(可选参数)
-- -- ]]
function Array:UpperSortByParams(...)
    local temp_tab = {...}
    local sort_func
    if table.getn(temp_tab) == 0 then
        sort_func = SortTools.ItemUpperSorter()
    else
        sort_func = SortTools.tableUpperSorter(temp_tab)
    end
    if self:GetSize() > 1 then
        table.sort(self.items, sort_func)
    end
end

--[[
依据项中的Key查找数组中的一项
@para1 item_key in 用来搜索的数组项Key
@para2 val in 要查找的item_key的值
@para3 offset in 开始检索的位置
@return 返回检索到的项,检索到的项的Index
@author deadline
@create 5/18/2012
--]]
function Array:FindByKey(item_key, val, offset)
	offset = offset or 0
	for i = offset + 1, self.size do
		local item = self.items[i]
		if item[item_key] == val then
			return item, i-1
		end
	end
	return nil, -1
end

--[[
依据项中的Key查找数组中的一项
@para1 item_key in 用来搜索的数组项Key
@para2 val in 要查找的item_key的值
@para3 offset in 开始检索的位置
@return 返回检索到的项,检索到的项的Index
@author deadline
@create 5/18/2012
--]]
function Array:FindByLastKey(item_key, val, offset)
	offset = offset or 0
	local data, idx = nil, -1
	for i = offset + 1, self.size do
		local item = self.items[i]
		if item[item_key] == val then
			data, idx = item, i-1
		end
	end
	return data, idx
end

--[[
依据项中的Key查找数组中的一项
@para1 equal_func in 用来检测数组项是否符合要求的函数
@para2 offset in 开始检索的位置
@return 返回检索到的项,检索到的项的Index
@author deadline
@create 5/18/2012
--]]
function Array:FindByFunc(equal_func, offset)
	offset = offset or 0
	for i = offset + 1, self.size do
		local item = self.items[i]
		if equal_func(item) then
			return item, i-1
		end
	end
	return nil, -1
end

--[[
移除对应索引的项
@para1 index in 待删除的索引
@author deadline
@create 5/18/2012
--]]
function Array:Erase(index)
	local item
	index = index or self.size - 1
	if index >= 0 and index < self.size then
		item = table.remove(self.items, index + 1)
		self.size = self.size -1
	end
	return item
end

--[[
在对应位置插入一项
@para1 key_name in 用来排序的数组项Key(可选参数)
@author deadline
@create 5/18/2012
--]]
function Array:Insert(item, index)
	index = index or 0
	table.insert(self.items, index + 1, item)
	self.size = self.size + 1
end

--[[
二分查找方式插入一项, 用于快速构建一个排序数组
@para1 item in 插入到数组中的项
@para2 comp_func in 比较函数
@author deadline
@create 5/18/2012
--]]
--[[
function Array:BinaryInsert(item, comp_func)
	SortTools.BinaryInsert(self.items, item, comp_func)
end
--]]

function Array.GetArray(array,begin_pos,end_pos)

	if array == nil then
		return {}
	end

	local ret = {}
	for i=begin_pos,end_pos do

		if i > #(array) then
			break
		end

		table.insert(ret,array[i])
	end

	return ret
end

function Array.GetArrayByScale(array,scale,length)
	if array == nil then
		return {}
	end

	local ret = {}
	local begin_pos = math.floor(#(array)*scale) + 1
	local end_pos = begin_pos+length-1

	return Array.GetArray(array,begin_pos,end_pos)
end

-- 合并数组 返回新的数组 不影响原来数组
function Array:ConcatArray(array)
	if array == nil or array:GetSize() == 0 then
		return self
	end
	local temp_arr = Array.New()
	self:ForEach(function(val)
		temp_arr:PushBack(val)
	end)
	array:ForEach(function(val)
		temp_arr:PushBack(val)
	end)
	return temp_arr
end

