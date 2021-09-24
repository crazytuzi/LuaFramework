--
-- 跨服战信息接口
-- User: luoning
-- Date: 14-9-28
-- Time: 下午3:35
--

function api_across_crossinit(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    if uid == nil then
        response.ret = -102
        return response
    end
    local zid = request.zoneid
    local ref = request.params.ref or 0
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
    local amMatchinfo = mServerbattle.getAcrossBattleInfo()

    if not next(amMatchinfo) then
        response.ret=-21001
        return response
    end

    local ts = getClientTs()
    local weets      = getWeeTs()
    local info =json.decode(amMatchinfo.info)
    local sevCfg=getConfig("serverWarTeamCfg")
    local start =tonumber(amMatchinfo.st)
    start=start+(sevCfg.preparetime+sevCfg.signuptime)*24*3600
   
    --报名结束时间
    local endts =start+sevCfg.applyedtime[1]*3600+sevCfg.applyedtime[2]*60

    require "model.amatches"
    local mMatches = model_amatches()
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", 'acrossinfo','dailytask'})
    local mUserinfo = uobjs.getModel('userinfo')
    local crossainfo=json.decode(amMatchinfo.info)
    --修复数据
    if ts>start-sevCfg.signuptime*24*3600 then
        if type(crossainfo)~='table' or not next (crossainfo) then
                local apiFile = "api.across.finalist"
                require (apiFile)
                api_across_finalist({params={}})
                writeLog("repair alliance" .. amMatchinfo.bid, "across")
        end
    end


    local myround =0
    local mycross ={}
    local battle_at = 0
    local setgems = false
    local carrygems = 0
    -- 拉对阵列表
    if ts>endts then

        local across,round,cross=mMatches.getMatchInfo(zid,mUserinfo.alliance,ref)
        response.data.across=across
        mycross=cross

        if type(mycross)=='table' and  next(mycross) then
            battle_at=tonumber(mycross.battle_at)
        end
        myround=round
        if mUserinfo.usegems>0 then
            if type(mycross) == "table" and next(mycross) then
                if (tonumber(mycross.battle_at) >mUserinfo.usegems_at) then
                    local auserinfo=mMatches.getaMatchUserInfo(mUserinfo.bid,zid,uid,0)
                    if type(auserinfo)=='table' and   auserinfo.data.userinfo then
                        local gems=tonumber(auserinfo.data.userinfo.gems)
                        if mUserinfo.usegems>gems and auserinfo.data.userinfo.gems~=nil then
                            -- 日常任务
                            local mDailyTask = uobjs.getModel('dailytask')
                            mDailyTask.changeTaskNum(7)

                            -- 活动
                            activity_setopt(uid,'wheelFortune',{value=mUserinfo.usegems-gems},true)
                            activity_setopt(uid,'wheelFortune2',{value=mUserinfo.usegems-gems},true)

                            mUserinfo.usegems=gems
                            carrygems=gems
                        end
                    else
                       carrygems=mUserinfo.usegems    
                    end
                    mUserinfo.usegems_at=ts
                    setgems=true

                end
            end
        end
    end
    if mUserinfo.alliance > 0 then
        if type (crossainfo)=='table' and next(crossainfo) then
            for k,v in pairs(crossainfo) do
                if v[1]==mUserinfo.alliance then
                    local acrossserver = require "model.acrossserverin"
                    local across = acrossserver.new()
                    local ApplyData =across:getAllianceApplyData(amMatchinfo.bid,getZoneId(),mUserinfo.alliance)
                    if type(ApplyData)=='table' and next(ApplyData) then
                        if battle_at>= tonumber(ApplyData.donate_at) and tonumber(ApplyData.donate_at)~=0  then
                            ApplyData.donate_at=ts
                            ApplyData.basetroops=""
                            ApplyData.basedonatenum=0
                            local redis = getRedis()
                            local redisKey =zid.."alliancebattle.across.donate"..mUserinfo.alliance.."bid"..amMatchinfo.bid
                            redis:set(redisKey,0)
                            --清空自己的捐献的部队
                            local ret =across:updateAllianceData(ApplyData)
                            if not ret then
                                response.ret= -21014
                                return response
                            end
                        end
                        response.data.applydata=ApplyData
                        response.data.applydata.teams=json.decode(ApplyData.teams)
                        response.data.applydata.servers=nil
                        response.data.applydata.basetroops=json.decode(ApplyData.basetroops)
                        local myapplydata=across:getUserDataFromDb(amMatchinfo.bid,zid,mUserinfo.alliance,uid)
                        if type(myapplydata)=='table' and  next(myapplydata) then
                            myapplydata.troops=json.decode(myapplydata.troops)
                            --修改自己的跨服数据
                            if setgems then
                                myapplydata.gems=carrygems
                                local data = myapplydata
                                data.gems  = carrygems
                                if carrygems<=0 then 
                                    local usercarrygems=tonumber(myapplydata.carrygems)
                                    data.usegems=tonumber(myapplydata.usegems)+(usercarrygems-mUserinfo.usegems)
                                end
                                local ret =across:updateUserBattleData(data)
                                if not ret then
                                    response.ret=-21012
                                    return response
                                end
                            end
                            -- 自己的数据和跨服数据对不上
                            if mUserinfo.usegems~= tonumber(myapplydata.gems) then
                                myapplydata.gems=mUserinfo.usegems
                            end

                            myapplydata.hero=json.decode(myapplydata.hero)
                            myapplydata.binfo = json.decode( myapplydata.binfo )
                            if type(myapplydata.binfo) == 'table' then
                                myapplydata.equip=myapplydata.binfo[4] or 0
                            end
                            if myapplydata.binfo  and  type(myapplydata.binfo[5])=="table"  and  myapplydata.binfo[5][1] then
                                myapplydata.plane=myapplydata.binfo[5][1]
                            end
                            myapplydata.binfo=nil
                            response.data.mydata=myapplydata
                        end
                    end
                    break
                end
            end
        end
    end 
    --如果反金币 要保存
    if setgems then
        if not uobjs.save() then    
           return response
        end
    end

    -- 军团跨服战称号
    local aCrossinfo = uobjs.getModel('acrossinfo')
    response.data.acrossfirst = aCrossinfo.getFirst()

    local function gate(bid)
        local bid = tonumber(string.sub(bid, 2)) 
        local config = getConfig("config")
        local connector = config.areacrossserver.connector

        local n = bid % #connector
        if n == 0 then n = #connector end

        return connector[n].connect
    end
            
    local acrossconfig = getConfig("config.z"..getZoneId()..".across")
    -- response.data.host ={host=acrossconfig.host,port=acrossconfig.port}    
    response.data.host = gate(amMatchinfo.bid)
    response.data.st = amMatchinfo.st
    response.data.et = amMatchinfo.et
    response.data.matchId =amMatchinfo.bid
    response.data.servers =json.decode(amMatchinfo.servers)
    response.data.crossainfo =crossainfo
    response.ret=0
    response.msg='Success'
    return response
end
