-- 设置部队

function api_areawar_setinfo(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = tonumber(request.uid)
    local hero  = request.params.hero or {}
    local fleet = request.params.fleetinfo or {}
    local wcount= tonumber(request.params.wcount) or 0
    local waid  = tonumber(request.params.waid) or 0
    local acount=tonumber(request.params.acount) or 0
    local equip = request.params.equip
    local plane = request.params.plane

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","hero","troops","userareawar"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop    = uobjs.getModel('troops') 
    local mUserareawar=uobjs.getModel('userareawar') 
    local mSequip = uobjs.getModel('sequip')
    local mPlane = uobjs.getModel('plane')
    
    if uid == nil or mUserinfo.alliance<0 then
        response.ret = -102
        return response
    end
    -- check equip
    if equip and not mSequip.checkFleetEquipStats(equip)  then
        response.ret=-8650 
        return response
    end

    local function gettroopsinfo(mTroop,fleet,hero,equip,addbuff,plane) 
        if not next(fleet) then
            return {}
        end
        local fleetInfo1,accessoryEffectValue1,herosinfo1,planevalue1 =mTroop.initFleetAttribute(fleet,11,{hero=hero,equip=equip,plane=plane})
        local result={{},{},{}}
        local keys={}
        for i=1,6 do
            local flag=false
            if type(fleetInfo1[i])=='table' and next(fleetInfo1[i]) then
                local isHero = false

                for k,v in pairs (fleetInfo1[i]) do 
                    if flag==false then  
                        table.insert(keys,k)
                    end
                    if k=="dmg"  and  addbuff.dmg~=nil  then
                        fleetInfo1[i][k]=math.floor(fleetInfo1[i][k] * (1+addbuff.dmg))
                    end  

                    if k == "maxhp"  and  addbuff.maxhp~=nil   then
                        fleetInfo1[i][k] = math.floor(fleetInfo1[i][k] * (1+addbuff.maxhp))
                        fleetInfo1[i].hp = math.floor(fleetInfo1[i].num * fleetInfo1[i][k])
                    end    

                    if k == 'hero' then isHero = true end
                end 
                if flag==false then
                    if not isHero then table.insert(keys,'hero') end
                end
                flag=true
                if not next(addbuff) then
                    break
                end
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
                        if type(v1[v])=='number' then
                            troops[1][k1][k]=math.ceil(v1[v]*1000)/1000
                        end
                    end
                    
                end
        end
        result[2]=troops
        result[4] = mSequip.formEquip(equip)
        result[5] = planevalue1 or {}
        --result[4]={accessoryEffectValue1,herosinfo1}
        return result,{accessoryEffectValue1,herosinfo1,planevalue1}
    end
    local data={}
    local ts = getClientTs()
    local weets  = getWeeTs()
    local joinAtData,code = M_alliance.getuseralliance{uid=uid,aid=mUserinfo.alliance}
    local joinAt = 0
    local role=nil
    if type(joinAtData) == 'table' and joinAtData['ret'] == 0 then
        joinAt = tonumber(joinAtData['data']['join_at']) or 0
        role   = tonumber(joinAtData['data']['role']) or nil
    end
    local EndAt=getAreaApplyEndAt()
    if joinAt>EndAt or  joinAt==0 then
        response.ret = -23013
        return response
    end
    local totalTanks = 0
    local fleetInfo = {}
    if next(fleet) then
        
        
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
            if not mTroop.checkWorldWarFleetInfo(fleetInfo, equip) then
                response.ret = -5006
                return response
            end
        end

    end
    if totalTanks<1 then
        response.ret=-5006
        return response
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

    local redis = getRedis()
    local bid =getAreaWarId(EndAt)

    if tostring(mUserareawar.bid)~=tostring(bid) or mUserareawar.aid~=mUserinfo.alliance then
        mUserareawar.reset()
        mUserareawar.bid=bid
        mUserareawar.aid=mUserinfo.alliance
    end
    local key="areawar.members."..bid
    local oldtank=mUserareawar.info.troops or {}
    local sevCfg=getConfig("areaWarCfg")
    local deltroops =getdeltroops(oldtank,fleetInfo)

    local battleday=sevCfg.prepareTime+sevCfg.battleTime
    local weekday=tonumber(getDateByTimeZone(ts,"%w"))
    local endTs=0
    if battleday>=weekday then
        --加上战斗结束时间
        endTs=weets+sevCfg['startWarTime'][1]*3600+sevCfg['startWarTime'][2]*60+sevCfg['maxBattleTime']
    else
        endTs=weets+sevCfg['startWarTime'][1]*3600+sevCfg['startWarTime'][2]*60+86400+sevCfg['maxBattleTime']
    end



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
                    {desc="区域战减少坦克",value=tank},
                    {desc="区域战上次设置部队",value=oldtank},
                    {desc="区域战本次设置部队",value=fleetInfo},
                }
            }
        ) 
        
        response.data.troops = mTroop.toArray(true)
    end
    -- 额外的加成
    local addbuff={} 
    if waid>0 then
       
        if mUserinfo.alliance~=waid then
            if acount>0 then
                addbuff.dmg=(addbuff.dmg or 0)+0.05 * acount
                addbuff.maxhp=(addbuff.maxhp or 0)+0.05 * acount
            end
            if wcount>0 then
                addbuff.dmg=(addbuff.dmg or 0)+wcount/(wcount+5)
                addbuff.maxhp=(addbuff.maxhp or 0)+wcount/(wcount+5)
            end
        end
    end

    local binfo,heroAccessoryInfo = gettroopsinfo(mTroop,fleetInfo,hero,equip,addbuff,plane)
    data.nickname=mUserinfo.nickname
    data.pic=mUserinfo.pic
    data.level=mUserinfo.level
    data.rank =mUserinfo.rank
    data.aid=mUserinfo.alliance
    data.alliancename=mUserinfo.alliancename
    data.binfo=binfo
    data.troops=fleetInfo
    data.hero=hero
    data.role=role
    data.equip=mSequip.formEquip(equip)
    data.plane=plane
    --data.heroAccessoryInfo=heroAccessoryInfo
    mUserareawar.info.troops=data.troops
    mUserareawar.info.hero=data.hero
	mUserareawar.info.equip=data.equip
    mUserareawar.info.plane = plane
    if uobjs.save() then
        if next(tank)  then
            writeLog(uid..'|'..json.encode(tank),'areawartroops') 
        end
        local ret=redis:hset(key,uid,json.encode(data))
        redis:expireat(key, EndAt+7*86400)
        if ts<=endTs then
            local mAreaWar = require "model.areawar"
            mAreaWar.construct()
            -- 反复设置部队时,只有开战前才能更新用户行动信息
            if ts <= (endTs - sevCfg['maxBattleTime']) then
           	 mAreaWar.setUserActionTroops(bid,uid,binfo,fleetInfo)
            end
            mAreaWar.joinAreaWar(bid,uid,data.aid)
        end
        response.ret = 0
        response.msg = 'Success'
    end
    return response

end
