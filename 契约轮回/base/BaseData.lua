--
-- Author: LaoY
-- Date: 2018-07-03 10:00:43
-- 数据基类

BaseData = BaseData or class("BaseData")
BaseData.EventNamePre = "bind_data_"
function BaseData:ctor()
	self.event = Event()
end

function BaseData:dctor()
	self:clear()
end

function BaseData:clear()
	self.event:RemoveAll()
end

function BaseData:GetValue(data_name)
	local value
	if string.find(data_name,"%.") then
		local data_name_list = string.split(data_name,".")
		local tab = self
		local len = #data_name_list
		for i=1, len-1 do
			local tab_name = data_name_list[i]
			tab = tab[tab_name]
		end
		if tab then
			value = tab[data_name_list[len]]
		end
	else
		value = self[data_name]
	end
    return value
end

function BaseData:AddListener(event,handler)
	return self.event:AddListener(event,handler)
end

function BaseData:RemoveListener(event_id)
	if not event_id then
		return
	end
	self.event:RemoveListener(event_id)
end

function BaseData:RemoveTabListener(tab)
	self.event:RemoveTabListener(tab)
end

function BaseData:Brocast(event,...)
	self.event:Brocast(event,...)
end

function BaseData:BrocastAll()
	-- 有可能在派发的时候又侦听，必须要复制出来，保证迭代不会出错
	local list = clone(self.event.events_map)
	-- 有可能会重复派发同一个事件，需要记录；或者换一个方式实现，略
	local brocast_list = {}
	for k,event_id in pairs(list) do
		if not brocast_list[event_id] then
			brocast_list[event_id] = true
			event_id = string.gsub(event_id,BaseData.EventNamePre,"")
			self:BrocastData(event_id)
		end
	end
end

function BaseData:BindData(data_name,handler)--"hp" , "handler()"
	local event = string.format("%s%s",BaseData.EventNamePre,data_name)
	return self:AddListener(event,handler)
end

--[[
	@author LaoY
	@des	
	@param3 ingore_update 是否不派发事件
--]]
function BaseData:ChangeData(data_name,value,ingore_update)
	local event_id = data_name
	if string.find(data_name,"%.") then
		local data_name_list = string.split(data_name,".")
		local tab = self
		local is_repeated = false
		local len = #data_name_list
		for i=1, len-1 do
			local tab_name = data_name_list[i]
			if tonumber(tab_name) then
				tab_name = tonumber(tab_name)
				if not is_repeated then
					is_repeated = true
				end
			end
			tab[tab_name] = tab[tab_name] or {}
			tab = tab[tab_name]
		end
		if tab then
			tab[data_name_list[len]] = value
		end
		if is_repeated then
			event_id = data_name_list[1]
		end
	elseif type(value) == "table" then
		self[data_name] = self[data_name] or {}
		table.RecursionMerge(self[data_name],value)
	else
		self[data_name] = value
	end
	if not ingore_update then
		self:BrocastData(event_id)
	end
end

function BaseData:BrocastData(data_name)
	local value = self:GetValue(data_name)
	if not value then
		return
	end
	local event = string.format("%s%s",BaseData.EventNamePre,data_name)
	self:Brocast(event,value)
end

-- 废弃 功能合并到ChangeData
function BaseData:ChangeTableData(table_name,data_name,value,...)
	if not self[table_name] then
		return
	end
	self[table_name][data_name] = value
	local event = string.format("%s%s.%s",BaseData.EventNamePre,table_name,data_name)
	self:Brocast(event,value,...)
end