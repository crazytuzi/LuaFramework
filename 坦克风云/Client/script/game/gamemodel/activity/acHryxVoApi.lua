
acHryxVoApi = {}

function acHryxVoApi:getAcVo()
	return activityVoApi:getActivityVo("hryx")
end

function acHryxVoApi:updateData(data)
    local vo = self:getAcVo()
    vo:updateData(data)
    activityVoApi:updateShowState(vo)
end

function acHryxVoApi:updateSpecialData(data)
    local vo = self:getAcVo()
    if vo then
        vo:updateSpecialData(data)
    end
end

function acHryxVoApi:getShoplist()
    local vo = self:getAcVo()
    if vo and vo.shoplist then
        return vo.shoplist
    end
    return {}
end

-- 获取版本
function acHryxVoApi:getVersion( ... )
    local vo = self:getAcVo()
    if vo and vo.version then
        return vo.version
    end
    return nil
end

function acHryxVoApi:getCurPicName(idx )
    local vo = self:getAcVo()
    local name = ""
    if vo and vo.exteriorId and vo.rankReward then
            name = idx ==1 and exteriorCfg.exteriorLit[vo.rankReward].decorateSp or exteriorCfg.exteriorLit[vo.exteriorId].decorateSp
    else
        print " =========== e r r o r in getCurPicName name is nil ============="
    end
    return name
end
function acHryxVoApi:getAddIcon( ... )
    local url = "acHryxSubIcon_v1.png"
    -- local version = self:getVersion()
    -- if version then
    --     if version == 1 then
    --         url = "130_basePic.png"
    --     elseif version == 2 then
    --         url = "sdly_basePic.png"
    --     elseif version == 3 then
    --         url = "xrfd_basePic.png"
    --     elseif version == 4 then
    --         url = "wlzc_basePic.png"
    --     end
    -- end
    return url
end

function acHryxVoApi:getShoplistSortKey()
    local voList = self:getShoplist()
    local voSortKey = {}
    for k, v in pairs(voList) do
        voSortKey[#voSortKey + 1] = k
    end

    -- 排序
    local ownGems = playerVoApi:getGems()
    table.sort(voSortKey, function(a, b)
        local item1 = voList[tonumber(a)]
        local item2 = voList[tonumber(b)]
        local canBuy1 = (ownGems >= item1.p)
        local canBuy2 = (ownGems >= item2.p)
        local limitMax1 = (self:getRd(tonumber(a)) >= item1.bn)
        local limitMax2 = (self:getRd(tonumber(b)) >= item2.bn)

        -- 购买次数上限
        if limitMax1 ~= limitMax2 then
            if limitMax1 then
                return false
            elseif limitMax2 then
                return true
            end
        end

        -- 可购买直接返回
        if canBuy1 ~= canBuy2 then
            if canBuy1 then
                return true
            elseif canBuy2 then
                return false
            end
        end

        return tonumber(a) < tonumber(b)
    end)

    return voSortKey
end

function acHryxVoApi:getPriceDis(idx)
    local shoplist = self:getShoplist()
    if shoplist and shoplist[idx] then
        return math.floor(shoplist[idx].p * shoplist[idx].dis) -- ceil向上取整 floor向下取整
    end
    return 0
end

function acHryxVoApi:getPrice(idx)
    local shoplist = self:getShoplist()
    if shoplist and shoplist[idx] then
        return shoplist[idx].p
    end
    return 0
end

-- 获得充值值
function acHryxVoApi:getV()
    local vo = self:getAcVo()
    if vo and vo.v then
        return vo.v
    end
    return 0
end

-- 道具购买记录
function acHryxVoApi:getRd(idx)
    local vo = self:getAcVo()
    if vo and vo.rd then
        return vo.rd["i" .. idx] or 0
    end
    return 0
end

-- 是否有可领取状态
function acHryxVoApi:canReward()
    return false
end

function acHryxVoApi:isEnd()
    local vo = self:getAcVo()
    if vo and base.serverTime < vo.et then
        return false
    end
    return true
end

function acHryxVoApi:getTimeStr()
    local str = ""
    local vo = self:getAcVo()
    if vo then
        local timeValue = vo.et - base.serverTime - 86400 -- 要是有1天发奖励需要减 86400
        local activeTime = timeValue > 0 and G_formatActiveDate(timeValue) or nil
        if activeTime == nil then
            activeTime = getlocal("serverwarteam_all_end")
        end
        return getlocal("activityCountdown") .. ":" .. activeTime
    end
    return str
end

function acHryxVoApi:getRewardTimeStr()
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
function acHryxVoApi:isRewardTime()
    local vo = self:getAcVo()
    if vo then
        if base.serverTime > vo.acEt - 86400 and base.serverTime < vo.acEt then
            return true
        end
    end
    return false
end

function acHryxVoApi:getNeedPlayerLv( )
    local vo = self:getAcVo()
    if vo and vo.unlockNeedPlayerlv then
        return vo.unlockNeedPlayerlv
    end
    return 100
end

function acHryxVoApi:getOpenDays( )
    local vo = self:getAcVo()
    local tt = vo.et - vo.st
    return math.ceil(tt /86400)
end

------------------------------------------  t a b 1 ------------------------------------------

function acHryxVoApi:getRechargeNeedLimit( )---上榜需要的充值金币数
    local vo = self:getAcVo()
    if vo and vo.picket then
        return vo.picket,vo.v--vo.v 已充值金币数
    end
    return 99999,0
end

function acHryxVoApi:socketRank(callback)--拿排行榜数据
    local function requestHandler(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.rankList then
                -- print(" I got ranklist now !!!")
                self:updateSpecialData(sData.data)
                if callback then
                    callback()
                end
            else
                print(" data is nil ????? ")
            end
        end
    end
    socketHelper:acHryxBuyexter(requestHandler,"list")
end

function acHryxVoApi:getRankList()
    local vo = self:getAcVo()
    if vo.rankList and SizeOfTable(vo.rankList) > 0 then
        return vo.rankList , SizeOfTable(vo.rankList) + 1
    end
    return {},0
end

function acHryxVoApi:getPlayerRank( )
    local vo = self:getAcVo()
    if vo.rankList and SizeOfTable(vo.rankList) > 0 then
        for k,v in pairs(vo.rankList) do
            if v[1] == playerVoApi:getPlayerName() and tonumber(v[4]) == playerVoApi:getUid() then
                return k,playerVoApi:getPlayerName(),tonumber(v[2]), tonumber(v[3])
            end
        end
    end
    local limit = self:getRechargeNeedLimit()
    local str = "5+"
    if tonumber(vo.v or 0) < limit then
        str = getlocal("dimensionalWar_out_of_rank")
    end
    return str, playerVoApi:getPlayerName(), playerVoApi:getPlayerPower(), vo.v or 0
end



function acHryxVoApi:addActivieIcon()
    spriteController:addPlist("public/activeCommonImage2.plist")
    spriteController:addTexture("public/activeCommonImage2.png")
    spriteController:addPlist("public/activeCommonImage3.plist")
    spriteController:addTexture("public/activeCommonImage3.png")
end

function acHryxVoApi:removeActivieIcon()
    spriteController:removePlist("public/activeCommonImage2.plist")
    spriteController:removeTexture("public/activeCommonImage2.png")
    spriteController:removePlist("public/activeCommonImage3.plist")
    spriteController:removeTexture("public/activeCommonImage3.png")
end

function acHryxVoApi:clearAll()
end