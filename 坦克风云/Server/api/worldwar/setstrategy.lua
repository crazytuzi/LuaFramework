-- 设置策略

function api_worldwar_setstrategy(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local ts = getClientTs()
    local strategy=request.params.strategy 
    local line    =request.params.line 
    local sevCfg=getConfig("worldWarCfg")
    local zoneid=request.zoneid
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
        --世界大战基本信息
    local mMatchinfo= mServerbattle.getWorldWarBattleInfo()
    if not next(mMatchinfo)  then
        return response
    end
   
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", 'wcrossinfo','troops'})
    local mCrossinfo = uobjs.getModel('wcrossinfo')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    -- 检测是否报名
    local worldserver = require "model.worldserverin"
    local cross = worldserver.new()
    local ApplyData =cross:getUserApplyData(mMatchinfo.bid,zoneid,uid)

    local tinfo=json.decode(ApplyData.tinfo)
    if not next(ApplyData) then
        return response
    end
    local savedata={}
    local data={}
    if next(strategy) and type(strategy)=="table" then
        savedata.strategy=json.encode(strategy)
        tinfo.sts=getClientTs()
        savedata.tinfo=json.encode(tinfo)
        data.strategy=strategy
    end
    
    if type(line)=="table" and next(line) then
        savedata.line=json.encode(line)
        if type(tinfo)~="table" then  tinfo={} end 
        local troops =tinfo.troops or {}
        if next(troops) then
            local binfo,flag=mTroop.getFleetdata(troops[line[1]],troops[line[2]],troops[line[3]],tinfo.hero,line,nil,tinfo.equip,tinfo.plane)
            data.binfo=binfo
            tinfo.flag=flag
        else
            savedata.line=nil
        end
    end

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
    data.jointype=tonumber(ApplyData.jointype)
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
    
   
    local ret = cross:updateUserApplyData(ApplyData.id,savedata)
    if not ret then
        response.ret=-22005 
        return response
    end

    if uobjs.save() then 
        response.ret = 0        
        response.msg = 'Success'
    end


    return response
end