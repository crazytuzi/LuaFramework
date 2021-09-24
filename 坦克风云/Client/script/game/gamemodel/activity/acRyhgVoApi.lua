--[[
活动荣耀回归 VoApi

@author JNK
]]
acRyhgVoApi = {}

function acRyhgVoApi:getAcVo()
	return activityVoApi:getActivityVo("ryhg")
end

function acRyhgVoApi:updateData(data)
    local vo = self:getAcVo()
    vo:updateData(data)
    activityVoApi:updateShowState(vo)
end

-- 是否有可领取状态
function acRyhgVoApi:canReward()
    return false
end

function acRyhgVoApi:isEnd()
    local vo = self:getAcVo()
    if vo and base.serverTime < vo.et then
        return false
    end
    return true
end

function acRyhgVoApi:getTimeStr()
    local str = ""
    local vo = self:getAcVo()
    if vo then
        local timeValue = vo.et - base.serverTime -- 要是有1天发奖励需要减 86400
        local activeTime = timeValue > 0 and G_formatActiveDate(timeValue) or nil
        if activeTime == nil then
            activeTime = getlocal("serverwarteam_all_end")
        end
        return getlocal("activityCountdown") .. ":" .. activeTime
    end
    return str
end

-- 设置激活码
function acRyhgVoApi:setFlybackCode(code)
    local key = "ryhg_FlybackCode"
    -- local key = "ryhg_FlybackCode" .. G_getUserPlatID()
    CCUserDefault:sharedUserDefault():setStringForKey(key, code)
    CCUserDefault:sharedUserDefault():flush()
end
-- 获取激活码
function acRyhgVoApi:getFlybackCode()
    local key = "ryhg_FlybackCode"
    -- local key = "ryhg_FlybackCode" .. G_getUserPlatID()
    local saveContent = CCUserDefault:sharedUserDefault():getStringForKey(key)
    return saveContent
end

function acRyhgVoApi:addActivieIcon()
    spriteController:addPlist("public/activeCommonImage2.plist")
    spriteController:addTexture("public/activeCommonImage2.png")
end

function acRyhgVoApi:removeActivieIcon()
    spriteController:removePlist("public/activeCommonImage2.plist")
    spriteController:removeTexture("public/activeCommonImage2.png")
end

function acRyhgVoApi:clearAll()
end