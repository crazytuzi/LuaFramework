--
-- 坦克嘉年华活动
-- User: luoning
-- Date: 14-12-23
-- Time: 下午3:17
--
function api_active_jianianhua(request)

    local aname = 'tankjianianhua'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    local dtype = tonumber(request.params.dtype) or 0
    local checkDtype = {3,9,0}

    if uid == nil or not table.contains(checkDtype, dtype) then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    if dtype==0 then
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

    local activeCfg = getConfig("active."..aname.."."..mUseractive.info[aname].cfg)

    local getCostFlag = true
    local weelTs = getWeeTs()

    if mUseractive.info[aname].t < weelTs and dtype == 9 then
        response.ret = -1981
        return response
    end

    if mUseractive.info[aname].t < weelTs then
        getCostFlag = false
        mUseractive.info[aname].t = weelTs
    end

    local gemCost = dtype == 9 and activeCfg.mulCost or activeCfg.cost
    if getCostFlag and ( gemCost < activeCfg.cost or not mUserinfo.useGem(gemCost)) then
        response.ret = -109
        return response
    end

    --抽取奖励
    local selectIcons = {}
    for i=1, dtype do
        local pool = getRewardByPool(activeCfg.serverreward.pool)
        table.insert(selectIcons, pool[1])
    end

    local rewardlist = activeCfg.serverreward.rewardlist

    local serverToClient = function(type)
        local tmpData = type:split("_")
        local tmpType = tmpData[2]
        local tmpPrefix = string.sub(type, 1, 1)
        if tmpPrefix == 't' then tmpPrefix = 'o' end
        if tmpPrefix == 'a' then tmpPrefix = 'e' end
        return tmpPrefix, tmpType
    end

    --给予奖励
    local getSingleReward = function(aLine)

        local serverreward={}
        local clientreward={}
        local showFlag = false
        local nR = {}
        for _,v in pairs(aLine) do
            local tmp = selectIcons[v]
            if nR[tmp] then
                nR[tmp] = nR[tmp] + 1
            else
                nR[tmp] = 1
            end
        end
        local niubi = activeCfg.niubiicon[1]
        if nR[niubi] then
            if nR[niubi] == 1 or nR[niubi] == 2 then
                local tmpNum = nR[niubi]
                for i,v in pairs(nR) do
                    nR[i] = v + tmpNum
                end
                nR[niubi] = nil
            end
        end
        for i,v in pairs(nR) do
            if rewardlist[i.."-"..v] then
                for mtype,mnum in pairs(rewardlist[i.."-"..v]) do
                    if serverreward[mtype] then
                        serverreward[mtype] = mnum + serverreward[mtype]
                    else
                        serverreward[mtype] = mnum
                    end
                    local tmpPrefix, tmpType = serverToClient(mtype)
                    table.insert(clientreward,{tmpPrefix, tmpType, mnum})
                end
            end
            if v==3 then
                showFlag = true
            end
        end
        return serverreward,clientreward,showFlag
    end
    local serverreward={}
    local clientreward={}
    local checkLine={}
    local showLine = {}
    if dtype == 3 then
        checkLine = {{1,2,3} }
    elseif dtype == 9 then
        checkLine = {{4,5,6},{1,2,3},{7,8,9},{2,5,8},{1,4,7},{3,6,9},{1,5,9},{3,5,7}}
    end
    for i,v in pairs(checkLine) do
        local sReward,cReward,showFlag = getSingleReward(v)
        for mtype,mnum in pairs(sReward) do
            if serverreward[mtype] then
                serverreward[mtype] = mnum + serverreward[mtype]
            else
                serverreward[mtype] = mnum
            end
        end
        table.insert(clientreward,cReward)
        if showFlag then
            table.insert(showLine,i)
        end
    end

    local oldGems = mUserinfo.gems
    if not takeReward(uid, serverreward) then
        return response
    end
    local newGems = mUserinfo.gems

    response.data[aname].clientReward=clientreward
    response.data[aname].selectIcons=selectIcons
    response.data[aname].showLine=showLine
    if next(showLine) then
        local logInfo = {uid, oldGems, newGems, selectIcons}
        writeLog(json.encode(logInfo), "jianianhua")
    end

    if getCostFlag then
        regActionLogs(uid,1,{action=55,item="",value=gemCost,params={buyNum=dtype,reward=clientreward}})
    end

    local rewnum=1
    if dtype == 9 then
        rewnum=7
    end

    local lotterylog = {r=serverreward,hr={}}
    -- 和谐版活动
    if moduleIsEnabled('harmonyversion') ==1 then
      
        local hReward,hClientReward = harVerGifts('active','tankjianianhua', rewnum)
        if not takeReward(uid,hReward) then
            response.ret = -403
            return response
        end
        response.data[aname].hReward=hClientReward
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
        table.insert(data,1,{getClientTs(),1,rewardlog,lotterylog.hr,rewnum})
        if next(data) then
            for i=#data,11,-1 do
                table.remove(data)
            end

            data=json.encode(data)
            redis:set(redkey,data)
            redis:expireat(redkey,mUseractive.info[aname].et+86400)
        end 

        response.ret = 0
        response.msg = "Success"
    end

    return response
end

