acJtxlhVoApi = {}

function acJtxlhVoApi:getAcVo()
    if self.vo == nil then
        self.vo = activityVoApi:getActivityVo("jtxlh")
    end
    return self.vo
end

function acJtxlhVoApi:getVersion()
    local vo = self:getAcVo()
    if vo and vo.version then
        return vo.version
    end
    return 1 --默认
end

function acJtxlhVoApi:getTimeStr()
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

function acJtxlhVoApi:updateData(data)
    local vo = self:getAcVo()
    vo:updateData(data)
    activityVoApi:updateShowState(vo)
end

function acJtxlhVoApi:isToday()
    local isToday = false
    local vo = self:getAcVo()
    if vo and vo.lastTime then
        isToday = G_isToday(vo.lastTime)
    end
    return isToday
end

function acJtxlhVoApi:canReward()
    local vo = self:getAcVo()
    if vo == nil then
        return false
    end
    return false
end

function acJtxlhVoApi:isEnd()
    local vo = self:getAcVo()
    if vo and base.serverTime < vo.et then
        return false
    end
    return true
end

--军团奖励数据
function acJtxlhVoApi:getAllianceReward(idx)
    local vo = self:getAcVo()
    if vo and vo.activeCfg and vo.activeCfg.allianceReward and vo.activeCfg.allianceReward[idx] then
        return FormatItem(vo.activeCfg.allianceReward[idx].reward, nil, true)
    end
    return {}
end

--个人奖励数据
function acJtxlhVoApi:getPersonalReward(idx)
    local vo = self:getAcVo()
    if vo and vo.activeCfg and vo.activeCfg.reward and vo.activeCfg.reward[idx] then
        return FormatItem(vo.activeCfg.reward[idx].reward, nil, true)
    end
    return {}
end

function acJtxlhVoApi:getRewardCfg()
    local vo = self:getAcVo()
    if vo and vo.activeCfg then
        return vo.activeCfg.allianceReward or {}, vo.activeCfg.reward or {}
    end
    return {}, {}
end

--充值数据（军团总充值，个人总充值）
function acJtxlhVoApi:getRecharge()
    local allianceRewardCfg, rewardCfg = self:getRewardCfg()
    local aRechargeLv, pRechargeLv = #allianceRewardCfg, #rewardCfg
    local aMaxRechargeNum, pMaxRechargeNum = allianceRewardCfg[aRechargeLv].recharge, rewardCfg[pRechargeLv].recharge
    local aRechargeNum, pRechargeNum = 0, 0
    local aRgs, pRgs = {}, {} --军团和个人的档位领取状态
    local vo = self:getAcVo()
    if vo then
        aRechargeNum, pRechargeNum = vo.arNum or 0, vo.prNum or 0
        aRgs, pRgs = vo.aRgs or {}, vo.pRgs or {}
    end
    return {aRechargeNum, aMaxRechargeNum, aRechargeLv, aRgs}, {pRechargeNum, pMaxRechargeNum, pRechargeLv, pRgs}
end

function acJtxlhVoApi:syncAllianceFlag(jtxlh)
    local vo = self:getAcVo()
    local myAlliance = allianceVoApi:getSelfAlliance()
    if vo and myAlliance and tonumber(myAlliance.aid) > 0 then
        local syncFlag = false
        local alReward = self:getRewardCfg()
        local aRechargeNum = tonumber(jtxlh.c or 0)
        for k, v in pairs(alReward) do
            if aRechargeNum >= tonumber(v.recharge) then --奖励已发放
                syncFlag = true
            end
        end
        if syncFlag == true then
            G_getAlliance(nil, false) --同步军团数据
        end
        local aid = tonumber(myAlliance.aid)
        local params = {aid = aid, uid = playerVoApi:getUid(), syncAlFlag = syncFlag}
        chatVoApi:sendUpdateMessage(58, params, aid + 1)
    end
end

function acJtxlhVoApi:getJtxlhData(callback)
    local function requestCallBack(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data and sData.data.jtxlh then
                self:updateData(sData.data.jtxlh)
            end
            if callback then
                callback()
            end
        end
    end
    socketHelper:acJtxlhRequest(requestCallBack)
end

function acJtxlhVoApi:getAllianceFlagInfo()
    local vo = self:getAcVo()
    if vo and vo.activeCfg then
        return vo.activeCfg.aFlag or {"i1", "if1"}
    end
end

--获取充值进度
function acJtxlhVoApi:getRewardPercentage()
    local percentage = {}
    local aRgdata, pRgdata = self:getRecharge()
    local aRgcfg, pRgcfg = self:getRewardCfg()
    for k = 1, 2 do
        local rechargeNum, numDuan = 0, 0
        local rechargeCfg = {}
        if k == 1 then
            rechargeNum = tonumber(aRgdata[1])
            numDuan = 2
            rechargeCfg = aRgcfg
        else
            rechargeNum = tonumber(pRgdata[1])
            numDuan = 4
            rechargeCfg = pRgcfg
        end
        local per = 0
        local everyPer = 100 / numDuan
        local duanIdex = 0
        for i = 1, numDuan do
            if rechargeNum <= rechargeCfg[i].recharge then
                duanIdex = i
                break
            end
        end
        if rechargeNum >= rechargeCfg[numDuan].recharge then
            per = 100
        elseif duanIdex == 1 then
            per = rechargeNum / rechargeCfg[1].recharge / numDuan * 100
        else
            local lastNeed, need = rechargeCfg[duanIdex - 1].recharge, rechargeCfg[duanIdex].recharge
            per = (duanIdex - 1) * everyPer + (rechargeNum - lastNeed) / (need - lastNeed) / numDuan * 100
        end
        percentage[k] = per
    end
    return percentage
end

--显示奖励面板
function acJtxlhVoApi:showRewardDialog(title, size, reward, layerNum, confirmCallback)
    require "luascript/script/game/scene/gamedialog/activityAndNote/acJtxlhSmallDialog"
    acJtxlhSmallDialog:showRewardDialog(title, size, reward, layerNum, confirmCallback)
end

function acJtxlhVoApi:clearAll()
    self.vo = nil
end

function acJtxlhVoApi:addActivieIcon()
    spriteController:addPlist("public/activeCommonImage2.plist")
    spriteController:addTexture("public/activeCommonImage2.png")
end
function acJtxlhVoApi:removeActivieIcon()
    spriteController:removePlist("public/activeCommonImage2.plist")
    spriteController:removeTexture("public/activeCommonImage2.png")
end
