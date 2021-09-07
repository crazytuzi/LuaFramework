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
end

function ChatFilter:__delete()
	ChatFilter.Instance = nil
	self.filter_list = nil
	self.usernamefilter_list = nil
end

function ChatFilter:ResetShieldList(add_list)
	if add_list == nil or next(add_list) == nil then
		return
	end

	local spid = GLOBAL_CONFIG.package_info.config.agent_id
	local agent_cfg = ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").background_keyword
	if agent_cfg then
		for k,v in pairs(agent_cfg) do
			if v.spid == spid then
				return
			end
		end
	end

	local chat_list = TableCopy(config_chatfilter_list)
	self.filter_list = chat_list

	for k,v in pairs(add_list) do
		if v ~= nil and v[1] ~= nil then
			local add_value = tostring(v[1])
			if add_value then
				table.insert(self.filter_list, add_value)
			end
		end
	end
end

--过滤敏感词，将过敏感词用*号代替
function ChatFilter:Filter(content)
	local match_list = self:GetMatchList(self:LinkHandler(content, false), self.filter_list)
	return self:LinkHandler(self:ReplaceMatch(match_list, content), true)
end

--是否含有非法字符
function ChatFilter:IsIllegal(content, is_username)
	local match_list = {}
	if is_username then
		local s, e = string.find(content, "%s")
		if s ~= nil and e ~= nil and e >= s then
			return 1
		end
		match_list = self:GetMatchList(content, self.usernamefilter_list)
	else
		match_list = self:GetMatchList(content, self.filter_list)
	end
	return #match_list > 0
end

function ChatFilter:GetMatchList(content, filter_list)
	content = string.gsub(content, "%s", "")			-- 空白符
	content = string.gsub(content, "　", "")			-- 全角空格
	if filter_list == nil then
		return nil
	end
	local match_list = {}
	local len = #filter_list
	for i=1,len do
		local match = filter_list[i]
		local s, e = string.find(content, match)
		if s ~= nil and e ~= nil and e >= s then
			local t = {}
			t.match = match
			t.len = self:Utfstrlen(match)
			-- t.len = AdapterToLua:utf8FontCount(match)
			table.insert(match_list, t)
		end
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
		for i=1,#arr do
			local s, e = string.find(content, "{.-}")
			if nil ~= s and nil ~= e then
				local str = string.sub(content, s, e)
				table.insert(self.filter_link_list, str)
				content = string.gsub(content, str, "#link#", 1)
			end
		end
	end
	return content
end
