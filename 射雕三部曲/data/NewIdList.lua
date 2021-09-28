--[[
文件名:NewIdList.lua
描述：人物数据抽象类型
创建人：liaoyuangang
创建时间：2016.05.09
--]]

local NewIdList = class("NewIdList", {})

function NewIdList:ctor()
	self.mNewIdList = {}
end

-- 添加一个新物品实例Id
--[[
-- 参数
    instanceId: 物品的实例Id
]]
function NewIdList:insertNewId(instanceId)
	if not Utility.isEntityId(instanceId) then
		return
	end
    table.insert(self.mNewIdList, instanceId)
end

-- 清除对应新物品Id列表中值，如参数 instanceId 不为nil，则只把该instanceId从列表中清除，否则清除所有该类型
--[[
-- 参数
    instanceId: 物品的实例Id
]]
function NewIdList:clearNewId(instanceId)
	if instanceId then
        for index, item in pairs(self.mNewIdList) do
            if item == instanceId then
                table.remove(self.mNewIdList, index)
                break
            end
        end
    else
        self.mNewIdList = {}
    end
end

-- 判断某实例Id是否在新物品列表中
--[[
-- 参数
    instanceId: 物品的实例Id
]]
function NewIdList:IdIsNew(instanceId)
    return table.keyof(self.mNewIdList, instanceId or "")
end 

-- 判断某类型的新物品列表是否为空
function NewIdList:newIdListIsEmpty()
    return #self.mNewIdList == 0
end

-- 获取某类型的新物品Id列表
function NewIdList:getNewIdList()
    return self.mNewIdList
end

return NewIdList