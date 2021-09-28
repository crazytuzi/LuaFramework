-- 成就数据
require("app.cfg.target_info")

local AchievementData = class("AchievementData")

function AchievementData:ctor()
    self._achievementData = {}
    self._achievementData.info = {}
    
    self._achievementData.contain = function(data)
        for i=1, #self._achievementData.info do
            if self._achievementData.info[i].t == data.t then
                return true
            end
        end
        return false
    end
    
    self._achievementData.replace = function(data)
        for i=1, #self._achievementData.info do
            if self._achievementData.info[i].t == data.t then
                self._achievementData.info[i] = data
            end
        end
    end
    
    self._achievementData.add = function(data)
        self._achievementData.info[#self._achievementData.info+1] = data
    end
    
    self._hasNew = nil
end

function AchievementData:setData(data)

    for i=1, #data.info do
        if self._achievementData.contain(data.info[i]) then
            self._achievementData.replace(data.info[i])
        else
            self._achievementData.add(data.info[i])
        end
    end
    self._hasNew = nil
end

function AchievementData:getData()
    local data = nil
    if self._achievementData then
        data = {info = {}}
        for i=1, #self._achievementData.info do
            local info = self._achievementData.info[i]
            local target = target_info.get(info.id)
            -- assert(target, "Could not find the target info with id: "..info.id)

            if target then
                if G_Me.userData.level >= target.show_level then
                    data.info[#data.info+1] = info
                end
            end
        end
    end
    
    return data
end

function AchievementData:hasNew()
    if self._achievementData and self._hasNew == nil then
        for i=1, #self._achievementData.info do
            local info = self._achievementData.info[i]
            if info.step == 2 then
                self._hasNew = true
                break
            end
        end
    end
    return self._hasNew
end

function AchievementData:reset()
    self._hasNew = false
end

return AchievementData