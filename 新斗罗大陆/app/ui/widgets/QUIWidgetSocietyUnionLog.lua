--[[	
	文件名称：QUIWidgetSocietyUnionLog.lua
	创建时间：2016-03-25 18:40:03
	作者：nieming
	描述：QUIWidgetSocietyUnionLog 宗门日志
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetSocietyUnionLog = class("QUIWidgetSocietyUnionLog", QUIWidget)
local QUIWidgetSocietyUnionLogSheet1 = import("..widgets.QUIWidgetSocietyUnionLogSheet1")
local QUIWidgetSocietyUnionLogSheet2 = import("..widgets.QUIWidgetSocietyUnionLogSheet2")
local QListView = import("...views.QListView")

--初始化
function QUIWidgetSocietyUnionLog:ctor(options)
	local ccbFile = "Widget_society_union_log.ccbi"
	local callBacks = {
	}
	QUIWidgetSocietyUnionLog.super.ctor(self,ccbFile,callBacks,options)
	--代码
	self._logs = {}
	self._data = {}

	if options then 
		self._data = options.data or {}
	end
end

--describe：onEnter 
function QUIWidgetSocietyUnionLog:onEnter()
	--代码
	self._isExit = true
	if (remote.user.userConsortia.consortiaId == nil or remote.user.userConsortia.consortiaId == "") then
		return
	end
	self:sortData()
	
	self:setInfo()
end

function QUIWidgetSocietyUnionLog:sortData()
	if self._data == nil or next(self._data) == nil then return end
    table.sort(self._data, function (x, y)
        return x.createdAt > y.createdAt
    end)

    local tempData
    self._logs = {}
    for k, v in ipairs(self._data) do
        local currentDate = q.date("%Y-%m-%d", v.createdAt/1000)
        if not tempData then
        	tempData = currentDate
        	table.insert(self._logs, {oType = "tag",value = currentDate})
        elseif tempData ~= currentDate then
        	tempData = currentDate
        	table.insert(self._logs, {oType = "tag",value = currentDate})
        end
        table.insert(self._logs, {oType = "data",value = v})

    end
    self:setInfo()
end

--describe：onExit 
function QUIWidgetSocietyUnionLog:onExit()
	--代码
	self._isExit = false
end

--describe：setInfo 
function QUIWidgetSocietyUnionLog:setInfo()
	--代码
	if not self._listView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local data = self._logs[index]
	            local item = list:getItemFromCache(data.oType)
	   
	            if not item then
	            	if data.oType == "tag" then
	            		item = QUIWidgetSocietyUnionLogSheet1.new()
	            	else
	            		item = QUIWidgetSocietyUnionLogSheet2.new()
	            	end
	                isCacheNode = false
	            end
	            
	            item:setInfo(data, index)
	            info.item = item
	            info.tag = data.oType
	            info.size = item:getContentSize()
	            return isCacheNode
	        end,
	        enableShadow = true,
	        totalNumber = #self._logs,
    	} 
    	self._listView = QListView.new(self._ccbOwner.listView,cfg)
    else
    	self._listView:reload({totalNumber = #self._logs}) 
	end
end

--describe：getContentSize 
--function QUIWidgetSocietyUnionLog:getContentSize()
	----代码
--end

return QUIWidgetSocietyUnionLog
