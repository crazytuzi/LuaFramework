local QSBNode = import("..QSBNode")
local QSBArgsRandom = class("QSBArgsRandom", QSBNode)

--[[
	参数
	info = { 
		randomType: "range"、"list"  -- range 代表区域随机，list代表列表随机，默认是list
		count: 随机数目,默认是1
	}
	input = {
		datas = {v1,v2,v3,v4} -- 数据，当randomType为range时,datas = {start,end} (起始位置，结束位置)
		formats = {f1,f2,f3},如果formats比datas长度短 那后面的datas都用最后一个format
		f1的结构为:
		当f1为数字时，f1代表权重
		当f1为table时,{weight = 权重(默认1) ,priority = 优先级(默认1),replace_interval = 重新放回的随机次数(默认0)}
		随机会根据权重先随机优先级高的，然后随机优先级低的
		当formats为空时 等同于 formats = {1} (所有权重全部为1)
	}
	output = {
		output_type: "table"、"data"、"auto" 输出格式,table代表输出的是一个table , data代表输出一个值, auto:如果randomType 为range则输出一个值 为list输出一个table,默认为auto

		注:当output_type为"data"时 无论count有多少个值最后都只会取第一个
	}

	所有的参数都有默认值 除了datas要写之外 其他的都没写的必要  
	我认为大部分策划 大概只需要会以下几个模板就行了
	随机一定区域的数字
	OPTIONS = {
		info = {randomType = "range"},
		input = {datas = {1,10}}
	}
	随机一组字符串,返回字符串
	OPTIONS = {
		input = {
			datas = {"str1","str2","str3"},
		},
		output = {output_type = "data"},
	}
	随机一组字符串,并添加权重,返回一组字符串
	OPTIONS = {
		info = {count = 5},
		input = {
			datas = {"str1","str2","str3"},
			formats = {1,1,3},
		},
	}
	
]]

local function initTable(tab,defaultTab)
	for k,v in pairs(defaultTab) do
		if tab[k] == nil then
			tab[k] = v
		end 
	end
end

function QSBArgsRandom:ctor(...)
	self.super.ctor(self,...)
	self._info = self:getOptions().info or {}
	self._input = self:getOptions().input or {}
	self._output = self:getOptions().output or {}
	initTable(self._info,{randomType = "list",count = 1})
	initTable(self._input,{datas = {},formats = {1}})
	initTable(self._output,{output_type = "auto"})
	self._format_data = {}
end

function QSBArgsRandom:getDatasByPriority(priority)
	for i,t in ipairs(self._format_data) do
		if t.priority == priority then
			return t
		end
	end
	--没找到就造一个
	local tab = {["priority"] = priority,datas = {}}
	table.insert(self._format_data,tab)
	return tab
end

function QSBArgsRandom:sortDatasByPriority()
	table.sort(self._format_data,function(a,b) return a.priority > b.priority end)
end

--格式化输入的内容 使其更加容易被按照规则随机
function QSBArgsRandom:formatInput()
	if self._info.randomType == "range" then
		return
	end
	self._format_data = {}
	self._interval_cache = {}
	local formats = self._input.formats
	for i,data in ipairs(self._input.datas) do
		local fdata = {}
		fdata.data = data
		local format = formats[i]
		if format == nil then
			format = formats[#formats]
		end

		if type(format) == "number" then
			fdata.weight = format
			fdata.replace_interval = 0
			fdata.priority = 1
		elseif type(format) == "table" then
			fdata.weight = format.weight or 1
			fdata.replace_interval = format.replace_interval or 0
			fdata.priority = format.priority or 1
		else
			assert(false,"unknown format type:"..type(format))
		end
		local tab = self:getDatasByPriority(fdata.priority)
		table.insert(tab.datas,fdata)
	end
	self:sortDatasByPriority()
end

function QSBArgsRandom:updateInterval()
	for k,v in pairs(self._interval_cache) do
		if v > 0 then
			self._interval_cache[k] = v -1
		end
		if self._interval_cache[k] <= 0 then
			self._interval_cache[k] = nil
		end
	end
end

function QSBArgsRandom:getRangeValue()
	local result = {}
	local range_start = self._input.datas[1]
	local range_end = self._input.datas[2]
	for i = 1,self._info.count,1 do
		result[i] = app.random(range_start,range_end)
	end
	return result
end

function QSBArgsRandom:getCurrentPriorityIndex()
	for i,formats in ipairs(self._format_data) do
		local all_data = {}
		local total_weight = 0
		for _,v in ipairs(formats.datas) do
			if self._interval_cache[v] == nil or self._interval_cache[v] <= 0 then
				total_weight = total_weight + v.weight
				table.insert(all_data,v)
			end
		end
		if #all_data > 0 then
			return i,all_data,total_weight
		end
	end
	return -1
end

function QSBArgsRandom:getOne(list,total_weight)
	local r = 0
	local random = app.random(total_weight)
	for _,obj in ipairs(list) do
		if random > r and random <= r + obj.weight then
			return obj
		end
		r = r + obj.weight
	end
end

function QSBArgsRandom:getListValue()
	local result = {}
	for i = 1,self._info.count,1 do
		local idx,datas,total_weight = self:getCurrentPriorityIndex()
		if idx == -1 then
			break
		end
		local vget = self:getOne(datas,total_weight)
		if vget ~= nil then
			self:updateInterval()
			result[i] = vget.data
			self._interval_cache[vget] = vget.replace_interval
		end
	end
	return result
end

function QSBArgsRandom:getRandomValue()
	if self._info.randomType == "range" then
		return self:getRangeValue()
	elseif self._info.randomType == "list" then
		return self:getListValue()
	else
		assert(false,"unknown random type:"..self._info.randomType)
	end
end

function QSBArgsRandom:outputRandomValue(value)
	local outType = self._output.output_type
	local output = nil
	if outType == "auto" then
		if self._info.randomType == "list" then
			output = value
		elseif self._info.randomType == "range" then
			output = value[1]
		end
	elseif outType == "table" then
		output = value
	elseif outType == "data" then
		output = value[1]
	else
		assert(false,"unknown output type:"..outType)
	end
	self:finished({select = output})
end

function QSBArgsRandom:_execute(dt)
	self:formatInput()
	local value = self:getRandomValue()
	self:outputRandomValue(value)
end

return QSBArgsRandom