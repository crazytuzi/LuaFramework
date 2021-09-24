--1 服内的设置部队and跨服的设置部队

function api_areateamwar_setinfo(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local zid = request.zoneid
    local aName =request.params.aName or ""
    local hero  =request.params.hero or {}
    local fleet = request.params.fleetinfo or {}
    local clear = request.params.clear or 0
    local usegems=request.params.usegems or 0 
    local line =  tonumber(request.params.line) or 1
    local group =request.params.group 
    local equip = request.params.equip
    local plane = request.params.plane
    

    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
        --缓存跨服军团战的基本信息
    local mMatchinfo= mServerbattle.getserverareabattlecfg()
    if not next(mMatchinfo)  then
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","hero","troops","areacrossinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop    = uobjs.getModel('troops') 
    local mAreacrossinfo    = uobjs.getModel('areacrossinfo') 
    local mHero     = uobjs.getModel('hero')
    local sevCfg=getConfig("serverAreaWarCfg")

    if uid == nil or mUserinfo.alliance<0 or line<=0 then
        response.ret = -102
        return response
    end
    local action='update'
    local joinAtData,code = M_alliance.getuseralliance{uid=uid,aid=mUserinfo.alliance}
    local joinAt = 0
    local role=nil
    if type(joinAtData) == 'table' and joinAtData['ret'] == 0 then
        joinAt = tonumber(joinAtData['data']['join_at']) or 0
        role   = tonumber(joinAtData['data']['role']) or nil
    end
    local EndAt=tonumber(mMatchinfo.st)+(sevCfg.signuptime*24*3600)
    if joinAt>EndAt or  joinAt==0 then
        response.ret = -23013
        return response
    end
    if mAreacrossinfo.gems~=nil and mAreacrossinfo.gems>0 then
        if mAreacrossinfo.bid~=mMatchinfo.bid  then
            response.ret=-21021
            return response
        end
    end
    if mAreacrossinfo.bid ~=mMatchinfo.bid then
        action='apply'
        mAreacrossinfo.init(mMatchinfo.bid)
    end

    require "model.areamatches"

    local mMatches = model_areamatches()
    local across,round,cross=mMatches.getbattlestats(zid,mUserinfo.alliance,0)
    if  type(cross) ~= "table" or   not next(cross)  then
        response.ret=-23106
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
    if next(fleetInfo) then
        if clear~=1 and totalTanks<1 then
            response.ret=-5006
            return response
        end
    end
    if type(mAreacrossinfo.info)~='table' then  mAreacrossinfo.info={} end
    if type(mAreacrossinfo.info.hero)~='table' then  mAreacrossinfo.info.hero={{},{},{}} end
    if  type(mAreacrossinfo.info.troops)~='table' then mAreacrossinfo.info.troops={{},{},{}}  action='apply' end
    if  type(mAreacrossinfo.info.ts)~='table' then mAreacrossinfo.info.ts={0,0,0}   end
    if type(mAreacrossinfo.info.equip)~='table' then mAreacrossinfo.info.equip = {0,0,0} end
    if type(mAreacrossinfo.info.plane)~='table' then mAreacrossinfo.info.plane = {0,0,0} end
    

    local oldtank=copyTab(mAreacrossinfo.info.troops[line])

    local function getbattlehero(hid,line)
        local flag = true
        if next(mAreacrossinfo.info.hero) then
                for k,v in pairs(mAreacrossinfo.info.hero) do
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
     -- check hero
    if type(hero)=='table' and next(hero) then
        local herofalg =mHero.checkFleetHeroStats(hero)
        if herofalg==false then
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
        mAreacrossinfo.info.hero[line]=hero   
    end
  
    
    
    if clear==1 then
        mAreacrossinfo.info.troops={{},{},{}} 
        mAreacrossinfo.info.hero={{},{},{}}
        mAreacrossinfo.info.equip={0,0,0}
        mAreacrossinfo.info.plane={0,0,0}
    end

     -- 兵力检测 
    local sn=nil    
    if next (fleetInfo) then
        if not mTroop.checkWorldWarFleetInfo(fleetInfo,equip) then
            response.ret = -5006
            return response
        end
        sn=line
        mAreacrossinfo.info.troops[line]=fleetInfo
    end

    if usegems == 0 then
        -- 军徽(超级装备)检测
        local mSequip = uobjs.getModel('sequip')
        mAreacrossinfo.info.equip[line]=mSequip.formEquip(equip)

        if equip and not mSequip.checkkuafu(mAreacrossinfo.info.equip,line,equip) then
            response.ret=-8650 
            return response   
        end
        -- if equip and not mSequip.checkEquipStats( mAreacrossinfo.info.equip,equip ) then
        --     response.ret=-8650 
        --     return response        
        -- end

        --飞机做检测
	    local mPlane = uobjs.getModel('plane')
	    mAreacrossinfo.info.plane[line]=plane or 0
	    if plane and not mPlane.checkPlaneStats( mAreacrossinfo.info.plane,plane,line) then
	        response.ret=-12110
	        return response        
	    end
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

    local deltroops =getdeltroops(oldtank,mAreacrossinfo.info.troops[line])
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
                    {desc="跨服区域战减少坦克",value=tank},
                    {desc="跨服区域战上次设置部队",value=oldtank},
                    {desc="跨服区域战本次设置部队",value=fleetInfo},
                }
            }
        ) 
        
        
    end
    
    --mAreacrossinfo.info.line={2,1,4}

    --local fleetInfo1,accessoryEffectValue1,herosinfo1 =mTroop.initFleetAttribute(fleetInfo,0,{hero=hero})
    --local binfo=mTroop.getbinfo(fleetInfo1)
    local binfo,lines,heroAccessoryInfo=mTroop.getFleetdata(mAreacrossinfo.info.troops[1],mAreacrossinfo.info.troops[2],mAreacrossinfo.info.troops[3],mAreacrossinfo.info.hero,nil,"areateamwar",mAreacrossinfo.info.equip,mAreacrossinfo.info.plane)
    local data={}
    data.uid=uid
    data.bid=mAreacrossinfo.bid
    data.aid=mUserinfo.alliance
    data.zid=getZoneId()
    data.level=mUserinfo.level
    data.nickname=mUserinfo.nickname
    data.pic=mUserinfo.pic
    data.rank=mUserinfo.rank
    data.fc=mUserinfo.fc
    data.aname=mUserinfo.alliancename
    data.role=role
    data.binfo=binfo
    --data.heroAccessoryInfo=heroAccessoryInfo
    data.servers=json.decode(mMatchinfo.servers)
    if clear==1 then
        data.binfo={}
        data.heroAccessoryInfo={}
    end
    
    if usegems>0 then
        data.binfo=nil
        data.heroAccessoryInfo=nil
        data.addgems=usegems
        mAreacrossinfo.gems=mAreacrossinfo.gems+usegems
        if not mUserinfo.useResource({gems=usegems}) then
            response.ret = -109 
            return response
        end
         regActionLogs(uid,1,{action=207,item="",value=usegems,params={}})
    end
 
    local senddata={cmd='areateamwarserver.setuser',params={data=data,action=action,sn=sn,group=group}}
    local config = getConfig("config.areacrossserver.connect")
    local flag = false
    for i=1,1 do
            local ret=sendGameserver(config.host,config.port,senddata)
            response.ret=-1
            if ret and  ret.ret==0 then
                flag=true
                break
            end
            response.ret=ret.ret
    end
       
    if not flag then
        return response
    end

    local ts=getClientTs()
    mAreacrossinfo.info.ts[line]=ts

    if uobjs.save() then 
        if next(tank)  then
            writeLog(uid..'|'..json.encode(tank),'serverareawartroops') 
        end
        response.ret = 0        
        response.msg = 'Success'
        response.data.areacrossinfo=mAreacrossinfo.toArray(true)
        response.data.areacrossinfo.pointlog=nil
        response.data.troops = mTroop.toArray(true)
    end


    return response

end