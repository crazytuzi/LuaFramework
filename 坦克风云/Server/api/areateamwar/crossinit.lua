-- 初始化

function api_areateamwar_crossinit(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = tonumber(request.uid)
    local zid = request.zoneid
    local ref = request.params.ref or 0
    if uid == nil   then
        response.ret = -102
        return response
    end


    
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
    --缓存跨服区域战的基本信息
    local mMatchinfo= mServerbattle.getserverareabattlecfg()
    if not next(mMatchinfo)  then
        return response
    end
    local ts = getClientTs()
    local weets      = getWeeTs()
    local sevCfg = getConfig('serverAreaWarCfg')
    local start =tonumber(mMatchinfo.st)
    start=start+(sevCfg.signuptime*24*3600+5)
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","hero","troops","areacrossinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop    = uobjs.getModel('troops') 
    local mAreacrossinfo    = uobjs.getModel('areacrossinfo') 
    local setgems=false
    if mAreacrossinfo.bid ~=mMatchinfo.bid then
       setgems=true
       mAreacrossinfo.init(mMatchinfo.bid)
    end
    
    if  ts>start then 
        require "model.areamatches"
        local mMatches = model_areamatches()

        local across,round,cross=mMatches.getbattlestats(zid,mUserinfo.alliance,ref)
        response.data.across=across
        -- 结束后加胜利军团的奖励
        local win= mAreacrossinfo.info.win or 0
        if  across and round>0 and win==0 and across.over==1  then
            if type(cross)=='table' and  cross[3]~=nil then
                local rank=tonumber(cross[3])
                local rankpoint=0
                for  k,v in pairs (sevCfg.AllianceReward) do 
                    if rank>=v["range"][1] and rank<=v["range"][2] then
                        rankpoint=v["point"]
                        break
                    end
                end
                mAreacrossinfo.addpoint(rankpoint,rank)
                mAreacrossinfo.info.win=1
                setgems=true
            end

            
        end
        
        if type(cross) == "table" and next(cross) then
                if (tonumber(cross[2]) >mAreacrossinfo.usegems_at) and  next(mAreacrossinfo.info) then
                    local auserinfo=mMatches.getaMatchUserInfo(mUserinfo.alliance,zid,uid)
                    if type(auserinfo)=='table' and   auserinfo.data.userinfo then
                        setgems=true
                        mAreacrossinfo.usegems_at=ts
                        local gems=tonumber(auserinfo.data.userinfo.gems)
                        local point=tonumber(auserinfo.data.userinfo.point)
                        local addpoint=mAreacrossinfo.info.point or 0
                        if (point-addpoint)>0 then
                            mAreacrossinfo.addpoint(point-addpoint,9)
                            mAreacrossinfo.info.point=(mAreacrossinfo.info.point or 0) +(point-addpoint)
                            
                        end
                        if mAreacrossinfo.gems>gems and auserinfo.data.userinfo.gems~=nil then
                            -- 日常任务
                            local mDailyTask = uobjs.getModel('dailytask')
                            mDailyTask.changeTaskNum(7)

                            -- 活动
                            activity_setopt(uid,'wheelFortune',{value=mAreacrossinfo.gems-gems},true)
                            activity_setopt(uid,'wheelFortune2',{value=mAreacrossinfo.gems-gems},true)
                            activity_setopt(uid,'xiaofeisongli',{value=mAreacrossinfo.gems-gems})
                            activity_setopt(uid,'danrixiaofei',{value=mAreacrossinfo.gems-gems})
                            mAreacrossinfo.usegems=mAreacrossinfo.usegems+(mAreacrossinfo.gems-gems)
                            mAreacrossinfo.gems=gems
                        end
                    
                    end
                end
        end
        


    end
    --+sevCfg.startWarTime[1]*3600+sevCfg,startWarTime[1]

    if setgems then
        if not uobjs.save() then    
           return response
        end
    end

    local function gate(bid)
        local bid = tonumber(string.sub(bid, 2)) 
        local config = getConfig("config")
        local connector = config.areacrossserver.connector

        local n = bid % #connector
        if n == 0 then n = #connector end

        return connector[n].connect
    end

    response.data.areacrossinfo=mAreacrossinfo.toArray(true)
    response.data.areacrossinfo.pointlog=nil
    response.data.st = mMatchinfo.st
    response.data.et = mMatchinfo.et
    response.data.matchId =mMatchinfo.bid
    response.data.servers =json.decode(mMatchinfo.servers)
    local areacrossserver=getConfig("config.areacrossserver")
    response.data.httphost = areacrossserver.httphost
    -- response.data.host = areacrossserver.connect
    response.data.host = gate(mMatchinfo.bid)
    response.data.areawarFirst = mAreacrossinfo.getFirst()
    response.ret=0
    response.msg='Success'
    return response


end