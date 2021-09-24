-- 结束游戏
function api_fleetgo_over(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    if moduleIsEnabled('fleetgo') == 0 then
        response.ret = -180
        return response
    end
    local uid = request.uid
    local km = request.params.km
    local num = request.params.num
    if km < 0 or num < 0 then
        response.ret=-102
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local ts= getClientTs()
    local weeTs = getWeeTs()
    -- 当天23:59时间戳
    local currTs = weeTs+86400-1
    local cfg = getConfig('fleetgo')
    local Cfg = copyTab(cfg)
    local itemLimit = Cfg.itemLimit --奖励上限
    local gemLimit = Cfg.gemLimit --钻石上限
    local checkTime = Cfg.serverreward.checkTime
    local count = #checkTime -1
    local index1 = math.floor(km/50)
    if km > checkTime[count][1] then
        index1 = math.floor(checkTime[count][1]/50)
    end
    local index2 = index1 + 1
    local tab1 = checkTime[index1]
    local tab2 = checkTime[index2]
    if tab1 == nil then
       tab1 = {0,0,0,0}
    end
    local lasttime = ts-mUserinfo.flags.gamest
    -- if lasttime < tab1[2] or lasttime > tab2[3] or num > tab2[4] then
    --     response.ret=-102
    --     return response
    -- end
    -- 游戏次数
    mUserinfo.flags.playnum = mUserinfo.flags.playnum + 1 
    local reward = {}
    for i=1,num do
        local tmpreward = {}
        tmpreward = getRewardByPool(Cfg.serverreward.pool)
        for k,v in pairs(tmpreward) do
            reward[k] = (reward[k] or 0) + v
        end
    end
    local hour = tonumber(getDateByTimeZone(mUserinfo.flags.gamest,"%H"))
    local hours = {}
    for k,v in pairs(Cfg.doubleTime) do
        for k1,v1 in pairs(v) do
            table.insert(hours,v1)
        end
    end
    local double = false
    if #hours == 4 then
        if hour >= hours[1] and hour <= hours[2] then
            double = true
        end  
        if hour >= hours[3] and hour <= hours[4] then
            double = true
        end     
    end
    if #hours == 2 then 
        if hour >= hours[1] and hour <= hours[2] then
            double = true
        end
    end
    if double == true then
        for k,v in pairs(reward) do
            reward[k] = v*2
        end
    end
    if not takeReward(uid,reward) then
        response.ret=-102
        return response
    end
    -- 任务结算
    if type(mUserinfo.flags.task)~='table' or not next(mUserinfo.flags.task) then
        mUserinfo.flags.task={}
        for k,v in pairs(Cfg.serverreward.achievement) do
            mUserinfo.flags.task[k]={}
            mUserinfo.flags.task[k].index=v[1].index
            mUserinfo.flags.task[k].r=0 --0未完成、1可领取、2已领取
            mUserinfo.flags.task[k].p=1 --进度 1,2,3
            mUserinfo.flags.task[k].cur=0 --当前数量
        end
    end
    for k,v in pairs(mUserinfo.flags.task) do
        if k == 'f1' then
           mUserinfo.flags.task[k].cur = mUserinfo.flags.task[k].cur + 1
        end
        if k == 'f2' then
            if km > mUserinfo.flags.task[k].cur then
               mUserinfo.flags.task[k].cur = km
            end
           
        end
        if k == 'f3' then
           mUserinfo.flags.task[k].cur = 
               mUserinfo.flags.task[k].cur + km
        end

    end
    local weekday = tonumber(getDateByTimeZone(ts,"%w"))
    if weekday == 0 then
        weekday = 7
    end
    local weeket = weeTs - (weekday-1)*86400
    if uobjs.save() then    
        processEventsAfterSave()
        local redis =getRedis()
        
        local testkey = "zid."..getZoneId().."fleetgotest"
        local testdata =redis:get(testkey)
        testdata =json.decode(testdata)
        if type (testdata)~="table" then testdata={} end
        table.insert(testdata,1,{lasttime,km,num})
        if next(testdata) then
            testdata=json.encode(testdata)
            redis:set(testkey,testdata)
        end

        local redkey = "zid."..getZoneId().."fleetgoweek"..weeket
        local todaykey = "zid."..getZoneId().."fleetgotoday"..weeTs
        local reportkey ="zid."..getZoneId().."fleetgoreport".."uid."..uid
        local keys = {}
        table.insert(keys,redkey)
        table.insert(keys,todaykey)
        table.insert(keys,reportkey)
        -- ptb:e(keys)
        for k1,v1 in pairs(keys) do
            if k1 == 1 then  
                local data =redis:get(v1)
                data =json.decode(data)
                if type (data)~="table" then 
                    data={} 
                    table.insert(data,{uid,ts,km})
                else
                    local flag = false
                    local checkkey
                    for k,v in pairs(data) do
                        if uid == v[1] then
                           flag = true
                           checkkey = k
                           break
                        end
                    end
                    if flag == true then
                        local tab = {}
                        table.insert(tab,data[checkkey])
                        table.insert(tab,{uid,ts,km})
                        tab = getsort(tab)
                        data[checkkey] = tab[1]
                    else
                        table.insert(data,{uid,ts,km})
                    end
                end
                if next(data) then
                    data=json.encode(data)
                    redis:set(v1,data)
                    redis:expireat(v1,ts+86400*9)
                end
            elseif k1 == 2 then
                local data =redis:get(v1)
                data =json.decode(data)
                if type (data)~="table" then 
                    data={} 
                end
                table.insert(data,{uid,ts,km})
                if next(data) then
                    data=json.encode(data)
                    redis:set(v1,data)
                    redis:expireat(v1,ts+86400*1)
                end
            else
                local data =redis:get(v1)
                data =json.decode(data)
                if type (data)~="table" then data={} end
                table.insert(data,1,{mUserinfo.flags.gamest,formatReward(reward),km,num})
                if next(data) then
                    if #data >10 then
                        for i=#data,11 do
                            table.remove(data)
                        end
                    end
                    data=json.encode(data)
                    redis:set(v1,data)
                    -- redis:expireat(v1)
                end
            end
            
        end   
        local datas = {}
        for k,v in pairs(keys) do
            local data =redis:get(v)
            data =json.decode(data)
            if k==1 then
                local weekkm = 0
                local rate = 0
                if data ~= nil then
                    if next(data) then
                        data = getsort(data)
                        local checkkey = 0
                        for k1,v1 in pairs(data) do
                            if uid == v1[1] then
                                checkkey = k1
                                break
                            end
                        end
                        local checkkeydata
                        if checkkey ~= 0 then
                            checkkeydata = data[checkkey]
                            weekkm = checkkeydata[3]
                            rate = string.format("%.2f",(#data - checkkey+1)/(#data))                            
                        end
                    end
                end
                table.insert(datas,weekkm)--周航行最大距离
                table.insert(datas,rate)--超过百分比
            elseif k==2 then
                local tmpkm = 0
                local maxkm = 0
                if data ~= nil then
                    if next(data) then
                        for k1,v1 in pairs(data) do
                            if uid == v1[1] then
                               tmpkm = tmpkm + v1[3]
                               if v1[3] > maxkm then
                                   maxkm = v1[3]
                               end
                            end
                        end
                    end
                end
                table.insert(datas,tmpkm)--当日已开出
                table.insert(datas,maxkm)--当日最高
            end
        end
        response.data.reward=formatReward(reward)
        response.data.info=datas
        response.ret = 0
        response.msg = 'Success'
    end
    return response

end