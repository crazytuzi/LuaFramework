--
-- @Author: LaoY
-- @Date:   2019-08-09 10:47:58
--

--require("game.xx.xxx")

FuzzySearch = FuzzySearch or class("FuzzySearch")

function FuzzySearch:ctor(config,search_key,save_key,func)
	self.fuzzy_serarch_map = {}

	self:initConfig(config,search_key,save_key,func)
end

function FuzzySearch:dctor()
	self.fuzzy_serarch_map = nil
end

local function getSearchCharList(str)
	local list = string.utf8list(str)
	local t = {}
	local len = #list
	local map = {}

	for i=1,len-1 do
		for j=len,i+1,-1 do
			local char = ""
			for k=i,j do
				char = char .. list[k]
			end
			if not map[char] then
				t[#t+1] = char
				map[char] = true
			end
		end
	end
	return t,list
end

local function getAllCharList(str)
	local search_list,list = getSearchCharList(str)
	table.insertarray(search_list, list)
	return search_list
end

--[[
	@author LaoY
	@des	初始化模糊搜索配置表
	@param1 config
	@param2 search_key 	搜索配置表的字段，暂时不支持多个
	@param3 save_key 	保存的字段，不填保存单条配置
	@param4 func 		还没想好要用来干嘛
	@return nil
--]]
function FuzzySearch:initConfig(config,search_key,save_key,func)
	if not config then
		return
	end
	self.func = func
	for k,v in pairs(config) do
		local save_value = save_key and v[save_key] or v
		if not save_value then
			save_value = k
		end
		local search_key_str = v[search_key]
		local search_key_char_list = getAllCharList(search_key_str)
		for _,char in pairs(search_key_char_list) do
			self.fuzzy_serarch_map[char] = self.fuzzy_serarch_map[char] or {}
			self.fuzzy_serarch_map[char][#self.fuzzy_serarch_map[char]+1] = save_value
		end
	end
end


local function getWeightList(map,find_char_list,use_count)
	use_count = use_count or 0
	local len = #find_char_list
	local weight_map = {}
	local index = 0
	for i=1,len do
		local char = find_char_list[i]
		if map[char] then
			local len = #map[char]
			for j=1,len do
				index = index + 1
				local save_value = map[char][j]
				if not weight_map[save_value] then
					weight_map[save_value] = {char_list = {char},save_value = save_value,index = index,use_count = 1}
				else
					weight_map[save_value].use_count = weight_map[save_value].use_count + 1
					weight_map[save_value].char_list[#weight_map[save_value].char_list+1] = char
				end
			end
		end
	end

	

	local t = {}
	for k,v in pairs(weight_map) do
		if v.use_count >= use_count then
			t[#t+1] = v
		end
	end

	local function sortFunc(a,b)
		if a.use_count == b.use_count then
			return a.index < b.index
		else
			return a.use_count > b.use_count
		end
	end
	table.sort(t,sortFunc)
	local value_list = {}
	local len = #t
	for i=1,len do
		value_list[#value_list+1] = t[i].save_value
	end
	return value_list
end

function FuzzySearch:find(find_str)
	local search_list,list = getSearchCharList(find_str)
	local find_list = getWeightList(self.fuzzy_serarch_map,search_list)
	local find_list_2 = getWeightList(self.fuzzy_serarch_map,list,#list-1)
	local function is_exists(value)
		for k,v in pairs(find_list) do
			if v == value then
				return true
			end
		end
		return false
	end


	local len = #find_list_2
	for i=1,len do
		local value = find_list_2[i]
		if not is_exists(value) then
			find_list[#find_list+1] = value
		end
	end
	if self.func then
		return self.func(find_list)
	end
	return find_list
end
