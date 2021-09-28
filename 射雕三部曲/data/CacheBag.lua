--[[
文件名:CacheBag.lua
描述：背包数据抽象类型
创建人：liaoyuangang
创建时间：2016.05.09
--]]

-- 背包数据说明
--[[
    服务器返回的背包的数据，每条格式格式为：
    {
        BagModelId = 1001, -- 背包类型ID
        Size = 100,      -- 背包大小
        ExpandNum = 100, -- 背包扩展次数
    },
]]

local CacheBag = class("CacheBag", {})

--[[
]]
function CacheBag:ctor()
    -- 服务器返回背包信息的原始数据
    self.mBagInfo = {}
    -- 已背包模型Id为key的背包信息列表
    self.mIdList = {}
end

-- 清空管理对象中的数据
function CacheBag:reset()
   self.mBagInfo = {}
   self.mIdList = {}
end

-- 刷新背包信息辅助缓存，主要用于数据获取时效率优化
function CacheBag:refreshAssistCache()
    self.mIdList = {}

    for index, item in pairs(self.mBagInfo) do
        self.mIdList[item.BagModelId] = item
    end
end

-- 设置背包信息，其中每条数据包含的字段参考文件头部的“背包数据说明”
function CacheBag:setBagInfo(bagInfo)
    self.mBagInfo = bagInfo or {}
    self:refreshAssistCache()
end

--- 获取全部背包信息，返回值中每条数据包含的字段参考文件头部的“背包数据说明”
function CacheBag:getAllBagInfo(needClone, needIndex)
    if needIndex then
        return needClone and clone(self.mIdList) or self.mIdList
    else
        return needClone and clone(self.mBagInfo) or self.mBagInfo
    end
end

--- 获取某一种背包的信息
--[[
-- 参数
    bagModelId: 背包类型模型Id
-- 返回值数据包含的字段参考文件头部的“背包数据说明”
 ]]
function CacheBag:getBagInfo(bagModelId)
    return self.mIdList[bagModelId]
end

--- 修改某种背包的背包信息
--[[
-- 参数
    bagInfo: 数据包含的字段参考文件头部的“背包数据说明”
 ]]
function CacheBag:modifyBagInfo(bagInfo)
    if not bagInfo or not bagInfo.BagModelId then
        return
    end
    for index, item in pairs(self.mBagInfo) do
        if item.BagModelId == bagInfo.BagModelId then
            self.mBagInfo[index] = bagInfo
        end
    end

    self:refreshAssistCache()
end

return CacheBag