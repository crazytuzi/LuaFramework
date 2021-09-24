--1 服内的设置部队
function api_alliancewarnew_setinfo(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            alliancewar = {}
        },
    }

    local uid = request.uid
    local zid = request.zoneid
    local aName =request.params.aName or ""
    local hero  =request.params.hero or {}
    local fleet = request.params.fleetinfo or {}
    local clear = request.params.clear or 0
    local equip = request.params.equip
    local plane = request.params.plane

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","hero","troops","areacrossinfo","useralliancewar"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop    = uobjs.getModel('troops') 
    local mUseralliancewar    = uobjs.getModel('useralliancewar') 
    local mHero     = uobjs.getModel('hero')
    local mSequip = uobjs.getModel('sequip')
    local mPlane = uobjs.getModel('plane')

    if uid == nil or mUserinfo.alliance<0  then
        response.ret = -102
        return response
    end
    local mAllianceWar = require "model.alliancewarnew"
    local ts = getClientTs()
    local date  = getWeeTs()
    local allianceWarCfg = getConfig('allianceWar2Cfg')
    local ents = allianceWarCfg.signUpTime.finish[1]*3600+allianceWarCfg.signUpTime.finish[2]*60
    if ts <= date+ents  then
        response.ret = -8250
        return response
    end
    local aid=mUserinfo.alliance
    local execRet, code = M_alliance.getapply{uid=uid,aid=aid,date=date,endts=date+ents}
    if not execRet then
        response.ret = code
        return response
    end
    if  execRet.data.targetState==nil or  tonumber(execRet.data.targetState)==0 then
        response.ret = -8251
        return response
    end
    local areaid=tonumber(execRet.data.info.areaid)
    local warId =execRet.data.info.warid
    if not warId then
        response.ret = -4002
        return response
    end
    
    local joinAt =tonumber(execRet.data.join_at)
  
    local EndAt=date+ents
    if joinAt>EndAt or  joinAt==0 then
        response.ret = -23013
        return response
    end
    if tostring(mUseralliancewar.bid)~=tostring(warId) then
        mUseralliancewar.reset()
        mUseralliancewar.bid=warId
        -- 二次授勋+参加军团战X次
        mHero.refreshFeat("t12",1,1)
    end

    -- 已结束
    if mAllianceWar.getOverBattleFlag(warId) then
        response.ret = 0
        response.msg = 'Success'
        response.data.alliancewar.isover = 1
        return response
    end
   
    mUseralliancewar.rank=execRet.data.targetState
    mUseralliancewar.aid=mUserinfo.alliance
    local fleetInfo = {}
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
    if next(fleetInfo) then
        if clear~=1 and totalTanks<1 then
            response.ret=-5006
            return response
        end
    end
    if type(mUseralliancewar.info)~='table' then  mUseralliancewar.info={} end
    if type(mUseralliancewar.info.hero)~='table' then  mUseralliancewar.info.hero={} end
    if  type(mUseralliancewar.info.troops)~='table' then mUseralliancewar.info.troops={}  end

    

    local oldtank=copyTab(mUseralliancewar.info.troops)

   
     -- check hero
    if type(hero)=='table' then
        local herofalg =mHero.checkFleetHeroStats(hero)
        if herofalg==false then
            response.ret=-11016 
            return response
        end
        mUseralliancewar.info.hero=hero   
    end
  
    -- check equip
    if equip and not mSequip.checkFleetEquipStats(equip)  then
        response.ret=-8650 
        return response        
    end    
    mUseralliancewar.info.equip=mSequip.formEquip(equip)
    mUseralliancewar.info.plane=plane
    if clear==1 then
        mUseralliancewar.info.troops={} 
        mUseralliancewar.info.hero={}
        mUseralliancewar.info.equip=nil
        mUseralliancewar.info.plane=nil
    end

     -- 兵力检测   
    if next (fleetInfo) then
        -- 兵力检测
        if not mTroop.checkWorldWarFleetInfo(fleetInfo,equip) then
            response.ret = -5006
            return response
        end
        mUseralliancewar.info.troops=fleetInfo
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

    local deltroops =getdeltroops(oldtank,mUseralliancewar.info.troops)
    local tank={}
    if  next(deltroops) then
        for k,v in pairs(deltroops) do
            local v =math.ceil(v/allianceWarCfg.tankeTransRate)
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
                    {desc="服内军团战减少坦克",value=tank},
                    {desc="服内军团战上次设置部队",value=oldtank},
                    {desc="服内军团战本次设置部队",value=fleetInfo},
                }
            }
        ) 
        
        
    end
    
    --mAreacrossinfo.info.line={2,1,4}

    --local fleetInfo1,accessoryEffectValue1,herosinfo1 =mTroop.initFleetAttribute(fleetInfo,0,{hero=hero})
    --local binfo=mTroop.getbinfo(fleetInfo1)
    local binfo,heroAccessoryInfo=mTroop.gettroopsinfo(mUseralliancewar.info.troops,mUseralliancewar.info.hero,mUseralliancewar.info.equip,5,plane)
    mUseralliancewar.binfo=binfo
    if uobjs.save() then 
        if next(tank)  then
            writeLog(uid..'|'..json.encode(tank),'alliancewarnewtroops') 
        end
        response.data.troops = mTroop.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    end


    return response

end