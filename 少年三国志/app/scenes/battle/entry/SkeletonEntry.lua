-- SkeletonEntry

local SkeletonEntry = class("SkeletonEntry", require "app.scenes.battle.entry.SpEntry")

function SkeletonEntry:ctor(spJson, objects, battleField, eventHandler, jumpToEvent, repeated)

    local spId = spJson.spId
    local spFilePath = "battle/boss/"..spId.."/"..spId
    
    local spJsonName = spFilePath..".json"
    self._spJsonContent = self:getJson(spJsonName) or decodeJsonFile(spJsonName)
    self:setJson(spJsonName, self._spJsonContent)

    self._spJsonName = spJsonName

    -- 这里的node是基础节点, 默认基础节点的位置是在屏幕中心
    self._node = display.newNode()
    self._node:setCascadeOpacityEnabled(true)
    self._node:setCascadeColorEnabled(true)
    self._node:retain()
    
    -- 加载资源
    if self._spJsonContent.png or CCFileUtils:sharedFileUtils():isFileExist(CCFileUtils:sharedFileUtils():fullPathForFilename(spFilePath..".png")) then
        display.addSpriteFramesWithFile(spFilePath..".plist", spFilePath..".png")
    end
    
    SkeletonEntry.super.super.ctor(self, spJson, objects, battleField, eventHandler)
    
    self:initWithSpJson(spJson)
    
    -- 用来保存sp的数组
    self._spArr = {}
    
    -- 用来保存spStep数据用数组
    self._spStepArr = {}
    
    -- 是否是永久播放
    local events = self._spJsonContent.events
    if events then
        for k, v in pairs(events) do
            self.isForever = v == "forever"
        end
    end
    
    -- 默认的colorOffset
    self._colorOffset = {0, 0, 0, 0}
    setmetatable(self._colorOffset, {__index = function(t, k)
        if k == "r" then return t[1]
        elseif k == "g" then return t[2]
        elseif k == "b" then return t[3]
        elseif k == "a" then return t[4]
        end
    end})
    
    self._colorOffset.set = function(r, g, b, a)
        self._colorOffset[1] = r
        self._colorOffset[2] = g
        self._colorOffset[3] = b
        self._colorOffset[4] = a
    end
    
    self:jumpToDefaultEvent(jumpToEvent or "ready", repeated == nil and true or repeated)
    
    self.isSkeleton = true
    
end

function SkeletonEntry:initEntry()
    
    SkeletonEntry.super.super.initEntry(self)

    if self._spArr then
        for k, sp in pairs(self._spArr) do
            if sp.isEntry then
--                sp:initEntry()
                if sp:getObject():getParent() then
                    sp:getObject():removeFromParent()
                end
            else
                if sp.clipNode and sp.clipNode:getParent() then
                    sp.clipNode:removeFromParent()
                elseif sp:getParent() then
                    sp:removeFromParent()
                end
            end
        end
    end
    
    -- 清理sp的step函数
    self._spStepArr = {}
    
    -- 这里套一层接收事件，目的是为了隐藏诸如attack_stop, cont_stop这种骨骼动画内部的事件，改成对外通用的事件finish，不需要外部关心内部实现
    self:addEntryToQueue(self, self.update, function(event, ...)
        if self._eventHandler then
            self._eventHandler((event == "attack_stop" or event == "cont_stop" or event == "dead_stop") and "finish" or event, ...)
        end
    end)
    
end

-- 根据所选帧数判断当前已保存的节点是否存在并且是否是entry，如果有就初始化(initEntry)
function SkeletonEntry:initEntryAtFrame(frameIndex)
    for k, v in pairs(self._spJsonContent) do
        if v["f"..frameIndex] and self._spArr[k] and self._spArr[k].isEntry then
            self._spArr[k]:initEntry()
        end
    end
end

function SkeletonEntry:getData() return self._spJsonContent end

function SkeletonEntry:update(frameIndex)

    -- 跳转至某一帧
    if self._jumpTo then
        self._jumpTo = false
        
        self:initEntryAtFrame(self._eventStartFrame)
        
        -- 马上播开始帧
        SkeletonEntry.super.update(self, self._eventStartFrame)
        -- 然后跳到下一帧
        return false, "jumpTo", {self._eventStartFrame+1}
    elseif frameIndex == self._eventFinishFrame+1 then
        if self._ended then
            return true
        elseif not self._repeated then
            self:jumpTo(self._defaultEvent, true)
        end
        
        SkeletonEntry.super.update(self, self._eventStartFrame)
        return false, "jumpTo", {self._eventStartFrame+1}
    end
    
    local finish, event = SkeletonEntry.super.update(self, frameIndex)
    return finish, event
    
end

function SkeletonEntry:jumpTo(eventName, repeated, ended)
    
    local events = self._spJsonContent.events
    local eventFinishName = eventName.."_stop"
    
    local eventStartFrame = nil
    local eventFinishFrame = nil
    for k, v in pairs(events) do
        if v == eventName then
            eventStartFrame = tonumber(string.sub(k, 2))
        elseif v == eventFinishName then
            eventFinishFrame = tonumber(string.sub(k, 2))
        end
    end
    assert(eventStartFrame and eventFinishFrame, "There is not event frame with name: "..eventName)
    
    self._eventStartFrame = eventStartFrame
    self._eventFinishFrame = eventFinishFrame
    self._repeated = repeated
    self._ended = ended
    
    self._jumpTo = true
    
    return function(frameIndex)
        return frameIndex+eventStartFrame == eventFinishFrame
    end
    
end

function SkeletonEntry:setDefaultEvent(event)
    self._defaultEvent = event
end

function SkeletonEntry:jumpToDefaultEvent(event, repeated)
    self:setDefaultEvent(event)
    self:jumpToEvent(event, repeated)
end

function SkeletonEntry:jumpToAppear(repeated) return self:jumpTo("appear", repeated) end
function SkeletonEntry:jumpToReady(repeated) return self:jumpTo("ready", repeated) end
function SkeletonEntry:jumpToAttack(repeated) return self:jumpTo("attack", repeated) end
function SkeletonEntry:jumpToCont(repeated) return self:jumpTo("cont", repeated) end
function SkeletonEntry:jumpToHit(repeated) return self:jumpTo("behit", repeated) end
function SkeletonEntry:jumpToDead(repeated) return self:jumpTo("dead", repeated, true) end

function SkeletonEntry:jumpToEvent(event, repeated) return self:jumpTo(event, repeated) end

return SkeletonEntry

