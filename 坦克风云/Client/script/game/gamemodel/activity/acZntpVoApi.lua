acZntpVoApi = {}

function acZntpVoApi:getAcVo()
    return activityVoApi:getActivityVo("zntp")
end

function acZntpVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage2.plist")
	spriteController:addTexture("public/activeCommonImage2.png")
end

function acZntpVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage2.plist")
	spriteController:removeTexture("public/activeCommonImage2.png")
end

function acZntpVoApi:getTimeStr()
    local vo = self:getAcVo()
    if vo then
        local activeTime = vo.et - base.serverTime > 0 and G_formatActiveDate(vo.et - base.serverTime) or nil
        if activeTime == nil then
            activeTime = getlocal("serverwarteam_all_end")
        end
        return getlocal("activityCountdown") .. ":" .. activeTime
    end
    return ""
end

--[[ 该活动没有领奖时间
function acZntpVoApi:getRewardTimeStr()
    local vo = self:getAcVo()
    if vo then
        local activeTime = G_formatActiveDate(vo.et - base.serverTime)
        if self:isRewardTime() == false then
            activeTime = getlocal("notYetStr")
        end
        return getlocal("onlinePackage_next_title") .. activeTime
    end
    return ""
end

--是否处于领奖时间
function acZntpVoApi:isRewardTime()
    local vo = self:getAcVo()
    if vo then
        if base.serverTime > vo.acEt - 86400 and base.serverTime < vo.acEt then
            return true
        end
    end
    return false
end
--]]

function acZntpVoApi:canReward()
    local vo = self:getAcVo()
    if vo and vo.taskList then
        for k, v in ipairs(vo.taskList) do
            if v.state and v.state == 1 then
                return true
            end
        end
    end
    return false
end

--获取任务列表数据 @ 领取状态 1:可领取 2:未达成 3:已领取
function acZntpVoApi:getTaskList()
	local vo = self:getAcVo()
	if vo and vo.taskList then
        return vo.taskList
	end
end

function acZntpVoApi:requestTaskReward(tid, callback)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                if sData.data.zntp then
                    self:updateData(sData.data.zntp)
                end
                if callback then
                    callback()
                end
            end
        end
    end
    socketHelper:acZntpTaskReward(tid, socketCallback)
end

function acZntpVoApi:updateData(data)
    if data then
        local vo = self:getAcVo()
        vo:updateData(data)
        activityVoApi:updateShowState(vo)
    end
end

function acZntpVoApi:clearAll()
	
end