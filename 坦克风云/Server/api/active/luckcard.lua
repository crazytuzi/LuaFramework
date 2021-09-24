-- 幸运翻牌

function api_active_luckcard(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid    = request.uid
    local action = tonumber(request.params.action) or 1
    local free   = request.params.free or nil
    local aname  = request.params.aname or 'luckcard'
    local num    = request.params.num or 1
    local ts     = getClientTs()
    local weeTs  = getWeeTs()
    
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
    local mBag = uobjs.getModel("bag")
    local mHero = uobjs.getModel('hero')
    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
    
    local activeCfg = mUseractive.getActiveConfig(aname)
    local function search(cfg,num)
        local reward={}
        local report={}
        local flag=true
        local go=true
        for i=1,8 do
            if go==false then
                break
            end
            local result = getRewardByPool(cfg.serverreward['randomPool'..i])
            
            local log
            for k,v in pairs (result) do
                reward[k]=(reward[k] or 0)+v*num
                result[k]=v*num
                local flag=table.contains(cfg.nextRequire,k)
                if not flag  then
                    go=false
                end
            
            end

            table.insert(report,{formatReward(result)})

            --连续了 中了大奖了
            if i==8 and go==true  then
                local luckResult = {}
                for k, v in pairs (cfg.luckyReward.serverreward) do
                    reward[k]=(reward[k] or 0)+v *num
                    luckResult[k]=(luckResult[k] or 0)+v *num
                end

                table.insert(report,{formatReward(luckResult)})
            end
        end
        return reward,report
    end

    if action==1 then
        --免费
        local reward,report
        if free then
            num=1
            local lastTs = mUseractive.info[aname].t or 0
            if weeTs > lastTs then
                mUseractive.info[aname].c = 0
                mUseractive.info[aname].v = 0
                mUseractive.info[aname].t =weeTs
            end
            if mUseractive.info[aname].v~=0 then
                response.ret = -102
                return response
            end
            mUseractive.info[aname].v = 1
            reward,report=search(activeCfg,1)
        else --花钱
            -- 十倍

            local gems=activeCfg.cost1
            if num==10 then
                gems=activeCfg.cost2
                reward,report=search(activeCfg,num)
            else -- 1倍
               reward,report=search(activeCfg,num)
            end

            if not mUserinfo.useGem(gems) then
                response.ret = -109 
                return response
            end
            regActionLogs(uid,1,{action=127,item="",value=gems,params={buyNum=num}})  
        end
        if not takeReward(uid,reward) then
                return response
        end
        local cpReport=copyTable(report) --给客户端返回的report中不包含和谐版返回的奖励
         -- 和谐版活动
         local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','luckcard', num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward=hClientReward
            table.insert(report,{formatReward(hReward)})--记录中添加和谐版奖励
        end 
        if uobjs.save() then  
            local redis =getRedis()
            local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={}  end   
            table.insert(data,{ts,report})   
            if next(data) then
                if #data >10 then
                    for i=1,#data-10 do
                        table.remove(data,1)
                    end
                end
                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[aname].et+86400)
            end
            response.data[aname] =mUseractive.info[aname]
            if next(harCReward) then
                response.data[aname].hReward=harCReward
            end            
            response.ret = 0
            response.msg = 'Success'
            response.data.report=cpReport
        end

    else
        local redis =getRedis()
        local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid
        local data =redis:get(redkey)
        data =json.decode(data)
        response.ret = 0
        response.msg = 'Success'
        response.data.report=data

    end


    return response
end
