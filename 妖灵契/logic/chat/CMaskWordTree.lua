local CMaskWordTree = class("CMaskWordTree")
local string = string
local pairs = pairs
local ipairs = ipairs
local tinsert = table.insert

function CMaskWordTree.ctor(self)
	self.m_RootNode = self:CreateNode('r') 
end

function CMaskWordTree.UpdateNodes(self, words)
	for i, v in pairs(words) do
		local chars = self:GetCharList(string.lower(v))
		if #chars > 0 then
			self:InsertNode(self.m_RootNode, chars, 1)
		end
	end
end

--树节点创建
function CMaskWordTree.CreateNode(self, char, flag, childs)
	local node = {}
	node.char = char or nil		--字符
	node.flag = flag or 0		--是否结束标志，0：继续，1：结尾
	node.childs = childs or {}	--保存子节点
	node.isleaf = true --childs数量为0则是叶子节点
	return node
end

--插入节点
function CMaskWordTree.InsertNode(self, parent, chars, index)
	local node = self:FindNode(parent, chars[index])
	if node == nil then
		node = self:CreateNode(chars[index])
		parent.isleaf = false
		tinsert(parent.childs, node)
	end
	local len = #chars
	if index == len then
		node.flag = 1
	else
		index = index + 1
		if index <= len then
			self:InsertNode(node, chars, index)
		end
	end
end

--节点中查找子节点
function CMaskWordTree.FindNode(self, node, char)
	local childs = node.childs
	for i, child in ipairs(childs) do
		if child.char == string.lower(char) then 
			return child
		end
	end

end

function CMaskWordTree.GetCharList(self, str)
	local list = {}
	while str do
		local utf8 = string.byte(str,1)
		if utf8 == nil then
			break
		end
		--utf8字符1byte,中文3byte
		if utf8 > 127 then
			local tmp = string.sub(str,1,3)
			tinsert(list,tmp)
			str = string.sub(str,4)
		else
			local tmp = string.sub(str,1,1)
			tinsert(list,tmp)
			str = string.sub(str,2)
		end
	end
	return list
end

--将字符串中敏感字用*替换返回
function CMaskWordTree.ReplaceMaskWord(self, str)
	local linkStr = {}
	local emojiList = {}
	for sLink in string.gmatch(str, "%b{}") do
		tinsert(linkStr, sLink)
	end
	for sLink in string.gmatch(str, "#%d+") do
		tinsert(emojiList, sLink)
	end
	str = string.gsub(str, "#%d+", "#emoji")
	local chars = self:GetCharList(str)
	local index = 1
	local node = self.m_RootNode
	local prenode = nil
	local matchs = {}
	local isReplace = false
	local lastMatchLen = nil
	local totalLen = #chars
	local function replace(chars, list, last)
		for i=1, last do
			local v = list[i]
			if isReplace then
				chars[v] = ""
			else
				chars[v] = "***"
				isReplace = true
			end
		end
	end
	while totalLen + 1 >= index do
		prenode = node
		if not chars[index] then
			node = nil
		else
			node = self:FindNode(node, chars[index])
		end
		if chars[index] == " " then
			if #matchs then
				tinsert(matchs, index)
				node = prenode
			else
				node = self.m_RootNode
			end
		elseif node == nil then
			index = index - #matchs
			if lastMatchLen then
				replace(chars, matchs, lastMatchLen)
				index = index + (lastMatchLen - 1)
				lastMatchLen = nil
			else
				isReplace = false
			end
			node = self.m_RootNode
			matchs = {}
		elseif node.flag == 1 then
			tinsert(matchs, index)
			if node.isleaf or totalLen == index then
				replace(chars, matchs, #matchs)
				lastMatchLen = nil
				matchs = {}
				node = self.m_RootNode
			else
				lastMatchLen = #matchs
			end
		else
			tinsert(matchs, index)
		end
		index = index + 1
	end
	local str = ''
	for i, v in ipairs(chars) do
		str = str..v
	end
	local index = 1
	for sLink in string.gmatch(str, "%b{}") do
		if linkStr[index] then
			str = string.replace(str, sLink, linkStr[index])
		end
		index = index + 1
	end
	local index = 1
	for sLink in string.gmatch(str, "#emoji") do
		if emojiList[index] then
			str = string.gsub(str, sLink, emojiList[index], 1)
		end
		index = index + 1
	end
	return str
end

--字符串中是否含有敏感字
function CMaskWordTree.IsContainMaskWord(self, str)
	local sCheck = string.gsub(str, " ", "")
	sCheck = string.gsub(sCheck, "#%u", "")
	sCheck = string.gsub(sCheck, "#%d", "")
	sCheck = string.gsub(sCheck, "%b{}", "")
	
	local chars = self:GetCharList(sCheck)
	local index = 1
	local node = self.m_RootNode
	local masks = {}
	while #chars + 1 >= index do
		if not chars[index] then
			node = nil
		else
			node = self:FindNode(node, chars[index])
		end
		if node == nil then
			index = index - #masks 
			node = self.m_RootNode
			masks = {}
		elseif node.flag == 1 then
			return true
		else
			tinsert(masks, index)
		end
		index = index + 1
	end
	return false
end

function CMaskWordTree.GetMaskWord(self, str)
	local sCheck = string.gsub(str, " ", "")
	sCheck = string.gsub(sCheck, "#%u", "")
	sCheck = string.gsub(sCheck, "%b{}", "")
	
	local chars = self:GetCharList(sCheck)
	local index = 1
	local node = self.m_RootNode
	local masks = {}
	while #chars + 1 >= index do
		if not chars[index] then
			node = nil
		else
			node = self:FindNode(node, chars[index])
		end
		if node == nil then
			index = index - #masks 
			node = self.m_RootNode
			masks = {}
		elseif node.flag == 1 then
			local sWord = ""
			tinsert(masks, index)
			for i,v in ipairs(masks) do
				sWord = string.format("%s%s", sWord, chars[v])
			end
			return sWord
		else
			tinsert(masks, index)
		end
		index = index + 1
	end
	return nil
end


return CMaskWordTree
