--[[
文件名:CacheMarquee.lua
描述：走马灯数据抽象类型
创建人：liaoyuangang
创建时间：2016.05.09
--]]

-- 走马灯信息数据说明
--[[
-- 服务器返回的数据中，每个条目包含的字段如下
    {
        TemplateName:模板名 (运营类型消息模板为: System)
        Weight: 权重
        AriseNum:显示次数
        StarTime: 开始显示时间
        EndTime: 结束显示时间
        Content = {
            {
                ResourceTypeSub:资源类型Id
                Count:数量
                Value:值
            }
            ....
        }
    }
]]

local CacheMarquee = class("CacheMarquee", {})

function CacheMarquee:ctor()
	self.mMarqueeMessage = {}
end

function CacheMarquee:reset()
	self.mMarqueeMessage = {}
end

function CacheMarquee:updateMarquee(marqueeMessage)
	marqueeMessage = marqueeMessage or {}
    -- 服务器删除系统走马灯的情况（MarqueeMessage列表为空或MarqueeMessage中有系统走马灯信息）
    local needDelSys = false
    if #marqueeMessage == 0 then
        needDelSys = true
    else
        for index, item in pairs(marqueeMessage) do
            if item.TemplateName == "System" then
                needDelSys = true
                break
            end
        end
    end
    if needDelSys then
        for index = #self.mMarqueeMessage, 1, -1 do
            if self.mMarqueeMessage[index].TemplateName == "System" then
                table.remove(self.mMarqueeMessage, index)
            end
        end
    end

    for index, item in pairs(marqueeMessage) do
        table.insert(self.mMarqueeMessage, item)
    end
    table.sort(self.mMarqueeMessage, function(item1, item2)
        local weight1 = item1.Weight or 0
        local weight2 = item2.Weight or 0
        return weight2 > weight2
    end)
end

--- 获取一条走马灯信息
-- 走马灯的内容参考文件头部的 走马灯信息数据说明
function CacheMarquee:getMarqueeMessage(getScene)
    -- 如果还没有登录，则直接返回
    if not Player:dataIsInitiated() then
        return ""
    end

    -- 如果还在引导中页不用提示走马灯信息
    if Guide.manager:isInGuide() then
        return ""
    end

    local currTime = Player:getCurrentTime()

    local currScene = cc.Director:getInstance():getRunningScene()
    -- 如果不是当前scene，则返回空; 如果当前走马灯信息列表为空，则返回空
    if currScene ~= getScene or not self.mMarqueeMessage or #self.mMarqueeMessage == 0 then
        return ""
    end
    --dump(self.mMarqueeMessage, "self.mMarqueeMessage:")

    -- 当前需要播放的走马灯的index
    if not self.mShowMarqueeIndex or self.mShowMarqueeIndex > #self.mMarqueeMessage then
        self.mShowMarqueeIndex = 1
    end
    -- 如果列表中走马灯的播放权重都相同，则播放上次记录的条目，否则需要先播放权重高的条目
    local tempIndex = self.mShowMarqueeIndex
    if self.mMarqueeMessage[1].Weight > self.mMarqueeMessage[tempIndex].Weight then
        tempIndex = 1
    end
    -- 校正播放开始时间内的走马灯信息
    local foundOne = false
    for index = tempIndex, #self.mMarqueeMessage do
        if self.mMarqueeMessage[index].StarTime < currTime then
            tempIndex = index
            foundOne = true
            break
        end
    end
    if not foundOne then
        for index = 1, tempIndex do
            if self.mMarqueeMessage[index].StarTime < currTime then
                tempIndex = index
                foundOne = true
                break
            end
        end
    end
    if not foundOne then  -- 没有找到需要开始播放的条目
        return ""
    end

    local tempItem = self.mMarqueeMessage[tempIndex]
    local ret = clone(tempItem)
    -- 连续获取两条消息的间隔时间不能小于某个值，否则认为是同一次获取，暂定为1秒
    local timeTick = Player:getCurrentTime()
    if not self.mLastGetMsgTime or (timeTick - self.mLastGetMsgTime > 2) then
        self.mLastGetMsgTime = timeTick
        self.mShowMarqueeIndex = tempIndex + 1

        tempItem.AriseNum = tempItem.AriseNum - 1
        if tempItem.AriseNum < 1 or tempItem.EndTime < currTime then
            table.remove(self.mMarqueeMessage, tempIndex)
        end
    end
    return ret
end

return CacheMarquee
