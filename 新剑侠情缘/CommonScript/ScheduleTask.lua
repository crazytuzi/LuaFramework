Require("CommonScript/lib.lua")
Lib.ScheduleTask = {}
local ScheduleTask = Lib.ScheduleTask

function ScheduleTask:LoadSetting()
    self.tbSetting = LoadTabFile("Setting/ScheduleTask.tab", "ss", "Name", {"Name", "OpenWeek"})
    for _, tb in pairs(self.tbSetting) do
    	if not tb.OpenWeek or tb.OpenWeek == "" then
    		tb.OpenWeek = nil
    	else
    		local tbParam = Lib:SplitStr(tb.OpenWeek, ";")
    		while true do
	    		if #tbParam ~= 2 then
	    			Log("[x] ScheduleTask:LoadSetting 1", tb.Name, tb.OpenWeek)
	    			tb.OpenWeek = {0}	--配置错误，强制关闭
	    			break
	    		end

	    		local nModulo = tonumber(tbParam[1]) or 0
	    		if nModulo <= 0 then
	    			Log("[x] ScheduleTask:LoadSetting 2", tb.Name, tb.OpenWeek, tbParam[1], nModulo)
	    			tb.OpenWeek = {0}
	    			break
	    		end

	    		local tbIdx = Lib:SplitStr(tbParam[2], ",")
	    		if #tbIdx <= 0 then
	    			Log("[x] ScheduleTask:LoadSetting 3", tb.Name, tb.OpenWeek, tbParam[2])
	    			tb.OpenWeek = {0}
	    			break
	    		end

	    		tb.OpenWeek = {nModulo, {}}
	    		for _, szIdx in ipairs(tbIdx) do
	    			tb.OpenWeek[2][tonumber(szIdx) or 0] = true
	    		end

	    		break
	    	end
    	end
    end
end
ScheduleTask:LoadSetting()

function ScheduleTask:IsOpenWeek(szName, nTime)
	if MODULE_ZONESERVER then
		return true
	end
	local tbSetting = self.tbSetting[szName]
	if not tbSetting then
		Log("[x] ScheduleTask:IsOpenWeek", szName)
		return false
	end

	if not tbSetting.OpenWeek then
		return true
	end

	local nModulo, tbIdx = unpack(tbSetting.OpenWeek)
	if nModulo <= 0 then
		return false
	end

	local nIdx = Lib:GetLocalWeek(nTime) % nModulo + 1
	return not not tbIdx[nIdx]
end

function ScheduleTask:IsOpenThisWeek(szName)
	return self:IsOpenWeek(szName, GetTime())
end
