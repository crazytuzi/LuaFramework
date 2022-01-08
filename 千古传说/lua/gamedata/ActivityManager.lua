--[[
******活动管理*******

	-- by Stephen.tao
	-- 2011/1/14
]]


local ActivityManager = class("ActivityManager")
local ActivityConfig = require('lua.table.activity_config')

function ActivityManager:ctor(data)
	self.list = TFArray:new()
end
--活动管理器清空
function ActivityManager:restart()
	self.list:clear()
end
--按照id排序
local function sortlist( v1,v2 )
	if v1.id < v2.id then
		return true
	end
	return false
end

--按照等级增加活动至列表
function ActivityManager:AddNormalActivity()
	for v in ActivityConfig:iterator() do
		if v.level <= MainPlayer:getLevel() then
			if self.list:indexOf(v) == -1 then
				self.list:push(v)
			end
		end
	end
	self.list:sort(sortlist)
end

--获取活动列表
function ActivityManager:getlist()
	return self.list
end
--通过id获得当前所在的index
function ActivityManager:getIndexById(id)
	local data = ActivityConfig:objectByID(id)
	if data == nil then
		print("功能未开放 ，id == "..id)
		return nil
	end
	local index = ActivityConfig:indexOf(data)
	return index
end


ActivityManager.TAP_Arena     = 1;
ActivityManager.TAP_Climb     = 2;
ActivityManager.TAP_EverQuest = 3;
ActivityManager.TAP_Carbon    = 4;
ActivityManager.TAP_FuMoLu    = 5;
ActivityManager.TAP_ShengNongKuang = 6;

--显示某个活动界面
function ActivityManager:showLayer(index)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activity.ActivityLayer");
    layer:loadData(index)
    AlertManager:show()
end

return ActivityManager:new()