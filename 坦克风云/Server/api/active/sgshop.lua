--desc: 闪购商店
--user: chenyunhe
function api_active_sgshop(request)
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
    local aname = 'sgshop'
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

    -- 获取秒杀物品信息 随机保证不重复
    local function getquick()
        local result = {}
        -- 极限秒杀数据初始化
        local quickst = weeTs + activeCfg.quickShow[1]*3600 + 30*60
        local quicket = weeTs + activeCfg.quickShow[2]*3600 + 30*60
        local timekey = 0   
        local quickcachekey 
        local quickuserkey
        local date = os.date('%m%d')
        -- 开启时间内生成数据
        if ts >= quickst and ts <= quicket then   
            if minute>=30 then
                timekey = hour..'_'..30
            else
                timekey = (hour-1)..'_'..30
            end
      
            -- 获取秒杀数据
            quickcachekey ="zid."..getZoneId().."."..aname.."ts"..mUseractive.info[aname].st.."quick"..timekey..date
            local itemcache = redis:hget(quickcachekey,'item')
            local ln = redis:hget(quickcachekey,'ln')

            -- 已购买秒杀物品的玩家
            quickuserkey ="zid."..getZoneId().."."..aname.."ts"..mUseractive.info[aname].st.."quick"..timekey..date..'user'
          
            local quickuser = json.decode(redis:get(quickuserkey))
            if type(quickuser)~='table' or not next(quickuser) then
                quickuser = {}
            end

            if not itemcache or itemcache=='' then
               
                local quickpoolkey ="zid."..getZoneId().."."..aname.."ts"..mUseractive.info[aname].st.."quickpool"..date
                local quickpool = json.decode(redis:get(quickpoolkey))
                if type(quickpool)~='table' then
                    quickpool = {}
                end
       
                local randpool = copyTable(activeCfg.serverreward.qucikPool)
                -- 重置随机奖池
                for k,v in pairs(quickpool) do
                    randpool[2][v] = 0
                end
        
                local res,rkey = getRewardByPool(randpool)
                table.insert(quickpool,rkey[1])

                redis:set(quickpoolkey,json.encode(quickpool))
                redis:expire(quickpoolkey,86400)

                local itemcfg = activeCfg.sg[res[1]]
                --设置物品信息
                redis:hset(quickcachekey,'ln',itemcfg.bn)-- 剩余数量
                redis:hset(quickcachekey,'item',res[1])
                redis:expire(quickcachekey,3600)

                result['ln'] = itemcfg.bn
                result['item'] = res[1]
                result['flag'] = 0 -- 购买标识  0未购买过

                -- 玩家有没有买过
            else
                result['ln'] = ln
                result['item'] = itemcache
                result['flag'] = 0
                if table.contains(quickuser,mUserinfo.uid) then
                    result['flag'] = 1
                end
            end
        end
     
        return result,quickuserkey,quickcachekey
    end
    -- 随机红包
    local function randbag(total,bn)
        local bags={}--分配的结果
        local totalgold=total--总金额
        local i=0
        local rate1=math.ceil(math.max(1,totalgold/20))
        local rate2=math.ceil(math.max(1,totalgold/2))
        while(i<bn)
        do
            if i<bn-1 then
                setRandSeed()
                local rand=math.floor(rand(100*rate1,math.min(100*rate2,100*(totalgold-rate1*(bn-i))))/100)
                -- 随机类型
                local res,rkey = getRewardByPool(activeCfg.serverreward.shopPool)
                table.insert(bags,{rand,rkey[1]})
                totalgold=totalgold-rand
            else
                local res,rkey = getRewardByPool(activeCfg.serverreward.shopPool)
                table.insert(bags,{totalgold,rkey[1]})
            end
            i=i+1
        end

        return bags
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

        if gemCost>0 then
            activity_setopt(uid,'sgshop',{act='usegem',num=gemCost})
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
        regActionLogs(uid,1,{action=189,item="",value=gemCost,params={buy={shop,sid}}})
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
        response.data[aname].quick = getquick()

        if not response.data[aname].ugm then
            response.data[aname].ugm = 0
        end

        if not response.data[aname].ubg1 then
            response.data[aname].ubg1 = 0
        end

        if not response.data[aname].ubg2 then
            response.data[aname].ubg2 = 0
        end


        if not response.data[aname].charge then
            response.data[aname].charge = 0
        end

        if not response.data[aname].cbg1 then
            response.data[aname].cbg1 = 0
        end

        if not response.data[aname].cbg2 then
            response.data[aname].cbg2 = 0
        end

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
        if gemCost > 0 then
            activity_setopt(uid,'sgshop',{act='usegem',num=gemCost})
        end
        regActionLogs(uid,1,{action=190,item="",value=gemCost,params={alog}})
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
    elseif action == 'buyquick'  then -- 购买秒杀物品
        -- 每个人只能购买一次
        local quick,userkey,quickkey = getquick()
        -- 未开启
        if type(quick)~='table' or not next(quick) then
            response.ret = -1985
            return response
        end
    
        local buyitem = request.params.buy
        if quick.item ~= buyitem then
            response.ret = -2034
            return response
        end


        -- 已购买
        if quick.flag ==1 then
            response.ret = -23303
            return response
        end

        local leftnum=tonumber(redis:hget(quickkey,'ln'))
        if leftnum<=0 then
            response.ret = -1996
            return response
        end

        local left=redis:hincrby(quickkey,"ln",-1)
        if left < 0 then
            response.ret = -1996
            return response
        end

        local rewardCfg = activeCfg.sg[buyitem].sr
        local costg = activeCfg.sg[buyitem].g
        if not mUserinfo.useGem(costg) then
            response.ret = -109
            return response
        end

        if costg>0 then
             activity_setopt(uid,'sgshop',{act='usegem',num=costg})
        end

        regActionLogs(uid,1,{action=189,item="",value=costg,params={}})

        if not takeReward(uid,rewardCfg) then
            response.ret = -403
            return response
        end

        --已购买秒杀物品的玩家
        local quickuser = json.decode(redis:get(userkey))
        if type(quickuser)~='table' or not next(quickuser) then
            quickuser = {}
        end
        table.insert(quickuser,uid)
        redis:set(userkey,json.encode(quickuser))
        redis:expire(userkey,3600)

        response.data.reward = formatReward(rewardCfg)
        response.data.quick = getquick()
    elseif action == 'getVouchers' then -- 代金红包
        response.data[aname]=mUseractive.info[aname]   
        response.ret=0
        response.msg="Success"
        return response
    elseif action == 'sendbag' then -- 给军团里发红包
        -- 发送频率太快
        local toofast = 'toofast'..uid
        local u = redis:get(toofast)
        if u then
           response.ret = -8203
           return response
        end
        redis:set(toofast,uid)
        redis:expire(toofast,5)
      
        local item = request.params.item -- 第一档还是第二档
        if not table.contains({1,2},item) then
            response.ret = -102
            return response
        end

        if mUserinfo.alliance == 0 then
            response.ret = -4005
            return response
        end

        local ugm = mUseractive.info[aname].ugm or 0
        local ugb = mUseractive.info[aname]['ubg'..item] or 0

        if ugm <=0 then
            response.ret = -102
            return response
        end

        -- 验证可发送红包
        local cansend = math.floor((ugm-activeCfg.consume[item]*ugb)/activeCfg.consume[item])
        if cansend <= 0 then
            response.ret = -102
            return response
        end

        local redid=ts..'_'..mUserinfo.alliance
        local redkey="zid"..getZoneId()..aname..mUseractive.info[aname].st..'redbag'..redid
        --不能同一时间发送
        local redinfo=redis:hget(redkey,'info')
        local redbag=json.decode(redinfo)
        if type(redbag)=='table' and next(redbag) then
            response.ret=-8203--已经存在
            return response
        end

        local bags= randbag(activeCfg.consumeGet[item],activeCfg.consumeBack[item])
        redis:hset(redkey,'num',activeCfg.consumeBack[item])--红包
        local info = {
            redid,--红包编号
            uid,-- 玩家id
            mUserinfo.nickname,
            mUserinfo.alliance,--军团id
            mUserinfo.alliancename,--军团名
            item,---第几档
            {},---领取玩家的信息
            activeCfg.consumeBack[item],--总数量
            ts,-- 发送时间
            bags,-- 红包数据 
        }
        local data = json.encode(info)
        redis:hset(redkey,'info',data)
        redis:expireat(redkey,ts+86400)-- 保留一天

        mUseractive.info[aname]['ubg'..item] = (mUseractive.info[aname]['ubg'..item] or 0) + 1
        response.data.redbaginfo  = info

    elseif action == 'grabbag' then
        local redid = request.params.id -- 领取礼包的编号
        local ts= getClientTs()

        local alliance = mUserinfo.alliance
        if alliance==0 then
            response.ret = -4005   --没加入军团 不能领取奖励
            return response
        end

        local redkey = "zid"..getZoneId()..aname..mUseractive.info[aname].st..'redbag'..redid
        local giftinfo = json.decode(redis:hget(redkey,'info'))
        if type(giftinfo)~='table' or not next(giftinfo) then
            response.ret = -4001 --数据发生变化重试
            return response
        end

        -- 只能领取所在军团的礼包
        if alliance~=giftinfo[4] then
            response.ret = -2039
            return response
        end

        local leftnum=tonumber(redis:hget(redkey,'num')) or 0
        -- 需要判断当前玩家是否已领取  礼包是否能领取  不能领取自己发的红包
        local received = false
        for k,v in pairs(giftinfo[7]) do
            if v[1]==uid then
               received =  true
               break
            end
        end

        if leftnum > 0 and not received and giftinfo[2] ~= uid then
            -- 减少礼包
            local left=redis:hincrby(redkey,"num",-1)
            if left<0 then-- 剩余次数大于0 并发时也有可能导致剩余次数是0
                giftinfo[11] = 0
                giftinfo[12] = received
                giftinfo[13] = false
                response.data.redbaginfo = giftinfo
                response.ret = 0        
                response.msg = 'Success'
                return response
            else
                --随机获得代金券
                setRandSeed()
                local rand=rand(1,#giftinfo[10])
                local randdg=giftinfo[10][rand]

                -- 记录抢得红包玩家信息
                table.insert(giftinfo[7],{uid,mUserinfo.nickname,randdg[1],randdg[2],ts})
                -- 被抢的一条奖励移除
                table.remove(giftinfo[10],rand)
                local data = json.encode(giftinfo)
                redis:hset(redkey,'info',data)
                redis:expireat(redkey,ts+86400*3)

                giftinfo[11] = left
                giftinfo[12] = true -- 已抢到过
                giftinfo[13] = true -- 抢到了
              
                response.data.grabinfo = randdg
                if not mUseractive.info[aname].dg then
                    mUseractive.info[aname].dg = {}
                end
                mUseractive.info[aname].dg['g'..randdg[2]]=(mUseractive.info[aname].dg['g'..randdg[2]] or 0) +randdg[1]
                response.data.redbaginfo = giftinfo
            end      
        else
            giftinfo[11] = leftnum
            giftinfo[12] = received
            giftinfo[13] = false
            response.data.redbaginfo = giftinfo
            response.ret = 0        
            response.msg = 'Success'
            return response
        end
    elseif action == 'personalbag' then -- 领取个人的代金券红包
        local item = request.params.item -- 第一档还是第二档
        if not table.contains({1,2},item) then
            response.ret = -102
            return response
        end

        local charge = mUseractive.info[aname].charge or 0
        local cbg = mUseractive.info[aname]['cbg'..item] or 0

        if charge <=0 then
            response.ret = -102
            return response
        end

        -- 验证能否领取红包
        local canreceive = math.floor((charge-activeCfg.recharge[item]*cbg)/activeCfg.recharge[item])
        if canreceive <= 0 then
            respons.ret = -102
            return response
        end
    
        local bags= randbag(activeCfg.rechargeGet[item],activeCfg.rechargeBack[item])
        if not mUseractive.info[aname].dg then
            mUseractive.info[aname].dg = {}
        end

        for k,v in pairs(bags) do
            mUseractive.info[aname].dg['g'..v[2]]=(mUseractive.info[aname].dg['g'..v[2]] or 0) +v[1]
        end

        mUseractive.info[aname]['cbg'..item] = (mUseractive.info[aname]['cbg'..item] or 0) + 1
        response.data.reward = bags

    end

    if uobjs.save() then
            response.data[aname]=mUseractive.info[aname]
            response.ret = 0        
            response.msg = 'Success'
    end
    return response
end
