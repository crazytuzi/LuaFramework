--1 服内赛结束时，跨服报名的时候我需要知道当前军团在服内是否的冠亚？
--2 服内报名以后，我要知道我的军团是否报名状态。
--3 服内的设置部队and跨服的设置部队

function api_across_setinfo(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local zid = request.zoneid
    local aName =request.params.aName or ""
    local hero  =request.params.hero or {}
    local usegems=request.params.usegems or 0 
    local fleet = request.params.fleetinfo or {}
    local clear = request.params.clear or 0
    local equip = request.params.equip
    local plane = request.params.plane

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","hero","troops","plane"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop    = uobjs.getModel('troops') 
    local mSequip = uobjs.getModel('sequip')
    local mPlane = uobjs.getModel('plane')

    if uid == nil or mUserinfo.alliance<0 then
        response.ret = -102
        return response
    end

    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
        --缓存跨服军团战的基本信息
    local mMatchinfo= mServerbattle.getAcrossBattleInfo()
    if not next(mMatchinfo)  then
        return response
    end
    local acrossserver = require "model.acrossserverin"
    local across = acrossserver.new()
    local ApplyData =across:getAllianceApplyData(mMatchinfo.bid,zid,mUserinfo.alliance)
    if not next(ApplyData) then
        response.ret=-21010
        return response
    end

    if mUserinfo.usegems~=nil and mUserinfo.usegems>0 then
        if mUserinfo.bid~=mMatchinfo.bid and mUserinfo.bid~="" then
            response.ret=-21021
            return response
        end
    end

    local function gettroopsinfo(mTroop,fleet,hero,equip,plane) 
        if not next(fleet) then
            return {}
        end
        local fleetInfo1,accessoryEffectValue1,herosinfo1,plane1 =mTroop.initFleetAttribute(fleet,12,{hero=hero,equip=equip,plane=plane})
        local result={{},{},{}}
        local keys={}
        for i=1,6 do
            if type(fleetInfo1[i])=='table' and next(fleetInfo1[i]) then
                local isHero = false
                for k,v in pairs (fleetInfo1[i]) do   
                    table.insert(keys,k)
                    if k == 'hero' then isHero = true end
                end 
                if not isHero then table.insert(keys,'hero') end
                break
            end
        end
        result[1]=keys
        table.insert(result[3],herosinfo1[1])
        local troops = {}
        for k,v in pairs(keys) do
            local  attfleetInfo = fleetInfo1
                for k1,v1 in pairs(attfleetInfo)  do
                    if type (troops[1]) ~='table' then troops[1]={} end
                    if type (troops[1][k1])~='table' then troops[1][k1]={}  end
                    if next(v1) then 
                        troops[1][k1][k]=v1[v]
                    end
                    
                end
        end
        result[2]=troops
        --result[4]={accessoryEffectValue1,herosinfo1}
        result[4]=mSequip.formEquip(equip)
        result[5]=plane1 or {}
        return result,{accessoryEffectValue1,herosinfo1,result[4],plane1}
    end
    local data = {}
    local senddata = {}
    local fleetInfo = {}
    if next(fleet) then
        
        local totalTanks = 0
        for m,n in pairs(fleet) do        
            if type(n) == 'table' and next(n) and n[2] > 0 then
                if n[1] then 
                    n[1]= 'a' .. n[1] 
                end    
                totalTanks = totalTanks + n[2]
                fleetInfo[m] = n
            else
                fleetInfo[m] = {}
            end
        end
         -- 兵力检测
        if next (fleetInfo) then
            if not mTroop.checkWorldWarFleetInfo(fleetInfo,equip) then
                response.ret = -21013
                return response
            end
        end
        local binfo,heroAccessoryInfo = gettroopsinfo(mTroop,fleetInfo,hero,equip,plane)
        data.binfo=json.encode(binfo)
        data.troops=json.encode(fleetInfo)
        data.heroAccessoryInfo=json.encode(heroAccessoryInfo)
        senddata.binfo =binfo
        senddata.troops =fleetInfo
        senddata.heroAccessoryInfo=heroAccessoryInfo
    end

    
    local sevCfg=getConfig("serverWarTeamCfg")
    if mUserinfo.level<sevCfg.joinlv then
        response.ret=-21050
        return response
    end

    local ret,code = M_alliance.getalliance{getuser=1,method=1,aid=mUserinfo.alliance,uid=uid}
    
    if not ret then
        response.ret = code
        return response
    end
   

    local ts = getClientTs()
    local weets      = getWeeTs()

    require "model.amatches"
    local mMatches = model_amatches()
    local start =tonumber(mMatchinfo.st)
    start=start+(sevCfg.preparetime+sevCfg.signuptime)*24*3600
    if tonumber(ret.data.join_at)==0 or tonumber(ret.data.join_at)> start-sevCfg.jointime*3600 then
        response.ret=-21050
        return  response
    end
    --报名结束时间
    local endts =start+sevCfg.applyedtime[1]*3600+sevCfg.applyedtime[2]*60
    if ts> endts then
        local ainfo,myround=mMatches.getMatchInfo(zid,mUserinfo.alliance,0)
        if myround>0 then
            local endts =weets+sevCfg.startBattleTs[myround][1]*3600+sevCfg.startBattleTs[myround][2]*60+sevCfg.warTime
            local stts = weets+sevCfg.startBattleTs[myround][1]*3600+sevCfg.startBattleTs[myround][2]*60-sevCfg.setTroopsLimit
            if ts < endts  and  ts>stts   then
                response.ret =-21011
                return response
            end
        end
    end
    
    local mHero     = uobjs.getModel('hero')

    --check hero
    if type(hero)=='table' and next(hero) then
        hero =mHero.checkFleetHeroStats(hero)
        if type(hero)~='table' and hero==false then
            response.ret=-11016 
            return  response
        end
        data.hero=json.encode(hero)
        senddata.hero =hero
    end

    -- 检测扣的坦克是否能够
    local function getdeltroops(oldtank,troops)
        local old={}
        local new={}
        local result={}
        if next(oldtank) then
            for k,v in pairs(oldtank) do
                if v[2]~=nil and v[2]>0 then
                    old[v[1]]=(old[v[1]] or 0)+v[2]
                end
            end
        end
        for k,v in pairs(troops) do
            if v[2]~=nil and  v[2]>0 then
                new[v[1]]=(new[v[1]] or 0)+v[2]
            end
        end
        if next(new) then
            for k,v in pairs(new) do
                local count =v- (old[k] or 0)
                if count>0 then
                    result[k]=count
                end
            end

        end
        return result
    end

    -- 兑换兵
    local oldtank = {}
    local userdata=across:getUserDataFromDb(ApplyData.bid,zid,mUserinfo.alliance,uid)
    local action  = 'apply'
    if userdata~=nil and next(userdata) then
        action ='update'
        oldtank = json.decode(userdata.troops) or {}
    end

    local deltroops =getdeltroops(oldtank,fleetInfo)

    local tank={}
    if  next(deltroops) then
        for k,v in pairs(deltroops) do
            local v =math.ceil(v/sevCfg.tankeTransRate)
            local tmp={}
            table.insert(tmp,mTroop.troops[k])
            if not mTroop.troops[k] or v > mTroop.troops[k] or not mTroop.consumeTanks(k,v) then
                response.ret = -115
                return response
            end
            table.insert(tmp,mTroop.troops[k])
            tank[k]=tmp
        end
        
        regKfkLogs(uid,'tankChange',{
                addition={
                    {desc="军团跨服战减少坦克",value=tank},
                    {desc="军团跨服战战上次设置部队",value=oldtank},
                    {desc="军团跨服战本次设置部队",value=fleetInfo},
                }
            }
        ) 
        
        response.data.troops = mTroop.toArray(true)
    end

    if usegems>0 then
        if not mUserinfo.useResource({gems=usegems}) then
            response.ret = -109 
            return response
        end

        request.params.aName = 0
        regActionLogs(uid,1,{action=49,item="",value=usegems,params={}})
        mUserinfo.usegems=mUserinfo.usegems +usegems
        mUserinfo.bid=ApplyData.bid
        data.carrygems=mUserinfo.usegems
        data.gems=mUserinfo.usegems
        senddata.carrygems =data.carrygems
        senddata.gems=data.carrygems
    end


    local ts=getClientTs()
    
    data.bid =ApplyData.bid
    data.aid =mUserinfo.alliance
    data.zid =zid
    data.nickname=mUserinfo.nickname
    data.pic=mUserinfo.pic
    data.level=mUserinfo.level
    data.rank=mUserinfo.rank
    data.fc=mUserinfo.fc
    data.aname=aName
    data.uid=uid
    if clear==1 then
        data.hero=json.encode({})
        data.binfo=json.encode({})
        data.troops=json.encode({})
        senddata.binfo ={}
        senddata.troops ={}
        senddata.heroAccessoryInfo={}
        senddata.hero={}
    end
        
    local userdata=across:getUserDataFromDb(data.bid,zid,mUserinfo.alliance,uid)
    local action  = 'apply'
    if userdata~=nil and next(userdata) then
        action ='update'
    end
    --服外设置部队
    local config = getConfig("config.z"..zid..".across")
    
    senddata.bid =ApplyData.bid
    senddata.aid =mUserinfo.alliance
    senddata.zid =zid
    senddata.nickname=mUserinfo.nickname
    senddata.pic=mUserinfo.pic
    senddata.level=mUserinfo.level
    senddata.rank=mUserinfo.rank
    senddata.fc=mUserinfo.fc
    senddata.uid=uid
    senddata.role=ret.data.role
    senddata.aname=aName
    local sdata={cmd='acrossserver.setuser',params={data=senddata,action=action}}
    local ret=sendGameserver(config.host,config.port,sdata)
    if ret.ret~=0 then
        response.ret=ret.ret
        return response
    end


    local ret  = false
    if action=='apply'  then
        ret =across:setUserBattleData(data)
    else
        ret =across:updateUserBattleData(data)
    end

    if not ret then
        response.ret=-21012
        return response
    end
    
    if uobjs.save() then

        if next(tank)  then
            writeLog(uid..'|'..json.encode(tank),'acrosstroops') 
        end

        response.ret = 0
        response.msg = 'Success'
    end

    return response

end