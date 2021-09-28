--[[
文件名:CacheZhenshouSlot.lua
描述：珍兽卡槽数据抽象类型
创建人：lengjiazhi
创建时间：2018.11.26
--]]


local CacheZhenshouSlot = class("CacheZhenshouSlot", {})

function CacheZhenshouSlot:ctor()
	-- 珍兽阵容列表的原始数据
	self.mZhenshouSlotList = {}
end

-- 清空管理对象中的数据
function CacheZhenshouSlot:reset()
	self.mZhenshouSlotList = {}
end

-- 设置珍兽阵容信息
function CacheZhenshouSlot:setZhenshouSlot(ZhenshouSlot)
	self.mZhenshouSlotList = ZhenshouSlot or {}
end

-- 获取珍兽阵容信息
function CacheZhenshouSlot:getSlotInfo(callback)
	if next(self.mZhenshouSlotList) == nil then
		self:requestGetInfo(callback)
	else
		if callback then
			callback(self.mZhenshouSlotList)
		end
	end
	return self.mZhenshouSlotList
end

--判断某一个珍兽是否上阵
--zhenshouId:实体id
function CacheZhenshouSlot:isCombat(zhenshouId)
	for i,v in ipairs(self.mZhenshouSlotList.CombatStr) do
		if v.ZhenShouId == zhenshouId then
			return true
		end
	end
	return false
end

--判断阵容中是否有相同的珍兽
function CacheZhenshouSlot:isSameZhenshouCombat(zhenshouModelId)
	local zhenshouInfo = ZhenshouObj:getZhenshouList()
	for _, slotItem in ipairs(self.mZhenshouSlotList.CombatStr) do
		for _, zhenshouItem in ipairs(zhenshouInfo) do
			if zhenshouItem.Id == slotItem.ZhenShouId then
				if zhenshouModelId == zhenshouItem.ModelId then
					return true
				end
			end
		end
	end
	return false
end

--根据实体id获取所在的卡槽id
function CacheZhenshouSlot:getSlotIdById(zhenshouId)
	for i,v in ipairs(self.mZhenshouSlotList.CombatStr) do
		if v.ZhenShouId == zhenshouId then
			return v.SlotId
		end
	end
end

--==============
-- 手动请求服务器数据
function CacheZhenshouSlot:requestGetInfo(callFunc)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "ZhenshouSlot",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function(response)
          	if not response or response.Status ~= 0 then
                return
            end
            
            if callFunc then 
          		callFunc(response.Value.ZhenShouSlotInfo)
          	end

          	self:setZhenshouSlot(response.Value.ZhenShouSlotInfo)
        end,
    })
end

return CacheZhenshouSlot