SortTools = {}

-- 升序排列函数，如果参数为空直接比较，参数不为空比较表项，优先级依次递减
function SortTools.AscFunc(...)
	local params = {...}
	local count = #params
	if 0 == count then
		return function(a, b)
			return a < b
		end
	elseif 1 == count then
		return function(a, b)
			return a[params[1]] < b[params[1]]
		end
	end

	return function(a, b)
		for _, v in ipairs(params) do
			if a[v] < b[v] then
				return true
			elseif a[v] > b[v] then
				return false
			end
		end
		return false
	end
end

-- 升序排列
function SortTools.SortAsc(t, ...)
	table.sort(t, SortTools.AscFunc(...))
end

-- 降序排列函数，如果参数为空直接比较，参数不为空比较表项，优先级依次递减
function SortTools.DescFunc(...)
	local params = {...}
	local count = #params
	if 0 == count then
		return function(a, b)
			return a > b
		end
	elseif 1 == count then
		return function(a, b)
			return a[params[1]] > b[params[1]]
		end
	end

	return function(a, b)
		for _, v in ipairs(params) do
			if a[v] > b[v] then
				return true
			elseif a[v] < b[v] then
				return false
			end
		end
		return false
	end
end

-- 降序排列
function SortTools.SortDesc(t, ...)
	table.sort(t, SortTools.DescFunc(...))
end

--[[
从小到大排序的算子(用于表项)
@para1 sort_key_name 需要比较的表项中的key
@para2 sort_key_name2 第一个参数相同的情况下比较此key
--]]
function SortTools.KeyLowerSorter(sort_key_name, sort_key_name2)
	return function(a, b)
		if a[sort_key_name] < b[sort_key_name] then
			return true
		elseif a[sort_key_name] == b[sort_key_name] and nil ~= sort_key_name2 then
			return a[sort_key_name2] < b[sort_key_name2]
		else
			return false
		end
	end
end

--[[
从大到小排序的算子(用于表项)
@para2 sort_key_name 需要比较的表项中的key
--]]
function SortTools.KeyUpperSorter(sort_key_name)
	return function(a, b)
		return a[sort_key_name] > b[sort_key_name]
	end
end

--[[
从大到小排序的算子(用于表项)
@para1~3 sort_key_name1, sort_key_name2, sort_key_name3 需要比较的表项中的key,优先级依次递减
--]]
function SortTools.KeyUpperSorters(sort_key_name1, sort_key_name2, sort_key_name3, sort_key_name4, sort_key_name5)
	return function(a, b)
		local order_a = 100000
		local order_b = 100000
		if a[sort_key_name1] > b[sort_key_name1] then
			order_a = order_a + 10000
		elseif a[sort_key_name1] < b[sort_key_name1] then
			order_b = order_b + 10000
		end

		if nil == sort_key_name2 then  return order_a > order_b end

		if a[sort_key_name2] > b[sort_key_name2] then
			order_a = order_a + 1000
		elseif a[sort_key_name2] < b[sort_key_name2] then
			order_b = order_b + 1000
		end

		if nil == sort_key_name3 then  return order_a > order_b end

		if a[sort_key_name3] > b[sort_key_name3] then
			order_a = order_a + 100
		elseif a[sort_key_name3] < b[sort_key_name3] then
			order_b = order_b + 100
		end

		if nil == sort_key_name4 then  return order_a > order_b end

		if a[sort_key_name4] > b[sort_key_name4] then
			order_a = order_a + 10
		elseif a[sort_key_name4] < b[sort_key_name4] then
			order_b = order_b + 10
		end

		if nil == sort_key_name5 then  return order_a > order_b end

		if a[sort_key_name5] > b[sort_key_name5] then
			order_a = order_a + 1
		elseif a[sort_key_name5] < b[sort_key_name5] then
			order_b = order_b + 1
		end

		return order_a > order_b
	end
end

function SortTools.KeyLowerSorters(sort_key_name1, sort_key_name2, sort_key_name3, sort_key_name4, sort_key_name5)
	return function(a, b)
		local order_a = 100000
		local order_b = 100000
		if a[sort_key_name1] > b[sort_key_name1] then
			order_a = order_a + 10000
		elseif a[sort_key_name1] < b[sort_key_name1] then
			order_b = order_b + 10000
		end

		if nil == sort_key_name2 then  return order_a < order_b end

		if a[sort_key_name2] > b[sort_key_name2] then
			order_a = order_a + 1000
		elseif a[sort_key_name2] < b[sort_key_name2] then
			order_b = order_b + 1000
		end

		if nil == sort_key_name3 then  return order_a < order_b end

		if a[sort_key_name3] > b[sort_key_name3] then
			order_a = order_a + 100
		elseif a[sort_key_name3] < b[sort_key_name3] then
			order_b = order_b + 100
		end

		if nil == sort_key_name4 then  return order_a < order_b end

		if a[sort_key_name4] > b[sort_key_name4] then
			order_a = order_a + 10
		elseif a[sort_key_name4] < b[sort_key_name4] then
			order_b = order_b + 10
		end

		if nil == sort_key_name5 then  return order_a < order_b end

		if a[sort_key_name5] > b[sort_key_name5] then
			order_a = order_a + 1
		elseif a[sort_key_name5] < b[sort_key_name5] then
			order_b = order_b + 1
		end

		return order_a > order_b
	end
end