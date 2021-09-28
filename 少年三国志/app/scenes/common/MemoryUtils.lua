
local MemoryUtils =  class("MemoryUtils")

local GC_MAX_SECONDS = 300 
local GC_MAX_VM_KB = 25000
local GC_MAX_VM_SECONDS = 5



function MemoryUtils:ctor()
    self._lastGC = 0

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SCENE_CHANGED, self._onReceiveSceneChanged, self)

end

function MemoryUtils:_onReceiveSceneChanged()

    --print("mem on scene change ")
    self:tryGC()
end



--一定做一次GC
function MemoryUtils:forceGC(reason)
    collectgarbage("collect")
    trace("force gc, reason: " .. tostring(reason) .. "->" .. tostring(collectgarbage("count")))

    self._lastGC = FuncHelperUtil:getTickCount()
end

--尝试触发一次GC, 它会考虑2个因素
--上次GC时间 距离现在是否超过了  GC_MAX_SECONDS, 是的话马上GC
--上次GC时间 距离现在超过了GC_MAX_VM_SECONDS, 而且本次VM大小是否超过了 GC_MAX_VM_KB, 是的话马上GC
function MemoryUtils:tryGC()
    local elapsedTicks = FuncHelperUtil:getTickCount() - self._lastGC
    if elapsedTicks > GC_MAX_SECONDS*1000 then
        self:forceGC("gctime")
    elseif elapsedTicks > GC_MAX_VM_SECONDS*1000 then
        local mem = collectgarbage("count")
        if mem > GC_MAX_VM_KB then
            self:forceGC("too high vm mem: " .. tostring(mem))
        end
    end
end



return MemoryUtils
