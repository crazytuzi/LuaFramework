acNlgcVoApi = {
    name = "nlgc",
}

function acNlgcVoApi:getAcVo()
    return activityVoApi:getActivityVo("nlgc")
end

function acNlgcVoApi:setActiveName(name)
    self.name = name
end

function acNlgcVoApi:getActiveName()
    return self.name or "jjzz"
end

function acNlgcVoApi:getTimeStr()
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

function acNlgcVoApi:updateData(data)
    local vo = self:getAcVo()
    vo:updateData(data)
    activityVoApi:updateShowState(vo)
end

function acNlgcVoApi:isToday()
    local isToday = false
    local vo = self:getAcVo()
    if vo and vo.t then
        isToday = G_isToday(vo.t)
    end
    return isToday
end

function acNlgcVoApi:isFree()
    if self:isToday() == true then
        return false
    else
        return true
    end
end

function acNlgcVoApi:canReward()
    return false
end

function acNlgcVoApi:isEnd()
    local vo = self:getAcVo()
    if vo and base.serverTime < vo.et then
        return false
    end
    return true
end

function acNlgcVoApi:getActivePropInfo(key, id)
    local pinfo = {}
    if id == "a1" then
        pinfo.pic, pinfo.name, pinfo.desc = "ac_nlgc_item_icon.png", getlocal("ac_nlgc_item_name"), "ac_nlgc_item_desc"
    end
    return pinfo
end

function acNlgcVoApi:addActivieIcon()
    spriteController:addPlist("public/activeCommonImage3.plist")
    spriteController:addTexture("public/activeCommonImage3.png")
end

function acNlgcVoApi:removeActivieIcon()
    spriteController:removePlist("public/activeCommonImage3.plist")
    spriteController:removeTexture("public/activeCommonImage3.png")
end
