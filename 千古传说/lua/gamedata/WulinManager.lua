--[[
******活动管理*******

	-- by Stephen.tao
	-- 2011/1/14
]]


local WulinManager = class("WulinManager")
local WulinConfig = require('lua.table.wulin_config')

function WulinManager:ctor(data)
	self.list = TFArray:new()
end
--活动管理器清空
function WulinManager:restart()
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
function WulinManager:AddNormalActivity()
	for v in WulinConfig:iterator() do
		if v.level <= MainPlayer:getLevel() then
			if self.list:indexOf(v) == -1 then
				self.list:push(v)
			end
		end
	end
	self.list:sort(sortlist)
end

--获取活动列表
function WulinManager:getlist()
	return self.list
end
--通过id获得当前所在的index
function WulinManager:getIndexById(id)
	local data = WulinConfig:objectByID(id)
	if data == nil then
		print("功能未开放 ，id == "..id)
		return nil
	end
	local index = WulinConfig:indexOf(data)
	return index
end


WulinManager.TAP_ZhengBaSai     = 1;

--显示某个活动界面
function WulinManager:showLayer(index)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activity.WulinLayer");
    layer:loadData(index)
    AlertManager:show()
end

return WulinManager:new()