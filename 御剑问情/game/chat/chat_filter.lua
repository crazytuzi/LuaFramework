------------------------------------------------------
--聊天过滤，也称敏感词过滤
--@author bzw
------------------------------------------------------
ChatFilter = ChatFilter or BaseClass()
function ChatFilter:__init()
	if ChatFilter.Instance ~= nil then
		print_error("[ChatFilter] attempt to create singleton twice!")
		return
	end
	ChatFilter.Instance = self
	self.filter_list = config_chatfilter_list
	self.usernamefilter_list = config_usernamefilter_list
	self.filter_link_list = {}

	-- 后台控制屏蔽词
	--"a"写死个文字传过去加密用的
	local content = "1"
	--返回
	local verify_callback = function(url, arg, data, size)
		local ret_t = cjson.decode(data)
		if ret_t and ret_t.ret == 0 and ret_t.data and type(ret_t.data) == "table" then
			for k,v in pairs(ret_t.data) do
				if type(v) == "table" and v[1] then
					table.insert(self.filter_list, v[1])
				end
			end
		end
	end
	-- 返回结束

	local now_server_time = os.time()
	local key = "hdISla9sjXphPqEoE8lZcg=="
	local sign = MD52.GetMD5(content .. now_server_time .. key)
	local real_url = string.format("http://cls.ug14.youyannet.com/api/keyword.php?keyword=%s&time=%s&sign=%s",
									content, tostring(now_server_time), sign)
	HttpClient:Request(real_url, verify_callback)
end

function ChatFilter:__delete()
	self.filter_list = nil
	self.usernamefilter_list = nil
	ChatFilter.Instance = nil
end

--过滤敏感词，将过敏感词用*号代替
function ChatFilter:Filter(content)
	local match_list = self:GetMatchList(self:LinkHandler(content, false), self.filter_list)
	return self:LinkHandler(self:ReplaceMatch(match_list, content), true)
end

--是否含有非法字符
function ChatFilter:IsIllegal(content, is_username)
	content = self:LinkHandler(content, false)
	local match_list = 0
	if is_username then
		match_list = self:GetMatchList(content, self.usernamefilter_list)
	else
		match_list = self:GetMatchList(content, self.filter_list)
	end
	return #match_list > 0
end

function ChatFilter:GetMatchList(content, filter_list)
	if filter_list == nil then
		return nil
	end
	local match_list = {}
	local len = #filter_list
	for i=1,len do
		local match = filter_list[i]
		local s, e = string.find(content, match)
		if s ~= nil and e ~= nil and e >= s  then
			local t = {}
			t.match = match
			t.len = self:Utfstrlen(match)
			-- t.len = AdapterToLua:utf8FontCount(match)
			table.insert(match_list, t)
		end
	end

	--检测连续4个数字
	local t_match = "%d%s*%d%s*%d%s*%d%s*"
	local n_s, n_e = string.find(content, t_match)
	if n_s ~= nil and n_e ~= nil and n_e >= n_s then
		local t = {}
		t.match = t_match
		t.len = 4
		table.insert(match_list, t)
	end

	return match_list
end

function ChatFilter:ReplaceMatch(match_list, content)
	if match_list == nil then return end

	function sortfun(a, b)
		return a.len > b.len
	end
	table.sort(match_list, sortfun)

	for k,v in pairs(match_list) do
		local r_str = ""
		for i=1,v.len do
			r_str = r_str .. "*"
		end
		content = string.gsub(content, v.match , r_str)
	end

	return content
end

function ChatFilter:Utfstrlen(str)
	local len = #str
	local left = len
	local cnt = 0
	local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc}
	while left ~= 0 do
		local tmp=string.byte(str,-left)
		local i=#arr
		while arr[i] do
			if tmp>=arr[i] then
				left=left-i
				break
			end
			i=i-1
		end
		cnt=cnt+1
	end
	return cnt
end

-- 字符中链接过滤的处理
-- 先替换掉链接，避免被过滤掉
-- 最后过滤完后再替换回来
function ChatFilter:LinkHandler(content, is_replace)
	content = content or ""
	if is_replace then
		for i,v in ipairs(self.filter_link_list) do
			content = string.gsub(content, "#link#", v, 1)
		end
		self.filter_link_list = {}
	else
		local arr = Split(content, "{")
		local start_index = 0
		while true do
			local s, e = string.find(content, "{.-}", start_index)
			if nil ~= s and nil ~= e then
				start_index = e
				local str = string.sub(content, s, e)
				table.insert(self.filter_link_list, str)
			else
				break
			end
		end
		content = string.gsub(content, "{.-}", "#link#")
	end
	return content
end

--是否包含不需要屏蔽的类型
function ChatFilter:MatchStr(content)
	for k,v in pairs(NO_FILTER_LIST) do
		if string.find(content, v) ~= nil then
			--不需要进行屏蔽检测
			return false
		end
	end
	return true
end

function ChatFilter:IsEmoji(content)
    local len = string.utf8len(content)
    for i = 1, len do
        local str = ChatData.Instance:SubStringUTF8(content, i, i)
        local byteLen = string.len(str)
        if byteLen > 3 then
            return true
        end


        if byteLen == 3 then
            if string.find(str, "[\226][\132-\173]") or string.find(str, "[\227][\128\138]") then
                return true
            end
        end


        if byteLen == 1 then
            local ox = string.byte(str)
            if (33 <= ox and 47 >= ox) or (58 <= ox and 64 >= ox) or (91 <= ox and 96 >= ox) or (123 <= ox and 126 >= ox) or (str == "　") then
                return true
            end
        end
    end
    return false
end