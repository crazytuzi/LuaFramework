-- 配件嘉年华
function api_active_pjjnh(request)
    local response = {
        ret = -1,
        msg = 'error',
        data = {
        },
    }

    local uid = request.uid
    local action = request.params.action
    local aname = request.params.aname or 'pjjnh'
    local free  = request.params.free 
    local num   = tonumber(request.params.num) or 1
    local ts = getClientTs()
    local weeTs = getWeeTs()
    if uid == nil or action == nil then
        response.ret = -102
        return response
    end
    if not uid or not action then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo",'useractive','bag','troops','accessory','hero'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops = uobjs.getModel('troops')
    local mAccessory = uobjs.getModel('accessory')
    local activStatus = mUseractive.getActiveStatus(aname)

    local ts = getClientTs()
    local weeTs = getWeeTs()
    local lastTs = mUseractive.info[aname].t or 0
    local activeCfg = mUseractive.getActiveConfig(aname)
    if weeTs>lastTs then
        mUseractive.info[aname].t1 =nil
        mUseractive.info[aname].t2 =nil
        mUseractive.info[aname].t3 =nil
        mUseractive.info[aname].tr = {}
        mUseractive.info[aname].f=0
        mUseractive.info[aname].t=weeTs
    end
    local redis = getRedis()
    local redisKey ="z-"..getZoneId()..aname..mUseractive.info[aname].st.."-uid-"..uid
    if action=="rand" then
        local rlog =json.decode(redis:get(redisKey))
        if rlog==nil then
            rlog={}
        end
        if free then
            if mUseractive.info[aname].f>0 then
                response.ret=-102
                return response
            end
            mUseractive.info[aname].f=1
            num=1
            mUseractive.info[aname].t1=(mUseractive.info[aname].t1 or 0)+1
        else
            local gems=activeCfg.cost1
            if num~=1 then
                gems=activeCfg.cost2
                num=activeCfg.poolNum
                mUseractive.info[aname].t2=(mUseractive.info[aname].t2 or 0)+1
            else
                mUseractive.info[aname].t1=(mUseractive.info[aname].t1 or 0)+1
            end

            if not mUserinfo.useGem(gems) then
                response.ret = -109
                return response
            end
            mUseractive.info[aname].t3=(mUseractive.info[aname].t3 or 0)+gems
            regActionLogs(uid,1,{action=128,item="",value=gems,params={action=action,num=num}})
        end
        local l=mUseractive.info[aname].l or 0
        local report={}
        local lotterylog = {r={},hr={}}
        for i=1,num do
            
            l=l+1
            local lnum= l%activeCfg.poolNum
            if lnum==0 then
                l=activeCfg.poolNum
            else
                l=lnum  
                mUseractive.info[aname].l=l
            end
            -- 特殊的库里抽取奖励
            local rate = 1
            local pool=activeCfg.serverreward.randomPool1
            if l==activeCfg.poolNum  then
           
                -- 删除记录
                rlog={}
                mUseractive.info[aname].l=0
                pool=activeCfg.serverreward.randomPool2
                
                --特殊库翻倍
                rate = activeCfg.pool2Rate
            end
            
            local reward= copyTab( getRewardByPool(pool) )
            for k, v in pairs(reward) do
                reward[k] = math.floor( v * rate )
                lotterylog.r[k] = (lotterylog.r[k] or 0) + v
            end
            table.insert(report,{l,formatReward(reward)})
             -- 奖励发放
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
            
            if l~=activeCfg.poolNum then
                --记录一下位置
                local tmp={l,formatReward(reward)}
                table.insert( rlog, tmp )
            end
            
        end
        
        -- 和谐版判断
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','pjjnh',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            response.data.hReward = hClientReward
            lotterylog.hr = hClientReward
        end
        
        if uobjs.save() then
            local rewardlog = {}
            if next(lotterylog.r) then
                for k,v in pairs(lotterylog.r) do
                    table.insert(rewardlog,formatReward({[k]=v}))
                end
            end

            local redis =getRedis()
            local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end   
            table.insert(data,1,{ts,1,rewardlog,lotterylog.hr,num})
            if next(data) then
                for i=#data,11,-1 do
                    table.remove(data)
                end

                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[aname].et+86400)
            end      

            response.ret = 0        
            response.msg = 'Success'
            response.data.report = report
            redis:set(redisKey,json.encode(rlog))
            redis:expireat(redisKey,mUseractive.info[aname].et)
            response.data[aname] = mUseractive.info[aname]
            response.data.accessory = mAccessory.toArray(true)
            response.data[aname].rlog=rlog
        end
    elseif action=="getlog" then
        local rlog =json.decode(redis:get(redisKey))
        if rlog==nil then
                rlog={}
        end
        response.ret = 0        
        response.msg = 'Success'
        response.data[aname]={}
        response.data[aname].rlog=rlog
    elseif action=="task" then
        local tid= tonumber(request.params.method) or 1   
        if activeCfg.task[tid]==nil then
            response.ret=-102
            return response
        end
        local flag=table.contains(mUseractive.info[aname].tr,tid)
        if flag then
            response.ret=-102
            return response
        end
        local tcfg=activeCfg.task[tid]
        local num=mUseractive.info[aname][tcfg[1]] or 0
        if num<tcfg[2] then
            response.ret=-1981
            return response 
        end
        if not takeReward(uid,tcfg[3]) then
                response.ret = -403
                return response
        end
        table.insert(mUseractive.info[aname].tr,tid)
        if uobjs.save() then
            response.ret = 0        
            response.msg = 'Success'
            response.data.accessory = mAccessory.toArray(true)
            response.data[aname] = mUseractive.info[aname]
        end
    elseif action=='log' then
        local redis =getRedis()
        local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid
        local data =redis:get(redkey)
        data =json.decode(data)

        if type(data) ~= 'table' then data = {} end
        response.ret = 0
        response.msg = 'Success'
        response.data.report=data
        return response
    end

    return response

end