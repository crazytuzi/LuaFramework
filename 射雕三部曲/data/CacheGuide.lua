--[[
文件名:CacheGuide.lua
描述：新手引导数据抽象类型
创建人：liaoyuangang
创建时间：2016.05.09
--]]

local CacheGuide = class("CacheGuide", {})

function CacheGuide:ctor()
	self.mGuideInfo = {}
end

function CacheGuide:reset()
	self.mGuideInfo = {}
end

-- 更新新手引导信息
function CacheGuide:updateGuideInfo(guideInfo)
    for key, value in pairs(guideInfo or {}) do
        self.mGuideInfo[tonumber(key)] = value
    end
end

-- 获取新手引导信息
function CacheGuide:getGuideInfo()
    return clone(self.mGuideInfo)
end

return CacheGuide