function api_active_list(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid

     if uid == nil then
        response.ret = -102
        return response
    end

    require "model.active"

    local mActive = model_active()
    local actives = mActive.toArray()

    local activeCfg = getConfig("active")
    local acfg = {}
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel("userinfo")
    -- 注册时间
    local regDays =  ((getWeeTs() - getWeeTs(mUserinfo.regdate)) / 86400) + 1

    -- if uid == 1009218 or uid == 1003172 then
    --     local testac = '{"name":"fbReward","type":"1","id":"5","updated_at":"1395145140","st":"1394957400","status":"1","et":"1395287400"}'
    --         actives.fbReward = json.decode(testac)
    -- end

    local harmonyFlag = moduleIsEnabled('harmonyversion') -- 抽奖和谐版是否开启
    local giftCfg,harmoneyCfg
    if harmonyFlag==1 then
         giftCfg = getConfig('harmonyVersion')
         harmoneyCfg = {default={}}
         harmoneyCfg["default"].reward = giftCfg.default["reward"]
    end

    local list = {}
    if type(actives) == 'table' then
        for k,v in pairs(actives) do
            if tonumber(v.type) ~= 10 then
                local acname=k
                acname = acname:split('_')
                list[k] = {}
                list[k].st = v.st
                list[k].et = v.et
                list[k].type = v.type
                acname=acname[1]
                acfg = activeCfg[acname]
                if not acfg then
                    acfg = getConfig("active/"..acname)
                end
                if type(acfg) == 'table' then
                    local tmpCfg = acfg
                    --一个活动多个配置文件处理
                    if acfg['multiSelectType'] then
                        tmpCfg = acfg[tonumber(v.cfg)]
                    end
                    --自定义配置文件
                    if type(v['selfcfg']) == 'string' and #v['selfcfg'] > 2 then
                        tmpCfg = mActive.selfCfg(k, true)
                        tmpCfg.version=tonumber(v.cfg)
                    end
                    
                    -- 属于绑定活动,需要判定是不是已经过了活动时间 并且开关是开着的
                    local need = true
                    local bindActive = getConfig('bindActive')
                    if bindActive[k] then
                        -- 开关未开，不返
                        if not switchIsEnabled('bindActive') then
                            need = false
                        -- 绑定时间已经过了，不返
                    elseif regDays < tmpCfg.bindTime[1] or regDays > tmpCfg.bindTime[2] + tmpCfg.rewardTime then
                            need = false
                        end
                    end

                    -- 需要返给客户端的
                    if need then
                        -- 方便前端数据格式,做一下处理
                        if tmpCfg._activeCfg then
                            list[k]["_activeCfg"] = {}
                            for m,n in pairs(tmpCfg) do
                                if m ~= 'serverreward' and m ~= "_activeCfg" then
                                    list[k]["_activeCfg"][m] = n
                                end
                            end
                        else
                            for m,n in pairs(tmpCfg) do
                                if m ~= 'serverreward'  then
                                    list[k][m] = n

                                elseif k=="xiaofeisongli" then
                                    list[k][m] = n
                                elseif k=="danrixiaofei" then
                                    list[k][m] = n
                                elseif k=="chongzhisongli" then
                                    list[k][m] = n
                                elseif k=="danrichongzhi" then
                                    list[k][m] = n
                                end
                            end
                        end
                    end
                end
            end
            -- 和谐版抽奖 奖励配置
            if harmonyFlag==1 then
                if type(giftCfg.active[k])=='table' and next(giftCfg.active[k]) then
                    harmoneyCfg[k]={}
                    for hkey,hv in pairs(giftCfg.active[k]) do
                        if hkey~='serverreward' and hkey~='spserverreward' then
                            harmoneyCfg[k][hkey] = hv
                        end
                        
                    end
                    
                end
            end
        end
    end
    if moduleIsEnabled('boss') == 1 then
        local weet = getWeeTs()
        local bossCfg = getConfig('bossCfg')
        local time=bossCfg.opentime[2][1]*3600+bossCfg.opentime[2][2]*60
        local sttime=bossCfg.opentime[1][1]*3600+bossCfg.opentime[1][2]*60
        list['boss']={st=weet+sttime,et=weet+time}
    end

    if moduleIsEnabled('dailychoice') == 1 then
        local timeCfg = getConfig('dailyactive.meiridati.openTime')
        list['dailychoice']=timeCfg
    end

    local xuanshang=activity_setopt(uid,'xuanshangtask',{t=''})
    if type(xuanshang)=='table' and next(xuanshang) then
        list['xuanshangtask']=xuanshang
    end

    -- 德国月卡 
    local germancard=activity_setopt(uid,'germancard',{num=0})
    if not germancard and type(list['germancard'])=='table' then
        list['germancard']= nil
    end

    -- 远洋征战 增加士气的活动 不在界面显示
    if type(list['oceanmorale'])=='table' and next(list['oceanmorale']) then
        list['oceanmorale'] = nil
    end

    response.data.harmoneyCfg = harmoneyCfg
    response.data.activelist = list
    response.ret = 0
    response.msg = 'Success'
    
    return response
end
