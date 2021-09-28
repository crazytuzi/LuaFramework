local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
-----------------------------------------------------------------------------
local tOutputWay = getConfigItemByKey("PropOutputWay", "id")

-- 获取一条记录
record = function(self, id)
	return tOutputWay[id]
end
-----------------------------------------------------------------------------
-- 获得途径的名字
name = function(self, record)
	return record and tostring(record.showname) or ""
end

-- 获得途径的等级限制
lvLimit = function(self, record)
	return record and tonumber(record.level)
end

-- 获得途径的跳转界面
goto = function(self, record)
	return record and tostring(record.key) or ""
end
-----------------------------------------------------------------------------