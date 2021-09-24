acJjzzVoApi = {
}

function acJjzzVoApi:getAcVo()
    return activityVoApi:getActivityVo("jjzz")
end

function acJjzzVoApi:setActiveName(name)
    self.name = name
end

function acJjzzVoApi:getActiveName()
    return self.name or "jjzz"
end

function acJjzzVoApi:getTimeStr()
    local str = ""
    local vo = self:getAcVo()
    if vo then
        local activeTime = vo.et - base.serverTime > 0 and G_formatActiveDate(vo.et - base.serverTime) or nil
        if activeTime == nil then
            activeTime = getlocal("serverwarteam_all_end")
        end
        return getlocal("activityCountdown") .. ":"..activeTime
    end
    return str
end

function acJjzzVoApi:updata(data)
    local vo = self:getAcVo()
    vo:updateData(data)
    activityVoApi:updateShowState(vo)
end

function acJjzzVoApi:isToday()
    local isToday = false
    local vo = self:getAcVo()
    if vo and vo.t then
        isToday = G_isToday(vo.t)
    end
    return isToday
end

function acJjzzVoApi:getCost()
    local vo = self:getAcVo()
    local cfg = vo.acCfg.heroList[vo.key[1]][vo.key[2]]
    return cfg.cost1, cfg.cost2
end

function acJjzzVoApi:getMultiNum()
    local vo = self:getAcVo()
    if vo and vo.acCfg then
        return vo.acCfg.count or 10
    end
    return 10
end

function acJjzzVoApi:canReward()
    return false
end

function acJjzzVoApi:getHexieReward()
    local acVo = self:getAcVo()
    if acVo and acVo.acCfg then
        local hxcfg = acVo.acCfg.hxcfg
        if hxcfg then
            return FormatItem(hxcfg.reward)[1]
        end
    end
    return nil
end

function acJjzzVoApi:isEnd()
    local vo = self:getAcVo()
    if vo and base.serverTime < vo.et then
        return false
    end
    return true
end

function acJjzzVoApi:addActivieIcon()
    spriteController:addPlist("public/activeCommonImage3.plist")
    spriteController:addTexture("public/activeCommonImage3.png")
end

function acJjzzVoApi:removeActivieIcon()
    spriteController:removePlist("public/activeCommonImage3.plist")
    spriteController:removeTexture("public/activeCommonImage3.png")
end

