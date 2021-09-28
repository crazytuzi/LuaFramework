local utf8 = {}



function utf8.next_raw(s, i)
	if not i then
		if #s == 0 then return nil end
		return 1, true 
	end
	if i > #s then return end
	local c = s:byte(i)
	if c >= 0x00 and c <= 0x7F then
		i = i + 1
	elseif c >= 0xC2 and c <= 0xDF then
		i = i + 2
	elseif c >= 0xE0 and c <= 0xEF then
		i = i + 3
	elseif c >= 0xF0 and c <= 0xF4 then
		i = i + 4
	else 
		return i + 1, false
	end
	if i > #s then return end
	return i, true
end


utf8.next = utf8.next_raw


function utf8.byte_indices(s, previ)
	return utf8.next, s, previ
end


function utf8.len(s)
	assert(s, "bad argument #1 to 'len' (string expected, got nil)")
	local len = 0
	for _ in utf8.byte_indices(s) do
		len = len + 1
	end
	return len
end


function utf8.byte_index(s, target_ci)
	if target_ci < 1 then return end
	local ci = 0
	for i in utf8.byte_indices(s) do
		ci = ci + 1
		if ci == target_ci then
			return i
		end
	end
	assert(target_ci > ci, "invalid index")
end


function utf8.char_index(s, target_i)
	if target_i < 1 or target_i > #s then return end
	local ci = 0
	for i in utf8.byte_indices(s) do
		ci = ci + 1
		if i == target_i then
			return ci
		end
	end
	error("invalid index")
end




function utf8.prev(s, nexti)
	nexti = nexti or #s + 1
	if nexti <= 1 or nexti > #s + 1 then return end
	local lasti, lastvalid = utf8.next(s)
	for i, valid in utf8.byte_indices(s) do
		if i == nexti then
			return lasti, lastvalid
		end
		lasti, lastvalid = i, valid
	end
	if nexti == #s + 1 then
		return lasti, lastvalid
	end
	error("invalid index")
end


function utf8.byte_indices_reverse(s, nexti)
	if #s < 200 then
		
		return utf8.prev, s, nexti
	else
		
		
		local t = {}
		for i in utf8.byte_indices(s) do
			if nexti and i >= nexti then break end
			table.insert(t, i)
		end
		local i = #t + 1
		return function()
			i = i - 1
			return t[i]
		end
	end
end





function utf8.sub(s, start_ci, end_ci)
	
	assert(start_ci >= 1)
	assert(not end_ci or end_ci >= 0)
	local ci = 0
	local start_i, end_i
	for i in utf8.byte_indices(s) do
		ci = ci + 1
		if ci == start_ci then
			start_i = i
		end
		if ci == end_ci then
			end_i = i
		end
	end
	if not start_i then
		assert(start_ci > ci, 'invalid index')
		return ''
	end
	if end_ci and not end_i then
		if end_ci < start_ci then
			return ''
		end
		assert(end_ci > ci, 'invalid index')
	end
	return s:sub(start_i, end_i and end_i - 1)
end



function utf8.contains(s, i, sub)
	if i < 1 or i > #s then return nil end
	for si = 1, #sub do
		if s:byte(i + si - 1) ~= sub:byte(si) then
			return false
		end
	end
	return true
end


function utf8.count(s, sub)
	assert(#sub > 0)
	local count = 0
	local i = 1
	while i do
		if utf8.contains(s, i, sub) then
			count = count + 1
			i = i + #sub
			if i > #s then break end
		else
			i = utf8.next(s, i)
		end
	end
	return count
end















function utf8.isvalid(s, i)
	local c = s:byte(i)
	if not c then
		return false
	elseif c >= 0x00 and c <= 0x7F then
		return true
	elseif c >= 0xC2 and c <= 0xDF then
		local c2 = s:byte(i + 1)
		return c2 and c2 >= 0x80 and c2 <= 0xBF
	elseif c >= 0xE0 and c <= 0xEF then
		local c2 = s:byte(i + 1)
		local c3 = s:byte(i + 2)
		if c == 0xE0 then
			return c2 and c3 and
				c2 >= 0xA0 and c2 <= 0xBF and
				c3 >= 0x80 and c3 <= 0xBF
		elseif c >= 0xE1 and c <= 0xEC then
			return c2 and c3 and
				c2 >= 0x80 and c2 <= 0xBF and
				c3 >= 0x80 and c3 <= 0xBF
		elseif c == 0xED then
			return c2 and c3 and
				c2 >= 0x80 and c2 <= 0x9F and
				c3 >= 0x80 and c3 <= 0xBF
		elseif c >= 0xEE and c <= 0xEF then
			if c == 0xEF and c2 == 0xBF and (c3 == 0xBE or c3 == 0xBF) then
				return false 
			end
			return c2 and c3 and
				c2 >= 0x80 and c2 <= 0xBF and
				c3 >= 0x80 and c3 <= 0xBF
		end
	elseif c >= 0xF0 and c <= 0xF4 then
		local c2 = s:byte(i + 1)
		local c3 = s:byte(i + 2)
		local c4 = s:byte(i + 3)
		if c == 0xF0 then
			return c2 and c3 and c4 and
				c2 >= 0x90 and c2 <= 0xBF and
				c3 >= 0x80 and c3 <= 0xBF and
				c4 >= 0x80 and c4 <= 0xBF
		elseif c >= 0xF1 and c <= 0xF3 then
			return c2 and c3 and c4 and
				c2 >= 0x80 and c2 <= 0xBF and
				c3 >= 0x80 and c3 <= 0xBF and
				c4 >= 0x80 and c4 <= 0xBF
		elseif c == 0xF4 then
			return c2 and c3 and c4 and
				c2 >= 0x80 and c2 <= 0x8F and
				c3 >= 0x80 and c3 <= 0xBF and
				c4 >= 0x80 and c4 <= 0xBF
		end
	end
	return false
end



function utf8.next_valid(s, i)
	local valid
	i, valid = utf8.next_raw(s, i)
	while i and (not valid or not utf8.isvalid(s, i)) do
		i, valid = utf8.next(s, i)
	end
	return i
end


function utf8.valid_byte_indices(s)
	return utf8.next_valid, s
end


function utf8.validate(s)
	for i, valid in utf8.byte_indices(s) do
		if not valid or not utf8.isvalid(s, i) then
			error(string.format('invalid utf8 char at #%d', i))
		end
	end
end

local function table_lookup(s, i, j, t)
	return t[s:sub(i, j)]
end


function utf8.replace(s, f, ...)
	if type(f) == 'table' then
		return utf8.replace(s, table_lookup, f)
	end
	if s == '' then
		return s
	end
	local t = {}
	local lasti = 1
	for i in utf8.byte_indices(s) do
		local nexti = utf8.next(s, i) or #s + 1
		local repl = f(s, i, nexti - 1, ...)
		if repl then
			table.insert(t, s:sub(lasti, i - 1))
			table.insert(t, repl)
			lasti = nexti
		end
	end
	table.insert(t, s:sub(lasti))
	return table.concat(t)
end

local function replace_invalid(s, i, j, repl_char)
	if not utf8.isvalid(s, i) then
		return repl_char
	end
end


function utf8.sanitize(s, repl_char)
	repl_char = repl_char or '�' 
	return utf8.replace(s, replace_invalid, repl_char)
end

return utf8
