EventCountManager = EventCountManager or BaseClass()
function EventCountManager:__init()
    if EventCountManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

    EventCountManager.Instance = self

    self.eventCount = 0
    self.nowTimeEvent = 0
    self.nowTime = 0
    self.onTick = true
end


function EventCountManager:AddCount(count)
    -- self.eventCount = self.eventCount + count

    -- if Application.platform == RuntimePlatform.WindowsPlayer or Application.platform == RuntimePlatform.WindowsEditor then
    --     if self.eventCount > 130 then
    --         print(string.format("<color='#13fc60'>警告当前所在监听事件数量大于130,目前的监听事件数量为%s</color>",self.eventCount))
    --     end
    -- end
end

function EventCountManager:ReleseCount(count)
    -- self.eventCount = self.eventCount - count
    -- print(string.format("<color='#13fc60'>释放了监听事件数量%s</color>，当前事件总量为%s",count,self.eventCount))
end

function EventCountManager:FireCount(count)
    -- self.nowTimeEvent = self.nowTimeEvent + count

    -- if Application.platform == RuntimePlatform.WindowsPlayer or Application.platform == RuntimePlatform.WindowsEditor then
    --     if self.nowTimeEvent > 45 then
    --         print(string.format("<color='#ffff00'>警告同一时间(2s内)触发监听事件数量大于45,达到了%s目前总的已注册监听事件为%s</color>" ,self.nowTimeEvent,self.eventCount))
    --     end
    -- end
end