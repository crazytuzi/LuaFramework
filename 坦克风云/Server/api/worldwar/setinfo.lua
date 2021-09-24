--  设置世界大战部队
--  lmh
function api_worldwar_setinfo(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local hero  =request.params.hero
    local equip = request.params.equip
    local plane = request.params.plane
    if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","wcrossinfo"})
    local mTroop = uobjs.getModel('troops')
    local mCrossinfo = uobjs.getModel('wcrossinfo')
    local fleet = request.params.fleetinfo or {}
    local line = request.params.line or 1
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

    if clear~=1 and totalTanks<1 then
        response.ret=-5006
        return response
    end

    local method = request.params.join   or 1 
    local mUserinfo = uobjs.getModel('userinfo')
    local ts = getClientTs()
    local sevCfg=getConfig("worldWarCfg")
    local zoneid=tonumber(request.zoneid)
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
        --世界大战基本信息
    local mMatchinfo= mServerbattle.getWorldWarBattleInfo()
    if not next(mMatchinfo)  then
        return response
    end
   
    -- 检测是否报名
    local worldserver = require "model.worldserverin"
    local cross = worldserver.new()
    local ApplyData =cross:getUserApplyData(mMatchinfo.bid,zoneid,uid)
    if type (ApplyData)=='table' and not next(ApplyData) then
        response.ret=-22002
        return response
    end
    require "model.wmatches"
    local mMatches = model_wmatches()
    if not next(mMatches.base) then
        response.ret = mMatches.errorCode
        return response
    end
    local jointype=tonumber(ApplyData.jointype)
    local weeTs=getWeeTs()
    local start =tonumber(mMatchinfo.st)
    local endts=start+sevCfg.signuptime*24*3600
    local setTroopsLimit=sevCfg.setTroopsLimit
    local isTmatch = false

    -- 积分判断设置部队
    if ts>endts  and ts <(endts+sevCfg.pmatchdays*24*3600 - 3*3600) then
        local pmatchstarttime=sevCfg["pmatchstarttime"..jointype]
        local pmatchendtime=sevCfg["pmatchendtime"..jointype]
        local st=weeTs+pmatchstarttime[1]*3600+pmatchstarttime[2]*60-setTroopsLimit
        local et=weeTs+pmatchendtime[1]*3600+pmatchendtime[2]*60
        if ts>=st  and  ts<=et then
            response.ret=-22016
            return response
        end
    end

    -- 淘汰赛是判断
    if ts >(endts+sevCfg.pmatchdays*24*3600 - 3*3600) then
        mMatches.getMultInfo(jointype)
        local tmatch=tonumber(mMatches.getMyRoundTmatch(uid,zoneid,jointype))
        if tmatch <=0 then
            return response
        end
        if tmatch%2==0 then
            tmatch=2
        else
            tmatch=1
        end
        local pmatchstarttime=sevCfg["tmatch"..tmatch.."starttime"..jointype]
        local st=weeTs+pmatchstarttime[1]*3600+pmatchstarttime[2]*60-setTroopsLimit
        local et=weeTs+pmatchstarttime[1]*3600+pmatchstarttime[2]*60+sevCfg.battleTime*3
        if ts>=st and  ts<=et then
            response.ret=-22016
            return response
        end
        isTmatch = true
    end

    --ptb:p(ApplyData)
    local tinfo =json.decode(ApplyData.tinfo)
    if isTmatch and tonumber(ApplyData.eliminateTroopsFlag) ~= 1 then
        tinfo = {}
    end

    if type(tinfo)~='table' then  tinfo={} end
    if type(tinfo.flag)~='table' then  tinfo.flag={1,1,1} end
    if type(tinfo.hero)~='table' then  tinfo.hero={{},{},{}} end
    if  type(tinfo.troops)~='table' then tinfo.troops={{},{},{}}   end
    if  type(tinfo.ts)~='table' then tinfo.ts={0,0,0}   end
    if type(tinfo.equip)~='table' then tinfo.equip={0,0,0} end
    if type(tinfo.plane)~='table' then tinfo.plane={0,0,0} end
    local oldtank=copyTab(tinfo.troops[line])
    local function getbattlehero(hid,line)
        local flag = true
        if next(tinfo.hero) then
                for k,v in pairs(tinfo.hero) do
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
       tinfo.hero[line]={}
       hero={}     
    end
    -- chek end

    local mSequip = uobjs.getModel('sequip')

    tinfo.hero[line]=hero
    tinfo.troops[line]=fleetInfo
    tinfo.equip[line]=mSequip.formEquip(equip)
    tinfo.plane[line]=plane or 0

    if equip and not mSequip.checkkuafu(tinfo.equip,line,equip) then
        response.ret = -27011
        return response
    end
    
    -- check equip
    -- if equip and not mSequip.checkEquipStats( tinfo.equip,equip ) then
    --     response.ret=-8650 
    --     return response        
    -- end

    --飞机做检测
    local mPlane = uobjs.getModel('plane')
    if plane and not mPlane.checkPlaneStats( tinfo.plane,plane,line) then
        response.ret=-12110
        return response        
    end

     -- 兵力检测
    if next (fleetInfo) then
        if not mTroop.checkWorldWarFleetInfo(fleetInfo, equip) then
            response.ret = -5006
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

    local deltroops =getdeltroops(oldtank,tinfo.troops[line])
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
        local bid =mMatchinfo.bid
        if type(mCrossinfo.pointlog.del)~='table' then mCrossinfo.pointlog.del={}  end
        --把旧的重置一下
        if mCrossinfo.pointlog.del[bid]==nil or type(mCrossinfo.pointlog.del[bid])~='table' then 
            mCrossinfo.pointlog.del={}   
            mCrossinfo.pointlog.del[bid]={et=tonumber(mMatchinfo.et),tank={}}
        end
        if type(mCrossinfo.pointlog.del[bid].tank)~='table' then mCrossinfo.pointlog.del[bid].tank={} end
        local tmp={o=oldtank,n=tinfo.troops[line],d=tank,t=ts}
        table.insert(mCrossinfo.pointlog.del[bid].tank,tmp)
        response.data.troops = mTroop.toArray(true)

        regKfkLogs(uid,'tankChange',{
                addition={
                    {desc="世界大战减少坦克",value=tank},
                    {desc="世界大战上次设置部队",value=oldtank},
                    {desc="世界大战本次设置部队",value=tinfo.troops[line]},
                }
            }
        ) 

    end
    
    tinfo.flag[line]=2
    local troops = tinfo.troops   
    local setline=json.decode(ApplyData.line)
    local binfo,flag=mTroop.getFleetdata(tinfo.troops[1],tinfo.troops[2],tinfo.troops[3],tinfo.hero,nil,nil,tinfo.equip,tinfo.plane)
    if setline~=nil and next(setline) then
        binfo,flag=mTroop.getFleetdata(tinfo.troops[setline[1]],tinfo.troops[setline[2]],tinfo.troops[setline[3]],tinfo.hero,setline,nil,tinfo.equip,tinfo.plane)
    end
    tinfo.flag=flag
    local data={}
    data.uid=uid
    data.bid=mMatchinfo.bid
    data.zid=zoneid
    data.level=mUserinfo.level
    data.nickname=mUserinfo.nickname
    data.pic=mUserinfo.pic
    data.bpic=mUserinfo.bpic
    data.apic=mUserinfo.apic
    data.rank=mUserinfo.rank
    data.fc=mUserinfo.fc
    data.binfo=binfo
    data.jointype=tonumber(ApplyData.jointype)
    -- print(isTmatch, ApplyData.eliminateTroopsFlag  )
    if isTmatch and ApplyData.eliminateTroopsFlag ~= 1 then
        data.eliminateTroopsFlag = 1
    end    
    local senddata={cmd='worldserver.setuser',params={data=data,action='update'}}
    local config = getConfig("config.z"..getZoneId()..".worldwar")
    local flag = false
    for i=1,5 do
        
        local ret=sendGameserver(config.host,config.port,senddata)
        if ret.ret==0 then
            flag=true
            break
        end
    end


    local ts=getClientTs()
    if not flag then
        writeLog("host=="..config.host..config.host.."params=="..json.encode(params),'setcrosserror')
        response.ret = -22005 
        return response
    end
    --ptb:e(params)
    data.binfo=json.encode(binfo)
    if type(tinfo.ts)~='table' then  tinfo.ts={0,0,0} end
    tinfo.ts[line]=ts
    data.tinfo=json.encode(tinfo)
    local ret = cross:updateUserApplyData(ApplyData.id,data)
    if not ret then
        response.ret=-22005 
        return response
    end

    if uobjs.save() then 
        if next(tank)  then
            writeLog(uid..'|'..json.encode(tank),'worldwartroops') 
        end

        response.ret = 0        
        response.msg = 'Success'
    end


    return response

end