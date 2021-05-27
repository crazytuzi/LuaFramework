bit = {data32 = {}, data64 = {}}

for i = 1, 64 do
	if i <= 32 then
		bit.data32[i] = 2 ^ (32 - i)
	end
	bit.data64[i] = 2 ^ (64 - i)
end

-- number转table 1->32 高位->低位
function bit:d2b(arg, is_long)
	local len = is_long and 64 or 32
	local bit_t = is_long and bit.data64 or bit.data32
	local arg2 = math.abs(arg)
	local tr = {}
	for i = 1, len do
		if arg2 >= bit_t[i] then
			tr[i] = 1
			arg2 = arg2 - bit_t[i]
		else
			tr[i] = 0
		end
	end
	if arg < 0 then
		for i = 1, len do
			if i ~= 1 then
				tr[i] = tr[i] == 1 and 0 or 1
			end
		end
		local add = 0
		for i = len, 1, -1 do
			local val = tr[i]
			if i == len or add > 0 then
				val = val + 1
				if val == 2 then
					tr[i] = 0
					add = 1
				else
					tr[i] = 1
					break
				end
			end
		end
		tr[1] = 1
	end
	return  tr
end

-- table转number
function bit:b2d(arg)
	local nr = 0
	for i = 1, 32 do
		if arg[i] == 1 then
			nr = nr + 2 ^ (32 - i)
		end
	end
	return nr
end

-- long long转table 1->64 高位->低位
-- @high 高32位
-- @low 低32位
function bit:ll2b(high, low)
	local high_t, low_t = bit:d2b(high), bit:d2b(low)

	for i = 1, 32 do
		high_t[i + 32] = low_t[i]
	end

	return high_t
end

-- table转long long
-- @return 高32位，低32位
function bit:b2ll(arg)
	local high_t, low_t = {}, {}

	for i = 1, 32 do
		high_t[i] = arg[i]
		low_t[i] = arg[i + 32]
	end

	return bit:b2d(high_t), bit:b2d(low_t)
end

-- 按位与
function bit:_and(a, b)
	return AdapterToLua:_and(a, b)
end

-- 按位或
function bit:_or(a, b)
	return AdapterToLua:_or(a, b)
end

-- 按位取反
function bit:_not(a)
	return AdapterToLua:_not(a)
end

-- 按位异或
function bit:_xor(a, b)
	return AdapterToLua:_xor(a, b)
end

-- 右移
function bit:_rshift(a, n)
	return AdapterToLua:_rshift(a, n)
end

-- 左移
function bit:_lshift(a, n)
	return AdapterToLua:_lshift(a, n)
end

-- 两个uint合并成int64
function bit:merge64(l, h)
	return AdapterToLua:_merge64(l, h)
end

function bit:b2int64(arg)
	local h, l = bit:b2ll(arg)
	return bit:merge64(l, h)
end