-- 刷新
function api_fleetgo_refresh(request)
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
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    -- ptb:e(mUserinfo.flags)
    local ts= getClientTs()
    local weeTs = getWeeTs()
    -- 当天23:59时间戳
    local currTs = weeTs+86400-1
    local cfg = getConfig('fleetgo')
    local Cfg = copyTab(cfg)
    if mUserinfo.flags.playnum == nil then
       mUserinfo.flags.playnum = 0
    end
    if mUserinfo.flags.playtime == nil then
       mUserinfo.flags.playtime = 0
    end
    -- 初始化每天可玩次数
    if ts > mUserinfo.flags.playtime then
        mUserinfo.flags.playtime = currTs
        mUserinfo.flags.playnum = 0 
    end
    local ts = getClientTs()
    local weeTs = getWeeTs()
    local weekday = tonumber(getDateByTimeZone(ts,"%w"))
    if weekday == 0 then
        weekday = 7
    end
    local weeket = weeTs - (weekday-1)*86400
    local redis =getRedis()
    local redkey ="zid."..getZoneId().."fleetgoweek"..weeket
    local todaykey = "zid."..getZoneId().."fleetgotoday"..weeTs
    local keys = {}
    table.insert(keys,redkey)
    table.insert(keys,todaykey)
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
        else
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

    -- hwm 2018-08-22 优化
    -- 中途添任务配置需要自动接上
    if type(mUserinfo.flags.task) == "table" then
        for taskType,taskInfo in pairs(mUserinfo.flags.task) do
            if taskInfo.r == 2 then
                local taskList = Cfg.serverreward.achievement[taskType]
                if taskList then
                    local taskCfg = taskList[taskInfo.p]
                    if type(taskCfg) == "table" and taskCfg.next then
                        local nextTaskCfg = taskList[taskCfg.next]
                        if nextTaskCfg then
                            taskInfo.p=taskCfg.next
                            taskInfo.index=nextTaskCfg.index
                            taskInfo.r=0
                            taskInfo.con=nextTaskCfg[1]
                        end
                    end
                end
            end
        end
    end

    Cfg.serverreward = nil

    if uobjs.save() then    
        processEventsAfterSave()
        response.ret = 0
        response.data.cfg=Cfg
        response.data.info=datas
        response.data.playnum=mUserinfo.flags.playnum
        response.msg = 'Success'
    end
    return response

end