--军团战捐献

function api_across_donate(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local method = request.params.method   or 1 
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    local zid = request.zoneid
    if mUserinfo.alliance <= 0 then
        return response
    end 
    
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
        --缓存跨服军团战的基本信息
    local mMatchinfo= mServerbattle.getAcrossBattleInfo()
    if not next(mMatchinfo)  then
        return response
    end
    local ts = getClientTs()
    local sevCfg=getConfig("serverWarTeamCfg")
    local acrossserver = require "model.acrossserverin"
    local across = acrossserver.new()
    local ApplyData =across:getAllianceApplyData(mMatchinfo.bid,zid,mUserinfo.alliance)
    local data = ApplyData
    if not next(ApplyData) then
        response.ret=-21010
        return response
    end

    -- 加入时间限制
    local ret,code = M_alliance.getalliance{alliancebattle=1,method=1,aid=mUserinfo.alliance,uid=uid}
    if not ret then
        response.ret=code
        return response
    end

    require "model.amatches"
    local mMatches = model_amatches()
    local start =tonumber(mMatchinfo.st)
    if tonumber(ret.data.join_at)> start+sevCfg.preparetime*24*3600 then
        response.ret=-21022
        return response
    end

    local redis = getRedis()
    local redisKey =zid.."alliancebattle.across.donate"..mUserinfo.alliance.."bid"..mMatchinfo.bid
    start=start+(sevCfg.preparetime+sevCfg.signuptime)*24*3600
    --报名结束时间
    local endts =start+sevCfg.applyedtime[1]*3600+sevCfg.applyedtime[2]*60
    if ts> endts then
        local ainfo,myround,mycross=mMatches.getMatchInfo(zid,mUserinfo.alliance,0)
        if type(mycross)=='table' and  next(mycross) then
            if tonumber(mycross.battle_at)>= tonumber(ApplyData.donate_at) and tonumber(ApplyData.donate_at)~=0 then
                data.basedonatenum=0
                redis:set(redisKey,0)
                data.basetroops=""
            end
        end
        if myround>0  then
            local weets      = getWeeTs()
            local endts =weets+sevCfg.startBattleTs[myround][1]*3600+sevCfg.startBattleTs[myround][2]*60+sevCfg.warTime
            if ts>=endts and  tonumber(mycross.battle_at)<weets then
                local ainfo,myround,mycross=mMatches.getMatchInfo(zid,mUserinfo.alliance,1)
            end
            if type(mycross)=='table' and  next(mycross) then
                if tonumber(mycross.battle_at)>= tonumber(ApplyData.donate_at) and tonumber(ApplyData.donate_at)~=0 then
                    data.basedonatenum=0
                    redis:set(redisKey,0)
                    data.basetroops=""
                end
            end
            if tonumber(mycross.battle_at)<weets then
                local stts = weets+sevCfg.startBattleTs[myround][1]*3600+sevCfg.startBattleTs[myround][2]*60-sevCfg.setTroopsLimit
                if ts < endts  and  ts>stts then
                    response.ret =-21015
                    return response
                end
            end
        end
    end

    
    local basedonatenum =tonumber(data.basedonatenum) 

    local userdata=across:getUserDataFromDb(mMatchinfo.bid,zid,mUserinfo.alliance,uid)
    local gdonatenum = 0
    local rdonatenum = 0
    local action  = 'apply'
    if userdata~=nil and next(userdata) then
        action ='update'
        gdonatenum=tonumber(userdata.gdonatenum)
        rdonatenum=tonumber(userdata.rdonatenum)
    end
    local usegems=sevCfg.baseDonateGem
    
    if method==1 then
        if not mUserinfo.useGem(usegems) then
            response.ret = -109 
            return response
        end
        gdonatenum=gdonatenum+1
        regActionLogs(uid,1,{action=50,item="",value=usegems,params={}})
    
    else

        local resource =sevCfg.baseDonateRes.h
        local ret =mUserinfo.useResource(resource)
        if not ret then
            response.ret = -109 
            return response
        end

        rdonatenum=rdonatenum+1
    end
    
    --处理并发捐献
    local incr  =redis:incr(redisKey)
    if incr<basedonatenum then
        redis:set(redisKey,basedonatenum)
        incr= redis:incr(redisKey)
    end
    redis:expireat(redisKey,tonumber(mMatchinfo.et))
    basedonatenum =incr
    local version  =getVersionCfg()
    local roleMaxLevel = version.roleMaxLevel
    local basetroops=json.decode(data.basetroops)
    if basetroops==nil then
        basetroops={}
    end
    local baseFleetInfo = sevCfg.baseFleetInfo[roleMaxLevel] or sevCfg.baseFleetInfo[80]
 
    local lindex=tonumber(#basetroops)
    local index = 0
    for k,v in pairs(sevCfg.baseDonateTime) do
        if basedonatenum>=v then
            index=k
        end
    end

    local troopscount =0
    for k,v in pairs(sevCfg.baseDonateNum) do
        if v> index then
            break
        end
        troopscount=troopscount+v
    end

    if  lindex>= troopscount and lindex>sevCfg.maxBaseFleetNum then
        response.ret = -21018
        return response
    end
   
    if troopscount-lindex>0 then
        local item = {}
        local count =math.floor((roleMaxLevel * roleMaxLevel/4 )) 
        local c = 0
        for k,v in pairs(baseFleetInfo) do
            item[k]={v,count}
            c=c+1
        end
        if c <6 then
            setRandSeed()
            local FleetInfo=copyTable(baseFleetInfo)
            local len = c
            for i=c+1,6 do
                local randnum  =rand(1,len)
                local aid=FleetInfo[randnum]
                item[i]={aid,count}
                table.remove(FleetInfo,randnum)
                len=len-1
            end
        end
        for i=1,troopscount-lindex do
            table.insert(basetroops,item)
        end
        
    end


    data.basetroops=json.encode(basetroops)
    data.basedonatenum=basedonatenum
    data.donate_at=ts
    local senddata={}
    senddata.basetroops=basetroops
    senddata.basedonatenum=basedonatenum
    senddata.donate_at=ts
    senddata.aid=mUserinfo.alliance
    senddata.bid=mMatchinfo.bid
    senddata.zid=zid
    --服外设置部队
    local config = getConfig("config.z"..zid..".across")
    local sdata={cmd='acrossserver.setalliance',params={data=senddata,action='update'}}
    local ret=sendGameserver(config.host,config.port,sdata)
    if ret.ret~=0 then
        response.ret=ret.ret
        return response
    end
    

    local senduserdata={}
    senduserdata.bid =ApplyData.bid
    senduserdata.aid =mUserinfo.alliance
    senduserdata.zid =zid
    senduserdata.nickname=mUserinfo.nickname
    senduserdata.pic=mUserinfo.pic
    senduserdata.level=mUserinfo.level
    senduserdata.rank=mUserinfo.rank
    senduserdata.fc=mUserinfo.fc
    senduserdata.uid=uid
    senduserdata.aname=mUserinfo.alliancename
    senduserdata.gdonatenum=gdonatenum
    senduserdata.rdonatenum=rdonatenum
    if action=='apply'  then
        local ret =across:setUserBattleData(senduserdata)
        if not ret then
            return response
        end
        local sdata={cmd='acrossserver.setuser',params={data=senduserdata,action=action}}
        local ret=sendGameserver(config.host,config.port,sdata)
        if ret.ret~=0 then
            response.ret=ret.ret
            return response
        end
    else
        local ret =across:updateUserBattleData(senduserdata)
        if not ret then
            return response
        end
    end

    local ret=across:updateAllianceData(data)

    if ret then 

        if uobjs.save() then    
            response.ret = 0
            response.data.basedonatenum = basedonatenum
            response.data.basetroops = basetroops
            response.msg = 'Success'
        end

    end
    
   
    return response


end