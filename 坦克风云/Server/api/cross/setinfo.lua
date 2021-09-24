
function api_cross_setinfo(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local aName =request.params.aName or ""
    local hero  =request.params.hero
    local equip = request.params.equip
    local plane = request.params.plane
    if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive','crossinfo'})
    local mCrossinfo = uobjs.getModel('crossinfo')

    local mTroop = uobjs.getModel('troops')
    local mSequip = uobjs.getModel('sequip')
    local fleet = request.params.fleetinfo or {}
    local line = request.params.line or 1
    local clear = request.params.clear or 0
    if uid <= 0 then
        response.ret = -102
        return response
    end

    if not next(fleet) and clear~=1 then
        response.ret = -10002
        return response
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

    -- 兵力检测
    if next (fleetInfo) then
        if not mTroop.checkWorldWarFleetInfo(fleetInfo,equip) then
            response.ret = -5006
            return response
        end
    end
        
    if clear~=1 and totalTanks<1 then
        response.ret=-5006
        return response
    end
   
    if type(mCrossinfo.battle)~='table' then  mCrossinfo.battle={} end
    if type(mCrossinfo.battle.flag)~='table' then  mCrossinfo.battle.flag={1,1,1} end
    if type(mCrossinfo.battle.hero)~='table' then  mCrossinfo.battle.hero={{},{},{}} end
    if type(mCrossinfo.battle.troops)~='table' then mCrossinfo.battle.troops={{},{},{}}   end
    if type(mCrossinfo.battle.line)~='table' then mCrossinfo.battle.line={1,2,3}   end
    if type(mCrossinfo.battle.equip)~='table' then mCrossinfo.battle.equip={0,0,0} end
    if type(mCrossinfo.battle.plane)~='table' then mCrossinfo.battle.plane={0,0,0} end
    local function getbattlehero(hid,line)
        local flag = true
        if next(mCrossinfo.battle.hero) then
                for k,v in pairs(mCrossinfo.battle.hero) do
                    if next(v) and k~=line then
                        for k1,v1 in pairs(v) do
                            if v1==hid then
                                flag=false
                                return flag
                            end
                        end
                    end
                end

        end
        return flag
    end    
    local mUserinfo = uobjs.getModel('userinfo')
    local mHero     = uobjs.getModel('hero')

     -- check hero
    if type(hero)=='table' and next(hero) then
        hero =mHero.checkFleetHeroStats(hero)
        if hero==false then
            response.ret=-11016 
            return response
        end
        if next(hero) then
            for k,v in pairs(hero) do
                if v~=0 then 
                    --检测以设置过的英雄是否有重复
                    local ret = getbattlehero(v,line)
                    if not ret then
                        hero[k]=0
                    end
                end
            end
        end
    else
       mCrossinfo.battle.hero[line]={}
       hero={}     
    end
    -- chek end

    -- check equip
    mCrossinfo.battle.equip[line] = mSequip.formEquip(equip) -- 设置装备大师的格式
    -- 检测个部队中是否有重复的超级装备
    if equip and not mSequip.checkkuafu(mCrossinfo.battle.equip,line,equip) then
        response.ret = -27011
        return response
    end
    
    -- if equip and not mSequip.checkEquipStats(mCrossinfo.battle.equip,equip)  then
    --     response.ret=-8650 
    --     return response
    -- end

     --飞机做检测
    local mPlane = uobjs.getModel('plane')
    mCrossinfo.battle.plane[line]=plane or 0
    if plane and not mPlane.checkPlaneStats( mCrossinfo.battle.plane,plane,line) then
        response.ret=-12110
        return response        
    end
  

    local oldtank = mCrossinfo.battle.troops[line]

    mCrossinfo.battle.hero[line]=hero
    mCrossinfo.battle.troops[line]=fleetInfo
    if clear==1 then
        mCrossinfo.battle.troops={{},{},{}} 
        mCrossinfo.battle.hero={{},{},{}}
        mCrossinfo.battle.plane={0,0,0}
        mCrossinfo.battle.equip={0,0,0}
    end
    -- 检测是否有所有的坦克
    -- if not mTroop.checkFleetInfoStats(mCrossinfo.battle.troops) then
    --     response.ret = -5015
    --     return response
    -- end
     -- 兵力检测
    -- if next (fleetInfo) then
    --     if not mTroop.checkFleetInfo(fleetInfo) then
    --         response.ret = -5006
    --         return response
    --     end
    -- end

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

    -- 1:100 扣除坦克
    local deltroops =getdeltroops(oldtank,fleetInfo)
    local sevCfg=getConfig("serverWarPersonalCfg")
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
                    {desc="个人跨服战减少坦克",value=tank},
                    {desc="个人跨服战上次设置部队",value=oldtank},
                    {desc="个人跨服战本次设置部队",value=fleetInfo},
                    {desc="个人跨服战位置",value=line},
                }
            }
        ) 
        
        response.data.troops = mTroop.toArray(true)
    end

    local troops = mCrossinfo.battle.troops   
    local params=mCrossinfo.getlastdata(aName,mCrossinfo.battle.troops[mCrossinfo.battle.line[1]],mCrossinfo.battle.troops[mCrossinfo.battle.line[2]],mCrossinfo.battle.troops[mCrossinfo.battle.line[3]],mCrossinfo.battle.hero,mCrossinfo.battle.equip,mCrossinfo.battle.plane)

    local data={cmd='crossserver.setuser',params={udata={params}}}
    local config = getConfig("config.z"..getZoneId()..".cross")
    local flag = false
    for i=1,5 do
        
        local ret=sendGameserver(config.host,config.port,data)
        if ret.ret==0 then
            flag=true
            break
        end
    end
   
    local ts=getClientTs()
    if not flag then
        
        writeLog("host=="..config.host..config.host.."params=="..json.encode(params),'setcrosserror')
        response.ret = -20020
        return response
    end
    --ptb:e(params)
    if type(mCrossinfo.battle.ts)~='table' then  mCrossinfo.battle.ts={0,0,0} end

    mCrossinfo.battle.ts[line]=ts
    mCrossinfo.battle.flag[line]=2
    processEventsBeforeSave()
    if uobjs.save() then
        if next(tank)  then
            writeLog(uid..'|'..json.encode(tank),'serverwarpersontroops') 
        end        
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    end

    return response

end