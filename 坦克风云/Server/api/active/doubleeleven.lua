-- 双十一活动

function api_active_doubleeleven(request)
    local response = {
        ret=-1,
        msg="error",
        data={}
    }



    local uid = request.uid
    local action = request.params.action 
    local sid    = request.params.sid 
    local shop   = request.params.shop 
    local shophour= tonumber(request.params.shophour) or 0 
    local nexthang = tonumber(request.params.nexthang) or 0
    if uid == nil   then
        response.ret = -102
        return response
    end

    local ts = getClientTs()
    local weeTs = getWeeTs()
    local aname = 'double11'
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops = uobjs.getModel('troops')
    local mAccessory = uobjs.getModel('accessory')
    local mBag = uobjs.getModel("bag")
    local mHero= uobjs.getModel("hero")

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local activeCfg = mUseractive.getActiveConfig(aname)
    local weeTs = getWeeTs()
    local ts    = getClientTs()
    local hour = tonumber(getDateByTimeZone(ts,'%H'))
    local minute = tonumber(getDateByTimeZone(ts,'%M'))
    if shophour>0 then
        if hour~=shophour then
            response.ret=-102
            return response
        end
    end
    if mUseractive.info[aname].t~=weeTs then
        mUseractive.info[aname].qg={}
        mUseractive.info[aname].t=weeTs
    end
    
    -- 每天23:55就重置刮刮卷信息
    local yestodayTs = weeTs-300 -- 昨天23:55
    local todayTs = yestodayTs + 86400 -- 今天23:55
    local refreshTs,refreshSlot = yestodayTs,false
    mUseractive.info[aname].ggts = mUseractive.info[aname].ggts or 0
    -- 当前时间是昨天23:55之后，今天23:55之前
    if ts < todayTs and mUseractive.info[aname].ggts ~= yestodayTs then
        refreshTs = yestodayTs
        refreshSlot = true
    -- 当前世界是今天23:55之后
    elseif ts >= todayTs and mUseractive.info[aname].ggts ~= todayTs then
        refreshTs = todayTs
        refreshSlot = true
    end
    -- 需要刷新
    if refreshSlot then
        mUseractive.info[aname].ggts = refreshTs
        mUseractive.info[aname].gg = {}
        mUseractive.info[aname].dgem = {}
    end
    
    local redis = getRedis()
    local function getbuyinfo(action,shop,hour,id,method)
        

        local cachekey ="zid."..getZoneId().."."..aname.."ts"..mUseractive.info[aname].st.."shoid."
        local result={}
        if action=="getbuyShop" then
            for k,v in pairs(shop) do
                local item={}
                local cachekey ="zid."..getZoneId().."."..aname.."ts"..mUseractive.info[aname].st.."shoid."..k.."id."
                for ik,iv in pairs(v) do
                    local c =tonumber(redis:get(cachekey..ik))
                    if c==nil then
                        c=0
                    end
                    item[ik]=c
                end
                result[k]=item
            end
            return result
        end 

        if action=="buy" then
            local cachekey ="zid."..getZoneId().."."..aname.."ts"..mUseractive.info[aname].st.."shoid."..shop.."id."..sid
            local  result= tonumber(redis:incr(cachekey)) or 0
            redis:expire(cachekey,86400)
            return result
        end
        if action=="getbuy" then
            local cachekey ="zid."..getZoneId().."."..aname.."ts"..mUseractive.info[aname].st.."shoid."..shop.."id."..sid
            local  result= tonumber(redis:get(cachekey)) or 0
            return result
        end

        local cachekey ="zid."..getZoneId().."."..aname.."ts"..mUseractive.info[aname].st.."-"..weeTs.."-hour"..hour.."id."
        local result={}
        if action=='grab' then
            local  result= tonumber(redis:incr(cachekey..sid)) or 0
            redis:expire(cachekey..sid,86400)
            return result
        elseif action == "get" then
            local c =tonumber(redis:get(cachekey..sid))
            if c==nil then
                c=0
            end
            result=c
        else
            for k,v in pairs (shop) do
                local c =tonumber(redis:get(cachekey..k))
                if c==nil then
                    c=0
                end
                result[k]=c
            end
        end

        return result
    end
    if action=='getshop' then  --获取抢购商店信息
        if activeCfg.shopItems[shop]==nil then
            response.ret=-102
            return response
        end
        if hour<activeCfg.timeShow[1] or hour > activeCfg.timeShow[2] then
            response.ret=-102
            return response
        end 
        local info=getbuyinfo(action,activeCfg.shopItems[shop],hour)
        response.data[aname]=mUseractive.info[aname]
        response.data[aname].shop=info
        response.ret=0
        response.msg="Success"
        return response
    elseif action == "grab" then    -- 抢购
        
        if type(mUseractive.info[aname].qg["t"..hour])~='table' then  mUseractive.info[aname].qg["t"..hour]={} end
        local flag=table.contains(mUseractive.info[aname].qg["t"..hour], sid)
        --ptb:e(mUseractive.info[aname].qg[hour])
        if  flag then
            response.ret=-1993
            return response
        end
        if activeCfg.shopItems[shop]==nil then
            response.ret=-102
            return response
        end
        if hour<activeCfg.timeShow[1] or hour > activeCfg.timeShow[2] then
            response.ret=-1985
            return response
        end 
        if activeCfg.shopItems[shop][sid]==nil then
            response.ret=-102
            return response
        end

        local gemCost=activeCfg.shopItems[shop][sid].g
        if  gemCost ==nil  or  gemCost<=0 then
            response.ret=-102
            return response
        end
        if  not mUserinfo.useGem(gemCost) then
            response.ret = -109
            return response
        end

        local num=getbuyinfo('get',nil,hour,sid)
        response.data[aname]=mUseractive.info[aname]
        if num > activeCfg.shopItems[shop][sid].bn then
            local info=getbuyinfo("getshop",activeCfg.shopItems[shop],hour)
            response.data[aname].shop=info
            response.ret=-14006
            return response
        end
        local num=getbuyinfo(action,nil,hour,sid)
        if num > activeCfg.shopItems[shop][sid].bn then
            local info=getbuyinfo("getshop",activeCfg.shopItems[shop],hour)
            response.data[aname].shop=info
            response.ret=-14006
            return response
        end
        if not takeReward(uid,activeCfg.shopItems[shop][sid].sr) then
            response.ret = -403 
            return response
        end
        regActionLogs(uid,1,{action=101,item="",value=gemCost,params={buy={shop,sid}}})
        table.insert(mUseractive.info[aname].qg["t"..hour],sid)
        local info=getbuyinfo("getshop",activeCfg.shopItems[shop],hour)
        response.data[aname].shop=info
        if activeCfg.func[shop]=='hero' then
            response.data.hero =mHero.toArray(true)
            response.data.bag =mBag.toArray(true)
        end

    elseif action=="getbuyShop" then
        local info=getbuyinfo(action,activeCfg.buyShop,hour)
        response.data[aname]=mUseractive.info[aname]
        response.data[aname].buyshop=info
        response.ret=0
        response.msg="Success"
        return response
    elseif action == "buy" then     -- 购买
        if activeCfg.buyShop[shop]==nil then
            response.ret=-102
            return response
        end
        local gemCost=activeCfg.buyShop[shop][sid].g
        if  gemCost ==nil  or  gemCost<=0 then
            response.ret=-102
            return response
        end

        local num =getbuyinfo("getbuy",shop,hour,sid)
        response.data[aname]=mUseractive.info[aname]
        if num>activeCfg.buyShop[shop][sid].bn then
            local info=getbuyinfo("getbuyShop",activeCfg.buyShop,hour)
            response.data[aname].buyshop=info
            response.ret=-14006
            return response
        end

        local num =getbuyinfo("buy",shop,hour,sid)

         if num>activeCfg.buyShop[shop][sid].bn then
            local info=getbuyinfo("getbuyShop",activeCfg.buyShop,hour)
            response.data[aname].buyshop=info
            response.ret=-14006
            return response
        end
        local alog={gems=gemCost,sid=sid,shop=shop,reward=activeCfg.buyShop[shop][sid].sr}
        if type(mUseractive.info[aname].dg)~='table'  then mUseractive.info[aname].dg={} end
        local dgems=mUseractive.info[aname].dg['g'..shop] or 0
        if dgems>0 then
            delgems=math.floor(gemCost*activeCfg.rate)
            if dgems>=delgems then
                gemCost=gemCost-delgems
                mUseractive.info[aname].dg['g'..shop]=mUseractive.info[aname].dg['g'..shop]-delgems
            else
                gemCost=gemCost-mUseractive.info[aname].dg['g'..shop]
                mUseractive.info[aname].dg['g'..shop]=nil    
            end
        end
        
        if  not mUserinfo.useGem(gemCost) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=102,item="",value=gemCost,params={alog}})
        if not takeReward(uid,activeCfg.buyShop[shop][sid].sr) then        
            response.ret = -403 
            return response
        end
        local info=getbuyinfo("getbuyShop",activeCfg.buyShop,hour)
        
        response.data[aname].buyshop=info
        local info=getbuyinfo("getshop",activeCfg.shopItems[shop],hour)
        response.data[aname].shop=info
        if activeCfg.func[shop]=='hero' then
            response.data.hero =mHero.toArray(true)
            response.data.bag  =mBag.toArray(true)
        end
    elseif action == "hang" then     -- 刮刮乐    
        if type(mUseractive.info[aname].dg)~="table"  then  mUseractive.info[aname].dg={}  end
        -- 0-8点 和 23:55至24:00点 刮 9-10点的票
        if (hour < activeCfg.timeShow[1]) or (hour >= activeCfg.timeShow[2]-1 and minute >= 55) then
            hour = activeCfg.timeShow[1]
        -- 如果是其他时间段，55-60分时，则需要再加一小时
        elseif 55 <= minute and 60 >= minute then
            hour = hour + 1
        end
        -- 如果请求的是刮下一场，则是下个阶段的刮刮乐
        if 1 == nexthang then
            hour = hour + 1
        end 
        
        if hour<activeCfg.timeShow[1] or hour > activeCfg.timeShow[2] then
            response.ret=-1985
            return response
        end 
        
        local flag=table.contains(mUseractive.info[aname].gg, hour)
        if flag then
            response.ret=-1976
            return response
        end
        
        local dgems=getRewardByPool(activeCfg.serverreward['pool'..shop])
        if type(dgems)~='table' then
            return response
        end
        for k,v in pairs (dgems) do
            mUseractive.info[aname].dg['g'..shop]=(mUseractive.info[aname].dg['g'..shop] or 0) +v
            response.data.dgems=v
            mUseractive.info[aname].dgem["t"..hour] = v
        end
        table.insert(mUseractive.info[aname].gg,hour)
    end

    if uobjs.save() then
            response.data[aname]=mUseractive.info[aname]
            response.ret = 0        
            response.msg = 'Success'
    end
    return response
end
