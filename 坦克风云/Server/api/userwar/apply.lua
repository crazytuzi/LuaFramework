-- 报名异元战场

function api_userwar_apply(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = request.uid
    local hero  = request.params.hero or {}
    local fleet = request.params.fleetinfo or {}
    local equip = request.params.equip
    local plane = request.params.plane

    local date  = getWeeTs()
    if uid == nil or point == 0 or aid == 0 or areaid == 0 then
        response.ret = -102
        return response
    end
     
    if moduleIsEnabled('userwar') == 0 then
        response.ret = -4012
        return response
    end
    local cobjs = getCacheObjs(uid,false,'apply')
    local mUserwar = cobjs.getModel('userwar')
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","hero","troops"})
    local mHero     = uobjs.getModel('hero')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop    = uobjs.getModel('troops')
    local mSequip = uobjs.getModel('sequip')

    local ts = getClientTs()
    local userwarnew = require "model.userwarnew"
    local userWarCfg=getConfig("userWarCfg")
    local warId = userwarnew.getWarId()
    local opts = userwarnew.getWarOpenTs()
    
    if not  userwarnew.isEnable() then
        response.ret = -4002
        return response
    end
    -- 时间限制
    if  ts+userWarCfg.prepareTime>opts.st then
        response.ret = -4002
        return response
    end
    
    if tostring(mUserwar.bid)~=tostring(warId) then
        local maxApplyNum = userWarCfg.maxApplyNum or 10
        local applyNum = userwarnew.getApplyNum(warId)
        if applyNum >= maxApplyNum then
            response.ret = -23310
            return response
        end
        mUserwar.reset()
        mUserwar.bid = warId
        mUserwar.apply_at = ts
        mUserwar.mapx,mUserwar.mapy = userwarnew.getPlace()
        local lid = mUserwar.mapx..'-'..mUserwar.mapy
        userwarnew.setLandUser(warId,lid,uid)
        userwarnew.setApplyNum(warId,1)
    end
    
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
    
    if type(mUserwar.info)~='table' then  mUserwar.info={} end
    if type(mUserwar.info.hero)~='table' then  mUserwar.info.hero={} end
    if type(mUserwar.info.troops)~='table' then mUserwar.info.troops={}  end
    if not mUserwar.info.equip then mUserwar.info.equip = 0 end
    if not mUserwar.info.plane then mUserwar.info.plane = 0 end
    local oldtank=copyTab(mUserwar.info.troops)

     -- check hero
    local tmphero={}
    if type(hero)=='table' then

        local herofalg =mHero.checkFleetHeroStats(hero)
        if herofalg==false then
            response.ret=-11016 
            return response
        end
        tmphero=copyTab(hero)
        if type(hero)=='table' and next(hero) then
            for k,v in pairs (hero) do
                if v~=0 and mHero.hero[v]~=nil then
                    hero[k]=v.."-"..mHero.hero[v][3].."-"..mHero.hero[v][1]
                end
            end
        end
        mUserwar.info.hero=hero   
    end

    -- check equip
    if equip and not mSequip.checkFleetEquipStats(equip)  then
        response.ret=-8650 
        return response        
    end
    mUserwar.info.equip=mSequip.formEquip(equip)
    mUserwar.info.plane=plane

     -- 兵力检测   
    if next (fleetInfo) then
        -- 兵力检测
        if not mTroop.checkWorldWarFleetInfo(fleetInfo, equip) then
            response.ret = -5006
            return response
        end
    end
    mUserwar.info.troops=fleetInfo


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

    local deltroops =getdeltroops(oldtank,mUserwar.info.troops)
    local tank={}
    if  next(deltroops) then
        for k,v in pairs(deltroops) do
            local v =math.ceil(v/userWarCfg.tankeTransRate)
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
                    {desc="异元战减少坦克",value=tank},
                    {desc="异元战上次设置部队",value=oldtank},
                    {desc="异元战本次设置部队",value=fleetInfo},
                }
            }
        ) 
    end
    
    --mAreacrossinfo.info.line={2,1,4}
    --local fleetInfo1,accessoryEffectValue1,herosinfo1 =mTroop.initFleetAttribute(fleetInfo,0,{hero=hero})
    --local binfo=mTroop.getbinfo(fleetInfo1)
    
    local binfo,heroAccessoryInfo=mTroop.gettroopsinfo(mUserwar.info.troops,tmphero, equip, 11,plane)
    mUserwar.binfo=binfo
    mUserwar.name=mUserinfo.nickname
    mUserwar.level=mUserinfo.level
    -- 二次授勋+参加异元战场X次
    mHero.refreshFeat("t11",1,1)
    if cobjs.save(true) and uobjs.save() then 
        if next(tank)  then
            writeLog(uid..'|'..json.encode(tank),'userwartroops') 
        end
        response.data.troops = mTroop.toArray(true)
        response.data.userwarhero = mUserwar.info.hero
        response.ret = 0        
        response.msg = 'Success'
    end


    return response
end