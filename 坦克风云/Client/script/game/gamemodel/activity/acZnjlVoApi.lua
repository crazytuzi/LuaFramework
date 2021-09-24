acZnjlVoApi = {
    jlPlayer = nil, --幸运锦鲤名单
}

function acZnjlVoApi:getAcVo()
    if self.vo == nil then
        self.vo = activityVoApi:getActivityVo("znjl")
    end
    return self.vo
end

function acZnjlVoApi:updateData(data)
    local vo = self:getAcVo()
    vo:updateData(data)
    activityVoApi:updateShowState(vo)
end
function acZnjlVoApi:updateSpecialData(data)
    local vo = self:getAcVo()
    if vo then
        vo:updateSpecialData(data)
    end
end
function acZnjlVoApi:getVersion( )
    local vo = self:getAcVo()
    if vo and vo.version then
        return vo.version
    end
    return 1
end

function acZnjlVoApi:getTimeStr()
    local str = ""
    local vo = self:getAcVo()
    if vo then
        local activeTime = vo.et - 86400 - base.serverTime > 0 and G_formatActiveDate(vo.et - 86400 - base.serverTime) or nil
        if activeTime == nil then
            activeTime = getlocal("serverwarteam_all_end")
        end
        return getlocal("activityCountdown") .. ":"..activeTime
    end
    return str
end

function acZnjlVoApi:getRewardTimeStr()
    local str = ""
    local vo = self:getAcVo()
    if vo then
        local activeTime = G_formatActiveDate(vo.et - base.serverTime)
        if self:isRewardTime() == false then
            activeTime = getlocal("notYetStr")
        end
        return getlocal("sendReward_title_time")..activeTime
    end
    return str
end

--是否处于领奖时间
function acZnjlVoApi:isRewardTime()
    local vo = self:getAcVo()
    if vo then
        if base.serverTime > vo.acEt - 86400 and base.serverTime < vo.acEt then
            return true
        end
    end
    return false
end

--是否可以拉取锦鲤名单数据（领奖时间6分钟延迟10秒后拉取）
function acZnjlVoApi:canPullJlPlayer()
    local vo = self:getAcVo()
    if vo then
        if base.serverTime >= (vo.acEt - 86400 + 370) and base.serverTime < vo.acEt then
            return true
        end
    end
    return false
end

function acZnjlVoApi:isToday()
    local flag = true
    local vo = self:getAcVo()
    if vo and vo.lastTime then
        flag = G_isToday(vo.lastTime)
    end
    return flag
end

function acZnjlVoApi:isEnd()
    local vo = self:getAcVo()
    if vo and base.serverTime < vo.et then
        return false
    end
    return true
end

function acZnjlVoApi:canReward()
    local vo = self:getAcVo()
    if vo == nil then
        return false
    end
    if self:isRewardTime() == true then
        do return false end
    end
    local flag,num = acZnjlVoApi:hasReward()
    if self:getVersion() == 2 then
        if num == 2 then
            return true
        elseif num == 0 or num ==1 then
            return false
        end
    end
    return not flag
end

--幸运锦鲤大奖
function acZnjlVoApi:getLuckyReward()
    local vo = self:getAcVo()
    if vo == nil then
        do return {} end
    end
    return FormatItem(vo.activeCfg.koiReward, nil, true)
end

--每日福利大奖
function acZnjlVoApi:getDailyReward()
    local vo = self:getAcVo()
    if vo == nil then
        do return {} end
    end
    return FormatItem(vo.activeCfg.dailyReward, nil, true)
end

--是否可以领取奖励
function acZnjlVoApi:hasReward()
    local vo = self:getAcVo()
    if vo == nil then
        return true
    end
    if self:isToday() == false then
        vo.rewardFlag = 0
    end
    if self:getVersion() == 2 then
        if vo.rewardFlag then
            if tonumber(vo.rewardFlag) == 2 then
                return false,2
            elseif tonumber(vo.rewardFlag) == 1 then
                return true,1
            end
        end
    else
        if vo.rewardFlag and tonumber(vo.rewardFlag) == 1 then
            return true
        end
    end
    return false,0
end

function acZnjlVoApi:IsRechargeReturnNum( )
    local vo = self:getAcVo()
    if vo and vo.rewardFlag then
        return vo.rewardFlag == 0 and 0 or 1
    end
    return 0
end

function acZnjlVoApi:resetDailyReward()
    local vo = self:getAcVo()
    if vo then
        vo.rewardFlag = 0
        vo.lastTime = base.serverTime
    end
end

--获取每日奖励
function acZnjlVoApi:getRewardRequest(callback)
    local function handler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.znjl then
                self:updateData(sData.data.znjl)
                if callback then
                    callback()
                end
            end
        end
    end
    socketHelper:acZnjlRewardRequest(handler)
end

--获取每日奖励
function acZnjlVoApi:znjlGet(callback)
    --已经有锦鲤名单或者还没有生成锦鲤名单时不需要拉取数据
    if self.jlPlayer or self:canPullJlPlayer() == false then
        if callback then
            callback()
        end
        do return end
    end
    local function handler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.log then
                self.jlPlayer = sData.data.log
            end
            if callback then
                callback()
            end
        end
    end
    socketHelper:acZnjlGet(handler)
end

--是否有资格成为锦鲤
function acZnjlVoApi:hasQualification()
    local vo = self:getAcVo()
    if vo and vo.qualification and tonumber(vo.qualification) == 1 then
        return true
    end
    return false
end

--获取豪华大礼总价值
function acZnjlVoApi:getRewardValue()
    local vo = self:getAcVo()
    if vo and vo.activeCfg and vo.activeCfg.rewardValue then
        return vo.activeCfg.rewardValue
    end
    return 0
end

--获取锦鲤名单
function acZnjlVoApi:getJlPlayer()
    return self.jlPlayer
end

function acZnjlVoApi:getJlPlayerShowStr()
    local str
    local cmd = self:getVersion() == 2 and "znsd" or "znjl"
    if self:canPullJlPlayer() == true then
        local jlPlayer = self:getJlPlayer()
        if jlPlayer then
            local zid, nameStr = jlPlayer.zid, jlPlayer.nickname
            if zid and nameStr then
                local zidStr = GetServerNameByID(zid, true)
                str = getlocal("activity_"..cmd.."_tip5", {zidStr, nameStr})
            end
        end
    else
        if self:hasQualification() == true then
            str = getlocal("activity_"..cmd.."_tip4")
        else
            str = getlocal("activity_"..cmd.."_tip3")
        end
    end
    if str == nil then
        str = getlocal("activity_"..cmd.."_tip3")
    end
    return str
end

function acZnjlVoApi:addActivieIcon()
    if self:getVersion() == 1 then
        spriteController:addPlist("public/activeCommonImage2.plist")
        spriteController:addTexture("public/activeCommonImage2.png")
    else
        spriteController:addPlist("public/activeCommonImage3.plist")
        spriteController:addTexture("public/activeCommonImage3.png")
    end
end

function acZnjlVoApi:removeActivieIcon()
    if self:getVersion() == 1 then
        spriteController:removePlist("public/activeCommonImage2.plist")
        spriteController:removeTexture("public/activeCommonImage2.png")
    else
        spriteController:removePlist("public/activeCommonImage3.plist")
        spriteController:removeTexture("public/activeCommonImage3.png")
    end
end

function acZnjlVoApi:setQualification()
    local vo = self:getAcVo()
    if vo then
        vo.qualification = 1
    end
end

function acZnjlVoApi:clearAll()
    self.vo = nil
    self.jlPlayer = nil
end
