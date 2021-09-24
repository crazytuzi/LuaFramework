-- 获取幸运帮

function api_military_getluckrank(request)
    local response = {
            ret=-1,
            msg='error',
            data = {userarena={}},
        }
    
    if moduleIsEnabled('military')  == 0 then
        response.ret = -10000
        return response
    end


    local uid = request.uid
   
    if uid <= 0 then
        response.ret = -102
        return response
    end

     local uobjs = getUserObjs(uid)
    uobjs.load({"userarena","userinfo"})    

    local muserarena = uobjs.getModel('userarena')
    local mUserinfo = uobjs.getModel('userinfo')

    local ts = getClientTs()
    local rewardtime=muserarena.getRewardTime(ts)

    local uptime =rewardtime[1]

    local dntime =rewardtime[2]

    local maxrank =tonumber(getMaxArenaRank())

    local redis = getRedis()
    local arenaCfg = getConfig('arenaCfg')

    local  start  = arenaCfg.luckRank[1]

    local  ends = arenaCfg.luckRank[2]


    if ends > tonumber(maxrank) and tonumber(maxrank)>450 then
        ends=tonumber(maxrank)
    end
    local arenaNpcCfg = {}    
    local upkey = "z"..getZoneId()..".userarena.Luck.Rank"..uptime
    local update = redis:get(upkey)
    local uplist= json.decode(update)
     
    if type(uplist)~='table' or not next(uplist)  or type(uplist[1])~='table' then
        
        local ranks={}
        if type(uplist)~='table'  then
            ranks=getRandList(start,ends,arenaCfg.maxlucknums)
        else
           ranks= uplist
        end
        
        uplist={}
        for  k,rank in pairs (ranks) do
              local  item  = {}
              local muid= tonumber( getArenaUidByRank(rank))
              if muid>1000000 then
                    local userinfo = mUserinfo
                    if muid~=uid then
                        local uobjs = getUserObjs(muid,true)
                        userinfo = uobjs.getModel('userinfo')
                    end
                    item={rank,muid,userinfo.nickname}
                    table.insert(uplist,item) 
               else
                 if not next(arenaNpcCfg) then
                        arenaNpcCfg = getConfig('arenaNpcCfg')
                    end
                    local sid='s'..muid
                    if arenaNpcCfg[sid] then

                        item={rank,muid,arenaNpcCfg[sid].name}
                        table.insert(uplist,item)
                    end

               end
        end
       
        local data = json.encode(uplist)
        local reuslt = redis:set(upkey,data)
        redis:expire(upkey,432000)  
       
    end



    local dnkey = "z"..getZoneId()..".userarena.Luck.Rank"..dntime

    local dndate = redis:get(dnkey)


    
    local dnlist= json.decode(dndate)
     if type(dnlist)~='table' or not next(dnlist)   then


        dnlist={}
        dnlist=getRandList(start,ends,arenaCfg.maxlucknums)
        --设置定时
        local cronParams = {cmd ="military.update",params={rankey=dnkey}}

        if not(setGameCron(cronParams,dntime-ts-5)) then
            setGameCron(cronParams,dntime-ts-5) 
        end

        local data = json.encode(dnlist)
        local reuslt = redis:set(dnkey,data)
        redis:expire(dnkey,432000)  
       
    end

    local ranklist= {}
    ranklist.uprank=uplist
    ranklist.dnrank=dnlist 
    response.ret=0
    response.msg = 'Success'
    response.data.userarena.luckrank=ranklist
    return  response
end