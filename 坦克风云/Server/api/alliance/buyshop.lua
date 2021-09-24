function api_alliance_buyshop(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    -- 参数：type，为1的时候是购买个人商店的商品，为2的时候是购买全军团珍品中的商品
    -- 参数：id，商品的ID，例如 “i1”
    local id = request.params.id
    local action = request.params.type
    local uid = request.uid 
    local slot = request.params.slot

    if uid == nil or id == nil or action == nil then
        response.ret = -102
        return response
    end
    
    -- 军团商店已关闭
    if moduleIsEnabled('allianceshop') == 0 then
        response.ret = -4016 
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mProp = uobjs.getModel('props')    
    local mBag = uobjs.getModel('bag')

    -- 未加入军团
    if mUserinfo.alliance <= 0 then
        response.ret = -8012
        return response
    end

    -- 当前时间
    local ts = getClientTs()
    local allianceShopCfg = getConfig('allianceShopCfg')
    local weeTs = getWeeTs()
    local allianceActive = getConfig("alliance.allianceActive")
    local allianceActivePoint = getConfig("alliance.allianceActivePoint")
    local apoint =allianceActivePoint[3]
    local apointcount =allianceActive[3]
    if action == 1 then
        local lastRefreshTs = getWeeTs()        

        if ( mProp.allianceinfo.p.refreshAt or 0 ) < lastRefreshTs then
            mProp.allianceinfo.p = {}
            mProp.allianceinfo.p.refreshAt = ts
        end

        if (mProp.allianceinfo.p[id] or 0 ) >= allianceShopCfg.pShopItems[id].pBuyNum then
            response.ret = -4013
            return response
        end

        -- 购买普通商品
        local alliancestoreParams = {            
            aid=mUserinfo.alliance,
            uid=uid,
            useraising=allianceShopCfg.pShopItems[id].price,
            cdtime = allianceShopCfg.cdTime,    -- 加入军团超过此时间段才能购买
            lvl = allianceShopCfg.pShopItems[id].lv,    -- 物品解锁需要的军团等级
            weet=weeTs,ts=ts,ap=apoint,apc=apointcount
        }

        local useRaisingRet,useRaisingCode = M_alliance.alliancestore(alliancestoreParams)

        if not useRaisingRet then
            response.ret = useRaisingCode
            return response
        end

        mProp.allianceinfo.p[id] = ( mProp.allianceinfo.p[id] or 0 ) + 1
        if not takeReward(uid,allianceShopCfg.pShopItems[id].serverReward) then
            response.ret = -403
            return response
        end

        local log = {uid=uid,parmas=request.params,shop=allianceShopCfg.pShopItems[id].serverReward}
        writeLog(log,"allianceShop")

        response.data.alliancegetshop = mProp.allianceinfo.p
        response.data.alliance = useRaisingRet.data.alliance
    elseif action == 2 then
        
        local lastRefreshTs = M_alliance.getShopLastRefreshTs(allianceShopCfg.aShopRefreshTime,ts) 

        local shops = M_alliance.getShop(lastRefreshTs)

        if shops[slot] ~= id then
            response.ret = -4015
            return response
        end

        if ( mProp.allianceinfo.a.refreshAt or 0 ) < lastRefreshTs then
            mProp.allianceinfo.a = {}
            mProp.allianceinfo.a.refreshAt = ts
        end

        -- 此key用来标识每个位置上购买的物品信息，不同的位置是有可能刷出一样的东西的
        local buyKey = id .. '_' .. slot

        -- 个人购买珍品次数达到上限
        if (mProp.allianceinfo.a[buyKey] or 0 ) >= allianceShopCfg.aShopItems[id].pBuyNum  then
            response.ret = -4013
            return response
        end




        local alliancestoreParams = {
            aid=mUserinfo.alliance, -- 军团id
            uid=uid,    -- 用户id
            useraising=allianceShopCfg.aShopItems[id].price, -- 需要的贡献
            maxcount = allianceShopCfg.aShopItems[id].aBuyNum,  -- 军团能购买的次数
            rftime = lastRefreshTs,  -- 需要刷新珍品的时间
            prop = id,  -- 珍品id
            slot = slot,    -- 哪个位置的物品
            cdtime = allianceShopCfg.cdTime,    -- 加入军团超过此时间段才能购买
            weet=weeTs,ts=ts,ap=apoint,apc=apointcount
        }

        local useRaisingRet,useRaisingCode = M_alliance.alliancestore(alliancestoreParams)

        -- 军团购买次数达到上限/贡献不足
        if not useRaisingRet then
            response.ret = useRaisingCode
            return response
        end
        response.data.alliance = useRaisingRet.data.alliance
        -- 用户购买数量累加
        mProp.allianceinfo.a[buyKey] = ( mProp.allianceinfo.a[buyKey] or 0 ) + 1
        if not takeReward(uid,allianceShopCfg.aShopItems[id].serverReward) then
            response.ret = -403
            return response
        end

        local log = {uid=uid,parmas=request.params,shop=allianceShopCfg.aShopItems[id].serverReward}
        writeLog(log,"allianceShop")

        -- 珍品数据需要全军团推送
        if type(useRaisingRet.data.members) == 'table' then
            -- push -------------------------------------------------
            local cmd = 'alliance.buyshop.push'
            local data = {
                alliancebuyshoppush = {
                    slot = slot,
                    id = id,
                },
            }

            for _,v in pairs( useRaisingRet.data.members) do
                local mid = tonumber(v.uid) 
                if mid and mid ~= uid then
                    regSendMsg(mid,cmd,data)
                end
            end
            -- push -------------------------------------------------
        end
    elseif action==3 then
        -- 领地商店
        local lastRefreshTs = getWeeTs()

        if ( mProp.allianceinfo.s.refreshAt or 0 ) < lastRefreshTs then
            mProp.allianceinfo.s = {}
            mProp.allianceinfo.s.refreshAt = ts
        end

        if (mProp.allianceinfo.s[id] or 0 ) >= allianceShopCfg.sShopItems[id].pBuyNum then
            response.ret = -4013
            return response
        end

        -- 扣除 公海币
        local mTerritorymember = uobjs.getModel('atmember')
        if not mTerritorymember.useSeacoin(allianceShopCfg.sShopItems[id].price) then
            response.ret = -8409
            return response
        end

        -- 拉取军团数据
        local alliancestoreParams = {
            aid=mUserinfo.alliance,
            uid=uid,
            cdtime = allianceShopCfg.cdTime,    -- 加入军团超过此时间段才能购买
            -- lvl = allianceShopCfg.sShopItems[id].lv,    -- 物品解锁需要的军团等级
            weet=weeTs,ts=ts
        }

        -- 物品解锁需要的领地等级
        local needTerLvl = allianceShopCfg.sShopItems[id].lv
        local mAterritory = mTerritorymember.getTerritoryObj(true)
        local territoryLvl = (mAterritory and mAterritory.getMainLevel()) or 0
        if territoryLvl < needTerLvl then
            response.ret = -8060
            return response
        end

        local useRaisingRet,useRaisingCode = M_alliance.alliancestore(alliancestoreParams)

        if not useRaisingRet then
            response.ret = useRaisingCode
            return response
        end

        mProp.allianceinfo.s[id] = ( mProp.allianceinfo.s[id] or 0 ) + 1
        if not takeReward(uid,allianceShopCfg.sShopItems[id].serverReward) then
            response.ret = -403
            return response
        end

        local log = {uid=uid,parmas=request.params,shop=allianceShopCfg.sShopItems[id].serverReward}
        writeLog(log,"allianceShop")

        response.data.alliancegetshop = mProp.allianceinfo.s
        response.data.alliance = useRaisingRet.data.alliance        
    end
    --日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    --新的日常任务检测
    mDailyTask.changeNewTaskNum('s304',1)
    if uobjs.save() then        
        response.ret = 0
        response.msg = 'Success'
    end
        
    return response
end 